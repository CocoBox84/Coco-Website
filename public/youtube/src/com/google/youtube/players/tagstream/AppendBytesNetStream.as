package com.google.youtube.players.tagstream
{
   import com.google.utils.Scheduler;
   import com.google.youtube.event.BandwidthSampleEvent;
   import com.google.youtube.event.FallbackEvent;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.tag.DataTag;
   import com.google.youtube.model.tag.ITag;
   import com.google.youtube.util.getDefinition;
   import flash.events.Event;
   import flash.events.NetStatusEvent;
   import flash.events.ProgressEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.utils.describeType;
   
   public class AppendBytesNetStream extends NetStream
   {
      
      protected static const SCHEDULER:Object = Scheduler;
      
      protected static const NetStreamAppendBytesAction:Object = getDefinition("flash.net.NetStreamAppendBytesAction");
      
      protected static const PROGRESS_INTERVAL:Number = 150;
      
      protected static var checkedAppendBytes:Boolean = false;
      
      protected static var hasAppendBytes:Boolean = false;
      
      public static var canSeekBuffered:Boolean = false;
      
      protected var desiredBufferLength:Number = 5;
      
      protected var progressScheduler:Scheduler;
      
      protected var bytesTotalValue:uint;
      
      protected var dataGenEnabled:Boolean;
      
      protected var timerStart:Number = 0;
      
      protected var pausedValue:Boolean = false;
      
      public var firstDataTime:Number = 0;
      
      public var disableTagStream:Boolean = false;
      
      protected var firstTagTimeout:Scheduler;
      
      public var appendedBytes:Boolean = false;
      
      protected var tagStream:TagStream;
      
      protected var durationValue:Number = 0;
      
      public function AppendBytesNetStream(param1:NetConnection, param2:TagStream, param3:Number)
      {
         super(param1);
         this.tagStream = param2;
         this.desiredBufferLength = param3 || this.desiredBufferLength;
         this.progressScheduler = SCHEDULER.setInterval(PROGRESS_INTERVAL,this.onProgress);
         this.progressScheduler.stop();
         param2.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         param2.addEventListener(BandwidthSampleEvent.SAMPLE,dispatchEvent);
         PipelineEventDispatcher.addErrorListenersTo(param2,dispatchEvent);
      }
      
      public static function isStreamingAvailable() : Boolean
      {
         if(Boolean(NetStreamAppendBytesAction) && !checkedAppendBytes)
         {
            checkedAppendBytes = true;
            hasAppendBytes = Boolean(describeType(NetStream).factory.method.(@name == "appendBytes").length());
         }
         return Boolean(NetStreamAppendBytesAction) && hasAppendBytes;
      }
      
      override public function pause() : void
      {
         this.pausedValue = true;
         super.pause();
      }
      
      public function get loadedTime() : Number
      {
         return this.tagStream.opened ? this.tagStream.loadedTime : (this.time + bufferLength) * 1000;
      }
      
      override public function get time() : Number
      {
         if(this.disableTagStream)
         {
            return super.time;
         }
         return super.time + Number(this.tagStream.startTime) / 1000;
      }
      
      protected function get readAheadLow() : Boolean
      {
         return bufferLength <= Math.max(this.desiredBufferLength,bufferTime + 0.5);
      }
      
      protected function feedTags() : void
      {
         var _loc2_:ITag = null;
         var _loc1_:* = !(super.time > 0.25 || this.pausedValue);
         while((this.readAheadLow || _loc1_) && this.tagStream.opened)
         {
            _loc2_ = this.tagStream.pop();
            if(!_loc2_)
            {
               break;
            }
            _loc2_.feed(this);
            if(!this.firstDataTime && _loc2_ is DataTag)
            {
               if(this.firstTagTimeout)
               {
                  this.firstTagTimeout.stop();
                  this.firstTagTimeout = null;
               }
               this.firstDataTime = new Date().getTime() - this.timerStart;
               dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{"code":"AppendBytesNetStream.Connect.Data"}));
               if(this.pausedValue)
               {
                  this.dispatchEventAsynchronously(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{"code":"NetStream.Buffer.Full"}));
               }
            }
            this.appendedBytes = true;
            _loc1_ = false;
         }
      }
      
      override public function get bytesTotal() : uint
      {
         return this.disableTagStream ? super.bytesTotal : this.bytesTotalValue;
      }
      
      override public function get bytesLoaded() : uint
      {
         return this.disableTagStream ? super.bytesLoaded : uint(Math.min(this.bytesTotal,this.loadedTime / 1000 / this.durationValue * this.bytesTotal));
      }
      
      protected function closeTagStream() : void
      {
         if(this.firstTagTimeout)
         {
            this.firstTagTimeout.stop();
            this.firstTagTimeout = null;
         }
         this.progressScheduler.stop();
         if(this.tagStream.opened)
         {
            this.tagStream.close();
         }
      }
      
      public function onProgress(param1:Event = null) : void
      {
         this.feedTags();
         if(this.tagStream.hasAudio && this.tagStream.opened && !this.readAheadLow && info.audioBufferLength < 0.5)
         {
            this.closeTagStream();
            dispatchEvent(new FallbackEvent(FallbackEvent.FALLBACK,FallbackEvent.TRUNCATED_AUDIO));
         }
      }
      
      override public function resume() : void
      {
         this.pausedValue = false;
         super.resume();
      }
      
      public function updateLoadedTotal(param1:Number, param2:VideoFormat) : void
      {
         this.durationValue = param1;
         this.bytesTotalValue = param1 * param2.byteRate;
      }
      
      protected function dispatchEventAsynchronously(param1:Event) : void
      {
         var event:Event = param1;
         SCHEDULER.setTimeout(0,function(param1:Event):void
         {
            dispatchEvent(event);
         });
      }
      
      override public function seek(param1:Number) : void
      {
         var _loc2_:String = null;
         if(!this.disableTagStream)
         {
            super.seek(0);
            super.resume();
            this.closeTagStream();
            _loc2_ = this.tagStream.isCached(param1) ? "AppendBytesNetStream.Seek.Notify" : "NetStream.Seek.InvalidTime";
            this.dispatchEventAsynchronously(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{"code":_loc2_}));
         }
         else
         {
            super.seek(param1);
         }
      }
      
      override public function play(... rest) : void
      {
         var _loc2_:uint = 0;
         if(!this.disableTagStream)
         {
            if(this.dataGenEnabled)
            {
               this.closeTagStream();
               super.seek(0);
            }
            else
            {
               super.play(null);
               this.dataGenEnabled = true;
            }
            this.timerStart = new Date().getTime();
            this.firstDataTime = 0;
            this.progressScheduler.restart();
            _loc2_ = this.tagStream.open();
            if(this.firstTagTimeout)
            {
               this.firstTagTimeout.stop();
            }
            this.firstTagTimeout = SCHEDULER.setTimeout(_loc2_,dispatchEvent);
            dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{"code":"AppendBytesNetStream.Connect.Opened"}));
            this.tagStream.needsSampleAccess = super.checkPolicyFile;
            Object(this).appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
         }
         else
         {
            this.dataGenEnabled = false;
            this.closeTagStream();
            super.play.apply(this,rest);
         }
      }
      
      public function splice() : void
      {
         this.tagStream.splice();
      }
      
      override public function close() : void
      {
         this.closeTagStream();
         this.dataGenEnabled = false;
         super.close();
      }
   }
}

