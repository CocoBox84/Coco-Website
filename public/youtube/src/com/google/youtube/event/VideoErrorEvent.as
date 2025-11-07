package com.google.youtube.event
{
   import flash.events.ErrorEvent;
   import flash.events.Event;
   
   public class VideoErrorEvent extends ErrorEvent
   {
      
      public static const ERROR:String = ErrorEvent.ERROR;
      
      public var errorCode:int;
      
      public function VideoErrorEvent(param1:String, param2:String = "", param3:int = 0)
      {
         this.errorCode = param3;
         super(param1,false,false,param2);
      }
      
      override public function clone() : Event
      {
         return new VideoErrorEvent(type,text,this.errorCode);
      }
   }
}

