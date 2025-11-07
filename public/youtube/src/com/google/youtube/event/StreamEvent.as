package com.google.youtube.event
{
   import flash.events.Event;
   
   public class StreamEvent extends Event
   {
      
      public static var STREAM:String;
      
      public static const FIRSTBYTE:int = 0;
      
      public static const DONE:int = 1;
      
      public var streamState:int;
      
      public function StreamEvent(param1:String, param2:int)
      {
         super(param1);
         this.streamState = param2;
      }
      
      override public function clone() : Event
      {
         return new StreamEvent(type,this.streamState);
      }
   }
}

registerEvents(StreamEvent);

