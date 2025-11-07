package com.google.youtube.players
{
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.model.StatsPlayerState;
   import com.google.youtube.model.VideoData;
   import flash.events.ErrorEvent;
   import flash.events.NetStatusEvent;
   
   public class ErrorState extends BasePlayerState implements IStatsProviderState
   {
      
      public var error:ErrorEvent;
      
      public function ErrorState(param1:IVideoPlayer, param2:ErrorEvent = null)
      {
         super(param1);
         this.error = param2;
      }
      
      override public function onNewVideoData(param1:GetVideoInfoEvent) : IPlayerState
      {
         return this;
      }
      
      override public function seek(param1:Number, param2:Boolean) : IPlayerState
      {
         return this;
      }
      
      public function get statsStateId() : String
      {
         return StatsPlayerState.ERROR;
      }
      
      override public function play(param1:VideoData = null) : IPlayerState
      {
         return super.play(param1 || videoPlayer.getVideoData());
      }
      
      override public function pause() : IPlayerState
      {
         return this;
      }
      
      override public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         return this;
      }
   }
}

