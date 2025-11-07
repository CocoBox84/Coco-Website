package com.google.youtube.players
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.VideoData;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.geom.Rectangle;
   import flash.net.NetStream;
   
   public interface IVideoPlayer extends IEventDispatcher
   {
      
      function get stream() : NetStream;
      
      function getPlayerState() : IPlayerState;
      
      function stop() : void;
      
      function unrecoverableError(param1:String = null) : void;
      
      function onInterstitialComplete(param1:Event) : void;
      
      function get videoUrlProvider() : IVideoUrlProvider;
      
      function captureFrame(param1:Boolean = true) : BitmapData;
      
      function showInterstitial() : Boolean;
      
      function setVideoData(param1:VideoData) : void;
      
      function splice(param1:VideoData = null) : void;
      
      function needsCorrectAspect() : Boolean;
      
      function set playbackRate(param1:Number) : void;
      
      function getBytesTotal() : Number;
      
      function getVolume() : Number;
      
      function getDuration() : Number;
      
      function getTime() : Number;
      
      function initiatePlayback() : void;
      
      function getVideoData() : VideoData;
      
      function getDisplayRect() : Rectangle;
      
      function getVideoRect() : Rectangle;
      
      function isCached(param1:Number) : Boolean;
      
      function getBytesLoaded() : Number;
      
      function end() : void;
      
      function setVolume(param1:Number) : void;
      
      function getLoadedFraction() : Number;
      
      function setIgnorePeggedToLive(param1:Boolean) : void;
      
      function resetVideoSurface(param1:DisplayObject = null) : void;
      
      function get playbackRate() : Number;
      
      function getDefaultVideoSurface() : DisplayObject;
      
      function getPlayerInfo(param1:PlayerInfo) : void;
      
      function isStageVideoAvailable() : Boolean;
      
      function isPeggedToLive() : Boolean;
      
      function resetStream(param1:Boolean = true) : void;
      
      function getBufferEmptyEvents() : Number;
      
      function isTagStreaming() : Boolean;
      
      function getFPS() : Number;
      
      function resize(param1:Number, param2:Number, param3:Boolean = true) : void;
      
      function initiateSplice() : void;
      
      function pause() : void;
      
      function seek(param1:Number, param2:Boolean = true) : void;
      
      function destroy() : void;
      
      function play(param1:VideoData = null) : void;
      
      function getLoggingOptions() : Object;
      
      function getBuffers() : Array;
      
      function get availablePlaybackRates() : Array;
   }
}

