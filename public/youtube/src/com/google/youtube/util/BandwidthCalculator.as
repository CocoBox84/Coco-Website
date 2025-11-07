package com.google.youtube.util
{
   public class BandwidthCalculator
   {
      
      protected static const WINDOW:Number = 8;
      
      protected var window:SlidingPercentile;
      
      public function BandwidthCalculator(param1:Number = 8)
      {
         super();
         this.window = new SlidingPercentile(param1);
      }
      
      public function addSample(param1:BandwidthSample) : void
      {
         var _loc2_:uint = param1.bytes;
         var _loc3_:int = param1.endTime - param1.startTime;
         if(!_loc2_ || !_loc3_)
         {
            return;
         }
         var _loc4_:Number = 1000 * _loc2_ / _loc3_;
         this.window.addSample(this.getSampleWeight(param1),_loc4_);
      }
      
      protected function getSampleWeight(param1:BandwidthSample) : Number
      {
         var _loc2_:Number = param1.bytes;
         _loc2_ /= param1.formatByteRate;
         var _loc3_:Number = (param1.endTime - param1.startTime) / 1000;
         return Math.min(_loc3_ + _loc2_,WINDOW / 2.2);
      }
      
      public function getEstimate(param1:Number = 0.5) : Number
      {
         return this.window.percentile(param1);
      }
   }
}

