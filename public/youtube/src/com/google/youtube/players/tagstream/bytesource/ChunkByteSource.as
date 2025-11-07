package com.google.youtube.players.tagstream.bytesource
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.players.tagstream.PipelineEventDispatcher;
   import com.google.youtube.util.FlvUtils;
   import com.google.youtube.util.MediaLocation;
   import flash.utils.ByteArray;
   
   public class ChunkByteSource extends PipelineEventDispatcher implements IByteSource
   {
      
      protected static var bytesLoadedValue:uint;
      
      public static var openChunksEarly:Boolean = false;
      
      protected static const earlyOpenMillis:uint = 6000;
      
      protected var pendingChunkOff:uint;
      
      protected var chunkOff:uint;
      
      protected var gotLastChunk:Boolean;
      
      protected var chunkSize:uint;
      
      protected var videoFormat:VideoFormat;
      
      protected var fileSizeValue:Number = NaN;
      
      protected var pending:IByteSource;
      
      protected var upstream:IByteSource;
      
      protected var pendingChunkLen:uint;
      
      protected var bytesToSkip:uint;
      
      protected var chunkLen:uint;
      
      protected var chunkBytesRead:uint;
      
      protected var bytesToDiscard:ByteArray = new ByteArray();
      
      protected var mediaLocation:MediaLocation;
      
      public function ChunkByteSource(param1:VideoFormat, param2:MediaLocation)
      {
         super();
         this.mediaLocation = param2;
         this.videoFormat = param1;
         this.chunkSize = ChunkByteSource.chunkSize(param2);
      }
      
      public static function chunkSize(param1:MediaLocation) : uint
      {
         return uint(15 * param1.byteRate) & 0xFFFFF000;
      }
      
      protected function align(param1:uint) : uint
      {
         var _loc2_:uint = param1 - param1 % this.chunkSize;
         return _loc2_ == 0 && param1 >= FlvUtils.FLV_HEADER_SIZE && this.videoFormat.isFlv ? uint(FlvUtils.FLV_HEADER_SIZE) : _loc2_;
      }
      
      protected function startReadingFromNextChunk() : void
      {
         this.chunkBytesRead = 0;
         this.chunkOff = this.pendingChunkOff;
         this.chunkLen = this.pendingChunkLen;
         this.upstream = this.pending;
         this.pending = null;
      }
      
      public function get bytesLoaded() : uint
      {
         return bytesLoadedValue;
      }
      
      public function open(param1:SeekPoint) : void
      {
         this.gotLastChunk = false;
         this.openNextChunk(this.snap(param1.byteOffset));
         this.startReadingFromNextChunk();
      }
      
      protected function closeStream(param1:IByteSource) : void
      {
         if(param1)
         {
            param1.close();
            stopForwardingEvents(param1,true);
         }
      }
      
      protected function createUpstream(param1:MediaLocation, param2:int, param3:Boolean) : IByteSource
      {
         return new HttpByteSource(param1,param2,param3);
      }
      
      public function read(param1:ByteArray, param2:uint, param3:uint) : uint
      {
         var _loc5_:uint = 0;
         if(this.bytesToSkip)
         {
            _loc5_ = uint(this.upstream.read(this.bytesToDiscard,0,this.bytesToSkip));
            this.bytesToSkip -= _loc5_;
            this.chunkBytesRead += _loc5_;
            bytesLoadedValue += _loc5_;
            this.bytesToDiscard.clear();
            if(this.bytesToSkip)
            {
               return 0;
            }
         }
         var _loc4_:uint = uint(this.upstream.read(param1,param2,param3));
         this.chunkBytesRead += _loc4_;
         bytesLoadedValue += _loc4_;
         if(this.shouldOpenNextChunk)
         {
            this.openNextChunk(this.chunkOff + this.chunkLen);
         }
         if(_loc4_ < param3 && Boolean(this.upstream.eof))
         {
            this.closeStream(this.upstream);
            if(!this.pending || this.chunkBytesRead < this.chunkLen)
            {
               this.gotLastChunk = true;
            }
            else if(this.chunkBytesRead == this.chunkLen)
            {
               this.startReadingFromNextChunk();
            }
         }
         return _loc4_;
      }
      
      protected function isAligned(param1:uint) : Boolean
      {
         return this.align(param1) == param1;
      }
      
      protected function snap(param1:uint) : uint
      {
         var _loc2_:uint = this.align(param1);
         if(Boolean(this.fetchedOffsets[_loc2_]) || param1 - _loc2_ < this.chunkSize / 10)
         {
            this.bytesToSkip = param1 - _loc2_;
            return _loc2_;
         }
         return param1;
      }
      
      protected function get fetchedOffsets() : Array
      {
         return this.mediaLocation.fetchedOffsets;
      }
      
      public function info(param1:PlayerInfo) : void
      {
         if(this.upstream)
         {
            this.upstream.info(param1);
         }
      }
      
      protected function get shouldOpenNextChunk() : Boolean
      {
         return !this.pending && this.openNextChunkThreshold <= this.chunkBytesRead && !isNaN(this.fileSize) && this.fileSize > this.chunkOff + this.chunkLen;
      }
      
      protected function get fileSize() : Number
      {
         if(isNaN(this.fileSizeValue))
         {
            this.fileSizeValue = this.mediaLocation.formatIndex.fileSize;
         }
         return this.fileSizeValue;
      }
      
      protected function get openNextChunkThreshold() : uint
      {
         if(!openChunksEarly)
         {
            return this.chunkLen;
         }
         var _loc1_:uint = this.mediaLocation.byteRate;
         var _loc2_:uint = earlyOpenMillis * _loc1_ / 1000;
         return _loc2_ > this.chunkLen ? 0 : uint(this.chunkLen - _loc2_);
      }
      
      public function get eof() : Boolean
      {
         return Boolean(this.upstream) && Boolean(this.upstream.eof) && this.gotLastChunk;
      }
      
      protected function openNextChunk(param1:uint) : void
      {
         var _loc2_:Boolean = false;
         if(this.isAligned(param1))
         {
            _loc2_ = Boolean(this.fetchedOffsets[param1]);
            this.fetchedOffsets[param1] = 1;
         }
         this.pendingChunkOff = param1;
         var _loc3_:uint = this.align(this.pendingChunkOff + this.chunkSize);
         if(!isNaN(this.fileSize) && _loc3_ >= this.fileSize)
         {
            _loc3_ += 2048;
         }
         this.pendingChunkLen = _loc3_ - this.pendingChunkOff;
         var _loc4_:SeekPoint = new SeekPoint();
         _loc4_.byteOffset = this.pendingChunkOff;
         _loc4_.byteLength = this.pendingChunkLen;
         var _loc5_:int = earlyOpenMillis + HttpByteSource.TIMEOUT;
         this.pending = this.createUpstream(this.mediaLocation,_loc5_,_loc2_);
         forwardEvents(this.pending,true);
         this.pending.open(_loc4_);
      }
      
      public function close() : void
      {
         this.closeStream(this.upstream);
         this.closeStream(this.pending);
         this.pending = null;
      }
   }
}

