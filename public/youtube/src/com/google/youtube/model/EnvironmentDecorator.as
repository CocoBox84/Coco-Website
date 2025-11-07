package com.google.youtube.model
{
   import com.google.utils.RequestVariables;
   import com.google.youtube.players.IVideoUrlProvider;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   
   public class EnvironmentDecorator implements IVideoUrlProvider
   {
      
      protected var partnerId:int;
      
      protected var watermarkDestination:String;
      
      protected var playerUrl:String;
      
      protected var environment:IVideoUrlProvider;
      
      public function EnvironmentDecorator(param1:int, param2:IVideoUrlProvider)
      {
         super();
         this.partnerId = param1;
         this.environment = param2;
         this.allowCrossDomainAccess();
      }
      
      public function getVideoUrlRequest(param1:VideoData, param2:RequestVariables = null, param3:Boolean = false) : URLRequest
      {
         var _loc4_:URLRequest = new URLRequest(this.playerUrl);
         if(!param2)
         {
            param2 = new RequestVariables();
         }
         _loc4_.data = param2;
         return _loc4_;
      }
      
      public function getPlaybackLoggingRequest(param1:VideoData, param2:RequestVariables = null) : URLRequest
      {
         return this.environment.getPlaybackLoggingRequest(param1,param2);
      }
      
      public function getVideoFormatUrlRequest(param1:VideoData, param2:VideoFormat, param3:RequestVariables = null, param4:Boolean = false) : URLRequest
      {
         return this.getVideoUrlRequest(param1,param3,param4);
      }
      
      public function get baseUrl() : String
      {
         return this.environment.baseUrl;
      }
      
      protected function allowCrossDomainAccess() : void
      {
      }
      
      public function getStillUrl(param1:VideoData, param2:Number = 430, param3:Number = 320) : String
      {
         return this.environment.getStillUrl(param1);
      }
      
      public function getVideoWatchRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:URLRequest = this.environment.getVideoWatchRequest(param1);
         _loc2_.data.partnerid = this.partnerId;
         return _loc2_;
      }
      
      public function getVideoWatchUrl(param1:VideoData) : String
      {
         var _loc2_:URLRequest = this.getVideoWatchRequest(param1);
         return _loc2_.url + _loc2_.data.toString();
      }
      
      public function applyGetVideoInfo(param1:URLVariables) : void
      {
         this.environment.applyGetVideoInfo(param1);
      }
      
      public function getVideoUrl(param1:VideoData, param2:RequestVariables = null) : String
      {
         var _loc3_:URLRequest = this.environment.getVideoUrlRequest(param1,param2);
         return _loc3_.url + decodeURI(_loc3_.data.toString());
      }
      
      public function getWatermarkDestinationRequest(param1:VideoData) : URLRequest
      {
         return new URLRequest(this.watermarkDestination);
      }
      
      public function getVideoEmbedCode(param1:VideoData) : String
      {
         return "";
      }
      
      public function getVideoInfoRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:URLRequest = this.environment.getVideoInfoRequest(param1);
         _loc2_.data.partnerid = this.partnerId;
         return _loc2_;
      }
   }
}

