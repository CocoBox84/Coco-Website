package com.google.youtube.event
{
   public class AdEvent extends VideoEvent
   {
      
      public static var STALL:String;
      
      public static var BUFFERING:String;
      
      public static var STOP:String;
      
      public static var SEEKING:String;
      
      public static var PAUSE:String;
      
      public static var STREAM_NOT_FOUND:String;
      
      public static var BREAK_END:String;
      
      public static var META_LOAD:String;
      
      public static var BREAK_START:String;
      
      public static var SEEK_TO:String;
      
      public static var PROGRESS:String;
      
      public static var PLAY:String;
      
      public static var SEEK:String;
      
      public static var END:String;
      
      public function AdEvent(param1:String, param2:Object = null, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

registerEvents(AdEvent);

