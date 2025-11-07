package com.google.utils
{
   public class DownloadTimer
   {
      
      protected var endTime:Number;
      
      protected var startBytes:Number;
      
      protected var startTime:Number;
      
      protected var endBytes:Number;
      
      protected var firstSample:Boolean;
      
      public function DownloadTimer(param1:Number, param2:Number)
      {
         super();
         this.resetEstimator(param1,param2);
      }
      
      public function getSize() : Number
      {
         return this.endBytes - this.startBytes;
      }
      
      public function clearHistory() : void
      {
         this.startBytes = this.endBytes;
         this.startTime = this.endTime;
      }
      
      public function getDuration() : Number
      {
         return this.endTime - this.startTime;
      }
      
      public function addData(param1:Number, param2:Number) : void
      {
         if(param1 < this.endBytes)
         {
            this.resetEstimator(param1,param2);
         }
         else if(param1 > this.endBytes)
         {
            this.endBytes = param1;
            this.endTime = param2;
            if(this.firstSample)
            {
               this.clearHistory();
               this.firstSample = false;
            }
         }
      }
      
      public function resetEstimator(param1:Number, param2:Number) : void
      {
         this.startBytes = this.endBytes = param1;
         this.startTime = this.endTime = param2;
         this.firstSample = true;
      }
   }
}

