package com.google.youtube.util
{
   public class UrlValidator
   {
      
      private static const EMBED_LOADING_WHITELIST:Array = ["youtube.com","youtube-nocookie.com","youtube.googleapis.com","video.google.com","corp.google.com","youtubeeducation.com"];
      
      private static var TRUSTED_DOMAIN_WHITELIST:Array = ["ytimg.com","googlevideo.com","google-liveplayer.appspot.com","ba.l.google.com","vp.video.l.google.com","c.googlesyndication.com","google.org","youtubeeducation.com","play.google.com","docs.google.com","drive.google.com","prod.google.com","sandbox.google.com","akamaihd.net","edgesuite.net"].concat(EMBED_LOADING_WHITELIST);
      
      public static const TRUSTED_SWF_REGEXP:RegExp = new RegExp("^(https?:\\/\\/([a-z0-9\\-]{1,63}\\.)*(" + TRUSTED_DOMAIN_WHITELIST.join("|").replace(/\./g,"\\.") + ")(:[0-9]+)?\\/)?[a-z0-9\\-_\\/]+.swf($|\\?)","i");
      
      public function UrlValidator()
      {
         super();
      }
      
      public static function isPromotedVideoDomain(param1:String) : Boolean
      {
         var _loc2_:Array = ["www.google.com/aclk","www.google.com/pagead/conversion","googleadservices.com/aclk","googleadservices.com/pagead/conversion","googleads.g.doubleclick.net/aclk","googleads.g.doubleclick.net/pagead/conversion"];
         return isSubdomain(param1,_loc2_);
      }
      
      public static function isBrandingPartner(param1:String) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         var _loc2_:Array = ["olympic.org","nbcolympics.com","nbcolympicsembed.com","vevo.com"];
         var _loc3_:* = "^https?://(www.|encrypted.)?google(.com|.co)?.[a-z]{2,3}/" + "(search|webhp)?";
         var _loc4_:* = param1.search(_loc3_) == 0;
         return isSubdomain(param1,_loc2_) || _loc4_;
      }
      
      public static function isRemarketingDomain(param1:String) : Boolean
      {
         var _loc2_:Array = ["googleadservices.com","googleads.g.doubleclick.net"];
         return isSubdomain(param1,_loc2_);
      }
      
      public static function isRtmp(param1:String) : Boolean
      {
         var _loc2_:RegExp = new RegExp("^rtmpe?://");
         return _loc2_.test(param1);
      }
      
      public static function isEmbedLoadingDomain(param1:String) : Boolean
      {
         return isSubdomain(param1,EMBED_LOADING_WHITELIST);
      }
      
      public static function isTrustedSwf(param1:String) : Boolean
      {
         TRUSTED_SWF_REGEXP.lastIndex = 0;
         return TRUSTED_SWF_REGEXP.test(param1);
      }
      
      public static function isTrustedDomain(param1:String) : Boolean
      {
         return isSubdomain(param1,TRUSTED_DOMAIN_WHITELIST);
      }
      
      protected static function isSubdomain(param1:String, param2:Array) : Boolean
      {
         var _loc3_:RegExp = new RegExp("^https?:\\/\\/([a-z0-9\\-]{1,63}\\.)*(" + param2.join("|").replace(/\./g,"\\.") + ")(:[0-9]+)?([\\/\\?\\#]|$)","i");
         return _loc3_.test(param1);
      }
      
      public static function isTrustedAdDomain(param1:String) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         var _loc2_:Array = ["2mdn.net","googlesyndication.com","ics.prod.google.com","static.doubleclick.net","static.googleadsserving.cn","studioapi.doubleclick.net","www.gstatic.com/doubleclick/studio/innovation/ytplayer"];
         return isSubdomain(param1,_loc2_);
      }
   }
}

