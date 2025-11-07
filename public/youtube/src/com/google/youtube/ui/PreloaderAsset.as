package com.google.youtube.ui
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol9")]
   public dynamic class PreloaderAsset extends MovieClip
   {
      
      public function PreloaderAsset()
      {
         super();
         addFrameScript(23,this.frame24);
      }
      
      internal function frame24() : *
      {
         stop();
      }
   }
}

