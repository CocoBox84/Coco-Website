package com.google.youtube.players.tagstream.bytesource
{
   import com.google.utils.Scheduler;
   import com.google.utils.Url;
   import com.google.youtube.event.StreamEvent;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.players.tagstream.PipelineEventDispatcher;
   import com.google.youtube.util.MediaLocation;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class HttpByteSource extends PipelineEventDispatcher implements IByteSource
   {
      
      public static const TIMEOUT:int = 5666;
      
      protected static const ERROR_DELAY:int = 350;
      
      protected static const SAMPLE_TIME:int = 1000;
      
      protected var fallbackTimer:Scheduler;
      
      protected var receivedFirstEvent:Boolean;
      
      protected var seekPointCopy:SeekPoint;
      
      protected var latencyValue:uint;
      
      protected var bytesRead:uint;
      
      protected var isFirstByteEventDispatched:Boolean;
      
      protected var lastByteTotal:Number = 0;
      
      protected var completeValue:Boolean;
      
      protected var mediaLocation:MediaLocation;
      
      protected var endTime:uint;
      
      protected var urlStream:URLStream;
      
      protected var startTime:uint;
      
      protected var fallbackTime:int;
      
      protected var isDoneEventDispatched:Boolean;
      
      protected var numRequests:int;
      
      protected var inFlight:Array = [];
      
      protected var isCacheHit:Boolean;
      
      public function HttpByteSource(param1:MediaLocation, param2:int = 5666, param3:Boolean = false)
      {
         super();
         this.mediaLocation = param1;
         this.isCacheHit = param3;
         this.fallbackTime = param2;
      }
      
      public static function remove(param1:Array, param2:*) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] == param2)
            {
               param1.splice(_loc3_--,1);
            }
            _loc3_++;
         }
      }
      
      protected function dispatchByteDeltas(param1:ProgressEvent) : void
      {
         var _loc2_:Number = NaN;
         if(!this.isCacheHit)
         {
            _loc2_ = param1.bytesLoaded;
            param1.bytesLoaded -= this.lastByteTotal;
            this.lastByteTotal = _loc2_;
            this.dispatchEvent(param1);
         }
      }
      
      protected function dispatchFirstByte() : void
      {
         if(!this.isCacheHit && !this.isFirstByteEventDispatched)
         {
            this.dispatchEvent(new StreamEvent(StreamEvent.STREAM,StreamEvent.FIRSTBYTE));
            this.isFirstByteEventDispatched = true;
         }
      }
      
      protected function issueNextRequest() : void
      {
         var _loc1_:URLStream = this.openUrlStream(this.getRequest(!this.numRequests ? this.mediaLocation.primaryUrl : this.mediaLocation.secondaryUrl,this.seekPointCopy.byteOffset,this.seekPointCopy.byteLength));
         this.inFlight.push(_loc1_);
         if(!this.numRequests && this.mediaLocation.hasSecondaryUrl)
         {
            this.fallbackTimer = Scheduler.setTimeout(this.fallbackTime,this.onFallbackTimer);
         }
         ++this.numRequests;
      }
      
      protected function getUrlStream() : URLStream
      {
         return new URLStream();
      }
      
      protected function dispatchDone() : void
      {
         if(!this.isCacheHit && this.isFirstByteEventDispatched && !this.isDoneEventDispatched)
         {
            this.dispatchEvent(new StreamEvent(StreamEvent.STREAM,StreamEvent.DONE));
            this.isDoneEventDispatched = true;
         }
      }
      
      public function read(param1:ByteArray, param2:uint, param3:uint) : uint
      {
         if(!this.urlStream || !this.urlStream.connected)
         {
            return 0;
         }
         var _loc4_:uint = Math.min(param3,this.urlStream.bytesAvailable);
         if(_loc4_ > 0)
         {
            this.urlStream.readBytes(param1,param2,_loc4_);
         }
         this.bytesRead += _loc4_;
         return _loc4_;
      }
      
      protected function stopFallbackTimer() : void
      {
         if(this.fallbackTimer)
         {
            this.fallbackTimer.stop();
            this.fallbackTimer = null;
         }
      }
      
      protected function delayedDispatch(param1:Event) : void
      {
         var event:Event = param1;
         Scheduler.setTimeout(ERROR_DELAY,function(param1:Event):void
         {
            dispatchEvent(event);
         });
      }
      
      public function info(param1:PlayerInfo) : void
      {
      }
      
      protected function openUrlStream(param1:URLRequest) : URLStream
      {
         var _loc2_:URLStream = this.getUrlStream();
         forwardEvents(_loc2_,false);
         _loc2_.addEventListener(ProgressEvent.PROGRESS,this.dispatchByteDeltas);
         _loc2_.addEventListener(ProgressEvent.PROGRESS,this.onFirstProgress);
         _loc2_.addEventListener(Event.COMPLETE,this.onComplete);
         _loc2_.load(param1);
         return _loc2_;
      }
      
      protected function onComplete(param1:Event) : void
      {
         if(!this.urlStream)
         {
            this.onFirstProgress(param1);
         }
         this.completeValue = true;
         this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
         this.dispatchDone();
      }
      
      override public function dispatchEvent(param1:Event) : Boolean
      {
         var _loc2_:Boolean = param1 is SecurityErrorEvent || param1 is IOErrorEvent;
         if(!_loc2_ || Boolean(this.urlStream))
         {
            return super.dispatchEvent(param1);
         }
         this.stopFallbackTimer();
         if(this.mediaLocation.hasSecondaryUrl && this.numRequests < 2)
         {
            this.issueNextRequest();
         }
         this.recordOrder(URLStream(param1.target),true);
         remove(this.inFlight,param1.target);
         if(!this.inFlight.length)
         {
            this.mediaLocation.resetOrder();
            return super.dispatchEvent(param1);
         }
         return false;
      }
      
      protected function halt(param1:URLStream) : void
      {
         if(param1.connected)
         {
            param1.close();
         }
         this.dispatchDone();
         stopForwardingEvents(param1,true);
         param1.removeEventListener(ProgressEvent.PROGRESS,this.onFirstProgress);
         param1.removeEventListener(Event.COMPLETE,this.onComplete);
      }
      
      public function open(param1:SeekPoint) : void
      {
         this.inFlight = [];
         this.seekPointCopy = new SeekPoint();
         this.seekPointCopy.byteOffset = param1.byteOffset;
         this.seekPointCopy.byteLength = param1.byteLength;
         this.startTime = getTimer();
         this.issueNextRequest();
         this.bytesRead = 0;
      }
      
      protected function closeInflightRequests() : void
      {
         var _loc1_:URLStream = null;
         for each(_loc1_ in this.inFlight)
         {
            this.halt(_loc1_);
         }
         this.inFlight = [];
      }
      
      public function get complete() : Boolean
      {
         return this.completeValue;
      }
      
      protected function getRequest(param1:String, param2:uint, param3:uint) : URLRequest
      {
         var _loc5_:uint = 0;
         var _loc4_:Url = new Url(param1);
         if(param3)
         {
            _loc5_ = param2 + param3 - 1;
            _loc4_.queryVars.range = param2 + "-" + _loc5_;
         }
         else if(param2)
         {
            _loc4_.queryVars = param2 + "-";
         }
         return new URLRequest(_loc4_.recombineUrl());
      }
      
      protected function onFallbackTimer(param1:Event) : void
      {
         if(this.mediaLocation.hasSecondaryUrl && this.numRequests < 2)
         {
            this.issueNextRequest();
         }
      }
      
      protected function onFirstProgress(param1:Event) : void
      {
         this.endTime = getTimer();
         this.recordOrder(URLStream(param1.target),false);
         this.stopFallbackTimer();
         remove(this.inFlight,param1.target);
         this.closeInflightRequests();
         this.urlStream = URLStream(param1.target);
         this.latencyValue = this.endTime - this.startTime;
         this.urlStream.removeEventListener(ProgressEvent.PROGRESS,this.onFirstProgress);
         this.urlStream.removeEventListener(IOErrorEvent.IO_ERROR,this.dispatchEvent);
         this.urlStream.addEventListener(IOErrorEvent.IO_ERROR,this.delayedDispatch);
         this.dispatchFirstByte();
      }
      
      public function get bytesFetched() : uint
      {
         return this.bytesRead + (Boolean(this.urlStream) && this.urlStream.connected ? this.urlStream.bytesAvailable : 0);
      }
      
      public function get eof() : Boolean
      {
         return this.completeValue && (!this.urlStream.connected || this.urlStream.bytesAvailable == 0);
      }
      
      protected function recordOrder(param1:URLStream, param2:Boolean) : void
      {
         if(!this.mediaLocation.hasSecondaryUrl || this.receivedFirstEvent || !this.inFlight.length)
         {
            return;
         }
         this.receivedFirstEvent = true;
         var _loc3_:URLStream = this.inFlight[0];
         var _loc4_:Boolean = param1 == _loc3_ && !param2 || param1 != _loc3_ && param2;
         if(!_loc4_)
         {
            this.mediaLocation.flip();
         }
      }
      
      public function get latency() : uint
      {
         return this.latencyValue;
      }
      
      public function close() : void
      {
         this.closeInflightRequests();
         this.stopFallbackTimer();
         if(this.urlStream)
         {
            this.halt(this.urlStream);
         }
      }
   }
}

