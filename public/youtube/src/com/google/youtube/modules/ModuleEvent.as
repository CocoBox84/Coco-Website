package com.google.youtube.modules
{
   import flash.events.Event;
   
   public class ModuleEvent extends Event
   {
      
      public static var COMMAND_NAVIGATE_TO_URL:String;
      
      public static var COMMAND_CUE:String;
      
      public static var COMMAND_LOAD_ID:String;
      
      public static var COMMAND_LIKE_PLAYLIST_CLIP:String;
      
      public static var COMMAND_SEEK:String;
      
      public static var COMMAND_RESET_LAYER:String;
      
      public static var COMMAND_LOG:String;
      
      public static var API_CHANGE:String;
      
      public static var COMMAND_STOP:String;
      
      public static var COMMAND_SHARE_PLAYLIST_CLIP:String;
      
      public static var COMMAND:String;
      
      public static var COMMAND_MUTE:String;
      
      public static var COMMAND_SELECT_PLAYLIST_CLIP:String;
      
      public static var CHANGE:String;
      
      public static var COMMAND_REMOVE_CUERANGE:String;
      
      public static var BUTTON_VISIBILITY_CHANGE:String;
      
      public static var COMMAND_PAUSE:String;
      
      public static var COMMAND_UNMUTE:String;
      
      public static var COMMAND_PLAY:String;
      
      public static var COMMAND_RESIZE:String;
      
      public static var COMMAND_REMOVE_FACEPLATE:String;
      
      public static var COMMAND_LOG_TIMING:String;
      
      public static var COMMAND_CUE_ID:String;
      
      public static var COMMAND_RELEASE_CUERANGE:String;
      
      public static var COMMAND_SET_LAYER:String;
      
      public static var COMMAND_PREROLL_READY:String;
      
      public static var COMMAND_LOAD:String;
      
      public static var COMMAND_ADD_CUERANGE:String;
      
      public var command:String;
      
      public var module:ModuleDescriptor;
      
      public var args:Array;
      
      public function ModuleEvent(param1:String, param2:ModuleDescriptor, param3:String = null, ... rest)
      {
         this.module = param2;
         this.command = param3;
         this.args = rest;
         super(param1,false,false);
      }
      
      override public function clone() : Event
      {
         var _loc1_:ModuleEvent = new ModuleEvent(type,this.module);
         _loc1_.command = this.command;
         _loc1_.args = this.args;
         return _loc1_;
      }
   }
}

import com.google.youtube.event.registerEvents;

registerEvents(ModuleEvent);

