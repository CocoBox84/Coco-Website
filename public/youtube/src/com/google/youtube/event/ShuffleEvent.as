package com.google.youtube.event
{
   import flash.events.Event;
   
   public class ShuffleEvent extends Event
   {
      
      public static var CHANGE:String;
      
      public function ShuffleEvent(param1:String, param2:Boolean = true)
      {
         super(param1,param2,false);
      }
   }
}

registerEvents(ShuffleEvent);

