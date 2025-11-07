package com.google.youtube.util.dash
{
   import com.google.utils.Scheduler;
   import com.google.youtube.model.VideoFormat;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public class LiveMpdParser extends EventDispatcher
   {
      
      protected static const SCHEDULER:Object = Scheduler;
      
      protected static const LIVE_PROFILE:String = "urn:mpeg:dash:profile:isoff-live:2011";
      
      protected var mpdUrl:String;
      
      protected var loader:URLLoader;
      
      protected var mpd:XML;
      
      protected var reloadTimer:Scheduler;
      
      public function LiveMpdParser(param1:String)
      {
         super();
         this.mpdUrl = param1;
      }
      
      public function scheduleUpdate() : void
      {
         default xml namespace = this.mpd.namespace();
         if(this.loader || this.reloadTimer || this.isDone)
         {
            return;
         }
         this.reloadTimer = SCHEDULER.setTimeout(this.getMinimumUpdatePeriod() * 1000,this.load);
      }
      
      protected function releaseLoader() : void
      {
         default xml namespace = this.mpd.namespace();
         this.loader.removeEventListener(Event.COMPLETE,this.onComplete);
         this.loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onError);
         this.loader.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
         this.loader = null;
         this.reloadTimer = null;
      }
      
      public function getUrlByIndex(param1:String, param2:int) : String
      {
         var rep:XML = null;
         var itag:String = param1;
         var i:int = param2;
         default xml namespace = this.mpd.namespace();
         rep = this.mpd..Representation.(@id == itag)[0];
         return rep.BaseURL[0].text() + "/" + rep..SegmentURL[i].@media;
      }
      
      public function get isDone() : Boolean
      {
         default xml namespace = this.mpd.namespace();
         return Boolean(this.mpd) && !this.mpd.@minimumUpdatePeriod.length();
      }
      
      protected function sumDurations(param1:Array) : Array
      {
         default xml namespace = this.mpd.namespace();
         var _loc2_:Array = [];
         var _loc3_:Number = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_.push(_loc3_);
            _loc3_ += param1[_loc4_];
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function getSegmentStartNumber() : uint
      {
         default xml namespace = this.mpd.namespace();
         return uint(this.mpd.Period.SegmentList.@startNumber[0]);
      }
      
      protected function getVideoFormat(param1:XML, param2:XML) : VideoFormat
      {
         default xml namespace = this.mpd.namespace();
         var _loc3_:String = param2.@id;
         var _loc4_:String = param1.@id;
         var _loc5_:String = [param2.@width,param2.@height].join("x");
         var _loc6_:String = [_loc3_,_loc5_,10,1,0].join("/");
         var _loc7_:String = [_loc4_,param1.@audioSamplingRate].join("/");
         var _loc8_:String = [_loc6_,_loc7_].join(":");
         var _loc9_:VideoFormat = new VideoFormat(_loc8_,"");
         _loc9_.dashLiveMpd = this;
         return _loc9_;
      }
      
      protected function getMinimumUpdatePeriod() : Number
      {
         default xml namespace = this.mpd.namespace();
         return Number(MpdUtils.parseDuration(this.mpd.@minimumUpdatePeriod[0]));
      }
      
      public function parseString(param1:String) : void
      {
         this.mpd = new XML(param1);
         default xml namespace = this.mpd.namespace();
      }
      
      protected function expandDurations(param1:XML) : Array
      {
         var _loc3_:XML = null;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         default xml namespace = this.mpd.namespace();
         var _loc2_:Array = [];
         for each(_loc3_ in param1.S)
         {
            _loc4_ = Number(_loc3_.@d);
            _loc5_ = 1;
            if(_loc3_.@r)
            {
               _loc5_ = int(_loc3_.@r) + 1;
            }
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc2_.push(_loc4_ * 1000);
               _loc6_++;
            }
         }
         return _loc2_;
      }
      
      public function getDurations(param1:String) : Array
      {
         default xml namespace = this.mpd.namespace();
         return Boolean(this.mpd) && Boolean(this.mpd.isValid) ? this.expandDurations(this.mpd.Period.SegmentList.SegmentTimeline[0]) : null;
      }
      
      public function getFormats() : Array
      {
         var audio:XML = null;
         var videos:XMLList = null;
         var result:Array = null;
         var video:XML = null;
         default xml namespace = this.mpd.namespace();
         audio = this.mpd..AdaptationSet.(@mimeType == "audio/mp4").Representation[0];
         videos = this.mpd..AdaptationSet.(@mimeType == "video/mp4").Representation;
         result = [];
         for each(video in videos)
         {
            result.push(this.getVideoFormat(audio,video));
         }
         return result;
      }
      
      protected function onError(param1:Event) : void
      {
         default xml namespace = this.mpd.namespace();
         this.releaseLoader();
         dispatchEvent(param1);
      }
      
      public function get isValid() : Boolean
      {
         default xml namespace = this.mpd.namespace();
         return Boolean(this.mpd) && this.mpd.@profiles[0] == LIVE_PROFILE;
      }
      
      protected function load(param1:Event = null) : void
      {
         default xml namespace = this.mpd.namespace();
         this.loader = new URLLoader();
         this.loader.dataFormat = URLLoaderDataFormat.BINARY;
         this.loader.addEventListener(Event.COMPLETE,this.onComplete);
         this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onError);
         this.loader.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
         this.loader.load(new URLRequest(this.mpdUrl));
      }
      
      protected function onComplete(param1:Event) : void
      {
         default xml namespace = this.mpd.namespace();
         this.parseBytes(this.loader.data);
         this.releaseLoader();
         if(this.mpd.isValid)
         {
            dispatchEvent(param1);
            this.scheduleUpdate();
         }
         else
         {
            dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
         }
      }
      
      public function getInitializationUrl(param1:String) : String
      {
         var rep:XML = null;
         var base:XML = null;
         var init:XML = null;
         var itag:String = param1;
         default xml namespace = this.mpd.namespace();
         rep = this.mpd..Representation.(@id == itag)[0];
         base = rep.BaseURL[0];
         init = rep.SegmentList.Initialization[0];
         return base.text() + "/" + init.@sourceURL;
      }
      
      public function getStartTimes(param1:String) : Array
      {
         default xml namespace = this.mpd.namespace();
         return Boolean(this.mpd) && Boolean(this.mpd.isValid) ? this.sumDurations(this.expandDurations(this.mpd.Period.SegmentList.SegmentTimeline[0])) : null;
      }
      
      public function parseBytes(param1:ByteArray) : void
      {
         this.mpd = new XML(param1);
         default xml namespace = this.mpd.namespace();
      }
   }
}

