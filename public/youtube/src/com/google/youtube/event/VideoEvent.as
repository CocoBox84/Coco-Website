package com.google.youtube.event
{
   import flash.events.Event;
   
   public class VideoEvent extends Event
   {
      
      public static var NET_STREAM_READY:String;
      
      public var data:Object;
      
      public function VideoEvent(param1:String, param2:Object = null, param3:Boolean = false)
      {
         this.data = param2;
         super(param1,param3,false);
      }
      
      override public function clone() : Event
      {
         return new VideoEvent(type,this.data,bubbles);
      }
   }
}

registerEvents(VideoEvent);

