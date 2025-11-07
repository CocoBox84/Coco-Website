package com.google.youtube.model
{
   public class ExternalPlayerState
   {
      
      public static const UNSTARTED:int = -1;
      
      public static const ENDED:int = 0;
      
      public static const PLAYING:int = 1;
      
      public static const PAUSED:int = 2;
      
      public static const BUFFERING:int = 3;
      
      public static const CUED:int = 5;
      
      public function ExternalPlayerState()
      {
         super();
      }
   }
}

