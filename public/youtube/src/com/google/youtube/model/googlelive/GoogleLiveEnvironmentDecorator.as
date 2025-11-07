package com.google.youtube.model.googlelive
{
   import com.google.utils.RequestVariables;
   import com.google.youtube.model.EnvironmentDecorator;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.players.IVideoInfoProvider;
   import com.google.youtube.players.IVideoUrlProvider;
   import flash.net.URLRequest;
   
   public class GoogleLiveEnvironmentDecorator extends EnvironmentDecorator implements IVideoInfoProvider
   {
      
      public function GoogleLiveEnvironmentDecorator(param1:int, param2:IVideoUrlProvider)
      {
         super(param1,param2);
      }
      
      override public function get baseUrl() : String
      {
         return environment.baseUrl || "https://google-liveplayer.appspot.com/";
      }
      
      public function get bufferLengthAfterVideoStarts() : Number
      {
         return IVideoInfoProvider(environment).bufferLengthAfterVideoStarts;
      }
      
      public function get maxBufferLength() : Number
      {
         return IVideoInfoProvider(environment).maxBufferLength;
      }
      
      override public function getVideoInfoRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:URLRequest = new URLRequest(this.baseUrl + "get_video_info");
         var _loc3_:RequestVariables = new RequestVariables();
         _loc3_.key = param1.videoId;
         _loc2_.data = _loc3_;
         return _loc2_;
      }
      
      public function get defaultBufferLength() : Number
      {
         return IVideoInfoProvider(environment).defaultBufferLength;
      }
   }
}

