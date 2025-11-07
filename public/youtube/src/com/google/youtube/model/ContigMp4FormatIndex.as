package com.google.youtube.model
{
   import com.google.youtube.util.BinarySearch;
   import flash.net.URLRequest;
   
   public class ContigMp4FormatIndex extends Mp4FormatIndex
   {
      
      protected var url:String;
      
      public function ContigMp4FormatIndex(param1:String)
      {
         super();
         this.url = param1;
      }
      
      protected function getNextSeekPointOrNull(param1:uint) : SeekPoint
      {
         var _loc3_:SeekPoint = null;
         var _loc4_:* = undefined;
         var _loc2_:int = this.getNextVideoSample(param1);
         if(_loc2_ < 0)
         {
            return null;
         }
         while(true)
         {
            _loc4_ = this.getNextKeyFrame(_loc2_++);
            if(_loc4_ < 0)
            {
               break;
            }
            _loc3_ = this.getSeekPointFromVideoSample(_loc4_,param1);
            if(!(Boolean(_loc3_) && _loc3_.timestamp < param1))
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      override public function canGetAnySeekPoint() : Boolean
      {
         return loaded;
      }
      
      protected function getKeyFrame(param1:uint) : uint
      {
         while(!moov.videoSyncOffsetTable[param1])
         {
            param1--;
         }
         return param1;
      }
      
      protected function getNextAudioChunk(param1:uint) : int
      {
         return BinarySearch.greaterThanOrEqual(moov.audioChunkOffsetTable,param1);
      }
      
      override public function getSeekPoint(param1:uint) : SeekPoint
      {
         return requestMoovInBand(param1) ? getSeekPointWithMoov() : this.getSeekPointFromVideoSample(this.getKeyFrame(this.getNearestVideoSample(param1)),param1);
      }
      
      override protected function getHeaderRequest() : URLRequest
      {
         return new URLRequest(this.url);
      }
      
      protected function firstSampleInVideoChunk(param1:uint) : uint
      {
         return this.firstSampleInChunk(param1,moov.videoSampleChunkTable);
      }
      
      override public function canGetSeekPoint(param1:uint) : Boolean
      {
         return param1 == 0 || loaded;
      }
      
      override public function getNextSeekPoint(param1:uint) : SeekPoint
      {
         return requestMoovInBand(param1) ? getSeekPointWithMoov() : this.getNextSeekPointOrNull(param1);
      }
      
      protected function getNextKeyFrame(param1:uint) : int
      {
         var _loc2_:uint = moov.videoSampleSizeTable.length;
         while(param1 < _loc2_ && !moov.videoSyncOffsetTable[param1])
         {
            param1++;
         }
         return param1 < _loc2_ ? int(param1) : -1;
      }
      
      protected function getSeekPointFromVideoSample(param1:uint, param2:uint) : SeekPoint
      {
         var _loc12_:uint = 0;
         var _loc13_:uint = 0;
         var _loc14_:uint = 0;
         var _loc15_:uint = 0;
         if(!moov.videoSyncOffsetTable[param1])
         {
            throw new Error();
         }
         var _loc3_:uint = uint(moov.videoSampleTimeTable[param1]);
         var _loc4_:uint = moov.videoSampleOffset(param1);
         var _loc5_:uint = uint(moov.videoSampleChunkTable[param1]);
         var _loc6_:uint = param1 > 0 ? uint(moov.videoSampleTimeTable[param1 - 1]) : uint(moov.audioSampleTimeTable[0]);
         var _loc7_:uint = uint(this.getNextAudioSample(_loc6_));
         var _loc8_:uint = uint(moov.audioSampleTimeTable[_loc7_]);
         var _loc9_:uint = moov.audioSampleOffset(_loc7_);
         var _loc10_:uint = uint(moov.audioSampleChunkTable[_loc7_]);
         var _loc11_:SeekPoint = new SeekPoint();
         if(_loc9_ < _loc4_)
         {
            _loc12_ = uint(this.getNextVideoChunk(_loc9_));
            _loc13_ = this.firstSampleInVideoChunk(_loc12_);
            _loc11_.timestamp = Math.min(_loc8_,_loc3_);
            _loc11_.byteOffset = _loc9_;
            _loc11_.currentAudioChunk = _loc10_;
            _loc11_.currentAudioSample = _loc7_;
            _loc11_.firstDesiredAudioSample = _loc7_;
            _loc11_.currentVideoChunk = _loc12_;
            _loc11_.currentVideoSample = _loc13_;
            _loc11_.firstDesiredVideoSample = param1;
         }
         else
         {
            _loc14_ = uint(this.getNextAudioChunk(_loc4_));
            _loc15_ = this.firstSampleInAudioChunk(_loc14_);
            _loc11_.timestamp = Math.min(_loc8_,_loc3_);
            _loc11_.byteOffset = _loc4_;
            _loc11_.currentVideoChunk = _loc5_;
            _loc11_.currentVideoSample = param1;
            _loc11_.firstDesiredVideoSample = param1;
            _loc11_.currentAudioChunk = _loc14_;
            _loc11_.currentAudioSample = _loc15_;
            _loc11_.firstDesiredAudioSample = _loc7_;
         }
         _loc11_.desiredTimestamp = Math.max(_loc11_.timestamp,param2);
         return _loc11_;
      }
      
      protected function getNextVideoSample(param1:uint) : int
      {
         return BinarySearch.greaterThanOrEqual(moov.videoSampleTimeTable,param1);
      }
      
      protected function firstSampleInAudioChunk(param1:uint) : uint
      {
         return this.firstSampleInChunk(param1,moov.audioSampleChunkTable);
      }
      
      override public function get fileSize() : Number
      {
         return loaded ? moov.getFileSize() : NaN;
      }
      
      protected function getAudioSample(param1:uint) : int
      {
         return BinarySearch.lessThanOrEqual(moov.audioSampleTimeTable,param1);
      }
      
      protected function firstSampleInChunk(param1:uint, param2:Array) : uint
      {
         var _loc3_:int = BinarySearch.lessThanOrEqual(param2,param1);
         while(_loc3_ >= 0 && param2[_loc3_] == param1)
         {
            _loc3_--;
         }
         return param2[_loc3_] != param1 ? uint(_loc3_ + 1) : uint(_loc3_);
      }
      
      override public function getTimeFromByte(param1:uint) : uint
      {
         var _loc2_:uint = uint(moov.videoSampleTimeTable[moov.videoSampleTimeTable.length - 1]);
         var _loc3_:SeekPoint = this.getSeekPoint(_loc2_);
         var _loc4_:uint = _loc3_.timestamp;
         var _loc5_:uint = _loc3_.byteOffset;
         return _loc4_ * param1 / _loc5_;
      }
      
      protected function getNextAudioSample(param1:uint) : int
      {
         return BinarySearch.greaterThanOrEqual(moov.audioSampleTimeTable,param1);
      }
      
      override public function get isFragmented() : Boolean
      {
         return false;
      }
      
      protected function getNextVideoChunk(param1:uint) : int
      {
         return BinarySearch.greaterThanOrEqual(moov.videoChunkOffsetTable,param1);
      }
      
      protected function getNearestVideoSample(param1:uint) : int
      {
         var _loc2_:int = BinarySearch.greaterThanOrEqual(moov.videoSampleTimeTable,param1);
         return _loc2_ >= 0 ? _loc2_ : int(moov.videoSampleTimeTable.length - 1);
      }
   }
}

