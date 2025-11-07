package com.google.youtube.ui
{
   import flash.display.Graphics;
   
   public function drawing(param1:Graphics) : Drawing
   {
      Drawing.DRAWING.graphics = param1;
      return Drawing.DRAWING;
   }
}

