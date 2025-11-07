package com.google.youtube.model.googledocs
{
   import com.google.utils.RequestVariables;
   import com.google.youtube.model.EnvironmentDecorator;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.players.IVideoInfoProvider;
   import com.google.youtube.players.IVideoUrlProvider;
   import flash.net.URLRequest;
   
   public class GoogleDocsEnvironmentDecorator extends EnvironmentDecorator implements IVideoInfoProvider
   {
      
      public function GoogleDocsEnvironmentDecorator(param1:int, param2:IVideoUrlProvider)
      {
         super(param1,param2);
      }
      
      public function get defaultBufferLength() : Number
      {
         return IVideoInfoProvider(environment).defaultBufferLength;
      }
      
      public function get maxBufferLength() : Number
      {
         return IVideoInfoProvider(environment).maxBufferLength;
      }
      
      override public function getVideoWatchUrl(param1:VideoData) : String
      {
         if(!param1)
         {
            return "";
         }
         var _loc2_:URLRequest = this.getVideoWatchRequest(param1);
         return _loc2_.url + "?" + _loc2_.data.toString();
      }
      
      override public function getVideoWatchRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:URLRequest = new URLRequest(this.baseUrl + "open");
         var _loc3_:RequestVariables = new RequestVariables();
         _loc3_.id = param1.videoId;
         if(param1.authKey)
         {
            _loc3_.authkey = param1.authKey;
         }
         _loc2_.data = _loc3_;
         return _loc2_;
      }
      
      public function get bufferLengthAfterVideoStarts() : Number
      {
         return IVideoInfoProvider(environment).bufferLengthAfterVideoStarts;
      }
      
      override public function getVideoInfoRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:URLRequest = new URLRequest(this.baseUrl + "get_video_info");
         var _loc3_:URLRequest = environment.getVideoInfoRequest(param1);
         var _loc4_:RequestVariables = new RequestVariables();
         _loc4_.docid = param1.videoId;
         _loc4_.authuser = param1.authUser;
         if(param1.authKey)
         {
            _loc4_.authkey = param1.authKey;
         }
         if(_loc3_.data.eurl)
         {
            _loc4_.eurl = _loc3_.data.eurl;
         }
         _loc2_.data = _loc4_;
         return _loc2_;
      }
      
      override public function getStillUrl(param1:VideoData, param2:Number = 430, param3:Number = 320) : String
      {
         var _loc4_:URLRequest = null;
         var _loc5_:RequestVariables = null;
         if(param1.imageUrl)
         {
            return param1.imageUrl;
         }
         if(param1.videoId)
         {
            _loc4_ = new URLRequest(this.baseUrl + "vt");
            _loc5_ = new RequestVariables();
            _loc5_.id = param1.videoId;
            if(param1.authUser)
            {
               _loc5_.authuser = param1.authUser;
            }
            if(param1.authKey)
            {
               _loc5_.authKey = param1.authKey;
            }
            _loc4_.data = _loc5_;
            return _loc4_.url + "?" + _loc4_.data.toString();
         }
         return this.baseUrl + "images/doclist/cleardot.gif";
      }
      
      override public function get baseUrl() : String
      {
         return environment.baseUrl.replace("www.youtube.com","docs.google.com");
      }
   }
}

