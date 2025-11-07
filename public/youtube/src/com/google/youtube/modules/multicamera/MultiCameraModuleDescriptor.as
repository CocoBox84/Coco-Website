package com.google.youtube.modules.multicamera
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.modules.IControlsCapability;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.ui.Button;
   import com.google.youtube.ui.CameraIcon;
   import com.google.youtube.ui.Theme;
   import flash.geom.Rectangle;
   
   public class MultiCameraModuleDescriptor extends ModuleDescriptor implements IControlsCapability
   {
      
      public static const ID:String = "multicamera";
      
      public static const CONTROLS_HEIGHT:int = 80;
      
      public var button:Button = new Button();
      
      public function MultiCameraModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         this.button.labels = {
            "active":Theme.newActiveButton(CameraIcon),
            "inactive":Theme.newButton(CameraIcon)
         };
         this.button.setLabel("inactive");
         iconActive = this.button;
         iconInactive = this.button;
         showButton = false;
         capabilities[IResizeableCapability] = true;
         capabilities[IOverlayCapability] = true;
         capabilities[IControlsCapability] = true;
      }
      
      public function set controlsRespected(param1:Boolean) : void
      {
         if(instance)
         {
            IControlsCapability(instance).controlsRespected = param1;
         }
      }
      
      override public function get tooltipMessage() : String
      {
         return WatchMessages.CAMERA_SELECTOR_MENU;
      }
      
      public function get controlsInset() : Rectangle
      {
         if(instance)
         {
            return IControlsCapability(instance).controlsInset;
         }
         return new Rectangle();
      }
   }
}

