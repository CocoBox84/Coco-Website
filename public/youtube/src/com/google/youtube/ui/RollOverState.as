package com.google.youtube.ui
{
   public class RollOverState extends EnabledState implements IRollOverState
   {
      
      public function RollOverState(param1:IUIElement)
      {
         super(param1);
      }
      
      override public function onRollOver() : IUIState
      {
         return this;
      }
      
      override public function onMouseDown() : IUIState
      {
         return new RollOverMouseDownState(element);
      }
      
      override public function onRollOut() : IUIState
      {
         return new EnabledState(element);
      }
   }
}

