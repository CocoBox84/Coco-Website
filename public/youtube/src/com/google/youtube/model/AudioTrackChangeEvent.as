package com.google.youtube.model
{
   import flash.events.Event;
   
   public class AudioTrackChangeEvent extends Event
   {
      
      public static var CHANGE:String;
      
      public var track:String;
      
      public function AudioTrackChangeEvent(param1:String, param2:String)
      {
         this.track = param2;
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new AudioTrackChangeEvent(type,this.track);
      }
   }
}

import com.google.youtube.event.registerEvents;

registerEvents(AudioTrackChangeEvent);

