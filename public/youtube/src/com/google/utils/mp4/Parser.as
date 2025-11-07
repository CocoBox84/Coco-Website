package com.google.utils.mp4
{
   import com.google.utils.IDataRead;
   import flash.utils.ByteArray;
   
   public class Parser
   {
      
      protected static const HEADER:int = 0;
      
      protected static const PAYLOAD:int = 1;
      
      protected static const VIDEO_TRACK:int = 118;
      
      protected static const AUDIO_TRACK:int = 115;
      
      protected static const HINT_TRACK:int = 104;
      
      protected static const META_TRACK:int = 109;
      
      protected static const ATOM_HEADER_SIZE:int = 8;
      
      protected static const VERSION_OFFSET:int = 8;
      
      protected static const FLAGS_OFFSET:int = 9;
      
      protected static const FULL_ATOM_HEADER_SIZE:int = 12;
      
      protected static const UINT_LENGTH:int = 4;
      
      protected static const AVC1:String = "avc1";
      
      protected static const CTTS:String = "ctts";
      
      protected static const ESDS:String = "esds";
      
      protected static const HDLR:String = "hdlr";
      
      protected static const ILST:String = "ilst";
      
      protected static const MDAT:String = "mdat";
      
      protected static const MDHD:String = "mdhd";
      
      protected static const META:String = "meta";
      
      protected static const MFHD:String = "mfhd";
      
      protected static const MOOF:String = "moof";
      
      protected static const MOOV:String = "moov";
      
      protected static const MP4A:String = "mp4a";
      
      protected static const SIDX:String = "sidx";
      
      protected static const STCO:String = "stco";
      
      protected static const STSC:String = "stsc";
      
      protected static const STSD:String = "stsd";
      
      protected static const STSS:String = "stss";
      
      protected static const STSZ:String = "stsz";
      
      protected static const STTS:String = "stts";
      
      protected static const TFDT:String = "tfdt";
      
      protected static const TFHD:String = "tfhd";
      
      protected static const TKHD:String = "tkhd";
      
      protected static const TRAF:String = "traf";
      
      protected static const TRAK:String = "trak";
      
      protected static const TREX:String = "trex";
      
      protected static const TRUN:String = "trun";
      
      protected var meta:Atom;
      
      protected var audioSpecificConfigValue:ByteArray;
      
      protected var moov:Object;
      
      protected var parsedAudioTrak:Object;
      
      protected var videoTrackIndex:int = -1;
      
      protected var traf:Object;
      
      protected var sidxTimestamps:Array;
      
      protected var trak:Object;
      
      protected var parsedVideoTrak:Object;
      
      protected var atomOffset:uint;
      
      protected var atom:Atom = new Atom();
      
      protected var parsedTrexs:Object;
      
      protected var chunkIndex:uint;
      
      protected var sidx:Atom;
      
      protected var sidxOffsets:Array;
      
      protected var googleAtoms:Object = {};
      
      protected var avcConfigBytesValue:ByteArray;
      
      protected var trun:Object;
      
      protected var audioTrackIndex:int = -1;
      
      protected var atomParseState:int = 0;
      
      protected var trexs:Array;
      
      protected var moof:Object;
      
      public function Parser()
      {
         super();
      }
      
      protected function parseCtts(param1:Atom, param2:uint) : Array
      {
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:int = 0;
         var _loc3_:Array = [];
         param1.position = FULL_ATOM_HEADER_SIZE;
         var _loc4_:uint = param1.readUnsignedInt();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = param1.readUnsignedInt();
            _loc7_ = param1.readUnsignedInt();
            _loc8_ = 0;
            while(_loc8_ < _loc6_)
            {
               _loc3_.push(_loc7_ * 1000 / param2);
               _loc8_++;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      protected function parseTrex(param1:Atom) : Object
      {
         var _loc2_:Object = {};
         param1.position = FULL_ATOM_HEADER_SIZE;
         _loc2_.trackId = param1.readUnsignedInt();
         _loc2_.defaultSampleDescriptionIndex = param1.readUnsignedInt();
         _loc2_.defaultSampleDuration = param1.readUnsignedInt();
         _loc2_.defaultSampleSize = param1.readUnsignedInt();
         _loc2_.defaultSampleFlags = param1.readUnsignedInt();
         return _loc2_;
      }
      
      protected function parseTkhd(param1:Atom) : Object
      {
         var _loc2_:Object = {};
         param1.position = VERSION_OFFSET;
         _loc2_.version = param1.readUnsignedByte();
         _loc2_.flags = param1.readUInt24();
         _loc2_.enabled = Boolean(_loc2_.flags & 0x800000);
         if(_loc2_.version == 0)
         {
            _loc2_.creationTime = param1.readUnsignedInt();
            _loc2_.modificationTime = param1.readUnsignedInt();
         }
         else if(_loc2_.version == 1)
         {
            throw new Error();
         }
         _loc2_.trackId = param1.readUnsignedInt();
         var _loc3_:uint = param1.readUnsignedInt();
         if(_loc2_.version == 0)
         {
            _loc2_.duration = param1.readUnsignedInt();
         }
         else if(_loc2_.version == 1)
         {
            throw new Error();
         }
         param1.position = 84;
         _loc2_.width = param1.readFixedPoint1616();
         _loc2_.height = param1.readFixedPoint1616();
         return _loc2_;
      }
      
      protected function badACOT() : void
      {
         throw new VerifyError();
      }
      
      public function getFileSize() : Number
      {
         if(this.sidxOffsets)
         {
            return this.sidxOffsets[this.sidxOffsets.length - 1];
         }
         var _loc1_:uint = this.videoSampleSizeTable.length - 1;
         var _loc2_:uint = this.videoSampleOffset(_loc1_);
         var _loc3_:uint = _loc2_ + this.videoSampleSizeTable[_loc1_];
         var _loc4_:uint = this.audioSampleSizeTable.length - 1;
         var _loc5_:uint = this.audioSampleOffset(_loc4_);
         var _loc6_:uint = _loc5_ + this.audioSampleSizeTable[_loc4_];
         return Math.max(_loc3_,_loc6_);
      }
      
      public function get audioSampleSizeTable() : Array
      {
         return this.parsedAudioTrak.sampleSizeTable;
      }
      
      public function get indexOffsets() : Array
      {
         return this.sidxOffsets;
      }
      
      protected function parseIlst(param1:Atom) : Object
      {
         var _loc4_:Atom = null;
         var _loc5_:Object = null;
         var _loc2_:Object = {
            "gsst":true,
            "gstd":true,
            "gssd":true,
            "gspu":true,
            "gspm":true,
            "gshh":true
         };
         var _loc3_:Object = {};
         param1.position = ATOM_HEADER_SIZE;
         while(param1.position < param1.length)
         {
            _loc4_ = param1.readAtom();
            if(_loc4_.type in _loc2_)
            {
               _loc5_ = this.parseGoogleAtom(param1.readAtom());
               _loc3_[_loc5_.name] = _loc5_.value;
            }
         }
         return _loc3_;
      }
      
      public function getVideoStreamWidth() : int
      {
         return this.parsedVideoTrak.tkhd.width;
      }
      
      protected function parseMdhd(param1:Atom) : uint
      {
         param1.position = 20;
         return param1.readUnsignedInt();
      }
      
      public function getVideoStreamHeight() : int
      {
         return this.parsedVideoTrak.tkhd.height;
      }
      
      public function get sampleCompositionTimeOffsetTable() : Array
      {
         return this.parsedVideoTrak.sampleCompositionTimeOffsetTable;
      }
      
      protected function parseGoogleAtom(param1:Atom) : Object
      {
         param1.position = 4;
         var _loc2_:String = param1.readUTFBytes(4);
         var _loc3_:uint = param1.readUnsignedInt();
         param1.position += 12;
         return {
            "name":_loc2_,
            "value":param1.readUTFBytes(_loc3_ - 16)
         };
      }
      
      protected function fastFailRteVerify() : void
      {
         if(!this.audioSpecificConfigValue || !this.audioSpecificConfigValue.length)
         {
            this.badAac();
         }
         if(!this.avcConfigBytesValue || !this.avcConfigBytesValue.length)
         {
            this.badAvc();
         }
         if(this.nullOrEmpty(this.parsedVideoTrak.sampleTimeTable))
         {
            this.badVSTT();
         }
         if(this.nullOrEmpty(this.parsedAudioTrak.sampleTimeTable))
         {
            this.badASTT();
         }
         if(this.nullOrEmpty(this.parsedVideoTrak.sampleChunkTable))
         {
            this.badVSCT();
         }
         if(this.nullOrEmpty(this.parsedAudioTrak.sampleChunkTable))
         {
            this.badASCT();
         }
         if(this.nullOrEmpty(this.parsedVideoTrak.sampleSizeTable))
         {
            this.badVSST();
         }
         if(this.nullOrEmpty(this.parsedAudioTrak.sampleSizeTable))
         {
            this.badASST();
         }
         if(this.nullOrEmpty(this.parsedVideoTrak.chunkOffsetTable))
         {
            this.badVCOT();
         }
         if(this.nullOrEmpty(this.parsedAudioTrak.chunkOffsetTable))
         {
            this.badACOT();
         }
         if(this.nullOrEmpty(this.parsedVideoTrak.syncOffsetTable))
         {
            this.badVSOT();
         }
      }
      
      protected function badDim() : void
      {
         throw new VerifyError();
      }
      
      protected function parseMoof(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc2_:uint = this.parseMovieFragmentHeader(param1[MFHD]);
         for each(_loc3_ in this.moof.trafs)
         {
            this.parseTrafFragmentAtoms(_loc3_);
         }
      }
      
      public function get videoSampleChunkTable() : Array
      {
         return this.parsedVideoTrak.sampleChunkTable;
      }
      
      protected function parseAtoms() : void
      {
         var _loc2_:Object = null;
         if(this.moov)
         {
            this.parseMoov();
         }
         if(this.moof)
         {
            this.parseMoof(this.moof);
         }
         var _loc1_:Boolean = Boolean(this.sidxTimestamps) && Boolean(this.sidxOffsets);
         if(Boolean(this.sidx) && !_loc1_)
         {
            _loc2_ = this.parseSidx(this.sidx);
            this.sidxTimestamps = _loc2_.timestamps;
            this.sidxOffsets = _loc2_.offsets;
         }
         this.moof = null;
         this.moov = null;
         this.trak = null;
         this.meta = null;
         this.atom = null;
         this.sidx = null;
      }
      
      protected function chunkRelativeOffset(param1:Array, param2:Array, param3:uint, param4:uint) : uint
      {
         var _loc5_:uint = 0;
         while(param4 > 0 && param1[--param4] == param3)
         {
            _loc5_ += param2[param4];
         }
         return _loc5_;
      }
      
      public function getAudioSpecificConfig() : ByteArray
      {
         return this.audioSpecificConfigValue;
      }
      
      protected function parseAacConfigFromStsd(param1:Atom) : ByteArray
      {
         var _loc4_:uint = 0;
         var _loc5_:String = null;
         param1.position = FULL_ATOM_HEADER_SIZE;
         var _loc2_:int = int(param1.readUnsignedInt());
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = param1.readUnsignedInt();
            _loc5_ = param1.readUTFBytes(4);
            if(_loc5_ == MP4A)
            {
               break;
            }
            param1.position += _loc4_ - 2 * UINT_LENGTH;
            _loc3_++;
         }
         if(_loc5_ != MP4A)
         {
            return null;
         }
         param1.position += 28;
         return this.aacFromEsds(param1);
      }
      
      public function readAtoms(param1:IDataRead) : Boolean
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         while(true)
         {
            if(this.atomParseState == HEADER)
            {
               _loc2_ = uint(ATOM_HEADER_SIZE - this.atom.length);
               _loc3_ = param1.read(this.atom,this.atom.length,_loc2_);
               this.atomOffset += _loc3_;
               if(_loc2_ != _loc3_)
               {
                  break;
               }
               if(this.atom.type == MDAT)
               {
                  this.parseAtoms();
                  this.atomParseState = HEADER;
                  this.atom = new Atom();
                  return true;
               }
               this.registerAtom(this.atom);
               if(this.atom.isContainer)
               {
                  this.atom = new Atom();
                  this.atomParseState = HEADER;
               }
               else
               {
                  this.atomParseState = PAYLOAD;
               }
            }
            else if(this.atomParseState == PAYLOAD)
            {
               _loc2_ = uint(this.atom.size - this.atom.length);
               _loc3_ = param1.read(this.atom,this.atom.length,_loc2_);
               this.atomOffset += _loc3_;
               if(_loc2_ != _loc3_)
               {
                  return false;
               }
               if(this.atom.type == SIDX)
               {
                  this.parseAtoms();
                  this.atomParseState = HEADER;
                  this.atom = new Atom();
                  this.atom.offset = 0;
                  return true;
               }
               this.atomParseState = HEADER;
               this.atom = new Atom();
               this.atom.offset = this.atomOffset;
            }
         }
         return false;
      }
      
      public function get audioChunkOffsetTable() : Array
      {
         return this.parsedAudioTrak.chunkOffsetTable;
      }
      
      protected function parseMeta(param1:Atom) : Object
      {
         var _loc3_:Atom = null;
         param1.position = ATOM_HEADER_SIZE;
         var _loc2_:uint = param1.readUnsignedInt();
         while(param1.position < param1.length)
         {
            _loc3_ = param1.readAtom();
            if(_loc3_.type == ILST)
            {
               return this.parseIlst(_loc3_);
            }
         }
         return {};
      }
      
      protected function badVSST() : void
      {
         throw new VerifyError();
      }
      
      protected function parseMoov() : void
      {
         var _loc1_:Atom = null;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         for each(_loc1_ in this.trexs)
         {
            this.parsedTrexs = this.parsedTrexs || {};
            _loc5_ = this.parseTrex(_loc1_);
            this.parsedTrexs[_loc5_.trackId] = _loc5_;
         }
         _loc4_ = 0;
         while(_loc4_ < this.moov.traks.length)
         {
            _loc6_ = this.parseTrakAtoms(this.moov.traks[_loc4_]);
            if(_loc6_.trackType == AUDIO_TRACK)
            {
               this.audioTrackIndex = _loc6_.tkhd.trackId;
               _loc3_ = this.moov.traks[_loc4_];
               this.parsedAudioTrak = _loc6_;
            }
            else if(_loc6_.trackType == VIDEO_TRACK)
            {
               this.videoTrackIndex = _loc6_.tkhd.trackId;
               _loc2_ = this.moov.traks[_loc4_];
               this.parsedVideoTrak = _loc6_;
            }
            _loc4_++;
         }
         if(this.parsedVideoTrak)
         {
            this.avcConfigBytesValue = this.parseAvcFromStsd(_loc2_[STSD]);
         }
         if(this.parsedAudioTrak)
         {
            this.audioSpecificConfigValue = this.parseAacConfigFromStsd(_loc3_[STSD]);
         }
         if(this.meta)
         {
            this.googleAtoms = this.parseMeta(this.meta);
         }
         this.moov = null;
         this.trak = null;
         this.meta = null;
         this.atom = null;
      }
      
      public function get videoSyncOffsetTable() : Array
      {
         return this.parsedVideoTrak.syncOffsetTable;
      }
      
      protected function badVSCT() : void
      {
         throw new VerifyError();
      }
      
      protected function parseTrackFragmentHeader(param1:Atom) : Object
      {
         var _loc2_:Object = {};
         param1.position = FLAGS_OFFSET;
         var _loc3_:uint = param1.readUInt24();
         _loc2_.trackId = param1.readUnsignedInt();
         if(_loc3_ & 1)
         {
            _loc2_.baseDataOffsetLow = param1.readUnsignedInt();
            _loc2_.baseDataOffsetHigh = param1.readUnsignedInt();
         }
         if(_loc3_ & 2)
         {
            _loc2_.sampleDescriptionOffset = param1.readUnsignedInt();
         }
         if(_loc3_ & 8)
         {
            _loc2_.defaultSampleDuration = param1.readUnsignedInt();
         }
         if(_loc3_ & 0x10)
         {
            _loc2_.defaultSampleSize = param1.readUnsignedInt();
         }
         if(_loc3_ & 0x20)
         {
            _loc2_.defaultSampleFlags = param1.readUnsignedInt();
         }
         _loc2_.durationIsEmpty = Boolean(_loc3_ & 0x010000);
         return _loc2_;
      }
      
      protected function parseAvcFromStsd(param1:Atom) : ByteArray
      {
         var _loc4_:uint = 0;
         var _loc5_:String = null;
         var _loc6_:uint = 0;
         var _loc7_:String = null;
         param1.position = FULL_ATOM_HEADER_SIZE;
         var _loc2_:int = int(param1.readUnsignedInt());
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = param1.readUnsignedInt();
            _loc5_ = param1.readUTFBytes(4);
            param1.position += 78;
            if(_loc5_ == AVC1)
            {
               _loc6_ = param1.readUnsignedInt();
               _loc7_ = param1.readUTFBytes(4);
               return param1.copyBytes(_loc6_ - 8);
            }
            _loc3_++;
         }
         return null;
      }
      
      public function get videoSampleTimeTable() : Array
      {
         return this.parsedVideoTrak.sampleTimeTable;
      }
      
      protected function badVSTT() : void
      {
         throw new VerifyError();
      }
      
      protected function parseTrakAtoms(param1:Object) : Object
      {
         var _loc2_:Object = {};
         _loc2_.tkhd = this.parseTkhd(param1[TKHD]);
         _loc2_.trackType = this.parseHdlr(param1[HDLR]);
         _loc2_.timeScale = this.parseMdhd(param1[MDHD]);
         _loc2_.sampleSizeTable = this.parseStsz(param1[STSZ]);
         var _loc3_:uint = uint(_loc2_.timeScale);
         _loc2_.sampleTimeTable = this.parseStts(param1[STTS],_loc3_);
         var _loc4_:uint = uint(_loc2_.sampleTimeTable.length);
         _loc2_.sampleChunkTable = this.parseStsc(param1[STSC],_loc4_);
         _loc2_.chunkOffsetTable = this.parseStco(param1[STCO]);
         if(STSS in param1)
         {
            _loc2_.syncOffsetTable = this.parseStss(param1[STSS]);
         }
         if(CTTS in param1)
         {
            _loc2_.compositionTimeOffsets = this.parseCtts(param1[CTTS],_loc3_);
         }
         return _loc2_;
      }
      
      public function get indexTimestamps() : Array
      {
         return this.sidxTimestamps;
      }
      
      protected function badAvc() : void
      {
         throw new VerifyError();
      }
      
      public function getAvcConfigBytes() : ByteArray
      {
         return this.avcConfigBytesValue;
      }
      
      protected function registerAtom(param1:Atom) : void
      {
         switch(param1.type)
         {
            case MOOV:
               this.moov = {};
               break;
            case MOOF:
               this.moof = {};
               break;
            case TRAK:
               this.trak = {};
               this.moov.traks = this.moov.traks || [];
               this.moov.traks.push(this.trak);
               break;
            case TRAF:
               this.traf = {};
               this.moof.trafs = this.moof.trafs || [];
               this.moof.trafs.push(this.traf);
               break;
            case TREX:
               this.trexs = this.trexs || [];
               this.trexs.push(param1);
               break;
            case TRUN:
               this.traf.truns = this.traf.truns || [];
               this.traf.truns.push(param1);
               break;
            case MFHD:
               this.moof[param1.type] = param1;
               break;
            case META:
               this.meta = param1;
               break;
            case SIDX:
               this.sidx = param1;
               break;
            case TFDT:
            case TFHD:
               this.traf[param1.type] = param1;
               break;
            case CTTS:
            case HDLR:
            case MDHD:
            case STCO:
            case STSC:
            case STSD:
            case STSS:
            case STSZ:
            case STTS:
            case TKHD:
               this.trak[param1.type] = param1;
         }
      }
      
      protected function badASST() : void
      {
         throw new VerifyError();
      }
      
      protected function parseMovieFragmentHeader(param1:Atom) : uint
      {
         param1.position = FULL_ATOM_HEADER_SIZE;
         return param1.readUnsignedInt();
      }
      
      public function get audioSampleChunkTable() : Array
      {
         return this.parsedAudioTrak.sampleChunkTable;
      }
      
      protected function nullOrEmpty(param1:Array) : Boolean
      {
         return !param1 || !param1.length;
      }
      
      public function get hasAudioTrak() : Boolean
      {
         return this.audioTrackIndex != -1;
      }
      
      public function resetSampleTables() : void
      {
         if(this.parsedVideoTrak)
         {
            this.parsedVideoTrak.sampleTimeTable = [];
            this.parsedVideoTrak.sampleChunkTable = [];
            this.parsedVideoTrak.sampleSizeTable = [];
            this.parsedVideoTrak.chunkOffsetTable = [];
            this.parsedVideoTrak.syncOffsetTable = [];
            this.parsedVideoTrak.sampleCompositionTimeOffsetTable = null;
         }
         if(this.parsedAudioTrak)
         {
            this.parsedAudioTrak.sampleTimeTable = [];
            this.parsedAudioTrak.sampleChunkTable = [];
            this.parsedAudioTrak.sampleSizeTable = [];
            this.parsedAudioTrak.chunkOffsetTable = [];
         }
      }
      
      protected function badASCT() : void
      {
         throw new VerifyError();
      }
      
      protected function parseTrackFragmentRun(param1:Object, param2:Atom) : void
      {
         var _loc6_:Object = null;
         var _loc12_:Array = null;
         var _loc17_:int = 0;
         var _loc18_:uint = 0;
         var _loc19_:uint = 0;
         var _loc20_:uint = 0;
         var _loc21_:uint = 0;
         var _loc22_:* = false;
         var _loc23_:uint = 0;
         param2.position = FLAGS_OFFSET;
         var _loc3_:uint = param2.readUInt24();
         var _loc4_:uint = param2.readUnsignedInt();
         if(_loc3_ & 1)
         {
            _loc17_ = int(param2.readUnsignedInt());
         }
         if(_loc3_ & 4)
         {
            throw new Error("first sample flags unhandled");
         }
         var _loc5_:Object = this.parsedTrexs[param1.tfhd.trackId];
         if(param1.tfhd.trackId == this.audioTrackIndex)
         {
            _loc6_ = this.parsedAudioTrak;
         }
         else
         {
            if(param1.tfhd.trackId != this.videoTrackIndex)
            {
               throw new Error();
            }
            _loc6_ = this.parsedVideoTrak;
         }
         var _loc7_:uint = uint(_loc6_.timeScale);
         var _loc8_:Array = _loc6_.sampleTimeTable;
         var _loc9_:Array = _loc6_.sampleSizeTable;
         var _loc10_:Array = _loc6_.chunkOffsetTable;
         var _loc11_:Array = _loc6_.sampleChunkTable;
         if(_loc6_.sampleCompositionTimeOffsetTable)
         {
            _loc12_ = _loc6_.sampleCompositionTimeOffsetTable;
         }
         else if(_loc3_ & 0x0800)
         {
            _loc6_.sampleCompositionTimeOffsetTable = [];
            _loc12_ = _loc6_.sampleCompositionTimeOffsetTable;
         }
         _loc10_.push(this.chunkIndex++);
         var _loc13_:uint = _loc10_.length - 1;
         var _loc14_:int = int(param1.decodeTime);
         var _loc15_:uint = _loc9_.length;
         var _loc16_:uint = 0;
         while(_loc16_ < _loc4_)
         {
            _loc19_ = uint(_loc3_ & 0x0100 ? param2.readUnsignedInt() : uint(param1.tfhd.defaultSampleDuration) || uint(_loc5_.defaultSampleDuration));
            _loc20_ = uint(_loc3_ & 0x0200 ? param2.readUnsignedInt() : uint(param1.tfhd.defaultSampleSize) || uint(_loc5_.defaultSampleSize));
            _loc21_ = uint(_loc3_ & 0x0400 ? param2.readUnsignedInt() : uint(param1.tfhd.defaultSampleFlags) || uint(_loc5_.defaultSampleFlags));
            if(_loc3_ & 0x0800)
            {
               _loc23_ = param2.readUnsignedInt() * 1000 / _loc7_;
               _loc12_.push(_loc23_);
            }
            _loc22_ = (_loc21_ >> 16 & 1) == 0;
            _loc8_.push(Math.round(_loc14_ * 1000 / _loc7_));
            _loc9_.push(_loc20_);
            _loc11_.push(_loc13_);
            if(_loc22_)
            {
               _loc6_.syncOffsetTable = _loc6_.syncOffsetTable || [];
               _loc6_.syncOffsetTable[_loc15_ + _loc16_] = true;
            }
            _loc14_ += _loc19_;
            _loc16_++;
         }
      }
      
      protected function badASTT() : void
      {
         throw new VerifyError();
      }
      
      public function getTrueStart() : int
      {
         return parseInt(this.googleAtoms.gsst);
      }
      
      public function get audioSampleTimeTable() : Array
      {
         return this.parsedAudioTrak.sampleTimeTable;
      }
      
      protected function parseTrackFragmentDecodeTime(param1:Atom) : uint
      {
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         param1.position = VERSION_OFFSET;
         var _loc2_:uint = param1.readUnsignedByte();
         param1.position += 3;
         if(_loc2_ == 1)
         {
            throw new Error("unsupported 64 bit decode time");
         }
         return param1.readUnsignedInt();
      }
      
      public function get videoSampleSizeTable() : Array
      {
         return this.parsedVideoTrak.sampleSizeTable;
      }
      
      public function get hasVideoTrak() : Boolean
      {
         return this.videoTrackIndex != -1;
      }
      
      protected function parseStsc(param1:Atom, param2:uint) : Array
      {
         var _loc5_:int = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc3_:Array = [];
         param1.position = FULL_ATOM_HEADER_SIZE;
         var _loc4_:uint = param1.readUnsignedInt();
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_)
         {
            _loc7_ = param1.readUnsignedInt();
            _loc8_ = param1.readUnsignedInt();
            param1.position += UINT_LENGTH;
            _loc9_ = uint(param2 - _loc5_);
            if(_loc6_ < _loc4_ - 1)
            {
               _loc10_ = param1.readUnsignedInt();
               param1.position -= UINT_LENGTH;
            }
            else
            {
               _loc10_ = _loc7_ + _loc9_ / _loc8_;
            }
            _loc12_ = int(_loc7_);
            while(_loc12_ < _loc10_)
            {
               _loc11_ = _loc5_;
               _loc13_ = 0;
               while(_loc13_ < _loc8_)
               {
                  _loc3_.push(_loc12_ - 1);
                  _loc5_++;
                  _loc13_++;
               }
               _loc12_++;
            }
            _loc6_++;
         }
         return _loc3_;
      }
      
      protected function parseSidx(param1:Atom) : Object
      {
         var _loc14_:uint = 0;
         var _loc15_:uint = 0;
         var _loc16_:Boolean = false;
         var _loc17_:uint = 0;
         var _loc18_:uint = 0;
         var _loc19_:uint = 0;
         var _loc20_:Boolean = false;
         var _loc21_:uint = 0;
         var _loc22_:uint = 0;
         param1.position = VERSION_OFFSET;
         var _loc2_:uint = param1.readUnsignedByte();
         param1.position += 3;
         var _loc3_:uint = param1.readUnsignedInt();
         var _loc4_:uint = param1.readUnsignedInt();
         if(_loc2_ != 0)
         {
            throw new Error();
         }
         var _loc5_:uint = param1.readUnsignedInt();
         var _loc6_:uint = param1.readUnsignedInt();
         var _loc7_:uint = param1.readUnsignedShort();
         var _loc8_:uint = param1.readUnsignedShort();
         var _loc9_:Array = [];
         var _loc10_:Array = [];
         var _loc11_:uint = param1.offset + param1.length + _loc6_;
         var _loc12_:uint = _loc5_;
         var _loc13_:uint = 0;
         while(_loc13_ < _loc8_)
         {
            _loc14_ = Math.round(_loc12_ * 1000 / _loc4_);
            if(Math.abs(_loc14_ % 10000 - 5000) >= 100)
            {
               _loc10_.push(_loc11_);
               _loc9_.push(_loc14_);
            }
            _loc15_ = param1.readUnsignedInt();
            _loc16_ = Boolean(_loc15_ & 0x80000000);
            if(_loc16_)
            {
               throw new Error();
            }
            _loc17_ = uint(_loc15_ & 0x7FFFFFFF);
            _loc18_ = param1.readUnsignedInt();
            _loc19_ = param1.readUnsignedInt();
            _loc20_ = Boolean(_loc19_ & 0x80000000);
            _loc21_ = uint((_loc19_ & 0x70000000) >> 28);
            _loc22_ = uint(_loc19_ & 0x0FFFFFFF);
            if(_loc20_)
            {
            }
            _loc11_ += _loc15_ & 0x7FFFFFFF;
            _loc12_ += _loc18_;
            _loc13_++;
         }
         _loc10_.push(_loc11_);
         _loc9_.push(_loc12_);
         return {
            "timestamps":_loc9_,
            "offsets":_loc10_
         };
      }
      
      public function audioSampleOffset(param1:uint) : uint
      {
         var _loc2_:uint = uint(this.audioSampleChunkTable[param1]);
         var _loc3_:uint = uint(this.audioChunkOffsetTable[_loc2_]);
         return _loc3_ + this.chunkRelativeOffset(this.audioSampleChunkTable,this.audioSampleSizeTable,_loc2_,param1);
      }
      
      protected function parseStss(param1:Atom) : Array
      {
         var _loc2_:Array = [];
         param1.position = FULL_ATOM_HEADER_SIZE;
         var _loc3_:uint = param1.readUnsignedInt();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_[param1.readUnsignedInt() - 1] = true;
            _loc4_++;
         }
         return _loc2_;
      }
      
      protected function parseHdlr(param1:Atom) : int
      {
         return param1[16];
      }
      
      protected function badVCOT() : void
      {
         throw new VerifyError();
      }
      
      protected function parseStco(param1:Atom) : Array
      {
         var _loc2_:Array = [];
         param1.position = FULL_ATOM_HEADER_SIZE;
         var _loc3_:uint = param1.readUnsignedInt();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_.push(param1.readUnsignedInt());
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function get muxedFileComplete() : Boolean
      {
         return this.audioSpecificConfigValue && this.audioSpecificConfigValue.length && this.avcConfigBytesValue && Boolean(this.avcConfigBytesValue.length) && Boolean(this.parsedVideoTrak.tkhd.width) && Boolean(this.parsedVideoTrak.tkhd.height) && Boolean(this.parsedVideoTrak.sampleTimeTable) && Boolean(this.parsedAudioTrak.sampleTimeTable) && Boolean(this.parsedVideoTrak.sampleChunkTable) && Boolean(this.parsedAudioTrak.sampleChunkTable) && Boolean(this.parsedVideoTrak.sampleSizeTable) && Boolean(this.parsedAudioTrak.sampleSizeTable) && Boolean(this.parsedVideoTrak.chunkOffsetTable) && Boolean(this.parsedAudioTrak.chunkOffsetTable) && Boolean(this.parsedVideoTrak.syncOffsetTable);
      }
      
      protected function badVSOT() : void
      {
         throw new VerifyError();
      }
      
      public function get videoChunkOffsetTable() : Array
      {
         return this.parsedVideoTrak.chunkOffsetTable;
      }
      
      protected function aacFromEsds(param1:Atom) : ByteArray
      {
         var _loc2_:int = int(param1.readUnsignedInt());
         var _loc3_:String = param1.readUTFBytes(4);
         if(_loc3_ != ESDS)
         {
            return null;
         }
         param1.position += 4;
         param1.position += 1;
         var _loc4_:uint = param1.readUnsignedByte();
         while(_loc4_ > 127)
         {
            _loc4_ = param1.readUnsignedByte();
         }
         param1.position += 2;
         var _loc5_:uint = param1.readUnsignedByte();
         if(_loc5_ & 0x20)
         {
            param1.position += 2;
         }
         if(_loc5_ & 0x40)
         {
            param1.position += param1.readUnsignedShort();
         }
         if(_loc5_ & 0x80)
         {
            param1.position += 2;
         }
         param1.position += 1;
         _loc4_ = param1.readUnsignedByte();
         while(_loc4_ > 127)
         {
            _loc4_ = param1.readUnsignedByte();
         }
         param1.position += 13;
         param1.position += 1;
         _loc4_ = param1.readUnsignedByte();
         var _loc6_:uint = uint(_loc4_ & 0x7F);
         while(_loc4_ > 127)
         {
            _loc4_ = param1.readUnsignedByte();
            _loc6_ <<= 8;
            _loc6_ = uint(_loc6_ | _loc4_ & 0x7F);
         }
         var _loc7_:ByteArray = new ByteArray();
         var _loc8_:uint = 0;
         while(_loc8_ < _loc6_)
         {
            _loc7_.writeByte(param1.readUnsignedByte());
            _loc8_++;
         }
         return _loc7_;
      }
      
      protected function parseStts(param1:Atom, param2:uint) : Array
      {
         var _loc5_:uint = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc3_:Array = [];
         param1.position = FULL_ATOM_HEADER_SIZE;
         var _loc4_:uint = param1.readUnsignedInt();
         var _loc8_:int = 0;
         while(_loc8_ < _loc4_)
         {
            _loc5_ = param1.readUnsignedInt();
            _loc6_ = int(param1.readUnsignedInt());
            _loc9_ = 0;
            while(_loc9_ < _loc5_)
            {
               _loc3_.push(Math.round(_loc7_ * 1000 / param2));
               _loc7_ += _loc6_;
               _loc9_++;
            }
            _loc8_++;
         }
         return _loc3_;
      }
      
      public function videoSampleOffset(param1:uint) : uint
      {
         var _loc2_:uint = uint(this.videoSampleChunkTable[param1]);
         var _loc3_:uint = uint(this.videoChunkOffsetTable[_loc2_]);
         return _loc3_ + this.chunkRelativeOffset(this.videoSampleChunkTable,this.videoSampleSizeTable,_loc2_,param1);
      }
      
      public function getHttpHostHeader() : String
      {
         return this.googleAtoms.gshh;
      }
      
      protected function parseTrafFragmentAtoms(param1:Object) : void
      {
         var _loc3_:Atom = null;
         var _loc2_:Object = {};
         _loc2_.tfhd = this.parseTrackFragmentHeader(param1[TFHD]);
         _loc2_.decodeTime = this.parseTrackFragmentDecodeTime(param1[TFDT]);
         for each(_loc3_ in param1.truns)
         {
            this.parseTrackFragmentRun(_loc2_,_loc3_);
         }
      }
      
      protected function parseStsz(param1:Atom) : Array
      {
         var _loc5_:int = 0;
         var _loc2_:Array = [];
         param1.position = FULL_ATOM_HEADER_SIZE;
         var _loc3_:uint = param1.readUnsignedInt();
         var _loc4_:uint = param1.readUnsignedInt();
         if(_loc3_ == 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc2_.push(param1.readUnsignedInt());
               _loc5_++;
            }
         }
         else
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc2_.push(_loc3_);
               _loc5_++;
            }
         }
         return _loc2_;
      }
      
      protected function badAac() : void
      {
         throw new VerifyError();
      }
   }
}

