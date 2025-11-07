package com.google.youtube.event
{
   import flash.events.Event;
   
   public class SeekEvent extends Event
   {
      
      public static var COMPLETE:String;
      
      public static var START:String;
      
      public static var SEEK:String;
      
      public static var CLEAR_CLIP:String;
      
      public var time:Number;
      
      public function SeekEvent(param1:String, param2:Number)
      {
         this.time = param2;
         super(param1,true,false);
      }
      
      override public function clone() : Event
      {
         return new SeekEvent(type,this.time);
      }
   }
}

registerEvents(SeekEvent);

