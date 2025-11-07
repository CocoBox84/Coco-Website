package com.google.youtube.util
{
   import com.google.events.SchedulerEvent;
   import com.google.utils.GuardedLoader;
   import com.google.utils.IStatProducer;
   import com.google.utils.RequestVariables;
   import com.google.utils.Scheduler;
   import com.google.youtube.model.FormatSelectionRecord;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.StatsPlayerState;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.YouTubeEnvironment;
   import com.google.youtube.players.IPlayerState;
   import com.google.youtube.players.IStatsProviderState;
   import com.google.youtube.players.IVideoPlayer;
   import com.google.youtube.players.StateChangeEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class StreamingStats
   {
      
      public static const EVENT_MESSAGE:String = "streamingstats";
      
      protected static const STREAMING_STATS_PING_INTERVAL:int = 10000;
      
      protected static const PERIODIC_PING_QUIESCENT_PERIOD:int = 30000;
      
      protected static const BANDWIDTH_ESTIMATE:String = "bwe";
      
      protected static const BANDWIDTH_METER:String = "bwm";
      
      protected static const BUFFER_HEALTH:String = "bh";
      
      protected static const DROPPED_FRAMES:String = "df";
      
      protected static const ERROR:String = "error";
      
      protected static const VIDEO_FORMAT_SWITCH:String = "vfs";
      
      protected static const VIDEO_PLAYER_STATE:String = "vps";
      
      protected static const VIEW_SIZE:String = "view";
      
      protected static var loader:GuardedLoader = new GuardedLoader();
      
      protected var lastDroppedFrameCount:uint;
      
      protected var getMediaTime:Function;
      
      protected var bandwidthSamples:Array = [];
      
      protected var quiescentScheduler:Scheduler;
      
      protected var getElapsedTime:Function;
      
      protected var ytEnv:YouTubeEnvironment;
      
      protected var lastRecordedVideoState:String;
      
      protected var stateTransitionFilter:Object = {};
      
      protected var player:IVideoPlayer;
      
      protected var pingScheduler:Scheduler;
      
      protected var statsDict:Dictionary = new Dictionary();
      
      public function StreamingStats(param1:YouTubeEnvironment)
      {
         super();
         this.buildStateTransitionFilter();
         this.statsDict[BANDWIDTH_ESTIMATE] = [];
         this.statsDict[BANDWIDTH_METER] = [];
         this.statsDict[BUFFER_HEALTH] = [];
         this.statsDict[DROPPED_FRAMES] = [];
         this.statsDict[ERROR] = [];
         this.statsDict[VIDEO_FORMAT_SWITCH] = [];
         this.statsDict[VIDEO_PLAYER_STATE] = [];
         this.statsDict[VIEW_SIZE] = [];
         this.ytEnv = param1;
         this.pingScheduler = new Scheduler(Infinity,STREAMING_STATS_PING_INTERVAL);
         this.pingScheduler.addEventListener(SchedulerEvent.TICK,this.onPingInterval);
         this.pingScheduler.stop();
         this.quiescentScheduler = Scheduler.setInterval(PERIODIC_PING_QUIESCENT_PERIOD,this.onQuiescentInterval);
         this.quiescentScheduler.stop();
      }
      
      protected function clearPlaybackState() : void
      {
         var _loc1_:String = null;
         if(this.pingScheduler)
         {
            this.pingScheduler.stop();
         }
         if(this.quiescentScheduler)
         {
            this.quiescentScheduler.stop();
         }
         for(_loc1_ in this.statsDict)
         {
            this.statsDict[_loc1_] = [];
         }
         this.lastRecordedVideoState = "";
         this.bandwidthSamples.splice(0);
         this.lastDroppedFrameCount = 0;
      }
      
      public function onVideoFormatChange(param1:FormatSelectionRecord) : void
      {
         if(param1)
         {
            this.recordVideoFormat(param1);
            this.recordViewSize(param1.switchTime,param1.viewportRect);
            this.recordBandwidthEstimate(param1.evalTime,param1.bandwidthEstimate);
            this.recordBufferHealth(param1.evalTime,param1.bandwidthEstimate);
            this.recordVideoState(this.elapsedTime,this.getCurrentVideoState());
            this.recordPeriodicStats();
            this.reportStats();
         }
      }
      
      public function onStreamingError(param1:String) : void
      {
         this.recordError(this.elapsedTime,param1,this.mediaTime);
      }
      
      protected function recordVideoState(param1:Number, param2:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(!isNaN(param1))
         {
            _loc3_ = param2 == StatsPlayerState.SEEKING_PAUSED ? StatsPlayerState.SEEKING : param2;
            _loc4_ = param1.toFixed(3) + ":" + _loc3_;
            this.statsDict[VIDEO_PLAYER_STATE].push(_loc4_);
            this.lastRecordedVideoState = param2;
         }
      }
      
      protected function recordBandwidthMeter() : void
      {
         var _loc4_:BandwidthSample = null;
         var _loc5_:String = null;
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         var _loc3_:Number = this.elapsedTime;
         if(!isNaN(_loc3_))
         {
            _loc4_ = this.bandwidthSamples.shift();
            while(_loc4_)
            {
               _loc1_ += _loc4_.bytes;
               _loc2_ += (_loc4_.endTime - _loc4_.startTime) / 1000;
               _loc4_ = this.bandwidthSamples.shift();
            }
            if(_loc1_ != 0 && _loc2_ != 0)
            {
               _loc5_ = _loc3_.toFixed(3) + ":" + _loc1_.toFixed(3) + ":" + _loc2_.toFixed(3);
               this.statsDict[BANDWIDTH_METER].push(_loc5_);
            }
         }
      }
      
      protected function buildStateTransitionFilter() : void
      {
         this.stateTransitionFilter = {};
         this.stateTransitionFilter[StatsPlayerState.NOTSTARTED] = {};
         this.stateTransitionFilter[StatsPlayerState.NOTSTARTED][StatsPlayerState.SEEKING] = 1;
         this.stateTransitionFilter[StatsPlayerState.SEEKING] = {};
         this.stateTransitionFilter[StatsPlayerState.SEEKING][StatsPlayerState.SEEKING] = 1;
         this.stateTransitionFilter[StatsPlayerState.SEEKING][StatsPlayerState.SEEKING_PAUSED] = 1;
         this.stateTransitionFilter[StatsPlayerState.SEEKING][StatsPlayerState.PAUSED] = 1;
         this.stateTransitionFilter[StatsPlayerState.SEEKING_PAUSED] = {};
         this.stateTransitionFilter[StatsPlayerState.SEEKING_PAUSED][StatsPlayerState.SEEKING] = 1;
         this.stateTransitionFilter[StatsPlayerState.SEEKING_PAUSED][StatsPlayerState.SEEKING_PAUSED] = 1;
      }
      
      public function endPlayback() : void
      {
         this.reportStats();
         this.clearPlaybackState();
      }
      
      public function onApplicationError() : void
      {
         this.recordPeriodicStats();
         this.reportStats();
      }
      
      public function startPlayback(param1:IVideoPlayer, param2:IStatProducer) : void
      {
         this.clearPlaybackState();
         this.getElapsedTime = param2.getElapsedTime;
         this.getMediaTime = param2.getMediaTime;
         this.player = param1;
         this.recordVideoState(0,StatsPlayerState.NOTSTARTED);
         this.pingScheduler.restart();
         this.quiescentScheduler.restart();
      }
      
      protected function onQuiescentInterval(param1:SchedulerEvent = null) : void
      {
         var _loc2_:String = this.getCurrentVideoState();
         if(_loc2_ == StatsPlayerState.PLAYING)
         {
            this.recordVideoState(this.elapsedTime,_loc2_);
            this.recordPeriodicStats(true);
            this.reportStats();
         }
      }
      
      public function onVideoStateChange(param1:StateChangeEvent) : void
      {
         var _loc2_:String = IStatsProviderState(param1.state).statsStateId;
         var _loc3_:String = IStatsProviderState(param1.oldState).statsStateId;
         if(Boolean(this.stateTransitionFilter[this.lastRecordedVideoState]) && Boolean(this.stateTransitionFilter[this.lastRecordedVideoState][_loc2_]))
         {
            return;
         }
         if(this.lastRecordedVideoState == StatsPlayerState.SEEKING && _loc2_ == StatsPlayerState.PLAYING && _loc3_ == StatsPlayerState.PAUSED)
         {
            return;
         }
         this.recordVideoState(this.elapsedTime,_loc2_);
         if(_loc2_ == StatsPlayerState.ENDED)
         {
            this.recordPeriodicStats();
            this.reportStats();
         }
      }
      
      protected function recordBandwidthEstimate(param1:Number, param2:Number) : void
      {
         var _loc3_:String = null;
         if(!isNaN(param2) && !isNaN(param1))
         {
            _loc3_ = param1.toFixed(3) + ":" + param2.toFixed(3);
            this.statsDict[BANDWIDTH_ESTIMATE].push(_loc3_);
         }
      }
      
      protected function recordBufferHealth(param1:Number, param2:Number) : void
      {
         var _loc3_:String = null;
         if(!isNaN(param2) && param2 >= 0 && !isNaN(param1))
         {
            _loc3_ = param1.toFixed(3) + ":" + param2.toFixed(3);
            this.statsDict[BUFFER_HEALTH].push(_loc3_);
         }
      }
      
      protected function recordDroppedFrames(param1:Number, param2:Number) : void
      {
         var _loc3_:String = null;
         if(!isNaN(param2) && !isNaN(param1))
         {
            _loc3_ = param1.toFixed(3) + ":" + param2;
            this.statsDict[DROPPED_FRAMES].push(_loc3_);
         }
      }
      
      protected function recordViewSize(param1:Number, param2:Rectangle) : void
      {
         var _loc3_:String = null;
         if(Boolean(param2.width) && Boolean(param2.height) && !isNaN(param1))
         {
            _loc3_ = param1.toFixed(3) + ":" + param2.width + ":" + param2.height;
            this.statsDict[VIEW_SIZE].push(_loc3_);
         }
      }
      
      protected function getReadAheadBuffer(param1:PlayerInfo) : Number
      {
         return param1.loadedTime / 1000 - param1.playhead;
      }
      
      protected function recordError(param1:Number, param2:String, param3:Number) : void
      {
         var _loc4_:String = null;
         if(!isNaN(param1) && param2 != "")
         {
            _loc4_ = param1.toFixed(3) + ":" + param2 + ":" + param3.toFixed(2);
            this.statsDict[ERROR].push(_loc4_);
         }
      }
      
      protected function recordVideoFormat(param1:FormatSelectionRecord) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            _loc2_ = param1.switchTime.toFixed(3) + ":" + param1.format.name + ":" + param1.viewportFormat.name + ":" + param1.oldFormat.name + ":" + param1.trigger;
            this.statsDict[VIDEO_FORMAT_SWITCH].push(_loc2_);
         }
      }
      
      protected function reportStats() : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc1_:RequestVariables = new RequestVariables();
         for(_loc2_ in this.statsDict)
         {
            if(this.statsDict[_loc2_].length > 0)
            {
               _loc3_ = this.statsDict[_loc2_];
               _loc4_ = _loc3_.shift().toString();
               for each(_loc5_ in _loc3_)
               {
                  _loc4_ += "," + _loc5_.toString();
               }
               _loc1_[_loc2_] = _loc4_;
               this.statsDict[_loc2_] = [];
            }
         }
         if(!this.isEmptyRequest(_loc1_))
         {
            this.sendRequest(_loc1_);
            this.quiescentScheduler.restart();
         }
      }
      
      protected function isEmptyRequest(param1:RequestVariables) : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:* = param1;
         for(_loc2_ in _loc4_)
         {
            return false;
         }
         return true;
      }
      
      protected function getDroppedFrames(param1:PlayerInfo) : Number
      {
         var _loc2_:Number = NaN;
         if(param1.droppedFrames >= this.lastDroppedFrameCount)
         {
            _loc2_ = param1.droppedFrames - this.lastDroppedFrameCount;
            this.lastDroppedFrameCount = param1.droppedFrames;
         }
         return _loc2_;
      }
      
      protected function get mediaTime() : Number
      {
         return this.getMediaTime != null ? this.getMediaTime() : -1;
      }
      
      protected function onPingInterval(param1:SchedulerEvent = null) : void
      {
         this.reportStats();
      }
      
      public function onBandwidthSample(param1:BandwidthSample) : void
      {
         this.bandwidthSamples.push(param1);
      }
      
      protected function sendRequest(param1:RequestVariables) : void
      {
         var _loc2_:VideoData = this.player.getVideoData();
         param1.event = EVENT_MESSAGE;
         param1.fmt = _loc2_.format.name;
         var _loc3_:URLRequest = this.ytEnv.getLoggingRequest(_loc2_,param1);
         loader.load(_loc3_);
      }
      
      protected function get elapsedTime() : Number
      {
         return this.getElapsedTime != null ? this.getElapsedTime() : NaN;
      }
      
      protected function recordPeriodicStats(param1:Boolean = false) : void
      {
         var _loc2_:PlayerInfo = new PlayerInfo();
         this.player.getPlayerInfo(_loc2_);
         this.recordDroppedFrames(this.elapsedTime,this.getDroppedFrames(_loc2_));
         this.recordBandwidthMeter();
         if(param1)
         {
            this.recordBufferHealth(this.elapsedTime,this.getReadAheadBuffer(_loc2_));
         }
      }
      
      public function set videoPlayer(param1:IVideoPlayer) : void
      {
         this.player = param1;
      }
      
      protected function getCurrentVideoState() : String
      {
         var _loc1_:IPlayerState = this.player.getPlayerState();
         return IStatsProviderState(_loc1_).statsStateId;
      }
   }
}

