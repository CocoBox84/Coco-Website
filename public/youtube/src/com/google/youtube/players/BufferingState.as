package com.google.youtube.players
{
   import com.google.youtube.model.ExternalPlayerState;
   import com.google.youtube.model.StatsPlayerState;
   import flash.events.NetStatusEvent;
   
   public class BufferingState extends BasePlayerState implements IBufferingState, IExternalState, IStatsProviderState
   {
      
      public function BufferingState(param1:IVideoPlayer)
      {
         super(param1);
      }
      
      override public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         switch(param1.info.code)
         {
            case "NetStream.Buffer.Full":
               return new PlayingState(videoPlayer);
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
         return StatsPlayerState.BUFFERING;
      }
      
      override public function pause() : IPlayerState
      {
         return new PausedBufferingState(videoPlayer);
      }
      
      public function get externalId() : int
      {
         return ExternalPlayerState.BUFFERING;
      }
   }
}

