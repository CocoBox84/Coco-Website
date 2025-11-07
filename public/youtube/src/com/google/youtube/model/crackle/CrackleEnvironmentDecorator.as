package com.google.youtube.model.crackle
{
   import com.google.utils.RequestVariables;
   import com.google.youtube.model.EnvironmentDecorator;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.players.IVideoUrlProvider;
   import flash.net.URLRequest;
   import flash.system.Security;
   
   public class CrackleEnvironmentDecorator extends EnvironmentDecorator
   {
      
      private static var SITE:int = 219;
      
      public function CrackleEnvironmentDecorator(param1:int, param2:IVideoUrlProvider)
      {
         super(param1,param2);
         playerUrl = "http://crackle.com/flash/CracklePlayer.swf";
         watermarkDestination = "http://crackle.com";
      }
      
      override public function getVideoUrlRequest(param1:VideoData, param2:RequestVariables = null, param3:Boolean = false) : URLRequest
      {
         var _loc4_:URLRequest = super.getVideoUrlRequest(param1,param2,true);
         _loc4_.data.id = param1.mediaId;
         _loc4_.data.site = SITE;
         return _loc4_;
      }
      
      override protected function allowCrossDomainAccess() : void
      {
         Security.allowDomain("staging.crackle.com");
         Security.allowDomain("crackle.com");
         Security.allowDomain("www.crackle.com");
      }
   }
}

