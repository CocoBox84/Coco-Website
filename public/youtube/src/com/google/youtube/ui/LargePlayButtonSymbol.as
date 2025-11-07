package com.google.youtube.ui
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol5")]
   public dynamic class LargePlayButtonSymbol extends MovieClip
   {
      
      public function LargePlayButtonSymbol()
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

