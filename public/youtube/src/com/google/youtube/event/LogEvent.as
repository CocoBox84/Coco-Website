package com.google.youtube.event
{
   import com.google.utils.RequestVariables;
   import flash.events.Event;
   
   public class LogEvent extends Event
   {
      
      public static var LOG:String;
      
      public static var TIMING:String;
      
      public static var PLAYBACK:String;
      
      public var args:RequestVariables;
      
      public var message:String;
      
      public function LogEvent(param1:String, param2:String = "", param3:RequestVariables = null)
      {
         this.args = param3;
         this.message = param2;
         super(param1,false,false);
      }
      
      override public function clone() : Event
      {
         return new LogEvent(type,this.message,this.args);
      }
   }
}

registerEvents(LogEvent);

