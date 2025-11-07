package com.google.youtube.ui
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol15")]
   public dynamic class MiniSpinner extends MovieClip
   {
      
      public function MiniSpinner()
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

