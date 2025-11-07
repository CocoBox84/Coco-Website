package com.google.youtube.util
{
   import flash.net.ObjectEncoding;
   import flash.utils.ByteArray;
   
   public class FlvUtils
   {
      
      public static const EXTENDED_TYPE_AUDIO_HEADER:uint = 265;
      
      public static const EXTENDED_TYPE_VIDEO_EOS:uint = 520;
      
      public static const EXTENDED_TYPE_VIDEO_HEADER:uint = 264;
      
      public static const TAG_TYPE_AUDIO:uint = 8;
      
      public static const TAG_TYPE_SCRIPT:uint = 18;
      
      public static const TAG_TYPE_VIDEO:uint = 9;
      
      public static const FLV_HEADER_SIZE:int = 13;
      
      public static const FRAME_HEADER_SIZE:int = 11;
      
      public static const FRAME_TRAILER_SIZE:int = 4;
      
      public static const SCRIPT_TAG_SIZE:uint = 858;
      
      protected static const MP3_AUDIO_DATA_PREAMBLE:Object = {
         8000:226,
         11025:38,
         22050:42,
         44100:46
      };
      
      public function FlvUtils()
      {
         super();
      }
      
      public static function writeFrameTrailer(param1:ByteArray) : void
      {
         if(param1.length < FRAME_HEADER_SIZE)
         {
            throw new Error("Tag too short");
         }
         var _loc2_:uint = uint(param1.length - FRAME_HEADER_SIZE);
         setDataSize(param1,_loc2_);
         param1.writeInt(param1.length);
      }
      
      public static function getVideoFrameType(param1:ByteArray) : uint
      {
         if(getTagType(param1) != TAG_TYPE_VIDEO)
         {
            throw new Error("Not a video frame");
         }
         return (param1[11] & 0xF0) >> 4;
      }
      
      public static function writeEosTag(param1:ByteArray, param2:String, param3:uint) : void
      {
         writeFrameHeader(param1,TAG_TYPE_VIDEO,param3);
         param1.writeByte(0x10 | formatToCodec(param2));
         param1.writeByte(2);
         param1.writeByte(0);
         param1.writeByte(0);
         param1.writeByte(0);
         writeFrameTrailer(param1);
      }
      
      public static function getExtendedType(param1:ByteArray) : uint
      {
         var _loc2_:uint = getTagType(param1);
         if(getDataSize(param1) < 2)
         {
            return _loc2_;
         }
         if(_loc2_ == TAG_TYPE_VIDEO && (param1[11] & 0x0F) == 7)
         {
            if(param1[12] == 0)
            {
               return EXTENDED_TYPE_VIDEO_HEADER;
            }
            if(param1[12] == 2)
            {
               return EXTENDED_TYPE_VIDEO_EOS;
            }
         }
         if(_loc2_ == TAG_TYPE_AUDIO && (param1[11] & 0xF0) == 160 && param1[12] == 0)
         {
            return EXTENDED_TYPE_AUDIO_HEADER;
         }
         return _loc2_;
      }
      
      public static function writeMp3AudioDataPreamble(param1:ByteArray, param2:uint, param3:Boolean) : void
      {
         if(!MP3_AUDIO_DATA_PREAMBLE[param2])
         {
            throw new Error("Unsupported Mp3 sample rate: " + param2);
         }
         param1.writeByte(MP3_AUDIO_DATA_PREAMBLE[param2] | uint(param3));
      }
      
      public static function isKeyFrame(param1:ByteArray) : Boolean
      {
         return getTagType(param1) == TAG_TYPE_VIDEO && getVideoFrameType(param1) == 1;
      }
      
      public static function setIsKeyFrame(param1:ByteArray, param2:Boolean) : void
      {
         param1[11] = param1[11] & 0x0F | (param2 ? 16 : 32);
      }
      
      public static function writeBeginSeekTag(param1:ByteArray, param2:String, param3:uint) : void
      {
         writeFrameHeader(param1,TAG_TYPE_VIDEO,param3);
         param1.writeByte(0x50 | formatToCodec(param2));
         param1.writeByte(0);
         writeFrameTrailer(param1);
      }
      
      public static function writeAacAudioDataPreamble(param1:ByteArray) : void
      {
         param1.writeByte(175);
         param1.writeByte(1);
      }
      
      public static function writeAvcVideoDataPreamble(param1:ByteArray, param2:Boolean, param3:int = 0) : void
      {
         param1.writeByte(param2 ? 23 : 39);
         param1.writeByte(1);
         param1.writeByte((param3 & 0xFF0000) >> 16);
         param1.writeByte((param3 & 0xFF00) >> 8);
         param1.writeByte(param3 & 0xFF);
      }
      
      public static function writeScriptTag(param1:ByteArray, param2:String, param3:uint, ... rest) : void
      {
         var _loc5_:Object = null;
         writeFrameHeader(param1,TAG_TYPE_SCRIPT,param3);
         param1.objectEncoding = ObjectEncoding.AMF0;
         param1.writeObject(param2);
         for each(_loc5_ in rest)
         {
            param1.writeObject(_loc5_);
         }
         writeFrameTrailer(param1);
      }
      
      public static function setFilterBit(param1:ByteArray, param2:Boolean) : void
      {
         if(param2)
         {
            param1[0] |= param1[0] & 0x20;
         }
         else
         {
            param1[0] &= param1[0] & 0xDF;
         }
      }
      
      public static function writeAvcSequenceHeaderPreamble(param1:ByteArray) : void
      {
         param1.writeByte(23);
         param1.writeByte(0);
         param1.writeByte(0);
         param1.writeByte(0);
         param1.writeByte(0);
      }
      
      public static function writeFlashAccessScriptTag(param1:ByteArray, param2:String) : void
      {
         writeScriptTag(param1,"|AdditionalHeader",0,{"Encryption":{
            "Version":2,
            "Method":"Standard",
            "Flags":0,
            "Params":{
               "Version":1,
               "EncryptionAlgorithm":"AES-CBC",
               "EncryptionParams":{"KeyLength":16},
               "KeyInfo":{
                  "Subtype":"FlashAccessv2",
                  "Data":{"Metadata":param2}
               }
            }
         }});
      }
      
      public static function getDataSize(param1:ByteArray) : uint
      {
         return param1[1] << 16 | param1[2] << 8 | param1[3];
      }
      
      public static function writeAacSequenceHeaderPreamble(param1:ByteArray) : void
      {
         param1.writeByte(175);
         param1.writeByte(0);
      }
      
      public static function setCompositionTimeOffset(param1:ByteArray, param2:int) : void
      {
         if(getTagType(param1) != TAG_TYPE_VIDEO || (param1[11] & 0x0F) != 7)
         {
            if(param2 != 0)
            {
               throw new Error();
            }
         }
         else
         {
            param1[13] = (param2 & 0xFF0000) >> 16;
            param1[14] = (param2 & 0xFF00) >> 8;
            param1[15] = param2 & 0xFF;
         }
      }
      
      public static function setDataSize(param1:ByteArray, param2:uint) : void
      {
         if(param2 & 0xFF000000)
         {
            throw new Error("Data size too large");
         }
         param1[1] = (param2 & 0xFF0000) >> 16;
         param1[2] = (param2 & 0xFF00) >> 8;
         param1[3] = (param2 & 0xFF) >> 0;
      }
      
      public static function setTimestamp(param1:ByteArray, param2:uint) : void
      {
         param1[4] = (param2 & 0xFF0000) >> 16;
         param1[5] = (param2 & 0xFF00) >> 8;
         param1[6] = (param2 & 0xFF) >> 0;
         param1[7] = (param2 & 0xFF000000) >> 24;
      }
      
      public static function readScriptTag(param1:ByteArray) : Object
      {
         param1.objectEncoding = ObjectEncoding.AMF0;
         param1.position = FRAME_HEADER_SIZE;
         var _loc2_:Object = {};
         _loc2_.name = param1.readObject();
         _loc2_.payload = param1.readObject();
         return _loc2_;
      }
      
      public static function getCompositionTimeOffset(param1:ByteArray) : int
      {
         if(getTagType(param1) != TAG_TYPE_VIDEO || (param1[11] & 0x0F) != 7)
         {
            return 0;
         }
         var _loc2_:* = 0;
         _loc2_ |= param1[13] << 16;
         _loc2_ |= param1[14] << 8;
         _loc2_ |= param1[15];
         if(_loc2_ & 1 << 23)
         {
            _loc2_ |= 4278190080;
         }
         return _loc2_;
      }
      
      public static function writeSelectiveEncryptionHeader(param1:ByteArray, param2:Boolean) : void
      {
         param1.writeByte(1);
         param1.writeUTF("SE");
         param1.writeByte(0);
         param1.writeByte(0);
         param1.writeByte(param2 ? 17 : 1);
         param1.writeByte(param2 ? 128 : 0);
      }
      
      public static function getTimestamp(param1:ByteArray) : uint
      {
         return param1[7] << 24 | param1[4] << 16 | param1[5] << 8 | param1[6];
      }
      
      protected static function formatToCodec(param1:String) : uint
      {
         return param1 == "5" ? 2 : 7;
      }
      
      public static function writeEndSeekTag(param1:ByteArray, param2:String, param3:uint) : void
      {
         writeFrameHeader(param1,TAG_TYPE_VIDEO,param3);
         param1.writeByte(0x50 | formatToCodec(param2));
         param1.writeByte(1);
         writeFrameTrailer(param1);
      }
      
      public static function getTagType(param1:ByteArray) : uint
      {
         return param1[0] & 0x1F;
      }
      
      public static function writeScriptedAccess(param1:ByteArray, param2:uint) : void
      {
         writeScriptTag(param1,"|RtmpSampleAccess",param2,true,true);
      }
      
      public static function writeEncryptionHeader(param1:ByteArray) : void
      {
         param1.writeByte(1);
         param1.writeUTF("Encryption");
         param1.writeByte(0);
         param1.writeByte(0);
         param1.writeByte(16);
      }
      
      public static function writeFrameHeader(param1:ByteArray, param2:uint, param3:uint) : void
      {
         param1.writeByte(param2);
         param1.writeByte(0);
         param1.writeByte(0);
         param1.writeByte(0);
         param1.writeByte((param3 & 0xFF0000) >> 16);
         param1.writeByte((param3 & 0xFF00) >> 8);
         param1.writeByte((param3 & 0xFF) >> 0);
         param1.writeByte((param3 & 0xFF000000) >> 24);
         param1.writeByte(0);
         param1.writeByte(0);
         param1.writeByte(0);
      }
      
      public static function writeFlvHeader(param1:ByteArray) : void
      {
         param1.writeByte("F".charCodeAt(0));
         param1.writeByte("L".charCodeAt(0));
         param1.writeByte("V".charCodeAt(0));
         param1.writeByte(1);
         param1.writeByte(5);
         param1.writeUnsignedInt(9);
         param1.writeUnsignedInt(0);
      }
   }
}

