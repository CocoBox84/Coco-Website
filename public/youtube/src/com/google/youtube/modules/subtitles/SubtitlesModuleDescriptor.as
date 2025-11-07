package com.google.youtube.modules.subtitles
{
   import com.google.utils.PlayerVersion;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.IModuleEnvironment;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.model.YouTubeEnvironment;
   import com.google.youtube.modules.IConfigCapability;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.IScriptCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.modules.ModuleStatus;
   import com.google.youtube.ui.Button;
   import com.google.youtube.ui.Theme;
   
   public class SubtitlesModuleDescriptor extends ModuleDescriptor
   {
      
      private static const NORMAL_REGIONS:Array = ["CA","MX","US"];
      
      public static const ID:String = "cc";
      
      public static const SUBTITLES_LOAD_POLICY_KEY:String = "loadPolicy";
      
      protected var tooltipMessageValue:String = "";
      
      public var subtitlesButton:Button = new Button();
      
      private var isUserLoadedValue:Boolean = false;
      
      private var activeButton:Button = new Button();
      
      private var inactiveButton:Button = new Button();
      
      public function SubtitlesModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         this.activeButton.labels = {
            "normal":Theme.newActiveButton(CcIcon),
            "international":Theme.newActiveButton(CcIconInternational)
         };
         this.activeButton.setLabel("normal");
         this.inactiveButton.labels = {
            "normal":Theme.newButton(CcIcon),
            "international":Theme.newButton(CcIconInternational)
         };
         this.inactiveButton.setLabel("normal");
         this.subtitlesButton.labels = {
            "active":this.activeButton,
            "inactive":this.inactiveButton
         };
         iconActive = this.subtitlesButton;
         iconInactive = this.subtitlesButton;
         this.subtitlesButton.setLabel("inactive");
         capabilities[IConfigCapability] = true;
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
         capabilities[IScriptCapability] = true;
         requiredVersion = new PlayerVersion(10);
         requiredClassList = ["flash.text.engine.BreakOpportunity"];
         loadPolicy = MODULE_LOAD_BY_PREFERENCE;
         sharedObjectKey = "subtitlesModuleData";
      }
      
      override protected function onMessageUpdate(param1:MessageEvent) : void
      {
         moduleName = param1.messages.getMessage(WatchMessages.SUBTITLES);
      }
      
      override public function get tooltipMessage() : String
      {
         switch(status)
         {
            case ModuleStatus.UNLOADED:
               return WatchMessages.CAPTIONS_ON;
            case ModuleStatus.ERROR:
               return WatchMessages.CAPTIONS_UNAVAILABLE;
            default:
               return this.tooltipMessageValue || WatchMessages.SUBTITLES;
         }
      }
      
      public function set tooltipMessage(param1:String) : void
      {
         this.tooltipMessageValue = param1;
      }
      
      override public function userUnload() : void
      {
         setSharedObject(SUBTITLES_LOAD_POLICY_KEY,MODULE_LOAD_BY_REQUEST);
         this.isUserLoadedValue = false;
         super.userUnload();
      }
      
      override public function userLoad() : void
      {
         setSharedObject(SUBTITLES_LOAD_POLICY_KEY,MODULE_LOAD_ALWAYS);
         this.isUserLoadedValue = true;
         super.userLoad();
      }
      
      public function get isUserLoaded() : Boolean
      {
         return this.isUserLoadedValue;
      }
      
      override public function shouldLoad(param1:IModuleEnvironment, param2:VideoData) : Boolean
      {
         var _loc3_:Object = param1.rawParameters;
         var _loc4_:YouTubeEnvironment = param1 as YouTubeEnvironment;
         if((_loc4_) && _loc4_.contentRegion && NORMAL_REGIONS.indexOf(_loc4_.contentRegion) == -1 && !_loc4_.experiments.isExperimentActive("914304"))
         {
            this.activeButton.setLabel("international");
            this.inactiveButton.setLabel("international");
         }
         if(_loc3_.cc_load_policy == MODULE_LOAD_ALWAYS || param2.rawVideoInfo.cc_load_policy == MODULE_LOAD_ALWAYS || param2.getMachineTagValue("yt:cc") == "alwayson")
         {
            return true;
         }
         var _loc5_:int = int(getSharedObjectValue(SUBTITLES_LOAD_POLICY_KEY));
         var _loc6_:Boolean = _loc5_ == MODULE_LOAD_ALWAYS || _loc5_ == MODULE_LOAD_BY_REQUEST;
         if(_loc6_)
         {
            return _loc5_ == MODULE_LOAD_ALWAYS;
         }
         return param2.getMachineTagValue("yt:cc") == "on" || Boolean(_loc3_.cc_prefer_on);
      }
   }
}

