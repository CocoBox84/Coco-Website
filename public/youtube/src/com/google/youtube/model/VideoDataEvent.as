package com.google.youtube.model
{
   import flash.events.Event;
   
   public class VideoDataEvent extends Event
   {
      
      public static var FORMAT_DISABLED:String;
      
      public static var NEW_VIDEO_DATA:String;
      
      public static var METADATA:String;
      
      public static var CHANGE:String;
      
      public static var VIDEO_INFO:String;
      
      public static var FORMAT_CHANGE:String;
      
      public var source:String;
      
      public var videoData:VideoData;
      
      public function VideoDataEvent(param1:String, param2:VideoData, param3:String = null, param4:Boolean = false)
      {
         this.videoData = param2;
         this.source = param3;
         super(param1,param4,false);
      }
      
      override public function clone() : Event
      {
         return new VideoDataEvent(type,this.videoData,this.source,bubbles);
      }
   }
}

import com.google.youtube.event.registerEvents;

registerEvents(VideoDataEvent);

