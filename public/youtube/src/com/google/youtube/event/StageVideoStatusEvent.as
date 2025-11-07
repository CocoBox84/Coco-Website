package com.google.youtube.event
{
   import flash.events.Event;
   
   public class StageVideoStatusEvent extends Event
   {
      
      public static var UNAVAILABLE:String;
      
      public static var AVAILABLE:String;
      
      public function StageVideoStatusEvent(param1:String, param2:Boolean = false)
      {
         super(param1,param2,false);
      }
   }
}

registerEvents(StageVideoStatusEvent);

