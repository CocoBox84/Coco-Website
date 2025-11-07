package com.google.youtube.time
{
   import flash.events.Event;
   
   public class CueRangeEvent extends Event
   {
      
      public static var ADD:String;
      
      public static var LOCK_BLOCK_EXIT:String;
      
      public static var CHANGE:String;
      
      public static var LOCK_BLOCK_ENTER:String;
      
      public static var REMOVE:String;
      
      public static var ENTER:String;
      
      public static var EXIT:String;
      
      public var cueRange:CueRange;
      
      public function CueRangeEvent(param1:String, param2:CueRange, param3:Boolean = false)
      {
         this.cueRange = param2;
         super(param1,param3,false);
      }
      
      override public function clone() : Event
      {
         return new CueRangeEvent(type,this.cueRange,bubbles);
      }
   }
}

import com.google.youtube.event.registerEvents;

registerEvents(CueRangeEvent);

