package com.google.youtube.model.googlebooks
{
   import com.google.utils.Url;
   import com.google.youtube.model.EnvironmentDecorator;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.players.IVideoInfoProvider;
   import com.google.youtube.players.IVideoUrlProvider;
   import flash.net.URLRequest;
   import flash.system.Security;
   
   public class GoogleBooksEnvironmentDecorator extends EnvironmentDecorator implements IVideoInfoProvider
   {
      
      public function GoogleBooksEnvironmentDecorator(param1:int, param2:IVideoUrlProvider)
      {
         super(param1,param2);
      }
      
      public function get bufferLengthAfterVideoStarts() : Number
      {
         return IVideoInfoProvider(environment).bufferLengthAfterVideoStarts;
      }
      
      public function get defaultBufferLength() : Number
      {
         return IVideoInfoProvider(environment).defaultBufferLength;
      }
      
      public function get maxBufferLength() : Number
      {
         return IVideoInfoProvider(environment).maxBufferLength;
      }
      
      override public function getVideoInfoRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:String = this.baseUrl.concat("books/crossdomain.xml");
         Security.loadPolicyFile(_loc2_);
         var _loc3_:int = int(param1.videoId.indexOf(":"));
         var _loc4_:String = param1.videoId.slice(0,_loc3_);
         var _loc5_:String = param1.videoId.slice(_loc3_ + 1);
         var _loc6_:Url = new Url(this.baseUrl.concat("books/volumes/",_loc4_,"/content/media"));
         var _loc7_:Object = {};
         _loc7_.aid = _loc5_;
         _loc7_.sig = param1.oceanSig;
         _loc7_.container = "flash";
         return new URLRequest(_loc6_.recombineUrl(false,_loc7_));
      }
      
      override public function getStillUrl(param1:VideoData, param2:Number = 430, param3:Number = 320) : String
      {
         var _loc4_:URLRequest = null;
         if(param1.imageUrl)
         {
            _loc4_ = new URLRequest(param1.imageUrl);
            return _loc4_.url;
         }
         return null;
      }
      
      override public function get baseUrl() : String
      {
         return environment.baseUrl.replace("www.youtube.com","play.google.com");
      }
   }
}

