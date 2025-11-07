package com.google.youtube.modules
{
   import flash.geom.Rectangle;
   
   public interface IOverlayCapability
   {
      
      function onVideoControlsHide() : void;
      
      function get reservedRect() : Rectangle;
      
      function onVideoControlsShow() : void;
   }
}

