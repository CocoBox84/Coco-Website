package com.google.youtube.util.hls
{
   import com.google.utils.ArrayUtils;
   import com.google.utils.Url;
   import com.google.youtube.model.AudioTrack;
   import com.google.youtube.model.VideoFormat;
   import flash.utils.ByteArray;
   
   public class HlsParser
   {
      
      protected static const M2TS_MIME_MATCH:RegExp = /video\/mp2t/i;
      
      protected static const HLS_MIME_TYPE:String = "application/vnd.apple.mpegurl";
      
      protected static const NEWLINE_CODE:uint = 10;
      
      protected static const HEADER:String = "#EXTM3U\n";
      
      protected static const ABSOLUTE_MATCH:RegExp = /^https?:/;
      
      protected static const ITAG_MATCH:RegExp = /itag(\/|=|%3[dD])([0-9]+)/;
      
      protected static const TAG_MATCH:RegExp = /^#([-A-Za-z]*)?:?(.*)/;
      
      protected static const DECIMAL_MATCH:RegExp = /^[0-9.]*/;
      
      protected static const METHOD_MATCH:RegExp = /METHOD=(AES-128|NONE)/;
      
      protected static const URI_MATCH:RegExp = /URI=\"([^\"]*)\"/;
      
      protected static const IV_MATCH:RegExp = /IV=0[xX]([0-9A-F]*)/;
      
      protected static const RESOLUTION_MATCH:RegExp = /RESOLUTION=([0-9]+x[0-9]+)/;
      
      protected static const BANDWIDTH_MATCH:RegExp = /BANDWIDTH=([0-9]+)/;
      
      protected static const AUDIO_MATCH:RegExp = /AUDIO=\"([^\"]+)\"/;
      
      protected static const EVENT_MATCH:RegExp = /EVENT=(START|CONTINUE|STOP)/;
      
      protected static const GROUP_ID_MATCH:RegExp = /GROUP-ID=\"([^\"]+)\"/;
      
      protected static const LANGUAGE_MATCH:RegExp = /LANGUAGE=\"([^\"]+)\"/;
      
      protected static const NAME_MATCH:RegExp = /NAME=\"([^\"]+)\"/;
      
      protected static const IS_DEFAULT_MATCH:RegExp = /DEFAULT=YES/;
      
      protected static const MAX_LIVE_ONLY_HISTORY:uint = 10;
      
      protected static const RESOLUTIONS:Object = {
         92:"426x240",
         93:"640x360",
         94:"854x480",
         95:"1280x720",
         96:"1920x1080",
         97:"8192x8192"
      };
      
      protected static const MOBILE_ONLY_ITAGS:Object = {
         91:true,
         132:true,
         151:true
      };
      
      protected static const DEFAULT_ITAG:String = "93";
      
      protected var sequence:uint;
      
      protected var cuePointParams:Object;
      
      protected var targetDuration:uint;
      
      protected var keyUrl:String;
      
      protected var parsedUrl:Url;
      
      protected var chunkDuration:uint;
      
      protected var audioRenditionGroup:String;
      
      protected var chunkStartTime:uint;
      
      protected var resolution:String;
      
      protected var iv:ByteArray;
      
      protected var bandwidth:uint;
      
      protected var endlist:Boolean;
      
      protected var renditionTable:Object = {};
      
      protected var discontinuity:Boolean;
      
      public function HlsParser()
      {
         super();
      }
      
      public static function makeHlsFormat(param1:VideoFormat, param2:Boolean = false) : void
      {
         if(!M2TS_MIME_MATCH.exec(param1.type))
         {
            param1.hlsPlaylist = new HlsPlaylist(param1.url,new HlsPlaylistLoader(param1.url),param2);
            if(param1.audioUrl)
            {
               param1.hlsAudioPlaylist = new HlsPlaylist(param1.audioUrl,new HlsPlaylistLoader(param1.audioUrl),param2);
            }
         }
      }
      
      protected function parseIv(param1:String) : ByteArray
      {
         if(param1.length % 2)
         {
            param1 = "0" + param1;
         }
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:int = 0;
         while(_loc3_ < (32 - param1.length) / 2)
         {
            _loc2_.writeByte(0);
            _loc3_++;
         }
         while(_loc3_ < 16)
         {
            _loc2_.writeByte(uint("0x" + param1.substr(0,2)));
            param1 = param1.substr(2);
            _loc3_++;
         }
         _loc2_.position = 0;
         return _loc2_;
      }
      
      public function hasHeader(param1:ByteArray) : Boolean
      {
         if(param1.bytesAvailable < HEADER.length)
         {
            return false;
         }
         var _loc2_:String = param1.readUTFBytes(HEADER.length);
         param1.position -= HEADER.length;
         return _loc2_ == HEADER;
      }
      
      protected function parseGlobalMetadata(param1:String, param2:String, param3:HlsPlaylist) : void
      {
         switch(param1)
         {
            case "EXT-X-TARGETDURATION":
               param3.targetDuration = 1000 * DECIMAL_MATCH.exec(param2);
               break;
            case "EXT-X-MEDIA-SEQUENCE":
               this.sequence = DECIMAL_MATCH.exec(param2);
               param3.live = true;
               param3.firstChunk = this.sequence;
               break;
            case "EXT-X-ENDLIST":
               param3.vod = true;
               break;
            case "EXT-X-PLAYLIST-TYPE":
               if(param2 == "EVENT")
               {
                  param3.dvr = true;
                  break;
               }
               if(param2 == "VOD")
               {
                  param3.vod = true;
               }
         }
      }
      
      protected function getRendition(param1:String, param2:String, param3:Object) : Object
      {
         var group:String = param1;
         var property:String = param2;
         var value:Object = param3;
         if(!this.renditionTable[group])
         {
            return null;
         }
         return this.renditionTable[group].filter(function(param1:Object, ... rest):Boolean
         {
            return param1[property] == value;
         })[0];
      }
      
      public function parseVariantPlaylist(param1:String, param2:String, param3:Boolean = false) : Array
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:uint = 0;
         var _loc10_:Array = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:Array = null;
         var _loc14_:Object = null;
         var _loc15_:VideoFormat = null;
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         this.parsedUrl = new Url(param2);
         var _loc6_:Array = param1.split(/\r?\n/);
         this.audioRenditionGroup = null;
         this.renditionTable = {};
         for each(_loc7_ in _loc6_)
         {
            _loc10_ = TAG_MATCH.exec(_loc7_);
            if(_loc10_)
            {
               this.parseVariantGlobalMetadata(_loc10_[1],_loc10_[2]);
            }
         }
         for(_loc8_ in this.renditionTable)
         {
            if(!this.getRendition(_loc8_,"uri",null))
            {
               this.renditionTable[_loc8_].unshift({
                  "name":"English",
                  "language":"en"
               });
            }
            if(!this.getRendition(_loc8_,"isDefault",true))
            {
               this.getRendition(_loc8_,"uri",null).isDefault = true;
            }
         }
         for each(_loc7_ in _loc6_)
         {
            _loc10_ = TAG_MATCH.exec(_loc7_);
            if(_loc10_)
            {
               this.parseVariantMetadata(_loc10_[1],_loc10_[2]);
            }
            else if(_loc7_ != "")
            {
               if(!ABSOLUTE_MATCH.exec(_loc7_))
               {
                  _loc7_ = Url.resolve(_loc7_,this.parsedUrl).recombineUrl();
               }
               _loc11_ = _loc7_;
               _loc12_ = this.submatch(ITAG_MATCH,_loc11_,1) || DEFAULT_ITAG;
               if(!(_loc12_ in MOBILE_ONLY_ITAGS))
               {
                  this.resolution = this.resolution || (RESOLUTIONS[_loc12_] || RESOLUTIONS[DEFAULT_ITAG]);
                  _loc13_ = this.renditionTable[this.audioRenditionGroup] || [{}];
                  for each(_loc14_ in _loc13_)
                  {
                     _loc15_ = new VideoFormat([_loc12_,this.resolution,10,1,0].join("/"),_loc11_,null,null,false,HLS_MIME_TYPE);
                     if(_loc14_.uri)
                     {
                        _loc15_.audioUrl = _loc14_.uri;
                     }
                     if(_loc14_.name)
                     {
                        _loc15_.audioTrack = new AudioTrack(_loc14_.name,_loc14_.language,_loc14_.isDefault);
                     }
                     _loc4_.push(_loc15_);
                     makeHlsFormat(_loc15_,param3);
                     _loc5_.push(_loc15_.hlsPlaylist);
                     if(_loc15_.hlsAudioPlaylist)
                     {
                        _loc5_.push(_loc15_.hlsAudioPlaylist);
                     }
                  }
               }
            }
         }
         _loc9_ = 0;
         while(_loc9_ < _loc5_.length)
         {
            _loc5_[_loc9_].siblingPlaylists = _loc5_.concat();
            _loc5_[_loc9_].siblingPlaylists.splice(_loc9_,1);
            _loc9_++;
         }
         return _loc4_;
      }
      
      protected function submatch(param1:RegExp, param2:String, param3:uint = 0) : String
      {
         var _loc4_:Array = param1.exec(param2);
         return _loc4_ ? _loc4_[param3 + 1] : null;
      }
      
      protected function calculateLiveStartTimes(param1:HlsPlaylist) : void
      {
         var _loc3_:HlsPlaylist = null;
         var _loc4_:int = 0;
         var _loc5_:uint = 0;
         var _loc2_:HlsPlaylist = param1;
         for each(_loc3_ in param1.siblingPlaylists)
         {
            param1.targetDuration = Math.max(param1.targetDuration,_loc3_.targetDuration);
            if(_loc3_.chunkStartTime[_loc3_.chunkStartTime.length - 1] > uint(_loc2_.chunkStartTime[_loc2_.chunkStartTime.length - 1]))
            {
               _loc2_ = _loc3_;
            }
         }
         _loc4_ = int(_loc2_.chunkStartTime.length - 1);
         if(param1.firstChunk == 0)
         {
            param1.chunkStartTime[0] = 0;
         }
         else if(_loc4_ < 0)
         {
            param1.chunkStartTime[param1.firstChunk] = param1.targetDuration * param1.firstChunk;
         }
         else if(param1.firstChunk > _loc4_)
         {
            param1.chunkStartTime[param1.firstChunk] = _loc2_.chunkStartTime[_loc4_] + _loc2_.chunkDuration[_loc4_] + param1.targetDuration * (param1.firstChunk - _loc4_ - 1);
         }
         else if(_loc2_.chunkStartTime[param1.firstChunk])
         {
            param1.chunkStartTime[param1.firstChunk] = _loc2_.chunkStartTime[param1.firstChunk];
         }
         else
         {
            param1.chunkStartTime[param1.firstChunk] = _loc2_.chunkStartTime[_loc2_.firstChunk];
            _loc5_ = param1.firstChunk;
            while(_loc5_ < _loc2_.firstChunk)
            {
               param1.chunkStartTime[param1.firstChunk] -= param1.chunkDuration[_loc5_];
               _loc5_++;
            }
         }
         _loc5_ = uint(param1.firstChunk + 1);
         while(_loc5_ < param1.chunkDuration.length)
         {
            param1.chunkStartTime[_loc5_] = param1.chunkStartTime[_loc5_ - 1] + param1.chunkDuration[_loc5_ - 1];
            _loc5_++;
         }
         if(param1.firstChunk > MAX_LIVE_ONLY_HISTORY)
         {
            param1.chunkDuration = ArrayUtils.sparseSlice(param1.chunkDuration,param1.firstChunk - MAX_LIVE_ONLY_HISTORY);
            param1.chunkStartTime = ArrayUtils.sparseSlice(param1.chunkStartTime,param1.firstChunk - MAX_LIVE_ONLY_HISTORY);
         }
      }
      
      protected function parseVariantGlobalMetadata(param1:String, param2:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         if(param1 == "EXT-X-MEDIA")
         {
            _loc3_ = this.submatch(URI_MATCH,param2);
            if(Boolean(_loc3_) && !ABSOLUTE_MATCH.exec(_loc3_))
            {
               _loc3_ = Url.resolve(_loc3_,this.parsedUrl).recombineUrl();
            }
            _loc4_ = {
               "uri":_loc3_,
               "language":this.submatch(LANGUAGE_MATCH,param2),
               "name":this.submatch(NAME_MATCH,param2),
               "isDefault":Boolean(IS_DEFAULT_MATCH.exec(param2))
            };
            _loc5_ = this.submatch(GROUP_ID_MATCH,param2);
            this.renditionTable[_loc5_] = this.renditionTable[_loc5_] || [];
            this.renditionTable[_loc5_].push(_loc4_);
         }
      }
      
      public function parsePlaylist(param1:ByteArray, param2:HlsPlaylist) : void
      {
         this.parsedUrl = new Url(param2.url);
         param2.chunkUrl = [];
         param2.chunkKeyUrl = [];
         param2.chunkIv = [];
         param2.byteLength = 0;
         this.sequence = 0;
         this.chunkStartTime = 0;
         this.endlist = false;
         this.discontinuity = false;
         this.continueParsingPlaylist(param1,param2);
      }
      
      public function copyPlaylist(param1:HlsPlaylist, param2:HlsPlaylist) : void
      {
         param2.live = param1.live;
         param2.vod = param1.vod;
         param2.dvr = param1.dvr;
         param2.targetDuration = param1.targetDuration;
         param2.firstChunk = param1.firstChunk;
         param2.chunkUrl = param1.chunkUrl.concat();
         param2.chunkDuration = param1.chunkDuration.concat();
         param2.chunkStartTime = param1.chunkStartTime.concat();
         param2.chunkKeyUrl = param1.chunkKeyUrl.concat();
         param2.chunkIv = param1.chunkIv.concat();
         param2.chunkDiscontinuity = param1.chunkDiscontinuity.concat();
         param2.url = param1.url;
         param2.chunkCuePointParams = param1.chunkCuePointParams.concat();
         param2.byteLength = param1.byteLength;
         param2.siblingPlaylists = param1.siblingPlaylists.concat();
      }
      
      protected function parseChunkMetadata(param1:String, param2:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         switch(param1)
         {
            case "EXTINF":
               this.chunkDuration = 1000 * DECIMAL_MATCH.exec(param2);
               break;
            case "EXT-X-KEY":
               if(this.submatch(METHOD_MATCH,param2) == "AES-128")
               {
                  this.keyUrl = this.submatch(URI_MATCH,param2);
                  if(!ABSOLUTE_MATCH.exec(this.keyUrl))
                  {
                     this.keyUrl = Url.resolve(this.keyUrl,this.parsedUrl).recombineUrl();
                  }
                  _loc3_ = this.submatch(IV_MATCH,param2);
                  this.iv = _loc3_ ? this.parseIv(_loc3_) : null;
                  break;
               }
               this.keyUrl = null;
               this.iv = null;
               break;
            case "EXT-X-CUEPOINT":
               if(this.submatch(EVENT_MATCH,param2) == "START")
               {
                  this.cuePointParams = {};
                  for each(_loc4_ in param2.split(","))
                  {
                     _loc5_ = _loc4_.split("=",2);
                     this.cuePointParams[_loc5_[0]] = _loc5_[1];
                  }
               }
               break;
            case "EXT-X-DISCONTINUITY":
               this.discontinuity = true;
         }
      }
      
      protected function parseVariantMetadata(param1:String, param2:String) : void
      {
         if(param1 == "EXT-X-STREAM-INF")
         {
            this.resolution = this.submatch(RESOLUTION_MATCH,param2);
            this.bandwidth = uint(this.submatch(BANDWIDTH_MATCH,param2));
            this.audioRenditionGroup = this.submatch(AUDIO_MATCH,param2);
         }
      }
      
      public function continueParsingPlaylist(param1:ByteArray, param2:HlsPlaylist) : void
      {
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:ByteArray = null;
         var _loc3_:uint = param1.bytesAvailable;
         while(_loc3_ > 0)
         {
            if(param1[param1.position + _loc3_ - 1] == NEWLINE_CODE)
            {
               break;
            }
            _loc3_--;
         }
         if(_loc3_ == 0)
         {
            return;
         }
         param2.byteLength += _loc3_;
         var _loc4_:Array = param1.readUTFBytes(_loc3_).split(/\r?\n/);
         for each(_loc5_ in _loc4_)
         {
            _loc6_ = TAG_MATCH.exec(_loc5_);
            if(_loc6_)
            {
               this.parseGlobalMetadata(_loc6_[1],_loc6_[2],param2);
            }
         }
         for each(_loc5_ in _loc4_)
         {
            _loc6_ = TAG_MATCH.exec(_loc5_);
            if(_loc6_)
            {
               this.parseChunkMetadata(_loc6_[1],_loc6_[2]);
            }
            else if(_loc5_ != "")
            {
               if(!ABSOLUTE_MATCH.exec(_loc5_))
               {
                  _loc5_ = Url.resolve(_loc5_,this.parsedUrl).recombineUrl();
               }
               param2.chunkUrl[this.sequence] = _loc5_;
               param2.chunkCuePointParams[this.sequence] = this.cuePointParams;
               param2.chunkDuration[this.sequence] = this.chunkDuration;
               if(!param2.live)
               {
                  param2.chunkStartTime[this.sequence] = this.chunkStartTime;
                  this.chunkStartTime += this.chunkDuration;
               }
               param2.chunkKeyUrl[this.sequence] = this.keyUrl;
               _loc7_ = this.iv;
               if(Boolean(this.keyUrl) && !_loc7_)
               {
                  _loc7_ = new ByteArray();
                  _loc7_.writeUnsignedInt(0);
                  _loc7_.writeUnsignedInt(0);
                  _loc7_.writeUnsignedInt(0);
                  _loc7_.writeUnsignedInt(this.sequence);
                  _loc7_.position = 0;
               }
               param2.chunkIv[this.sequence] = _loc7_;
               param2.chunkDiscontinuity[this.sequence] = this.discontinuity;
               ++this.sequence;
               this.cuePointParams = null;
               this.discontinuity = false;
            }
         }
         if(param2.live)
         {
            this.calculateLiveStartTimes(param2);
         }
      }
   }
}

