package com.google.youtube.ui
{
   public class EnabledState extends BaseControlState implements IEnabledState
   {
      
      public function EnabledState(param1:IUIElement)
      {
         super(param1);
      }
      
      override public function onRollOver() : IUIState
      {
         return new RollOverState(element);
      }
      
      override public function enable() : IUIState
      {
         return this;
      }
      
      override public function onMouseDown() : IUIState
      {
         return new MouseDownState(element);
      }
   }
}

