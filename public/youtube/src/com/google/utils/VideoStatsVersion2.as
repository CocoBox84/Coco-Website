package com.google.utils
{
   import com.google.events.SchedulerEvent;
   import flash.net.URLRequest;
   import flash.utils.getTimer;
   
   public class VideoStatsVersion2 implements IVideoStats
   {
      
      protected static var loader:GuardedLoader = new GuardedLoader();
      
      protected const DELAY_PATH:String = "/api/stats/delayplay";
      
      protected var startTimes:Array;
      
      protected var constructorParameters:Object;
      
      protected var detailedPingScheduler:Scheduler;
      
      protected var lastWatchTimeWasZero:Boolean = false;
      
      public var getMediaTime:Function;
      
      protected const INITIAL_DETAILED_PING_INTERVAL:int = 10000;
      
      protected var viewcountDelay:Number;
      
      protected var runtimeIntended:Number = 0;
      
      protected var endTimes:Array;
      
      protected var playbackStartedValue:Boolean;
      
      public var getLoggingOptions:Function;
      
      protected var mediaScheduler:Scheduler;
      
      protected const VERSION:Number = 2;
      
      protected var lastRealTime:Number;
      
      protected const DEFAULT_CLIENT_DESCRIPTION:String = "web";
      
      protected const WATCH_TIME_PATH:String = "/api/stats/watchtime";
      
      protected const PLAYBACK_PATH:String = "/api/stats/playback";
      
      protected const LONG_DETAILED_PING_INTERVAL:int = 40000;
      
      protected var startTime:Number;
      
      protected var detailedPingScheduleIndex:int = 0;
      
      protected var lastMediaTime:Number;
      
      protected var urlBase:String;
      
      public var getMediaDuration:Function;
      
      protected var runtimeNext:Number = 0;
      
      protected var globalParameters:Object;
      
      protected var segmentStart:Number;
      
      protected var sentInitialPingValue:Boolean;
      
      protected var detailedPingSchedule:Array;
      
      public var getPlayerState:Function;
      
      public var totalMediaTime:Number;
      
      public function VideoStatsVersion2(param1:String, param2:String, param3:Object)
      {
         var _loc4_:Object = null;
         this.detailedPingSchedule = [];
         super();
         this.urlBase = param1;
         this.constructorParameters = {
            "c":param3.c || this.DEFAULT_CLIENT_DESCRIPTION,
            "ns":param2
         };
         for(_loc4_ in param3)
         {
            if(param3[_loc4_] is String || param3[_loc4_] is Number)
            {
               this.constructorParameters[_loc4_] = param3[_loc4_];
            }
         }
         this.playbackStartedValue = false;
         this.startTimes = [];
         this.endTimes = [];
      }
      
      public function mediaUpdate(param1:SchedulerEvent = null) : void
      {
         var _loc5_:Number = NaN;
         var _loc2_:Number = Number(this.getMediaTime().toFixed(3));
         var _loc3_:Number = this.getTimerInSeconds();
         if(!this.sentInitialPingValue && _loc2_ > 0)
         {
            this.initializePlayback();
            this.runtimeNext = this.detailedPingSchedule[0];
            this.sendPlaybackRequest();
            this.detailedPingScheduler.restart();
         }
         var _loc4_:Number = _loc2_ - this.lastMediaTime;
         if(_loc4_ != 0)
         {
            _loc5_ = _loc3_ - this.lastRealTime;
            if(_loc4_ < 0 || _loc4_ > _loc5_ + 0.2)
            {
               this.addSegment();
               this.segmentStart = _loc2_;
            }
            else
            {
               this.totalMediaTime += _loc4_;
            }
            this.lastRealTime = _loc3_;
         }
         this.lastMediaTime = _loc2_;
         if(Boolean(this.viewcountDelay) && this.totalMediaTime >= Math.min(this.viewcountDelay,this.getMediaDuration()))
         {
            this.sendDelayedViewRequest();
         }
      }
      
      public function sendDelayedViewRequest() : void
      {
         var _loc1_:RequestVariables = new RequestVariables();
         this.applyRequestArgs(_loc1_,{
            "fexp":true,
            "lact":true,
            "mos":true,
            "partnerid":true,
            "ps":true,
            "rti":true,
            "rtn":true,
            "referrer":true,
            "uga":true,
            "vid":true,
            "volume":true
         });
         _loc1_.tv = 1;
         var _loc2_:URLRequest = new URLRequest(this.urlBase + this.DELAY_PATH);
         _loc2_.data = _loc1_;
         this.sendRequest(_loc2_);
         this.viewcountDelay = NaN;
      }
      
      protected function getTimerInSeconds() : Number
      {
         return getTimer() / 1000;
      }
      
      protected function sendWatchTime(param1:Boolean = true, param2:RequestVariables = null) : void
      {
         param2 ||= new RequestVariables();
         var _loc3_:String = this.startTimes.join(",") || this.getMediaTime().toFixed(3);
         var _loc4_:String = this.endTimes.join(",") || this.getMediaTime().toFixed(3);
         param2.st = _loc3_;
         param2.et = _loc4_;
         if(_loc3_ == _loc4_ && this.lastWatchTimeWasZero && param1)
         {
            return;
         }
         this.applyRequestArgs(param2,{
            "idpj":true,
            "lact":true,
            "ldpj":true,
            "rti":param1,
            "rtn":param1,
            "state":1
         });
         var _loc5_:URLRequest = new URLRequest(this.urlBase + this.WATCH_TIME_PATH);
         _loc5_.data = param2;
         this.sendRequest(_loc5_);
         this.startTimes = [];
         this.endTimes = [];
         if(_loc3_ == _loc4_)
         {
            if(param1)
            {
               this.lastWatchTimeWasZero = true;
            }
         }
         else
         {
            this.lastWatchTimeWasZero = false;
         }
      }
      
      public function startPlayback(param1:String, param2:String, param3:IStatProducer) : void
      {
         if(this.playbackStartedValue)
         {
            this.endPlayback();
         }
         this.playbackStartedValue = true;
         this.totalMediaTime = 0;
         this.runtimeIntended = 0;
         this.runtimeNext = 0;
         this.getMediaDuration = param3.getMediaDuration;
         this.getMediaTime = param3.getMediaTime;
         this.getLoggingOptions = param3.getLoggingOptions;
         this.getPlayerState = param3.getExternalState;
         this.globalParameters = {};
         this.globalParameters.docid = param1;
         this.startTime = this.getTimerInSeconds();
         this.lastMediaTime = this.getMediaTime();
         this.lastRealTime = this.startTime;
         this.segmentStart = this.lastMediaTime;
         if(this.detailedPingScheduler)
         {
            this.detailedPingScheduler.stop();
         }
         this.sentInitialPingValue = false;
         if(!this.mediaScheduler)
         {
            this.mediaScheduler = Scheduler.setInterval(100,this.mediaUpdate);
         }
         this.mediaScheduler.restart();
      }
      
      public function onAdEnd() : void
      {
      }
      
      public function get sentInitialPing() : Boolean
      {
         return this.sentInitialPingValue;
      }
      
      public function endPlayback() : void
      {
         var _loc1_:RequestVariables = null;
         if(this.playbackStartedValue)
         {
            this.playbackStartedValue = false;
            this.mediaScheduler.stop();
            if(this.detailedPingScheduler)
            {
               this.detailedPingScheduler.stop();
            }
            this.addSegment();
            _loc1_ = new RequestVariables();
            _loc1_.final = 1;
            this.sendWatchTime(false,_loc1_);
         }
      }
      
      protected function applyRequestArgs(param1:RequestVariables, param2:Object) : void
      {
         var _loc7_:Object = null;
         var _loc8_:String = null;
         param1.ver = this.VERSION;
         param1.cmt = this.getMediaTime().toFixed(3);
         var _loc3_:Number = this.getTimerInSeconds() - this.startTime;
         param1.rt = _loc3_.toFixed(3);
         var _loc4_:Number = this.getMediaDuration();
         if(_loc4_)
         {
            param1.len = _loc4_;
         }
         if(this.viewcountDelay)
         {
            param1.delay = this.viewcountDelay;
         }
         if(param2["state"])
         {
            param1.state = this.getStateFromPlayerState(this.getPlayerState());
         }
         param2["adformat"] = true;
         param2["app"] = true;
         param2["attrib"] = true;
         param2["autoplay"] = true;
         param2["c"] = true;
         param2["cbr"] = true;
         param2["cbrand"] = true;
         param2["cbrver"] = true;
         param2["cmodel"] = true;
         param2["cnetwork"] = true;
         param2["cos"] = true;
         param2["cosver"] = true;
         param2["cplatform"] = true;
         param2["cver"] = true;
         param2["cpn"] = true;
         param2["delay"] = true;
         param2["docid"] = true;
         param2["el"] = true;
         param2["euri"] = true;
         param2["feature"] = true;
         param2["fs"] = true;
         param2["fmt"] = true;
         param2["list"] = true;
         param2["live"] = true;
         param2["ns"] = true;
         param2["subscribed"] = true;
         param2["splay"] = true;
         if(this.detailedPingSchedule.length)
         {
            if(Boolean(param2["rtn"]) && this.runtimeNext > 0)
            {
               param1.rtn = this.runtimeNext;
            }
            if(Boolean(param2["rti"]) && this.runtimeIntended > 0)
            {
               param1.rti = this.runtimeIntended;
            }
         }
         var _loc5_:Object = this.getLoggingOptions();
         if(_loc5_.eurl)
         {
            _loc5_.euri = _loc5_.eurl;
         }
         var _loc6_:Array = [this.globalParameters,this.constructorParameters,_loc5_];
         for each(_loc7_ in _loc6_)
         {
            for(_loc8_ in _loc7_)
            {
               if(param2[_loc8_])
               {
                  param1[_loc8_] = _loc7_[_loc8_];
               }
            }
         }
      }
      
      public function onAdPlay() : void
      {
      }
      
      protected function initializePlayback() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:Object = this.getLoggingOptions();
         if(_loc1_.delay)
         {
            this.viewcountDelay = _loc1_.delay;
         }
         if(!this.detailedPingScheduler)
         {
            _loc2_ = 0;
            _loc3_ = 0;
            if(_loc1_ && !isNaN(_loc1_.idpj) && !isNaN(_loc1_.ldpj))
            {
               _loc2_ = int(_loc1_.idpj) * 1000;
               _loc3_ = int(_loc1_.ldpj) * 1000;
            }
            if(this.INITIAL_DETAILED_PING_INTERVAL - Math.abs(_loc2_) < 0)
            {
               _loc2_ = 0;
            }
            if(this.LONG_DETAILED_PING_INTERVAL - Math.abs(_loc3_) < 0)
            {
               _loc3_ = 0;
            }
            this.detailedPingSchedule = [this.INITIAL_DETAILED_PING_INTERVAL + _loc2_,this.INITIAL_DETAILED_PING_INTERVAL,this.INITIAL_DETAILED_PING_INTERVAL,this.LONG_DETAILED_PING_INTERVAL + _loc3_ - _loc2_,this.LONG_DETAILED_PING_INTERVAL];
            this.createDetailedPingScheduler(this.detailedPingSchedule[0]);
         }
      }
      
      public function sendPlaybackRequest() : void
      {
         this.sentInitialPingValue = true;
         var _loc1_:RequestVariables = new RequestVariables();
         this.applyRequestArgs(_loc1_,{
            "fexp":true,
            "lact":true,
            "mos":true,
            "partnerid":true,
            "ps":true,
            "rti":true,
            "rtn":true,
            "referrer":true,
            "uga":true,
            "vid":true,
            "volume":true
         });
         var _loc2_:URLRequest = new URLRequest(this.urlBase + this.PLAYBACK_PATH);
         _loc2_.data = _loc1_;
         this.sendRequest(_loc2_);
      }
      
      protected function addSegment() : void
      {
         if(this.lastMediaTime - this.segmentStart > 0)
         {
            this.startTimes.push(this.segmentStart);
            this.endTimes.push(this.lastMediaTime);
            this.segmentStart = this.lastMediaTime;
         }
      }
      
      public function sendReport(param1:Boolean = false, param2:RequestVariables = null) : void
      {
         this.addSegment();
         this.sendWatchTime(param1,param2);
      }
      
      protected function sendRequest(param1:URLRequest) : void
      {
         loader.load(param1);
      }
      
      public function get playbackStarted() : Boolean
      {
         return this.playbackStartedValue;
      }
      
      protected function onJitteredInterval(param1:SchedulerEvent = null) : void
      {
         this.detailedPingScheduleIndex = Math.min(this.detailedPingScheduleIndex + 1,this.detailedPingSchedule.length - 1);
         var _loc2_:int = int(this.detailedPingSchedule[this.detailedPingScheduleIndex]);
         this.runtimeIntended = this.runtimeNext;
         this.runtimeNext = this.runtimeIntended + _loc2_;
         this.sendReport(true);
         this.createDetailedPingScheduler(_loc2_);
      }
      
      protected function getStateFromPlayerState(param1:int) : String
      {
         return param1 == 1 ? "playing" : "paused";
      }
      
      protected function createDetailedPingScheduler(param1:int) : void
      {
         if(this.detailedPingScheduler)
         {
            this.detailedPingScheduler.stop();
         }
         this.detailedPingScheduler = Scheduler.setTimeout(param1,this.onJitteredInterval);
         this.detailedPingScheduler.restart();
      }
   }
}

