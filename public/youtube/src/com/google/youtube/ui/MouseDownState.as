package com.google.youtube.ui
{
   public class MouseDownState extends EnabledState implements IMouseDownState
   {
      
      public function MouseDownState(param1:IUIElement)
      {
         super(param1);
      }
      
      override public function onRollOver() : IUIState
      {
         return new RollOverMouseDownState(element);
      }
      
      override public function onMouseUp() : IUIState
      {
         return new EnabledState(element);
      }
      
      override public function onMouseDown() : IUIState
      {
         return this;
      }
   }
}

