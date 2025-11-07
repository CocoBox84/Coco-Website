package com.google.youtube.ui.themes
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol150")]
   public dynamic class LightVolumeSlider extends MovieClip
   {
      
      public var fill:MovieClip;
      
      public function LightVolumeSlider()
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

