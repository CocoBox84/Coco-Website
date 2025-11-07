package com.google.youtube.players
{
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.model.ExternalPlayerState;
   import com.google.youtube.model.StatsPlayerState;
   import com.google.youtube.model.VideoData;
   import flash.events.NetStatusEvent;
   
   public class PausedState extends BasePlayerState implements IPausedState, IExternalState, IStatsProviderState
   {
      
      public var triggeredByBufferFull:Boolean;
      
      public var triggeredByStream:Boolean;
      
      public function PausedState(param1:IVideoPlayer, param2:Boolean = false, param3:Boolean = false)
      {
         this.triggeredByStream = param2;
         this.triggeredByBufferFull = param3;
         super(param1);
      }
      
      public function get statsStateId() : String
      {
         return StatsPlayerState.PAUSED;
      }
      
      override public function onNewVideoData(param1:GetVideoInfoEvent) : IPlayerState
      {
         videoPlayer.initiatePlayback();
         return new SeekingPausedState(videoPlayer);
      }
      
      public function get externalId() : int
      {
         return ExternalPlayerState.PAUSED;
      }
      
      override protected function seekUnbuffered(param1:Number) : IPlayerState
      {
         var _loc2_:IPlayerState = super.seekUnbuffered(param1);
         if(_loc2_ is ErrorState)
         {
            return _loc2_;
         }
         return new SeekingPausedState(videoPlayer,param1,true);
      }
      
      override public function play(param1:VideoData = null) : IPlayerState
      {
         if(!param1 && videoPlayer.getVideoData() && Boolean(videoPlayer.stream))
         {
            videoPlayer.stream.resume();
            return new PlayingState(videoPlayer);
         }
         return super.play(param1);
      }
      
      override public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Start":
               return new PausedBufferingState(videoPlayer);
            case "NetStream.Buffer.Full":
               if(videoPlayer.stream)
               {
                  videoPlayer.stream.pause();
               }
         }
         return this;
      }
      
      override public function seek(param1:Number, param2:Boolean) : IPlayerState
      {
         var _loc3_:IPlayerState = super.seek(param1,param2);
         if(_loc3_ is ErrorState)
         {
            return _loc3_;
         }
         return new SeekingPausedState(videoPlayer,param1,param2);
      }
      
      override public function pause() : IPlayerState
      {
         return this;
      }
   }
}

