package com.google.youtube.util
{
   public class BandwidthSample
   {
      
      public var startTime:uint;
      
      public var endTime:uint;
      
      public var bytes:uint;
      
      public var streamCount:uint;
      
      public var formatByteRate:Number;
      
      public function BandwidthSample()
      {
         super();
      }
      
      public function clone() : BandwidthSample
      {
         var _loc1_:BandwidthSample = new BandwidthSample();
         _loc1_.bytes = this.bytes;
         _loc1_.startTime = this.startTime;
         _loc1_.endTime = this.endTime;
         _loc1_.formatByteRate = this.formatByteRate;
         _loc1_.streamCount = this.streamCount;
         return _loc1_;
      }
   }
}

