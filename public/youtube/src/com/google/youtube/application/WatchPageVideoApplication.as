package com.google.youtube.application
{
   import com.google.utils.PlayerVersion;
   import com.google.utils.RequestLoader;
   import com.google.utils.RequestVariables;
   import com.google.utils.Scheduler;
   import com.google.youtube.event.ActionBarEvent;
   import com.google.youtube.event.AdEvent;
   import com.google.youtube.event.ExternalEvent;
   import com.google.youtube.event.LogEvent;
   import com.google.youtube.event.MouseActivityEvent;
   import com.google.youtube.event.PlaybackRateEvent;
   import com.google.youtube.event.SeekEvent;
   import com.google.youtube.event.SpliceEvent;
   import com.google.youtube.event.SubscriptionEvent;
   import com.google.youtube.event.TweenEvent;
   import com.google.youtube.event.VideoProgressEvent;
   import com.google.youtube.event.VolumeEvent;
   import com.google.youtube.model.AudioTrackChangeEvent;
   import com.google.youtube.model.EventLabel;
   import com.google.youtube.model.FailureReport;
   import com.google.youtube.model.FormatSelectionRecord;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.ListId;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.PlayerStyle;
   import com.google.youtube.model.QualityChangeEvent;
   import com.google.youtube.model.VideoControlType;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.VideoDataEvent;
   import com.google.youtube.model.VideoQuality;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.model.YouTubeEnvironment;
   import com.google.youtube.modules.IControlsCapability;
   import com.google.youtube.modules.IModule;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.modules.ModuleStatus;
   import com.google.youtube.modules.akamaihd.AkamaiHdModuleDescriptor;
   import com.google.youtube.modules.endscreen.EndScreenModuleDescriptor;
   import com.google.youtube.modules.enhance.EnhanceModuleDescriptor;
   import com.google.youtube.modules.iv.IvModuleDescriptor;
   import com.google.youtube.modules.multicamera.MultiCameraModuleDescriptor;
   import com.google.youtube.modules.playlist.PlaylistModuleDescriptor;
   import com.google.youtube.modules.region.RegionModuleDescriptor;
   import com.google.youtube.modules.st.StreamingTextModuleDescriptor;
   import com.google.youtube.modules.subtitles.SubtitlesModuleDescriptor;
   import com.google.youtube.modules.threed.ThreeDModuleDescriptor;
   import com.google.youtube.modules.yva.YvaModuleDescriptor;
   import com.google.youtube.players.AkamaiHDLiveVideoPlayer;
   import com.google.youtube.players.BaseAdPlayerState;
   import com.google.youtube.players.BaseVideoPlayer;
   import com.google.youtube.players.ErrorState;
   import com.google.youtube.players.IBufferingState;
   import com.google.youtube.players.IEndedState;
   import com.google.youtube.players.IPausedState;
   import com.google.youtube.players.IPlayerState;
   import com.google.youtube.players.IPlayingState;
   import com.google.youtube.players.IVideoAdEventProvider;
   import com.google.youtube.players.IVideoPlayer;
   import com.google.youtube.players.NotStartedState;
   import com.google.youtube.players.PausedState;
   import com.google.youtube.players.PlayerAdapter;
   import com.google.youtube.players.StateChangeEvent;
   import com.google.youtube.time.CueRange;
   import com.google.youtube.time.CueRangeEvent;
   import com.google.youtube.time.TimeRange;
   import com.google.youtube.ui.ActionBar;
   import com.google.youtube.ui.AudioTrackButton;
   import com.google.youtube.ui.Bezel;
   import com.google.youtube.ui.Dialog;
   import com.google.youtube.ui.Drawing;
   import com.google.youtube.ui.ErrorDisplay;
   import com.google.youtube.ui.Filmstrip;
   import com.google.youtube.ui.FullScreenButton;
   import com.google.youtube.ui.LargePlayButton;
   import com.google.youtube.ui.LayoutElement;
   import com.google.youtube.ui.ModuleButton;
   import com.google.youtube.ui.NextButton;
   import com.google.youtube.ui.PlayPauseButton;
   import com.google.youtube.ui.SeekBarMarker;
   import com.google.youtube.ui.SettingsButton;
   import com.google.youtube.ui.ShortcutsDialog;
   import com.google.youtube.ui.SizeButton;
   import com.google.youtube.ui.Theme;
   import com.google.youtube.ui.TimeDisplay;
   import com.google.youtube.ui.VideoControls;
   import com.google.youtube.ui.VideoFaceplate;
   import com.google.youtube.ui.VideoInfoWindow;
   import com.google.youtube.ui.VideoStoryboardThumbnail;
   import com.google.youtube.ui.VolumeControlButton;
   import com.google.youtube.ui.WatchLaterButton;
   import com.google.youtube.ui.Watermark;
   import com.google.youtube.ui.YouTubeButton;
   import com.google.youtube.ui.drawing;
   import com.google.youtube.util.MouseActivity;
   import com.google.youtube.util.Tween;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.EventPhase;
   import flash.events.FullScreenEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.Rectangle;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.system.System;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.ui.Keyboard;
   import flash.ui.Mouse;
   
   public class WatchPageVideoApplication extends VideoApplication
   {
      
      protected static const RESTORE_SO_KEY:String = "restore";
      
      protected static const FILMSTRIP_DELAY:int = 100;
      
      protected var nextButton:NextButton;
      
      protected var biggerSizeButton:SizeButton;
      
      protected var filmstrip:Filmstrip;
      
      protected var controlsInset:Rectangle = new Rectangle();
      
      protected var isFullScreenNav:Boolean = false;
      
      protected var loggingOptions:Object = {};
      
      protected var seekingState:IPlayerState;
      
      protected var videoControls:VideoControls;
      
      protected var youTubeButton:YouTubeButton;
      
      protected var seekingTime:Number;
      
      protected var screen:LayoutElement;
      
      protected var getAutoHideOffset:Function;
      
      protected var insetControlsMask:Rectangle;
      
      protected var watchLaterButton:WatchLaterButton;
      
      protected var shortcutsDialog:ShortcutsDialog;
      
      protected var audioTrackButton:AudioTrackButton;
      
      protected var firstBytePollScheduler:Scheduler;
      
      protected var mouseActivity:MouseActivity;
      
      protected var videoInfoUpdateInterval:Scheduler;
      
      protected var controlsOffset:int = 0;
      
      protected var fullScreenButton:FullScreenButton;
      
      protected var playPauseButton:PlayPauseButton;
      
      protected var endScreenCueRange:CueRange;
      
      protected var videoInfoWindow:VideoInfoWindow;
      
      protected var uiOverlay:LayoutElement = new LayoutElement();
      
      protected var endScreen:LayoutElement;
      
      protected var settingsButton:SettingsButton;
      
      protected var timeDisplay:TimeDisplay;
      
      protected var viewportTween:Tween;
      
      protected var moduleButtons:Array = [];
      
      protected var bezel:Bezel;
      
      protected var spliceStartTrigger:Event;
      
      protected var errorDisplay:ErrorDisplay;
      
      protected var framePreview:VideoStoryboardThumbnail;
      
      protected var prevTime:Date;
      
      protected var smallerSizeButton:SizeButton;
      
      protected var actionBarPausedVideo:Boolean;
      
      protected const AUTO_HIDE_OFFSET_MODES:Object;
      
      protected var filmstripDelay:Scheduler;
      
      protected var activeDialog:Dialog;
      
      protected var volumeControlButton:VolumeControlButton;
      
      protected var prevBytes:Number;
      
      protected var actionBar:ActionBar;
      
      public function WatchPageVideoApplication(param1:Object = null)
      {
         this.AUTO_HIDE_OFFSET_MODES = {
            "0":this.autoHideDisabledMode,
            "1":this.autoHideCompletelyMode,
            "2":this.autoHideFullScreenOnlyMode,
            "3":this.autoHideWithGutterModeAutomatically
         };
         this.getAutoHideOffset = this.autoHideFullScreenOnlyMode;
         super(param1);
         towardsEndOfMovieThreshold = 80;
      }
      
      override public function resizeApplication(param1:Number, param2:Number) : void
      {
         var _loc5_:ModuleDescriptor = null;
         var _loc6_:Rectangle = null;
         if(state is UnbuiltAppState)
         {
            super.resizeApplication(param1,param2);
            return;
         }
         var _loc3_:Number = ytEnv.showControls && this.videoControls && this.videoControls.visible && this.videoControls.visibleControls ? VideoControls.CONTROLS_HEIGHT - this.controlsOffset : 0;
         if(_loc3_ > 0 && ytEnv.autoHideControls == YouTubeEnvironment.AUTO_HIDE_OFF)
         {
            _loc3_ += Theme.getConstant("SEEK_HEIGHT") - (Theme.getConstant("SEEK_OFFSET") || 0);
         }
         var _loc4_:Rectangle = new Rectangle();
         if(!isFullScreen())
         {
            for each(_loc5_ in moduleHost.getModulesByCapability(IControlsCapability))
            {
               _loc6_ = IControlsCapability(_loc5_).controlsInset;
               _loc4_.top += _loc6_.top;
               _loc4_.bottom += _loc6_.bottom;
               _loc4_.left += _loc6_.left;
               _loc4_.right += _loc6_.right;
            }
         }
         this.controlsInset = !isFullScreen() ? _loc4_ : new Rectangle();
         for each(_loc5_ in moduleHost.getModulesByCapability(IControlsCapability))
         {
            IControlsCapability(_loc5_).controlsRespected = this.controlsInset == _loc4_;
         }
         x = this.controlsInset.left;
         y = this.controlsInset.top;
         this.insetControlsMask = this.controlsInset.equals(new Rectangle()) ? null : new Rectangle(0,0,param1 - this.controlsInset.left - this.controlsInset.right,param2 - this.controlsInset.top - this.controlsInset.bottom);
         this.maskSprite(this.actionBar,this.insetControlsMask);
         this.maskSprite(this.videoControls,this.insetControlsMask);
         super.resizeApplication(param1 - this.controlsInset.left - this.controlsInset.right,param2 - _loc3_ - this.controlsInset.top - this.controlsInset.bottom);
         nominalWidth = param1;
         nominalHeight = param2;
         this.showControls(false);
      }
      
      public function onSeekClearClip(param1:SeekEvent = null) : void
      {
         var _loc2_:Number = videoData.clipEnd;
         videoData.clipStart = NaN;
         videoData.clipEnd = NaN;
         this.videoControls.videoData = videoData;
         if(Boolean(_loc2_) && videoPlayer.getPlayerState() is IEndedState)
         {
            this.seekVideo(_loc2_,false);
         }
      }
      
      protected function hideAudioTrackButton() : void
      {
         this.videoControls.audioTrack.remove(this.audioTrackButton);
      }
      
      public function onScreenDoubleClick(param1:MouseEvent) : void
      {
         this.onScreenClick(param1);
         if(ytEnv.gestures)
         {
            this.bezel.finish();
            this.toggleFullScreen(param1);
         }
      }
      
      protected function onCopyDebugInfo(param1:ContextMenuEvent) : void
      {
         this.setClipboard(this.getDebugText(true));
      }
      
      override protected function onMessageUpdate(param1:MessageEvent) : void
      {
         super.onMessageUpdate(param1);
         this.updateContextMenu();
         this.updateAudioTrackButton();
      }
      
      public function onPlayPause(param1:MouseEvent) : void
      {
         if(this.playPauseButton.enabled)
         {
            togglePause();
         }
      }
      
      override protected function setStillVisibility(param1:Boolean) : void
      {
         if(this.getAutoHideOffset() && param1 && videoPlayer.getPlayerState() is NotStartedState)
         {
            layerManager.setLayer("autohideCuedControls",{"videoControls":null});
         }
         else
         {
            layerManager.clearLayer("autohideCuedControls");
         }
         super.setStillVisibility(param1);
      }
      
      override public function mute() : void
      {
         super.mute();
         this.volumeControlButton.setValue(getVolume());
      }
      
      override protected function initVideoStats(param1:Object) : void
      {
         param1.el = ytEnv.eventLabel;
         super.initVideoStats(param1);
      }
      
      public function onPopout(param1:Event) : void
      {
         ytEnv.callExternal("yt.www.watch.player.openPopup",videoData.videoId,videoData.videoWidth,videoData.videoHeight);
      }
      
      private function hideFramePreviews() : void
      {
         this.filmstripDelay.stop();
         if(Boolean(this.filmstrip) && contains(this.filmstrip))
         {
            this.framePreview.tween.fadeOut(200);
            this.framePreview.tween.addEventListener(TweenEvent.END,this.removeOnTweenEnd);
            this.filmstrip.tween.fadeOut(200);
            this.filmstrip.tween.addEventListener(TweenEvent.END,this.removeOnTweenEnd);
         }
      }
      
      protected function hideControls(param1:Boolean = true) : void
      {
         var _loc4_:ModuleDescriptor = null;
         var _loc5_:int = 0;
         if(videoPlayer.getPlayerState() is IEndedState)
         {
            return;
         }
         var _loc2_:int = param1 ? 500 : 0;
         if(ytEnv.autoHideControls != YouTubeEnvironment.AUTO_HIDE_OFF)
         {
            this.videoControls.setLabel(VideoControls.FADE,param1);
         }
         if(this.controlsOffset && this.viewportTween && this.videoControls.visible)
         {
            _loc5_ = this.height - VideoControls.CONTROLS_HEIGHT + this.controlsOffset;
            this.viewportTween.easeIn().to({"height":_loc5_},_loc2_);
         }
         if(isFullScreen() && !ytEnv.hosted)
         {
            Mouse.hide();
         }
         var _loc3_:Array = moduleHost.getLoadedModulesByCapability(IOverlayCapability);
         for each(_loc4_ in _loc3_)
         {
            IOverlayCapability(_loc4_.instance).onVideoControlsHide();
         }
         this.settingsButton.hideMenu();
      }
      
      override public function setVolume(param1:Number) : void
      {
         super.setVolume(param1);
         this.volumeControlButton.setValue(getVolume());
      }
      
      override protected function onVideoStateChange(param1:StateChangeEvent) : void
      {
         if(param1.state is IPlayingState || param1.state is PausedState && PausedState(param1.state).triggeredByBufferFull)
         {
            this.onQualityPlaybackBegin(videoData.format.quality.toString());
            ytEnv.logCsi(videoData,new Date(),param1.state is PausedState);
         }
         if(param1.state is IEndedState)
         {
            this.playPauseButton.showReplay();
         }
         else if(!this.seekingState)
         {
            if(param1.state is IPausedState)
            {
               if(videoData.isPauseEnabled)
               {
                  this.playPauseButton.showPlay();
               }
               else
               {
                  this.playPauseButton.showResume();
               }
            }
            else if(videoData.isPauseEnabled)
            {
               this.playPauseButton.showPause();
            }
            else
            {
               this.playPauseButton.showStop();
            }
         }
         this.videoControls.isPeggedToLive = videoPlayer.isPeggedToLive();
         this.timeDisplay.isPeggedToLive = videoPlayer.isPeggedToLive();
         if(!(param1.state is ErrorState))
         {
            layout.remove(this.errorDisplay);
         }
         if(Boolean(this.actionBar) && !(param1.state is PausedState))
         {
            this.actionBar.hideInfoCard();
         }
         if(this.watchLaterButton)
         {
            this.watchLaterButton.hideMenu();
         }
         super.onVideoStateChange(param1);
      }
      
      override public function setLoop(param1:Boolean) : void
      {
         super.setLoop(param1);
         this.updateNextButton();
      }
      
      override protected function onVideoProgress(param1:VideoProgressEvent) : void
      {
         var _loc2_:URLRequest = null;
         var _loc3_:RequestLoader = null;
         super.onVideoProgress(param1);
         if(!(state is UnbuiltAppState))
         {
            if(this.seekingState)
            {
               param1.time = this.seekingTime;
            }
            this.timeDisplay.time = param1.time;
            if(videoData.isHls && !videoData.isHlsLiveOnly && !isNaN(param1.duration))
            {
               this.timeDisplay.duration = param1.duration;
               this.videoControls.duration = param1.duration;
            }
            this.videoControls.onVideoProgress(param1);
         }
         if(videoData.isDoubleclickTracked && currentProgressMediaTime >= 70)
         {
            _loc2_ = ytEnv.getDoubleclickTrackRequest(videoData);
            _loc3_ = new RequestLoader();
            _loc3_.loadRequest(_loc2_);
            videoData.isDoubleclickTracked = false;
         }
      }
      
      protected function onGetVideoAspectRatio(param1:Event = null) : Number
      {
         var _loc2_:Rectangle = videoPlayer.getDisplayRect();
         return _loc2_.width / _loc2_.height;
      }
      
      protected function onGetWatchUrl(param1:ContextMenuEvent) : void
      {
         this.setClipboard(getVideoWatchUrl());
      }
      
      private function showFramePreviews() : void
      {
         if(!contains(this.filmstrip) || this.filmstrip.tween.willTrigger(TweenEvent.END))
         {
            this.framePreview.tween.removeEventListener(TweenEvent.END,this.removeOnTweenEnd);
            this.filmstrip.tween.removeEventListener(TweenEvent.END,this.removeOnTweenEnd);
            this.filmstripDelay.restart();
         }
      }
      
      override protected function resizeModule(param1:Rectangle, param2:Rectangle, param3:ModuleDescriptor = null) : void
      {
         if(Boolean(param1) && Boolean(this.videoControls))
         {
            if(this.videoControls.visible)
            {
               param1.height -= Math.max(this.videoControls.height - VideoControls.CONTROLS_HEIGHT,0);
            }
            param2 = new Rectangle(0,0,this.width,this.height - VideoControls.CONTROLS_HEIGHT + this.controlsOffset);
            super.resizeModule(param1,param2,param3);
         }
      }
      
      override protected function disableVideoControls(param1:Object, param2:Object = null) : void
      {
         super.disableVideoControls(param1,param2);
         param2 = param2 ? param2 : VideoControlType.DEFAULT_EXCEPTIONS;
         this.playPauseButton.enabled = Boolean(param2[VideoControlType.PLAY]) || Boolean(param2[VideoControlType.PAUSE]);
         if(this.nextButton)
         {
            this.nextButton.enabled = param2[VideoControlType.NEXT];
         }
         this.volumeControlButton.enabled = param2[VideoControlType.VOLUME];
         if(this.audioTrackButton)
         {
            this.audioTrackButton.enabled = param2[VideoControlType.VOLUME];
         }
         if(this.fullScreenButton)
         {
            this.fullScreenButton.enabled = param2[VideoControlType.FULLSCREEN];
         }
         if(Boolean(this.youTubeButton) && !param2[VideoControlType.YOUTUBE_BUTTON])
         {
            this.youTubeButton.removeEventListener(MouseEvent.CLICK,this.navigateToYouTube);
            this.youTubeButton.enabled = false;
         }
         if(param2[VideoControlType.PLAY])
         {
            this.playPauseButton.showPlay();
         }
         else if(param2[VideoControlType.PAUSE])
         {
            if(videoData.isPauseEnabled)
            {
               this.playPauseButton.showPause();
            }
            else
            {
               this.playPauseButton.showStop();
            }
         }
         this.videoControls.enabled = false;
         this.timeDisplay.enabled = false;
         this.updateAutoHideControls();
         layout.remove(this.filmstrip);
         this.filmstripDelay.stop();
      }
      
      override public function toggleFullScreen(param1:Event = null) : void
      {
         super.toggleFullScreen(param1);
         if(this.fullScreenButton)
         {
            this.fullScreenButton.enabled = stageAmbassador.fullScreenAllowed;
            this.fullScreenButton.onMouseOut(null);
         }
      }
      
      protected function updateAutoHideControls() : void
      {
         if(ytEnv.showControls && this.controlsOffset != this.getAutoHideOffset())
         {
            this.controlsOffset = this.getAutoHideOffset();
            this.onResize();
         }
      }
      
      override public function unMute() : void
      {
         super.unMute();
         this.volumeControlButton.setValue(getVolume());
      }
      
      protected function onSpeedTest(param1:ContextMenuEvent) : void
      {
         var event:ContextMenuEvent = param1;
         var request:URLRequest = ytEnv.getSpeedTestRequest();
         try
         {
            navigateToUrl(request);
         }
         catch(error:SecurityError)
         {
         }
         pauseVideo();
      }
      
      override protected function onCueRangeRemoved(param1:CueRangeEvent) : void
      {
         if(param1.cueRange.marker)
         {
            this.videoControls.removeMarker(param1.cueRange.marker);
         }
      }
      
      public function onSizeChange(param1:Event = null) : void
      {
         var _loc2_:* = false;
         if(isFullScreen())
         {
            this.toggleFullScreen();
         }
         if(param1 && param1.target is SizeButton && SizeButton(param1.target).enabled)
         {
            _loc2_ = !ytEnv.playerWide;
            _loc2_ = param1.target == this.biggerSizeButton;
            ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.SIZE_CLICKED,_loc2_));
            if(_loc2_)
            {
               this.smallerSizeButton.showLarge();
               this.biggerSizeButton.showLarge();
            }
            else
            {
               this.smallerSizeButton.showSmall();
               this.biggerSizeButton.showSmall();
            }
            ytEnv.playerWide = _loc2_;
         }
      }
      
      override protected function setPreloaderVisibility(param1:Boolean) : void
      {
         super.setPreloaderVisibility(param1 && !this.seekingState);
      }
      
      protected function hideAppEndScreen() : void
      {
         setPlayButtonVisibility(false);
         this.setStillVisibility(false);
         layout.remove(this.endScreen);
      }
      
      protected function addScreen() : void
      {
         if(!(videoPlayer is IVideoAdEventProvider))
         {
            layout.add(this.screen);
         }
      }
      
      override public function build() : void
      {
         var showNormal:Boolean;
         var extras:Boolean = false;
         if(ytEnv.watchXlbUrl)
         {
            ytEnv.messages.load(ytEnv.interfaceLanguage,ytEnv.watchXlbUrl);
         }
         this.screen = new LayoutElement();
         Drawing.invisibleRect(this.screen.graphics,0,0,1,1);
         this.screen.horizontalStretch = 1;
         this.screen.verticalStretch = 1;
         this.endScreen = new LayoutElement();
         drawing(this.endScreen.graphics).fill(0,0.95).rect(0,0,1,1).end();
         this.endScreen.horizontalStretch = 1;
         this.endScreen.verticalStretch = 1;
         layout.order(IVideoPlayer,VideoStoryboardThumbnail,Bezel,this.screen,IModule,"com.google.youtube.modules.subtitles::SubtitlesModule","com.google.youtube.modules.threed::ThreeDModule",LargePlayButton,ErrorDisplay,"com.google.youtube.modules.fresca::FrescaModule",ActionBar,Watermark,this.endScreen,"com.google.youtube.modules.multicamera::MultiCameraModule","com.google.youtube.modules.endscreen::EndScreenModule","com.google.youtube.modules.st::StreamingTextModule",VideoInfoWindow,"com.google.youtube.modules.ad::AdModule",VideoFaceplate,"com.google.youtube.modules.playlist::PlaylistModule",this.uiOverlay,Filmstrip,VideoControls);
         layerManager.setLayer("chrome",{"videoControls":new VideoControls(ytEnv.messages,ytEnv.showControls)});
         if(ytEnv.playerStyle == PlayerStyle.YVA)
         {
            this.videoControls.visible = false;
         }
         this.videoControls.primary.order(PlayPauseButton,NextButton);
         this.videoControls.status.order(VolumeControlButton,TimeDisplay);
         this.videoControls.modules.order(PlaylistModuleDescriptor.ID,ModuleButton,StreamingTextModuleDescriptor.ID,IvModuleDescriptor.ID,SubtitlesModuleDescriptor.ID,ThreeDModuleDescriptor.ID,SettingsButton);
         this.videoControls.secondary.order(WatchLaterButton,YouTubeButton);
         this.videoControls.size.order(SizeButton,FullScreenButton);
         this.playPauseButton = new PlayPauseButton(ytEnv.messages);
         this.playPauseButton.addEventListener(MouseEvent.CLICK,focusManager.onPlayPause);
         this.videoControls.addEventListener(SeekEvent.SEEK,focusManager.onSeekRequest);
         this.videoControls.addEventListener(SeekEvent.START,focusManager.onSeekStart);
         this.videoControls.addEventListener(SeekEvent.COMPLETE,focusManager.onSeekComplete);
         this.videoControls.addEventListener(SeekEvent.CLEAR_CLIP,this.onSeekClearClip);
         this.videoControls.addEventListener(TweenEvent.UPDATE,this.onSeekbarTweenUpdate);
         this.volumeControlButton = new VolumeControlButton(sharedSoundData.getStoredVolume(),ytEnv.messages);
         this.volumeControlButton.addEventListener(VolumeEvent.MUTE,this.onVolumeMute);
         this.volumeControlButton.addEventListener(VolumeEvent.UNMUTE,this.onVolumeUnmute);
         this.volumeControlButton.addEventListener(VolumeEvent.CHANGE,this.onVolumeChange);
         this.timeDisplay = new TimeDisplay(ytEnv.messages);
         this.videoControls.status.add(this.volumeControlButton,this.timeDisplay);
         this.settingsButton = new SettingsButton(ytEnv.messages,!ytEnv.autoQuality);
         this.settingsButton.addEventListener(QualityChangeEvent.CHANGE,focusManager.onQualityChange);
         this.settingsButton.addEventListener(QualityChangeEvent.SETTINGS_CHANGE,this.onQualitySettingsChange);
         this.settingsButton.addEventListener(PlaybackRateEvent.RATE_CHANGE,this.onPlaybackRateSelected);
         this.settingsButton.addEventListener(MouseEvent.CLICK,this.onSettingsClick);
         if(ytEnv.enableSizeButton)
         {
            this.smallerSizeButton = new SizeButton(ytEnv.messages,true);
            this.smallerSizeButton.addEventListener(MouseEvent.CLICK,this.onSizeChange);
            this.biggerSizeButton = new SizeButton(ytEnv.messages,false);
            this.biggerSizeButton.addEventListener(MouseEvent.CLICK,this.onSizeChange);
            this.videoControls.size.add(this.biggerSizeButton,this.smallerSizeButton);
            if(ytEnv.playerWide)
            {
               this.smallerSizeButton.showLarge();
               this.biggerSizeButton.showLarge();
            }
            else
            {
               this.smallerSizeButton.showSmall();
               this.biggerSizeButton.showSmall();
            }
         }
         if(ytEnv.showInfo)
         {
            extras = ytEnv.embellishEmbed || !ytEnv.preferYouTubeTitleTip;
            this.actionBar = new ActionBar(ytEnv.messages,ytEnv.showLikeButton,!ytEnv.suppressEndScreenShare && extras,ytEnv.showYouTubeTitleTip,!extras,false);
            this.actionBar.addEventListener(ActionBarEvent.SHARE,this.sharePlaylistClip);
            this.actionBar.addEventListener(ActionBarEvent.NAVIGATE_TO_YOUTUBE,this.navigateToYouTube);
            this.actionBar.addEventListener(ActionBarEvent.NAVIGATE_TO_VIDEO_CHANNEL,function(param1:ActionBarEvent):void
            {
               navigateToUrl(ytEnv.getVideoChannelRequest(videoData),"_blank");
            });
            this.actionBar.addEventListener(ActionBarEvent.EXPAND,this.onActionBarExpand);
            this.actionBar.addEventListener(ActionBarEvent.COLLAPSE,this.onActionBarCollapse);
            this.actionBar.addEventListener(ActionBarEvent.LIKE,this.likePlaylistClip);
            this.actionBar.addEventListener(ActionBarEvent.DISLIKE,this.likePlaylistClip);
            this.maskSprite(this.actionBar,this.insetControlsMask);
            this.showActionBar();
         }
         showNormal = isFullScreen();
         if(PlayerVersion.isAtLeastVersion(9,0,28) && ytEnv.allowFullScreen && stageAmbassador.stageAllowed)
         {
            this.fullScreenButton = new FullScreenButton(ytEnv.messages);
            if(showNormal)
            {
               this.fullScreenButton.showNormal();
            }
            else
            {
               this.fullScreenButton.showFullScreen();
            }
            this.fullScreenButton.addEventListener(MouseEvent.CLICK,this.toggleFullScreen);
            this.videoControls.size.add(this.fullScreenButton);
         }
         this.screen.addEventListener(MouseEvent.CLICK,focusManager.onScreenClick);
         this.screen.doubleClickEnabled = true;
         this.screen.addEventListener(MouseEvent.DOUBLE_CLICK,focusManager.onScreenDoubleClick);
         this.updateContextMenu();
         this.videoControls.primary.add(this.playPauseButton);
         this.addScreen();
         this.bezel = new Bezel();
         if(ytEnv.gestures)
         {
            layout.add(this.bezel);
         }
         if(ytEnv.showControls)
         {
            this.viewportTween = new Tween(viewportRect);
            this.viewportTween.addEventListener(TweenEvent.UPDATE,this.onViewportChange);
            if(ytEnv.showYouTubeButton)
            {
               this.youTubeButton = new YouTubeButton(ytEnv.messages);
               this.youTubeButton.addEventListener(MouseEvent.CLICK,this.navigateToYouTube);
               this.videoControls.secondary.add(this.youTubeButton);
            }
            if(ytEnv.showWatchLaterButton)
            {
               this.watchLaterButton = new WatchLaterButton(ytEnv.messages);
               this.watchLaterButton.addEventListener(MouseEvent.CLICK,this.onAddToWatchLater);
            }
         }
         if(ytEnv.eventLabel == EventLabel.DETAIL_PAGE)
         {
            stageAmbassador.addEventListener(MouseEvent.CLICK,this.onUserActivity);
         }
         this.filmstripDelay = Scheduler.setTimeout(FILMSTRIP_DELAY,this.onFilmstripDelay);
         this.filmstripDelay.stop();
         this.mouseActivity = new MouseActivity(stageAmbassador,this);
         this.mouseActivity.addEventListener(MouseActivityEvent.ACTIVE,this.onMouseActive);
         this.mouseActivity.addEventListener(MouseActivityEvent.IDLE,this.onMouseIdle);
         super.build();
      }
      
      public function autoHideDisabledMode() : Number
      {
         return 0;
      }
      
      public function disableSeekBar() : void
      {
         this.videoControls.allowSeeking = false;
         this.videoControls.enabled = false;
      }
      
      private function onAudioTrackSelect(param1:AudioTrackChangeEvent) : void
      {
         this.spliceStartTrigger = param1;
         videoData.audioTrack = param1.track;
         this.spliceStartTrigger = null;
      }
      
      protected function pollForFirstByte(param1:Event = null) : void
      {
         if(getBytesLoaded() > 0)
         {
            this.prevTime = new Date();
            this.prevBytes = getBytesLoaded();
            ytEnv.applyTimingArgs({"fvb":this.prevTime.valueOf()});
            this.firstBytePollScheduler.stop();
         }
      }
      
      protected function setAutoHideOffset(param1:int) : void
      {
         this.getAutoHideOffset = this.AUTO_HIDE_OFFSET_MODES[param1.toString()];
         if(!(this.getAutoHideOffset is Function))
         {
            this.getAutoHideOffset = this.autoHideFullScreenOnlyMode;
         }
      }
      
      private function disableVideoControlsWithAdEvent(param1:AdEvent) : void
      {
         if(param1.data.disable !== false)
         {
            layerManager.setLayer("adbreak",{
               "enableKeyboard":false,
               "enableControls":param1.data
            });
         }
      }
      
      override protected function onAdBreakStart(param1:AdEvent) : void
      {
         super.onAdBreakStart(param1);
         this.disableVideoControlsWithAdEvent(param1);
         if(this.screen)
         {
            this.screen.mouseEnabled = false;
            this.screen.doubleClickEnabled = false;
         }
         if(videoAdEventProvider is PlayerAdapter)
         {
            this.setPreloaderVisibility(false);
         }
      }
      
      protected function onReportIssue(param1:ContextMenuEvent) : void
      {
         var options:Object;
         var i:String = null;
         var request:URLRequest = null;
         var event:ContextMenuEvent = param1;
         var rv:RequestVariables = new RequestVariables();
         rv.ec = FailureReport.USER_ERROR_REPORT_CODE;
         options = this.getLoggingOptions();
         for(i in options)
         {
            rv[i] = options[i];
         }
         onLog(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,rv));
         request = ytEnv.getReportIssueRequest(videoData);
         try
         {
            navigateToUrl(request);
         }
         catch(error:SecurityError)
         {
         }
         pauseVideo();
      }
      
      protected function onActionBarCollapse(param1:ActionBarEvent) : void
      {
         if(this.actionBarPausedVideo)
         {
            this.actionBarPausedVideo = false;
            playVideo();
         }
      }
      
      protected function onMouseActive(param1:MouseActivityEvent) : void
      {
         if(ytEnv.eventLabel == EventLabel.DETAIL_PAGE && nominalHeight <= 100 && nominalWidth <= 160)
         {
            return;
         }
         this.showControls();
         if(this.actionBar)
         {
            this.actionBar.tween.easeOut().to({"y":0},100);
         }
         if(watermark && !isFullScreen() && !videoData.isPartnerWatermark)
         {
            watermark.show();
         }
         this.addScreen();
      }
      
      override protected function onCueRangeChanged(param1:CueRangeEvent) : void
      {
         this.onCueRangeRemoved(param1);
         this.onCueRangeAdded(param1);
      }
      
      override protected function onAfterMediaEnd() : void
      {
         if(ytEnv.eventLabel == EventLabel.DETAIL_PAGE && ytEnv.playlist && ytEnv.playlist.hasNext())
         {
            this.isFullScreenNav = isFullScreen();
         }
         super.onAfterMediaEnd();
      }
      
      override protected function resizePlayer(param1:Number, param2:Number) : void
      {
         if(ytEnv.showControls && Boolean(this.controlsOffset))
         {
            param2 = this.height;
            param1 = this.width;
         }
         super.resizePlayer(param1,param2);
      }
      
      override protected function onAdPlay(param1:AdEvent) : void
      {
         this.playPauseButton.showPause();
         super.onAdPlay(param1);
         this.disableVideoControlsWithAdEvent(param1);
         if(!param1.data || !param1.data.nolog)
         {
            ytEnv.logCsi(videoData,new Date());
         }
      }
      
      protected function onGetWatchUrlAtTime(param1:ContextMenuEvent) : void
      {
         var _loc2_:String = ytEnv.getVideoWatchUrl(videoData);
         var _loc3_:* = "#t=" + Math.floor(currentProgressMediaTime) + "s";
         this.setClipboard(_loc2_ + _loc3_);
      }
      
      override protected function onAdPause(param1:AdEvent) : void
      {
         this.playPauseButton.showPlay();
      }
      
      override protected function onCueRangeAdded(param1:CueRangeEvent) : void
      {
         if(param1.cueRange.marker)
         {
            this.videoControls.addMarker(param1.cueRange.marker);
         }
      }
      
      override protected function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:Sprite = null;
         if(!shouldHandleKeyEvent(param1))
         {
            return;
         }
         this.mouseActivity.touch();
         this.onUserActivity();
         super.onKeyDown(param1);
         switch(param1.keyCode)
         {
            case Keyboard.SPACE:
               _loc2_ = stageAmbassador.focus as Sprite;
               if(!_loc2_ || !_loc2_.buttonMode)
               {
                  this.displayBezel();
               }
               break;
            case 179:
            case 178:
            case 75:
               this.displayBezel();
               break;
            case 176:
            case 110:
               ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.NEXT_CLICKED));
         }
         if(param1.keyCode == 191 && param1.shiftKey || param1.charCode == "?".charCodeAt(0))
         {
            if(this.activeDialog)
            {
               this.hideShortcutsDialog();
            }
            else
            {
               this.showShortcutsDialog();
            }
         }
      }
      
      protected function onEmbedCopy(param1:ContextMenuEvent) : void
      {
         this.setClipboard(getVideoEmbedCode());
      }
      
      protected function getAddToLinkHandler(param1:String, param2:ListId) : Function
      {
         var token:String = param1;
         var listId:ListId = param2;
         return function(param1:TextEvent):void
         {
            watchLaterButton.hideMenu();
            navigateToUrl(ytEnv.getAddToRequest(videoData,token,listId,true,param1.text),"_blank");
         };
      }
      
      protected function showControls(param1:Boolean = true) : void
      {
         var _loc4_:ModuleDescriptor = null;
         var _loc5_:int = 0;
         var _loc2_:int = param1 ? 100 : 0;
         if(this.videoControls.enabled && this.videoControls.allowSeeking)
         {
            this.videoControls.setLabel(VideoControls.DEFAULT,param1);
         }
         if(Boolean(this.viewportTween) && this.videoControls.visible)
         {
            _loc5_ = Boolean(this.controlsOffset) && param1 ? _loc2_ : 0;
            this.viewportTween.easeOut().to({"height":this.height - VideoControls.CONTROLS_HEIGHT},_loc5_);
         }
         var _loc3_:Array = moduleHost.getLoadedModulesByCapability(IOverlayCapability);
         for each(_loc4_ in _loc3_)
         {
            IOverlayCapability(_loc4_.instance).onVideoControlsShow();
         }
         Mouse.show();
         this.mouseActivity.touch();
      }
      
      protected function isStandardVideoSize(param1:int, param2:int) : Boolean
      {
         var _loc3_:Number = Math.abs(param1 - param2 * (16 / 9));
         var _loc4_:Number = Math.abs(param1 - param2 * (4 / 3));
         return Math.min(_loc3_,_loc4_) <= BaseVideoPlayer.FUDGE_PIXELS;
      }
      
      override public function initData() : void
      {
         layerManager.registerHandlers({
            "videoControls":this.setVideoControls,
            "autohide":this.setAutoHideOffset
         });
         layerManager.setLayer("autohide",{"autohide":ytEnv.autoHideControls});
         Theme.setActiveTheme(ytEnv.theme);
         Theme.setActiveInterfaceLanguage(ytEnv.interfaceLanguage);
         super.initData();
      }
      
      protected function hideActionBar() : void
      {
         if(!isFullScreen() && ytEnv.showInfoOnlyInFullScreen)
         {
            layout.remove(this.actionBar);
         }
      }
      
      protected function maskSprite(param1:Sprite, param2:Rectangle) : void
      {
         if(!param1 || !param1.mask && !param2)
         {
            return;
         }
         layout.remove(param1.mask);
         if(param2)
         {
            param1.mask = param1.mask || new Sprite();
            Drawing.invisibleRect(Sprite(param1.mask).graphics,param2.x,param2.y,param2.width,param2.height);
         }
         else
         {
            param1.mask = null;
         }
         layout.add(param1.mask);
      }
      
      override protected function seekVideo(param1:Number, param2:Boolean) : void
      {
         super.seekVideo(param1,param2);
         if(videoData.clipStart && param1 < videoData.clipStart || videoData.clipEnd && param1 > videoData.clipEnd)
         {
            this.onSeekClearClip();
         }
      }
      
      public function autoHideWithGutterModeAutomatically() : Number
      {
         if(isFullScreen())
         {
            return VideoControls.CONTROLS_HEIGHT;
         }
         if(nominalHeight <= 200 || this.isStandardVideoSize(nominalWidth,nominalHeight))
         {
            return VideoControls.CONTROLS_HEIGHT - 3;
         }
         return 0;
      }
      
      public function onVolumeChange(param1:VolumeEvent) : void
      {
         this.setVolume(param1.volume);
         if(focusManager.delegate != this)
         {
            focusManager.onVolumeChange(param1);
         }
         var _loc2_:Object = {"volume":param1.volume};
         ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.VOLUME_CHANGE,_loc2_));
      }
      
      protected function onLoginDialogSuccess(param1:Object) : void
      {
         videoData.subscriptionToken = param1.subscription_ajax;
         videoData.subscribe();
      }
      
      override protected function loadModule(param1:Class, param2:String) : ModuleDescriptor
      {
         var _loc3_:ModuleDescriptor = null;
         var _loc4_:ModuleButton = null;
         _loc3_ = super.loadModule(param1,param2);
         if(Boolean(_loc3_) && (_loc3_.iconActive || _loc3_.iconInactive))
         {
            _loc4_ = new ModuleButton(_loc3_,ytEnv.messages);
            _loc4_.addEventListener(MouseEvent.CLICK,this.onModuleButtonClick);
            this.moduleButtons.push(_loc4_);
            this.videoControls.modules.add(_loc4_);
         }
         return _loc3_;
      }
      
      public function hideShortcutsDialog(param1:Event = null) : void
      {
         this.shortcutsDialog.removeEventListener(Event.COMPLETE,this.hideShortcutsDialog);
         this.shortcutsDialog = null;
         this.setActiveDialog(null);
      }
      
      override protected function onVideoDataChange(param1:VideoDataEvent) : void
      {
         super.onVideoDataChange(param1);
         if(!(state is UnbuiltAppState))
         {
            this.timeDisplay.duration = videoPlayer.getDuration();
            this.timeDisplay.durationVisible = !videoData.isLive;
            this.timeDisplay.enabled = videoData.isSeekEnabled();
            this.timeDisplay.isLive = videoData.isLive;
            this.timeDisplay.timeVisible = !videoData.isLive || videoData.isSeekEnabled();
            this.videoControls.duration = videoPlayer.getDuration();
            this.videoControls.enabled = videoData.isSeekEnabled();
            this.videoControls.isLive = videoData.isLive;
            if(param1.source == VideoDataEvent.NEW_VIDEO_DATA || param1.source == VideoDataEvent.VIDEO_INFO || param1.source == VideoDataEvent.FORMAT_DISABLED)
            {
               this.updateVideoQualityButton();
               this.videoControls.videoData = videoData;
               layout.remove(this.filmstrip);
               this.filmstrip = null;
               if(param1.videoData.mosaicLoader)
               {
                  this.framePreview = new VideoStoryboardThumbnail(param1.videoData.mosaicLoader);
                  this.framePreview.brightness = 0.4;
                  this.filmstrip = new Filmstrip(param1.videoData.mosaicLoader);
               }
               this.updateAudioTrackButton();
            }
            this.updateNextButton();
            if(videoData.canWatchLater && Boolean(this.watchLaterButton))
            {
               this.videoControls.secondary.add(this.watchLaterButton);
               if(param1.source == VideoDataEvent.NEW_VIDEO_DATA)
               {
                  this.watchLaterButton.reset();
               }
            }
            else
            {
               this.videoControls.secondary.remove(this.watchLaterButton);
            }
            if(ytEnv.autoHideControls != YouTubeEnvironment.AUTO_HIDE_OFF)
            {
               this.updateAutoHideControls();
            }
            this.volumeControlButton.setValue(getVolume());
            this.volumeControlButton.mouseEnabled = !videoData.infringe;
         }
         if(this.actionBar)
         {
            this.actionBar.videoData = videoData;
            this.actionBar.metadataRequest = ytEnv.getVideoMetadataRequest(videoData);
         }
         this.updateContextMenu();
         if(cueRangeManager)
         {
            this.setupEndScreen();
         }
      }
      
      override protected function onPlaylistOrderChanged(param1:Event) : void
      {
         super.onPlaylistOrderChanged(param1);
         this.updateNextButton();
      }
      
      protected function onMouseIdle(param1:MouseActivityEvent) : void
      {
         var _loc2_:* = videoPlayer.getPlayerState() is IPausedState;
         var _loc3_:Boolean = this.videoControls.mouseOver || ytEnv.autoHideControls == YouTubeEnvironment.AUTO_HIDE_OFF || _loc2_;
         if(!_loc3_ || isFullScreen())
         {
            this.hideControls();
         }
         if(Boolean(this.actionBar) && !_loc2_)
         {
            this.actionBar.tween.easeIn().to({"y":-this.actionBar.height},500);
         }
         if(Boolean(watermark) && !videoData.isPartnerWatermark)
         {
            watermark.hide();
         }
         layout.remove(this.screen);
      }
      
      protected function updateVideoQualityButton() : void
      {
         var _loc2_:VideoQuality = null;
         if(!ytEnv.enableQualityMenu || videoPlayer is PlayerAdapter)
         {
            this.videoControls.modules.remove(this.settingsButton);
            return;
         }
         this.settingsButton.clear();
         this.settingsButton.addSpeeds(getAvailablePlaybackRates());
         this.settingsButton.setSpeed(1);
         this.settingsButton.add("auto");
         var _loc1_:Array = getAvailableQualityLevels();
         if(_loc1_.length > 0 && this.height > VideoControls.CONTROLS_HEIGHT * 2)
         {
            this.settingsButton.add.apply(null,_loc1_);
            this.videoControls.modules.add(this.settingsButton);
            for each(_loc2_ in _loc1_)
            {
               if(videoData.getFormatForQuality(_loc2_).quality != _loc2_)
               {
                  this.settingsButton.disableQuality(_loc2_.toString());
               }
            }
         }
         else
         {
            this.videoControls.modules.remove(this.settingsButton);
         }
         this.settingsButton.showBubble = videoData.accountPlaybackToken != null;
         this.settingsButton.setAuto(ytEnv.autoQuality);
      }
      
      protected function updateVideoInfo(param1:Event = null) : void
      {
         var _loc2_:Object = this.getLoggingOptions();
         var _loc3_:Object = {
            "timestamp":videoPlayer.getTime().toFixed(3),
            "videoWidth":videoPlayer.getVideoRect().width,
            "videoHeight":videoPlayer.getVideoRect().height,
            "videoBitrate":Math.round(videoData.videoBitrate),
            "videoBuffers":videoPlayer.getBuffers(),
            "videoFps":Math.round(videoPlayer.getFPS()),
            "volume":Math.round(getVolume()),
            "duration":videoPlayer.getDuration(),
            "rendering":_loc2_.rendering,
            "decoding":(_loc2_.decoding == "unavailable" ? "software (hardware unavailable)" : _loc2_.decoding),
            "playerType":String(videoPlayer).substring(8,String(videoPlayer).length - 1),
            "streamType":(videoData.isTransportRtmp() ? "RTMP" : "HTTP"),
            "streamBitrate":Math.round(this.calculateBitrate() / 1000),
            "stageFps":stageAmbassador.frameRate,
            "droppedFrames":_loc2_.nsidf || 0,
            "playBitrate":Math.round(_loc2_.nsipbps * 8 / 1000) || 0,
            "loudness":videoData.perceptualLoudnessDb.toFixed(3),
            "muffled":videoData.muffleFactor
         };
         this.videoInfoWindow.updateVideoInfo(_loc3_);
      }
      
      protected function onHideVideoInfo(param1:Event = null) : void
      {
         layout.remove(this.videoInfoWindow);
         this.videoInfoUpdateInterval.stop();
      }
      
      protected function onTimelineData(param1:Event) : void
      {
         this.loadModule(StreamingTextModuleDescriptor,videoData.streamingTextModule);
         videoData.timelineData.removeEventListener(Event.ADDED,this.onTimelineData);
      }
      
      override protected function onVideoClick(param1:MouseEvent) : void
      {
         if(videoPlayer.getPlayerState() is BaseAdPlayerState)
         {
            this.loggingOptions.aclk = 1;
         }
      }
      
      protected function onQualityPlaybackBegin(param1:String) : void
      {
         if(this.settingsButton)
         {
            this.settingsButton.showLoaded();
            this.settingsButton.setQualityLabel(param1);
            this.settingsButton.setAuto(ytEnv.autoQuality);
         }
         if(this.audioTrackButton)
         {
            this.audioTrackButton.showLoaded();
         }
      }
      
      protected function setVideoControls(param1:VideoControls) : void
      {
         if(!param1)
         {
            this.hideControls(false);
            this.videoControls.visible = false;
            this.videoControls.enabled = false;
            this.onResize();
            return;
         }
         if(param1 != this.videoControls && ytEnv.showControls)
         {
            this.maskSprite(this.videoControls,null);
            layout.remove(this.videoControls);
            layout.add(param1);
            this.maskSprite(param1,this.insetControlsMask);
         }
         this.videoControls = param1;
         this.videoControls.visible = true;
         this.videoControls.enabled = videoData.isSeekEnabled();
      }
      
      override public function init() : void
      {
         environment = new YouTubeEnvironment(context,EventLabel.DETAIL_PAGE);
         nominalHeight += VideoControls.CONTROLS_HEIGHT;
         super.init();
      }
      
      private function removeOnTweenEnd(param1:TweenEvent) : void
      {
         var _loc2_:DisplayObject = param1.target.target as DisplayObject;
         if(_loc2_)
         {
            layout.remove(_loc2_);
         }
      }
      
      protected function onActionBarExpand(param1:ActionBarEvent) : void
      {
         if(videoPlayer.getPlayerState() is IPlayingState)
         {
            this.actionBarPausedVideo = true;
            pauseVideo();
         }
      }
      
      public function onScreenClick(param1:MouseEvent) : void
      {
         if(ytEnv.gestures)
         {
            togglePause();
            this.displayBezel();
         }
      }
      
      protected function updateContextMenu() : void
      {
         var menu:ContextMenu = null;
         var menuItem:ContextMenuItem = null;
         try
         {
            menu = new ContextMenu();
            menu.hideBuiltInItems();
            menu.customItems = [];
            if(ytEnv.isYouTubePlayer)
            {
               menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.COPY_VIDEO_URL));
               menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.onGetWatchUrl);
               menu.customItems.push(menuItem);
               menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.COPY_VIDEO_URL_AT_TIME));
               menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.onGetWatchUrlAtTime);
               menu.customItems.push(menuItem);
            }
            if(ytEnv.showPopout)
            {
               menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.POPOUT));
               menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.onPopout);
               menu.customItems.push(menuItem);
            }
            if(ytEnv.isYouTubePlayer && videoData && videoData.allowEmbed)
            {
               menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.EMBED_COPY));
               menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.onEmbedCopy);
               menu.customItems.push(menuItem);
            }
            menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.REPORT_ISSUE));
            menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.onReportIssue);
            menu.customItems.push(menuItem);
            menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.SPEED_TEST));
            menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.onSpeedTest);
            menu.customItems.push(menuItem);
            menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.STOP_DOWNLOAD));
            menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.onMenuStopDownload);
            menu.customItems.push(menuItem);
            menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.SHOW_VIDEO_INFO));
            menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.onShowVideoInfo);
            menu.customItems.push(menuItem);
            menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.COPY_DEBUG_INFO));
            menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.onCopyDebugInfo);
            menu.customItems.push(menuItem);
            if(ytEnv.showReportAbuse)
            {
               menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.REPORT_ABUSE));
               menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.onReportAbuse);
               menu.customItems.push(menuItem);
            }
            if(ytEnv.isYouTubeEmbedPlayer)
            {
               menuItem = new ContextMenuItem(ytEnv.messages.getMessage(WatchMessages.HOSTED_BY),false,false);
               menuItem.separatorBefore = true;
               menu.customItems.push(menuItem);
            }
            ytEnv.contextMenuItems = menu.customItems;
            contextMenu = menu;
         }
         catch(e:ReferenceError)
         {
         }
      }
      
      override protected function addCallbacks() : void
      {
         try
         {
            environment.addCallback("onLoginDialogSuccess",this.onLoginDialogSuccess);
            environment.addCallback("showVideoInfo",this.onShowVideoInfo);
            environment.addCallback("hideVideoInfo",this.onHideVideoInfo);
            environment.addCallback("startAutoHideControls",function():void
            {
            });
            environment.addCallback("stopAutoHideControls",function():void
            {
            });
            if(ytEnv.isAdPlayback)
            {
               environment.addCallback("setCustomUiOverlay",this.setCustomUiOverlay);
               environment.addCallback("enableSeekBar",this.enableSeekBar);
               environment.addCallback("disableSeekBar",this.disableSeekBar);
            }
            environment.addCallback("getVideoAspectRatio",this.onGetVideoAspectRatio);
         }
         catch(error:SecurityError)
         {
         }
         super.addCallbacks();
      }
      
      protected function calculateBitrate() : Number
      {
         var _loc1_:Number = getSmoothedBandwidth() * 8;
         if(_loc1_)
         {
            return _loc1_;
         }
         var _loc2_:Number = getBytesLoaded();
         var _loc3_:Date = new Date();
         if(_loc2_ == getBytesTotal() || videoPlayer is IVideoAdEventProvider)
         {
            return -1;
         }
         if(!this.prevTime)
         {
            return -1;
         }
         var _loc4_:Number = (_loc3_.valueOf() - this.prevTime.valueOf()) / 1000;
         var _loc5_:Number = _loc2_ - this.prevBytes;
         _loc1_ = _loc5_ * 8 / _loc4_;
         if(_loc1_ != 0)
         {
            this.prevTime = _loc3_;
            this.prevBytes = _loc2_;
         }
         if(isNaN(_loc1_))
         {
            return -1;
         }
         return _loc1_;
      }
      
      protected function setupEndScreen() : void
      {
         var _loc1_:Number = NaN;
         if(ytEnv.showEndScreen && videoData.duration > 0)
         {
            _loc1_ = Math.max(0,(videoData.clipEnd || videoData.duration) - 30);
            if(this.endScreenCueRange)
            {
               this.endScreenCueRange.removeEventListener(CueRangeEvent.ENTER,this.onLoadEndScreen);
            }
            cueRangeManager.removeCueRange(this.endScreenCueRange);
            this.endScreenCueRange = new CueRange(new TimeRange(_loc1_ * 1000,CueRange.AFTER_MEDIA_END));
            this.endScreenCueRange.addEventListener(CueRangeEvent.ENTER,this.onLoadEndScreen);
            cueRangeManager.addCueRange(this.endScreenCueRange);
         }
      }
      
      protected function onAddedToWatchLaterComplete(param1:Event) : void
      {
         var _loc3_:* = false;
         this.watchLaterButton.hideMenu();
         this.watchLaterButton.enabled = true;
         var _loc2_:XML = XML(param1.target.data);
         if(_loc2_.return_code == YouTubeEnvironment.AJAX_SUCCESS || _loc2_.return_code == YouTubeEnvironment.AJAX_DUPLICATE)
         {
            _loc3_ = _loc2_.list_id != "None";
            this.watchLaterButton.setLabel(_loc3_ ? "complete" : "default");
            if(String(_loc2_.html_content).length)
            {
               this.watchLaterButton.tooltipText = _loc2_.html_content;
            }
            else if(String(_loc2_.error_message).length)
            {
               this.watchLaterButton.tooltipText = _loc2_.error_message;
            }
            else
            {
               this.watchLaterButton.tooltipMessage = WatchMessages.WATCH_LATER;
            }
            ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.WATCH_LATER,videoData.videoId));
         }
         else
         {
            this.watchLaterButton.setLabel("error");
            this.watchLaterButton.setMenuMessage(_loc2_.error_message);
         }
      }
      
      override protected function onPlaylistComplete(param1:Event = null) : void
      {
         super.onPlaylistComplete(param1);
         this.loadModule(PlaylistModuleDescriptor,ytEnv.playlistModule);
         this.updateNextButton();
      }
      
      public function autoHideCompletelyMode() : Number
      {
         return VideoControls.CONTROLS_HEIGHT;
      }
      
      override public function get height() : Number
      {
         return nominalHeight - this.controlsInset.top - this.controlsInset.bottom;
      }
      
      protected function onAddToWatchLater(param1:Event) : void
      {
         var loader:RequestLoader;
         var listId:ListId = null;
         var inList:Boolean = false;
         var event:Event = param1;
         if(!this.watchLaterButton.enabled || !videoData.isDataValid())
         {
            return;
         }
         listId = new ListId(ListId.WATCH_LATER_LIST);
         inList = this.watchLaterButton.getLabel() == "complete";
         this.watchLaterButton.enabled = false;
         this.watchLaterButton.setLabel("loading");
         this.watchLaterButton.hideMenu();
         loader = new RequestLoader();
         loader.addEventListener(Event.COMPLETE,function(param1:Event):void
         {
            var _loc2_:URLRequest = null;
            var _loc3_:RequestLoader = null;
            if(tokenRequestComplete(param1.target.data,listId))
            {
               _loc2_ = ytEnv.getAddToRequest(videoData,param1.target.data.addto_ajax_token,listId,!inList);
               _loc3_ = new RequestLoader();
               _loc3_.addEventListener(Event.COMPLETE,onAddedToWatchLaterComplete);
               _loc3_.loadRequest(_loc2_);
            }
         });
         loader.loadRequest(ytEnv.getAddToTokenAjaxRequest(listId,videoData.videoId),URLLoaderDataFormat.VARIABLES);
      }
      
      public function onLoadEndScreen(param1:CueRangeEvent) : void
      {
         this.loadModule(EndScreenModuleDescriptor,videoData.endscreenModule);
      }
      
      override public function getLoggingOptions() : Object
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         _loc1_ = super.getLoggingOptions();
         if(ytEnv.eventLabel == EventLabel.DETAIL_PAGE)
         {
            _loc1_.lact = ytEnv.callExternal("yt.www.watch.activity.getTimeSinceActive");
         }
         if(this.getAutoHideOffset())
         {
            _loc1_.ahoffset = this.getAutoHideOffset();
         }
         for(_loc2_ in this.loggingOptions)
         {
            _loc1_[_loc2_] = this.loggingOptions[_loc2_];
         }
         this.loggingOptions = {};
         return _loc1_;
      }
      
      override public function onEndScreenExit(param1:CueRangeEvent) : void
      {
         this.hideAppEndScreen();
         super.onEndScreenExit(param1);
      }
      
      protected function onModuleButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:ModuleDescriptor = param1.target.module;
         if(_loc2_.status == ModuleStatus.UNLOADED || _loc2_.status == ModuleStatus.ERROR)
         {
            moduleHost.load(_loc2_,true);
         }
         else
         {
            if(!param1.cancelable)
            {
               param1 = new MouseEvent(param1.type,param1.bubbles,true,param1.localX,param1.localY,param1.relatedObject,param1.ctrlKey,param1.altKey,param1.shiftKey,param1.buttonDown,param1.delta);
            }
            if(_loc2_.instance)
            {
               _loc2_.instance.onUnload(param1);
            }
            if(!param1.isDefaultPrevented())
            {
               moduleHost.unload(_loc2_,true);
            }
         }
      }
      
      public function onSeekComplete(param1:SeekEvent) : void
      {
         var _loc2_:Boolean = this.seekingState is IBufferingState && !(this.seekingState is IPausedState);
         var _loc3_:Boolean = this.seekingState is IPlayingState || _loc2_ || param1.time == Infinity;
         this.seekingState = null;
         cueRangeManager.allowExclusiveLock = true;
         this.seekVideo(param1.time,true);
         if(_loc3_)
         {
            playVideo();
         }
         this.hideFramePreviews();
      }
      
      public function setClipboard(param1:String) : void
      {
         var value:String = param1;
         try
         {
            System.setClipboard(value);
         }
         catch(error:Error)
         {
         }
      }
      
      override protected function selectPlaylistClip(param1:VideoData, param2:Boolean = false) : void
      {
         var destination:URLRequest = null;
         var selectedVideoData:VideoData = param1;
         var newWindow:Boolean = param2;
         if(!selectedVideoData)
         {
            return;
         }
         if(selectedVideoData == videoData)
         {
            this.seekVideo(0,true);
         }
         else if(!isFullScreen() && ytEnv.eventLabel == EventLabel.DETAIL_PAGE && selectedVideoData.featureType != MultiCameraModuleDescriptor.ID)
         {
            try
            {
               destination = ytEnv.getVideoWatchRequest(selectedVideoData);
               destination.data.NR = "1";
               delete destination.data.feature;
               if(selectedVideoData.featureType)
               {
                  destination.data.feature = selectedVideoData.featureType;
               }
               navigateToUrl(destination,newWindow ? "_blank" : "_self");
            }
            catch(error:SecurityError)
            {
            }
         }
         else
         {
            if(isFullScreen())
            {
               this.isFullScreenNav = true;
            }
            prepareVideo(selectedVideoData);
            playVideo();
         }
      }
      
      protected function openLoginDialog(param1:SubscriptionEvent) : void
      {
         ytEnv.callExternal("yt.embed.openLoginDialog");
      }
      
      override public function getDebugText(param1:Boolean = false) : String
      {
         var _loc2_:URLVariables = new URLVariables();
         var _loc3_:RequestVariables = ytEnv.getErrorLoggingRequestVariables();
         if(_loc3_.cl)
         {
            _loc2_.cl = _loc3_.cl;
         }
         if(_loc3_.ts)
         {
            _loc2_.ts = _loc3_.ts;
         }
         if(param1 && this.errorDisplay && Boolean(this.errorDisplay.errorStack))
         {
            _loc2_.stacktrace = this.errorDisplay.errorStack;
         }
         return _loc2_.toString() + "&" + super.getDebugText(param1);
      }
      
      public function onVolumeUnmute(param1:VolumeEvent) : void
      {
         this.unMute();
         if(focusManager.delegate != this)
         {
            focusManager.onVolumeUnmute(param1);
         }
         var _loc2_:Object = {"muted":false};
         ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.VOLUME_CHANGE,_loc2_));
      }
      
      protected function setActiveDialog(param1:Dialog) : void
      {
         if(this.activeDialog)
         {
            layout.remove(this.activeDialog);
         }
         if(param1)
         {
            layout.add(param1);
         }
         this.activeDialog = param1;
      }
      
      public function onNext(param1:Event) : void
      {
         if(ytEnv.playlist)
         {
            this.selectPlaylistClip(ytEnv.playlist.getNext());
         }
         else
         {
            ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.NEXT_CLICKED));
         }
      }
      
      override protected function onResize(param1:Event = null) : void
      {
         if(Boolean(param1) && param1.eventPhase != EventPhase.AT_TARGET)
         {
            return;
         }
         super.onResize(param1);
         setPlaybackFormat(formatSelector.getVideoFormat(FormatSelectionRecord.RESIZE));
      }
      
      public function enableSeekBar() : void
      {
         this.videoControls.allowSeeking = true;
         this.videoControls.enabled = true;
      }
      
      override protected function likePlaylistClip(param1:ActionBarEvent) : void
      {
         var _loc2_:Number = param1.type == ActionBarEvent.LIKE ? YouTubeEnvironment.LIKE_SENTIMENT : YouTubeEnvironment.DISLIKE_SENTIMENT;
         new RequestLoader().loadRequest(ytEnv.getSentimentRequest(param1.videoData,_loc2_));
         ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.RATE_SENTIMENT,_loc2_));
      }
      
      override protected function displayApplicationError(param1:String, param2:Number) : void
      {
         if(!this.errorDisplay)
         {
            this.errorDisplay = new ErrorDisplay();
         }
         layout.add(this.errorDisplay);
         this.errorDisplay.setMessage(param1,ytEnv.messages.getMessage(param1) ? ytEnv.messages : null);
         super.displayApplicationError(param1,param2);
      }
      
      protected function showActionBar() : void
      {
         if(isFullScreen() || !ytEnv.showInfoOnlyInFullScreen)
         {
            layout.add(this.actionBar);
         }
      }
      
      public function onSettingsClick(param1:Event) : void
      {
         var _loc2_:ModuleDescriptor = null;
         for each(_loc2_ in moduleHost.getModules())
         {
            _loc2_.advancedButton = false;
         }
      }
      
      override protected function startApplication() : void
      {
         if(!ytEnv.hosted)
         {
            Scheduler.setFrameRateOf(stageAmbassador);
         }
         var _loc1_:Object = ytEnv.getSharedObject(RESTORE_SO_KEY,videoData.videoId);
         if(_loc1_)
         {
            if(_loc1_.time)
            {
               videoData.startSeconds = _loc1_.time;
            }
            if(_loc1_.share)
            {
               ytEnv.callExternal("shareVideoFromFlash");
            }
            ytEnv.setSharedObject(RESTORE_SO_KEY);
         }
         if(ytEnv.isEmbedded)
         {
            this.loadModules();
         }
         var _loc2_:String = ytEnv.getVideoUrl(videoData);
         videoData.videoUrl = _loc2_;
         super.startApplication();
         if(!(state is PendingUserInputAppState))
         {
            ytEnv.applyTimingArgs({"gv":new Date().valueOf()});
            this.firstBytePollScheduler = Scheduler.setInterval(0,this.pollForFirstByte);
         }
         this.updateAutoHideControls();
      }
      
      override protected function unloadModules() : void
      {
         var _loc2_:ModuleButton = null;
         super.unloadModules();
         var _loc1_:Array = [];
         for each(_loc2_ in this.moduleButtons)
         {
            if(_loc2_.module.shouldUnload())
            {
               _loc2_.removeEventListener(MouseEvent.CLICK,this.onModuleButtonClick);
               this.videoControls.modules.remove(_loc2_);
            }
            else
            {
               _loc1_.push(_loc2_);
            }
         }
         this.moduleButtons = _loc1_;
      }
      
      protected function updateAudioTrackButton() : void
      {
         var _loc1_:Array = videoData.getAudioTracks();
         if(_loc1_.length > 1)
         {
            this.showAudioTrackButton();
            this.audioTrackButton.setTracks(_loc1_);
            if(videoData.audioTrack)
            {
               this.audioTrackButton.currentTrack = videoData.audioTrack;
            }
         }
         else
         {
            this.hideAudioTrackButton();
         }
      }
      
      protected function onUserActivity(param1:Event = null) : void
      {
         if(ytEnv.eventLabel == EventLabel.DETAIL_PAGE)
         {
            ytEnv.callExternal("yt.www.watch.activity.setTimestamp");
         }
      }
      
      protected function onReportAbuse(param1:ContextMenuEvent) : void
      {
         var event:ContextMenuEvent = param1;
         var request:URLRequest = ytEnv.getReportAbuseRequest();
         try
         {
            navigateToUrl(request);
         }
         catch(error:SecurityError)
         {
         }
         pauseVideo();
      }
      
      override protected function onSpliceComplete(param1:SpliceEvent) : void
      {
         this.onQualityPlaybackBegin(videoData.format.quality.toString());
         super.onSpliceComplete(param1);
      }
      
      protected function onFilmstripDelay(param1:Event) : void
      {
         layout.add(this.filmstrip);
         this.filmstrip.tween.removeEventListener(TweenEvent.END,this.removeOnTweenEnd);
         this.filmstrip.tween.fadeOut(0).fadeIn(200);
         if(videoPlayer.isTagStreaming())
         {
            layout.add(this.framePreview);
            this.framePreview.tween.removeEventListener(TweenEvent.END,this.removeOnTweenEnd);
            this.framePreview.tween.fadeOut(0).fadeIn(100);
         }
      }
      
      public function onSeekRequest(param1:SeekEvent) : void
      {
         if(videoPlayer is PlayerAdapter || videoData.isTransportRtmp() || videoPlayer is AkamaiHDLiveVideoPlayer)
         {
            return;
         }
         this.seekingTime = param1.time;
         if(this.filmstrip)
         {
            if(videoPlayer.isCached(param1.time))
            {
               this.hideFramePreviews();
            }
            else
            {
               this.showFramePreviews();
            }
            this.filmstrip.time = param1.time;
            this.framePreview.time = param1.time;
         }
         this.seekVideo(param1.time,false);
      }
      
      public function onVolumeMute(param1:VolumeEvent) : void
      {
         this.mute();
         if(focusManager.delegate != this)
         {
            focusManager.onVolumeMute(param1);
         }
         var _loc2_:Object = {"muted":true};
         ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.VOLUME_CHANGE,_loc2_));
      }
      
      override protected function enableVideoControls() : void
      {
         this.playPauseButton.enabled = true;
         if(this.youTubeButton)
         {
            this.youTubeButton.addEventListener(MouseEvent.CLICK,this.navigateToYouTube);
            this.youTubeButton.enabled = true;
         }
         if(this.nextButton)
         {
            this.nextButton.enabled = true;
         }
         this.volumeControlButton.enabled = true;
         if(this.audioTrackButton)
         {
            this.audioTrackButton.enabled = true;
         }
         if(this.fullScreenButton)
         {
            this.fullScreenButton.enabled = stageAmbassador.fullScreenAllowed;
         }
         this.videoControls.enabled = videoData.isSeekEnabled();
         this.timeDisplay.enabled = videoData.isSeekEnabled();
         this.showControls();
         super.enableVideoControls();
         this.updateAutoHideControls();
      }
      
      protected function showAppEndScreen() : void
      {
         this.showControls();
         if(ytEnv.showEndScreen)
         {
            if(!ytEnv.showRelatedVideos || !videoData.suggestions.length)
            {
               setPlayButtonVisibility(true);
               this.setStillVisibility(true);
               layout.remove(this.endScreen);
            }
            else
            {
               layout.add(this.endScreen);
            }
         }
      }
      
      public function onSeekStart(param1:SeekEvent) : void
      {
         cueRangeManager.allowExclusiveLock = false;
         this.seekingState = videoPlayer.getPlayerState();
         this.seekingTime = param1.time;
         this.onSeekRequest(param1);
         if(videoPlayer is AkamaiHDLiveVideoPlayer)
         {
            return;
         }
         pauseVideo();
      }
      
      protected function onShowVideoInfo(param1:Event = null) : void
      {
         if(!this.videoInfoWindow)
         {
            this.videoInfoWindow = new VideoInfoWindow(ytEnv.messages);
            this.videoInfoWindow.x = 10;
            this.videoInfoWindow.y = 10;
            this.videoInfoWindow.addEventListener(Event.CLOSE,this.onHideVideoInfo);
            this.videoInfoUpdateInterval = Scheduler.setInterval(500,this.updateVideoInfo);
         }
         else
         {
            this.videoInfoUpdateInterval.restart();
         }
         layout.add(this.videoInfoWindow);
         this.updateVideoInfo();
      }
      
      protected function onMenuStopDownload(param1:ContextMenuEvent) : void
      {
         stopVideo();
      }
      
      protected function updateNextButton() : void
      {
         if(ytEnv.showNextButton)
         {
            if(!this.nextButton)
            {
               this.nextButton = new NextButton(ytEnv.messages);
               this.nextButton.addEventListener(MouseEvent.CLICK,focusManager.onNext);
            }
            this.videoControls.primary.add(this.nextButton);
         }
         else
         {
            this.videoControls.primary.remove(this.nextButton);
         }
      }
      
      protected function tokenRequestComplete(param1:Object, param2:ListId = null) : Boolean
      {
         if(param1.status != "200" && Boolean(param1.message))
         {
            this.watchLaterButton.setLabel("error");
            this.watchLaterButton.setMenuMessage(param1.message);
            this.watchLaterButton.enabled = true;
            this.watchLaterButton.addEventListener(TextEvent.LINK,this.getAddToLinkHandler(param1.addto_ajax_token,param2));
            return false;
         }
         return true;
      }
      
      override public function onEndScreenEnter(param1:CueRangeEvent) : void
      {
         this.showAppEndScreen();
         super.onEndScreenEnter(param1);
      }
      
      private function onSeekbarTweenUpdate(param1:TweenEvent) : void
      {
         if(this.videoControls.visible)
         {
            this.resizeModule(viewportRect.clone(),viewportRect);
         }
      }
      
      protected function onViewportChange(param1:TweenEvent) : void
      {
         this.resizeModule(viewportRect.clone(),viewportRect);
         layout.realign();
      }
      
      override public function loadModules() : void
      {
         super.loadModules();
         this.loadModule(AkamaiHdModuleDescriptor,videoData.akamaiHdModule);
         this.loadModule(EnhanceModuleDescriptor,videoData.enhanceModule);
         this.loadModule(IvModuleDescriptor,videoData.ivModule);
         this.loadModule(MultiCameraModuleDescriptor,videoData.multiCameraModule);
         this.loadModule(RegionModuleDescriptor,videoData.regionModule);
         this.loadModule(SubtitlesModuleDescriptor,videoData.subtitlesModule);
         this.loadModule(YvaModuleDescriptor,videoData.yvaModule);
         if(Boolean(ytEnv.playlist) && ytEnv.isEmbedded)
         {
            this.loadModule(PlaylistModuleDescriptor,ytEnv.playlistModule);
         }
      }
      
      override protected function onFullScreenEvent(param1:FullScreenEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         super.onFullScreenEvent(param1);
         this.updateAutoHideControls();
         if(isFullScreen())
         {
            if(Boolean(watermark) && !videoData.isPartnerWatermark)
            {
               watermark.hide();
            }
            if(this.fullScreenButton)
            {
               this.fullScreenButton.showNormal();
            }
            if(this.smallerSizeButton)
            {
               this.smallerSizeButton.showLarge();
               this.biggerSizeButton.showSmall();
            }
            this.loadModule(PlaylistModuleDescriptor,ytEnv.playlistModule);
            this.showActionBar();
         }
         else
         {
            if(watermark)
            {
               watermark.show();
            }
            _loc2_ = videoData.videoId;
            if(this.isFullScreenNav)
            {
               _loc3_ = ytEnv.getSharedObject(RESTORE_SO_KEY,_loc2_) || {};
               _loc3_.time = videoPlayer.getTime();
               ytEnv.setSharedObject(RESTORE_SO_KEY,_loc2_,_loc3_);
            }
            if(this.fullScreenButton)
            {
               this.fullScreenButton.showFullScreen();
            }
            if(this.smallerSizeButton)
            {
               if(ytEnv.playerWide)
               {
                  this.smallerSizeButton.showLarge();
                  this.biggerSizeButton.showLarge();
               }
               else
               {
                  this.smallerSizeButton.showSmall();
                  this.biggerSizeButton.showSmall();
               }
            }
            if(ytEnv.eventLabel == EventLabel.DETAIL_PAGE)
            {
               ytEnv.callExternal("checkCurrentVideo",_loc2_);
            }
            this.hideActionBar();
         }
      }
      
      protected function showAudioTrackButton() : void
      {
         if(!this.audioTrackButton)
         {
            this.audioTrackButton = new AudioTrackButton(ytEnv.messages);
            this.audioTrackButton.addEventListener(AudioTrackChangeEvent.CHANGE,this.onAudioTrackSelect);
            this.audioTrackButton.enabled = this.volumeControlButton.enabled;
         }
         this.videoControls.audioTrack.add(this.audioTrackButton);
      }
      
      override public function get width() : Number
      {
         return nominalWidth - this.controlsInset.top - this.controlsInset.bottom;
      }
      
      override protected function sharePlaylistClip(param1:Event = null) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         pauseVideo();
         if(this.isFullScreenNav)
         {
            _loc2_ = videoData.videoId;
            _loc3_ = ytEnv.getSharedObject(RESTORE_SO_KEY,_loc2_) || {};
            _loc3_.share = 1;
            ytEnv.setSharedObject(RESTORE_SO_KEY,_loc2_,_loc3_);
         }
         else if(ytEnv.isIframeEmbed || ytEnv.eventLabel == EventLabel.DETAIL_PAGE)
         {
            ytEnv.broadcastExternal(new ExternalEvent(ExternalEvent.SHARE_CLICKED,{
               "videoId":videoData.videoId,
               "feature":"player_" + ytEnv.eventLabel
            }));
         }
         else
         {
            ytEnv.popupShareWindow(videoData);
         }
         if(isFullScreen())
         {
            this.toggleFullScreen();
         }
      }
      
      override protected function onAdMetaData(param1:AdEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:SeekBarMarker = null;
         if(param1.target is IVideoAdEventProvider)
         {
            _loc2_ = IVideoAdEventProvider(param1.target).getAdTimes();
            _loc3_ = int(_loc2_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = int(_loc2_[_loc4_]);
               _loc6_ = new SeekBarMarker(_loc5_,_loc5_);
               this.videoControls.addMarker(_loc6_);
               _loc4_++;
            }
         }
      }
      
      protected function onPlaybackRateSelected(param1:PlaybackRateEvent) : void
      {
         var _loc2_:RequestVariables = new RequestVariables();
         _loc2_.rate = param1.playbackRate;
         onLog(new LogEvent(LogEvent.LOG,"rate_selected",_loc2_));
         videoPlayer.playbackRate = param1.playbackRate;
      }
      
      override protected function navigateToYouTube(param1:Event = null) : void
      {
         if(ytEnv.eventLabel == EventLabel.DETAIL_PAGE && isFullScreen())
         {
            this.toggleFullScreen();
         }
         else
         {
            super.navigateToYouTube(param1);
         }
      }
      
      public function showShortcutsDialog() : void
      {
         var _loc1_:Boolean = Boolean(ytEnv.playlist) && (Boolean(ytEnv.playlist.listId) || Boolean(ytEnv.playlist.length));
         this.shortcutsDialog = new ShortcutsDialog(ytEnv.messages,_loc1_);
         this.shortcutsDialog.addEventListener(Event.COMPLETE,this.hideShortcutsDialog);
         this.setActiveDialog(this.shortcutsDialog);
      }
      
      public function autoHideFullScreenOnlyMode() : Number
      {
         return isFullScreen() ? VideoControls.CONTROLS_HEIGHT : 0;
      }
      
      override protected function onAdBreakEnd(param1:AdEvent) : void
      {
         super.onAdBreakEnd(param1);
         layerManager.clearLayer("adbreak");
         if(this.screen)
         {
            this.screen.mouseEnabled = true;
            this.screen.doubleClickEnabled = true;
         }
      }
      
      protected function displayBezel() : void
      {
         if(!(videoPlayer.getPlayerState() is IPausedState))
         {
            this.bezel.play(Bezel.PLAY);
         }
         else if(videoData.isPauseEnabled)
         {
            this.bezel.play(Bezel.PAUSE);
         }
         else
         {
            this.bezel.play(Bezel.STOP);
         }
      }
      
      override protected function onSpliceStart(param1:SpliceEvent) : void
      {
         if(this.spliceStartTrigger is QualityChangeEvent)
         {
            if(Boolean(this.settingsButton) && !ytEnv.autoQuality)
            {
               this.settingsButton.showLoading();
            }
         }
         else if(this.spliceStartTrigger is AudioTrackChangeEvent)
         {
            if(this.audioTrackButton)
            {
               this.audioTrackButton.showLoading();
            }
         }
      }
      
      public function setCustomUiOverlay(param1:DisplayObject) : void
      {
         this.uiOverlay.child = param1;
         layout.add(this.uiOverlay);
         this.videoControls.visibleControls = false;
         this.videoControls.setLabel(VideoControls.FADE,false);
      }
      
      public function onQualitySettingsChange(param1:QualityChangeEvent) : void
      {
         var _loc2_:URLRequest = null;
         var _loc3_:RequestLoader = null;
         if(videoData.accountPlaybackToken)
         {
            _loc2_ = ytEnv.getAccountPlaybackSaveRequest(videoData.accountPlaybackToken,param1.quality);
            _loc3_ = new RequestLoader();
            _loc3_.loadRequest(_loc2_);
         }
      }
      
      public function onQualityChange(param1:QualityChangeEvent) : void
      {
         this.spliceStartTrigger = param1;
         setPlaybackFormat(formatSelector.getVideoFormat(FormatSelectionRecord.MANUAL,param1.quality));
         this.spliceStartTrigger = null;
         this.settingsButton.setAuto(ytEnv.autoQuality);
      }
      
      override protected function updateVideoData(param1:VideoData) : void
      {
         if(param1 != videoData)
         {
            if(videoData)
            {
               videoData.timelineData.removeEventListener(Event.ADDED,this.onTimelineData);
               videoData.removeEventListener(SubscriptionEvent.OPEN_LOGIN_DIALOG,this.openLoginDialog);
            }
            if(param1)
            {
               param1.timelineData.addEventListener(Event.ADDED,this.onTimelineData);
               param1.subscribeRequest = ytEnv.getChannelSubscribeRequest();
               param1.unsubscribeRequest = ytEnv.getUnsubscribeRequest();
               param1.addEventListener(SubscriptionEvent.OPEN_LOGIN_DIALOG,this.openLoginDialog);
            }
         }
         super.updateVideoData(param1);
      }
   }
}

