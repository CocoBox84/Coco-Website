package com.google.utils
{
   import com.google.events.SchedulerEvent;
   import flash.net.SharedObject;
   import flash.net.URLRequest;
   import flash.system.Capabilities;
   import flash.utils.getTimer;
   
   public class VideoStats implements IVideoStats
   {
      
      private static var downloadPerf:Array;
      
      private static var downloadPerfLoaded:Boolean;
      
      private static var lso:SharedObject;
      
      private static var loader:GuardedLoader = new GuardedLoader();
      
      private var sendDownloadData:Boolean;
      
      private const MAX_REQ:Number = 400;
      
      private const BW_MAX_SAMPLES:Number = 3;
      
      private var startTimes:Array;
      
      private var sendScheduler:Scheduler;
      
      public var getBytesLoaded:Function;
      
      public var getMediaTime:Function;
      
      private var count:Number;
      
      private const INITIAL_DETAILED_PING_INTERVAL:int = 10000;
      
      private var endTimes:Array;
      
      private var lastPlaybackDelay:Number;
      
      private var mediaScheduler:Scheduler;
      
      private var playbackStartedValue:Boolean;
      
      private var lastRealTime:Number;
      
      private var numSegments:Number;
      
      private var startTime:Number;
      
      private var firstValidBufferEmptySent:Boolean;
      
      private var thresholdCount:Number;
      
      private var statNamespace:String;
      
      private var detailedPingScheduleIndex:int = 0;
      
      private var lastBufferEmptyEvents:Number;
      
      private var lastBytes:Number;
      
      private var constructorParameters:Object;
      
      private const BW_SAMPLE_SIZE:Number = 1048576;
      
      private var lastAdPlayTime:Number;
      
      private var downloadTimer:DownloadTimer;
      
      private var shouldSendSegments:Boolean;
      
      private var downloadPerformanceTimer:DownloadTimer;
      
      public var getSmoothedBandwidth:Function;
      
      public var getBufferEmptyEvents:Function;
      
      private var recordedDownloadPerformance:Boolean;
      
      private var accumulatedAdDuration:Number;
      
      private var lastBandwidth:Number;
      
      private var lastNumDroppedFrame:int;
      
      private const LONG_DETAILED_PING_INTERVAL:int = 40000;
      
      private var lastMediaTime:Number;
      
      private var urlBase:String;
      
      public var getMediaDuration:Function;
      
      private var segmentStart:Number;
      
      private var sentInitialPingValue:Boolean;
      
      private var globalParameters:Object;
      
      private var accumulatorMap:Object;
      
      private var detailedPingSchedule:Array;
      
      public var getPlayerState:Function;
      
      private var multipleInterval:Number;
      
      private var numSegmentsSent:Number;
      
      public function VideoStats(param1:String, param2:String, param3:Object)
      {
         var key:Object = null;
         var urlBaseValue:String = param1;
         var statNamespaceValue:String = param2;
         var parameters:Object = param3;
         this.detailedPingSchedule = [];
         super();
         if(!lso)
         {
            try
            {
               lso = SharedObject.getLocal("videostats","/");
            }
            catch(error:Error)
            {
            }
         }
         this.urlBase = urlBaseValue;
         this.statNamespace = statNamespaceValue;
         this.constructorParameters = {};
         for(key in parameters)
         {
            if(parameters[key] is String || parameters[key] is Number)
            {
               this.constructorParameters[key] = parameters[key];
            }
         }
         this.playbackStartedValue = false;
         this.startTimes = [];
         this.endTimes = [];
         this.shouldSendSegments = false;
         this.lastBufferEmptyEvents = 0;
         downloadPerfLoaded = false;
         this.thresholdCount = 3;
         this.multipleInterval = 4;
      }
      
      public static function predictedBandwidthInBitsPerSecond() : Number
      {
         var _loc3_:String = null;
         loadBandwidthData();
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         for(_loc3_ in downloadPerf)
         {
            _loc1_ += downloadPerf[_loc3_].bytes;
            _loc2_ += downloadPerf[_loc3_].time;
         }
         if(_loc2_ < 0.1)
         {
            return 0;
         }
         return _loc1_ * 8 / _loc2_ * 0.636717;
      }
      
      public static function loadBandwidthData() : void
      {
         var _loc1_:Array = null;
         var _loc2_:String = null;
         var _loc3_:Object = null;
         if(downloadPerfLoaded)
         {
            return;
         }
         downloadPerf = [];
         if(lso != null && Boolean(lso.data.perf))
         {
            _loc1_ = lso.data.perf;
            for(_loc2_ in _loc1_)
            {
               _loc3_ = new Object();
               _loc3_.bytes = _loc1_[_loc2_].bytes;
               _loc3_.time = _loc1_[_loc2_].time;
               _loc3_.smoothed = "smoothed" in _loc1_[_loc2_] ? _loc1_[_loc2_].smoothed : NaN;
               downloadPerf.push(_loc3_);
            }
         }
         downloadPerfLoaded = true;
      }
      
      public function onAdEnd() : void
      {
         var _loc1_:Number = NaN;
         if(!isNaN(this.lastAdPlayTime))
         {
            _loc1_ = this.getTimerInSeconds();
            this.accumulatedAdDuration += _loc1_ - this.lastAdPlayTime;
            this.lastAdPlayTime = NaN;
         }
      }
      
      public function endPlayback() : void
      {
         if(this.playbackStartedValue)
         {
            this.playbackStartedValue = false;
            if(this.mediaScheduler)
            {
               this.mediaScheduler.stop();
            }
            if(this.sendScheduler)
            {
               this.sendScheduler.stop();
            }
            this.addSegment();
            this.sendSegments();
         }
      }
      
      private function applyPersistentArgs(param1:RequestVariables) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         for(_loc2_ in this.globalParameters)
         {
            param1[_loc2_] = this.globalParameters[_loc2_];
         }
         for(_loc3_ in this.constructorParameters)
         {
            param1[_loc3_] = this.constructorParameters[_loc3_];
         }
      }
      
      public function get sentInitialPing() : Boolean
      {
         return this.sentInitialPingValue;
      }
      
      private function sendSegments(param1:Boolean = false, param2:RequestVariables = null) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:URLRequest = null;
         if(this.numSegments > 0 || param1)
         {
            _loc3_ = this.startTimes.length > 0 ? String(this.startTimes[0]) : null;
            _loc4_ = this.endTimes.length > 0 ? String(this.endTimes[0]) : null;
            _loc5_ = 1;
            while(_loc5_ < this.numSegments)
            {
               _loc3_ += "," + String(this.startTimes[_loc5_]);
               _loc4_ += "," + String(this.endTimes[_loc5_]);
               _loc5_++;
            }
            if(this.shouldSendSegments || param1)
            {
               param2 ||= new RequestVariables();
               if(Boolean(_loc3_) && Boolean(_loc4_))
               {
                  param2.st = _loc3_;
                  param2.et = _loc4_;
               }
               this.setStandardArgs(param2);
               if(param2.sendtmp)
               {
                  param2.vtmp = 1;
               }
               _loc6_ = new URLRequest(this.urlBase);
               _loc6_.data = param2;
               this.sendRequest(_loc6_);
            }
            ++this.numSegmentsSent;
            this.numSegments = 0;
         }
      }
      
      private function addSegment() : void
      {
         if(this.numSegmentsSent > this.MAX_REQ)
         {
            return;
         }
         if(this.lastMediaTime - this.segmentStart > 3)
         {
            this.startTimes[this.numSegments] = this.segmentStart;
            this.endTimes[this.numSegments] = this.lastMediaTime;
            ++this.numSegments;
            this.segmentStart = this.lastMediaTime;
         }
      }
      
      private function onJitteredInterval(param1:SchedulerEvent = null) : void
      {
         this.detailedPingScheduleIndex = Math.min(this.detailedPingScheduleIndex + 1,this.detailedPingSchedule.length - 1);
         this.sendReport();
         ++this.count;
         this.createJitteredScheduler(this.detailedPingSchedule[this.detailedPingScheduleIndex]);
      }
      
      public function startPlayback(param1:String, param2:String, param3:IStatProducer) : void
      {
         var _loc6_:String = null;
         if(this.playbackStartedValue)
         {
            this.endPlayback();
         }
         this.playbackStartedValue = true;
         this.getBufferEmptyEvents = param3.getBufferEmptyEvents;
         this.getBytesLoaded = param3.getBytesLoaded;
         this.getMediaDuration = param3.getMediaDuration;
         this.getMediaTime = param3.getMediaTime;
         this.getPlayerState = param3.getLoggingOptions;
         this.getSmoothedBandwidth = param3.getVerySmoothBandwidth;
         this.globalParameters = {};
         if(this.statNamespace)
         {
            this.globalParameters.ns = this.statNamespace;
         }
         this.globalParameters.docid = param1;
         if(param2)
         {
            this.globalParameters.sw = param2;
         }
         if(Boolean(param2) || Boolean(this.constructorParameters.sendtmp))
         {
            this.shouldSendSegments = true;
         }
         loadBandwidthData();
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         for(_loc6_ in downloadPerf)
         {
            _loc4_ += downloadPerf[_loc6_].bytes;
            _loc5_ += downloadPerf[_loc6_].time;
         }
         if(_loc4_ > 0 && _loc5_ > 0)
         {
            this.globalParameters.hbd = _loc4_;
            this.globalParameters.hbt = _loc5_.toFixed(3);
         }
         this.sendDownloadData = false;
         var _loc7_:Number = this.getBytesLoaded();
         var _loc8_:Number = this.getTimerInSeconds();
         this.recordedDownloadPerformance = false;
         this.downloadTimer = new DownloadTimer(_loc7_,_loc8_);
         this.downloadPerformanceTimer = new DownloadTimer(_loc7_,_loc8_);
         this.lastPlaybackDelay = 0;
         this.lastNumDroppedFrame = 0;
         this.firstValidBufferEmptySent = false;
         this.accumulatorMap = {
            "nsiabbl":new Accumulator(),
            "nsiabl":new Accumulator(),
            "nsialr":new Accumulator(),
            "nsivbbl":new Accumulator(),
            "nsivbl":new Accumulator()
         };
         this.numSegments = 0;
         this.numSegmentsSent = 0;
         this.startTime = _loc8_;
         this.lastMediaTime = this.getMediaTime();
         this.lastRealTime = this.startTime;
         this.segmentStart = this.lastMediaTime;
         if(this.sendScheduler)
         {
            this.sendScheduler.stop();
         }
         this.lastAdPlayTime = NaN;
         this.accumulatedAdDuration = 0;
         this.sentInitialPingValue = false;
         if(!this.mediaScheduler)
         {
            this.mediaScheduler = new Scheduler(Infinity,100);
            this.mediaScheduler.addEventListener(SchedulerEvent.TICK,this.mediaUpdate);
         }
         this.mediaScheduler.restart();
      }
      
      private function setStandardArgs(param1:RequestVariables) : void
      {
         var _loc4_:String = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Object = null;
         var _loc10_:String = null;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc2_:Number = this.getMediaDuration();
         if(_loc2_)
         {
            param1.len = _loc2_;
         }
         if(this.getBufferEmptyEvents is Function)
         {
            _loc6_ = this.getBufferEmptyEvents();
            _loc7_ = _loc6_ - this.lastBufferEmptyEvents;
            if(_loc7_ > 0)
            {
               param1.nbe = _loc7_;
            }
            this.lastBufferEmptyEvents = _loc6_;
         }
         if(this.accumulatedAdDuration > 0 || !isNaN(this.lastAdPlayTime))
         {
            if(!isNaN(this.lastAdPlayTime))
            {
               _loc8_ = this.getTimerInSeconds();
               this.accumulatedAdDuration += _loc8_ - this.lastAdPlayTime;
               this.lastAdPlayTime = _loc8_;
            }
            param1.ad = this.accumulatedAdDuration.toFixed(3);
            this.accumulatedAdDuration = 0;
         }
         if(this.sendDownloadData)
         {
            param1.hcbd = downloadPerf[downloadPerf.length - 1].bytes;
            param1.hcbt = downloadPerf[downloadPerf.length - 1].time;
            this.sendDownloadData = false;
         }
         if(this.lastBytes > 0)
         {
            param1.bc = this.lastBytes;
         }
         var _loc3_:Number = this.downloadTimer.getSize();
         if(_loc3_ > 0)
         {
            param1.bd = _loc3_;
            param1.bt = this.downloadTimer.getDuration().toFixed(3);
            this.downloadTimer.clearHistory();
         }
         if(this.getPlayerState is Function)
         {
            _loc9_ = this.getPlayerState();
            if(_loc9_)
            {
               delete _loc9_.nsiabbl;
               delete _loc9_.nsiabl;
               delete _loc9_.nsialr;
               delete _loc9_.nsivbbl;
               delete _loc9_.nsivbl;
               for(_loc10_ in _loc9_)
               {
                  param1[_loc10_] = _loc9_[_loc10_];
               }
               _loc11_ = Number(param1.pd);
               param1.pd = (_loc11_ - this.lastPlaybackDelay).toFixed(3);
               this.lastPlaybackDelay = _loc11_;
               if(param1.pd == "0.000")
               {
                  delete param1.pd;
               }
               if(!isNaN(param1.nsidf) && param1.nsidf > this.lastNumDroppedFrame)
               {
                  _loc12_ = int(param1.nsidf);
                  param1.nsidf = int(_loc12_ - this.lastNumDroppedFrame);
                  this.lastNumDroppedFrame = _loc12_;
               }
               else
               {
                  delete param1.nsidf;
               }
            }
         }
         for(_loc4_ in this.accumulatorMap)
         {
            if(this.accumulatorMap[_loc4_].getCount() > 0)
            {
               param1[_loc4_ + "c"] = this.accumulatorMap[_loc4_].getCount();
               param1[_loc4_ + "mean"] = this.accumulatorMap[_loc4_].getMean().toFixed(3);
               param1[_loc4_ + "min"] = this.accumulatorMap[_loc4_].getMin().toFixed(3);
               param1[_loc4_ + "max"] = this.accumulatorMap[_loc4_].getMax().toFixed(3);
               this.accumulatorMap[_loc4_].clear();
            }
         }
         if(!this.firstValidBufferEmptySent && param1.nbe > 0 && param1.pd > 0.25)
         {
            _loc13_ = 0;
            _loc14_ = 0;
            while(_loc14_ < this.numSegments)
            {
               _loc13_ += this.endTimes[_loc14_] - this.startTimes[_loc14_];
               _loc14_++;
            }
            if(param1.nbe * 2 < _loc13_)
            {
               this.firstValidBufferEmptySent = true;
               param1.fbe = 1;
            }
         }
         var _loc5_:Number = this.getTimerInSeconds() - this.startTime;
         param1.rt = _loc5_.toFixed(3);
         this.applyPersistentArgs(param1);
      }
      
      public function onAdPlay() : void
      {
         if(isNaN(this.lastAdPlayTime))
         {
            this.lastAdPlayTime = this.getTimerInSeconds();
         }
      }
      
      private function onInterval(param1:SchedulerEvent = null) : void
      {
         if(this.count <= this.thresholdCount || (this.count - this.thresholdCount) % this.multipleInterval == 0)
         {
            this.sendReport();
         }
         ++this.count;
      }
      
      public function mediaUpdate(param1:SchedulerEvent = null) : void
      {
         var mediaAdvance:Number;
         var args:RequestVariables = null;
         var request:URLRequest = null;
         var data:Object = null;
         var state:Object = null;
         var i:String = null;
         var idpj:int = 0;
         var ldpj:int = 0;
         var realAdvance:Number = NaN;
         var event:SchedulerEvent = param1;
         var mediaBytesLoaded:Number = this.getBytesLoaded();
         var mediaTime:Number = this.getMediaTime();
         var realTime:Number = this.getTimerInSeconds();
         var bandwidth:Number = this.getSmoothedBandwidth();
         this.recordedDownloadPerformance = this.recordedDownloadPerformance && (isNaN(bandwidth) || bandwidth == this.lastBandwidth);
         this.lastBandwidth = bandwidth;
         this.downloadTimer.addData(mediaBytesLoaded,realTime);
         this.downloadPerformanceTimer.addData(mediaBytesLoaded,realTime);
         this.lastBytes = mediaBytesLoaded;
         if(!this.recordedDownloadPerformance && this.downloadPerformanceTimer.getSize() >= this.BW_SAMPLE_SIZE)
         {
            this.recordedDownloadPerformance = true;
            data = new Object();
            data.bytes = this.downloadPerformanceTimer.getSize();
            data.time = this.downloadPerformanceTimer.getDuration();
            data.smoothed = bandwidth;
            if(downloadPerf.length > this.BW_MAX_SAMPLES)
            {
               downloadPerf.shift();
            }
            downloadPerf.push(data);
            this.sendDownloadData = true;
            if(lso)
            {
               lso.data.perf = downloadPerf;
               try
               {
                  lso.flush();
               }
               catch(e:Error)
               {
               }
            }
         }
         if(!this.sentInitialPingValue || this.shouldSendSegments)
         {
            if(this.getPlayerState is Function)
            {
               state = this.getPlayerState();
               for(i in this.accumulatorMap)
               {
                  this.accumulatorMap[i].add(state[i]);
               }
            }
         }
         if(!this.sentInitialPingValue && mediaTime > 0)
         {
            this.sentInitialPingValue = true;
            args = new RequestVariables();
            args.st = mediaTime;
            args.et = mediaTime;
            args.fv = escape(Capabilities.version);
            args.playback = 1;
            this.setStandardArgs(args);
            request = new URLRequest(this.urlBase);
            request.data = args;
            this.sendRequest(request);
            this.count = 1;
            if(!this.sendScheduler)
            {
               if(state && !isNaN(state.idpj) && !isNaN(state.ldpj))
               {
                  idpj = int(state.idpj) * 1000;
                  ldpj = int(state.ldpj) * 1000;
                  if(this.INITIAL_DETAILED_PING_INTERVAL - Math.abs(idpj) < 0)
                  {
                     idpj = 0;
                  }
                  if(this.LONG_DETAILED_PING_INTERVAL - Math.abs(ldpj) < 0)
                  {
                     ldpj = 0;
                  }
                  this.detailedPingSchedule = [this.INITIAL_DETAILED_PING_INTERVAL + idpj,this.INITIAL_DETAILED_PING_INTERVAL,this.INITIAL_DETAILED_PING_INTERVAL,this.LONG_DETAILED_PING_INTERVAL + ldpj - idpj,this.LONG_DETAILED_PING_INTERVAL];
                  this.createJitteredScheduler(this.detailedPingSchedule[0]);
               }
               else
               {
                  this.sendScheduler = new Scheduler(Infinity,10000);
                  this.sendScheduler.addEventListener(SchedulerEvent.TICK,this.onInterval);
               }
            }
            this.sendScheduler.restart();
         }
         mediaAdvance = mediaTime - this.lastMediaTime;
         if(mediaAdvance != 0)
         {
            realAdvance = realTime - this.lastRealTime;
            if(mediaAdvance < 0 || mediaAdvance > realAdvance + 0.2)
            {
               this.addSegment();
               this.segmentStart = mediaTime;
            }
            this.lastRealTime = realTime;
         }
         this.lastMediaTime = mediaTime;
      }
      
      protected function getTimerInSeconds() : Number
      {
         return getTimer() / 1000;
      }
      
      private function createJitteredScheduler(param1:int) : void
      {
         if(this.sendScheduler)
         {
            this.sendScheduler.stop();
         }
         this.sendScheduler = Scheduler.setTimeout(param1,this.onJitteredInterval);
         this.sendScheduler.restart();
      }
      
      public function sendReport(param1:Boolean = false, param2:RequestVariables = null) : void
      {
         this.addSegment();
         this.sendSegments(param1,param2);
      }
      
      public function get playbackStarted() : Boolean
      {
         return this.playbackStartedValue;
      }
      
      public function sendRequest(param1:URLRequest) : void
      {
         loader.load(param1);
      }
   }
}

