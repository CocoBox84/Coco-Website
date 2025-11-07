package com.google.youtube.players
{
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.model.ExternalPlayerState;
   import com.google.youtube.model.StatsPlayerState;
   import com.google.youtube.model.VideoData;
   import flash.events.NetStatusEvent;
   
   public class SeekingPausedState extends SeekingState implements IPausedState, IExternalState, IStatsProviderState
   {
      
      public function SeekingPausedState(param1:IVideoPlayer, param2:Number = NaN, param3:Boolean = true)
      {
         super(param1,param2,param3);
      }
      
      public function get externalId() : int
      {
         return ExternalPlayerState.PAUSED;
      }
      
      override public function onNewVideoData(param1:GetVideoInfoEvent) : IPlayerState
      {
         return new SeekingPausedState(videoPlayer);
      }
      
      override public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         var _loc2_:Number = NaN;
         var _loc3_:IPlayerState = null;
         if(pendingSeekRequest)
         {
            _loc2_ = pendingSeekRequest.length ? Number(pendingSeekRequest[0]) : seekTimeValue;
            _loc3_ = super.onNetStatus(param1);
            if(_loc3_ is SeekingState && !(_loc3_ is SeekingPausedState))
            {
               _loc3_ = new SeekingPausedState(videoPlayer,_loc2_,SeekingState(_loc3_).allowSeekAhead);
            }
            return _loc3_;
         }
         switch(param1.info.code)
         {
            case "NetStream.Play.Start":
               return new PausedBufferingState(videoPlayer);
            case "NetStream.Seek.Notify":
            case "NetStream.Buffer.Full":
               if(videoPlayer.stream)
               {
                  videoPlayer.stream.pause();
               }
               return new PausedState(videoPlayer);
            default:
               return super.onNetStatus(param1);
         }
      }
      
      override public function play(param1:VideoData = null) : IPlayerState
      {
         if(!param1 && Boolean(videoPlayer.getVideoData()))
         {
            if(videoPlayer.stream)
            {
               videoPlayer.stream.resume();
            }
            return new SeekingState(videoPlayer,seekTime,allowSeekAhead);
         }
         return super.play(param1);
      }
      
      override public function get statsStateId() : String
      {
         return StatsPlayerState.SEEKING_PAUSED;
      }
      
      override public function pause() : IPlayerState
      {
         return this;
      }
      
      override protected function seekUnbuffered(param1:Number) : IPlayerState
      {
         return super.seekUnbuffered(param1).pause();
      }
   }
}

