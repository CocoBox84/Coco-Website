package com.google.youtube.players
{
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.model.ExternalPlayerState;
   import com.google.youtube.model.StatsPlayerState;
   
   public class NotStartedState extends BasePlayerState implements IExternalState, IPausedState, IStatsProviderState
   {
      
      public function NotStartedState(param1:IVideoPlayer)
      {
         super(param1);
      }
      
      override public function onNewVideoData(param1:GetVideoInfoEvent) : IPlayerState
      {
         return this;
      }
      
      override public function pause() : IPlayerState
      {
         return this;
      }
      
      public function get externalId() : int
      {
         return ExternalPlayerState.UNSTARTED;
      }
      
      public function get statsStateId() : String
      {
         return StatsPlayerState.NOTSTARTED;
      }
   }
}

