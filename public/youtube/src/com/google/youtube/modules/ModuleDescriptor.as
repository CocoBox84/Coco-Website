package com.google.youtube.modules
{
   import com.google.utils.PlayerVersion;
   import com.google.utils.RequestVariables;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.IModuleEnvironment;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.util.hasDefinition;
   import flash.display.Loader;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   import flash.net.SharedObject;
   import flash.utils.Dictionary;
   
   public class ModuleDescriptor extends EventDispatcher
   {
      
      public static const VALIDATE_SIZE_PREROLL:String = "VALIDATE_SIZE_PREROLL";
      
      protected static const MODULE_LOAD_ALWAYS:int = 1;
      
      protected static const MODULE_LOAD_BY_PREFERENCE:int = 2;
      
      protected static const MODULE_LOAD_BY_REQUEST:int = 3;
      
      protected var uidValue:String = "";
      
      public var iconInactive:*;
      
      public var loader:Loader;
      
      public var instance:IModule;
      
      private var moduleNameValue:String;
      
      private var statusValue:String = "UNLOADED";
      
      protected var showButtonValue:Boolean = true;
      
      public var capabilities:Dictionary = new Dictionary();
      
      public var loadPolicy:int = 1;
      
      public var sharedObjectKey:String = null;
      
      public var requiredSize:Rectangle;
      
      public var requiredVersion:PlayerVersion;
      
      public var showTooltipOnLoad:Boolean = false;
      
      protected var messages:IMessages;
      
      public var requiredClassList:Array = [];
      
      protected var advancedButtonValue:Boolean;
      
      public var iconActive:*;
      
      public var url:String;
      
      public function ModuleDescriptor(param1:IMessages, param2:String)
      {
         super();
         this.messages = param1;
         this.uidValue = param2;
         param1.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
      }
      
      public function setSharedObject(param1:String = null, param2:Object = null) : void
      {
         var so:SharedObject = null;
         var key:String = param1;
         var value:Object = param2;
         if(this.sharedObjectKey)
         {
            try
            {
               so = SharedObject.getLocal(this.sharedObjectKey,"/");
               if(key)
               {
                  so.data[key] = value;
               }
               else
               {
                  so.clear();
               }
               so.flush();
            }
            catch(error:Error)
            {
            }
         }
      }
      
      public function get visible() : Boolean
      {
         return this.showButton && !this.advancedButton;
      }
      
      public function get tooltipMessage() : String
      {
         return "";
      }
      
      public function get showButton() : Boolean
      {
         return this.showButtonValue;
      }
      
      protected function onMessageUpdate(param1:MessageEvent) : void
      {
         this.moduleName = param1.messages.getMessage(WatchMessages.PLAYER_MODULE);
      }
      
      public function shouldUnload() : Boolean
      {
         return true;
      }
      
      public function get moduleName() : String
      {
         return this.moduleNameValue;
      }
      
      public function getSharedObjectValue(param1:String) : Object
      {
         var result:Object = null;
         var so:SharedObject = null;
         var key:String = param1;
         if(this.sharedObjectKey)
         {
            try
            {
               so = SharedObject.getLocal(this.sharedObjectKey,"/");
               result = so.data[key];
            }
            catch(error:Error)
            {
            }
         }
         return result;
      }
      
      public function set showButton(param1:Boolean) : void
      {
         if(this.showButtonValue != param1)
         {
            this.showButtonValue = param1;
            dispatchEvent(new ModuleEvent(ModuleEvent.BUTTON_VISIBILITY_CHANGE,this));
         }
      }
      
      public function userUnload() : void
      {
      }
      
      public function set moduleName(param1:String) : void
      {
         this.moduleNameValue = param1;
         this.notify();
      }
      
      public function shouldLoad(param1:IModuleEnvironment, param2:VideoData) : Boolean
      {
         return this.loadPolicy == MODULE_LOAD_ALWAYS;
      }
      
      public function hasRequiredVersion() : Boolean
      {
         var _loc1_:PlayerVersion = null;
         if(this.requiredVersion)
         {
            _loc1_ = PlayerVersion.getPlayerVersion();
            if(!_loc1_.isAtLeastPlayerVersion(this.requiredVersion))
            {
               this.status = ModuleStatus.ERROR;
               return false;
            }
         }
         if(!hasDefinition.apply(null,this.requiredClassList))
         {
            this.status = ModuleStatus.ERROR;
            return false;
         }
         return true;
      }
      
      public function notify() : void
      {
         dispatchEvent(new ModuleEvent(ModuleEvent.CHANGE,this));
      }
      
      public function get uid() : String
      {
         return this.uidValue;
      }
      
      public function userLoad() : void
      {
      }
      
      public function log(param1:String, param2:RequestVariables) : void
      {
         dispatchEvent(new ModuleEvent(ModuleEvent.COMMAND,this,ModuleEvent.COMMAND_LOG,param1,param2));
      }
      
      public function set status(param1:String) : void
      {
         if(this.statusValue != param1)
         {
            this.statusValue = param1;
            this.notify();
         }
      }
      
      public function set advancedButton(param1:Boolean) : void
      {
         if(this.advancedButtonValue != param1)
         {
            this.advancedButtonValue = param1;
            dispatchEvent(new ModuleEvent(ModuleEvent.BUTTON_VISIBILITY_CHANGE,this));
         }
      }
      
      public function get status() : String
      {
         return this.statusValue;
      }
      
      public function get advancedButton() : Boolean
      {
         return this.advancedButtonValue;
      }
      
      public function hasRequiredSize(param1:Rectangle) : Boolean
      {
         return !this.requiredSize || param1.contains(this.requiredSize.width - 1,this.requiredSize.height - 1);
      }
      
      public function get description() : String
      {
         var _loc1_:String = this.moduleName || this.messages.getMessage(WatchMessages.PLAYER_MODULE);
         return _loc1_ + " " + this.messages.getMessage(this.status);
      }
   }
}

