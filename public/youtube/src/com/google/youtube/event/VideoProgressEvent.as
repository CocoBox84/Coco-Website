package com.google.youtube.event
{
   import flash.events.Event;
   import flash.events.ProgressEvent;
   
   public class VideoProgressEvent extends ProgressEvent
   {
      
      public static const PROGRESS:String = ProgressEvent.PROGRESS;
      
      public var duration:Number;
      
      public var loadedFraction:Number;
      
      public var time:Number;
      
      public function VideoProgressEvent(param1:String, param2:Number = 0, param3:Number = 0, param4:Number = 0, param5:Number = 0, param6:Number = 0, param7:Boolean = false)
      {
         this.time = param2;
         this.duration = param3;
         this.loadedFraction = param6;
         super(param1,param7,false,param4,param5);
      }
      
      override public function clone() : Event
      {
         return new VideoProgressEvent(type,this.time,this.duration,bytesLoaded,bytesTotal);
      }
   }
}

