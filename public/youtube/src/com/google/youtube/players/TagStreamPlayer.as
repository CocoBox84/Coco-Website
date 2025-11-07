package com.google.youtube.players
{
   import com.google.events.SchedulerEvent;
   import com.google.utils.RequestVariables;
   import com.google.utils.Scheduler;
   import com.google.youtube.event.BandwidthSampleEvent;
   import com.google.youtube.event.FallbackEvent;
   import com.google.youtube.event.LogEvent;
   import com.google.youtube.event.SpliceEvent;
   import com.google.youtube.model.FailureReport;
   import com.google.youtube.model.FormatEnabler;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.YouTubeEnvironment;
   import com.google.youtube.players.tagstream.AppendBytesNetStream;
   import com.google.youtube.players.tagstream.DvrTagSource;
   import com.google.youtube.players.tagstream.QueueTagSource;
   import com.google.youtube.players.tagstream.TagStream;
   import com.google.youtube.players.tagstream.bytesource.ChunkByteSource;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.NetStream;
   
   public class TagStreamPlayer extends HTTPVideoPlayer
   {
      
      protected static var prebufferVideoData:VideoData;
      
      protected static var prebufferStream:TagStream;
      
      protected static const PREBUFFER_TIME_LIMIT:uint = 30000;
      
      protected static const SEEK_DELAY:Number = 5;
      
      protected static var prebufferedIds:Object = {};
      
      protected var lastRequestedSeek:Number;
      
      protected var adaptiveExperiment:Boolean = false;
      
      protected var publicIOErrorCodes:Object = {};
      
      protected var tagStream:TagStream;
      
      protected var formatEnabler:FormatEnabler;
      
      protected var seekDelay:Scheduler = Scheduler.setTimeout(SEEK_DELAY,this.initiateSeek);
      
      public var originalTimeOffset:Number = 0;
      
      protected var networkError:Boolean = false;
      
      protected var halfSpeedPlaybackExperiment:Boolean = false;
      
      public function TagStreamPlayer(param1:IVideoInfoProvider)
      {
         this.adaptiveExperiment = YouTubeEnvironment(param1).adaptiveExperiment;
         this.halfSpeedPlaybackExperiment = YouTubeEnvironment(param1).halfSpeedPlaybackExperiment;
         this.seekDelay.stop();
         this.publicIOErrorCodes[FailureReport.VIDEO_FETCH_ERROR_CODE] = true;
         this.publicIOErrorCodes[FailureReport.MANIFEST_KEY_ERROR_CODE] = true;
         super(param1);
      }
      
      public static function prebuffer(param1:VideoData, param2:YouTubeEnvironment) : void
      {
         if(param1.videoId in prebufferedIds || Boolean(prebufferVideoData))
         {
            return;
         }
         prebufferVideoData = param1;
         prebufferVideoData.videoUrl = param2.getVideoUrl(prebufferVideoData);
         prebufferStream = new TagStream(param2,prebufferVideoData,param2.enableDvrTagSource,param2.enableDiskByteSource);
         prebufferStream.addEventListener(ProgressEvent.PROGRESS,onPrebufferProgress);
         prebufferStream.open();
         prebufferedIds[prebufferVideoData.videoId] = true;
      }
      
      public static function prebufferFailure(param1:VideoData) : void
      {
         prebufferedIds[param1.videoId] = true;
      }
      
      public static function hasPrebuffered(param1:VideoData) : Boolean
      {
         return param1.videoId in prebufferedIds;
      }
      
      protected static function onPrebufferProgress(param1:Event) : void
      {
         if(prebufferStream.loadedTime > PREBUFFER_TIME_LIMIT)
         {
            prebufferStream.removeEventListener(ProgressEvent.PROGRESS,onPrebufferProgress);
            prebufferStream.close();
            prebufferVideoData = null;
         }
      }
      
      override public function getBuffers() : Array
      {
         return this.tagStream ? this.tagStream.getBuffers() : [];
      }
      
      override public function onPlayStatus(param1:Object) : void
      {
         if(param1.code == "M2TsTagSource.TimeCorrection")
         {
            this.originalTimeOffset = param1.original / 1000 - streamValue.time;
         }
         else
         {
            super.onPlayStatus(param1);
         }
      }
      
      override public function get playbackRate() : Number
      {
         return this.tagStream ? this.tagStream.playbackRate : 1;
      }
      
      override public function getLoadedFraction() : Number
      {
         var _loc1_:AppendBytesNetStream = stream as AppendBytesNetStream;
         if(Boolean(_loc1_) && this.useAppendBytes)
         {
            return videoData.format.isHls && videoData.isLive ? videoData.format.hlsPlaylist.liveChunkTime / videoData.duration : _loc1_.loadedTime / (videoData.duration * 1000);
         }
         return super.getLoadedFraction();
      }
      
      protected function createAppendBytesNetStream() : AppendBytesNetStream
      {
         var _loc1_:YouTubeEnvironment = YouTubeEnvironment(videoInfoProvider);
         var _loc2_:Number = Number(Number(_loc1_.rawParameters.tsp_buffer) || 10);
         TagStream.useDualSplicers = _loc1_.useDualSplicers;
         ChunkByteSource.openChunksEarly = _loc1_.openChunksEarly;
         if(_loc1_.fastSpliceExperiment)
         {
            TagStream.useFastSplice = true;
            _loc2_ = 5.333;
            DvrTagSource.READ_AHEAD = 50000 - _loc2_ * 1000;
            QueueTagSource.maxQueueMillis = 50000 - _loc2_ * 1000;
         }
         if(_loc1_.tagStreamingDvrNoTimeLimit)
         {
            DvrTagSource.READ_AHEAD = uint.MAX_VALUE;
         }
         DvrTagSource.CACHE_LIMIT = _loc1_.dvrCacheLimit;
         if(_loc1_.tagQueueReadaheadExperiment)
         {
            TagStream.useQueue = true;
            QueueTagSource.maxQueueBytes = _loc1_.dvrCacheLimit;
         }
         TagStream.disableM2TsAudio = _loc1_.disableM2TsAudio;
         this.tagStream = new TagStream(_loc1_,videoData,_loc1_.enableDvrTagSource,_loc1_.enableDiskByteSource);
         this.tagStream.playbackRate = playbackRateValue;
         return new AppendBytesNetStream(netConnection,this.tagStream,_loc2_);
      }
      
      override public function onProgress(param1:Event = null) : void
      {
         var _loc3_:RequestVariables = null;
         super.onProgress(param1);
         var _loc2_:AppendBytesNetStream = stream as AppendBytesNetStream;
         if(_loc2_)
         {
            _loc2_.updateLoadedTotal(videoData.duration,videoData.format);
            if(videoData.format.isHls && isPeggedToLive() && getTime() != 0 && getTime() < videoData.format.hlsPlaylist.minPeggedToLiveTime)
            {
               _loc3_ = new RequestVariables();
               _loc3_.time = getTime();
               _loc3_.behind = videoData.format.hlsPlaylist.liveChunkTime - getTime();
               dispatchEvent(new LogEvent(LogEvent.LOG,"fbehind",_loc3_));
               this.seek(videoData.format.hlsPlaylist.liveChunkTime);
            }
         }
         if(this.formatEnabler)
         {
            this.formatEnabler.enableFormats(videoData,getTime() / 1000);
         }
      }
      
      protected function initiateSeek(param1:Event = null) : void
      {
         this.setPlayerState(state.seek(this.lastRequestedSeek,this.tagStream.allowReadahead));
      }
      
      override public function isTagStreaming() : Boolean
      {
         return this.useAppendBytes;
      }
      
      override public function getNewNetStream() : NetStream
      {
         if(streamValue)
         {
            streamValue.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
            streamValue.removeEventListener(BandwidthSampleEvent.SAMPLE,dispatchEvent);
            streamValue.removeEventListener(SchedulerEvent.END,this.onError);
            streamValue.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
            streamValue.removeEventListener(FallbackEvent.FALLBACK,this.onFallback);
         }
         var _loc1_:AppendBytesNetStream = this.createAppendBytesNetStream();
         _loc1_.disableTagStream = !this.useAppendBytes;
         _loc1_.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         _loc1_.addEventListener(SchedulerEvent.END,this.onError);
         _loc1_.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
         _loc1_.addEventListener(FallbackEvent.FALLBACK,this.onFallback);
         _loc1_.addEventListener(BandwidthSampleEvent.SAMPLE,dispatchEvent);
         return _loc1_;
      }
      
      override public function getPlayerInfo(param1:PlayerInfo) : void
      {
         super.getPlayerInfo(param1);
         param1.hasSeamless = this.useAppendBytes;
         if(this.tagStream)
         {
            this.tagStream.info(param1);
         }
      }
      
      override public function getLoggingOptions() : Object
      {
         var _loc1_:Object = super.getLoggingOptions();
         _loc1_.tsphab = Object(streamValue).appendedBytes ? "1" : "0";
         _loc1_.tspne = this.networkError ? "1" : "0";
         _loc1_.tspfdt = Object(streamValue).firstDataTime;
         return _loc1_;
      }
      
      override public function set playbackRate(param1:Number) : void
      {
         super.playbackRate = param1;
         this.tagStream.playbackRate = playbackRateValue;
         this.seek(stream.time);
      }
      
      protected function isSupportedFormat(param1:VideoFormat) : Boolean
      {
         return Boolean(param1.formatIndex) && (this.adaptiveExperiment || param1.name != "5");
      }
      
      override protected function onNetStatus(param1:NetStatusEvent) : void
      {
         var _loc2_:RequestVariables = null;
         var _loc3_:RequestVariables = null;
         if(!this.useAppendBytes)
         {
            super.onNetStatus(param1);
            return;
         }
         switch(param1.info.code)
         {
            case "NetStream.Seek.Notify":
               if(param1.info.realSeek)
               {
                  super.onNetStatus(param1);
               }
               break;
            case "NetStream.Buffer.Empty":
               if(Boolean(this.tagStream) && !this.tagStream.opened)
               {
                  dispatchEvent(new SpliceEvent(SpliceEvent.COMPLETE));
               }
               super.onNetStatus(param1);
               break;
            case "AppendBytesNetStream.Connect.Opened":
               _loc2_ = new RequestVariables();
               _loc2_.vri = new Date().valueOf();
               dispatchEvent(new LogEvent(LogEvent.TIMING,param1.info.code,_loc2_));
               break;
            case "AppendBytesNetStream.Connect.Data":
               _loc3_ = new RequestVariables();
               _loc3_.fvf = new Date().valueOf();
               dispatchEvent(new LogEvent(LogEvent.TIMING,param1.info.code,_loc3_));
               break;
            default:
               super.onNetStatus(param1);
         }
      }
      
      override public function initiatePlayback() : void
      {
         if(Boolean(videoData.playlistUrl) && !videoData.isHlsVariantPlaylistReady())
         {
            disconnectStream();
         }
         else
         {
            super.initiatePlayback();
         }
      }
      
      protected function onFallback(param1:FallbackEvent) : void
      {
         var _loc2_:RequestVariables = null;
         var _loc3_:RequestVariables = null;
         if(videoData.format.requiresTagStreamPlayer)
         {
            this.onError(param1);
         }
         else
         {
            this.networkError = true;
            super.initiateSplice();
            _loc2_ = new RequestVariables();
            _loc2_.tsp = 1;
            _loc2_.ec = FailureReport.INVALID_DATA_ERROR_CODE;
            _loc2_.fbec = param1.errorCode;
            dispatchEvent(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,_loc2_));
            _loc3_ = new RequestVariables();
            _loc3_.fback = new Date().valueOf();
            dispatchEvent(new LogEvent(LogEvent.TIMING,"fback",_loc3_));
         }
      }
      
      override protected function playStream() : Boolean
      {
         AppendBytesNetStream(streamValue).disableTagStream = !this.useAppendBytes;
         return super.playStream();
      }
      
      override protected function onError(param1:Event) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:String = null;
         var _loc2_:RequestVariables = new RequestVariables();
         if(YouTubeEnvironment(videoInfoProvider).fallbackQualityExperiment)
         {
            videoData.disableCurrentFormat();
            if(videoData.format.enabled)
            {
               this.formatEnabler = this.formatEnabler || new FormatEnabler();
               _loc2_.aq = 1;
               _loc3_ = true;
            }
         }
         if(!_loc3_ && !this.networkError && !videoData.format.requiresTagStreamPlayer)
         {
            _loc2_.fb = 1;
            this.networkError = true;
            this.initiatePlayback();
            _loc3_ = true;
         }
         if(!_loc3_)
         {
            super.onError(param1);
         }
         _loc2_.tsp = 1;
         if(param1 is SecurityErrorEvent)
         {
            _loc2_.ec = FailureReport.CROSSDOMAIN_ERROR_CODE;
         }
         else if(param1 is SchedulerEvent)
         {
            _loc2_.ec = FailureReport.SHORT_TIMEOUT_ERROR_CODE;
         }
         else if(param1 is IOErrorEvent)
         {
            _loc2_.ec = FailureReport.IO_ERROR_CODE;
            _loc4_ = IOErrorEvent(param1).text;
            if(_loc4_.indexOf("api/drm") > -1)
            {
               _loc4_ = FailureReport.MANIFEST_KEY_ERROR_CODE;
            }
            else if(_loc4_.indexOf("videoplayback") > -1)
            {
               _loc4_ = FailureReport.VIDEO_FETCH_ERROR_CODE;
            }
            else if(_loc4_.indexOf("api/manifest") > -1)
            {
               _loc4_ = FailureReport.MANIFEST_FETCH_ERROR_CODE;
            }
            if(Boolean(_loc4_) && Boolean(this.publicIOErrorCodes[_loc4_]))
            {
               _loc2_.seid = _loc4_;
            }
         }
         else if(param1 is FallbackEvent)
         {
            _loc2_.ec = FailureReport.INVALID_DATA_ERROR_CODE;
         }
         else
         {
            _loc2_.ec = FailureReport.UNKNOWN_ERROR;
         }
         dispatchEvent(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,_loc2_));
      }
      
      protected function get useAppendBytes() : Boolean
      {
         return AppendBytesNetStream.isStreamingAvailable() && !this.networkError && this.isSupportedFormat(videoData.format);
      }
      
      override protected function setPlayerState(param1:IPlayerState) : void
      {
         super.setPlayerState(param1);
         this.seekDelay.stop();
      }
      
      override public function get availablePlaybackRates() : Array
      {
         if(this.halfSpeedPlaybackExperiment && !videoData.adModule)
         {
            return [0.25,0.5,1];
         }
         return super.availablePlaybackRates;
      }
      
      override public function isCached(param1:Number) : Boolean
      {
         return Boolean(this.tagStream) && this.tagStream.isCached(param1);
      }
      
      override public function initiateSplice() : void
      {
         var _loc1_:Boolean = this.useAppendBytes;
         _loc1_ &&= !(state is PausedState);
         _loc1_ &&= Boolean(this.tagStream) && this.tagStream.opened;
         if(_loc1_)
         {
            dispatchEvent(new SpliceEvent(SpliceEvent.START));
            this.tagStream.splice();
         }
         else
         {
            super.initiateSplice();
         }
      }
      
      override public function seek(param1:Number, param2:Boolean = true) : void
      {
         if(this.isTagStreaming() && Boolean(this.tagStream))
         {
            this.tagStream.allowReadahead = param2;
            this.lastRequestedSeek = param1;
            if(param2)
            {
               this.initiateSeek();
            }
            else
            {
               this.seekDelay.restart();
            }
         }
         else
         {
            super.seek(param1,param2);
         }
         if(this.useAppendBytes && param2)
         {
            dispatchEvent(new SpliceEvent(SpliceEvent.COMPLETE));
         }
      }
   }
}

