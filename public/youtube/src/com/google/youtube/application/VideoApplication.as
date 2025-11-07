package com.google.youtube.application
{
   import com.google.events.SchedulerEvent;
   import com.google.utils.IStatProducer;
   import com.google.utils.IVideoStats;
   import com.google.utils.PlayerVersion;
   import com.google.utils.RequestLoader;
   import com.google.utils.RequestVariables;
   import com.google.utils.SafeLoader;
   import com.google.utils.Scheduler;
   import com.google.utils.Url;
   import com.google.utils.VideoStats;
   import com.google.utils.VideoStatsVersion2;
   import com.google.youtube.event.AccessibilityPropertiesEvent;
   import com.google.youtube.event.ActionBarEvent;
   import com.google.youtube.event.AdEvent;
   import com.google.youtube.event.BandwidthSampleEvent;
   import com.google.youtube.event.ExternalEvent;
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.event.LogEvent;
   import com.google.youtube.event.PlaybackRateEvent;
   import com.google.youtube.event.ResizeEvent;
   import com.google.youtube.event.ShuffleEvent;
   import com.google.youtube.event.SpliceEvent;
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.event.VideoProgressEvent;
   import com.google.youtube.model.EventLabel;
   import com.google.youtube.model.ExternalPlayerState;
   import com.google.youtube.model.FailureReport;
   import com.google.youtube.model.FormatSelectionRecord;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.PlayerStyle;
   import com.google.youtube.model.Playlist;
   import com.google.youtube.model.SharedSoundData;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.VideoDataEvent;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.VideoQuality;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.model.YouTubeEnvironment;
   import com.google.youtube.modules.IModule;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.IScriptCapability;
   import com.google.youtube.modules.IStageScaleCapability;
   import com.google.youtube.modules.IVideoFilterCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.modules.ModuleEvent;
   import com.google.youtube.modules.ModuleHost;
   import com.google.youtube.modules.ModuleStatus;
   import com.google.youtube.modules.ad.AdModuleDescriptor;
   import com.google.youtube.modules.flashaccess.FlashAccessModuleDescriptor;
   import com.google.youtube.modules.fresca.FrescaModuleDescriptor;
   import com.google.youtube.modules.ratings.RatingsModuleDescriptor;
   import com.google.youtube.modules.streaminglib.StreamingLibModuleDescriptor;
   import com.google.youtube.modules.threed.ThreeDModuleDescriptor;
   import com.google.youtube.modules.usergoals.UserGoalsModuleDescriptor;
   import com.google.youtube.modules.ypc.YpcLicenseCheckerModuleDescriptor;
   import com.google.youtube.modules.ypc.YpcModuleDescriptor;
   import com.google.youtube.players.AkamaiRTMPEndedState;
   import com.google.youtube.players.ErrorState;
   import com.google.youtube.players.IBufferingState;
   import com.google.youtube.players.IEndedState;
   import com.google.youtube.players.IExternalState;
   import com.google.youtube.players.IPausedState;
   import com.google.youtube.players.IPlayerState;
   import com.google.youtube.players.IPlayingState;
   import com.google.youtube.players.ISeekingState;
   import com.google.youtube.players.IVideoAdAware;
   import com.google.youtube.players.IVideoAdEventProvider;
   import com.google.youtube.players.IVideoPlayer;
   import com.google.youtube.players.NotStartedState;
   import com.google.youtube.players.PlayerFactory;
   import com.google.youtube.players.SeekingState;
   import com.google.youtube.players.StateChangeEvent;
   import com.google.youtube.players.TagStreamPlayer;
   import com.google.youtube.players.UnrecoverableErrorState;
   import com.google.youtube.time.CueRange;
   import com.google.youtube.time.CueRangeEvent;
   import com.google.youtube.time.CueRangeManager;
   import com.google.youtube.time.TimeRange;
   import com.google.youtube.ui.DefaultWatermark;
   import com.google.youtube.ui.Drawing;
   import com.google.youtube.ui.LargePlayButton;
   import com.google.youtube.ui.LayoutElement;
   import com.google.youtube.ui.Preloader;
   import com.google.youtube.ui.SeekBarMarker;
   import com.google.youtube.ui.Tooltip;
   import com.google.youtube.ui.UIElement;
   import com.google.youtube.ui.VideoFaceplate;
   import com.google.youtube.ui.VideoStill;
   import com.google.youtube.ui.Watermark;
   import com.google.youtube.ui.drawing;
   import com.google.youtube.util.BandwidthCalculator;
   import com.google.youtube.util.EventRouter;
   import com.google.youtube.util.Layout;
   import com.google.youtube.util.StageAmbassador;
   import com.google.youtube.util.StreamingStats;
   import com.google.youtube.util.Tween;
   import flash.accessibility.Accessibility;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageDisplayState;
   import flash.display.StageScaleMode;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.EventPhase;
   import flash.events.FocusEvent;
   import flash.events.FullScreenEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.ui.Keyboard;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class VideoApplication extends Application implements IStatProducer
   {
      
      protected static const END_SCREEN_CUERANGE_ID:String = "END_SCREEN_CUERANGE_ID";
      
      protected static const PREROLL_CUERANGE_ID:String = "PREROLL_CUERANGE_ID";
      
      public static const CARDIO_HEARTBEAT_METRIC:String = "heartbeat";
      
      public static const CARDIO_HEARTBEAT_AD_METRIC:String = "heartbeat_ad";
      
      public static const CARDIO_HEARTBEAT_SLATE_METRIC:String = "heartbeat_slate";
      
      public static const CARDIO_CONNECTED_METRIC:String = "connected";
      
      public static const CARDIO_PLAYBACK_METRIC:String = "playback";
      
      public static const CARDIO_ERROR_METRIC_FORMAT:String = "error-{ec}";
      
      private static const CARDIO_HEARTBEAT_INTERVAL:Number = 30000;
      
      protected static const INITIAL_ACCESSIBILITY_UPDATE_DELAY_MS:Number = 2000;
      
      protected static const ACCESSIBILITY_UPDATE_DELAY_MS:Number = 100;
      
      protected var cardioHeartbeatScheduler:Scheduler;
      
      protected var apiEndScreenCueRange:CueRange;
      
      protected var playbackDelay:Number;
      
      protected var moduleHost:ModuleHost;
      
      protected var seekSoftTimeout:Scheduler;
      
      protected var totalProgressMediaTime:Number = 0;
      
      protected var nominalWidth:Number = 640;
      
      protected var towardsEndOfMovieThreshold:int = 101;
      
      protected var adProgressInterval:Scheduler;
      
      protected var watermark:Watermark;
      
      protected var tabbableElements:Array = [];
      
      protected var lastExternalPlayerStateTime:Number;
      
      protected var sharedSoundData:SharedSoundData;
      
      protected var preloader:Preloader;
      
      protected var playbackStartTime:int = -1;
      
      protected var isAdPlaying:Boolean;
      
      protected var enableKeyboard:Boolean;
      
      protected var prerollCueRange:CueRange;
      
      protected var state:IAppState;
      
      protected var currentProgressWallTime:Number;
      
      protected var videoFaceplate:VideoFaceplate;
      
      protected var seekStartWallTime:Number;
      
      protected var currentProgressMediaTime:Number = 0;
      
      protected var advertiserVideoCueRanges:Object = {};
      
      protected var smoother:BandwidthCalculator = new BandwidthCalculator(90);
      
      protected var shouldTrackPlaybackProgress:Boolean;
      
      protected var videoStats:IVideoStats;
      
      protected var formatSelector:FormatSelector;
      
      protected var cardioRequestLoader:RequestLoader = new RequestLoader();
      
      protected var stopBlackout:LayoutElement = new LayoutElement();
      
      protected var errorReportCount:Number = 0;
      
      protected var layerManager:ApplicationLayerManager = new ApplicationLayerManager();
      
      protected var largePlayButton:LargePlayButton;
      
      protected var nominalHeight:Number = 360;
      
      protected var layout:Layout;
      
      protected var background:Sprite;
      
      protected var nowSplicing:Object = {};
      
      protected var lastProgressMediaTime:Number = 0;
      
      public var videoPlayer:IVideoPlayer;
      
      protected var keyboardExceptions:Object = {};
      
      protected var videoDataDispatcher:EventDispatcher = new EventDispatcher();
      
      protected var videoAdEventProvider:IVideoAdEventProvider;
      
      protected var streamingStats:StreamingStats;
      
      protected var prebufferVideoData:VideoData;
      
      protected var externalPlayerState:Number;
      
      protected var playerMask:LayoutElement;
      
      protected var isSized:Boolean = false;
      
      protected var cueRangeManager:CueRangeManager;
      
      protected var playlistCued:Boolean = true;
      
      protected var viewportRect:Rectangle = new Rectangle();
      
      protected var uiEventDispatcher:EventDispatcher = new EventDispatcher();
      
      protected var accessibilityUpdateTimeout:Scheduler;
      
      protected var expirationTimeout:Scheduler;
      
      protected var focusManager:EventRouter;
      
      protected var lastProgressWallTime:Number;
      
      protected var lastCardioMediaTime:Number = 0;
      
      protected var ytEnv:YouTubeEnvironment;
      
      protected var stopBlackoutTween:Tween = new Tween(this.stopBlackout).easeOut();
      
      protected var preloaderReveal:Tween;
      
      protected var videoStill:VideoStill;
      
      protected var apiCueRanges:Object = {};
      
      public function VideoApplication(param1:Object = null)
      {
         super(param1);
         addEventListener(AppStateChangeEvent.STATE_CHANGE,this.onAppStateChange);
         this.setAppState(new UnbuiltAppState(this));
         buildPolicy = BUILD_POLICY_AUTO;
      }
      
      protected function navigateToUrl(param1:URLRequest, param2:String = null) : void
      {
         var time:Number = NaN;
         var request:URLRequest = param1;
         var target:String = param2;
         if(request)
         {
            if(this.isFullScreen())
            {
               this.toggleFullScreen();
            }
            time = this.videoPlayer.getTime();
            if(request.data is RequestVariables && request.data.v && request.data.v == this.videoData.videoId && time > 10 && this.videoPlayer.getDuration() - time > 10)
            {
               RequestVariables(request.data).setHash("at=" + Math.round(this.videoPlayer.getTime()));
            }
            if(request.data && request.data.feature && (this.ytEnv.isIframeEmbed || this.ytEnv.onSite))
            {
               environment.broadcastExternal(new ExternalEvent(ExternalEvent.NAVIGATE,{
                  "url":request.url + request.data,
                  "feature":request.data.feature
               }));
            }
            try
            {
               navigateToURL(request,target);
            }
            catch(error:SecurityError)
            {
            }
            if(this.videoData.isPartnerWatermark)
            {
               if(!this.isAdPlaying)
               {
                  this.pauseVideo();
               }
            }
            else if(!(this.videoPlayer.getPlayerState() is IEndedState) && !(this.videoPlayer.getPlayerState() is NotStartedState) && !(this.videoPlayer.getPlayerState() is ErrorState))
            {
               if(this.videoPlayer.isTagStreaming() || this.ytEnv.isAdPlayback)
               {
                  this.pauseVideo();
               }
               else
               {
                  this.stopVideo();
               }
            }
         }
      }
      
      public function getVideoWatchUrl() : String
      {
         return this.videoPlayer.videoUrlProvider.getVideoWatchUrl(this.videoData);
      }
      
      protected function onS2Log(param1:VideoData, param2:RequestVariables) : URLRequest
      {
         var _loc3_:URLRequest = this.ytEnv.getS2LoggingRequest(param1,param2);
         var _loc4_:RequestLoader = new RequestLoader();
         _loc4_.loadRequest(_loc3_);
         return _loc3_;
      }
      
      public function cueVideo(param1:VideoData) : void
      {
         this.prepareVideo(param1);
         this.setAppState(new PendingUserInputAppState(this));
         this.setExternalState(ExternalPlayerState.CUED);
      }
      
      public function resizeApplication(param1:Number, param2:Number) : void
      {
         this.viewportRect.width = param1;
         this.viewportRect.height = param2;
         this.nominalWidth = param1;
         this.nominalHeight = param2;
         if(!(this.state is UnbuiltAppState))
         {
            this.resizePlayer(param1,param2);
            this.resizeModule(this.viewportRect.clone(),this.viewportRect);
         }
         this.layout.realign();
         this.ytEnv.viewportRect = this.viewportRect;
         this.isSized = true;
      }
      
      public function getVideoData() : Object
      {
         return this.videoData.getExternalVideoData(this.ytEnv.isIframeEmbed);
      }
      
      public function getVolume() : Number
      {
         if(this.videoData.infringe)
         {
            return 0;
         }
         var _loc1_:Number = this.videoPlayer.getVolume();
         if(isNaN(_loc1_))
         {
            _loc1_ = 100;
         }
         return _loc1_;
      }
      
      protected function getPlaybackRate() : Number
      {
         return this.videoPlayer.playbackRate;
      }
      
      protected function initVideoStats(param1:Object) : void
      {
         if(this.ytEnv.videoStatsVersion2Experiment)
         {
            this.videoStats = new VideoStatsVersion2(this.ytEnv.videoStatsV2Url,this.ytEnv.videoStatsNamespace,param1);
         }
         else
         {
            this.videoStats = new VideoStats(this.ytEnv.videostatsUrl,this.ytEnv.videoStatsNamespace,param1);
         }
      }
      
      public function scriptedUnloadModule(param1:String) : void
      {
         var _loc2_:ModuleDescriptor = this.moduleHost.getDescriptorById(param1);
         if(Boolean(_loc2_) && IScriptCapability in _loc2_.capabilities)
         {
            this.moduleHost.unload(_loc2_);
         }
      }
      
      protected function autoAdvanceOnError() : Boolean
      {
         if(this.ytEnv.willAutoplay && this.ytEnv.playlist.index < this.ytEnv.playlist.length - 1 && this.videoPlayer.getTime() == 0)
         {
            this.onAfterMediaEnd();
            return true;
         }
         return false;
      }
      
      protected function setStillVisibility(param1:Boolean) : void
      {
         var _loc2_:String = null;
         if(this.videoPlayer)
         {
            _loc2_ = this.videoPlayer.videoUrlProvider.getStillUrl(this.videoData,this.viewportRect.width,this.viewportRect.height);
         }
         if(param1 && Boolean(_loc2_))
         {
            this.videoStill.load(_loc2_);
            this.layout.add(this.videoStill);
         }
         else
         {
            this.layout.remove(this.videoStill);
         }
      }
      
      public function mute() : void
      {
         this.sharedSoundData.setMute();
         this.updatePlayerAudio();
      }
      
      public function getMediaTime() : Number
      {
         return this.videoPlayer.getTime();
      }
      
      public function setVolume(param1:Number) : void
      {
         param1 = param1 < 0 ? 0 : (param1 > 100 ? 100 : param1);
         this.sharedSoundData.setVolume(param1);
         this.unMute();
      }
      
      public function scriptedPlayVideo() : void
      {
         this.videoData.scriptedPlayback = true;
         this.playVideo();
      }
      
      protected function updateAccessibilityProperties(param1:Event = null) : void
      {
         if(Capabilities.hasAccessibility && Accessibility.active)
         {
            if(this.preloader)
            {
               this.preloader.enabled = false;
            }
            Accessibility.updateProperties();
         }
         this.tabbableElements.sortOn(["tabOrderPriority"],Array.NUMERIC);
         var _loc2_:int = 0;
         while(_loc2_ < this.tabbableElements.length)
         {
            this.tabbableElements[_loc2_].tabIndex = _loc2_;
            _loc2_++;
         }
      }
      
      protected function onModuleLog(param1:String, param2:RequestVariables) : void
      {
         this.onLog(new LogEvent(LogEvent.LOG,param1,param2));
      }
      
      public function scriptedLoadVideoById(param1:Object, param2:Number = 0, param3:String = null) : void
      {
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(getQualifiedClassName(param1) == "Object")
         {
            if(!param1.videoId)
            {
               return;
            }
            _loc4_ = param1.videoId;
            param2 ||= Number(param1.startSeconds) || 0;
            _loc5_ = Number(param1.endSeconds);
            param3 = param1.suggestedQuality;
            _loc6_ = Number(param1.delay);
         }
         else
         {
            if(!(param1 is String))
            {
               return;
            }
            _loc4_ = String(param1);
         }
         this.prepareVideoById(_loc4_,param2,_loc5_,param3,_loc6_);
         this.videoData.scriptedPlayback = true;
         this.playVideo(this.videoData);
      }
      
      public function pauseVideo() : void
      {
         this.setAppState(this.state.pauseVideo());
         if(!(this.state is IBlockingAppState))
         {
            this.videoPlayer.pause();
         }
      }
      
      protected function onLogPlayback(param1:LogEvent) : void
      {
         var _loc2_:RequestVariables = null;
         var _loc3_:URLRequest = null;
         var _loc4_:RequestLoader = null;
         var _loc5_:URLRequest = null;
         var _loc6_:RequestLoader = null;
         if(this.ytEnv.isPlaybackLoggable && !this.videoData.isPlaybackLogged)
         {
            if(this.videoData.isGetVideoLoggable)
            {
               _loc2_ = param1.args || new RequestVariables();
               _loc3_ = this.ytEnv.getPlaybackLoggingRequest(this.videoData,_loc2_);
               _loc4_ = new RequestLoader();
               _loc4_.loadRequest(_loc3_);
               this.videoData.isGetVideoLoggable = false;
            }
            if(this.videoData.partnerTrackingToken)
            {
               _loc5_ = this.ytEnv.getPartnerLoggingRequest(this.videoData);
               _loc6_ = new RequestLoader();
               _loc6_.loadRequest(_loc5_);
            }
            if(this.ytEnv.logWatch)
            {
               this.logUserWatch(this.videoData,_loc2_);
            }
            this.videoData.isPlaybackLogged = true;
         }
      }
      
      protected function onMessageUpdate(param1:MessageEvent) : void
      {
         if(this.videoFaceplate)
         {
            this.videoFaceplate.adString = this.ytEnv.messages.getMessage(WatchMessages.ADVERTISEMENT);
            if(this.videoFaceplate.closeable)
            {
               this.videoFaceplate.showCloseButton(this.ytEnv.messages.getMessage(WatchMessages.RETURN_TO_VIDEO));
            }
         }
      }
      
      protected function resizeAllModuleDisplays(param1:Rectangle, param2:ModuleHost) : void
      {
         var _loc5_:ModuleDescriptor = null;
         var _loc3_:Array = param2.getLoadedModulesByCapability(IResizeableCapability);
         var _loc4_:ResizeEvent = new ResizeEvent(ResizeEvent.DISPLAY,param1);
         for each(_loc5_ in _loc3_)
         {
            IApplication(_loc5_.instance).guardedCall(IResizeableCapability(_loc5_.instance).onDisplayResize,_loc4_);
         }
      }
      
      public function cueVideoByThirdPartyFlvUrl(param1:String) : void
      {
         var _loc2_:Object = {
            "no_get_video_log":"1",
            "thirdPartyFlvUrl":param1
         };
         this.cueVideoByPlayerVars(_loc2_);
      }
      
      public function setLoop(param1:Boolean) : void
      {
         if(this.ytEnv.playlist)
         {
            this.ytEnv.playlist.loop = param1;
         }
      }
      
      protected function onVideoProgress(param1:VideoProgressEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:RequestVariables = null;
         var _loc4_:URLRequest = null;
         var _loc5_:RequestVariables = null;
         var _loc6_:PlayerInfo = null;
         this.currentProgressWallTime = getTimer() / 1000;
         this.currentProgressMediaTime = param1.time;
         if(this.shouldTrackPlaybackProgress && !this.isAdPlaying)
         {
            if(this.currentProgressWallTime - this.lastProgressWallTime > 0.05 && this.currentProgressMediaTime == this.lastProgressMediaTime)
            {
               this.playbackDelay += this.currentProgressWallTime - this.lastProgressWallTime;
            }
            else if(this.lastProgressMediaTime > 0 && this.currentProgressMediaTime > this.lastProgressMediaTime)
            {
               this.totalProgressMediaTime += this.currentProgressMediaTime - this.lastProgressMediaTime;
            }
            if(this.totalProgressMediaTime > 0)
            {
               this.sendCardioPlayback();
            }
            if(this.videoData.trackingToken)
            {
               _loc2_ = this.videoData.trackPoint;
               if(_loc2_ == 1 && this.currentProgressMediaTime > 0 || _loc2_ == 2 && this.currentProgressMediaTime >= 20 || _loc2_ == 3 && this.currentProgressMediaTime >= 30)
               {
                  _loc3_ = new RequestVariables();
                  _loc3_.st = _loc3_.et = this.currentProgressMediaTime;
                  _loc3_.ctp = _loc2_;
                  ++this.videoData.trackPoint;
                  this.onS2Log(this.videoData,_loc3_);
               }
            }
         }
         this.lastProgressWallTime = this.currentProgressWallTime;
         this.lastProgressMediaTime = this.currentProgressMediaTime;
         if(this.ytEnv.isPlaybackLoggable && this.videoData.duration && this.videoData.duration > 0 && !this.videoData.flvUrl && !this.videoData.calledSetAwesome() && this.totalProgressMediaTime >= Math.min(0.8 * this.videoData.duration,180))
         {
            _loc4_ = this.ytEnv.getSetAwesomeRequest(this.videoData,Math.floor(param1.time),Math.floor(this.totalProgressMediaTime));
            this.videoData.callSetAwesome(_loc4_);
         }
         if(this.ytEnv.isPlaybackLoggable && !this.videoData.isDelayedViewcountLogged && !this.ytEnv.videoStatsVersion2Experiment && this.videoData.delayedViewcountThreshold > 0 && this.totalProgressMediaTime >= Math.min(this.videoData.delayedViewcountThreshold,this.getMediaDuration()))
         {
            _loc5_ = new RequestVariables();
            _loc5_.tv = 1;
            this.videoData.isDelayedViewcountLogged = true;
            this.videoStats.sendReport(true,_loc5_);
         }
         if(this.videoData.duration && this.videoData.duration > 0 && this.totalProgressMediaTime >= this.videoData.conversionViewPingThreshold)
         {
            this.sendConversionViewPing();
         }
         if(this.videoPlayer.isTagStreaming())
         {
            _loc6_ = new PlayerInfo();
            this.videoPlayer.getPlayerInfo(_loc6_);
            if(Boolean(this.videoData.duration) && Boolean(_loc6_.loadedTime) && _loc6_.loadedTime >= this.videoData.duration * 1000)
            {
               this.tryPrebuffer();
            }
         }
         this.setPlaybackFormat(this.formatSelector.getVideoFormat(FormatSelectionRecord.ADAPTIVE));
         this.setExternalVideoProgress();
      }
      
      protected function sendCardioPlayback() : void
      {
         var _loc1_:RequestVariables = null;
         if(this.videoData.enableCardioRealtimeAnalytics && !this.videoData.sentCardioPlayback)
         {
            _loc1_ = new RequestVariables();
            _loc1_.metric = CARDIO_PLAYBACK_METRIC;
            this.loadCardioRequest(this.videoData,_loc1_);
            this.videoData.sentCardioPlayback = true;
            this.cardioHeartbeatScheduler.restart();
         }
      }
      
      public function cueVideoByConnAndStream(param1:String, param2:String) : void
      {
         var _loc3_:VideoData = new VideoData({});
         _loc3_.format = new VideoFormat(null,param2,param1);
         _loc3_.flvUrl = param2;
         this.addVideoPlayer(_loc3_);
         this.cueVideo(_loc3_);
      }
      
      protected function getPlaybackQuality() : VideoQuality
      {
         return this.videoData.format ? this.videoData.format.quality : this.ytEnv.videoQualityPref;
      }
      
      public function setShuffle(param1:Boolean) : void
      {
         if(this.ytEnv.playlist)
         {
            this.ytEnv.playlist.shuffle = param1;
         }
      }
      
      public function loadVideoByPlayerVars(param1:Object) : void
      {
         if(!param1.list)
         {
            this.ytEnv.playlist = null;
         }
         this.loadVideo(new VideoData(param1));
      }
      
      protected function clearVideo() : void
      {
         trace("Warning: clearVideo() is deprecated.");
      }
      
      public function playVideoAt(param1:int) : void
      {
         var _loc2_:VideoData = null;
         if(this.ytEnv.playlist)
         {
            _loc2_ = this.ytEnv.playlist.getVideo(param1);
            if(_loc2_)
            {
               this.ytEnv.playlist.index = param1;
               _loc2_.scriptedPlayback = true;
               this.loadVideo(_loc2_);
            }
            else
            {
               this.playlistCued = false;
               this.ytEnv.playlist.index = param1;
            }
         }
      }
      
      protected function setExternalState(param1:int) : void
      {
         var _loc2_:Number = this.getMediaTime();
         if(param1 != this.externalPlayerState || this.lastExternalPlayerStateTime != _loc2_)
         {
            this.externalPlayerState = param1;
            this.lastExternalPlayerStateTime = _loc2_;
            environment.broadcastExternal(new ExternalEvent(ExternalEvent.STATE_CHANGE,this.externalPlayerState));
         }
      }
      
      protected function onVideoStateChange(param1:StateChangeEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:RequestVariables = null;
         var _loc4_:ErrorState = null;
         var _loc5_:VideoErrorEvent = null;
         var _loc6_:RequestVariables = null;
         var _loc7_:Object = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:RequestVariables = null;
         var _loc11_:Number = NaN;
         this.cueRangeManager.onPlayerStateChange(param1);
         this.setPreloaderVisibility(param1.state is IBufferingState);
         if((param1.state is ISeekingState || param1.state is IPlayingState) && !this.videoStats.playbackStarted && this.ytEnv.videoStatsEnabled)
         {
            this.playbackDelay = 0;
            this.errorReportCount = 0;
            this.playbackStartTime = getTimer();
            this.videoStats.startPlayback(this.videoData.videoId,this.ytEnv.samplingWeight,this);
            if(this.streamingStats)
            {
               this.streamingStats.startPlayback(this.videoPlayer,this);
            }
            if(!isNaN(this.videoData.secondsToExpiration))
            {
               _loc2_ = this.videoData.secondsToExpiration;
               if(_loc2_ < 15)
               {
                  _loc2_ = 15;
               }
               this.expirationTimeout = Scheduler.setTimeout(_loc2_ * 1000,this.expireVideo);
            }
         }
         if(param1.state is ISeekingState || param1.state is IPausedState)
         {
            this.shouldTrackPlaybackProgress = false;
         }
         if(param1.state is IPlayingState)
         {
            this.shouldTrackPlaybackProgress = true;
            this.lastProgressWallTime = getTimer() / 1000;
         }
         else
         {
            this.lastProgressMediaTime = 0;
         }
         if(param1.state is IEndedState)
         {
            param1.preventDefault();
            if(this.videoStats.playbackStarted)
            {
               this.videoStats.sendReport();
            }
         }
         if(param1.state is AkamaiRTMPEndedState && (this.videoPlayer.getBytesLoaded() <= 0 || this.videoPlayer.getDuration() - this.videoPlayer.getTime() > 20))
         {
            _loc3_ = new RequestVariables();
            _loc3_.ec = FailureReport.ENDS_TOO_SOON_ERROR_CODE;
            _loc3_.len = this.videoPlayer.getDuration();
            _loc3_.end = this.videoPlayer.getTime();
            _loc3_.bc = this.videoPlayer.getBytesLoaded();
            this.onLog(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,_loc3_));
         }
         if(param1.state is ErrorState)
         {
            _loc4_ = ErrorState(param1.state);
            _loc5_ = _loc4_.error as VideoErrorEvent;
            if(_loc5_)
            {
               _loc6_ = new RequestVariables();
               if(this.hasFallback(_loc5_))
               {
                  _loc6_.retry = 1;
               }
               _loc6_.ec = FailureReport.getErrorCode(_loc5_);
               if(_loc6_.ec)
               {
                  if(this.videoData.isTransportRtmp())
                  {
                     _loc7_ = this.videoPlayer.getLoggingOptions();
                     if(_loc7_.sip)
                     {
                        _loc6_.sip = _loc7_.sip;
                     }
                  }
                  this.onLog(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,_loc6_));
               }
               if(_loc6_.retry == 1)
               {
                  this.videoData.isRetrying = true;
                  this.videoPlayer.play(this.videoData);
               }
               else if(!this.autoAdvanceOnError())
               {
                  _loc8_ = ErrorState(param1.state).error != null ? ErrorState(param1.state).error.text : "";
                  _loc9_ = WatchMessages.ERROR_GENERIC;
                  if(Boolean(_loc8_) && _loc8_.indexOf("GetVideoInfoError:") == 0)
                  {
                     _loc9_ = _loc8_.substr(_loc8_.indexOf(":") + 1);
                  }
                  else if(param1.state is UnrecoverableErrorState)
                  {
                     _loc9_ = UnrecoverableErrorState(param1.state).message || WatchMessages.ERROR_GENERIC;
                  }
                  else if(this.videoData.payPerStream && _loc8_ == "NetConnection.Connect.Closed")
                  {
                     _loc9_ = WatchMessages.ERROR_CONNECTION_AUTH;
                  }
                  this.displayApplicationError(_loc9_,_loc5_.errorCode);
               }
               if(this.cardioHeartbeatScheduler)
               {
                  this.cardioHeartbeatScheduler.stop();
               }
            }
         }
         if(!this.seekSoftTimeout.isRunning() && param1.state is ISeekingState && this.state is StartedAppState)
         {
            this.seekSoftTimeout.restart();
            if(SeekingState(param1.state).allowSeekAhead)
            {
               this.seekStartWallTime = getTimer();
            }
         }
         if(this.seekSoftTimeout.isRunning() && !(param1.state is ISeekingState) && !(param1.state is IBufferingState))
         {
            this.seekSoftTimeout.stop();
            if(!isNaN(this.seekStartWallTime) && this.videoData.enableRealtimeLogging)
            {
               _loc10_ = new RequestVariables();
               _loc11_ = (getTimer() - this.seekStartWallTime) / 1000;
               _loc10_.sl = _loc11_.toFixed(3);
               _loc10_.st = this.videoData.startSeconds;
               this.onLog(new LogEvent(LogEvent.LOG,"streaming",_loc10_));
               this.seekStartWallTime = NaN;
            }
         }
         if(this.streamingStats)
         {
            this.streamingStats.onVideoStateChange(param1);
         }
         if(!this.videoData.isPauseEnabled && param1.state is IPausedState)
         {
            this.layout.add(this.stopBlackout);
            this.stopBlackoutTween.fadeOut(0).fadeIn(16000);
         }
         else
         {
            this.layout.remove(this.stopBlackout);
         }
         if(param1.state is IExternalState && !param1.isDefaultPrevented())
         {
            this.setExternalState(IExternalState(param1.state).externalId);
         }
      }
      
      protected function disableVideoControls(param1:Object, param2:Object = null) : void
      {
         if(param1)
         {
            this.focusManager.delegate = param1;
         }
      }
      
      protected function loadCardioRequest(param1:VideoData, param2:RequestVariables) : URLRequest
      {
         param2.st = Math.floor(this.getMediaTime());
         var _loc3_:URLRequest = this.ytEnv.getCardioLoggingRequest(param1,param2);
         this.cardioRequestLoader.loadRequest(_loc3_);
         return _loc3_;
      }
      
      protected function resizeModule(param1:Rectangle, param2:Rectangle, param3:ModuleDescriptor = null) : void
      {
         var _loc5_:IResizeableCapability = null;
         var _loc6_:ResizeEvent = null;
         var _loc4_:int = numChildren - 1;
         while(_loc4_ >= 0)
         {
            _loc5_ = getChildAt(_loc4_) as IResizeableCapability;
            if((Boolean(_loc5_)) && (!param3 || param3.instance == _loc5_))
            {
               _loc6_ = new ResizeEvent(ResizeEvent.VIEWPORT,param1,param2.clone());
               IApplication(_loc5_).guardedCall(IResizeableCapability(_loc5_).onResize,_loc6_);
            }
            if(_loc5_ is IOverlayCapability)
            {
               param1.height -= IOverlayCapability(_loc5_).reservedRect.height;
            }
            _loc4_--;
         }
      }
      
      public function unMute() : void
      {
         this.sharedSoundData.unsetMute();
         this.updatePlayerAudio();
      }
      
      protected function setPlaybackQualityString(param1:String = "auto") : void
      {
         this.setPlaybackQuality(new VideoQuality(param1));
      }
      
      protected function shouldHandleKeyEvent(param1:KeyboardEvent) : Boolean
      {
         return this.shouldHandleKeyCode(param1.keyCode) && !param1.ctrlKey && !param1.altKey;
      }
      
      protected function onCueRangeRemoved(param1:CueRangeEvent) : void
      {
      }
      
      protected function onModuleSetLayer(param1:String, param2:String, param3:*) : void
      {
         var _loc4_:Object = {};
         _loc4_[param2] = param3;
         this.layerManager.setLayer(param1,_loc4_);
      }
      
      protected function setEnableControls(param1:*) : void
      {
         if(param1 === true)
         {
            this.enableVideoControls();
         }
         else if(param1)
         {
            this.disableVideoControls(param1.delegate,param1.except);
         }
         else
         {
            this.disableVideoControls(this);
         }
      }
      
      public function scriptedClickToPlayById(param1:Object, param2:Number = 0, param3:String = null) : void
      {
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(getQualifiedClassName(param1) == "Object")
         {
            if(!param1.videoId)
            {
               return;
            }
            _loc4_ = param1.videoId;
            param2 ||= Number(param1.startSeconds) || 0;
            _loc5_ = Number(param1.endSeconds);
            param3 = param1.suggestedQuality;
            _loc6_ = Number(param1.delay);
         }
         else
         {
            if(!(param1 is String))
            {
               return;
            }
            _loc4_ = String(param1);
         }
         this.prepareVideoById(_loc4_,param2,_loc5_,param3,_loc6_);
         this.videoData.scriptedClickToPlay = true;
         this.playVideo(this.videoData);
      }
      
      public function onSeekSoftTimeout(param1:Event = null) : void
      {
         var _loc2_:RequestVariables = new RequestVariables();
         _loc2_.ec = FailureReport.SOFT_TIMEOUT_ERROR_CODE;
         if(this.videoData.canRetry && this.videoPlayer.getBytesLoaded() <= 0)
         {
            _loc2_.retry = 1;
         }
         this.onLog(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,_loc2_));
         if(_loc2_.retry == 1)
         {
            this.videoData.isRetrying = true;
            this.playVideo(this.videoData);
         }
      }
      
      protected function isMuted() : Boolean
      {
         return this.videoData.infringe || this.sharedSoundData.isMuted();
      }
      
      protected function resizeModuleDisplay(param1:Rectangle, param2:ModuleDescriptor) : void
      {
         var _loc3_:ResizeEvent = null;
         if(Boolean(param2) && param2.instance is IResizeableCapability)
         {
            _loc3_ = new ResizeEvent(ResizeEvent.DISPLAY,param1);
            IApplication(param2.instance).guardedCall(IResizeableCapability(param2.instance).onDisplayResize,_loc3_);
         }
      }
      
      protected function setPreloaderVisibility(param1:Boolean) : void
      {
         if(this.preloader)
         {
            if(param1)
            {
               this.layout.add(this.preloader);
               this.preloaderReveal.easeIn().fadeIn();
            }
            else if(!this.preloader.interactive)
            {
               this.preloaderReveal.fadeOut();
               this.layout.remove(this.preloader);
            }
         }
      }
      
      public function toggleFullScreen(param1:Event = null) : void
      {
         if(!stageAmbassador.addedToStage || !PlayerVersion.isAtLeastVersion(9,0,28))
         {
            return;
         }
         if(this.isFullScreen())
         {
            stageAmbassador.displayState = StageDisplayState.NORMAL;
            return;
         }
         if(!this.allowsLateFullScreenSourceRect())
         {
            this.handleFullScreenSourceRect();
         }
         stageAmbassador.displayState = StageDisplayState.FULL_SCREEN;
         if(this.allowsLateFullScreenSourceRect())
         {
            this.handleFullScreenSourceRect();
         }
      }
      
      public function getPlaylistIndex() : int
      {
         return this.ytEnv.playlist ? this.ytEnv.playlist.index : -1;
      }
      
      override public function onInited() : void
      {
         if(stageAmbassador.stageWidth <= 0 && stageAmbassador.stageHeight <= 0)
         {
            Scheduler.setTimeout(0,function(param1:Event):void
            {
               onInited();
            });
            return;
         }
         super.onInited();
         this.onResize();
         this.startApplication();
         this.addCallbacks();
         this.layout.add(this.background,this.watermark);
         this.ytEnv.messages.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
         this.cardioHeartbeatScheduler = Scheduler.setInterval(CARDIO_HEARTBEAT_INTERVAL,this.sendCardioHeartbeat);
         this.cardioHeartbeatScheduler.stop();
         this.onVideoDataChange(new VideoDataEvent(VideoDataEvent.CHANGE,this.videoData,VideoDataEvent.NEW_VIDEO_DATA));
         environment.broadcastExternal(new ExternalEvent(ExternalEvent.READY,this.ytEnv.playerApiId));
         this.setExternalState(ExternalPlayerState.UNSTARTED);
      }
      
      public function cueVideoByUrl(param1:Object, param2:Number = 0, param3:String = null) : void
      {
         var _loc4_:Url = null;
         if(getQualifiedClassName(param1) == "Object")
         {
            if(!param1.mediaContentUrl)
            {
               return;
            }
            _loc4_ = new Url(param1.mediaContentUrl);
            param2 ||= Number(param1.startSeconds) || 0;
            param3 = param1.suggestedQuality;
         }
         else
         {
            if(!(param1 is String))
            {
               return;
            }
            _loc4_ = new Url(String(param1));
         }
         this.ytEnv.applyGdataDevParams(_loc4_.queryVars);
         this.cueVideoById(_loc4_.fullPath.split("/").pop(),param2,param3);
      }
      
      public function getLoadedFraction() : Number
      {
         return this.videoPlayer.getLoadedFraction();
      }
      
      private function tinySeekIfPaused(param1:int) : void
      {
         param1 /= Math.abs(param1);
         var _loc2_:Number = this.videoPlayer.isTagStreaming() && this.videoPlayer.getPlayerState() is IPausedState && PlayerVersion.isAtLeastVersion(11,2) ? 1 / 20 : 3;
         this.seekVideo(this.videoPlayer.getTime() + param1 * _loc2_,true);
      }
      
      protected function addAdvertiserVideoCueRanges() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:TimeRange = null;
         var _loc4_:int = 0;
         if(this.videoData.isAdvertiserVideo && Boolean(this.cueRangeManager))
         {
            _loc1_ = this.videoData.duration * 1000;
            _loc2_ = 0;
            if(this.ytEnv.movePromotedVideoBillingTo5SecsExperiment)
            {
               _loc2_ = 5000;
            }
            if(this.ytEnv.movePromotedVideoBillingTo7SecsExperiment)
            {
               _loc2_ = 7000;
            }
            _loc3_ = new TimeRange(_loc2_,_loc1_);
            this.addAdvertiserVideoEventCueRange(VideoData.ADVERTISER_EVENT_IMPRESSION,_loc3_,this.onAdvertiserVideoCueRangeEvent);
            if(this.videoData.conversionConfig.socialEnabled)
            {
               _loc3_ = new TimeRange(100,_loc1_);
               this.addAdvertiserVideoEventCueRange(VideoData.ADVERTISER_VIDEO_VIEW,_loc3_,this.onAdvertiserVideoView);
            }
            _loc3_ = new TimeRange(_loc1_ * 0.25,_loc1_);
            this.addAdvertiserVideoEventCueRange(VideoData.ADVERTISER_EVENT_PROGRESS_25,_loc3_,this.onAdvertiserVideoCueRangeEvent);
            _loc3_ = new TimeRange(_loc1_ * 0.5,_loc1_);
            this.addAdvertiserVideoEventCueRange(VideoData.ADVERTISER_EVENT_PROGRESS_50,_loc3_,this.onAdvertiserVideoCueRangeEvent);
            _loc3_ = new TimeRange(_loc1_ * 0.75,_loc1_);
            this.addAdvertiserVideoEventCueRange(VideoData.ADVERTISER_EVENT_PROGRESS_75,_loc3_,this.onAdvertiserVideoCueRangeEvent);
            _loc3_ = new TimeRange(_loc1_,CueRange.AFTER_MEDIA_END);
            this.addAdvertiserVideoEventCueRange(VideoData.ADVERTISER_EVENT_COMPLETE,_loc3_,this.onAdvertiserVideoCueRangeEvent);
            this.addAdvertiserVideoEventCueRange(VideoData.ADVERTISER_EVENT_FOLLOW_ON_VIEW,_loc3_,this.onAdvertiserVideoCueRangeEvent);
            if(this.ytEnv.isPaidView)
            {
               _loc4_ = 0;
               if(this.ytEnv.isSkippableInStream)
               {
                  _loc4_ = Math.min(30 * 1000,_loc1_);
               }
               _loc3_ = new TimeRange(_loc4_,CueRange.AFTER_MEDIA_END);
               this.addAdvertiserVideoEventCueRange(VideoData.ADVERTISER_EVENT_ENGAGED_VIEW,_loc3_,this.onAdvertiserVideoCueRangeEvent);
            }
         }
      }
      
      public function getVideoFileByteOffset() : Number
      {
         return this.videoData.videoFileByteOffset;
      }
      
      override public function build() : void
      {
         if(!this.preloader && this.ytEnv.showPreloader)
         {
            this.preloader = new Preloader(stageAmbassador);
            this.preloader.enabled = this.ytEnv.interactivePreloader;
            this.preloader.addEventListener(Event.COMPLETE,function(param1:Event):void
            {
               setPreloaderVisibility(videoPlayer.getPlayerState() is IBufferingState);
            });
            this.preloaderReveal = new Tween(this.preloader);
         }
         this.seekSoftTimeout = Scheduler.setTimeout(FailureReport.LOAD_SOFT_TIMEOUT_MILLISECONDS,this.onSeekSoftTimeout);
         this.seekSoftTimeout.stop();
         this.background = new Sprite();
         if(this.ytEnv.hosted)
         {
            this.playerMask = new LayoutElement();
            this.playerMask.horizontalStretch = 1;
            this.playerMask.verticalStretch = 1;
            drawing(this.playerMask.graphics).fill(16711680).rect(0,0,1,1).end();
         }
         this.stopBlackout.horizontalStretch = 1;
         this.stopBlackout.verticalStretch = 1;
         this.stopBlackout.mouseEnabled = false;
         drawing(this.stopBlackout.graphics).fill(0,0.9).rect(0,0,1,1).end();
         this.layout.alignWith(this.viewportRect);
         this.layout.order(this.playerMask,this.background,IVideoPlayer,this.stopBlackout,VideoStill,this.preloader,IModule,LargePlayButton,"com.google.youtube.modules.ratings::RatingsModule",Watermark,"com.google.youtube.modules.multicamera::MultiCameraModule","com.google.youtube.modules.ypc::YpcModule","com.google.youtube.modules.ad::AdModule",VideoFaceplate);
         if(!this.videoStill)
         {
            this.videoStill = new VideoStill();
         }
         if(!this.largePlayButton && this.ytEnv.showLargePlayButton)
         {
            this.largePlayButton = new LargePlayButton(this.ytEnv.messages);
            this.largePlayButton.addEventListener(MouseEvent.CLICK,this.onLargePlayButtonClick);
         }
         if(!this.cueRangeManager)
         {
            this.cueRangeManager = new CueRangeManager(this.videoPlayer.getTime,this.videoPlayer.getPlayerState);
            this.cueRangeManager.addEventListener(CueRangeEvent.ADD,this.onCueRangeAdded);
            this.cueRangeManager.addEventListener(CueRangeEvent.REMOVE,this.onCueRangeRemoved);
            this.cueRangeManager.addEventListener(CueRangeEvent.CHANGE,this.onCueRangeChanged);
            this.cueRangeManager.addEventListener(CueRangeEvent.LOCK_BLOCK_ENTER,this.onCueRangeLockBlockEnter);
            this.cueRangeManager.addEventListener(CueRangeEvent.LOCK_BLOCK_EXIT,this.onCueRangeLockBlockExit);
         }
         if(!this.moduleHost)
         {
            this.moduleHost = new ModuleHost(this.videoPlayer,environment,this.cueRangeManager,this.uiEventDispatcher,this.videoDataDispatcher,stageAmbassador);
         }
         this.moduleHost.addEventListener(ModuleEvent.CHANGE,this.onModuleChange);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_ADD_CUERANGE,this.cueRangeManager.addCueRange);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_REMOVE_CUERANGE,this.cueRangeManager.removeCueRange);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_RELEASE_CUERANGE,this.cueRangeManager.releaseExclusiveLock);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_CUE,this.cueVideo);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_CUE_ID,this.cueVideoById);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_LOAD,this.loadVideo);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_LOAD_ID,this.loadVideoById);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_NAVIGATE_TO_URL,this.navigateToUrl);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_PAUSE,this.pauseVideo);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_PLAY,this.playVideo);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_LIKE_PLAYLIST_CLIP,this.likePlaylistClip);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_SELECT_PLAYLIST_CLIP,this.selectPlaylistClip);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_SHARE_PLAYLIST_CLIP,this.sharePlaylistClip);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_PREROLL_READY,this.onPrerollReady);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_RESET_LAYER,this.onModuleResetLayer);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_RESIZE,this.refreshReservedRect);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_SEEK,this.seekVideo);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_SET_LAYER,this.onModuleSetLayer);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_STOP,this.stopVideo);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_REMOVE_FACEPLATE,this.onVideoFaceplateEnd);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_MUTE,this.mute);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_UNMUTE,this.unMute);
         this.moduleHost.setCommandHandler(AdEvent.BREAK_START,this.onAdBreakStart);
         this.moduleHost.setCommandHandler(AdEvent.BREAK_END,this.onAdBreakEnd);
         this.moduleHost.setCommandHandler(AdEvent.PLAY,this.onAdPlay);
         this.moduleHost.setCommandHandler(AdEvent.PAUSE,this.onAdPause);
         this.moduleHost.setCommandHandler(AdEvent.END,this.onAdEnd);
         this.moduleHost.setCommandHandler(AdEvent.META_LOAD,this.onAdMetaData);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_LOG,this.onModuleLog);
         this.moduleHost.setCommandHandler(ModuleEvent.COMMAND_LOG_TIMING,this.onModuleLogTiming);
         if(!this.watermark && this.ytEnv.showLogo)
         {
            this.watermark = new Watermark(this.ytEnv.messages);
            this.watermark.addEventListener(MouseEvent.CLICK,this.onWatermarkClick);
         }
         if(this.ytEnv.autoPlay)
         {
            this.setAppState(new NotStartedAppState(this));
         }
         else
         {
            this.setAppState(new PendingUserInputAppState(this));
         }
         if(this.ytEnv.rawParameters.listType == "search" && this.ytEnv.autoPlay)
         {
            this.playlistCued = false;
            this.setAppState(new PendingUserInputAppState(this));
            this.ytEnv.playlist.addEventListener(Event.COMPLETE,this.onPlaylistComplete);
         }
         this.layerManager.setLayer("default",{
            "enableControls":true,
            "enableKeyboard":this.ytEnv.enableKeyboard
         });
      }
      
      protected function onAppStateChange(param1:AppStateChangeEvent) : void
      {
         if(this.state is PendingUserInputAppState && Boolean(this.videoPlayer))
         {
            this.setPreloaderVisibility(false);
            if(this.isSized)
            {
               this.setStillVisibility(true);
            }
            this.setPlayButtonVisibility(Boolean(this.videoData) && Boolean(this.videoData.videoId));
         }
         else if(this.state is PendingPrerollAppState)
         {
            this.setPreloaderVisibility(true);
            this.setStillVisibility(false);
            this.setPlayButtonVisibility(false);
            this.layerManager.setLayer("preroll",{"enableControls":false});
         }
         else if(this.state is StartedAppState)
         {
            this.layerManager.clearLayer("preroll");
            if(!this.apiEndScreenCueRange)
            {
               this.apiEndScreenCueRange = new CueRange(TimeRange.AFTER_MEDIA_END,null,END_SCREEN_CUERANGE_ID,CueRange.PRIORITY_END_SCREEN);
               this.apiEndScreenCueRange.addEventListener(CueRangeEvent.ENTER,this.onEndScreenEnter);
               this.apiEndScreenCueRange.addEventListener(CueRangeEvent.EXIT,this.onEndScreenExit);
               this.cueRangeManager.addCueRange(this.apiEndScreenCueRange);
            }
            if(!this.cueRangeManager.started)
            {
               this.cueRangeManager.startPlayback();
            }
            this.setPreloaderVisibility(false);
            this.setStillVisibility(false);
            this.setPlayButtonVisibility(false);
         }
         else if(!(this.state is UnbuiltAppState))
         {
            this.setPreloaderVisibility(false);
            this.setStillVisibility(false);
            this.setPlayButtonVisibility(false);
         }
      }
      
      protected function setExternalVideoProgress() : void
      {
         environment.broadcastExternal(new ExternalEvent(ExternalEvent.VIDEO_PROGRESS,this.getMediaTime()));
      }
      
      public function getPlaylistId() : String
      {
         return Boolean(this.ytEnv.playlist) && Boolean(this.ytEnv.playlist.listId) ? this.ytEnv.playlist.listId.toString() : null;
      }
      
      private function onAdvertiserVideoView(param1:CueRangeEvent) : void
      {
         if(!this.videoData.conversionConfig.socialEnabled)
         {
            return;
         }
         var _loc2_:Object = {
            "aid":this.videoData.conversionConfig.aid,
            "uid":this.videoData.conversionConfig.uid,
            "ad":false
         };
         if(this.ytEnv.isPaidView)
         {
            _loc2_.agcid = this.ytEnv.adSenseAdGroupCreativeId;
            _loc2_.ad = true;
         }
         this.ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.ADVERTISER_VIDEO_VIEW,_loc2_));
         this.cueRangeManager.removeCueRange(param1.cueRange);
      }
      
      protected function removePrebufferListeners() : void
      {
         this.prebufferVideoData.removeEventListener(GetVideoInfoEvent.INFO,this.prebufferWhenReady);
         this.prebufferVideoData.removeEventListener(ErrorEvent.ERROR,this.onPrebufferFailure);
      }
      
      protected function onKeyFocusChange(param1:FocusEvent) : void
      {
         var _loc4_:Boolean = false;
         if(!this.shouldHandleKeyCode(param1.keyCode))
         {
            return;
         }
         switch(param1.keyCode)
         {
            case Keyboard.DOWN:
            case Keyboard.END:
            case Keyboard.ENTER:
            case Keyboard.HOME:
            case Keyboard.LEFT:
            case Keyboard.RIGHT:
            case Keyboard.SPACE:
            case Keyboard.UP:
               param1.preventDefault();
               return;
            default:
               var _loc2_:int = param1.target ? InteractiveObject(param1.target).tabIndex : -1;
               var _loc3_:int = param1.relatedObject ? param1.relatedObject.tabIndex : -1;
               if(_loc3_ != -1 && _loc2_ != -1)
               {
                  _loc4_ = !param1.shiftKey ? _loc2_ > _loc3_ : _loc2_ < _loc3_;
                  if(_loc4_)
                  {
                     param1.preventDefault();
                     environment.broadcastExternal(new ExternalEvent(ExternalEvent.TAB_ORDER_CHANGE,param1.shiftKey));
                     stageAmbassador.focus = null;
                  }
               }
               return;
         }
      }
      
      public function addCueRange(param1:Object, param2:Number = NaN, param3:Number = NaN, param4:Number = NaN) : Boolean
      {
         var _loc5_:String = null;
         if(getQualifiedClassName(param1) == "Object")
         {
            if(!param1.id || isNaN(param1.start) || isNaN(param1.end))
            {
               return false;
            }
            _loc5_ = param1.id;
            param2 = Number(param1.start);
            param3 = Number(param1.end);
            if(param1.color != null)
            {
               param4 = Number(param1.color);
            }
         }
         else
         {
            if(!(param1 is String))
            {
               return false;
            }
            _loc5_ = String(param1);
         }
         if(isNaN(param2) || isNaN(param3) || _loc5_ in this.apiCueRanges)
         {
            return false;
         }
         var _loc6_:SeekBarMarker = null;
         if(!isNaN(param4) && this.ytEnv.isTrustedLoader)
         {
            _loc6_ = new SeekBarMarker(param2,param3,[param4,param4]);
         }
         var _loc7_:TimeRange = new TimeRange(param2 * 1000,param3 * 1000);
         var _loc8_:CueRange = new CueRange(_loc7_,_loc6_,_loc5_);
         _loc8_.addEventListener(CueRangeEvent.ENTER,this.onApiCueRangeEvent);
         _loc8_.addEventListener(CueRangeEvent.EXIT,this.onApiCueRangeEvent);
         this.cueRangeManager.addCueRange(_loc8_);
         this.apiCueRanges[_loc5_] = _loc8_;
         return true;
      }
      
      public function cueVideoByPlayerVars(param1:Object) : void
      {
         if(!param1.list)
         {
            this.ytEnv.playlist = null;
         }
         this.cueVideo(new VideoData(param1));
      }
      
      protected function initStreamingStats() : void
      {
         this.streamingStats = new StreamingStats(this.ytEnv);
      }
      
      protected function addAdvertiserVideoEventCueRange(param1:String, param2:TimeRange, param3:Function) : void
      {
         if(param1 in this.advertiserVideoCueRanges)
         {
            return;
         }
         var _loc4_:CueRange = new CueRange(param2,null,param1);
         _loc4_.addEventListener(CueRangeEvent.ENTER,param3);
         _loc4_.addEventListener(CueRangeEvent.EXIT,param3);
         this.cueRangeManager.addCueRange(_loc4_);
         this.advertiserVideoCueRanges[param1] = _loc4_;
      }
      
      protected function expireVideo(param1:SchedulerEvent) : void
      {
         this.videoPlayer.unrecoverableError(WatchMessages.ERROR_EXPIRED);
      }
      
      protected function sendConversionViewPing() : void
      {
         var _loc2_:RequestLoader = null;
         if(this.videoData.sentConversionViewPing)
         {
            return;
         }
         this.videoData.sentConversionViewPing = true;
         var _loc1_:URLRequest = this.ytEnv.getConversionPixelRequest(this.videoData,VideoData.CONVERSION_VIEW);
         if(_loc1_)
         {
            _loc2_ = new RequestLoader();
            _loc2_.sendRequest(_loc1_);
         }
      }
      
      protected function onAdBreakStart(param1:AdEvent) : void
      {
         var _loc2_:int = 0;
         this.videoPlayer.setIgnorePeggedToLive(true);
         this.ytEnv.messages.load(this.ytEnv.interfaceLanguage,this.ytEnv.watchXlbUrl);
         this.videoAdEventProvider = IVideoAdEventProvider(param1.target);
         if(!this.videoAdEventProvider.getHasAdUI())
         {
            if(this.videoFaceplate)
            {
               this.onVideoFaceplateEnd();
            }
            _loc2_ = 1;
            if(Boolean(param1.data) && Boolean(param1.data.slots))
            {
               _loc2_ = int(param1.data.slots);
            }
            this.videoFaceplate = new VideoFaceplate(this.ytEnv.messages,_loc2_,this.ytEnv.interfaceLanguage,this.ytEnv.plusOneInlineAnnotationExperiment);
            this.videoFaceplate.adString = this.ytEnv.messages.getMessage(WatchMessages.ADVERTISEMENT);
            this.videoFaceplate.addEventListener(Event.COMPLETE,this.onVideoFaceplateEnd);
            this.layout.add(this.videoFaceplate);
            this.videoFaceplate.show();
         }
         this.layout.remove(this.watermark);
         if(this.videoPlayer is IVideoAdAware)
         {
            IVideoAdAware(this.videoPlayer).onAdBreakStart();
         }
      }
      
      protected function getBackgroundColor() : Number
      {
         if(this.isFullScreen())
         {
            return 0;
         }
         if(!isNaN(this.videoData.backgroundColor))
         {
            return this.videoData.backgroundColor;
         }
         return this.ytEnv.backgroundColor;
      }
      
      public function loadVideoById(param1:Object, param2:Number = 0, param3:String = null) : void
      {
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         if(getQualifiedClassName(param1) == "Object")
         {
            if(!param1.videoId)
            {
               return;
            }
            _loc4_ = param1.videoId;
            param2 ||= Number(param1.startSeconds) || 0;
            _loc5_ = Number(param1.endSeconds);
            param3 = param1.suggestedQuality;
         }
         else
         {
            if(!(param1 is String))
            {
               return;
            }
            _loc4_ = String(param1);
         }
         this.prepareVideoById(_loc4_,param2,_loc5_,param3);
         this.playVideo(this.videoData);
      }
      
      public function isFullScreen() : Boolean
      {
         return stageAmbassador.isFullScreen();
      }
      
      public function scriptedLoadVideoByUrl(param1:Object, param2:Number = 0, param3:String = null) : void
      {
         var _loc4_:Url = null;
         if(getQualifiedClassName(param1) == "Object")
         {
            if(!param1.mediaContentUrl)
            {
               return;
            }
            _loc4_ = new Url(param1.mediaContentUrl);
            param2 ||= Number(param1.startSeconds) || 0;
            param3 = param1.suggestedQuality;
         }
         else
         {
            if(!(param1 is String))
            {
               return;
            }
            _loc4_ = new Url(String(param1));
         }
         this.ytEnv.applyGdataDevParams(_loc4_.queryVars);
         this.scriptedLoadVideoById(_loc4_.fullPath.split("/").pop(),param2,param3);
      }
      
      protected function onAdProgress(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this.videoAdEventProvider is IVideoAdEventProvider && Boolean(this.videoFaceplate))
         {
            _loc2_ = this.videoAdEventProvider.getAdDuration();
            _loc3_ = this.videoAdEventProvider.getAdTime();
            this.videoFaceplate.updateProgress(_loc3_,_loc2_);
         }
      }
      
      protected function shouldHandleKeyCode(param1:uint) : Boolean
      {
         return this.enableKeyboard || Boolean(this.keyboardExceptions[param1]);
      }
      
      protected function onCueRangeChanged(param1:CueRangeEvent) : void
      {
      }
      
      protected function onAdPause(param1:AdEvent) : void
      {
      }
      
      protected function getApiInterface() : Array
      {
         return this.ytEnv.getApiInterface();
      }
      
      protected function onAdPlay(param1:AdEvent) : void
      {
         this.isAdPlaying = true;
         this.videoStats.onAdPlay();
         if(this.videoFaceplate)
         {
            if(Boolean(param1.data) && Boolean(param1.data.closeable))
            {
               this.videoFaceplate.addEventListener(Event.CLOSE,this.onVideoFaceplateClose);
               this.videoFaceplate.showCloseButton(this.ytEnv.messages.getMessage(WatchMessages.RETURN_TO_VIDEO));
            }
            if(this.adProgressInterval)
            {
               this.adProgressInterval.restart();
            }
            else
            {
               this.adProgressInterval = Scheduler.setInterval(200,this.onAdProgress);
            }
            if(this.videoAdEventProvider)
            {
               this.videoFaceplate.videoId = this.videoAdEventProvider.getVideoId();
            }
         }
      }
      
      protected function onCueRangeAdded(param1:CueRangeEvent) : void
      {
      }
      
      protected function onModuleChange(param1:ModuleEvent) : void
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:ModuleDescriptor = null;
         if(IOverlayCapability in param1.module.capabilities)
         {
            _loc2_ = param1.module.instance as DisplayObject;
            if(param1.module.status == ModuleStatus.LOADED)
            {
               this.layout.add(_loc2_);
               this.resizeModule(this.viewportRect.clone(),this.viewportRect,param1.module);
               this.resizeModuleDisplay(this.videoPlayer.getDisplayRect(),param1.module);
            }
            else
            {
               this.layout.remove(_loc2_);
            }
         }
         if(IVideoFilterCapability in param1.module.capabilities)
         {
            _loc3_ = [];
            _loc4_ = this.moduleHost.getLoadedModulesByCapability(IVideoFilterCapability);
            for each(_loc5_ in _loc4_)
            {
               _loc3_ = _loc3_.concat(IVideoFilterCapability(_loc5_.instance).videoFilters);
            }
            DisplayObject(this.videoPlayer).filters = _loc3_;
         }
         if(param1.module.status == ModuleStatus.ERROR)
         {
            this.onPrerollReady(param1.module.uid);
         }
      }
      
      public function sendCardioHeartbeat(param1:Event = null) : void
      {
         var _loc2_:RequestVariables = new RequestVariables();
         _loc2_.tpmt = Math.floor(this.totalProgressMediaTime);
         if(this.lastProgressMediaTime != this.lastCardioMediaTime)
         {
            _loc2_.metric = CARDIO_HEARTBEAT_METRIC;
            this.loadCardioRequest(this.videoData,_loc2_);
            this.lastCardioMediaTime = this.lastProgressMediaTime;
         }
         else if(this.isAdPlaying)
         {
            _loc2_.metric = CARDIO_HEARTBEAT_AD_METRIC;
            this.loadCardioRequest(this.videoData,_loc2_);
         }
         else if(this.videoData.isSlateShowing)
         {
            _loc2_.metric = CARDIO_HEARTBEAT_SLATE_METRIC;
            this.loadCardioRequest(this.videoData,_loc2_);
         }
      }
      
      override public function handleError(param1:Error, param2:RequestVariables = null) : void
      {
         if(!param2)
         {
            param2 = new RequestVariables();
         }
         if(this.videoPlayer && this.videoData && Boolean(this.videoData.videoId))
         {
            param2.v = this.videoData.videoId;
         }
         this.ytEnv.handleError(param1,param2);
      }
      
      protected function setPlayButtonVisibility(param1:Boolean) : void
      {
         if(param1)
         {
            this.layout.add(this.largePlayButton);
         }
         else
         {
            this.layout.remove(this.largePlayButton);
         }
      }
      
      protected function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Sprite = null;
         if(!this.shouldHandleKeyEvent(param1))
         {
            return;
         }
         if(param1.keyCode == 17)
         {
            this.layerManager.setLayer("commandKey",{"enableKeyboard":false});
            return;
         }
         if(param1.keyCode >= 48 && param1.keyCode <= 57)
         {
            _loc2_ = this.videoPlayer.getDuration() / 10;
            this.seekVideo(_loc2_ * (param1.keyCode - 48),true);
            return;
         }
         switch(param1.keyCode)
         {
            case 32:
               _loc3_ = stageAmbassador.focus as Sprite;
               if(!_loc3_ || !_loc3_.buttonMode)
               {
                  this.togglePause();
               }
               break;
            case 179:
            case 75:
               this.togglePause();
               break;
            case 178:
               this.pauseVideo();
               break;
            case 37:
            case 74:
               this.tinySeekIfPaused(-1);
               break;
            case 38:
               this.setVolume(this.getVolume() + 5);
               break;
            case 39:
            case 76:
               this.tinySeekIfPaused(1);
               break;
            case 40:
               this.setVolume(this.getVolume() - 5);
               break;
            case 36:
               this.seekVideo(0,true);
               break;
            case 35:
               this.seekVideo(this.videoPlayer.getDuration(),true);
               break;
            case 70:
               this.toggleFullScreen();
               break;
            case 77:
               if(this.isMuted())
               {
                  this.unMute();
                  break;
               }
               this.mute();
               break;
            default:
               this.uiEventDispatcher.dispatchEvent(param1);
         }
      }
      
      protected function onAfterMediaEnd() : void
      {
         var _loc2_:VideoData = null;
         var _loc1_:Boolean = this.ytEnv.eventLabel == EventLabel.EMBEDDED || this.ytEnv.eventLabel == EventLabel.POPOUT;
         if(this.ytEnv.willAutoplay && (this.isFullScreen() || _loc1_))
         {
            _loc2_ = this.ytEnv.playlist.getNext();
            _loc2_.autoPlay = true;
            this.loadVideo(_loc2_);
         }
         else
         {
            this.setExternalState(ExternalPlayerState.ENDED);
         }
      }
      
      public function get videoData() : VideoData
      {
         return this.videoPlayer.getVideoData();
      }
      
      protected function sendCardioConnected() : void
      {
         var _loc1_:RequestVariables = new RequestVariables();
         _loc1_.metric = CARDIO_CONNECTED_METRIC;
         this.loadCardioRequest(this.videoData,_loc1_);
      }
      
      protected function onModuleResetLayer(param1:String) : void
      {
         this.layerManager.clearLayer(param1);
      }
      
      protected function sendCardioError(param1:String) : void
      {
         var _loc2_:String = CARDIO_ERROR_METRIC_FORMAT.replace("{ec}",param1);
         var _loc3_:RequestVariables = new RequestVariables();
         _loc3_.metric = _loc2_;
         this.loadCardioRequest(this.videoData,_loc3_);
      }
      
      protected function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 17)
         {
            this.layerManager.clearLayer("commandKey");
         }
      }
      
      protected function resizePlayer(param1:Number, param2:Number) : void
      {
         var _loc7_:Drawing = null;
         var _loc3_:Boolean = this.videoPlayer.needsCorrectAspect();
         var _loc4_:Array = this.moduleHost.getLoadedModulesByCapability(IStageScaleCapability);
         if(_loc4_.length > 0)
         {
            _loc3_ = IStageScaleCapability(_loc4_[0].instance).needsCorrectAspect;
         }
         this.videoPlayer.resize(param1,param2,_loc3_);
         var _loc5_:Rectangle = this.videoPlayer.getDisplayRect();
         var _loc6_:int = this.getBackgroundColor();
         if((Boolean(_loc6_)) || this.ytEnv.hosted)
         {
            _loc7_ = drawing(this.background.graphics).clear().fill(_loc6_).rect(0,0,param1,param2);
            if(!this.ytEnv.hosted)
            {
               _loc7_.rect(_loc5_.right,_loc5_.bottom,-_loc5_.width,-_loc5_.height);
            }
            _loc7_.end();
         }
         if(this.playerMask)
         {
            if(_loc5_.x < 0 || _loc5_.y < 0)
            {
               this.layout.add(this.playerMask);
               DisplayObject(this.videoPlayer).mask = this.playerMask;
            }
            else
            {
               this.layout.remove(this.playerMask);
               DisplayObject(this.videoPlayer).mask = null;
            }
         }
         this.resizeAllModuleDisplays(_loc5_,this.moduleHost);
      }
      
      public function loadPlaylist(param1:Object, param2:int = 0, param3:Number = 0, param4:String = null) : void
      {
         this.playlistCued = false;
         this.preparePlaylist(param1,param2,param3,param4);
      }
      
      protected function onTabEnabledChange(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc2_:UIElement = param1.target as UIElement;
         if(_loc2_)
         {
            _loc3_ = int(this.tabbableElements.indexOf(_loc2_));
            if(_loc2_.tabEnabled && _loc2_.parent && _loc3_ == -1)
            {
               this.addToTabOrder(_loc2_);
            }
            else if(_loc3_ != -1)
            {
               this.removeFromTabOrder(_loc2_,_loc3_);
            }
         }
      }
      
      protected function seekVideo(param1:Number, param2:Boolean) : void
      {
         if(!this.videoData.isSeekEnabled(param1))
         {
            return;
         }
         if(this.videoData.isLive && this.videoData.format.isHls && Boolean(this.videoData.format.hlsPlaylist.liveChunkTime))
         {
            param1 = Math.min(param1,this.videoData.format.hlsPlaylist.liveChunkTime);
         }
         this.setAppState(this.state.seekVideo());
         if(!(this.state is IBlockingAppState))
         {
            this.formatSelector.onSeek();
            this.videoPlayer.seek(param1,param2);
         }
      }
      
      protected function getAvailablePlaybackRates() : Array
      {
         return this.videoPlayer.availablePlaybackRates;
      }
      
      protected function logUserWatch(param1:VideoData, param2:RequestVariables) : URLRequest
      {
         var _loc3_:URLRequest = this.ytEnv.getUserWatchRequest(param1,param2);
         var _loc4_:RequestLoader = new RequestLoader();
         _loc4_.loadRequest(_loc3_);
         return _loc3_;
      }
      
      override public function initData() : void
      {
         var _loc1_:Object = environment.getLoggingOptions();
         this.initVideoStats(_loc1_);
         if(this.ytEnv.reportStreamingStats)
         {
            this.initStreamingStats();
         }
         this.layout = new Layout(this);
         this.layerManager.registerHandlers({
            "enableControls":this.setEnableControls,
            "enableKeyboard":this.setEnableKeyboard
         });
         Tooltip.reference = this;
         this.sharedSoundData = new SharedSoundData(this.ytEnv.showControls);
         if(!this.videoPlayer)
         {
            this.addVideoPlayer(this.ytEnv.initialVideoData);
         }
         this.ytEnv.initialVideoData = null;
         super.initData();
      }
      
      public function updatePlayerAudio() : void
      {
         var _loc1_:Number = NaN;
         _loc1_ = this.videoData.infringe ? 0 : this.sharedSoundData.getVolume();
         this.videoPlayer.setVolume(_loc1_);
         var _loc2_:Object = {
            "muted":this.isMuted(),
            "volume":this.getVolume()
         };
         this.ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.VOLUME_CHANGE,_loc2_));
      }
      
      protected function onPrerollCueRangeEnter(param1:CueRangeEvent) : void
      {
         this.cueRangeManager.removeCueRange(this.prerollCueRange);
         this.initiatePlayback();
         this.cueRangeManager.releaseExclusiveLock(PREROLL_CUERANGE_ID);
      }
      
      public function setPlaybackFormat(param1:VideoFormat) : void
      {
         var _loc2_:* = false;
         var _loc3_:Number = NaN;
         if(!param1 || param1.equals(this.videoData.format))
         {
            return;
         }
         if(!(this.videoPlayer.getPlayerState() is NotStartedState || this.state is IBlockingAppState || this.state is NotStartedAppState))
         {
            _loc2_ = this.videoPlayer.getPlayerState() is IPausedState;
            _loc3_ = this.videoPlayer.getTime();
            this.videoData.startSeconds = _loc3_;
            this.videoData.format = param1;
            if(!this.isAdPlaying)
            {
               this.videoPlayer.splice(this.videoData);
               if(_loc2_)
               {
                  this.videoPlayer.pause();
               }
            }
         }
      }
      
      protected function onPlaylistOrderChanged(param1:Event) : void
      {
      }
      
      protected function loadModule(param1:Class, param2:String) : ModuleDescriptor
      {
         if(!param2)
         {
            return null;
         }
         if(this.moduleHost.getModulesByType(param1).length)
         {
            return null;
         }
         var _loc3_:ModuleDescriptor = new param1(this.ytEnv.messages);
         _loc3_.url = param2;
         this.moduleHost.register(_loc3_);
         if(_loc3_.shouldLoad(this.ytEnv,this.videoData))
         {
            this.moduleHost.load(_loc3_);
         }
         else
         {
            this.onPrerollReady(_loc3_.uid);
         }
         if(!this.videoData.requiresPlayerSizeValidation || !this.ytEnv.showYouTubeEmbedBranding || _loc3_.hasRequiredSize(this.viewportRect))
         {
            this.onPrerollReady(_loc3_.uid + ModuleDescriptor.VALIDATE_SIZE_PREROLL);
         }
         else
         {
            this.displayApplicationError(WatchMessages.ERROR_TOO_SMALL,150);
         }
         return _loc3_;
      }
      
      protected function onLog(param1:LogEvent) : void
      {
         var _loc2_:RequestVariables = param1.args || new RequestVariables();
         _loc2_.event = param1.message;
         if(_loc2_.event == FailureReport.EVENT_MESSAGE)
         {
            this.errorReportCount += 1;
            _loc2_.erc = this.errorReportCount;
            if(this.videoStats.sentInitialPing)
            {
               _loc2_.vsp = 1;
            }
         }
         if(this.videoData.payPerStream)
         {
            _loc2_.pps = 1;
         }
         if(this.videoData.netConnectionClosedEventCount > 0)
         {
            _loc2_.ncc = this.videoPlayer.getVideoData().netConnectionClosedEventCount;
         }
         if(this.playbackStartTime >= 0)
         {
            _loc2_.rt = ((getTimer() - this.playbackStartTime) / 1000).toFixed(3);
         }
         if(Boolean(this.videoData.format) && Boolean(this.videoData.format.name))
         {
            _loc2_.fmt = this.videoData.format.name;
         }
         if("ec" in _loc2_)
         {
            _loc2_.shost = this.ytEnv.getSourceHost(this.videoData);
         }
         var _loc3_:URLRequest = this.ytEnv.getLoggingRequest(this.videoData,_loc2_);
         var _loc4_:RequestLoader = new RequestLoader();
         _loc4_.loadRequest(_loc3_);
         if(this.videoData.enableCardioRealtimeAnalytics && "ec" in _loc2_ && FailureReport.isCardioSupportedError(_loc2_.ec))
         {
            this.sendCardioError(_loc2_.ec);
         }
         if("ec" in _loc2_ && Boolean(this.streamingStats))
         {
            this.streamingStats.onStreamingError(_loc2_.ec);
         }
      }
      
      protected function onUnhandledError(param1:*) : void
      {
         this.handleError(param1.error);
      }
      
      protected function onVideoDataChange(param1:VideoDataEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:IPlayerState = null;
         var _loc4_:FormatSelectionRecord = null;
         var _loc5_:RequestVariables = null;
         if(param1.source == VideoDataEvent.FORMAT_DISABLED && !this.videoData.isFormatAllowedToPlay(this.videoData.format))
         {
            this.setPlaybackFormat(this.formatSelector.getVideoFormat(FormatSelectionRecord.INITIAL,null,this.videoData));
         }
         if(param1.source == VideoDataEvent.VIDEO_INFO || param1.source == VideoDataEvent.FORMAT_CHANGE)
         {
            if(this.videoData.isTransportRtmp() && !this.videoData.isAlwaysBuffered() || (this.videoPlayer as Object).constructor != PlayerFactory.getPlayerClass(this.videoData,this.ytEnv))
            {
               _loc3_ = this.videoPlayer.getPlayerState();
               this.addVideoPlayer(this.videoData);
               if(!(_loc3_ is NotStartedState) && !(this.state is PendingExclusiveLockAppState))
               {
                  this.playVideo();
                  if(_loc3_ is IPausedState)
                  {
                     this.pauseVideo();
                  }
               }
            }
            if(this.cardioHeartbeatScheduler)
            {
               if(this.videoData.enableCardioRealtimeAnalytics && (this.videoData.sentCardioPlayback || this.videoData.enableCardioBeforePlayback))
               {
                  this.cardioHeartbeatScheduler.restart();
               }
               else
               {
                  this.cardioHeartbeatScheduler.stop();
               }
            }
         }
         if(param1.source == VideoDataEvent.FORMAT_CHANGE)
         {
            environment.broadcastExternal(new ExternalEvent(ExternalEvent.QUALITY_CHANGE,this.videoData.format.quality.toString()));
            if(this.streamingStats)
            {
               _loc4_ = this.formatSelector.getSelectionRecordForFormat(this.videoData.format);
               if(_loc4_)
               {
                  if(_loc4_.trigger == FormatSelectionRecord.INITIAL || _loc4_.trigger == FormatSelectionRecord.MANUAL)
                  {
                     _loc4_.switchTime = this.getElapsedTime();
                     this.streamingStats.onVideoFormatChange(_loc4_);
                  }
                  else
                  {
                     this.nowSplicing[this.videoData.format.name] = _loc4_;
                  }
               }
            }
         }
         if(this.watermark)
         {
            this.watermark.enabled = this.videoData.isPartnerWatermark || this.ytEnv.isEmbedded && !this.ytEnv.showYouTubeButton && !this.ytEnv.showYouTubeTitleTip;
            if(this.ytEnv.onSite && !this.videoData.isPartnerWatermark)
            {
               this.watermark.clearWatermark();
            }
            else if(this.videoData.watermarkHd && this.videoData.isHd && this.watermark.enabled)
            {
               this.watermark.setWatermark(this.videoData.watermarkHd);
            }
            else if(this.ytEnv.showDefaultYouTubeWatermark && !this.videoData.isPartnerWatermark && !this.ytEnv.showYouTubeButton && !this.ytEnv.showYouTubeTitleTip)
            {
               this.watermark.setWatermark(DefaultWatermark);
            }
            else if(Boolean(this.videoData.watermark) && this.watermark.enabled)
            {
               this.watermark.setWatermark(this.videoData.watermark);
            }
            else
            {
               this.watermark.clearWatermark();
            }
         }
         this.setAppState(this.state.onVideoDataChange(param1));
         this.currentProgressWallTime = 0;
         this.currentProgressMediaTime = 0;
         this.lastProgressWallTime = 0;
         this.lastProgressMediaTime = 0;
         this.playbackDelay = 0;
         if(param1.source == VideoDataEvent.NEW_VIDEO_DATA)
         {
            this.totalProgressMediaTime = 0;
            this.errorReportCount = 0;
            if(this.cardioHeartbeatScheduler)
            {
               if(this.videoData.enableCardioRealtimeAnalytics)
               {
                  this.sendCardioConnected();
                  if(this.videoData.enableCardioBeforePlayback)
                  {
                     this.cardioHeartbeatScheduler.restart();
                  }
               }
               else
               {
                  this.cardioHeartbeatScheduler.stop();
               }
            }
         }
         this.resizeApplication(this.nominalWidth,this.nominalHeight);
         if(param1.source == VideoDataEvent.METADATA && this.videoStats.sentInitialPing && this.videoData.enableRealtimeLogging && Boolean(this.videoData.sourceData))
         {
            _loc5_ = new RequestVariables();
            _loc5_.sd = this.videoData.sourceData;
            this.onLog(new LogEvent(LogEvent.LOG,"streaming",_loc5_));
         }
         this.videoDataDispatcher.dispatchEvent(param1);
         if(param1.source == VideoDataEvent.VIDEO_INFO && !(this.state is IBlockingAppState))
         {
            this.initiatePlayback();
         }
         this.addAdvertiserVideoCueRanges();
         environment.broadcastExternal(new ExternalEvent(ExternalEvent.VIDEO_CHANGE));
         if(this.ytEnv.moreAudioNormalizationExperiment && this.videoData.perceptualLoudnessDb > -20 && this.videoData.perceptualLoudnessDb < 0)
         {
            _loc2_ = -20 - this.videoData.perceptualLoudnessDb;
            this.videoData.muffleFactor = Math.pow(10,_loc2_ / 20);
         }
         else if(this.videoData.perceptualLoudnessDb < -23)
         {
            _loc2_ = Math.min(-23 - this.videoData.perceptualLoudnessDb,10);
            this.videoData.muffleFactor = Math.pow(10,_loc2_ / 20);
         }
         this.updatePlayerAudio();
      }
      
      protected function togglePause() : void
      {
         if(this.videoPlayer.getPlayerState() is IPausedState)
         {
            this.playVideo();
         }
         else
         {
            this.pauseVideo();
         }
      }
      
      protected function allowsLateFullScreenSourceRect() : Boolean
      {
         return this.supportsFullScreenSourceRect() && PlayerVersion.isAtLeastVersion(10,1,0) && this.ytEnv.fullScreenSourceRectExperiment;
      }
      
      protected function onVideoClick(param1:MouseEvent) : void
      {
      }
      
      override public function init() : void
      {
         if(!environment)
         {
            environment = new YouTubeEnvironment(context,EventLabel.EMBEDDED,PlayerStyle.CHROMELESS);
         }
         registerErrorHandler(loaderInfo,this.onUnhandledError);
         SafeLoader.uncaughtErrorEventHandler = this.onUnhandledError;
         Scheduler.composeClockHandler(guardedCall);
         this.ytEnv = YouTubeEnvironment(environment);
         FormatSelector.CONSIDER_720_LOWDEF = this.ytEnv.consider720LowDef;
         FormatSelector.NO_SPECIAL_TREATMENT_240P = this.ytEnv.noSpecialTreatment240p;
         this.formatSelector = new FormatSelector(this,this.ytEnv);
         StageAmbassador.hosted = this.ytEnv.hosted;
         this.focusManager = new EventRouter(this);
         if(!stageAmbassador)
         {
            stageAmbassador = new StageAmbassador(this);
         }
         if(!this.ytEnv.hosted)
         {
            this.accessibilityUpdateTimeout = Scheduler.setTimeout(ACCESSIBILITY_UPDATE_DELAY_MS,this.updateAccessibilityProperties);
            addEventListener(AccessibilityPropertiesEvent.UPDATE,this.onAccessibilityPropertiesUpdate);
            addEventListener(Event.TAB_ENABLED_CHANGE,this.onTabEnabledChange);
            stageAmbassador.align = StageAlign.TOP_LEFT;
            stageAmbassador.scaleMode = StageScaleMode.NO_SCALE;
         }
         if(this.ytEnv.playlist)
         {
            this.ytEnv.playlist.addEventListener(Event.COMPLETE,this.onPlaylistComplete);
            this.ytEnv.playlist.addEventListener(ShuffleEvent.CHANGE,this.onPlaylistOrderChanged);
         }
         super.init();
         stageAmbassador.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreenEvent);
         if(!this.ytEnv.hosted)
         {
            stageAmbassador.addEventListener(Event.RESIZE,this.onResize);
         }
         if(this.ytEnv.enableKeyboard)
         {
            stageAmbassador.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
            stageAmbassador.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
            stageAmbassador.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChange);
         }
      }
      
      protected function onAdEnd(param1:AdEvent) : void
      {
         this.isAdPlaying = false;
         this.videoStats.onAdEnd();
         if(this.videoFaceplate)
         {
            this.videoFaceplate.incrementCurrentAdSlot();
            this.videoFaceplate.resetProgress();
            this.videoFaceplate.hideCloseButton();
            this.videoFaceplate.removeEventListener(Event.CLOSE,this.onVideoFaceplateClose);
         }
         if(this.adProgressInterval)
         {
            this.adProgressInterval.stop();
         }
      }
      
      public function getBytesLoaded() : Number
      {
         return this.videoPlayer.getBytesLoaded();
      }
      
      protected function setPlaybackRate(param1:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc2_:Number = 1;
         if(param1 < 1)
         {
            for each(_loc3_ in this.videoPlayer.availablePlaybackRates)
            {
               _loc2_ = _loc3_;
               if(param1 <= _loc2_)
               {
                  break;
               }
            }
         }
         else
         {
            _loc4_ = int(this.videoPlayer.availablePlaybackRates.length - 1);
            while(_loc4_ >= 0)
            {
               _loc2_ = Number(this.videoPlayer.availablePlaybackRates[_loc4_]);
               if(param1 >= _loc2_)
               {
                  break;
               }
               _loc4_--;
            }
         }
         this.videoPlayer.playbackRate = _loc2_;
      }
      
      protected function onCueRangeLockBlockExit(param1:CueRangeEvent) : void
      {
         var _loc2_:* = !(this.state is PendingExclusiveLockPausedAppState);
         this.setAppState(this.state.onCueRangeLockBlockExit(param1));
         if(_loc2_)
         {
            this.playVideo(this.videoPlayer.getPlayerState() is NotStartedState ? this.videoData : null);
         }
         else if(this.videoPlayer.getPlayerState() is IEndedState)
         {
            this.videoPlayer.end();
         }
      }
      
      public function cuePlaylist(param1:Object, param2:int = 0, param3:Number = 0, param4:String = null) : void
      {
         this.playlistCued = true;
         this.preparePlaylist(param1,param2,param3,param4);
      }
      
      protected function prebufferWhenReady(param1:Event = null) : void
      {
         this.removePrebufferListeners();
         this.prebufferVideoData.format = this.formatSelector.getVideoFormat(FormatSelectionRecord.INITIAL,null,this.prebufferVideoData,true);
         TagStreamPlayer.prebuffer(this.prebufferVideoData,this.ytEnv);
      }
      
      protected function removeFromTabOrder(param1:UIElement, param2:int) : void
      {
         this.tabbableElements.splice(param2,1);
         param1.tabIndex = -1;
         this.updateAccessibilityProperties();
      }
      
      protected function tryPrebuffer() : void
      {
         var _loc3_:URLRequest = null;
         var _loc1_:Playlist = this.ytEnv.playlist;
         var _loc2_:Boolean = (this.ytEnv.isEmbedded || this.isFullScreen()) && Boolean(_loc1_) && _loc1_.hasNext();
         if(_loc2_ && !TagStreamPlayer.hasPrebuffered(this.videoData))
         {
            this.prebufferVideoData = _loc1_.getVideo(_loc1_.index + 1);
            if(this.prebufferVideoData.isDataReady())
            {
               this.prebufferWhenReady();
            }
            else
            {
               _loc3_ = this.ytEnv.getVideoInfoRequest(this.prebufferVideoData);
               this.prebufferVideoData.addEventListener(GetVideoInfoEvent.INFO,this.prebufferWhenReady);
               this.prebufferVideoData.addEventListener(ErrorEvent.ERROR,this.onPrebufferFailure);
               this.prebufferVideoData.getVideoInfo(_loc3_);
            }
         }
      }
      
      protected function handleFullScreenSourceRect() : void
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc1_:VideoFormat = this.videoData.getFormatForRect(new Rectangle(0,0,Capabilities.screenResolutionX,Capabilities.screenResolutionY));
         var _loc2_:Number = _loc1_.size.width;
         var _loc3_:Number = _loc1_.size.height;
         var _loc4_:Number = Math.max(854,_loc2_);
         var _loc5_:Number = Math.max(480,_loc3_);
         var _loc6_:Boolean = false;
         var _loc7_:Array = this.moduleHost.getLoadedModulesByCapability(IStageScaleCapability);
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_.length)
         {
            if(IStageScaleCapability(_loc7_[_loc8_].instance).needsIdentityScale)
            {
               _loc6_ = true;
               break;
            }
            _loc8_++;
         }
         if(!this.supportsFullScreenSourceRect())
         {
            return;
         }
         var _loc9_:Rectangle = null;
         if(Capabilities.screenResolutionY > _loc5_ && Capabilities.screenResolutionX > _loc4_ && !_loc6_ && !this.videoPlayer.isStageVideoAvailable())
         {
            _loc10_ = Capabilities.screenResolutionX / Capabilities.screenResolutionY;
            if(_loc10_ > 0.1 && _loc10_ < 3)
            {
               _loc11_ = _loc4_ / _loc5_;
               if(_loc11_ < _loc10_)
               {
                  _loc4_ = _loc5_ * _loc10_;
               }
               else
               {
                  _loc5_ = _loc4_ / _loc10_;
               }
            }
            _loc9_ = new Rectangle(0,0,_loc4_,_loc5_);
         }
         if(Boolean(stageAmbassador.fullScreenSourceRect) != Boolean(_loc9_) || stageAmbassador.fullScreenSourceRect && _loc9_ && (stageAmbassador.fullScreenSourceRect.width != _loc4_ || stageAmbassador.fullScreenSourceRect.height != _loc5_))
         {
            stageAmbassador.fullScreenSourceRect = _loc9_;
         }
      }
      
      protected function addCallbacks() : void
      {
         try
         {
            environment.addCallback("clearVideo",this.clearVideo);
            environment.addCallback("destroy",this.stopVideo);
            environment.addCallback("cuePlaylist",this.cuePlaylist);
            environment.addCallback("cueVideoById",this.cueVideoById);
            environment.addCallback("cueVideoByUrl",this.cueVideoByUrl);
            environment.addCallback("getApiInterface",this.getApiInterface);
            environment.addCallback("getAvailableQualityLevels",this.getAvailableQualityLevelStrings);
            environment.addCallback("getCurrentTime",this.getMediaTime);
            environment.addCallback("getDuration",this.getMediaDuration);
            environment.addCallback("getOption",this.moduleHost.callOption);
            environment.addCallback("getOptions",this.moduleHost.getOptions);
            environment.addCallback("getPlaybackQuality",this.getPlaybackQualityString);
            environment.addCallback("getPlayerState",this.getExternalState);
            environment.addCallback("getPlaylist",this.getPlaylist);
            environment.addCallback("getPlaylistId",this.getPlaylistId);
            environment.addCallback("getPlaylistIndex",this.getPlaylistIndex);
            environment.addCallback("getVideoBytesLoaded",this.getBytesLoaded);
            environment.addCallback("getVideoBytesTotal",this.getBytesTotal);
            environment.addCallback("getVideoLoadedFraction",this.getLoadedFraction);
            environment.addCallback("getVideoEmbedCode",this.getVideoEmbedCode);
            environment.addCallback("getVideoStartBytes",this.getVideoFileByteOffset);
            environment.addCallback("getVideoUrl",this.getVideoWatchUrl);
            environment.addCallback("getVolume",this.getVolume);
            environment.addCallback("isMuted",this.isMuted);
            environment.addCallback("loadPlaylist",this.loadPlaylist);
            environment.addCallback("loadModule",this.scriptedLoadModule);
            environment.addCallback("loadVideoById",this.scriptedLoadVideoById);
            environment.addCallback("loadVideoByUrl",this.scriptedLoadVideoByUrl);
            environment.addCallback("mute",this.mute);
            environment.addCallback("nextVideo",this.nextVideo);
            environment.addCallback("pauseVideo",this.pauseVideo);
            environment.addCallback("playVideo",this.scriptedPlayVideo);
            environment.addCallback("playVideoAt",this.playVideoAt);
            environment.addCallback("previousVideo",this.previousVideo);
            environment.addCallback("seekTo",this.scriptedSeekVideo);
            environment.addCallback("setLoop",this.setLoop);
            environment.addCallback("setOption",this.moduleHost.callOption);
            environment.addCallback("setPlaybackQuality",this.setPlaybackQualityString);
            environment.addCallback("setShuffle",this.setShuffle);
            environment.addCallback("setSize",this.scriptedSetSize);
            environment.addCallback("setVolume",this.setVolume);
            environment.addCallback("stopVideo",this.stopVideo);
            environment.addCallback("unMute",this.unMute);
            environment.addCallback("addCueRange",this.addCueRange);
            environment.addCallback("removeCueRange",this.removeCueRange);
            environment.addCallback("getDebugText",this.scriptedGetDebugText);
            environment.addCallback("unloadModule",this.scriptedUnloadModule);
            environment.addCallback("setPlaybackRate",this.setPlaybackRate);
            environment.addCallback("getPlaybackRate",this.getPlaybackRate);
            environment.addCallback("getAvailablePlaybackRates",this.getAvailablePlaybackRates);
            if(this.ytEnv.hosted)
            {
               environment.addCallback("getClickToPlayButton",this.getClickToPlayButton);
            }
            if(this.ytEnv.isTrustedLoader)
            {
               environment.addCallback("getVideoData",this.getVideoData);
               environment.addCallback("cueVideoByFlashvars",this.cueVideoByPlayerVars);
               environment.addCallback("loadVideoByFlashvars",this.loadVideoByPlayerVars);
               environment.addCallback("cueVideoByPlayerVars",this.cueVideoByPlayerVars);
               environment.addCallback("loadVideoByPlayerVars",this.loadVideoByPlayerVars);
               environment.addCallback("onPrerollReady",this.onPrerollReady);
            }
            if(this.ytEnv.isAdPlayback)
            {
               environment.addCallback("cueVideoByThirdPartyFlvUrl",this.cueVideoByThirdPartyFlvUrl);
               environment.addCallback("cueVideoByConnAndStream",this.cueVideoByConnAndStream);
            }
         }
         catch(error:SecurityError)
         {
         }
      }
      
      public function getVideoEmbedCode() : String
      {
         return this.videoPlayer.videoUrlProvider.getVideoEmbedCode(this.videoData);
      }
      
      protected function onPlaylistComplete(param1:Event = null) : void
      {
         var _loc2_:Playlist = this.ytEnv.playlist;
         _loc2_.removeEventListener(Event.COMPLETE,this.onPlaylistComplete);
         var _loc3_:VideoData = _loc2_.getVideo();
         if(!_loc3_)
         {
            _loc2_.index = 0;
            _loc3_ = _loc2_.getVideo();
            if(!_loc3_)
            {
               return;
            }
         }
         _loc3_.startSeconds = _loc3_.startSeconds || _loc2_.startSeconds;
         if(this.videoPlayer.getPlayerState() is NotStartedState)
         {
            if(this.playlistCued)
            {
               this.cueVideo(_loc3_);
            }
            else
            {
               this.loadVideo(_loc3_);
            }
         }
         else if(this.videoPlayer.getPlayerState() is ErrorState)
         {
            this.autoAdvanceOnError();
         }
      }
      
      public function getElapsedTime() : Number
      {
         return this.playbackStartTime != -1 ? (getTimer() - this.playbackStartTime) / 1000 : 0;
      }
      
      public function scriptedGetDebugText() : String
      {
         return this.getDebugText();
      }
      
      protected function onVideoFaceplateEnd(param1:Event = null) : void
      {
         if(this.videoFaceplate)
         {
            this.videoFaceplate.removeEventListener(Event.COMPLETE,this.onVideoFaceplateEnd);
            this.layout.remove(this.videoFaceplate);
            this.videoFaceplate = null;
         }
      }
      
      protected function onAdvertiserVideoCueRangeEvent(param1:CueRangeEvent) : void
      {
         var _loc2_:String = param1.cueRange.id;
         var _loc3_:RequestLoader = new RequestLoader();
         var _loc4_:Boolean = true;
         switch(_loc2_)
         {
            case VideoData.ADVERTISER_EVENT_IMPRESSION:
               this.conditionallySendRequest(_loc3_,this.ytEnv.getPromotedVideoBillingRequest(this.videoData));
               this.conditionallySendRequest(_loc3_,this.videoData.getPromotedVideoBeaconRequest(_loc2_));
               break;
            case VideoData.ADVERTISER_EVENT_PROGRESS_25:
            case VideoData.ADVERTISER_EVENT_PROGRESS_50:
            case VideoData.ADVERTISER_EVENT_PROGRESS_75:
               this.videoStats.sendReport();
            case VideoData.ADVERTISER_EVENT_COMPLETE:
               this.conditionallySendRequest(_loc3_,this.videoData.getPromotedVideoBeaconRequest(_loc2_));
               this.conditionallySendRequest(_loc3_,this.ytEnv.getWatchTimePixelRequest(this.videoData,_loc2_));
               ++this.videoData.numberOfWatchTimePingsSent;
               break;
            case VideoData.ADVERTISER_EVENT_FOLLOW_ON_VIEW:
               this.sendConversionViewPing();
               _loc4_ = false;
               break;
            case VideoData.ADVERTISER_EVENT_ENGAGED_VIEW:
               this.conditionallySendRequest(_loc3_,this.ytEnv.getConversionAdViewPixelRequest(this.videoData));
               _loc4_ = false;
         }
         if(_loc4_)
         {
            this.conditionallySendRequest(_loc3_,this.ytEnv.getPromotedVideoTrackingRequest(this.videoData,_loc2_));
         }
         this.cueRangeManager.removeCueRange(param1.cueRange);
      }
      
      public function loadVideo(param1:VideoData) : void
      {
         this.prepareVideo(param1);
         this.ytEnv.resetCsi();
         this.playVideo(this.videoData);
      }
      
      public function onEndScreenExit(param1:CueRangeEvent) : void
      {
      }
      
      public function getPlaylist() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(this.ytEnv.playlist)
         {
            _loc1_ = [];
            if(this.ytEnv.playlist.loaded)
            {
               _loc2_ = 0;
               while(_loc2_ < this.ytEnv.playlist.length)
               {
                  _loc1_.push(this.ytEnv.playlist.getVideo(_loc2_).videoId);
                  _loc2_++;
               }
            }
            return _loc1_;
         }
         return null;
      }
      
      protected function onWatermarkClick(param1:Event) : void
      {
         if(this.watermark.enabled)
         {
            this.navigateToHost();
         }
      }
      
      public function nextVideo() : void
      {
         if(this.ytEnv.playlist)
         {
            if(this.ytEnv.playlist.getVideo())
            {
               if(this.ytEnv.playlist.hasNext())
               {
                  this.scriptedLoadVideoById(this.ytEnv.playlist.getNext().videoId);
               }
            }
            else
            {
               this.playlistCued = false;
               ++this.ytEnv.playlist.index;
            }
         }
      }
      
      public function getClickToPlayButton(param1:String, param2:Number = 0, param3:String = null) : DisplayObject
      {
         var onClickToPlay:Function;
         var videoId:String = param1;
         var startSeconds:Number = param2;
         var quality:String = param3;
         var button:VideoStill = new VideoStill();
         button.buttonMode = true;
         button.load(this.ytEnv.getStillUrl(new VideoData(videoId)));
         onClickToPlay = function(param1:MouseEvent):void
         {
            scriptedClickToPlayById(videoId,startSeconds,quality);
         };
         button.addEventListener(MouseEvent.CLICK,onClickToPlay,true);
         return button;
      }
      
      public function getVerySmoothBandwidth() : Number
      {
         return this.smoother.getEstimate(0.9);
      }
      
      public function scriptedSeekVideo(param1:Number = 0, param2:Boolean = true) : void
      {
         if(this.state is PendingUserInputAppState)
         {
            this.videoData.scriptedPlayback = true;
         }
         this.seekVideo(param1,param2);
      }
      
      public function scriptedLoadModule(param1:String) : void
      {
         var _loc2_:ModuleDescriptor = this.moduleHost.getDescriptorById(param1);
         if(Boolean(_loc2_) && IScriptCapability in _loc2_.capabilities)
         {
            this.moduleHost.load(_loc2_);
         }
      }
      
      public function loadVideoByUrl(param1:Object, param2:Number = 0, param3:String = null) : void
      {
         var _loc4_:Url = null;
         if(getQualifiedClassName(param1) == "Object")
         {
            if(!param1.mediaContentUrl)
            {
               return;
            }
            _loc4_ = new Url(param1.mediaContentUrl);
            param2 ||= Number(param1.startSeconds) || 0;
            param3 = param1.suggestedQuality;
         }
         else
         {
            if(!(param1 is String))
            {
               return;
            }
            _loc4_ = new Url(String(param1));
         }
         this.ytEnv.applyGdataDevParams(_loc4_.queryVars);
         this.loadVideoById(_loc4_.fullPath.split("/").pop(),param2,param3);
      }
      
      protected function onLargePlayButtonClick(param1:MouseEvent) : void
      {
         this.playVideo();
      }
      
      protected function onPrerollReady(param1:String = null) : void
      {
         var _loc2_:Object = null;
         if(this.cueRangeManager && !this.prerollCueRange && this.state is PendingPrerollAppState)
         {
            this.prerollCueRange = new CueRange(TimeRange.ALL_MEDIA,null,PREROLL_CUERANGE_ID,CueRange.PRIORITY_PREROLL,true,true);
            this.prerollCueRange.addEventListener(CueRangeEvent.ENTER,this.onPrerollCueRangeEnter);
            this.cueRangeManager.addCueRange(this.prerollCueRange);
         }
         this.setAppState(this.state.onPrerollReady(param1));
         if(param1)
         {
            _loc2_ = {};
            _loc2_["pre_" + param1] = new Date().valueOf();
            this.ytEnv.applyTimingArgs(_loc2_);
         }
      }
      
      private function conditionallySendRequest(param1:RequestLoader, param2:URLRequest) : void
      {
         if(param2)
         {
            param1.sendRequest(param2);
         }
      }
      
      public function removeCueRange(param1:String) : void
      {
         if(param1 in this.apiCueRanges)
         {
            this.cueRangeManager.removeCueRange(this.apiCueRanges[param1]);
            delete this.apiCueRanges[param1];
         }
      }
      
      public function getDebugText(param1:Boolean = false) : String
      {
         var _loc4_:String = null;
         var _loc5_:ErrorEvent = null;
         var _loc2_:URLVariables = new URLVariables();
         var _loc3_:Object = this.getLoggingOptions();
         if(param1)
         {
            for(_loc4_ in _loc3_)
            {
               _loc2_[_loc4_] = _loc3_[_loc4_];
            }
         }
         _loc2_.debug_videoId = this.videoData.videoId;
         _loc2_.debug_sourceData = this.videoData.sourceData;
         _loc2_.debug_playbackQuality = this.getPlaybackQuality();
         _loc2_.debug_flashVersion = Capabilities.version;
         _loc2_.debug_date = new Date().toString();
         _loc2_.videoFps = Math.round(this.videoPlayer.getFPS());
         _loc2_.stageFps = stageAmbassador.frameRate;
         _loc2_.droppedFrames = _loc3_.nsidf || 0;
         if(param1 && this.videoPlayer.getPlayerState() is ErrorState)
         {
            _loc5_ = ErrorState(this.videoPlayer.getPlayerState()).error;
            _loc2_.debug_error = _loc5_ ? _loc5_.toString() : "Not specified.";
         }
         if(param1 && Boolean(this.ytEnv.lastStackTrace))
         {
            _loc2_.debug_stacktrace = this.ytEnv.lastStackTrace;
         }
         return _loc2_.toString();
      }
      
      protected function onResize(param1:Event = null) : void
      {
         if(Boolean(param1) && param1.eventPhase != EventPhase.AT_TARGET)
         {
            return;
         }
         if(!this.ytEnv.hosted && stageAmbassador.addedToStage)
         {
            this.resizeApplication(stageAmbassador.stageWidth,stageAmbassador.stageHeight);
         }
         else
         {
            this.resizeApplication(this.nominalWidth,this.nominalHeight);
         }
      }
      
      protected function onPrebufferFailure(param1:Event) : void
      {
         this.removePrebufferListeners();
         this.prebufferVideoData = null;
         TagStreamPlayer.prebufferFailure(this.videoData);
      }
      
      protected function selectPlaylistClip(param1:VideoData, param2:Boolean = false) : void
      {
      }
      
      protected function displayApplicationError(param1:String, param2:Number) : void
      {
         this.setPreloaderVisibility(false);
         environment.broadcastExternal(new ExternalEvent(ExternalEvent.ERROR,param2));
         if(this.streamingStats)
         {
            this.streamingStats.onApplicationError();
         }
      }
      
      public function getLoggingOptions() : Object
      {
         var _loc2_:Object = null;
         var _loc3_:* = undefined;
         var _loc4_:Rectangle = null;
         var _loc6_:String = null;
         var _loc1_:Object = environment.getLoggingOptions();
         _loc2_ = this.videoData.getLoggingOptions();
         for(_loc3_ in _loc2_)
         {
            _loc1_[_loc3_] = _loc2_[_loc3_];
         }
         _loc2_ = this.videoPlayer.getLoggingOptions();
         for(_loc3_ in _loc2_)
         {
            _loc1_[_loc3_] = _loc2_[_loc3_];
         }
         _loc1_.cfps = this.videoPlayer.getFPS();
         _loc4_ = this.videoPlayer.getDisplayRect();
         _loc1_.w = _loc4_.width;
         _loc1_.h = _loc4_.height;
         _loc1_.screenw = Capabilities.screenResolutionX;
         _loc1_.screenh = Capabilities.screenResolutionY;
         if(stageAmbassador.hasOwnProperty("contentsScaleFactor"))
         {
            _loc1_.pixel_ratio = stageAmbassador.contentsScaleFactor;
         }
         _loc1_.playerw = this.nominalWidth;
         _loc1_.playerh = this.nominalHeight;
         _loc2_ = this.moduleHost.getLoggingOptions();
         for(_loc3_ in _loc2_)
         {
            if(!(_loc3_ in _loc1_))
            {
               _loc1_[_loc3_] = _loc2_[_loc3_];
            }
         }
         _loc1_.scoville = 1;
         _loc1_.pd = this.playbackDelay;
         _loc1_.volume = this.getVolume();
         _loc1_.mos = this.isMuted() ? 1 : 0;
         if(this.videoData.infringe)
         {
            _loc1_.infringe = 1;
         }
         _loc1_.fs = this.isFullScreen() ? 1 : 0;
         if(this.errorReportCount > 0)
         {
            _loc1_.erc = this.errorReportCount;
         }
         _loc1_.tpmt = Math.floor(this.totalProgressMediaTime);
         if(Boolean(this.ytEnv.playlist) && Boolean(this.ytEnv.playlist.listId))
         {
            _loc1_.list = this.ytEnv.playlist.listId;
            _loc1_.list_index = this.ytEnv.playlist.index;
         }
         if(this.videoData.featureType)
         {
            _loc1_.feature = this.videoData.featureType;
         }
         else if(this.ytEnv.sourceFeature)
         {
            _loc1_.feature = this.ytEnv.sourceFeature;
         }
         var _loc5_:Object = this.formatSelector.getLoggingOptions();
         for(_loc6_ in _loc5_)
         {
            _loc1_[_loc6_] = _loc5_[_loc6_];
         }
         return _loc1_;
      }
      
      protected function supportsFullScreenSourceRect() : Boolean
      {
         return !this.ytEnv.hosted && PlayerVersion.isAtLeastVersion(9,0,115);
      }
      
      protected function likePlaylistClip(param1:ActionBarEvent) : void
      {
      }
      
      public function setAppState(param1:IAppState) : void
      {
         if(Object(this.state).toString() == Object(param1).toString())
         {
            return;
         }
         var _loc2_:IAppState = this.state;
         this.state = param1;
         dispatchEvent(new AppStateChangeEvent(AppStateChangeEvent.STATE_CHANGE,this.state,_loc2_));
      }
      
      protected function onPlaybackRateChange(param1:PlaybackRateEvent) : void
      {
         environment.broadcastExternal(new ExternalEvent(ExternalEvent.PLAYBACK_RATE_CHANGE,param1.playbackRate));
      }
      
      protected function unloadModules() : void
      {
         this.moduleHost.unregisterAll();
      }
      
      protected function setEnableKeyboard(param1:*) : void
      {
         var _loc2_:int = 0;
         this.keyboardExceptions = {};
         if(param1 is Array)
         {
            this.enableKeyboard = false;
            for each(_loc2_ in param1)
            {
               this.keyboardExceptions[_loc2_] = 1;
            }
         }
         else
         {
            this.enableKeyboard = Boolean(param1);
         }
      }
      
      protected function enableVideoControls() : void
      {
         this.focusManager.delegate = this;
      }
      
      protected function onLogTiming(param1:LogEvent) : void
      {
         this.ytEnv.applyTimingArgs(param1.args);
      }
      
      protected function navigateToHost(param1:Event = null) : void
      {
         if(this.videoData.watermarkUrl)
         {
            this.navigateToUrl(new URLRequest(this.videoData.watermarkUrl));
         }
         else
         {
            this.navigateToUrl(this.videoPlayer.videoUrlProvider.getWatermarkDestinationRequest(this.videoData));
         }
      }
      
      protected function startApplication() : void
      {
         if(!(this.state is PendingUserInputAppState))
         {
            this.playVideo(this.videoData);
         }
         else
         {
            this.setStillVisibility(true);
         }
      }
      
      public function getBytesTotal() : Number
      {
         return this.videoPlayer.getBytesTotal() + this.getVideoFileByteOffset();
      }
      
      public function stopVideo() : void
      {
         var _loc1_:* = this.externalPlayerState == ExternalPlayerState.ENDED;
         this.videoData.startSeconds = _loc1_ ? 0 : this.videoPlayer.getTime();
         this.cueVideo(this.videoData);
      }
      
      protected function onVideoFaceplateClose(param1:Event) : void
      {
         this.videoAdEventProvider.onAdClose();
      }
      
      protected function hasFallback(param1:VideoErrorEvent) : Boolean
      {
         return Boolean(param1.text) && param1.text.indexOf("NetStream.Play.") != -1 && this.videoData.canRetry;
      }
      
      protected function onFullScreenEvent(param1:FullScreenEvent) : void
      {
         var event:FullScreenEvent = param1;
         if(this.isFullScreen())
         {
            this.layerManager.setLayer("fullscreen",{"enableKeyboard":false});
            Scheduler.setTimeout(0,function(param1:Event):void
            {
               layerManager.clearLayer("fullscreen");
            });
         }
      }
      
      protected function setPlaybackQuality(param1:VideoQuality) : void
      {
         this.setPlaybackFormat(this.formatSelector.getVideoFormat(FormatSelectionRecord.MANUAL,param1));
      }
      
      protected function onSpliceComplete(param1:SpliceEvent) : void
      {
         if(this.streamingStats)
         {
            if(Boolean(param1.format) && Boolean(this.nowSplicing[param1.format]))
            {
               this.nowSplicing[param1.format].switchTime = this.getElapsedTime();
               this.streamingStats.onVideoFormatChange(this.nowSplicing[param1.format]);
               delete this.nowSplicing[param1.format];
            }
         }
      }
      
      protected function prepareVideoById(param1:String, param2:Number = 0, param3:Number = NaN, param4:String = null, param5:Number = 0) : void
      {
         var _loc6_:VideoData = new VideoData({
            "video_id":param1,
            "start":param2 || 0,
            "end":param3 || NaN,
            "delay":param5
         });
         this.prepareVideo(_loc6_,param4);
      }
      
      public function playVideo(param1:VideoData = null) : void
      {
         this.setAppState(this.state.playVideo());
         this.ensureVideoFormatSelected();
         if(!(this.state is IBlockingAppState))
         {
            this.videoPlayer.play(param1);
            if(!param1 && this.videoData.isHlsLiveOnly)
            {
               this.seekVideo(Infinity,true);
            }
         }
      }
      
      protected function onAccessibilityPropertiesUpdate(param1:Event) : void
      {
         if(!(param1 is AccessibilityPropertiesEvent))
         {
            return;
         }
         this.accessibilityUpdateTimeout.restart();
      }
      
      protected function refreshReservedRect(param1:ModuleDescriptor) : void
      {
         this.resizeModule(this.viewportRect.clone(),this.viewportRect);
      }
      
      public function onEndScreenEnter(param1:CueRangeEvent) : void
      {
         this.onAfterMediaEnd();
      }
      
      public function getFPS() : Number
      {
         return this.videoPlayer.getFPS();
      }
      
      public function getBufferEmptyEvents() : Number
      {
         return this.videoPlayer.getBufferEmptyEvents();
      }
      
      protected function prepareVideo(param1:VideoData, param2:String = null) : void
      {
         this.videoPlayer.stop();
         if(this.expirationTimeout != null)
         {
            this.expirationTimeout.stop();
         }
         this.videoStats.endPlayback();
         if(this.streamingStats)
         {
            this.streamingStats.endPlayback();
         }
         if(param1 != this.videoData)
         {
            this.unloadModules();
            this.cueRangeManager.reset();
            this.advertiserVideoCueRanges = {};
            this.apiCueRanges = {};
            this.prerollCueRange = null;
            this.apiEndScreenCueRange = null;
         }
         if(param2)
         {
            this.ytEnv.videoQualityPref = new VideoQuality(param2);
         }
         this.setAppState(new NotStartedAppState(this));
         this.updateVideoData(param1);
      }
      
      public function getSmoothedBandwidth() : Number
      {
         return this.formatSelector.getSmoothedBandwidth();
      }
      
      public function scriptedSetSize(param1:Number, param2:Number) : void
      {
         if(this.ytEnv.hosted)
         {
            this.resizeApplication(param1,param2);
         }
      }
      
      protected function sharePlaylistClip(param1:Event = null) : void
      {
      }
      
      protected function onModuleLogTiming(param1:Object, param2:Object) : void
      {
         this.ytEnv.applyTimingArgs(param1,param2);
      }
      
      public function previousVideo() : void
      {
         if(this.ytEnv.playlist)
         {
            if(this.ytEnv.playlist.getVideo())
            {
               this.scriptedLoadVideoById(this.ytEnv.playlist.getPrevious().videoId);
            }
            else
            {
               this.playlistCued = false;
               --this.ytEnv.playlist.index;
            }
         }
      }
      
      public function getExternalState() : int
      {
         return isNaN(this.externalPlayerState) ? ExternalPlayerState.UNSTARTED : int(this.externalPlayerState);
      }
      
      protected function onAdMetaData(param1:AdEvent) : void
      {
      }
      
      protected function initiatePlayback() : void
      {
         this.ensureVideoFormatSelected();
         this.videoPlayer.initiatePlayback();
      }
      
      protected function addToTabOrder(param1:UIElement) : void
      {
         this.tabbableElements.push(param1);
         this.updateAccessibilityProperties();
      }
      
      public function loadModules() : void
      {
         this.loadModule(AdModuleDescriptor,this.videoData.adModule);
         this.loadModule(UserGoalsModuleDescriptor,this.videoData.userGoalsModule);
         this.loadModule(FlashAccessModuleDescriptor,this.videoData.flashAccessModule);
         this.loadModule(RatingsModuleDescriptor,this.videoData.ratingsModule);
         this.loadModule(StreamingLibModuleDescriptor,this.videoData.streamingLibModule);
         this.loadModule(ThreeDModuleDescriptor,this.videoData.threeDModule);
         this.loadModule(YpcModuleDescriptor,this.videoData.ypcModule);
         this.loadModule(YpcLicenseCheckerModuleDescriptor,this.videoData.ypcLicenseCheckerModule);
         this.loadModule(FrescaModuleDescriptor,this.videoData.frescaModule);
      }
      
      protected function addVideoPlayer(param1:VideoData) : void
      {
         var _loc2_:Number = this.sharedSoundData.getVolume();
         if(this.videoPlayer)
         {
            _loc2_ = this.videoPlayer.getVolume();
            this.videoPlayer.removeEventListener(BandwidthSampleEvent.SAMPLE,this.onBandwidthSample);
            this.videoPlayer.removeEventListener(LogEvent.LOG,this.onLog);
            this.videoPlayer.removeEventListener(LogEvent.PLAYBACK,this.onLogPlayback);
            this.videoPlayer.removeEventListener(LogEvent.TIMING,this.onLogTiming);
            this.videoPlayer.removeEventListener(MouseEvent.CLICK,this.onVideoClick);
            this.videoPlayer.removeEventListener(SpliceEvent.COMPLETE,this.onSpliceComplete);
            this.videoPlayer.removeEventListener(SpliceEvent.START,this.onSpliceStart);
            this.videoPlayer.removeEventListener(StateChangeEvent.STATE_CHANGE,this.onVideoStateChange);
            this.videoPlayer.removeEventListener(VideoProgressEvent.PROGRESS,this.onVideoProgress);
            this.videoPlayer.removeEventListener(PlaybackRateEvent.RATE_CHANGE,this.onPlaybackRateChange);
            if(this.videoPlayer is IVideoAdEventProvider)
            {
               this.videoPlayer.removeEventListener(AdEvent.BREAK_START,this.onAdBreakStart);
               this.videoPlayer.removeEventListener(AdEvent.BREAK_END,this.onAdBreakEnd);
               this.videoPlayer.removeEventListener(AdEvent.PAUSE,this.onAdPause);
               this.videoPlayer.removeEventListener(AdEvent.PLAY,this.onAdPlay);
               this.videoPlayer.removeEventListener(AdEvent.END,this.onAdEnd);
               this.videoPlayer.removeEventListener(AdEvent.META_LOAD,this.onAdMetaData);
            }
            this.videoPlayer.destroy();
            this.layout.remove(this.videoPlayer);
         }
         this.videoPlayer = PlayerFactory.getPlayer(param1,this.ytEnv);
         this.videoPlayer.addEventListener(BandwidthSampleEvent.SAMPLE,this.onBandwidthSample);
         this.videoPlayer.addEventListener(LogEvent.LOG,this.onLog);
         this.videoPlayer.addEventListener(LogEvent.PLAYBACK,this.onLogPlayback);
         this.videoPlayer.addEventListener(LogEvent.TIMING,this.onLogTiming);
         this.videoPlayer.addEventListener(MouseEvent.CLICK,this.onVideoClick);
         this.videoPlayer.addEventListener(SpliceEvent.COMPLETE,this.onSpliceComplete);
         this.videoPlayer.addEventListener(SpliceEvent.START,this.onSpliceStart);
         this.videoPlayer.addEventListener(StateChangeEvent.STATE_CHANGE,this.onVideoStateChange);
         this.videoPlayer.addEventListener(VideoProgressEvent.PROGRESS,this.onVideoProgress);
         this.videoPlayer.addEventListener(PlaybackRateEvent.RATE_CHANGE,this.onPlaybackRateChange);
         if(this.cueRangeManager)
         {
            this.cueRangeManager.getMediaTime = this.videoPlayer.getTime;
            this.cueRangeManager.getPlayerState = this.videoPlayer.getPlayerState;
         }
         if(this.moduleHost)
         {
            this.moduleHost.videoPlayer = this.videoPlayer;
         }
         if(this.streamingStats)
         {
            this.streamingStats.videoPlayer = this.videoPlayer;
         }
         if(this.videoPlayer is IVideoAdEventProvider)
         {
            this.videoPlayer.addEventListener(AdEvent.BREAK_START,this.onAdBreakStart);
            this.videoPlayer.addEventListener(AdEvent.BREAK_END,this.onAdBreakEnd);
            this.videoPlayer.addEventListener(AdEvent.PAUSE,this.onAdPause);
            this.videoPlayer.addEventListener(AdEvent.PLAY,this.onAdPlay);
            this.videoPlayer.addEventListener(AdEvent.END,this.onAdEnd);
            this.videoPlayer.addEventListener(AdEvent.META_LOAD,this.onAdMetaData);
         }
         this.videoPlayer.setVolume(_loc2_);
         this.updateVideoData(param1);
         this.layout.add(this.videoPlayer);
      }
      
      protected function onBandwidthSample(param1:BandwidthSampleEvent) : void
      {
         this.formatSelector.onBandwidthSample(param1.sample.clone());
         if(this.streamingStats)
         {
            this.streamingStats.onBandwidthSample(param1.sample.clone());
         }
         this.smoother.addSample(param1.sample.clone());
      }
      
      protected function getPlaybackQualityString() : String
      {
         return this.getPlaybackQuality().toString();
      }
      
      public function getMediaDuration() : Number
      {
         return this.videoPlayer.getDuration();
      }
      
      protected function onAdBreakEnd(param1:AdEvent) : void
      {
         this.videoAdEventProvider = null;
         if(this.videoFaceplate is VideoFaceplate)
         {
            this.videoFaceplate.destroy();
         }
         this.layout.add(this.watermark);
         if(this.videoPlayer is IVideoAdAware)
         {
            IVideoAdAware(this.videoPlayer).onAdBreakEnd();
         }
         this.videoPlayer.setIgnorePeggedToLive(false);
      }
      
      protected function navigateToYouTube(param1:Event = null) : void
      {
         this.navigateToUrl(this.ytEnv.getVideoWatchRequest(this.videoData));
      }
      
      protected function onSpliceStart(param1:SpliceEvent) : void
      {
      }
      
      protected function getAvailableQualityLevelStrings() : Array
      {
         var _loc1_:Array = this.getAvailableQualityLevels();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc1_[_loc2_] = _loc1_[_loc2_].toString();
            _loc2_++;
         }
         return _loc1_;
      }
      
      protected function onApiCueRangeEvent(param1:CueRangeEvent) : void
      {
         var _loc2_:String = param1.type == CueRangeEvent.ENTER ? ExternalEvent.CUE_RANGE_ENTER : ExternalEvent.CUE_RANGE_EXIT;
         environment.broadcastExternal(new ExternalEvent(_loc2_,param1.cueRange.id));
      }
      
      protected function ensureVideoFormatSelected() : void
      {
         var _loc1_:VideoFormat = null;
         if(!this.videoData.hasFormat())
         {
            this.videoData.audioTrack = this.ytEnv.audioTrackPref;
            _loc1_ = this.formatSelector.getVideoFormat(FormatSelectionRecord.INITIAL,null,this.videoData);
            if(_loc1_)
            {
               this.videoData.format = _loc1_;
            }
         }
      }
      
      protected function preparePlaylist(param1:Object, param2:int = 0, param3:Number = 0, param4:String = null) : void
      {
         var _loc5_:Object = null;
         if(getQualifiedClassName(param1) == "Object")
         {
            _loc5_ = param1;
            param2 ||= int(param1.index) || 0;
            param3 ||= Number(param1.startSeconds) || 0;
            param4 = param1.suggestedQuality;
         }
         else
         {
            _loc5_ = {"api":param1};
         }
         this.setPlaybackQualityString(param4);
         if(this.ytEnv.playlist)
         {
            this.ytEnv.playlist.removeEventListener(Event.COMPLETE,this.onPlaylistComplete);
         }
         this.ytEnv.playlist = new Playlist(_loc5_,false,false,param2,param3,this.ytEnv.BASE_YT_URL);
         if(this.ytEnv.playlist.loaded)
         {
            this.onPlaylistComplete();
         }
         else
         {
            this.ytEnv.playlist.addEventListener(Event.COMPLETE,this.onPlaylistComplete);
         }
      }
      
      public function cueVideoById(param1:Object, param2:Number = 0, param3:String = null) : void
      {
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         if(getQualifiedClassName(param1) == "Object")
         {
            if(!param1.videoId)
            {
               return;
            }
            _loc4_ = param1.videoId;
            param2 ||= Number(param1.startSeconds) || 0;
            _loc5_ = Number(param1.endSeconds);
            param3 = param1.suggestedQuality;
         }
         else
         {
            if(!(param1 is String))
            {
               return;
            }
            _loc4_ = String(param1);
         }
         this.prepareVideoById(_loc4_,param2,_loc5_,param3);
         this.setAppState(new PendingUserInputAppState(this));
         this.setExternalState(ExternalPlayerState.CUED);
      }
      
      protected function getAvailableQualityLevels() : Array
      {
         return this.videoData.getAvailableQualityLevels();
      }
      
      protected function updateVideoData(param1:VideoData) : void
      {
         if(param1 != this.videoData)
         {
            if(this.videoData)
            {
               this.videoData.removeEventListener(VideoDataEvent.CHANGE,this.onVideoDataChange);
            }
            if(param1)
            {
               param1.addEventListener(VideoDataEvent.CHANGE,this.onVideoDataChange);
            }
         }
         this.videoPlayer.setVideoData(param1);
      }
      
      protected function onCueRangeLockBlockEnter(param1:CueRangeEvent) : void
      {
         var _loc2_:Boolean = !(this.videoPlayer.getPlayerState() is NotStartedState) && this.videoPlayer.getPlayerState() is IPausedState;
         this.videoPlayer.pause();
         this.seekSoftTimeout.stop();
         this.setAppState(this.state.onCueRangeLockBlockEnter(param1,_loc2_));
      }
   }
}

