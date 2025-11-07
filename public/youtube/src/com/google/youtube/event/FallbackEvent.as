package com.google.youtube.event
{
   import flash.events.Event;
   
   public class FallbackEvent extends Event
   {
      
      public static var FALLBACK:String;
      
      public static const UNKNOWN:String = "0";
      
      public static const TRUNCATED_AUDIO:String = "1";
      
      public static const MP4_EOF:String = "2";
      
      public static const MP4_PARSE:String = "3";
      
      public var errorCode:String;
      
      public function FallbackEvent(param1:String, param2:String = "0")
      {
         this.errorCode = param2;
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new FallbackEvent(type);
      }
   }
}

registerEvents(FallbackEvent);

