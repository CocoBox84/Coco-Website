package com.google.youtube.event
{
   import flash.events.MouseEvent;
   
   public class MouseActivityEvent extends MouseEvent
   {
      
      public static var IDLE:String;
      
      public static var ACTIVE:String;
      
      public function MouseActivityEvent(param1:String, param2:Boolean = true)
      {
         super(param1,param2,false);
      }
   }
}

registerEvents(MouseActivityEvent);

