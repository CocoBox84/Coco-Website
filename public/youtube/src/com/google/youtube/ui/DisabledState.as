package com.google.youtube.ui
{
   public class DisabledState extends BaseControlState implements IDisabledState
   {
      
      public function DisabledState(param1:IUIElement)
      {
         super(param1);
      }
      
      override public function disable() : IUIState
      {
         return this;
      }
   }
}

