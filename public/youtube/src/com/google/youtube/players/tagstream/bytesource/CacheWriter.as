package com.google.youtube.players.tagstream.bytesource
{
   import com.google.utils.Scheduler;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.players.tagstream.PipelineEventDispatcher;
   import com.google.youtube.util.MediaLocation;
   import flash.events.ProgressEvent;
   import flash.utils.getTimer;
   
   public class CacheWriter extends PipelineEventDispatcher
   {
      
      protected var buffer:HttpDiskByteSource;
      
      protected var cache:BufferCache;
      
      protected const READAHEAD:uint = 40000;
      
      protected var fmt:VideoFormat;
      
      protected var chunkSize:uint;
      
      protected var lastLoadStartTime:uint;
      
      protected var lastConsecutiveByte:uint;
      
      protected var outputPositionValue:uint;
      
      protected var lastBufferDuration:uint;
      
      protected var loadScheduler:Scheduler;
      
      protected var mediaLocation:MediaLocation;
      
      public function CacheWriter(param1:BufferCache, param2:VideoFormat, param3:MediaLocation)
      {
         super();
         this.cache = param1;
         this.fmt = param2;
         this.mediaLocation = param3;
         this.chunkSize = ChunkByteSource.chunkSize(param3);
      }
      
      public function get loadedTime() : uint
      {
         return this.fmt.formatIndex.getTimeFromByte(this.buffer ? this.buffer.end : this.lastConsecutiveByte);
      }
      
      public function stop() : void
      {
         if(this.buffer)
         {
            stopForwardingEvents(this.buffer,false);
            this.buffer.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
            if(!this.buffer.complete)
            {
               this.buffer.streamClose();
            }
            this.cache.addBuffer(this.buffer);
            this.buffer = null;
         }
         if(this.loadScheduler)
         {
            this.loadScheduler.stop();
            this.loadScheduler = null;
         }
      }
      
      public function get bytesLoaded() : uint
      {
         return this.buffer ? this.buffer.end : this.lastConsecutiveByte;
      }
      
      protected function getReadahead(param1:uint) : uint
      {
         var _loc2_:uint = this.getTimeFromByte(param1);
         var _loc3_:uint = this.getTimeFromByte(this.outputPositionValue);
         return _loc2_ > _loc3_ ? uint(_loc2_ - _loc3_) : 0;
      }
      
      protected function onBufferComplete() : void
      {
         var _loc1_:uint = 0;
         stopForwardingEvents(this.buffer,false);
         this.buffer.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this.cache.addBuffer(this.buffer);
         if(this.buffer.length == this.buffer.desiredLength)
         {
            _loc1_ = this.buffer.end;
            this.buffer = null;
            this.scheduleLoad(this.getNextRange(_loc1_));
         }
         else
         {
            this.lastConsecutiveByte = _loc1_;
            this.buffer.last = true;
            this.buffer = null;
         }
      }
      
      public function set outputPosition(param1:uint) : void
      {
         this.outputPositionValue = param1;
      }
      
      protected function scheduleLoad(param1:Object) : void
      {
         if(!param1)
         {
            this.lastConsecutiveByte = this.cache.lastByte;
            return;
         }
         this.lastConsecutiveByte = param1.start;
         if(this.getReadahead(param1.start) < this.READAHEAD)
         {
            this.loadRangeNow(param1);
         }
         else
         {
            this.loadRangeLater(param1);
         }
      }
      
      protected function loadRangeLater(param1:Object) : void
      {
         var waitTime:uint;
         var downloadTime:uint;
         var range:Object = param1;
         var now:uint = uint(getTimer());
         this.lastLoadStartTime = this.lastLoadStartTime || now;
         downloadTime = uint(now - this.lastLoadStartTime);
         waitTime = Math.max(0,this.lastBufferDuration - downloadTime);
         this.loadScheduler = Scheduler.setTimeout(waitTime,function():void
         {
            loadRangeNow(range);
         });
      }
      
      public function get loadingBuffer() : HttpDiskByteSource
      {
         return this.buffer;
      }
      
      protected function onProgress(param1:ProgressEvent) : void
      {
         if(this.buffer.complete)
         {
            this.onBufferComplete();
         }
         dispatchEvent(param1);
      }
      
      public function info(param1:PlayerInfo) : void
      {
         if(this.buffer)
         {
            this.buffer.info(param1);
         }
      }
      
      protected function getNextRange(param1:uint) : Object
      {
         var _loc2_:Object = this.cache.getGap(param1);
         if(!_loc2_)
         {
            return null;
         }
         this.lastConsecutiveByte = _loc2_.start;
         var _loc3_:uint = _loc2_.start + this.chunkSize;
         _loc3_ -= _loc3_ % this.chunkSize;
         _loc3_ = _loc2_.end ? uint(Math.min(_loc3_,_loc2_.end)) : _loc3_;
         return {
            "start":_loc2_.start,
            "end":_loc3_
         };
      }
      
      protected function loadRangeNow(param1:Object) : void
      {
         this.buffer = new HttpDiskByteSource(this.mediaLocation);
         this.buffer.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         forwardEvents(this.buffer,false);
         var _loc2_:SeekPoint = new SeekPoint();
         _loc2_.byteOffset = param1.start;
         _loc2_.byteLength = param1.end - param1.start;
         var _loc3_:uint = this.getTimeFromByte(param1.start);
         var _loc4_:uint = this.getTimeFromByte(param1.end);
         this.lastBufferDuration = _loc4_ - _loc3_;
         this.lastLoadStartTime = getTimer();
         this.buffer.open(_loc2_);
      }
      
      protected function getTimeFromByte(param1:uint) : uint
      {
         return this.fmt.formatIndex.getTimeFromByte(param1);
      }
      
      public function startFilling(param1:uint) : void
      {
         this.outputPositionValue = param1;
         this.scheduleLoad(this.getNextRange(param1));
      }
   }
}

