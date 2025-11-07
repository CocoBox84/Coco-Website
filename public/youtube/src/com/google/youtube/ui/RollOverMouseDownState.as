package com.google.youtube.ui
{
   public class RollOverMouseDownState extends EnabledState implements IMouseDownState, IRollOverState
   {
      
      public function RollOverMouseDownState(param1:IUIElement)
      {
         super(param1);
      }
      
      override public function onMouseUp() : IUIState
      {
         return new RollOverState(element);
      }
      
      override public function onRollOut() : IUIState
      {
         return new MouseDownState(element);
      }
      
      override public function onRollOver() : IUIState
      {
         return this;
      }
      
      override public function onMouseDown() : IUIState
      {
         return this;
      }
   }
}

