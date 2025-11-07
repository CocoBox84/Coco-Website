package com.google.youtube.model
{
   import com.google.utils.PlayerVersion;
   import com.google.youtube.util.dash.LiveMpdParser;
   import com.google.youtube.util.hls.HlsPlaylist;
   import flash.geom.Rectangle;
   
   public class VideoFormat
   {
      
      public static const BYTES_PER_SECOND:Object = {
         5:40960,
         6:114688,
         13:7680,
         17:10240,
         18:94208,
         20:3072000,
         22:408576,
         23:8000,
         24:16000,
         25:40000,
         33:16896,
         34:118784,
         35:163840,
         36:32768,
         37:792576,
         38:1296384,
         40:5120,
         43:118784,
         44:163840,
         45:408576,
         59:163840,
         61:118784,
         62:163840,
         63:408576,
         64:792576,
         65:1296384,
         78:163840,
         80:163840,
         81:118784,
         82:102400,
         83:147456,
         84:384000,
         85:768000,
         88:920576,
         91:12600,
         92:23888,
         93:121800,
         94:168000,
         95:410550,
         96:812700,
         97:1296384,
         98:40960,
         119:40960,
         133:33500,
         134:121800,
         135:168000,
         136:410550,
         137:812700,
         138:1296384,
         139:4096,
         140:16384,
         141:40960,
         160:11750
      };
      
      private static var DEFAULT_SPEC:Array = ["","320x240","0","0","0"];
      
      private static var MP3_ITAGS:Object = {
         23:true,
         24:true,
         25:true
      };
      
      private static var MP4_ITAGS:Object = {
         18:true,
         22:true,
         37:true,
         38:true,
         59:true,
         78:true,
         81:true,
         82:true,
         83:true,
         84:true,
         85:true,
         119:true
      };
      
      private static var FLV_ITAGS:Object = {
         5:true,
         34:true,
         35:true
      };
      
      private static const M2TS_ITAGS:Object = {
         91:true,
         92:true,
         93:true,
         94:true,
         95:true,
         96:true,
         97:true
      };
      
      private static var DASH_ITAGS:Object = {
         133:true,
         134:true,
         135:true,
         136:true,
         137:true,
         138:true,
         160:true,
         139:true,
         140:true,
         141:true
      };
      
      private static var fragmentedMp4Indexes:Object = {};
      
      private static var dashLiveIndexes:Object = {};
      
      public var videoByteRateValue:Number = 0;
      
      public var idented:Boolean = false;
      
      public var audioByteRateValue:Number = 0;
      
      public var fetchedOffsetsVideo:Array;
      
      public var audioTrack:AudioTrack;
      
      public var formatIndexValue:IFormatIndex;
      
      public var hlsAudioPlaylist:HlsPlaylist;
      
      public var dashLiveMpd:LiveMpdParser;
      
      public var fallbackHost:String;
      
      public var fallbackConn:String;
      
      private var audioSpec:Array;
      
      public var isStereo3D:Boolean;
      
      private var spec:Array;
      
      public var videoInitializationSegmentByteRange:Array;
      
      public var audioUrl:String;
      
      public var enabled:Boolean = true;
      
      public var conn:String;
      
      public var type:String;
      
      public var videoIndexSegmentByteRange:Array;
      
      public var audioInitializationSegmentByteRange:Array;
      
      public var hlsPlaylist:HlsPlaylist;
      
      public var audioIndexSegmentByteRange:Array;
      
      public var url:String;
      
      public var fetchedOffsetsAudio:Array;
      
      public function VideoFormat(param1:String = null, param2:String = null, param3:String = null, param4:String = null, param5:Boolean = false, param6:String = null)
      {
         var _loc7_:Array = null;
         this.audioTrack = AudioTrack.DEFAULT;
         this.fetchedOffsetsVideo = [];
         this.fetchedOffsetsAudio = [];
         super();
         if(param1)
         {
            _loc7_ = param1.split(":");
            if(_loc7_)
            {
               this.spec = _loc7_[0].split("/");
               if(_loc7_.length > 1)
               {
                  this.audioSpec = _loc7_[1].split("/");
               }
            }
         }
         if(!this.spec || this.spec[0] == "" || this.spec[0] == "default")
         {
            this.spec = DEFAULT_SPEC;
         }
         if(param3)
         {
            this.conn = param3;
         }
         this.url = param2;
         this.fallbackHost = param4;
         this.isStereo3D = param5;
         this.type = param6;
      }
      
      protected static function getFragMp4Index(param1:String, param2:int) : FragMp4FormatIndex
      {
         fragmentedMp4Indexes[param1] = fragmentedMp4Indexes[param1] || new FragMp4FormatIndex(param1,param2);
         return fragmentedMp4Indexes[param1];
      }
      
      protected static function getDashLiveMp4Index(param1:LiveMpdParser, param2:String) : DashLiveFormatIndex
      {
         dashLiveIndexes[param2] = dashLiveIndexes[param2] || new DashLiveFormatIndex(param1,param2);
         return dashLiveIndexes[param2];
      }
      
      public function get audioName() : String
      {
         return this.audioSpec ? this.audioSpec[0] : "";
      }
      
      public function get audioByteRate() : Number
      {
         return this.audioByteRateValue || this.byteRate;
      }
      
      public function get quality() : VideoQuality
      {
         if(this.name == "40")
         {
            return VideoQuality.LIGHT;
         }
         var _loc1_:int = this.size.height;
         if(_loc1_ > 1080)
         {
            return VideoQuality.HIGHRES;
         }
         if(_loc1_ > 720)
         {
            return VideoQuality.HD1080;
         }
         if(_loc1_ > 576)
         {
            return VideoQuality.HD720;
         }
         if(_loc1_ > 360)
         {
            return VideoQuality.LARGE;
         }
         if(_loc1_ > 240)
         {
            return VideoQuality.MEDIUM;
         }
         if(_loc1_ > 144)
         {
            return VideoQuality.SMALL;
         }
         return VideoQuality.TINY;
      }
      
      public function get isFlv() : Boolean
      {
         return this.name in FLV_ITAGS;
      }
      
      public function get name() : String
      {
         return this.spec[0];
      }
      
      public function get size() : Rectangle
      {
         var _loc1_:Array = this.spec[1].split("x");
         if(_loc1_.length == 2)
         {
            return new Rectangle(0,0,parseInt(_loc1_[0]),parseInt(_loc1_[1]));
         }
         return new Rectangle(0,0,640,360);
      }
      
      public function get byteRate() : Number
      {
         return this.audioByteRateValue + this.videoByteRateValue || Number(BYTES_PER_SECOND[this.name]);
      }
      
      public function get formatIndex() : IFormatIndex
      {
         this.formatIndexValue = this.formatIndexValue || this.newFormatIndex();
         return this.formatIndexValue;
      }
      
      public function get isM2Ts() : Boolean
      {
         return this.name in M2TS_ITAGS && !this.hlsPlaylist;
      }
      
      public function isSupported() : Boolean
      {
         var _loc1_:int = parseInt(this.spec[2]);
         var _loc2_:int = parseInt(this.spec[3]);
         var _loc3_:int = parseInt(this.spec[4]);
         if(isNaN(_loc1_) || isNaN(_loc2_) || isNaN(_loc3_))
         {
            return false;
         }
         var _loc4_:PlayerVersion = PlayerVersion.getPlayerVersion();
         var _loc5_:String = PlayerVersion.getPlayerOs();
         if((_loc5_ == "AFL" || _loc5_ == "FL" || _loc5_ == "PS3") && _loc4_.isAtLeastVersion(8))
         {
            _loc4_ = new PlayerVersion(8);
         }
         return _loc4_.isAtLeastVersion(_loc1_,_loc2_,_loc3_);
      }
      
      public function isTransportRtmp() : Boolean
      {
         return Boolean(this.conn);
      }
      
      public function get requiresTagStreamPlayer() : Boolean
      {
         return this.isHls || this.isDash || this.isMp3 || this.isM2Ts || this.isDashLive;
      }
      
      public function equals(param1:VideoFormat) : Boolean
      {
         return this.toString() == param1.toString();
      }
      
      public function get videoByteRate() : Number
      {
         return this.videoByteRateValue || this.byteRate;
      }
      
      public function newFormatIndex() : IFormatIndex
      {
         var _loc1_:uint = 0;
         var _loc2_:uint = 0;
         if(this.isFlv)
         {
            return new FlvFormatIndex(this.byteRate,this.url,FlvFormatIndex.getManifestUrl(this.url));
         }
         if(this.isMp4)
         {
            return new ContigMp4FormatIndex(this.url);
         }
         if(this.isHls)
         {
            return new HlsFormatIndex(this.hlsPlaylist,this.size.width,this.size.height);
         }
         if(this.isDashLive)
         {
            return new SplitFormatIndex(getDashLiveMp4Index(this.dashLiveMpd,this.audioName),getDashLiveMp4Index(this.dashLiveMpd,this.name));
         }
         if(this.isDash)
         {
            _loc1_ = this.audioIndexSegmentByteRange ? uint(this.audioIndexSegmentByteRange[1] + 1) : 16384;
            _loc2_ = this.videoIndexSegmentByteRange ? uint(this.videoIndexSegmentByteRange[1] + 1) : 16384;
            return new SplitFormatIndex(getFragMp4Index(this.audioUrl,_loc1_),getFragMp4Index(this.url,_loc2_));
         }
         if(this.isMp3)
         {
            return new Mp3FormatIndex(this.byteRate,this.url,FlvFormatIndex.getManifestUrl(this.url));
         }
         if(this.isM2Ts)
         {
            return new UnindexedFormatIndex();
         }
         return null;
      }
      
      public function get isDash() : Boolean
      {
         return this.name in DASH_ITAGS && !this.dashLiveMpd;
      }
      
      public function get isMp4() : Boolean
      {
         return this.name in MP4_ITAGS;
      }
      
      public function get isDashLive() : Boolean
      {
         return this.name in DASH_ITAGS && Boolean(this.dashLiveMpd);
      }
      
      public function get isHls() : Boolean
      {
         return this.name in M2TS_ITAGS && Boolean(this.hlsPlaylist);
      }
      
      public function toString() : String
      {
         return this.spec.join("/") + "|" + (this.conn ? this.conn + "|" : "") + this.url + "|" + this.audioTrack.name;
      }
      
      public function get isMp3() : Boolean
      {
         return this.name in MP3_ITAGS;
      }
      
      public function get isAesEncrypted() : Boolean
      {
         return false;
      }
   }
}

