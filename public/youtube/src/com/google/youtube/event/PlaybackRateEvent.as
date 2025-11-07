package com.google.youtube.event
{
   import flash.events.Event;
   
   public class PlaybackRateEvent extends Event
   {
      
      public static var RATE_CHANGE:String;
      
      public var playbackRate:Number;
      
      public function PlaybackRateEvent(param1:String, param2:Number)
      {
         this.playbackRate = param2;
         super(param1,true,false);
      }
      
      override public function clone() : Event
      {
         return new PlaybackRateEvent(type,this.playbackRate);
      }
   }
}

registerEvents(PlaybackRateEvent);

