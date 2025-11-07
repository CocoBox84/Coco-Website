package com.google.youtube.util
{
   import com.google.utils.Scheduler;
   import com.google.youtube.event.BandwidthSampleEvent;
   import com.google.youtube.event.StreamEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.ProgressEvent;
   
   public class BandwidthMeter extends EventDispatcher
   {
      
      protected static const SCHEDULER:Object = Scheduler;
      
      protected static const INTERVAL:uint = 1000;
      
      public var totalMediaRate:Number = 0;
      
      protected var accumulator:Number = 0;
      
      protected var streamCount:int = 0;
      
      protected var startTime:Number;
      
      protected var sampleTimer:Scheduler;
      
      public function BandwidthMeter()
      {
         super();
      }
      
      public function onStreamEvent(param1:StreamEvent) : void
      {
         if(param1.streamState == StreamEvent.FIRSTBYTE)
         {
            if(this.streamCount == 0)
            {
               this.accumulator = 0;
               this.startTime = Scheduler.clock();
               this.sampleTimer = SCHEDULER.setTimeout(INTERVAL,this.onTimer);
            }
            ++this.streamCount;
         }
         else if(param1.streamState == StreamEvent.DONE)
         {
            if(this.streamCount == 1)
            {
               this.sampleTimer.stop();
               this.cutSample();
            }
            --this.streamCount;
         }
      }
      
      public function onProgress(param1:ProgressEvent) : void
      {
         if(this.streamCount > 0)
         {
            this.accumulator += param1.bytesLoaded;
         }
      }
      
      protected function onTimer(param1:Event) : void
      {
         this.cutSample();
         this.sampleTimer = SCHEDULER.setTimeout(INTERVAL,this.onTimer);
      }
      
      protected function cutSample() : void
      {
         var _loc1_:Number = Scheduler.clock();
         var _loc2_:BandwidthSample = new BandwidthSample();
         _loc2_.bytes = this.accumulator;
         _loc2_.startTime = this.startTime;
         _loc2_.endTime = _loc1_;
         _loc2_.formatByteRate = this.totalMediaRate;
         _loc2_.streamCount = this.streamCount;
         dispatchEvent(new BandwidthSampleEvent(BandwidthSampleEvent.SAMPLE,_loc2_));
         this.accumulator = 0;
         this.startTime = _loc1_;
      }
   }
}

