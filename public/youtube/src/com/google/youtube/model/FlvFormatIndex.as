package com.google.youtube.model
{
   import com.google.utils.RequestLoader;
   import com.google.youtube.util.FlvUtils;
   import flash.errors.EOFError;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.ObjectEncoding;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public class FlvFormatIndex extends EventDispatcher implements IFormatIndex
   {
      
      protected static const PARTIAL:int = 0;
      
      protected static const LOADING:int = 1;
      
      protected static const LOADED:int = 2;
      
      protected var loadedState:int = 0;
      
      protected var keyframeMap:KeyframeMap;
      
      protected var maxAvgBytesPerSec:uint;
      
      protected var loader:RequestLoader;
      
      protected var duration:uint;
      
      protected var manifestUrl:String;
      
      protected var aac:ByteArray;
      
      protected var script:ByteArray;
      
      protected var avc:ByteArray;
      
      protected var metaData:Object = {};
      
      protected var fileSizeValue:Number = NaN;
      
      protected var baseByteOffset:uint = 0;
      
      protected var videoUrl:String;
      
      public function FlvFormatIndex(param1:uint, param2:String, param3:String)
      {
         super();
         this.manifestUrl = param3;
         this.videoUrl = param2;
         this.maxAvgBytesPerSec = param1;
      }
      
      public static function getManifestUrl(param1:String) : String
      {
         var _loc2_:Array = param1.split("&");
         var _loc3_:String = "";
         var _loc4_:String = "";
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.length)
         {
            if(_loc2_[_loc5_].substr(0,3) == "id=")
            {
               _loc3_ = _loc2_[_loc5_].split("=")[1];
            }
            if(_loc2_[_loc5_].substr(0,5) == "itag=")
            {
               _loc4_ = _loc2_[_loc5_].split("=")[1];
            }
            _loc5_++;
         }
         if(_loc3_ == "")
         {
            return null;
         }
         var _loc6_:* = "http://www.youtube.com/api/manifest/t2b";
         _loc6_ = _loc6_ + "/source/youtube";
         _loc6_ = _loc6_ + ("/id/" + _loc3_);
         _loc6_ = _loc6_ + ("/itag/" + _loc4_);
         return _loc6_ + "/mfmt/amf";
      }
      
      public function get audioHeader() : ByteArray
      {
         return this.aac;
      }
      
      public function set audioHeader(param1:ByteArray) : void
      {
         this.aac = param1;
      }
      
      public function getNextSeekPoint(param1:uint) : SeekPoint
      {
         return param1 == 0 ? this.getSeekPointWithHeaders() : this.addHeaderOffset(this.keyframeMap.getNextSeekPoint(param1));
      }
      
      public function get fileSize() : Number
      {
         return this.fileSizeValue;
      }
      
      public function get metadata() : ByteArray
      {
         return this.script;
      }
      
      public function canGetSeekPoint(param1:uint) : Boolean
      {
         if(param1 == 0 || this.loadedState == LOADED)
         {
            return true;
         }
         if(!this.keyframeMap)
         {
            return false;
         }
         var _loc2_:SeekPoint = this.keyframeMap.getMax();
         return Boolean(_loc2_) && _loc2_.timestamp > param1;
      }
      
      public function getTimeFromByte(param1:uint) : uint
      {
         var _loc2_:uint = 0;
         if(this.loadedState == LOADED)
         {
            _loc2_ = this.keyframeMap.getMax().byteOffset;
            if(_loc2_)
            {
               return 1000 * (this.metaData.duration * param1 / _loc2_);
            }
         }
         return 1000 * (param1 / this.maxAvgBytesPerSec);
      }
      
      protected function getSeekPointWithHeaders() : SeekPoint
      {
         var _loc1_:SeekPoint = new SeekPoint();
         _loc1_.byteOffset = FlvUtils.FLV_HEADER_SIZE;
         _loc1_.timestamp = 0;
         _loc1_.desiredTimestamp = 0;
         return _loc1_;
      }
      
      protected function addHeaderOffset(param1:SeekPoint) : SeekPoint
      {
         if(param1 != null)
         {
            param1.byteOffset += this.getTotalHeaderSize();
         }
         return param1;
      }
      
      public function getSeekPoint(param1:uint) : SeekPoint
      {
         return param1 == 0 ? this.getSeekPointWithHeaders() : this.addHeaderOffset(this.keyframeMap.getSeekPoint(param1));
      }
      
      protected function onLoadComplete(param1:Event) : void
      {
         var manifestObject:Object = null;
         var event:Event = param1;
         if(this.loader.data && Boolean(this.loader.data.length))
         {
            this.loader.data.objectEncoding = ObjectEncoding.AMF3;
            try
            {
               manifestObject = this.loader.data.readObject();
            }
            catch(e:EOFError)
            {
            }
            catch(e:RangeError)
            {
            }
            if(manifestObject)
            {
               this.applyManifestObject(manifestObject);
               this.loadedState = LOADED;
            }
         }
         this.loader = null;
         dispatchEvent(this.loadedState == LOADED ? event : new IOErrorEvent(IOErrorEvent.IO_ERROR));
      }
      
      public function onResetPoint(param1:SeekPoint) : void
      {
         if(this.loadedState == PARTIAL && param1.timestamp > 0)
         {
            this.baseByteOffset = param1.byteOffset - this.getTotalHeaderSize();
         }
      }
      
      public function set videoHeader(param1:ByteArray) : void
      {
         this.avc = param1;
      }
      
      public function onSeekPoint(param1:SeekPoint, param2:Boolean) : void
      {
         if(this.loadedState == LOADED)
         {
            return;
         }
         if(!this.keyframeMap)
         {
            this.keyframeMap = new KeyframeMap([],[],[]);
         }
         var _loc3_:SeekPoint = this.keyframeMap.getMax();
         if(!_loc3_ || _loc3_.timestamp < param1.timestamp)
         {
            param1.byteOffset += this.baseByteOffset;
            this.keyframeMap.push(param1);
         }
         if(param2)
         {
            this.loadedState = LOADED;
         }
      }
      
      protected function getTotalHeaderSize() : uint
      {
         var _loc1_:uint = uint(FlvUtils.FLV_HEADER_SIZE);
         if(Boolean(this.avc) && Boolean(this.avc.length))
         {
            _loc1_ += this.avc.length;
         }
         if(Boolean(this.aac) && Boolean(this.aac.length))
         {
            _loc1_ += this.aac.length;
         }
         return _loc1_ + FlvUtils.SCRIPT_TAG_SIZE;
      }
      
      public function set metadata(param1:ByteArray) : void
      {
         var _loc2_:Object = FlvUtils.readScriptTag(param1);
         if(isNaN(this.fileSizeValue) && Boolean(_loc2_.payload.hasOwnProperty("bytelength")))
         {
            this.fileSizeValue = _loc2_.payload.bytelength;
         }
         this.script = param1;
      }
      
      protected function applyManifestObject(param1:Object) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         if(param1.avc)
         {
            this.avc = new ByteArray();
            FlvUtils.writeFrameHeader(this.avc,FlvUtils.TAG_TYPE_VIDEO,0);
            this.avc.writeBytes(param1.avc);
            FlvUtils.writeFrameTrailer(this.avc);
         }
         if(param1.aac)
         {
            this.aac = new ByteArray();
            FlvUtils.writeFrameHeader(this.aac,FlvUtils.TAG_TYPE_AUDIO,0);
            this.aac.writeBytes(param1.aac);
            FlvUtils.writeFrameTrailer(this.aac);
         }
         if(param1.width)
         {
            this.metaData.width = param1.width;
         }
         if(param1.height)
         {
            this.metaData.height = param1.height;
         }
         if(isNaN(this.fileSizeValue) && Boolean(param1.hasOwnProperty("bytelength_high_word")) && Boolean(param1.hasOwnProperty("bytelength_low_word")))
         {
            this.fileSizeValue = param1.bytelength_high_word * 268435456 + param1.bytelength_low_word;
         }
         if(Boolean(param1.audio_duration) && Boolean(param1.video_duration))
         {
            this.metaData.duration = Math.max(param1.audio_duration,param1.video_duration) / 1000;
         }
         else if(param1.audio_duration)
         {
            this.metaData.duration = param1.audio_duration / 1000;
         }
         else if(param1.video_duration)
         {
            this.metaData.duration = param1.video_duration / 1000;
         }
         this.script = new ByteArray();
         FlvUtils.writeScriptTag(this.script,"onMetaData",0,this.metadata);
         if(Boolean(param1.timestamp) && Boolean(param1.offset_low_word))
         {
            _loc2_ = param1.timestamp;
            _loc3_ = param1.offset_low_word;
            _loc4_ = param1.offset_high_word ? param1.offset_high_word : null;
            this.keyframeMap = new KeyframeMap(_loc2_,_loc3_,_loc4_);
         }
      }
      
      public function load() : void
      {
         if(this.loadedState == LOADING || this.loadedState == LOADED)
         {
            return;
         }
         this.loadedState = LOADING;
         this.loader = new RequestLoader();
         this.loader.addEventListener(Event.COMPLETE,this.onLoadComplete);
         this.loader.addEventListener(IOErrorEvent.IO_ERROR,dispatchEvent);
         this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,dispatchEvent);
         this.loader.addEventListener(ErrorEvent.ERROR,dispatchEvent);
         this.loader.loadRequest(new URLRequest(this.manifestUrl),URLLoaderDataFormat.BINARY);
      }
      
      public function get videoHeader() : ByteArray
      {
         return this.avc;
      }
      
      public function canGetAnySeekPoint() : Boolean
      {
         return this.loadedState == LOADED;
      }
   }
}

