package com.google.youtube.ui
{
   public interface IMenuItem extends IUIElement, ILayoutElement
   {
      
      function get selected() : Boolean;
      
      function set selected(param1:Boolean) : void;
   }
}

