package com.google.youtube.modules
{
   import com.google.youtube.application.IApplication;
   import com.google.youtube.event.VideoProgressEvent;
   import com.google.youtube.model.VideoDataEvent;
   import com.google.youtube.players.IVideoPlayer;
   import com.google.youtube.players.StateChangeEvent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   
   public interface IModule extends IApplication
   {
      
      function onPlayerStateChange(param1:StateChangeEvent) : void;
      
      function onKeyDown(param1:KeyboardEvent) : void;
      
      function getLoggingOptions() : Object;
      
      function onVideoDataChange(param1:VideoDataEvent) : void;
      
      function get player() : IVideoPlayer;
      
      function set player(param1:IVideoPlayer) : void;
      
      function onProgress(param1:VideoProgressEvent) : void;
      
      function set descriptor(param1:ModuleDescriptor) : void;
      
      function onUnload(param1:Event) : void;
      
      function get descriptor() : ModuleDescriptor;
   }
}

