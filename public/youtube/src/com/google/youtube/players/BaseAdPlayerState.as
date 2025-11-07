package com.google.youtube.players
{
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.model.VideoData;
   import flash.events.ErrorEvent;
   import flash.events.NetStatusEvent;
   
   public class BaseAdPlayerState implements IPlayerState
   {
      
      protected var videoPlayerValue:IVideoPlayer;
      
      protected var playerAdapter:PlayerAdapter;
      
      public function BaseAdPlayerState(param1:IVideoPlayer)
      {
         super();
         this.videoPlayer = param1;
      }
      
      public function unrecoverableError(param1:String = null) : IPlayerState
      {
         return new UnrecoverableErrorState(this.videoPlayer,null,param1);
      }
      
      public function onNewVideoData(param1:GetVideoInfoEvent) : IPlayerState
      {
         return null;
      }
      
      public function set videoPlayer(param1:IVideoPlayer) : void
      {
         this.videoPlayerValue = param1;
         this.playerAdapter = param1 as PlayerAdapter;
      }
      
      public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         return null;
      }
      
      public function get videoPlayer() : IVideoPlayer
      {
         return this.videoPlayerValue;
      }
      
      public function splice(param1:VideoData) : IPlayerState
      {
         return null;
      }
      
      public function get isPeggedToLive() : Boolean
      {
         return false;
      }
      
      public function onNewVideoDataError(param1:ErrorEvent) : IPlayerState
      {
         return null;
      }
      
      public function play(param1:VideoData = null) : IPlayerState
      {
         if(Boolean(this.playerAdapter) && this.playerAdapter.isAdPlayControllable())
         {
            this.playerAdapter.adPlay();
         }
         return null;
      }
      
      public function pause() : IPlayerState
      {
         if(Boolean(this.playerAdapter) && this.playerAdapter.isAdPlayControllable())
         {
            this.playerAdapter.adPause();
         }
         return null;
      }
      
      public function seek(param1:Number, param2:Boolean) : IPlayerState
      {
         return null;
      }
   }
}

