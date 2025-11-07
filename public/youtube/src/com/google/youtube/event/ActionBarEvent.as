package com.google.youtube.event
{
   import com.google.youtube.model.VideoData;
   import flash.events.Event;
   
   public class ActionBarEvent extends Event
   {
      
      public static var DISLIKE:String;
      
      public static var NAVIGATE_TO_YOUTUBE:String;
      
      public static var NAVIGATE_TO_VIDEO_CHANNEL:String;
      
      public static var LIKE:String;
      
      public static var EXPAND:String;
      
      public static var COLLAPSE:String;
      
      public static var SHARE:String;
      
      public var videoData:VideoData;
      
      public function ActionBarEvent(param1:String, param2:VideoData = null)
      {
         this.videoData = param2;
         super(param1,true,false);
      }
      
      override public function clone() : Event
      {
         return new ActionBarEvent(type,this.videoData);
      }
   }
}

registerEvents(ActionBarEvent);

