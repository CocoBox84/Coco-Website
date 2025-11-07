package com.google.youtube.players.tagstream.bytesource
{
   import com.google.utils.Scheduler;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.players.tagstream.PipelineEventDispatcher;
   import com.google.youtube.players.tagstream.TagStream;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.utils.ByteArray;
   
   public class ThrottledByteSource extends PipelineEventDispatcher implements IByteSource
   {
      
      protected static const SCHEDULER:Object = Scheduler;
      
      protected static const THROTTLE_FACTOR:Number = 0.75;
      
      protected static const THROTTLE_THRESHOLD:uint = 40000;
      
      protected static const SYNTHETIC_PROGRESS_INTERVAL:uint = 1000;
      
      protected var progressScheduler:Scheduler;
      
      protected var throttleBytesPerSecond:uint;
      
      protected var leftoverBytes:uint;
      
      protected var lastReadTime:uint;
      
      protected var tagStream:TagStream;
      
      protected var upstream:IByteSource;
      
      public function ThrottledByteSource(param1:TagStream, param2:VideoFormat, param3:IByteSource)
      {
         super();
         this.tagStream = param1;
         this.throttleBytesPerSecond = THROTTLE_FACTOR * param2.byteRate;
         this.upstream = param3;
         this.progressScheduler = SCHEDULER.setInterval(SYNTHETIC_PROGRESS_INTERVAL,this.dispatchProgress);
         this.progressScheduler.stop();
      }
      
      public function get eof() : Boolean
      {
         return this.upstream.eof;
      }
      
      protected function get allowedBytes() : uint
      {
         return this.tagStream.readAhead >= THROTTLE_THRESHOLD ? uint(this.leftoverBytes + (Scheduler.clock() - this.lastReadTime) * this.throttleBytesPerSecond / 1000) : uint.MAX_VALUE;
      }
      
      public function open(param1:SeekPoint) : void
      {
         this.lastReadTime = Scheduler.clock();
         forwardEvents(this.upstream,true);
         this.upstream.open(param1);
         this.progressScheduler.restart();
      }
      
      protected function dispatchProgress(param1:Event) : void
      {
         if(Scheduler.clock() - this.lastReadTime >= SYNTHETIC_PROGRESS_INTERVAL && this.allowedBytes && !this.eof)
         {
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
         }
      }
      
      public function info(param1:PlayerInfo) : void
      {
         this.upstream.info(param1);
      }
      
      public function close() : void
      {
         stopForwardingEvents(this.upstream,true);
         this.upstream.close();
         this.progressScheduler.stop();
      }
      
      public function read(param1:ByteArray, param2:uint, param3:uint) : uint
      {
         var _loc4_:uint = 0;
         param3 = Math.min(param3,this.allowedBytes);
         if(param3)
         {
            _loc4_ = uint(this.upstream.read(param1,param2,param3));
            if(this.allowedBytes != uint.MAX_VALUE)
            {
               this.leftoverBytes = this.allowedBytes - _loc4_;
            }
         }
         this.lastReadTime = Scheduler.clock();
         return _loc4_;
      }
   }
}

