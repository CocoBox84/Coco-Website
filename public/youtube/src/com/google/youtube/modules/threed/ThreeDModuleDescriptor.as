package com.google.youtube.modules.threed
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.IModuleEnvironment;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.modules.IConfigCapability;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.IScriptCapability;
   import com.google.youtube.modules.IStageScaleCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.modules.ModuleStatus;
   import com.google.youtube.ui.Button;
   import com.google.youtube.ui.SimpleTextButton;
   import com.google.youtube.ui.Theme;
   import flash.text.TextFormat;
   
   public class ThreeDModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "3d";
      
      protected var isConvertedThreeD:Boolean;
      
      public function ThreeDModuleDescriptor(param1:IMessages)
      {
         var _loc4_:SimpleTextButton = null;
         super(param1,ID);
         var _loc2_:TextFormat = Theme.newTextFormat();
         _loc2_.color = Theme.getConstant("FOREGROUND_TEXT_COLOR");
         var _loc3_:TextFormat = Theme.newTextFormat();
         _loc3_.color = Theme.getConstant("FOREGROUND_TEXT_COLOR_HOVER");
         _loc4_ = new SimpleTextButton("3D",_loc2_);
         var _loc5_:SimpleTextButton = new SimpleTextButton("+3D",_loc3_);
         iconActive = new Button();
         iconActive.labels = {
            "active":Theme.newActiveButton(ThreeDIcon),
            "inactive":Theme.newButton(ThreeDIcon),
            "converted_active":_loc5_,
            "converted_inactive":_loc4_
         };
         iconActive.setLabel("active");
         iconInactive = new Button();
         iconInactive.labels = {
            "uploaded":Theme.newButton(ThreeDIcon),
            "converted":_loc4_
         };
         iconInactive.setLabel("uploaded");
         capabilities[IConfigCapability] = true;
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
         capabilities[IScriptCapability] = true;
         capabilities[IStageScaleCapability] = true;
      }
      
      override protected function onMessageUpdate(param1:MessageEvent) : void
      {
         moduleName = param1.messages.getMessage(WatchMessages.THREE_D);
      }
      
      override public function shouldLoad(param1:IModuleEnvironment, param2:VideoData) : Boolean
      {
         this.isConvertedThreeD = Boolean(param2.rawVideoInfo.threed_converted) || Boolean(param1.rawParameters.threed_converted);
         if(this.isConvertedThreeD)
         {
            iconInactive.setLabel("converted");
         }
         advancedButton = this.isConvertedThreeD;
         return !this.isConvertedThreeD || Boolean(param2.threeDLayoutPreview);
      }
      
      override public function get tooltipMessage() : String
      {
         if(!this.isConvertedThreeD)
         {
            return WatchMessages.THREED_TOOLTIP;
         }
         if(status == ModuleStatus.UNLOADED || status == ModuleStatus.LOADING)
         {
            return WatchMessages.THREED_CONVERTED;
         }
         return WatchMessages.THREED_CONVERTED_TOOLTIP;
      }
   }
}

