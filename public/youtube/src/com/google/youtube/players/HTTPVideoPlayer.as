package com.google.youtube.players
{
   import com.google.utils.RequestVariables;
   import com.google.utils.Scheduler;
   import com.google.youtube.application.VideoApplication;
   import com.google.youtube.event.CuePointEvent;
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.event.LogEvent;
   import com.google.youtube.event.SpliceEvent;
   import com.google.youtube.event.StageVideoStatusEvent;
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.event.VideoEvent;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.time.TimeRange;
   import com.google.youtube.util.StageAmbassador;
   import com.google.youtube.util.getDefinition;
   import flash.display.DisplayObject;
   import flash.events.AsyncErrorEvent;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundTransform;
   import flash.media.Video;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.URLRequest;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class HTTPVideoPlayer extends BaseVideoPlayer
   {
      
      protected static const StageVideo:Object = getDefinition("flash.media.StageVideo");
      
      protected static const StageVideoEvent:Object = getDefinition("flash.events.StageVideoEvent");
      
      protected static const STAGE_VIDEO_SUPPORTED:Boolean = Boolean(StageVideo) && Boolean(StageVideoEvent) && Boolean(StageVideoEvent.RENDER_STATE);
      
      protected static var MIN_NBE_LOG_INTERVAL:Number = 500;
      
      protected static const RETRY_LIMIT:int = 4;
      
      protected var proxyNetClient:ProxyNetClient = new ProxyNetClient(this);
      
      protected var stageVideo:Object;
      
      protected var timerStart:Number;
      
      protected var replaceVideo:DisplayObject;
      
      protected var metaDataScheduler:Scheduler;
      
      protected var bufferTime:Number;
      
      protected var streamTimeLock:Number = NaN;
      
      protected var timer:Timer;
      
      protected var retryCount:Number = 0;
      
      protected var videoRenderStatus:String;
      
      protected var lastTimeEnteringPlayingState:Number;
      
      protected var netConnection:NetConnection;
      
      protected var streamTransitionTime:Number = NaN;
      
      protected var stageAmbassador:StageAmbassador = new StageAmbassador(this);
      
      protected var bufferEmptyStart:Date;
      
      protected var video:Video = new Video();
      
      protected var stageVideoTimeout:Scheduler;
      
      protected var sentTimerPing:Boolean = false;
      
      protected var streamValue:NetStream;
      
      protected var lastTimeReportBufferEmpty:Number;
      
      protected var videoInfoProvider:IVideoInfoProvider;
      
      protected var savedStartSeconds:Number = 0;
      
      protected var stageVideoRenderStatus:String;
      
      protected var stageVideoTimeoutMillis:Number = 2100;
      
      public function HTTPVideoPlayer(param1:IVideoInfoProvider)
      {
         this.videoInfoProvider = param1;
         this.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.stageVideoTimeout = Scheduler.setTimeout(this.stageVideoTimeoutMillis,this.checkStageVideoRenderStatus);
         this.stageVideoTimeout.stop();
         if(STAGE_VIDEO_SUPPORTED)
         {
            this.video.addEventListener(StageVideoEvent.RENDER_STATE,this.onVideoEvent);
         }
         super(param1);
      }
      
      override public function stop() : void
      {
         this.disconnectStream();
         super.stop();
      }
      
      override protected function setDisplayRect(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         super.setDisplayRect(param1,param2,param3,param4);
         x = param1;
         y = param2;
         this.resizeVideo(param3,param4);
      }
      
      protected function connectStream() : void
      {
         var _loc1_:Number = NaN;
         this.disconnectStream();
         this.streamValue = this.getNewNetStream();
         this.streamValue.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
         this.streamValue.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onError);
         this.streamValue.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onError);
         this.streamValue.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
         this.streamValue.bufferTime = this.videoInfoProvider.defaultBufferLength;
         this.streamValue.checkPolicyFile = videoData.checkPolicyFile;
         this.streamValue.client = this.proxyNetClient;
         if(!isNaN(volume))
         {
            _loc1_ = volume * videoData.muffleFactor / 100;
            this.streamValue.soundTransform = new SoundTransform(_loc1_);
         }
         dispatchEvent(new VideoEvent(VideoEvent.NET_STREAM_READY));
         if(this.playStream())
         {
            this.attachNetStream(true);
         }
      }
      
      override public function getBuffers() : Array
      {
         var _loc1_:Number = getLoadedFraction();
         var _loc2_:Number = videoData.startSeconds;
         return [new TimeRange(1000 * _loc2_,1000 * (_loc2_ + _loc1_ * (getDuration() - _loc2_)))];
      }
      
      protected function checkStageVideoRenderStatus(param1:Event) : void
      {
         if(Boolean(this.stageVideo) && !this.stageVideoRenderStatus)
         {
            this.stageVideoRenderStatus = "unavailable";
            this.attachNetStream();
         }
      }
      
      override public function getBytesLoaded() : Number
      {
         var _loc1_:Number = super.getBytesLoaded();
         if(this.streamValue)
         {
            _loc1_ = this.streamValue.bytesLoaded;
            if(_loc1_ == uint(-1))
            {
               _loc1_ = 0;
            }
         }
         return _loc1_;
      }
      
      override public function setVolume(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         super.setVolume(param1);
         if(!isNaN(volume) && Boolean(this.streamValue))
         {
            _loc2_ = volume * videoData.muffleFactor / 100;
            this.streamValue.soundTransform = new SoundTransform(_loc2_);
         }
      }
      
      protected function onVideoEvent(param1:Event) : void
      {
         this.videoRenderStatus = Object(param1).status;
         this.attachNetStream();
      }
      
      override public function getPlayerInfo(param1:PlayerInfo) : void
      {
         param1.hasSeamless = false;
         param1.hardwarePlayback = this.isStageVideoAvailable();
         if(this.streamValue)
         {
            param1.viewPortWidth = displayRect.width;
            param1.viewPortHeight = displayRect.height;
            param1.playhead = this.streamValue.time;
            param1.decodeBufferSeconds = this.streamValue.bufferLength;
            if(this.streamValue.hasOwnProperty("info"))
            {
               param1.playbackBytesPerSecond = this.streamValue.info.playbackBytesPerSecond;
               param1.droppedFrames = this.streamValue.info.droppedFrames;
            }
         }
      }
      
      public function onCuePoint(param1:Object) : void
      {
         var _loc2_:String = param1.name;
         if(Boolean(param1.parameters) && Boolean(param1.parameters.aegcuepoint))
         {
            _loc2_ = param1.parameters.aegcuepoint;
         }
         this.dispatchCuePoint(_loc2_,param1.time,param1.parameters);
      }
      
      protected function resizeVideo(param1:Number, param2:Number) : void
      {
         var pt:Point = null;
         var viewPort:Rectangle = null;
         var newWidth:Number = param1;
         var newHeight:Number = param2;
         if(this.stageVideo)
         {
            pt = localToGlobal(new Point(0,0));
            viewPort = new Rectangle(pt.x,pt.y,newWidth,newHeight);
            if(viewPort.width > 8191)
            {
               viewPort.x += (viewPort.width - 8191) / 2;
               viewPort.width = 8191;
            }
            if(viewPort.height > 8191)
            {
               viewPort.y += (viewPort.height - 8191) / 2;
               viewPort.height = 8191;
            }
            viewPort.x = Math.max(-8192,Math.min(viewPort.x,8191));
            viewPort.y = Math.max(-8192,Math.min(viewPort.y,8191));
            try
            {
               this.stageVideo.viewPort = viewPort;
            }
            catch(e:Error)
            {
               e.message += ", rect: " + viewPort;
               throw e;
            }
         }
         else
         {
            this.video.width = newWidth;
            this.video.height = newHeight;
            this.video.smoothing = this.video.width != this.video.videoWidth || this.video.height != this.video.videoHeight;
         }
      }
      
      protected function clearVideo() : void
      {
         if(contains(this.video))
         {
            removeChild(this.video);
         }
         if(STAGE_VIDEO_SUPPORTED)
         {
            this.video.removeEventListener(StageVideoEvent.RENDER_STATE,this.onVideoEvent);
         }
         this.video = new Video();
         if(STAGE_VIDEO_SUPPORTED)
         {
            this.video.addEventListener(StageVideoEvent.RENDER_STATE,this.onVideoEvent);
         }
         if(this.stageVideo)
         {
            this.stageVideo.viewPort = new Rectangle(0,0,0,0);
         }
      }
      
      override public function onProgress(param1:Event = null) : void
      {
         if(Boolean(this.streamValue) && this.streamValue.time != this.streamTimeLock)
         {
            this.savedStartSeconds = videoData.startSeconds;
         }
         super.onProgress(param1);
      }
      
      override protected function disconnectStream() : void
      {
         if(this.streamValue)
         {
            this.streamValue.soundTransform.volume = 0;
            this.streamValue.removeEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
            this.streamValue.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onError);
            this.streamValue.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
            this.streamValue.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onError);
            this.streamValue.close();
            if(this.streamValue.hasOwnProperty("dispose"))
            {
               Object(this.streamValue).dispose();
            }
            this.streamValue.client = {};
            this.streamValue = null;
         }
         if(Boolean(this.metaDataScheduler) && this.metaDataScheduler.isRunning())
         {
            this.metaDataScheduler.stop();
         }
      }
      
      public function getNewNetStream() : NetStream
      {
         return new NetStream(this.netConnection);
      }
      
      override public function getLoggingOptions() : Object
      {
         var info:* = undefined;
         var resultCandidates:Object = null;
         var i:* = undefined;
         var result:Object = super.getLoggingOptions();
         if(!this.streamValue || !this.streamValue.hasOwnProperty("info"))
         {
            return result;
         }
         try
         {
            if(this.streamValue.info)
            {
               info = this.streamValue.info;
               resultCandidates = {
                  "nsiabbl":info.audioBufferByteLength,
                  "nsidf":info.droppedFrames,
                  "nsivbbl":info.videoBufferByteLength
               };
               result = {"nsiempty":"1"};
               for(i in resultCandidates)
               {
                  if(resultCandidates[i] != 0)
                  {
                     result[i] = resultCandidates[i];
                     delete result["nsiempty"];
                  }
               }
            }
         }
         catch(error:Error)
         {
         }
         if(this.video.videoWidth > 0 && this.video.videoHeight > 0)
         {
            result.vw = this.video.videoWidth;
            result.vh = this.video.videoHeight;
         }
         result.decoding = this.stageVideo ? this.stageVideoRenderStatus : this.videoRenderStatus;
         result.rendering = this.stageVideo ? "accelerated" : "software";
         return result;
      }
      
      public function resetCDNRetryCount() : void
      {
         this.retryCount = 0;
      }
      
      protected function closeNetConnection(param1:NetConnection) : void
      {
         if(param1)
         {
            param1.removeEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
            param1.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onError);
            param1.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onError);
            param1.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
            param1.close();
            param1.client = {};
         }
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = true) : void
      {
         super.addEventListener(param1,param2,param3,param4,param5);
         if(param1 == VideoEvent.NET_STREAM_READY && Boolean(this.stream))
         {
            param2(new VideoEvent(VideoEvent.NET_STREAM_READY));
         }
      }
      
      public function onMetaData(param1:Object) : void
      {
         param1.bytesLoaded = this.getBytesLoaded();
         param1.bytesTotal = this.getBytesTotal();
         var _loc2_:Object = this.stageVideo || this.video;
         if(this.streamValue)
         {
            if(param1.width == undefined)
            {
               param1.width = _loc2_.videoWidth;
            }
            if(param1.height == undefined)
            {
               param1.height = _loc2_.videoHeight;
            }
         }
         if(param1.width == 0 || param1.height == 0)
         {
            if(!this.metaDataScheduler)
            {
               this.metaDataScheduler = Scheduler.setInterval(0,this.onPollVideoForDimensions);
            }
         }
         videoData.applyMetaData(param1);
         if(Boolean(videoData.keyframes) && videoData.videoUrl != videoUrlProvider.getVideoUrl(videoData))
         {
            this.initiatePlayback();
         }
      }
      
      protected function increaseTargetBufferLength(param1:Number) : void
      {
         if(!isNaN(param1) && this.streamValue && this.streamValue.bufferTime < param1)
         {
            this.streamValue.bufferTime = param1;
         }
      }
      
      override public function getDefaultVideoSurface() : DisplayObject
      {
         return this.video;
      }
      
      override public function getTime() : Number
      {
         var _loc1_:Number = NaN;
         if(!isNaN(this.streamTimeLock) && this.streamValue && this.streamValue.time != this.streamTimeLock)
         {
            this.streamTimeLock = NaN;
            this.streamTransitionTime = NaN;
         }
         if(state is IEndedState)
         {
            _loc1_ = Number(videoData.clipEnd || videoData.duration);
         }
         else if(state is SeekingState)
         {
            _loc1_ = SeekingState(state).seekTime;
         }
         else if(Boolean(this.streamValue) && this.streamValue.time > 0)
         {
            _loc1_ = isNaN(this.streamTimeLock) || isNaN(this.streamTransitionTime) ? this.streamValue.time + this.getTimeOffset() : this.streamTransitionTime;
         }
         else
         {
            _loc1_ = super.getTime();
         }
         if(_loc1_ == Infinity)
         {
            _loc1_ = 0;
         }
         else if(Boolean(videoData) && Boolean(videoData.duration))
         {
            _loc1_ = Math.min(_loc1_,videoData.duration);
         }
         return _loc1_;
      }
      
      protected function onError(param1:Event) : void
      {
         var _loc2_:ErrorEvent = null;
         this.disconnectStream();
         if(param1 is SecurityErrorEvent)
         {
            _loc2_ = ErrorEvent(param1);
         }
         else
         {
            _loc2_ = new VideoErrorEvent(VideoErrorEvent.ERROR,param1.type);
         }
         this.setPlayerState(new ErrorState(this,_loc2_));
      }
      
      override protected function setPlayerState(param1:IPlayerState) : void
      {
         super.setPlayerState(param1);
         if(state is IPlayingState)
         {
            if(this.timer)
            {
               this.timer.reset();
            }
            if(this.stageVideo)
            {
               this.stageVideoTimeout.restart();
            }
            this.lastTimeEnteringPlayingState = getTimer();
         }
         if(state is SeekingState)
         {
            this.streamTimeLock = this.streamValue ? this.streamValue.time + this.getTimeOffset() : -1;
         }
         if(!isNaN(this.streamTimeLock) && (isNaN(this.streamTransitionTime) || state is SeekingState))
         {
            this.streamTransitionTime = this.getTime();
         }
      }
      
      protected function logPlayback() : void
      {
         dispatchEvent(new LogEvent(LogEvent.PLAYBACK,LogEvent.PLAYBACK));
      }
      
      override public function get stream() : NetStream
      {
         return this.streamValue;
      }
      
      internal function setStream(param1:NetStream) : void
      {
         this.streamValue = param1;
      }
      
      override public function setVideoData(param1:VideoData) : void
      {
         if(videoData != param1)
         {
            this.clearVideo();
            if(videoData)
            {
               videoData.removeEventListener(GetVideoInfoEvent.INFO,this.onNewVideoData);
               videoData.removeEventListener(VideoErrorEvent.ERROR,this.onNewVideoDataError);
            }
            if(param1)
            {
               param1.addEventListener(GetVideoInfoEvent.INFO,this.onNewVideoData);
               param1.addEventListener(VideoErrorEvent.ERROR,this.onNewVideoDataError);
            }
            super.setVideoData(param1);
         }
      }
      
      public function onPlayStatus(param1:Object) : void
      {
         switch(param1.code)
         {
            case "NetStream.Play.SpliceComplete":
               dispatchEvent(new SpliceEvent(SpliceEvent.COMPLETE,param1.oldFormat,param1.format));
               break;
            case "NetStream.Play.Complete":
               this.onProgress();
               end();
         }
      }
      
      protected function onNewVideoData(param1:GetVideoInfoEvent) : void
      {
         videoUrlProvider.applyGetVideoInfo(param1.data);
         this.setPlayerState(state.onNewVideoData(param1));
      }
      
      override public function getBytesTotal() : Number
      {
         var _loc1_:Number = super.getBytesTotal();
         if(this.streamValue)
         {
            _loc1_ = this.streamValue.bytesTotal;
            if(_loc1_ == uint(-1))
            {
               _loc1_ = 0;
            }
         }
         return _loc1_;
      }
      
      protected function onPollVideoForDimensions(param1:Event) : void
      {
         var _loc2_:Object = this.stageVideo || this.video;
         if(Boolean(videoData) && _loc2_.videoWidth > 0)
         {
            videoData.applyMetaData({
               "width":_loc2_.videoWidth,
               "height":_loc2_.videoHeight
            });
            this.metaDataScheduler.stop();
         }
      }
      
      protected function isValidBufferEmpty() : Boolean
      {
         var _loc1_:Number = 1;
         var _loc2_:Number = 1;
         if(!(state is IPlayingState))
         {
            return false;
         }
         if((getTimer() - this.lastTimeEnteringPlayingState) / 1000 < _loc1_)
         {
            return false;
         }
         if(getDuration() > 0 && getDuration() - this.getTime() < _loc2_)
         {
            return false;
         }
         return true;
      }
      
      protected function onStageVideoEvent(param1:Event) : void
      {
         this.stageVideoRenderStatus = Object(param1).status;
         this.attachNetStream();
      }
      
      override public function resetVideoSurface(param1:DisplayObject = null) : void
      {
         if(Boolean(this.replaceVideo) && contains(this.replaceVideo))
         {
            removeChild(this.replaceVideo);
         }
         else if(contains(this.video))
         {
            removeChild(this.video);
         }
         this.replaceVideo = param1;
         addChild(this.replaceVideo || this.video);
         this.attachNetStream();
      }
      
      protected function onAddedToStage(param1:Event) : void
      {
         this.stageAmbassador.addEventListener(StageVideoStatusEvent.AVAILABLE,this.onStageVideoStatusEvent);
         this.stageAmbassador.addEventListener(StageVideoStatusEvent.UNAVAILABLE,this.onStageVideoStatusEvent);
      }
      
      override public function resetStream(param1:Boolean = true) : void
      {
         super.resetStream(param1);
         this.disconnectStream();
         this.closeNetConnection(this.netConnection);
         this.resetVideoSurface();
         if(videoData)
         {
            this.netConnection = new NetConnection();
            this.netConnection.client = this.proxyNetClient;
            this.netConnection.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
            this.netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onError);
            this.netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onError);
            this.netConnection.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
            if(param1)
            {
               this.netConnection.connect(videoData.format.conn);
            }
         }
      }
      
      override protected function isEnded() : Boolean
      {
         return super.isEnded() || state is PausedState && PausedState(state).triggeredByStream && Math.ceil(getDuration()) >= 1 && Math.ceil(getDuration()) - Math.ceil(this.getTime()) <= 2;
      }
      
      override public function isStageVideoAvailable() : Boolean
      {
         var _loc1_:Boolean = false;
         if(Object(this.videoInfoProvider).hasOwnProperty("stageVideoForbidden"))
         {
            _loc1_ = Boolean(Object(this.videoInfoProvider).stageVideoForbidden);
         }
         return STAGE_VIDEO_SUPPORTED && this.stageAmbassador.stageVideoAvailable && parent is VideoApplication && !this.replaceVideo && this.stageVideoRenderStatus != "unavailable" && !_loc1_;
      }
      
      override public function getFPS() : Number
      {
         return this.streamValue ? this.streamValue.currentFPS : super.getFPS();
      }
      
      protected function dispatchCuePoint(param1:String, param2:Number, param3:Object = null) : void
      {
         if(!param1 || isNaN(param2))
         {
            return;
         }
         dispatchEvent(new CuePointEvent(CuePointEvent.CUE_POINT,param1,param2,param3));
      }
      
      protected function attachNetStream(param1:Boolean = false) : void
      {
         var _loc2_:Boolean = this.isStageVideoAvailable();
         if(!param1 && _loc2_ == Boolean(this.stageVideo))
         {
            return;
         }
         if(_loc2_)
         {
            if(contains(this.video))
            {
               removeChild(this.video);
            }
            if(!this.stageVideo)
            {
               this.stageVideo = this.stageAmbassador.stageVideos[0];
               this.stageVideo.addEventListener(StageVideoEvent.RENDER_STATE,this.onStageVideoEvent);
            }
            this.videoRenderStatus = null;
            this.stageVideoRenderStatus = null;
            this.stageVideo.attachNetStream(this.streamValue);
            if(state is IPlayingState)
            {
               this.timerStart = new Date().getTime();
               this.sentTimerPing = false;
               this.stageVideoTimeout.restart();
            }
         }
         else
         {
            if(this.stageVideo)
            {
               this.stageVideo.removeEventListener(StageVideoEvent.RENDER_STATE,this.onStageVideoEvent);
            }
            this.stageVideo = null;
            this.videoRenderStatus = null;
            this.stageVideoRenderStatus = null;
            this.stageVideoTimeout.stop();
            this.video.attachNetStream(this.streamValue);
            this.resetVideoSurface(this.replaceVideo);
         }
         this.resizeVideo(displayRect.width,displayRect.height);
      }
      
      protected function getTimeOffset() : Number
      {
         if(videoData.isMp4 || videoData.requiresTimeOffset)
         {
            return this.savedStartSeconds;
         }
         return 0;
      }
      
      protected function handleCDNRetry() : void
      {
         var _loc1_:Number = videoData.cdnList.length ? 0.25 : 1;
         if(this.retryCount++ < RETRY_LIMIT * _loc1_)
         {
            play(getVideoData());
         }
         else
         {
            onCDNFailover();
         }
      }
      
      override public function needsCorrectAspect() : Boolean
      {
         return true;
      }
      
      override public function showInterstitial() : Boolean
      {
         return false;
      }
      
      protected function onStageVideoStatusEvent(param1:Event) : void
      {
         this.attachNetStream();
      }
      
      protected function playStream() : Boolean
      {
         try
         {
            this.streamValue.play(videoData.videoUrl);
         }
         catch(e:SecurityError)
         {
            onError(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR,e.message));
            return false;
         }
         this.logPlayback();
         return true;
      }
      
      protected function onNetStatus(param1:NetStatusEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:RequestVariables = null;
         switch(param1.info.code)
         {
            case "NetConnection.Connect.Success":
               this.connectStream();
               break;
            case "NetStream.Play.Start":
            case "NetStream.Seek.Notify":
               progressScheduler.restart();
               this.setPlayerState(state.onNetStatus(param1));
               break;
            case "NetStream.Buffer.Full":
               this.increaseTargetBufferLength(Math.min(this.videoInfoProvider.maxBufferLength,this.videoInfoProvider.bufferLengthAfterVideoStarts));
               this.setPlayerState(state.onNetStatus(param1));
               break;
            case "NetStream.Buffer.Empty":
               if(this.isValidBufferEmpty())
               {
                  _loc2_ = this.videoInfoProvider.maxBufferLength;
                  _loc3_ = _loc2_;
                  _loc4_ = Math.min(_loc2_,_loc3_);
                  this.streamValue.bufferTime = _loc4_;
                  if(videoData.enableRealtimeLogging && (isNaN(this.lastTimeReportBufferEmpty) || getTimer() - this.lastTimeReportBufferEmpty > MIN_NBE_LOG_INTERVAL))
                  {
                     _loc5_ = new RequestVariables();
                     _loc5_.nbe = 1;
                     _loc5_.mt = this.getTime().toFixed(3);
                     _loc5_.bc = this.getBytesLoaded();
                     _loc5_.ba = this.getBytesTotal();
                     if(videoData.startSeconds > 0)
                     {
                        _loc5_.shift = videoData.startSeconds;
                     }
                     dispatchEvent(new LogEvent(LogEvent.LOG,"streaming",_loc5_));
                     this.lastTimeReportBufferEmpty = getTimer();
                  }
                  ++bufferEmptyEvents;
               }
               this.setPlayerState(state.onNetStatus(param1));
               break;
            case "NetStream.Play.StreamNotFound":
            case "NetStream.Play.FileStructureInvalid":
            case "NetStream.Play.NoSupportedTrackFound":
               progressScheduler.stop();
               this.setPlayerState(new ErrorState(this,new VideoErrorEvent(VideoErrorEvent.ERROR,param1.info.code)));
               break;
            default:
               this.setPlayerState(state.onNetStatus(param1));
         }
      }
      
      override public function initiatePlayback() : void
      {
         var _loc1_:URLRequest = null;
         super.initiatePlayback();
         if(videoData.isDataReady())
         {
            progressScheduler.restart();
            videoData.videoUrl = videoUrlProvider.getVideoUrl(videoData);
            if(this.streamValue)
            {
               this.streamTimeLock = this.streamValue.time;
               this.playStream();
            }
            else
            {
               this.resetStream();
            }
         }
         else
         {
            _loc1_ = videoUrlProvider.getVideoInfoRequest(videoData);
            videoData.getVideoInfo(_loc1_);
            this.disconnectStream();
         }
      }
      
      protected function onNewVideoDataError(param1:ErrorEvent) : void
      {
         this.setPlayerState(state.onNewVideoDataError(param1));
      }
      
      override public function destroy() : void
      {
         this.closeNetConnection(this.netConnection);
         super.destroy();
      }
   }
}

