package com.google.youtube.application
{
   import com.google.youtube.model.EventLabel;
   import com.google.youtube.model.FormatSelectionRecord;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.VideoQuality;
   import com.google.youtube.model.YouTubeEnvironment;
   import com.google.youtube.players.BufferingState;
   import com.google.youtube.players.HTTPVideoPlayer;
   import com.google.youtube.players.IPausedState;
   import com.google.youtube.players.IVideoPlayer;
   import com.google.youtube.players.TagStreamPlayer;
   import com.google.youtube.util.BandwidthCalculator;
   import com.google.youtube.util.BandwidthSample;
   import flash.net.SharedObject;
   import flash.utils.getTimer;
   
   public class FormatSelector
   {
      
      protected static const LSO_NAME:String = "videostats";
      
      protected static const EVAL_EVERY_N_TIMES:uint = 10;
      
      protected static const MIN_SWITCH_MILLIS:Number = 5500;
      
      protected static const ADEQUATE_BUFF:Number = 6.5;
      
      protected static const SAFE_BUFF:Number = 12;
      
      protected static const SAMPLE_THRESHOLD_FOR_LOW_QUALITY_UNLOCK:Number = 15;
      
      protected static var RATE_FRACTION:Number = 0.76;
      
      protected static const HLS_BUFFER_SECONDS:Number = 5;
      
      protected static const HYSTERESIS:Number = 0.2;
      
      public static var CONSIDER_720_LOWDEF:Boolean = false;
      
      public static var NO_SPECIAL_TREATMENT_240P:Boolean = false;
      
      protected var predictor:BandwidthCalculator;
      
      protected var formatBufferTime:Object;
      
      protected var videoData:VideoData;
      
      protected var ytEnv:YouTubeEnvironment;
      
      protected var spliceMoratoriumStartTime:Number;
      
      protected var invocationCount:uint;
      
      protected var app:VideoApplication;
      
      protected var storedRate:Number;
      
      protected var lastEvaluated:FormatSelectionRecord;
      
      protected var switchDownCount:Object;
      
      protected var transitions:Array;
      
      public function FormatSelector(param1:VideoApplication, param2:YouTubeEnvironment)
      {
         var app:VideoApplication = param1;
         var ytEnv:YouTubeEnvironment = param2;
         this.predictor = new BandwidthCalculator();
         this.transitions = [];
         this.formatBufferTime = {};
         this.switchDownCount = {};
         super();
         this.app = app;
         this.ytEnv = ytEnv;
         try
         {
            this.storedRate = rateFromLso(SharedObject.getLocal(LSO_NAME,"/"));
         }
         catch(error:Error)
         {
         }
      }
      
      protected static function rateFromLso(param1:SharedObject) : Number
      {
         return param1 && param1.data && Boolean(param1.data.perf) && Boolean(param1.data.perf.length) && Boolean(param1.data.perf[param1.data.perf.length - 1].smoothed) ? Number(param1.data.perf[param1.data.perf.length - 1].smoothed) : NaN;
      }
      
      protected function get isAdaptive() : Boolean
      {
         var _loc1_:Boolean = Boolean(this.videoData) && this.videoData.adaptiveByDefault;
         return this.ytEnv.autoQuality && (this.ytEnv.adaptiveExperiment || _loc1_) && this.player is TagStreamPlayer;
      }
      
      protected function get isHdAllowed() : Boolean
      {
         var _loc1_:HTTPVideoPlayer = this.player as HTTPVideoPlayer;
         return this.ytEnv.fullScreenHd || Boolean(_loc1_) && _loc1_.isStageVideoAvailable();
      }
      
      protected function getLowestQualityAvailable() : int
      {
         var _loc1_:Array = this.getAllowedFormats();
         return this.isLowQualityAvailable() ? int(_loc1_.length - 1) : int(Math.max(0,_loc1_.length - 2));
      }
      
      protected function isLowQualityAvailable() : Boolean
      {
         if(NO_SPECIAL_TREATMENT_240P)
         {
            return true;
         }
         var _loc1_:Array = this.getAllowedFormats();
         var _loc2_:int = int(_loc1_.length - 1);
         return _loc2_ == 0 || _loc1_[_loc2_].name != "5" || this.formatBufferTime[_loc1_[_loc2_ - 1].name] >= SAMPLE_THRESHOLD_FOR_LOW_QUALITY_UNLOCK;
      }
      
      protected function byAllowed(param1:VideoFormat, param2:int, param3:Array) : Boolean
      {
         return this.videoData.isFormatAllowedToPlay(param1);
      }
      
      protected function isHd(param1:VideoFormat) : Boolean
      {
         return CONSIDER_720_LOWDEF ? param1.quality > VideoQuality.HD720 : param1.quality >= VideoQuality.HD720;
      }
      
      public function getLoggingOptions() : Object
      {
         return this.transitions.length ? {"tspadpt":this.transitions.join(",")} : {};
      }
      
      public function getSelectionRecordForFormat(param1:VideoFormat) : FormatSelectionRecord
      {
         var _loc2_:FormatSelectionRecord = null;
         if(param1 && this.lastEvaluated && this.lastEvaluated.format == param1)
         {
            _loc2_ = this.lastEvaluated;
            this.lastEvaluated = null;
         }
         return _loc2_;
      }
      
      protected function byStoredRate(param1:VideoFormat, param2:int, param3:Array) : Boolean
      {
         return isNaN(this.storedRate) || param1.byteRate / this.storedRate < RATE_FRACTION;
      }
      
      protected function getBandwidthDependentFormat() : VideoFormat
      {
         var _loc1_:PlayerInfo = new PlayerInfo();
         this.player.getPlayerInfo(_loc1_);
         this.recordSpinners();
         if(this.isSwitchProhibited(_loc1_))
         {
            return null;
         }
         var _loc2_:VideoFormat = this.chooseFormat(_loc1_);
         if(_loc2_.equals(this.app.videoData.format))
         {
            return null;
         }
         this.spliceMoratoriumStartTime = getTimer();
         this.recordSwitch(this.videoData.format,_loc2_);
         return _loc2_;
      }
      
      public function getVideoFormat(param1:String, param2:VideoQuality = null, param3:VideoData = null, param4:Boolean = false) : VideoFormat
      {
         var _loc6_:FormatSelectionRecord = null;
         var _loc7_:PlayerInfo = null;
         this.videoData = param3 ? param3 : this.app.videoData;
         var _loc5_:VideoFormat = null;
         switch(param1)
         {
            case FormatSelectionRecord.ADAPTIVE:
               if(this.isAdaptive && this.invocationCount++ >= EVAL_EVERY_N_TIMES)
               {
                  this.invocationCount = 0;
                  _loc5_ = this.getBandwidthDependentFormat();
               }
               break;
            case FormatSelectionRecord.INITIAL:
               this.ytEnv.audioTrackPref = param3.audioTrack || this.ytEnv.audioTrackPref;
               this.spliceMoratoriumStartTime = getTimer();
               _loc5_ = this.isAdaptive ? this.getInitialAdaptiveFormat() : (this.ytEnv.autoQuality ? this.getFormatForViewSize() : this.videoData.getFormatForQuality(this.ytEnv.videoQualityPref));
               break;
            case FormatSelectionRecord.MANUAL:
               this.ytEnv.videoQualityPref = param2;
               _loc5_ = this.isAdaptive ? this.getBandwidthDependentFormat() : (this.ytEnv.autoQuality ? this.getFormatBySizeOnly() : this.videoData.getFormatForQuality(param2));
               break;
            case FormatSelectionRecord.RESIZE:
               if(this.isAdaptive)
               {
                  _loc5_ = this.getBandwidthDependentFormat();
                  break;
               }
               if(this.ytEnv.autoQuality && (this.ytEnv.eventLabel == EventLabel.DETAIL_PAGE || this.app.isFullScreen()))
               {
                  _loc5_ = this.getFormatBySizeOnly();
               }
               break;
            default:
               throw new Error("Unknown Format Selection trigger: " + param1);
         }
         if(_loc5_ && _loc5_ != this.app.videoData.format && !param4)
         {
            _loc6_ = new FormatSelectionRecord();
            _loc7_ = new PlayerInfo();
            this.player.getPlayerInfo(_loc7_);
            _loc6_.evalTime = this.app.getElapsedTime();
            _loc6_.trigger = param1;
            _loc6_.format = _loc5_;
            _loc6_.oldFormat = this.app.videoData.format;
            _loc6_.viewportRect = this.ytEnv.viewportRect;
            _loc6_.viewportFormat = this.getFormatForViewSize();
            _loc6_.readAheadBuffer = this.readAhead(_loc7_);
            _loc6_.bandwidthEstimate = param1 == FormatSelectionRecord.INITIAL ? this.storedRate : this.getSmoothedBandwidth();
            this.lastEvaluated = _loc6_;
         }
         return _loc5_;
      }
      
      protected function getFormatBySizeOnly() : VideoFormat
      {
         var _loc1_:VideoFormat = this.getFormatForViewSize();
         if(this.videoData.hasFormat() && this.videoData.isFormatAllowedToPlay(this.videoData.format) && !this.ytEnv.useDualSplicers && _loc1_ && _loc1_.quality <= this.videoData.format.quality)
         {
            return null;
         }
         return _loc1_;
      }
      
      protected function getAllowedFormats() : Array
      {
         return this.videoData.formatList.filter(this.byAllowed);
      }
      
      protected function recordSwitch(param1:VideoFormat, param2:VideoFormat) : void
      {
         var _loc3_:String = param1.name;
         var _loc4_:String = param2.name;
         this.transitions.push(_loc3_ + "-" + _loc4_);
         var _loc5_:Number = this.predictor.getEstimate();
         if(isNaN(_loc5_))
         {
            return;
         }
         var _loc6_:Number = param1.byteRate;
         var _loc7_:Number = param2.byteRate;
         var _loc8_:Boolean = _loc6_ > _loc5_ && _loc6_ > _loc7_;
         if(_loc8_)
         {
            if(_loc3_ in this.switchDownCount)
            {
               ++this.switchDownCount[_loc3_];
            }
            else
            {
               this.switchDownCount[_loc3_] = 1;
            }
         }
      }
      
      protected function switchDir(param1:VideoFormat, param2:VideoFormat) : int
      {
         var _loc3_:Number = param1.byteRate;
         var _loc4_:Number = param2.byteRate;
         if(_loc4_ > _loc3_)
         {
            return 1;
         }
         if(_loc4_ < _loc3_)
         {
            return -1;
         }
         return 0;
      }
      
      protected function get player() : IVideoPlayer
      {
         return this.app.videoPlayer;
      }
      
      public function onBandwidthSample(param1:BandwidthSample) : void
      {
         this.predictor.addSample(param1);
      }
      
      protected function meetsConstraints(param1:PlayerInfo, param2:Number, param3:VideoFormat, param4:VideoFormat) : Boolean
      {
         var _loc5_:uint = param4.byteRate;
         var _loc6_:int = this.switchDir(param3,param4);
         var _loc7_:* = _loc6_ <= 0;
         var _loc8_:* = _loc6_ < 0;
         var _loc9_:* = !isNaN(param2);
         var _loc10_:Number = _loc5_ / param2;
         var _loc11_:Number = this.player.isPeggedToLive() ? HLS_BUFFER_SECONDS : SAFE_BUFF;
         var _loc12_:Number = this.player.isPeggedToLive() ? HLS_BUFFER_SECONDS : ADEQUATE_BUFF;
         var _loc13_:* = this.readAhead(param1) > _loc11_;
         var _loc14_:* = this.readAhead(param1) > _loc12_;
         var _loc15_:Number = HYSTERESIS / 2;
         var _loc16_:* = _loc10_ < RATE_FRACTION - _loc15_;
         var _loc17_:* = _loc10_ < RATE_FRACTION + _loc15_;
         var _loc18_:Boolean = this.bySize(param4,0,null);
         var _loc19_:* = !this.isHd(param4);
         var _loc20_:uint = param4.name in this.switchDownCount ? uint(this.switchDownCount[param4.name]) : 0;
         var _loc21_:uint = this.isHd(param4) ? 2 : 3;
         return _loc18_ && _loc20_ < _loc21_ && this.videoData.isFormatAllowedToPlay(param4) && (_loc19_ || param1.hardwarePlayback) && (_loc13_ || !_loc9_ || _loc17_) && (_loc9_ || _loc7_) && (_loc16_ || _loc7_) && (_loc13_ || _loc7_) && (!_loc9_ || _loc17_ || _loc14_ || _loc8_);
      }
      
      protected function readAhead(param1:PlayerInfo) : Number
      {
         return param1.loadedTime / 1000 - param1.playhead;
      }
      
      public function getSmoothedBandwidth() : Number
      {
         return this.isAdaptive ? this.predictor.getEstimate() : NaN;
      }
      
      protected function getFormatForViewSize() : VideoFormat
      {
         var _loc1_:Array = this.videoData.formatList;
         var _loc2_:VideoFormat = _loc1_.filter(this.byAllowed).filter(this.bySize).filter(this.byHd).shift();
         return _loc2_ || _loc1_.filter(this.byAllowed).pop();
      }
      
      protected function recordSpinners() : void
      {
         var _loc1_:String = this.videoData.format.name;
         var _loc2_:Boolean = this.player.getPlayerState() is BufferingState && this.player.getTime() > this.player.getVideoData().startSeconds;
         if(_loc2_)
         {
            if(!(_loc1_ in this.formatBufferTime))
            {
               this.formatBufferTime[_loc1_] = 1;
            }
            else
            {
               this.formatBufferTime[_loc1_] += 1;
            }
         }
      }
      
      protected function isSwitchProhibited(param1:PlayerInfo) : Boolean
      {
         var _loc2_:* = this.player.getPlayerState() is IPausedState;
         return _loc2_ || param1.splicingNow || !param1.hasSeamless || !this.getAllowedFormats().length || getTimer() - this.spliceMoratoriumStartTime < MIN_SWITCH_MILLIS;
      }
      
      public function onSeek() : void
      {
         this.spliceMoratoriumStartTime = getTimer();
      }
      
      protected function byHd(param1:VideoFormat, param2:int, param3:Array) : Boolean
      {
         return this.isHdAllowed || !this.isHd(param1);
      }
      
      protected function getInitialAdaptiveFormat() : VideoFormat
      {
         var _loc5_:VideoFormat = null;
         var _loc6_:Number = NaN;
         var _loc1_:Array = this.getAllowedFormats();
         if(!_loc1_.length)
         {
            return null;
         }
         var _loc2_:VideoFormat = _loc1_[_loc1_.length - 1];
         var _loc3_:* = _loc2_.name == "5";
         if(_loc3_ && this.storedRate && _loc1_.length > 1)
         {
            _loc5_ = _loc1_[_loc1_.length - 2];
            _loc6_ = _loc5_.byteRate;
            if(_loc6_ / this.storedRate >= RATE_FRACTION)
            {
               this.formatBufferTime[_loc5_.name] = SAMPLE_THRESHOLD_FOR_LOW_QUALITY_UNLOCK;
            }
            else
            {
               _loc1_.pop();
            }
         }
         var _loc4_:VideoFormat = _loc1_.filter(this.bySize).filter(this.byHd).filter(this.byStoredRate).shift();
         return (_loc4_) || _loc1_[this.getLowestQualityAvailable()];
      }
      
      protected function chooseFormat(param1:PlayerInfo) : VideoFormat
      {
         var _loc7_:VideoFormat = null;
         var _loc2_:VideoFormat = this.videoData.format;
         var _loc3_:int = this.getLowestQualityAvailable();
         var _loc4_:Number = this.predictor.getEstimate();
         var _loc5_:Array = this.getAllowedFormats();
         var _loc6_:int = 0;
         while(_loc6_ <= _loc3_)
         {
            _loc7_ = _loc5_[_loc6_];
            if(this.meetsConstraints(param1,_loc4_,_loc2_,_loc7_))
            {
               return _loc7_;
            }
            _loc6_++;
         }
         return _loc5_[_loc3_];
      }
      
      protected function bySize(param1:VideoFormat, param2:int, param3:Array) : Boolean
      {
         var _loc4_:Number = 1;
         if(this.app.stageAmbassador.hasOwnProperty("contentsScaleFactor"))
         {
            _loc4_ = Number(this.app.stageAmbassador.contentsScaleFactor);
         }
         var _loc5_:int = Math.ceil(this.ytEnv.viewportRect.width * _loc4_);
         var _loc6_:int = Math.ceil(this.ytEnv.viewportRect.height * _loc4_);
         var _loc7_:Number = 16 / 9;
         if(_loc5_ > Math.round(_loc7_ * _loc6_))
         {
            _loc5_ = Math.round(_loc7_ * _loc6_);
         }
         var _loc8_:int = _loc5_ * _loc6_;
         var _loc9_:int = param1.size.width * param1.size.height;
         var _loc10_:Number = param1.quality == VideoQuality.MEDIUM ? 0.26 : 0.85;
         return _loc9_ * _loc10_ < _loc8_;
      }
   }
}

