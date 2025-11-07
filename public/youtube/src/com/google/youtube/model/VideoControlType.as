package com.google.youtube.model
{
   public final class VideoControlType
   {
      
      public static const FULLSCREEN:String = "FULLSCREEN";
      
      public static const NEXT:String = "NEXT";
      
      public static const PAUSE:String = "PAUSE";
      
      public static const PLAY:String = "PLAY";
      
      public static const POPOUT:String = "POPOUT";
      
      public static const RATE:String = "RATE";
      
      public static const VOLUME:String = "VOLUME";
      
      public static const LIVE:String = "LIVE";
      
      public static const SCREEN:String = "SCREEN";
      
      public static const SEEK:String = "SEEK";
      
      public static const YOUTUBE_BUTTON:String = "YOUTUBE_BUTTON";
      
      public function VideoControlType()
      {
         super();
      }
      
      public static function get DEFAULT_EXCEPTIONS() : Object
      {
         return {
            "FULLSCREEN":true,
            "VOLUME":true,
            "YOUTUBE_BUTTON":true
         };
      }
   }
}

