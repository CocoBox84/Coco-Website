package com.google.youtube.ui
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol159")]
   public dynamic class VideoThumb extends MovieClip
   {
      
      public function VideoThumb()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

