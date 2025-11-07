package com.google.youtube.players
{
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.model.VideoData;
   import flash.events.ErrorEvent;
   import flash.events.NetStatusEvent;
   
   public interface IPlayerState
   {
      
      function unrecoverableError(param1:String = null) : IPlayerState;
      
      function onNewVideoDataError(param1:ErrorEvent) : IPlayerState;
      
      function get isPeggedToLive() : Boolean;
      
      function onNewVideoData(param1:GetVideoInfoEvent) : IPlayerState;
      
      function onNetStatus(param1:NetStatusEvent) : IPlayerState;
      
      function play(param1:VideoData = null) : IPlayerState;
      
      function pause() : IPlayerState;
      
      function seek(param1:Number, param2:Boolean) : IPlayerState;
      
      function splice(param1:VideoData) : IPlayerState;
      
      function get videoPlayer() : IVideoPlayer;
      
      function set videoPlayer(param1:IVideoPlayer) : void;
   }
}

