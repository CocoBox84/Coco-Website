package com.google.youtube.players.tagstream
{
   import com.google.youtube.event.BandwidthSampleEvent;
   import com.google.youtube.event.StreamEvent;
   import com.google.youtube.model.HlsFormatIndex;
   import com.google.youtube.model.IFormatIndex;
   import com.google.youtube.model.Mp4FormatIndex;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.SplitFormatIndex;
   import com.google.youtube.model.UnindexedFormatIndex;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.tag.AccessTag;
   import com.google.youtube.model.tag.DataTag;
   import com.google.youtube.model.tag.EofTag;
   import com.google.youtube.model.tag.FlvHeaderTag;
   import com.google.youtube.model.tag.FormatSwitchTag;
   import com.google.youtube.model.tag.ITag;
   import com.google.youtube.model.tag.TagFormat;
   import com.google.youtube.model.tag.TimeSwitchTag;
   import com.google.youtube.players.IVideoInfoProvider;
   import com.google.youtube.players.tagstream.bytesource.ChunkByteSource;
   import com.google.youtube.players.tagstream.bytesource.DashLiveByteSource;
   import com.google.youtube.players.tagstream.bytesource.DiskByteSource;
   import com.google.youtube.players.tagstream.bytesource.HttpByteSource;
   import com.google.youtube.players.tagstream.bytesource.IByteSource;
   import com.google.youtube.players.tagstream.bytesource.ThrottledByteSource;
   import com.google.youtube.util.BandwidthMeter;
   import com.google.youtube.util.FlvUtils;
   import com.google.youtube.util.MediaLocation;
   import com.google.youtube.util.getDefinition;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   
   public class TagStream extends PipelineEventDispatcher
   {
      
      protected static const HLS_TAG_SOURCE:String = "com.google.youtube.modules.streaminglib.HlsTagSource";
      
      protected static const M2TS_TAG_SOURCE:String = "com.google.youtube.modules.streaminglib.M2TsTagSource";
      
      protected static const TSP_TIMEOUT:Number = 12000;
      
      public static var useDualSplicers:Boolean = true;
      
      public static var useFastSplice:Boolean = false;
      
      public static var useQueue:Boolean = false;
      
      public static var disableM2TsAudio:Boolean = false;
      
      protected var downstreamSplicer:ISplicingTagSource;
      
      public var needsFlvHeader:Boolean = true;
      
      protected var chunkByteSource:ChunkByteSource;
      
      protected var lastAudioTag:DataTag;
      
      protected var upstreamSplicer:ISplicingTagSource;
      
      protected var splicingTagSource:ISplicingTagSource;
      
      protected var pipeline:ITagSource;
      
      protected var nextTag:DataTag;
      
      public var allowReadahead:Boolean = true;
      
      public var playbackRate:Number = 1;
      
      protected var lastFormat:TagFormat;
      
      protected var lastTimestamp:uint;
      
      public var useCache:Boolean = false;
      
      protected var diskByteSource:DiskByteSource;
      
      protected var videoData:VideoData;
      
      public var useDisk:Boolean = false;
      
      public var startTime:int = 0;
      
      protected var bandwidthMeter:BandwidthMeter = new BandwidthMeter();
      
      protected var videoInfoProvider:IVideoInfoProvider;
      
      protected var readahead:IReadaheadTagSource;
      
      public var needsSampleAccess:Boolean = false;
      
      protected var audioTagCounter:uint = 0;
      
      public function TagStream(param1:IVideoInfoProvider, param2:VideoData, param3:Boolean = false, param4:Boolean = false)
      {
         super();
         this.videoInfoProvider = param1;
         this.videoData = param2;
         this.useDisk = param4 && DiskByteSource.available;
         this.useCache = param3 && !this.useDisk;
         this.bandwidthMeter.addEventListener(BandwidthSampleEvent.SAMPLE,dispatchEvent);
      }
      
      public function get loadedTime() : Number
      {
         if(this.diskByteSource)
         {
            return this.diskByteSource.loadedTime;
         }
         if(this.readahead)
         {
            return this.readahead.loadedTime;
         }
         return 0;
      }
      
      protected function getUpstreamPipeline(param1:VideoFormat) : ITagSource
      {
         var _loc2_:ITagSource = this.getParsingTagSource(param1);
         if(useDualSplicers)
         {
            this.upstreamSplicer = new SplicingTagSource(_loc2_,param1);
            _loc2_ = this.upstreamSplicer;
         }
         if(useQueue || param1.isMp3 || useDualSplicers)
         {
            this.readahead = new QueueTagSource(_loc2_);
            _loc2_ = this.readahead;
         }
         else if(this.useCache)
         {
            this.readahead = new DvrTagSource(_loc2_,this.videoData.videoId,param1,this.allowReadahead);
            _loc2_ = this.readahead;
         }
         return _loc2_;
      }
      
      protected function getPipeline(param1:VideoFormat) : ITagSource
      {
         var _loc2_:ITagSource = this.getUpstreamPipeline(param1);
         if(useDualSplicers)
         {
            this.splicingTagSource = new SplicingTagSource(_loc2_,param1);
            this.downstreamSplicer = this.splicingTagSource;
         }
         else if(useFastSplice)
         {
            this.splicingTagSource = new FastSpliceTagSource(_loc2_,param1);
         }
         else
         {
            this.splicingTagSource = new SplicingTagSource(_loc2_,param1);
         }
         _loc2_ = this.splicingTagSource;
         return new InterframeTagSource(_loc2_);
      }
      
      public function info(param1:PlayerInfo) : void
      {
         if(this.pipeline)
         {
            this.pipeline.info(param1);
         }
      }
      
      protected function getByteSource(param1:VideoFormat, param2:MediaLocation) : IByteSource
      {
         var _loc3_:IByteSource = null;
         if(param1.isDashLive)
         {
            return new DashLiveByteSource(param1,param2);
         }
         if(param1.formatIndex is UnindexedFormatIndex)
         {
            _loc3_ = new HttpByteSource(param2);
         }
         else if(this.useDisk)
         {
            this.diskByteSource = new DiskByteSource(param1,param2);
            _loc3_ = this.diskByteSource;
         }
         else
         {
            this.chunkByteSource = new ChunkByteSource(param1,param2);
            _loc3_ = this.chunkByteSource;
         }
         if(DvrTagSource.READ_AHEAD == uint.MAX_VALUE)
         {
            _loc3_ = new ThrottledByteSource(this,param1,_loc3_);
         }
         return _loc3_;
      }
      
      protected function indexLoadRace(param1:Event) : Boolean
      {
         return Boolean(param1) && param1.target != this.videoData.format.formatIndex;
      }
      
      public function open() : uint
      {
         this.lastAudioTag = null;
         var _loc1_:IFormatIndex = this.videoData.format.formatIndex;
         if(_loc1_.canGetSeekPoint(this.videoData.startSeconds * 1000) && this.videoData.startSeconds != Infinity)
         {
            this.openWhenReady();
         }
         else
         {
            forwardEvents(_loc1_,false);
            _loc1_.addEventListener(Event.COMPLETE,this.openWhenReady);
            _loc1_.load();
         }
         var _loc2_:uint = TSP_TIMEOUT;
         if(this.videoData.format.isHls && this.videoData.startSeconds != Infinity)
         {
            _loc2_ += 1000 * Math.max(0,this.videoData.startSeconds - this.videoData.format.hlsPlaylist.liveChunkTime);
         }
         return _loc2_;
      }
      
      public function get bytesLoaded() : Number
      {
         if(this.chunkByteSource)
         {
            return this.chunkByteSource.bytesLoaded;
         }
         if(this.diskByteSource)
         {
            return this.diskByteSource.bytesLoaded;
         }
         return 0;
      }
      
      public function pop() : ITag
      {
         var _loc2_:DataTag = null;
         var _loc3_:int = 0;
         var _loc4_:TagFormat = null;
         if(this.needsFlvHeader)
         {
            this.needsFlvHeader = false;
            return new FlvHeaderTag();
         }
         if(this.playbackRate <= 0.5 && Boolean(this.lastAudioTag))
         {
            _loc2_ = this.lastAudioTag;
            if(this.audioTagCounter == 0)
            {
               this.lastAudioTag = null;
            }
            this.audioTagCounter = (this.audioTagCounter + 1) % (1 / this.playbackRate - 1);
            return _loc2_;
         }
         var _loc1_:DataTag = this.nextTag ? this.nextTag : (this.pipeline ? this.pipeline.pop() : null);
         this.nextTag = null;
         if(Boolean(_loc1_) && this.needsSampleAccess)
         {
            this.needsSampleAccess = false;
            this.nextTag = _loc1_;
            return new AccessTag(_loc1_.timestamp);
         }
         if(!_loc1_)
         {
            if(Boolean(this.pipeline) && this.pipeline.eof)
            {
               this.close();
               return new EofTag(this.lastTimestamp);
            }
            return null;
         }
         if(_loc1_.format && _loc1_.format.videoFormat.isHls && Boolean(this.lastTimestamp))
         {
            _loc3_ = _loc1_.timestamp - this.lastTimestamp;
            if(_loc3_ < 0 || _loc3_ > _loc1_.format.videoFormat.hlsPlaylist.targetDuration)
            {
               this.nextTag = _loc1_;
               this.lastTimestamp = _loc1_.timestamp;
               return new TimeSwitchTag();
            }
         }
         this.lastTimestamp = _loc1_.timestamp;
         if(this.lastFormat != _loc1_.format && Boolean(_loc1_.format))
         {
            this.nextTag = _loc1_;
            _loc4_ = this.lastFormat;
            this.lastFormat = _loc1_.format;
            return new FormatSwitchTag(_loc1_.timestamp,_loc4_,_loc1_.format);
         }
         if(FlvUtils.getTagType(_loc1_) == FlvUtils.TAG_TYPE_AUDIO)
         {
            this.lastAudioTag = _loc1_;
         }
         return _loc1_;
      }
      
      public function get readAhead() : int
      {
         if(this.readahead)
         {
            return this.readahead.loadedTime - this.lastTimestamp;
         }
         return 0;
      }
      
      public function get hasAudio() : Boolean
      {
         return !this.videoData.format.isM2Ts || !disableM2TsAudio;
      }
      
      protected function openWhenReady(param1:Event = null) : void
      {
         if(this.indexLoadRace(param1))
         {
            this.open();
            return;
         }
         this.close();
         this.pipeline = this.getPipeline(this.videoData.format);
         forwardEvents(this.pipeline,true);
         this.pipeline.addEventListener(StreamEvent.STREAM,this.bandwidthMeter.onStreamEvent);
         this.pipeline.addEventListener(ProgressEvent.PROGRESS,this.bandwidthMeter.onProgress);
         var _loc2_:uint = this.videoData.startSeconds * 1000;
         var _loc3_:IFormatIndex = this.videoData.format.formatIndex;
         var _loc4_:SeekPoint = _loc3_.getSeekPoint(_loc2_);
         if(this.videoData.startSeconds == Infinity && this.videoData.format.isHls)
         {
            _loc4_ = HlsFormatIndex(this.videoData.format.formatIndex).getLiveSeekPoint();
         }
         this.startTime = _loc4_.desiredTimestamp;
         this.bandwidthMeter.totalMediaRate = this.videoData.format.byteRate;
         this.pipeline.open(_loc4_);
         stopForwardingEvents(_loc3_,false);
         _loc3_.removeEventListener(Event.COMPLETE,this.openWhenReady);
      }
      
      public function get opened() : Boolean
      {
         return Boolean(this.pipeline);
      }
      
      public function isCached(param1:Number) : Boolean
      {
         return Boolean(this.readahead) && this.readahead.isCached(param1 * 1000);
      }
      
      protected function spliceWhenReady(param1:Event = null) : void
      {
         if(!this.pipeline || this.indexLoadRace(param1))
         {
            return;
         }
         this.bandwidthMeter.totalMediaRate = this.videoData.format.byteRate;
         if(useDualSplicers)
         {
            if(this.targetFormat.quality < this.videoData.format.quality)
            {
               this.downstreamSplicer.splice(this.getUpstreamPipeline(this.videoData.format),this.videoData.format);
            }
            else if(this.targetFormat.quality > this.videoData.format.quality)
            {
               this.upstreamSplicer.splice(this.getParsingTagSource(this.videoData.format),this.videoData.format);
            }
         }
         else
         {
            this.splicingTagSource.splice(this.getUpstreamPipeline(this.videoData.format),this.videoData.format);
         }
         var _loc2_:IFormatIndex = this.videoData.format.formatIndex;
         stopForwardingEvents(_loc2_,false);
         _loc2_.removeEventListener(Event.COMPLETE,this.spliceWhenReady);
      }
      
      protected function get targetFormat() : VideoFormat
      {
         return this.downstreamSplicer.splicing ? this.downstreamSplicer.target : this.upstreamSplicer.target;
      }
      
      protected function getVideoMediaLocation(param1:VideoFormat, param2:IFormatIndex = null) : MediaLocation
      {
         var _loc3_:MediaLocation = new MediaLocation(this.videoData,this.videoInfoProvider);
         _loc3_.primaryUrl = param1.url;
         _loc3_.fallbackHost = param1.fallbackHost;
         _loc3_.fetchedOffsets = param1.fetchedOffsetsVideo;
         _loc3_.byteRate = param1.videoByteRate;
         _loc3_.formatIndex = param2 ? param2 : param1.formatIndex;
         return _loc3_;
      }
      
      public function close() : void
      {
         if(this.pipeline)
         {
            this.pipeline.close();
            stopForwardingEvents(this.pipeline,true);
            this.pipeline.removeEventListener(StreamEvent.STREAM,this.bandwidthMeter.onStreamEvent);
            this.pipeline.removeEventListener(ProgressEvent.PROGRESS,this.bandwidthMeter.onProgress);
            this.pipeline = null;
            this.lastFormat = null;
            this.nextTag = null;
            this.needsFlvHeader = true;
         }
      }
      
      protected function getAudioMediaLocation(param1:VideoFormat, param2:IFormatIndex = null) : MediaLocation
      {
         var _loc3_:MediaLocation = new MediaLocation(this.videoData,this.videoInfoProvider);
         _loc3_.primaryUrl = param1.audioUrl;
         _loc3_.fallbackHost = param1.fallbackHost;
         _loc3_.fetchedOffsets = param1.fetchedOffsetsAudio;
         _loc3_.byteRate = param1.audioByteRate;
         _loc3_.formatIndex = param2 ? param2 : param1.formatIndex;
         return _loc3_;
      }
      
      protected function getParsingTagSource(param1:VideoFormat) : ITagSource
      {
         var _loc2_:ITagSource = null;
         var _loc3_:Class = null;
         var _loc4_:SplitFormatIndex = null;
         var _loc5_:Mp4FormatIndex = null;
         var _loc6_:Mp4FormatIndex = null;
         var _loc7_:Object = null;
         if(param1.isFlv)
         {
            _loc2_ = new FlvParsingTagSource(this.getByteSource(param1,this.getVideoMediaLocation(param1)),param1);
         }
         else if(param1.isMp4)
         {
            _loc2_ = new MuxTagSource(new Mp4TagSource(this.getByteSource(param1,this.getVideoMediaLocation(param1)),param1,Mp4FormatIndex(param1.formatIndex)));
         }
         else if(param1.isHls)
         {
            _loc3_ = getDefinition(HLS_TAG_SOURCE);
            if(!_loc3_)
            {
               dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,HLS_TAG_SOURCE));
            }
            else
            {
               _loc2_ = new _loc3_(param1);
            }
         }
         else if(param1.isDashLive || param1.isDash)
         {
            _loc4_ = SplitFormatIndex(param1.formatIndex);
            _loc5_ = Mp4FormatIndex(_loc4_.audio);
            _loc6_ = Mp4FormatIndex(_loc4_.video);
            _loc2_ = new MuxTagSource(new Mp4TagSource(this.getByteSource(param1,this.getVideoMediaLocation(param1,_loc6_)),param1,_loc6_),new Mp4TagSource(this.getByteSource(param1,this.getAudioMediaLocation(param1,_loc5_)),param1,_loc5_));
         }
         else if(param1.isMp3)
         {
            _loc2_ = new Mp3TagSource(this.getByteSource(param1,this.getVideoMediaLocation(param1)),param1);
         }
         else if(param1.isM2Ts)
         {
            _loc7_ = getDefinition(M2TS_TAG_SOURCE);
            _loc2_ = new _loc7_(this.getByteSource(param1,this.getVideoMediaLocation(param1)),param1,true,!disableM2TsAudio);
            if(!disableM2TsAudio)
            {
               _loc2_ = new MuxTagSource(_loc2_);
            }
         }
         return _loc2_;
      }
      
      public function splice() : void
      {
         var _loc1_:IFormatIndex = this.videoData.format.formatIndex;
         if(_loc1_.canGetAnySeekPoint())
         {
            this.spliceWhenReady();
         }
         else
         {
            forwardEvents(_loc1_,false);
            _loc1_.addEventListener(Event.COMPLETE,this.spliceWhenReady);
            _loc1_.load();
         }
      }
      
      public function getBuffers() : Array
      {
         return this.readahead ? this.readahead.getBuffers() : [];
      }
   }
}

