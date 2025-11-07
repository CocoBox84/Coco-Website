package com.google.youtube.event
{
   import com.google.youtube.util.BandwidthSample;
   import flash.events.Event;
   
   public class BandwidthSampleEvent extends Event
   {
      
      public static var SAMPLE:String;
      
      public var sample:BandwidthSample;
      
      public function BandwidthSampleEvent(param1:String, param2:BandwidthSample)
      {
         super(param1,true,false);
         this.sample = param2;
      }
      
      override public function clone() : Event
      {
         return new BandwidthSampleEvent(type,this.sample.clone());
      }
   }
}

registerEvents(BandwidthSampleEvent);

