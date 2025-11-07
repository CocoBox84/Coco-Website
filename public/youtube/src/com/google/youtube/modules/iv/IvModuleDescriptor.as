package com.google.youtube.modules.iv
{
   import com.google.utils.RequestVariables;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.IModuleEnvironment;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.IScriptCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.modules.ModuleStatus;
   import com.google.youtube.ui.Theme;
   
   public class IvModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "iv";
      
      public function IvModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         iconActive = Theme.newActiveButton(IvIcon);
         iconInactive = Theme.newButton(IvIcon);
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
         capabilities[IScriptCapability] = true;
         showButton = false;
      }
      
      override public function shouldLoad(param1:IModuleEnvironment, param2:VideoData) : Boolean
      {
         showButton = !param2.isHls;
         return param2.isHls || (param1.rawParameters.iv_load_policy || param2.rawVideoInfo.iv_load_policy) == MODULE_LOAD_ALWAYS;
      }
      
      override public function userLoad() : void
      {
         super.userLoad();
         var _loc1_:RequestVariables = new RequestVariables();
         _loc1_.toggle = 1;
         log("iv",_loc1_);
      }
      
      override public function userUnload() : void
      {
         super.userUnload();
         var _loc1_:RequestVariables = new RequestVariables();
         _loc1_.toggle = 0;
         log("iv",_loc1_);
      }
      
      override public function get tooltipMessage() : String
      {
         switch(status)
         {
            case ModuleStatus.UNLOADED:
               return WatchMessages.ANNOTATIONS_ON;
            case ModuleStatus.LOADED:
               return WatchMessages.ANNOTATIONS_OFF;
            case ModuleStatus.ERROR:
               return WatchMessages.ANNOTATIONS_UNAVAILABLE;
            default:
               return "";
         }
      }
      
      override protected function onMessageUpdate(param1:MessageEvent) : void
      {
         moduleName = param1.messages.getMessage(WatchMessages.ANNOTATIONS);
      }
   }
}

