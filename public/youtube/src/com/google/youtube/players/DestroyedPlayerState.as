package com.google.youtube.players
{
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.model.VideoData;
   import flash.events.ErrorEvent;
   import flash.events.NetStatusEvent;
   
   public class DestroyedPlayerState implements IPlayerState
   {
      
      public function DestroyedPlayerState(param1:IVideoPlayer)
      {
         super();
      }
      
      public function onNewVideoData(param1:GetVideoInfoEvent) : IPlayerState
      {
         return this;
      }
      
      public function unrecoverableError(param1:String = null) : IPlayerState
      {
         return this;
      }
      
      public function splice(param1:VideoData) : IPlayerState
      {
         return this;
      }
      
      public function get isPeggedToLive() : Boolean
      {
         return false;
      }
      
      public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         return this;
      }
      
      public function onNewVideoDataError(param1:ErrorEvent) : IPlayerState
      {
         return this;
      }
      
      public function pause() : IPlayerState
      {
         return this;
      }
      
      public function seek(param1:Number, param2:Boolean) : IPlayerState
      {
         return this;
      }
      
      public function set videoPlayer(param1:IVideoPlayer) : void
      {
      }
      
      public function play(param1:VideoData = null) : IPlayerState
      {
         return this;
      }
      
      public function get videoPlayer() : IVideoPlayer
      {
         return null;
      }
   }
}

