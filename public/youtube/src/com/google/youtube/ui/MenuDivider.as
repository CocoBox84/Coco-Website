package com.google.youtube.ui
{
   public class MenuDivider extends UIElement implements IMenuItem
   {
      
      public function MenuDivider()
      {
         super();
         horizontalStretch = 1;
         nominalHeight = 5;
         enabled = false;
         useHandCursor = false;
      }
      
      override protected function drawForeground() : void
      {
         foreground.graphics.clear();
         foreground.graphics.lineStyle(1,Theme.getConstant("SHADOW_COLOR"),1);
         foreground.graphics.moveTo(1,int(nominalHeight / 2));
         foreground.graphics.lineTo(nominalWidth - 1,int(nominalHeight / 2));
         foreground.graphics.lineStyle(1,Theme.getConstant("HIGHLIGHT_COLOR"),0.1);
         foreground.graphics.moveTo(1,int(nominalHeight / 2) + 1);
         foreground.graphics.lineTo(nominalWidth - 1,int(nominalHeight / 2) + 1);
      }
      
      public function get selected() : Boolean
      {
         return false;
      }
      
      public function set selected(param1:Boolean) : void
      {
      }
   }
}

