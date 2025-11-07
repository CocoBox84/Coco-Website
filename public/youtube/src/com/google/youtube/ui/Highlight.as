package com.google.youtube.ui
{
   public class Highlight extends UIElement
   {
      
      public function Highlight()
      {
         super();
      }
      
      override protected function drawBackground() : void
      {
         drawing(graphics).clear().fill(Theme.getConstant("MENU_HIGHLIGHT_COLOR"),Theme.getConstant("MENU_HIGHLIGHT_ALPHA")).rect(0,0,int(nominalWidth),int(nominalHeight)).end();
      }
   }
}

