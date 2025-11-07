package com.google.youtube.event
{
   import flash.events.Event;
   
   public class TweenEvent extends Event
   {
      
      public static var START:String;
      
      public static var UPDATE:String;
      
      public static var END:String;
      
      public function TweenEvent(param1:String, param2:Boolean = false)
      {
         super(param1,param2,false);
      }
   }
}

registerEvents(TweenEvent);

