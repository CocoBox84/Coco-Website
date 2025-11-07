package com.google.utils.mp4
{
   import flash.utils.ByteArray;
   
   public class Atom extends ByteArray
   {
      
      protected static const HEADER_SIZE:int = 8;
      
      protected static const ATOM_CONTAINER_TYPES:Object = {
         "moov":true,
         "trak":true,
         "udta":true,
         "tref":true,
         "imap":true,
         "mdia":true,
         "minf":true,
         "stbl":true,
         "edts":true,
         "mdra":true,
         "rmra":true,
         "imag":true,
         "vnrp":true,
         "dinf":true,
         "avcC":true,
         "moof":true,
         "traf":true,
         "mvex":true
      };
      
      protected static const TRAK_ATOM_TYPES:Object = {
         "tkhd":true,
         "mdia":true,
         "mdhd":true,
         "hdlr":true,
         "minf":true,
         "vmhd":true,
         "dinf":true,
         "dref":true,
         "stbl":true,
         "stsd":true,
         "stts":true,
         "stss":true,
         "stsc":true,
         "stsz":true,
         "stco":true
      };
      
      public var offset:uint;
      
      public function Atom()
      {
         super();
      }
      
      public function get size() : uint
      {
         position = 0;
         return readUnsignedInt();
      }
      
      public function readUInt24() : uint
      {
         var _loc1_:uint = readUnsignedByte();
         _loc1_ <<= 8;
         _loc1_ |= readUnsignedByte();
         _loc1_ <<= 8;
         return uint(_loc1_ | readUnsignedByte());
      }
      
      public function readAtom() : Atom
      {
         var _loc1_:Atom = new Atom();
         var _loc2_:uint = readUnsignedInt();
         _loc1_.writeUnsignedInt(_loc2_);
         _loc1_.writeBytes(this,position,_loc2_ - 4);
         position += _loc2_ - 4;
         _loc1_.position = 0;
         return _loc1_;
      }
      
      public function get type() : String
      {
         position = 4;
         return readUTFBytes(4);
      }
      
      public function readFixedPoint1616() : uint
      {
         var _loc1_:uint = readUnsignedShort();
         position += 2;
         return _loc1_;
      }
      
      public function copyBytes(param1:int) : ByteArray
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeBytes(this,position,param1);
         position += param1;
         return _loc2_;
      }
      
      public function get isContainer() : Boolean
      {
         return this.type in ATOM_CONTAINER_TYPES;
      }
   }
}

