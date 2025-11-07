package com.google.youtube.ui
{
   public class BaseControlState implements IUIState
   {
      
      protected var element:IUIElement;
      
      public function BaseControlState(param1:IUIElement)
      {
         super();
         this.element = param1;
      }
      
      public function onMouseUp() : IUIState
      {
         return this;
      }
      
      public function enable() : IUIState
      {
         return new EnabledState(this.element);
      }
      
      public function onMouseDown() : IUIState
      {
         return this;
      }
      
      public function onRollOver() : IUIState
      {
         return this;
      }
      
      public function onRollOut() : IUIState
      {
         return this;
      }
      
      public function disable() : IUIState
      {
         return new DisabledState(this.element);
      }
      
      public function setState(param1:IUIState) : IUIState
      {
         return param1;
      }
   }
}

