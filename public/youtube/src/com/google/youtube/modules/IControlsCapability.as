package com.google.youtube.modules
{
   import flash.geom.Rectangle;
   
   public interface IControlsCapability
   {
      
      function set controlsRespected(param1:Boolean) : void;
      
      function get controlsInset() : Rectangle;
   }
}

