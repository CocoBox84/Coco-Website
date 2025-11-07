package com.google.youtube.model
{
   import com.google.utils.Scheduler;
   import com.google.youtube.util.BinarySearch;
   import com.google.youtube.util.hls.HlsPlaylist;
   import flash.events.Event;
   
   public class LiveMosaicLoader extends MosaicLoader
   {
      
      private static const MAX_ERRORS_BEFORE_GLOBAL_TIMEOUT:int = 10;
      
      private static const DEFAULT_IGNORE_MOSAIC_COUNT:int = 3;
      
      public var hlsPlaylist:HlsPlaylist;
      
      private var errorCount:int;
      
      private var timeouts:Object = {};
      
      private var ignoreMosaicCount:int;
      
      public function LiveMosaicLoader(param1:VideoStoryboard, param2:Boolean)
      {
         super(param1);
         this.ignoreMosaicCount = param2 ? DEFAULT_IGNORE_MOSAIC_COUNT : 0;
      }
      
      override public function getIntervalPercentageForTime(param1:Number) : Number
      {
         if(!this.hlsPlaylist)
         {
            return 0;
         }
         var _loc2_:uint = param1 * 1000;
         var _loc3_:int = BinarySearch.lessThanOrEqual(this.hlsPlaylist.chunkStartTime,_loc2_);
         if(_loc3_ < 0)
         {
            return 0;
         }
         var _loc4_:uint = _loc2_ - this.hlsPlaylist.chunkStartTime[_loc3_];
         return _loc4_ / this.hlsPlaylist.chunkDuration[_loc3_];
      }
      
      override protected function loadError() : void
      {
         var key:String;
         var level:int = 0;
         var mosaic:int = 0;
         ++this.errorCount;
         if(this.errorCount >= MAX_ERRORS_BEFORE_GLOBAL_TIMEOUT)
         {
            super.loadError();
            return;
         }
         key = loading.level + "_" + loading.mosaic;
         if(this.timeouts[key])
         {
            this.timeouts[key] *= 2;
         }
         else
         {
            this.timeouts[key] = 60000;
         }
         level = loading.level;
         mosaic = loading.mosaic;
         super.loadError();
         Scheduler.setTimeout(this.timeouts[key],function(param1:Event):void
         {
            storyboard.getLevel(level).setBitmapData(mosaic,null);
         });
      }
      
      override protected function loadNext() : void
      {
         if(this.errorCount >= MAX_ERRORS_BEFORE_GLOBAL_TIMEOUT)
         {
            queue = [];
            return;
         }
         super.loadNext();
      }
      
      override protected function onLoadComplete(param1:Event) : void
      {
         super.onLoadComplete(param1);
         this.errorCount = 0;
      }
      
      override public function getFrameForTime(param1:Number) : int
      {
         if(!this.hlsPlaylist)
         {
            return -1;
         }
         var _loc2_:uint = param1 * 1000;
         var _loc3_:int = BinarySearch.lessThanOrEqual(this.hlsPlaylist.chunkStartTime,_loc2_);
         var _loc4_:VideoStoryboardLevel = storyboard.getLevel(0);
         var _loc5_:int = _loc4_.rows * _loc4_.columns * this.ignoreMosaicCount;
         return _loc3_ > this.hlsPlaylist.chunkStartTime.length - _loc5_ ? -1 : _loc3_;
      }
   }
}

