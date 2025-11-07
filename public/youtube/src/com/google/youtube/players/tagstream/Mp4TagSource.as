package com.google.youtube.players.tagstream
{
   import com.google.utils.mp4.Parser;
   import com.google.youtube.event.FallbackEvent;
   import com.google.youtube.model.Mp4FormatIndex;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.tag.DataTag;
   import com.google.youtube.model.tag.TagFormat;
   import com.google.youtube.players.tagstream.bytesource.IByteSource;
   import com.google.youtube.util.FlvUtils;
   import flash.errors.EOFError;
   
   public class Mp4TagSource extends PipelineEventDispatcher implements ITagSource
   {
      
      protected static const AUDIO:uint = 0;
      
      protected static const VIDEO:uint = 1;
      
      protected static const CHUNK_EOF:uint = 2;
      
      protected var byteSource:IByteSource;
      
      protected var videoIterator:Mp4Iterator = new Mp4Iterator();
      
      protected var sampleSizeTable:Array;
      
      protected var frameHeaderOffset:uint;
      
      protected var moov:Parser;
      
      protected var tag:DataTag = new DataTag();
      
      protected var formatIndex:Mp4FormatIndex;
      
      protected var audioIterator:Mp4Iterator = new Mp4Iterator();
      
      protected var extractingInBandAtoms:Boolean;
      
      protected var sampleChunkTable:Array;
      
      protected var iterator:Mp4Iterator;
      
      protected var tagFormat:TagFormat;
      
      protected var sampleTimeTable:Array;
      
      public function Mp4TagSource(param1:IByteSource, param2:VideoFormat, param3:Mp4FormatIndex)
      {
         super();
         this.tagFormat = new TagFormat(param2);
         this.byteSource = param1;
         this.formatIndex = param3;
         forwardEvents(param1,true);
         if(param3.loaded)
         {
            this.moov = param3.moov;
            this.extractingInBandAtoms = param3.isFragmented;
         }
         else
         {
            this.moov = new Parser();
            this.extractingInBandAtoms = true;
         }
      }
      
      protected function setCurrentIterator(param1:uint) : void
      {
         if(param1 == AUDIO)
         {
            this.iterator = this.audioIterator;
            this.sampleSizeTable = this.moov.audioSampleSizeTable;
            this.sampleTimeTable = this.moov.audioSampleTimeTable;
            this.sampleChunkTable = this.moov.audioSampleChunkTable;
         }
         else
         {
            this.iterator = this.videoIterator;
            this.sampleSizeTable = this.moov.videoSampleSizeTable;
            this.sampleTimeTable = this.moov.videoSampleTimeTable;
            this.sampleChunkTable = this.moov.videoSampleChunkTable;
         }
      }
      
      protected function isAudio() : Boolean
      {
         return this.iterator == this.audioIterator;
      }
      
      public function open(param1:SeekPoint) : void
      {
         if(this.formatIndex.isFragmented)
         {
            this.moov.resetSampleTables();
         }
         this.audioIterator.currentChunk = param1.currentAudioChunk;
         this.audioIterator.currentSample = param1.currentAudioSample;
         this.audioIterator.firstDesiredSample = param1.firstDesiredAudioSample;
         this.videoIterator.currentChunk = param1.currentVideoChunk;
         this.videoIterator.currentSample = param1.currentVideoSample;
         this.videoIterator.firstDesiredSample = param1.firstDesiredVideoSample;
         this.byteSource.open(param1);
      }
      
      public function pop() : DataTag
      {
         var result:* = undefined;
         if(this.extractingInBandAtoms)
         {
            try
            {
               if(!this.moov.readAtoms(this.byteSource))
               {
                  return null;
               }
            }
            catch(e:EOFError)
            {
               dispatchEvent(new FallbackEvent(FallbackEvent.FALLBACK,FallbackEvent.MP4_EOF));
               return null;
            }
            catch(e:Error)
            {
               dispatchEvent(new FallbackEvent(FallbackEvent.FALLBACK,FallbackEvent.MP4_PARSE));
               return null;
            }
            if(!this.formatIndex.moov)
            {
               this.formatIndex.moov = this.moov;
            }
            this.extractingInBandAtoms = false;
         }
         do
         {
            result = this.readSample();
         }
         while(result && !result.length);
         
         return result;
      }
      
      protected function currentChunkType() : uint
      {
         var _loc1_:Boolean = this.moov.hasAudioTrak && this.audioIterator.currentSample < this.moov.audioSampleSizeTable.length;
         var _loc2_:Boolean = this.moov.hasVideoTrak && this.videoIterator.currentSample < this.moov.videoSampleSizeTable.length;
         if(_loc1_ && _loc2_)
         {
            return this.moov.audioChunkOffsetTable[this.audioIterator.currentChunk] < this.moov.videoChunkOffsetTable[this.videoIterator.currentChunk] ? AUDIO : VIDEO;
         }
         if(_loc1_)
         {
            return AUDIO;
         }
         if(_loc2_)
         {
            return VIDEO;
         }
         return CHUNK_EOF;
      }
      
      protected function readSample() : DataTag
      {
         var _loc1_:DataTag = null;
         var _loc2_:uint = this.currentChunkType();
         if(_loc2_ == CHUNK_EOF)
         {
            this.extractingInBandAtoms = !this.byteSource.eof;
            return null;
         }
         this.setCurrentIterator(_loc2_);
         if(this.tag.position == 0)
         {
            this.writeFrameHeader(this.tag);
            this.frameHeaderOffset = this.tag.position;
         }
         var _loc3_:uint = uint(this.sampleSizeTable[this.iterator.currentSample]);
         var _loc4_:uint = this.frameHeaderOffset + _loc3_;
         var _loc5_:uint = uint(_loc4_ - this.tag.position);
         var _loc6_:uint = uint(this.byteSource.read(this.tag,this.tag.position,_loc5_));
         this.tag.position += _loc6_;
         var _loc7_:* = _loc6_ == _loc5_;
         if(_loc7_)
         {
            if(this.iterator.currentSample >= this.iterator.firstDesiredSample)
            {
               FlvUtils.writeFrameTrailer(this.tag);
               this.tag.length = this.tag.position;
               this.tag.format = this.tagFormat;
            }
            else
            {
               this.tag.position = 0;
               this.tag.length = 0;
            }
            _loc1_ = this.tag;
            this.tag = new DataTag();
            ++this.iterator.currentSample;
            this.iterator.currentChunk = this.iterator.currentSample < this.sampleChunkTable.length ? uint(this.sampleChunkTable[this.iterator.currentSample]) : uint(this.iterator.currentChunk + 1);
         }
         return _loc1_;
      }
      
      public function close() : void
      {
         this.byteSource.close();
         stopForwardingEvents(this.byteSource,true);
      }
      
      protected function writeFrameHeader(param1:DataTag) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:uint = 0;
         var _loc2_:uint = uint(this.sampleTimeTable[this.iterator.currentSample]);
         if(this.isAudio())
         {
            FlvUtils.writeFrameHeader(param1,FlvUtils.TAG_TYPE_AUDIO,_loc2_);
            FlvUtils.writeAacAudioDataPreamble(param1);
         }
         else
         {
            _loc3_ = Boolean(this.moov.videoSyncOffsetTable[this.videoIterator.currentSample]);
            _loc4_ = this.moov.sampleCompositionTimeOffsetTable ? uint(this.moov.sampleCompositionTimeOffsetTable[this.videoIterator.currentSample]) : 0;
            FlvUtils.writeFrameHeader(param1,FlvUtils.TAG_TYPE_VIDEO,_loc2_);
            FlvUtils.writeAvcVideoDataPreamble(param1,_loc3_,_loc4_);
         }
      }
      
      public function get eof() : Boolean
      {
         return this.byteSource.eof;
      }
      
      public function info(param1:PlayerInfo) : void
      {
         this.byteSource.info(param1);
      }
   }
}

