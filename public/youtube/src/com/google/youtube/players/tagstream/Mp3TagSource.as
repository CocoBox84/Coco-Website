package com.google.youtube.players.tagstream
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.tag.DataTag;
   import com.google.youtube.model.tag.TagFormat;
   import com.google.youtube.players.tagstream.bytesource.IByteSource;
   import com.google.youtube.util.FlvUtils;
   import flash.utils.ByteArray;
   
   public class Mp3TagSource extends PipelineEventDispatcher implements ITagSource
   {
      
      protected static const ID3_MAGIC:uint = 1229206272;
      
      protected static const SYNC_WORD:uint = 4292870144;
      
      protected static const VERSION_25:uint = 0;
      
      protected static const VERSION_RESERVED:uint = 1;
      
      protected static const VERSION_2:uint = 2;
      
      protected static const VERSION_1:uint = 3;
      
      protected static const LAYER_RESERVED:uint = 0;
      
      protected static const LAYER_III:uint = 1;
      
      protected static const LAYER_II:uint = 2;
      
      protected static const LAYER_I:uint = 3;
      
      protected static const BITRATES:Array = [[0,0,0,0,0],[32,32,32,32,8],[64,48,40,48,16],[96,56,48,56,24],[128,64,56,64,32],[160,80,64,80,40],[192,96,80,96,48],[224,112,96,112,56],[256,128,112,128,64],[288,160,128,144,80],[320,192,160,160,96],[352,224,192,176,112],[384,256,224,192,128],[416,320,256,224,144],[448,384,320,256,160]];
      
      protected static const SAMPLING_RATE_V1:Array = [44100,48000,32000];
      
      protected static const SAMPLING_RATE_V2:Array = [22050,24000,16000];
      
      protected static const SAMPLING_RATE_V25:Array = [11025,12000,8000];
      
      protected static const CHANNEL_STEREO:uint = 0;
      
      protected static const CHANNEL_JOINT:uint = 1;
      
      protected static const CHANNEL_DUAL:uint = 2;
      
      protected static const CHANNEL_SINGLE:uint = 3;
      
      protected static const EMPHASIS_NONE:uint = 0;
      
      protected static const EMPHASIS_5015:uint = 1;
      
      protected static const EMPHASIS_RESERVED:uint = 2;
      
      protected static const EMPHASIS_CCITJ17:uint = 3;
      
      protected static const HEADER:uint = 0;
      
      protected static const MP3PAYLOAD:uint = 1;
      
      protected static const ID3HEADER:uint = 2;
      
      protected static const ID3PAYLOAD:uint = 3;
      
      protected var byteSource:IByteSource;
      
      protected var header:uint;
      
      protected var timestamp:Number;
      
      protected var tag:DataTag = new DataTag();
      
      protected var state:uint;
      
      protected var format:TagFormat;
      
      protected var id3Length:uint;
      
      public function Mp3TagSource(param1:IByteSource, param2:VideoFormat)
      {
         super();
         this.format = new TagFormat(param2);
         this.byteSource = param1;
         forwardEvents(param1,true);
      }
      
      protected function get bytesNeeded() : uint
      {
         switch(this.state)
         {
            case HEADER:
               return 4;
            case ID3HEADER:
               return 10;
            case ID3PAYLOAD:
               return this.id3Length;
            case MP3PAYLOAD:
               return FlvUtils.FRAME_HEADER_SIZE + 1 + this.frameLength;
            default:
               throw new Error("Unknown state");
         }
      }
      
      protected function getId3PayloadLength(param1:ByteArray) : uint
      {
         var _loc2_:uint = 0;
         _loc2_ |= param1[param1.length - 4] & 0x7F;
         _loc2_ <<= 7;
         _loc2_ |= param1[param1.length - 3] & 0x7F;
         _loc2_ <<= 7;
         _loc2_ |= param1[param1.length - 2] & 0x7F;
         _loc2_ <<= 7;
         return uint(_loc2_ | param1[param1.length - 1] & 0x7F);
      }
      
      protected function get isStereo() : Boolean
      {
         return this.mode != CHANNEL_SINGLE;
      }
      
      public function open(param1:SeekPoint) : void
      {
         this.timestamp = param1.timestamp;
         this.byteSource.open(param1);
      }
      
      protected function get crcProtectedBit() : Boolean
      {
         return Boolean((this.header & 0x010000) >> 16);
      }
      
      public function get eof() : Boolean
      {
         return this.byteSource.eof;
      }
      
      protected function get padding() : uint
      {
         return (this.header & 0x0200) >> 9;
      }
      
      public function pop() : DataTag
      {
         var _loc1_:uint = 0;
         var _loc2_:DataTag = null;
         while(this.readNext())
         {
            switch(this.state)
            {
               case HEADER:
                  this.header = this.tag.readUnsignedInt();
                  if((this.header & 0xFFFFFF00) == ID3_MAGIC)
                  {
                     this.state = ID3HEADER;
                  }
                  else
                  {
                     if(uint(this.header & 0xFFE00000) != SYNC_WORD)
                     {
                        throw new Error("Bad sync: " + this.header.toString(16));
                     }
                     this.tag.position = 0;
                     _loc1_ = Math.round(this.timestamp);
                     FlvUtils.writeFrameHeader(this.tag,FlvUtils.TAG_TYPE_AUDIO,_loc1_);
                     FlvUtils.writeMp3AudioDataPreamble(this.tag,this.samplingRate,this.isStereo);
                     this.tag.writeUnsignedInt(this.header);
                     this.timestamp += this.frameDuration;
                     this.state = MP3PAYLOAD;
                  }
                  break;
               case ID3HEADER:
                  this.id3Length = this.getId3PayloadLength(this.tag) + 10;
                  this.state = ID3PAYLOAD;
                  break;
               case ID3PAYLOAD:
                  this.tag.length = 0;
                  this.state = HEADER;
                  break;
               case MP3PAYLOAD:
                  this.tag.position = this.tag.length;
                  FlvUtils.writeFrameTrailer(this.tag);
                  this.tag.format = this.format;
                  _loc2_ = this.tag;
                  this.tag = new DataTag();
                  this.state = HEADER;
                  return _loc2_;
            }
         }
         return null;
      }
      
      protected function getBitrateIndex(param1:uint, param2:uint) : uint
      {
         switch(param1)
         {
            case VERSION_1:
               switch(param2)
               {
                  case LAYER_I:
                     return 0;
                  case LAYER_II:
                     return 1;
                  case LAYER_III:
                     return 2;
               }
            case VERSION_2:
            case VERSION_25:
               switch(param2)
               {
                  case LAYER_I:
                     return 3;
                  case LAYER_II:
                  case LAYER_III:
                     return 4;
               }
         }
         throw new Error("Unknown MP3 version/layer combination.");
      }
      
      protected function get version() : uint
      {
         return (this.header & 0x180000) >> 19;
      }
      
      protected function get frameDuration() : Number
      {
         return 1000 * this.samplesPerFrame / this.samplingRate;
      }
      
      protected function get mode() : uint
      {
         return (this.header & 0xC0) >> 6;
      }
      
      protected function get layer() : uint
      {
         return (this.header & 0x060000) >> 17;
      }
      
      protected function get samplingRate() : uint
      {
         switch(this.version)
         {
            case VERSION_1:
               return SAMPLING_RATE_V1[this.samplingIndex];
            case VERSION_2:
               return SAMPLING_RATE_V2[this.samplingIndex];
            case VERSION_25:
               return SAMPLING_RATE_V25[this.samplingIndex];
            default:
               throw new Error("Unknown MP3 version: " + this.version);
         }
      }
      
      protected function readNext() : Boolean
      {
         var _loc1_:uint = uint(this.bytesNeeded - this.tag.length);
         var _loc2_:uint = uint(this.byteSource.read(this.tag,this.tag.length,_loc1_));
         return _loc2_ == _loc1_;
      }
      
      protected function get samplingIndex() : uint
      {
         return (this.header & 0x0C00) >> 10;
      }
      
      protected function get bitrate() : uint
      {
         var _loc1_:uint = uint((this.header & 0xF000) >> 12);
         var _loc2_:uint = this.getBitrateIndex(this.version,this.layer);
         return BITRATES[_loc1_][_loc2_] * 1000;
      }
      
      protected function get dataLength() : uint
      {
         var _loc1_:uint = this.samplesPerFrame / 8;
         switch(this.layer)
         {
            case LAYER_I:
               return (_loc1_ * this.bitrate / this.samplingRate + this.padding) * 4;
            case LAYER_II:
            case LAYER_III:
               return _loc1_ * this.bitrate / this.samplingRate + this.padding;
            default:
               throw new Error("Unknown MP3 layer: " + this.layer);
         }
      }
      
      protected function get frameLength() : uint
      {
         return this.dataLength + (this.crcProtectedBit ? 0 : 2);
      }
      
      public function info(param1:PlayerInfo) : void
      {
         this.byteSource.info(param1);
      }
      
      public function close() : void
      {
         this.byteSource.close();
         stopForwardingEvents(this.byteSource,true);
      }
      
      protected function get samplesPerFrame() : uint
      {
         switch(this.layer)
         {
            case LAYER_I:
               return 384;
            case LAYER_II:
               return 1152;
            case LAYER_III:
               switch(this.version)
               {
                  case VERSION_1:
                     return 1152;
                  case VERSION_2:
                  case VERSION_25:
                     return 576;
               }
         }
         throw new Error("Unknown samples per frame");
      }
   }
}

