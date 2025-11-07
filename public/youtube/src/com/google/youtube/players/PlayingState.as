package com.google.youtube.players
{
   import com.google.youtube.model.ExternalPlayerState;
   import com.google.youtube.model.StatsPlayerState;
   import flash.events.NetStatusEvent;
   
   public class PlayingState extends BasePlayerState implements IPlayingState, IExternalState, IStatsProviderState
   {
      
      public function PlayingState(param1:IVideoPlayer)
      {
         super(param1);
      }
      
      override public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         var _loc2_:Number = NaN;
         switch(param1.info.code)
         {
            case "NetStream.Buffer.Empty":
               if(!videoPlayer.getVideoData().isTransportRtmp())
               {
                  _loc2_ = videoPlayer.getVideoData().duration;
                  if(videoPlayer.getBytesLoaded() == videoPlayer.getBytesTotal() && videoPlayer.getTime() > _loc2_ - 1 && Boolean(_loc2_))
                  {
                     return this;
                  }
               }
               return new BufferingState(videoPlayer);
            default:
               return super.onNetStatus(param1);
         }
      }
      
      override public function get isPeggedToLive() : Boolean
      {
         return recentlyPeggedToLive();
      }
      
      public function get statsStateId() : String
      {
         return StatsPlayerState.PLAYING;
      }
      
      override public function pause() : IPlayerState
      {
         if(videoPlayer.stream)
         {
            videoPlayer.stream.pause();
         }
         return super.pause();
      }
      
      public function get externalId() : int
      {
         return ExternalPlayerState.PLAYING;
      }
   }
}

