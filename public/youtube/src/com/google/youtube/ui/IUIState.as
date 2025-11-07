package com.google.youtube.ui
{
   public interface IUIState
   {
      
      function onRollOver() : IUIState;
      
      function onMouseUp() : IUIState;
      
      function onRollOut() : IUIState;
      
      function enable() : IUIState;
      
      function setState(param1:IUIState) : IUIState;
      
      function disable() : IUIState;
      
      function onMouseDown() : IUIState;
   }
}

