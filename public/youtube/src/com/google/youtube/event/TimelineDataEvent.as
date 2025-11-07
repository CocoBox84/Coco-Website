package com.google.youtube.event
{
   import flash.events.Event;
   
   public class TimelineDataEvent extends Event
   {
      
      public var colors:Array;
      
      public var time:uint;
      
      public var text:String;
      
      public function TimelineDataEvent(param1:String, param2:uint, param3:String, param4:Array)
      {
         this.time = param2;
         this.text = param3;
         this.colors = param4;
         super(param1,false,false);
      }
   }
}

