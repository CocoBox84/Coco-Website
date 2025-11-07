package com.google.youtube.players
{
   import com.google.youtube.model.ExternalPlayerState;
   import com.google.youtube.model.StatsPlayerState;
   import com.google.youtube.model.VideoData;
   import flash.events.NetStatusEvent;
   
   public class PausedBufferingState extends PausedState implements IBufferingState, IStatsProviderState
   {
      
      public function PausedBufferingState(param1:IVideoPlayer)
      {
         super(param1);
      }
      
      override public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         switch(param1.info.code)
         {
            case "NetStream.Buffer.Full":
               if(videoPlayer.stream)
               {
                  videoPlayer.stream.pause();
               }
               return new PausedState(videoPlayer,false,true);
            case "NetStream.Pause.Notify":
               return new PausedState(videoPlayer);
            case "NetStream.Play.Stop":
               return new PausedState(videoPlayer,true);
            default:
               return this;
         }
      }
      
      override public function play(param1:VideoData = null) : IPlayerState
      {
         if(!param1 && videoPlayer.getVideoData() && Boolean(videoPlayer.stream))
         {
            videoPlayer.stream.resume();
            return new BufferingState(videoPlayer);
         }
         return super.play(param1);
      }
      
      override public function get externalId() : int
      {
         return ExternalPlayerState.BUFFERING;
      }
      
      override public function get statsStateId() : String
      {
         return StatsPlayerState.PAUSED_BUFFERING;
      }
      
      override public function pause() : IPlayerState
      {
         return this;
      }
   }
}

