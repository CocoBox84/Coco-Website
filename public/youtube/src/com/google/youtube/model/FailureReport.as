package com.google.youtube.model
{
   import com.google.youtube.event.VideoErrorEvent;
   
   public class FailureReport
   {
      
      public static const LOAD_SOFT_TIMEOUT_MILLISECONDS:Number = 15 * 1000;
      
      public static const EVENT_MESSAGE:String = "streamingerror";
      
      public static const INVALID_DATA_ERROR_CODE:String = "100";
      
      public static const SOFT_TIMEOUT_ERROR_CODE:String = "102";
      
      public static const NET_CONNECTION_ERROR_CODE:String = "103";
      
      public static const ENDS_TOO_SOON_ERROR_CODE:String = "104";
      
      public static const AUTHENTICATION_TOKEN_ERROR_CODE:String = "105";
      
      public static const GUEST_PLAYER_AD_FAIL_ERROR_CODE:String = "106";
      
      public static const UNKNOWN_ERROR:String = "107";
      
      public static const USER_ERROR_REPORT_CODE:String = "108";
      
      public static const ASYNC_ERROR_CODE:String = "111";
      
      public static const CROSSDOMAIN_ERROR_CODE:String = "112";
      
      public static const CDN_FAILOVER_ERROR_CODE:String = "115";
      
      public static const SHORT_TIMEOUT_ERROR_CODE:String = "116";
      
      public static const FLASH_ACCESS_ERROR_CODE:String = "117";
      
      public static const FLASH_ACCESS_TIMEOUT_ERROR_CODE:String = "118";
      
      public static const FLASH_ACCESS_PRELOAD_ERROR_CODE:String = "119";
      
      public static const IO_ERROR_CODE:String = "120";
      
      public static const VIDEO_FETCH_ERROR_CODE:String = "121";
      
      public static const MANIFEST_KEY_ERROR_CODE:String = "122";
      
      public static const MANIFEST_FETCH_ERROR_CODE:String = "123";
      
      public static const CARDIO_SUPPORTED_ERROR_CODES:Object = {
         100:true,
         102:true,
         107:true,
         108:true,
         115:true,
         120:true
      };
      
      public function FailureReport()
      {
         super();
      }
      
      public static function getErrorCode(param1:VideoErrorEvent) : String
      {
         var _loc2_:String = param1.text;
         if(Boolean(_loc2_) && _loc2_.indexOf("GetVideoInfoError") != -1)
         {
            return "";
         }
         var _loc3_:String = UNKNOWN_ERROR;
         if(_loc2_)
         {
            if(_loc2_.indexOf("NetStream.Play.") != -1)
            {
               _loc3_ = FailureReport.INVALID_DATA_ERROR_CODE;
            }
            else if(_loc2_.indexOf("NetConnection") != -1)
            {
               if(_loc2_.indexOf("Rejected") != -1)
               {
                  _loc3_ = FailureReport.AUTHENTICATION_TOKEN_ERROR_CODE;
               }
               else
               {
                  _loc3_ = FailureReport.NET_CONNECTION_ERROR_CODE;
               }
            }
            else if(_loc2_.indexOf("async") != -1)
            {
               _loc3_ = FailureReport.ASYNC_ERROR_CODE;
            }
         }
         return _loc3_;
      }
      
      public static function isCardioSupportedError(param1:String) : Boolean
      {
         return Boolean(CARDIO_SUPPORTED_ERROR_CODES[param1]);
      }
   }
}

