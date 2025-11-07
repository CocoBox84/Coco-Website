package com.google.youtube.util
{
   import com.google.utils.Url;
   import com.google.youtube.model.IFormatIndex;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.players.IVideoInfoProvider;
   import flash.net.URLRequest;
   
   public class MediaLocation
   {
      
      protected var videoData:VideoData;
      
      protected var byteRateValue:Number;
      
      protected var enableRetryValue:Boolean;
      
      public var formatIndex:IFormatIndex;
      
      protected var vip:IVideoInfoProvider;
      
      protected var flipCount:int;
      
      protected var primaryUrlValue:String;
      
      public var fetchedOffsets:Array;
      
      protected var fallbackHostValue:String;
      
      public function MediaLocation(param1:VideoData = null, param2:IVideoInfoProvider = null)
      {
         super();
         this.videoData = param1;
         this.vip = param2;
      }
      
      public function get primaryUrl() : String
      {
         return this.decorate(new Url(this.primaryUrlValue));
      }
      
      public function get byteRate() : Number
      {
         return this.byteRateValue;
      }
      
      public function set byteRate(param1:Number) : void
      {
         this.byteRateValue = param1;
      }
      
      public function set enableRetry(param1:Boolean) : void
      {
         if(param1)
         {
            this.fallbackHostValue = null;
         }
         this.enableRetryValue = param1;
      }
      
      public function set fallbackHost(param1:String) : void
      {
         this.fallbackHostValue = param1;
         this.enableRetryValue = false;
      }
      
      public function set primaryUrl(param1:String) : void
      {
         this.primaryUrlValue = param1;
      }
      
      public function get hasSecondaryUrl() : Boolean
      {
         return Boolean(this.fallbackHostValue) || this.enableRetryValue;
      }
      
      public function get enableRetry() : Boolean
      {
         return this.enableRetryValue;
      }
      
      public function get fallbackHost() : String
      {
         return this.fallbackHostValue;
      }
      
      public function flip() : void
      {
         var _loc1_:Url = null;
         var _loc2_:String = null;
         if(this.fallbackHostValue)
         {
            ++this.flipCount;
            _loc1_ = new Url(this.primaryUrl);
            _loc2_ = this.fallbackHostValue;
            this.fallbackHostValue = _loc1_.hostname;
            _loc1_.hostname = _loc2_;
            this.primaryUrlValue = _loc1_.recombineUrl();
         }
      }
      
      protected function decorate(param1:Url) : String
      {
         var _loc2_:VideoFormat = null;
         var _loc3_:URLRequest = null;
         param1.queryVars.keepalive = "yes";
         if(param1.recombineUrl().indexOf("ratebypass") == -1)
         {
            param1.queryVars.ratebypass = "yes";
         }
         if(Boolean(this.videoData) && Boolean(this.videoData.clientPlaybackNonce))
         {
            param1.queryVars.cpn = this.videoData.clientPlaybackNonce;
         }
         if(Boolean(this.vip) && Boolean(this.videoData))
         {
            _loc2_ = new VideoFormat("1/2x3/10/1/0");
            _loc2_.url = param1.recombineUrl();
            _loc3_ = this.vip.getVideoFormatUrlRequest(this.videoData,_loc2_);
            delete _loc3_.data.begin;
         }
         return param1.recombineUrl();
      }
      
      public function get secondaryUrl() : String
      {
         var _loc1_:Url = new Url(this.primaryUrlValue);
         if(this.fallbackHostValue)
         {
            _loc1_.hostname = this.fallbackHostValue;
         }
         else
         {
            if(!this.enableRetryValue)
            {
               return null;
            }
            _loc1_.queryVars.retry = 1;
         }
         return this.decorate(_loc1_);
      }
      
      public function resetOrder() : void
      {
         if(this.flipCount % 2)
         {
            this.flip();
         }
      }
   }
}

