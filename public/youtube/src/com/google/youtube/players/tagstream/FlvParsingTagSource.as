package com.google.youtube.players.tagstream
{
   import com.google.youtube.model.FlvFormatIndex;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.tag.DataTag;
   import com.google.youtube.model.tag.TagFormat;
   import com.google.youtube.players.tagstream.bytesource.IByteSource;
   import com.google.youtube.util.FlvUtils;
   import flash.events.IOErrorEvent;
   import flash.utils.ByteArray;
   
   public class FlvParsingTagSource extends PipelineEventDispatcher implements ITagSource
   {
      
      protected var byteSource:IByteSource;
      
      protected var parsedFlvHeader:Boolean = false;
      
      protected var format:TagFormat;
      
      protected var tag:DataTag = new DataTag();
      
      protected var parsePosition:uint = 0;
      
      public function FlvParsingTagSource(param1:IByteSource, param2:VideoFormat)
      {
         super();
         this.format = new TagFormat(param2);
         this.byteSource = param1;
         forwardEvents(param1,true);
      }
      
      public function pop() : DataTag
      {
         var _loc1_:ByteArray = null;
         if(!this.parseTag())
         {
            return null;
         }
         switch(FlvUtils.getExtendedType(this.tag))
         {
            case FlvUtils.TAG_TYPE_VIDEO:
            case FlvUtils.TAG_TYPE_AUDIO:
               return this.tag;
            case FlvUtils.TAG_TYPE_SCRIPT:
               if(!this.format.videoFormat.formatIndex.metadata)
               {
                  _loc1_ = new ByteArray();
                  this.tag.readBytes(_loc1_);
                  FlvFormatIndex(this.format.videoFormat.formatIndex).metadata = _loc1_;
               }
               return this.pop();
            case FlvUtils.EXTENDED_TYPE_AUDIO_HEADER:
               if(!this.format.videoFormat.formatIndex.audioHeader)
               {
                  FlvFormatIndex(this.format.videoFormat.formatIndex).audioHeader = new ByteArray();
                  this.tag.readBytes(this.format.videoFormat.formatIndex.audioHeader);
               }
               return this.pop();
            case FlvUtils.EXTENDED_TYPE_VIDEO_HEADER:
               if(!this.format.videoFormat.formatIndex.videoHeader)
               {
                  FlvFormatIndex(this.format.videoFormat.formatIndex).videoHeader = new ByteArray();
                  this.tag.readBytes(this.format.videoFormat.formatIndex.videoHeader);
               }
               return this.pop();
            case FlvUtils.EXTENDED_TYPE_VIDEO_EOS:
               return this.pop();
            default:
               dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
               return null;
         }
      }
      
      public function close() : void
      {
         this.byteSource.close();
         stopForwardingEvents(this.byteSource,true);
      }
      
      public function open(param1:SeekPoint) : void
      {
         var _loc2_:String = null;
         if(param1 == null)
         {
            _loc2_ = "null seekpoint in open";
            dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,_loc2_));
            return;
         }
         this.byteSource.open(param1);
      }
      
      public function get eof() : Boolean
      {
         return this.byteSource.eof;
      }
      
      protected function bytesNeeded() : uint
      {
         var _loc1_:uint = 0;
         if(this.parsePosition < FlvUtils.FRAME_HEADER_SIZE)
         {
            _loc1_ = uint(FlvUtils.FRAME_HEADER_SIZE);
         }
         else
         {
            _loc1_ = uint(FlvUtils.FRAME_HEADER_SIZE + FlvUtils.getDataSize(this.tag) + FlvUtils.FRAME_TRAILER_SIZE);
         }
         return _loc1_ - this.parsePosition;
      }
      
      public function info(param1:PlayerInfo) : void
      {
         this.byteSource.info(param1);
      }
      
      protected function parseTag() : Boolean
      {
         var _loc2_:uint = 0;
         var _loc1_:uint = this.bytesNeeded();
         while(_loc1_ > 0)
         {
            _loc2_ = uint(this.byteSource.read(this.tag,this.parsePosition,_loc1_));
            if(_loc2_ == 0)
            {
               return false;
            }
            this.parsePosition += _loc2_;
            _loc1_ = this.bytesNeeded();
         }
         this.tag.format = this.format;
         this.tag.length = this.parsePosition;
         this.tag.position = 0;
         this.parsePosition = 0;
         return true;
      }
   }
}

