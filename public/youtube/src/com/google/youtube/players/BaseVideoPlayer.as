package com.google.youtube.players
{
   import com.google.utils.RequestVariables;
   import com.google.utils.Scheduler;
   import com.google.youtube.event.LogEvent;
   import com.google.youtube.event.PlaybackRateEvent;
   import com.google.youtube.event.SpliceEvent;
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.event.VideoProgressEvent;
   import com.google.youtube.event.VolumeEvent;
   import com.google.youtube.model.FailureReport;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.VideoDataEvent;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.net.NetStream;
   
   public class BaseVideoPlayer extends Sprite implements IVideoPlayer
   {
      
      public static const FUDGE_PIXELS:Number = 8;
      
      protected static const PROGRESS_INTERVAL:Number = 150;
      
      protected var ignorePeggedToLive:Boolean = false;
      
      protected var progressScheduler:Scheduler;
      
      protected var peggedToLiveValue:Boolean = false;
      
      protected var volume:Number = 100;
      
      private var capturedFrame:BitmapData = null;
      
      protected var bufferEmptyEvents:Number = 0;
      
      protected var videoUrlProviderValue:IVideoUrlProvider;
      
      protected var state:IPlayerState;
      
      protected var playbackRateValue:Number = 1;
      
      protected var videoData:VideoData;
      
      protected var displayRect:Rectangle = new Rectangle();
      
      public function BaseVideoPlayer(param1:IVideoUrlProvider)
      {
         this.progressScheduler = Scheduler.setInterval(PROGRESS_INTERVAL,this.onProgress);
         super();
         this.videoUrlProviderValue = param1;
         this.stop();
      }
      
      public function destroy() : void
      {
         this.stop();
         this.setPlayerState(new DestroyedPlayerState(this));
         this.setVideoData(null);
      }
      
      public function stop() : void
      {
         this.progressScheduler.stop();
         this.setPlayerState(new NotStartedState(this));
      }
      
      protected function setDisplayRect(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.displayRect = new Rectangle(param1,param2,param3,param4);
      }
      
      public function get videoUrlProvider() : IVideoUrlProvider
      {
         return this.videoUrlProviderValue;
      }
      
      public function getDuration() : Number
      {
         if(Boolean(this.videoData) && Boolean(this.videoData.duration))
         {
            return this.videoData.duration;
         }
         if(Boolean(this.videoData) && this.videoData.isLive)
         {
            return this.getTime();
         }
         return 0;
      }
      
      public function onInterstitialComplete(param1:Event) : void
      {
      }
      
      public function getVideoData() : VideoData
      {
         return this.videoData;
      }
      
      public function getVolume() : Number
      {
         return this.volume;
      }
      
      public function setVolume(param1:Number) : void
      {
         this.volume = param1;
         dispatchEvent(new VolumeEvent(VolumeEvent.CHANGE,this.volume));
      }
      
      public function getLoadedFraction() : Number
      {
         var _loc1_:Number = this.getDuration();
         var _loc2_:Number = this.getBytesTotal();
         var _loc3_:Number = this.getBytesLoaded();
         var _loc4_:Number = this.videoData ? this.videoData.startSeconds : 0;
         var _loc5_:Number = (_loc4_ + _loc3_ / _loc2_ * (_loc1_ - _loc4_)) / _loc1_;
         return isNaN(_loc5_) || _loc5_ < 0 ? 0 : Math.min(1,_loc5_);
      }
      
      public function getPlayerInfo(param1:PlayerInfo) : void
      {
      }
      
      public function getBytesLoaded() : Number
      {
         return 0;
      }
      
      public function setIgnorePeggedToLive(param1:Boolean) : void
      {
         this.ignorePeggedToLive = param1;
      }
      
      public function play(param1:VideoData = null) : void
      {
         this.setPlayerState(this.state.play(param1));
      }
      
      public function getLoggingOptions() : Object
      {
         return {};
      }
      
      public function set playbackRate(param1:Number) : void
      {
         if(this.playbackRate != param1)
         {
            this.playbackRateValue = param1;
            dispatchEvent(new PlaybackRateEvent(PlaybackRateEvent.RATE_CHANGE,param1));
         }
      }
      
      public function isTagStreaming() : Boolean
      {
         return false;
      }
      
      protected function disconnectStream() : void
      {
      }
      
      public function getVideoRect() : Rectangle
      {
         return this.videoData.format ? new Rectangle(0,0,this.videoData.format.size.width,this.videoData.format.size.height) : new Rectangle();
      }
      
      public function getTime() : Number
      {
         return this.videoData ? this.videoData.startSeconds : 0;
      }
      
      public function onProgress(param1:Event = null) : void
      {
         if(this.isEnded())
         {
            this.end();
         }
         dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS,this.getTime(),this.getDuration(),this.getBytesLoaded(),this.getBytesTotal(),this.getLoadedFraction()));
      }
      
      public function getDefaultVideoSurface() : DisplayObject
      {
         return null;
      }
      
      public function isPeggedToLive() : Boolean
      {
         return this.peggedToLiveValue;
      }
      
      protected function setPlayerState(param1:IPlayerState) : void
      {
         if(this.state == param1 || this.state is UnrecoverableErrorState)
         {
            return;
         }
         if(this.videoData)
         {
            this.videoData.setEnded(param1 is IEndedState,this.getTime());
         }
         if(!this.ignorePeggedToLive || param1.isPeggedToLive)
         {
            this.peggedToLiveValue = param1.isPeggedToLive;
         }
         var _loc2_:IPlayerState = this.state;
         this.state = param1;
         dispatchEvent(new StateChangeEvent(StateChangeEvent.STATE_CHANGE,this.state,_loc2_));
      }
      
      public function initiateSplice() : void
      {
         if(this.videoData.startSeconds < 3)
         {
            this.videoData.startSeconds = 0;
         }
         dispatchEvent(new SpliceEvent(SpliceEvent.COMPLETE));
         this.initiatePlayback();
      }
      
      public function seek(param1:Number, param2:Boolean = true) : void
      {
         this.setPlayerState(this.state.seek(param1,param2));
      }
      
      public function splice(param1:VideoData = null) : void
      {
         this.setPlayerState(this.state.splice(param1));
      }
      
      public function get stream() : NetStream
      {
         return null;
      }
      
      public function unrecoverableError(param1:String = null) : void
      {
         this.stop();
         this.setPlayerState(this.state.unrecoverableError(param1));
      }
      
      public function getBytesTotal() : Number
      {
         return 0;
      }
      
      public function getDisplayRect() : Rectangle
      {
         return this.displayRect;
      }
      
      public function setVideoData(param1:VideoData) : void
      {
         if(param1 != this.videoData)
         {
            this.videoData = param1;
            if(this.videoData)
            {
               this.videoData.dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this.videoData,VideoDataEvent.NEW_VIDEO_DATA));
            }
         }
      }
      
      public function resetVideoSurface(param1:DisplayObject = null) : void
      {
      }
      
      public function get playbackRate() : Number
      {
         return this.playbackRateValue;
      }
      
      public function isStageVideoAvailable() : Boolean
      {
         return false;
      }
      
      public function resetStream(param1:Boolean = true) : void
      {
         this.bufferEmptyEvents = 0;
      }
      
      public function getBufferEmptyEvents() : Number
      {
         return this.bufferEmptyEvents;
      }
      
      public function getFPS() : Number
      {
         return 0;
      }
      
      public function resize(param1:Number, param2:Number, param3:Boolean = true) : void
      {
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc4_:Number = 16 / 9;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         if(this.videoData)
         {
            _loc4_ = Number(this.videoData.aspectOverride || this.videoData.videoWidth / this.videoData.videoHeight);
            _loc5_ = this.videoData.cropOverride;
            _loc6_ = this.videoData.aspectOverride;
            if(_loc5_ == VideoData.AUTO_CROP)
            {
               _loc5_ = param1 / param2;
            }
         }
         var _loc7_:Number = param1;
         var _loc8_:Number = param2;
         if(Boolean(_loc6_) || param3)
         {
            if(param1 > _loc4_ * param2)
            {
               _loc7_ = Math.round(_loc4_ * param2);
            }
            else
            {
               _loc8_ = Math.round(param1 / _loc4_);
            }
         }
         if(_loc8_ > 0)
         {
            _loc4_ = _loc7_ / _loc8_;
         }
         var _loc9_:Number = param1 / param2;
         var _loc10_:Number = _loc4_;
         if(_loc5_ > 0)
         {
            _loc10_ = _loc5_;
         }
         if(_loc10_ >= _loc4_)
         {
            if(_loc10_ >= _loc9_)
            {
               _loc11_ = param1;
               _loc12_ = param1 / _loc4_;
            }
            else
            {
               _loc11_ = param2 * _loc10_;
               _loc12_ = _loc11_ / _loc4_;
            }
         }
         else if(_loc10_ >= _loc9_)
         {
            _loc12_ = param1 / _loc10_;
            _loc11_ = _loc12_ * _loc4_;
         }
         else
         {
            _loc12_ = param2;
            _loc11_ = _loc12_ * _loc4_;
         }
         if(this.videoData && Math.abs(_loc11_ - this.videoData.videoWidth) <= FUDGE_PIXELS && Math.abs(_loc12_ - this.videoData.videoHeight) <= FUDGE_PIXELS)
         {
            _loc11_ = this.videoData.videoWidth;
            _loc12_ = this.videoData.videoHeight;
         }
         else if(param1 > _loc11_ && param1 - _loc11_ <= FUDGE_PIXELS)
         {
            _loc11_ = param1;
            _loc12_ = Math.round(_loc11_ / _loc4_);
         }
         else
         {
            _loc11_ = Math.round(_loc11_);
            _loc12_ = Math.round(_loc12_);
         }
         var _loc13_:Number = Math.floor((param1 - _loc11_) / 2);
         var _loc14_:Number = Math.floor((param2 - _loc12_) / 2);
         this.setDisplayRect(_loc13_,_loc14_,_loc11_,_loc12_);
      }
      
      protected function isEnded() : Boolean
      {
         return this.getTime() > this.videoData.clipEnd;
      }
      
      public function captureFrame(param1:Boolean = true) : BitmapData
      {
         if(!param1 || !this.capturedFrame)
         {
            this.capturedFrame = new BitmapData(width,height);
         }
         this.capturedFrame.draw(this);
         return this.capturedFrame;
      }
      
      public function showInterstitial() : Boolean
      {
         return false;
      }
      
      public function end() : void
      {
         this.pause();
         this.progressScheduler.stop();
         this.setPlayerState(new EndedState(this));
      }
      
      public function needsCorrectAspect() : Boolean
      {
         return false;
      }
      
      public function onCDNFailover() : void
      {
         var _loc2_:Object = null;
         var _loc3_:RequestVariables = null;
         var _loc1_:Number = this.videoData.cdnList.length;
         if(this.videoData.cdnListIndex < _loc1_ - 1)
         {
            ++this.videoData.cdnListIndex;
            _loc2_ = this.videoData.cdnList[this.videoData.cdnListIndex];
            this.videoData.partnerId = _loc2_.partnerId;
            this.videoData.setFormatList(_loc2_.fmt_list,_loc2_.fmt_stream_map);
            _loc3_ = new RequestVariables();
            _loc3_.ec = FailureReport.CDN_FAILOVER_ERROR_CODE;
            dispatchEvent(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,_loc3_));
            this.videoData.format = this.videoData.getFormatForQualityAndRect(this.videoData.videoQuality,this.displayRect);
            this.disconnectStream();
            this.play(this.videoData);
         }
         else
         {
            this.stop();
            this.setPlayerState(new ErrorState(this,new VideoErrorEvent(VideoErrorEvent.ERROR)));
         }
      }
      
      public function initiatePlayback() : void
      {
      }
      
      public function isCached(param1:Number) : Boolean
      {
         return false;
      }
      
      public function get availablePlaybackRates() : Array
      {
         return [1];
      }
      
      public function pause() : void
      {
         this.setPlayerState(this.state.pause());
      }
      
      public function getPlayerState() : IPlayerState
      {
         return this.state;
      }
      
      public function getBuffers() : Array
      {
         return [];
      }
   }
}

