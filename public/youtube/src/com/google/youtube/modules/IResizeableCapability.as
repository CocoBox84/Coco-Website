package com.google.youtube.modules
{
   import com.google.youtube.event.ResizeEvent;
   
   public interface IResizeableCapability
   {
      
      function onResize(param1:ResizeEvent) : void;
      
      function onDisplayResize(param1:ResizeEvent) : void;
   }
}

