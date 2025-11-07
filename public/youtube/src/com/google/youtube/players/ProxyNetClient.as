package com.google.youtube.players
{
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   
   use namespace flash_proxy;
   
   public dynamic class ProxyNetClient extends Proxy
   {
      
      private static const WHITELIST:Object = {
         "close":RTMPVideoPlayer,
         "onAdBreakStart":IVideoAdAware,
         "onAdBreakEnd":IVideoAdAware,
         "onCuePoint":HTTPVideoPlayer,
         "onFCSubscribe":AkamaiLiveVideoPlayer,
         "onFCUnsubscribe":AkamaiLiveVideoPlayer,
         "onMetaData":HTTPVideoPlayer,
         "onPlayStatus":HTTPVideoPlayer
      };
      
      flash_proxy var target:Object;
      
      public function ProxyNetClient(param1:Object)
      {
         super();
         this.flash_proxy::target = param1;
      }
      
      private function noop(... rest) : void
      {
      }
      
      override flash_proxy function callProperty(param1:*, ... rest) : *
      {
         if(param1 in WHITELIST && this.flash_proxy::target is WHITELIST[param1])
         {
            return this.flash_proxy::target[param1].apply(null,rest);
         }
      }
      
      override flash_proxy function getProperty(param1:*) : *
      {
         if(param1 in WHITELIST && this.flash_proxy::target is WHITELIST[param1])
         {
            return this.flash_proxy::target[param1];
         }
         return Object(this.noop);
      }
      
      override flash_proxy function hasProperty(param1:*) : Boolean
      {
         if(param1 && Boolean(param1.hasOwnProperty("localName")))
         {
            param1 = param1.localName;
         }
         return param1 in WHITELIST && this.flash_proxy::target is WHITELIST[param1];
      }
   }
}

