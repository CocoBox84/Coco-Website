package com.google.youtube.modules
{
   import com.google.utils.RequestVariables;
   import com.google.utils.SafeLoader;
   import com.google.youtube.application.Application;
   import com.google.youtube.event.AdEvent;
   import com.google.youtube.event.ExternalEvent;
   import com.google.youtube.model.Environment;
   import com.google.youtube.model.VideoDataEvent;
   import com.google.youtube.players.IVideoAdEventProvider;
   import com.google.youtube.players.IVideoPlayer;
   import com.google.youtube.time.CueRangeManager;
   import com.google.youtube.util.StageAmbassador;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.KeyboardEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class ModuleHost extends EventDispatcher
   {
      
      protected var cueRangeManager:CueRangeManager;
      
      protected var modules:Dictionary = new Dictionary();
      
      protected var videoDataDispatcher:EventDispatcher;
      
      protected var environment:Environment;
      
      protected var commandHandlers:Object = {};
      
      protected var player:IVideoPlayer;
      
      protected var unloadCommands:Object = {};
      
      protected var stageAmbassador:StageAmbassador;
      
      protected var uiEventDispatcher:EventDispatcher;
      
      public function ModuleHost(param1:IVideoPlayer, param2:Environment, param3:CueRangeManager, param4:EventDispatcher, param5:EventDispatcher, param6:StageAmbassador)
      {
         super();
         this.cueRangeManager = param3;
         this.player = param1;
         this.environment = param2;
         this.uiEventDispatcher = param4;
         this.videoDataDispatcher = param5;
         this.stageAmbassador = param6;
      }
      
      public function getModulesByCapability(param1:Class) : Array
      {
         var _loc3_:ModuleDescriptor = null;
         var _loc2_:Array = [];
         for each(_loc3_ in this.modules)
         {
            if(_loc3_.status != ModuleStatus.UNLOADED && _loc3_.status != ModuleStatus.ERROR && param1 in _loc3_.capabilities && (!_loc3_.instance || _loc3_.instance is param1))
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function setCommandHandler(param1:String, param2:Function) : void
      {
         this.commandHandlers[param1] = param2;
      }
      
      public function unregisterAll() : void
      {
         var _loc1_:ModuleDescriptor = null;
         var _loc2_:Array = [];
         for each(_loc1_ in this.modules)
         {
            _loc2_.push(_loc1_);
         }
         for each(_loc1_ in _loc2_)
         {
            if(_loc1_.shouldUnload())
            {
               this.unload(_loc1_);
               _loc1_.removeEventListener(ModuleEvent.CHANGE,this.onModuleChange);
               _loc1_.removeEventListener(ModuleEvent.COMMAND,this.onModuleCommand);
               delete this.modules[_loc1_];
            }
         }
      }
      
      public function getLoadedModulesByCapability(param1:Class) : Array
      {
         var _loc3_:ModuleDescriptor = null;
         var _loc2_:Array = [];
         for each(_loc3_ in this.modules)
         {
            if(_loc3_.status == ModuleStatus.LOADED && param1 in _loc3_.capabilities && _loc3_.instance is param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      protected function loadModuleFromDescriptor(param1:ModuleDescriptor) : void
      {
         var errorFunction:Function;
         var context:LoaderContext;
         var moduleDescriptor:ModuleDescriptor = param1;
         var loader:Loader = new SafeLoader();
         moduleDescriptor.loader = loader;
         moduleDescriptor.status = ModuleStatus.LOADING;
         loader.contentLoaderInfo.addEventListener(Event.INIT,function(param1:Event):void
         {
            param1.target.removeEventListener(Event.INIT,arguments.callee);
            if(param1.target.actionScriptVersion >= 3)
            {
               initDescriptor(moduleDescriptor,IModule(param1.target.content));
            }
            else if(param1.target.loader.hasOwnProperty("unloadAndStop"))
            {
               param1.target.loader.unloadAndStop();
            }
            else
            {
               param1.target.loader.unload();
            }
         });
         errorFunction = function(param1:ErrorEvent):void
         {
            moduleDescriptor.status = ModuleStatus.ERROR;
         };
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorFunction);
         loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorFunction);
         this.registerUncaughtErrorHandler(moduleDescriptor.uid,loader);
         context = new LoaderContext();
         context.applicationDomain = ApplicationDomain.currentDomain;
         context.securityDomain = SecurityDomain.currentDomain;
         loader.load(new URLRequest(moduleDescriptor.url),context);
      }
      
      public function getModules() : Array
      {
         var _loc2_:ModuleDescriptor = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this.modules)
         {
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      protected function onApiChange(param1:Event = null) : void
      {
         if(this.environment)
         {
            this.environment.broadcastExternal(new ExternalEvent(ExternalEvent.API_CHANGE));
         }
      }
      
      public function getDescriptorById(param1:String) : ModuleDescriptor
      {
         var _loc2_:ModuleDescriptor = null;
         for each(_loc2_ in this.modules)
         {
            if(_loc2_.uid == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function registerUncaughtErrorHandler(param1:String, param2:Loader) : void
      {
         var moduleUid:String = param1;
         var loader:Loader = param2;
         var handler:Function = function(param1:Error):void
         {
            handleModuleError(moduleUid,param1);
         };
         Application.registerErrorHandler(loader,handler);
      }
      
      protected function initModule(param1:ModuleDescriptor) : void
      {
         var _loc2_:IModule = param1.instance;
         _loc2_.descriptor = param1;
         _loc2_.player = this.player;
         _loc2_.environment = this.environment;
         _loc2_.stageAmbassador = this.stageAmbassador;
         _loc2_.addEventListener(ModuleEvent.COMMAND,this.onModuleCommand);
         if(param1.capabilities[IScriptCapability])
         {
            _loc2_.addEventListener(ModuleEvent.API_CHANGE,this.onApiChange);
         }
         this.uiEventDispatcher.addEventListener(KeyboardEvent.KEY_DOWN,_loc2_.onKeyDown);
         this.videoDataDispatcher.addEventListener(VideoDataEvent.CHANGE,_loc2_.onVideoDataChange);
         if(param1.capabilities[IVideoAdEventProvider])
         {
            _loc2_.addEventListener(AdEvent.BREAK_START,this.onModuleCommand);
            _loc2_.addEventListener(AdEvent.BREAK_END,this.onModuleCommand);
            _loc2_.addEventListener(AdEvent.PLAY,this.onModuleCommand);
            _loc2_.addEventListener(AdEvent.PAUSE,this.onModuleCommand);
            _loc2_.addEventListener(AdEvent.END,this.onModuleCommand);
         }
         _loc2_.guardedCall(_loc2_.init);
      }
      
      protected function onModuleChange(param1:Event) : void
      {
         var _loc2_:ModuleEvent = null;
         dispatchEvent(param1);
         if(param1 is ModuleEvent)
         {
            _loc2_ = ModuleEvent(param1);
            if(_loc2_.module.capabilities[IScriptCapability])
            {
               this.onApiChange();
            }
         }
      }
      
      public function initDescriptor(param1:ModuleDescriptor, param2:IModule) : Boolean
      {
         if(!(param1 in this.modules))
         {
            return false;
         }
         param1.instance = param2;
         this.initModule(param1);
         return true;
      }
      
      protected function onModuleCommand(param1:Event) : void
      {
         var _loc2_:ModuleEvent = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1 is ModuleEvent)
         {
            _loc2_ = ModuleEvent(param1);
            if(_loc2_.command in this.commandHandlers)
            {
               switch(_loc2_.command)
               {
                  case ModuleEvent.COMMAND_ADD_CUERANGE:
                     _loc2_.args[0].className = getQualifiedClassName(_loc2_.module);
                     break;
                  case ModuleEvent.COMMAND_RESET_LAYER:
                     _loc3_ = getQualifiedClassName(_loc2_.module);
                     _loc4_ = _loc3_ + "/" + _loc2_.args[0];
                     _loc2_.args = [_loc4_];
                     if(_loc3_ in this.unloadCommands)
                     {
                        delete this.unloadCommands[_loc3_][ModuleEvent.COMMAND_RESET_LAYER];
                     }
                     break;
                  case ModuleEvent.COMMAND_SET_LAYER:
                     _loc3_ = getQualifiedClassName(_loc2_.module);
                     _loc4_ = _loc3_ + "/" + _loc2_.args[0];
                     _loc2_.args.unshift(_loc4_);
                     this.unloadCommands[_loc3_] = this.unloadCommands[_loc3_] || {};
                     this.unloadCommands[_loc3_][ModuleEvent.COMMAND_RESET_LAYER] = [_loc4_];
               }
               this.commandHandlers[_loc2_.command].apply(null,_loc2_.args);
            }
         }
         else if(param1 is AdEvent)
         {
            this.commandHandlers[param1.type].apply(null,[param1]);
         }
      }
      
      public function unloadAll() : void
      {
         var _loc1_:ModuleDescriptor = null;
         for each(_loc1_ in this.modules)
         {
            this.unload(_loc1_);
         }
      }
      
      public function register(param1:ModuleDescriptor) : void
      {
         if(!(param1 in this.modules))
         {
            this.modules[param1] = param1;
            param1.addEventListener(ModuleEvent.CHANGE,this.onModuleChange);
            param1.addEventListener(ModuleEvent.COMMAND,this.onModuleCommand);
         }
      }
      
      public function load(param1:ModuleDescriptor, param2:Boolean = false) : void
      {
         if(!(param1 in this.modules))
         {
            return;
         }
         if(param2)
         {
            param1.userLoad();
         }
         if(param1.status == ModuleStatus.ERROR)
         {
            this.unload(param1);
         }
         if(param1.status == ModuleStatus.UNLOADED)
         {
            if(param1.hasRequiredVersion())
            {
               this.loadModuleFromDescriptor(param1);
            }
         }
      }
      
      public function getModulesByType(param1:Class) : Array
      {
         var _loc3_:ModuleDescriptor = null;
         var _loc2_:Array = [];
         for each(_loc3_ in this.modules)
         {
            if(_loc3_ is param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function getLoggingOptions() : Object
      {
         var _loc2_:Object = null;
         var _loc3_:* = undefined;
         var _loc4_:ModuleDescriptor = null;
         var _loc1_:Object = {};
         for each(_loc4_ in this.modules)
         {
            if(_loc4_.status == ModuleStatus.LOADED)
            {
               _loc2_ = _loc4_.instance.getLoggingOptions();
               for(_loc3_ in _loc2_)
               {
                  if(!(_loc3_ in _loc1_))
                  {
                     _loc1_[_loc3_] = _loc2_[_loc3_];
                  }
               }
            }
         }
         return _loc1_;
      }
      
      public function getOptions(param1:String = null) : Array
      {
         var module:ModuleDescriptor;
         var modules:Array = null;
         var script:IScriptCapability = null;
         var moduleId:String = param1;
         if(!moduleId)
         {
            modules = this.getLoadedModulesByCapability(IScriptCapability);
            return modules.map(function(param1:*, param2:int, param3:Array):String
            {
               return param1.uid;
            });
         }
         module = this.getDescriptorById(moduleId);
         if(module)
         {
            script = module.instance as IScriptCapability;
            if(script)
            {
               return script.options;
            }
            return [];
         }
         return null;
      }
      
      public function set videoPlayer(param1:IVideoPlayer) : void
      {
         var _loc2_:ModuleDescriptor = null;
         this.player = param1;
         for each(_loc2_ in this.modules)
         {
            if(_loc2_.instance)
            {
               _loc2_.instance.player = param1;
            }
         }
      }
      
      public function callOption(param1:String = null, param2:String = null, param3:* = undefined) : *
      {
         var _loc5_:IScriptCapability = null;
         if(!param1 || !param2)
         {
            return null;
         }
         var _loc4_:ModuleDescriptor = this.getDescriptorById(param1);
         if(_loc4_)
         {
            _loc5_ = _loc4_.instance as IScriptCapability;
            if(_loc5_)
            {
               return _loc5_.callOption(param2,param3);
            }
         }
         return null;
      }
      
      private function handleModuleError(param1:String, param2:Error) : void
      {
         var _loc3_:RequestVariables = new RequestVariables();
         _loc3_.module = param1;
         this.environment.handleError(param2,_loc3_);
      }
      
      public function unload(param1:ModuleDescriptor, param2:Boolean = false) : void
      {
         var name:String;
         var instance:IModule;
         var command:String = null;
         var moduleDescriptor:ModuleDescriptor = param1;
         var isUserInitiated:Boolean = param2;
         if(!(moduleDescriptor in this.modules))
         {
            return;
         }
         if(isUserInitiated)
         {
            moduleDescriptor.userUnload();
         }
         if(moduleDescriptor.status == ModuleStatus.UNLOADED)
         {
            return;
         }
         this.cueRangeManager.removeCueRangesByClassName(getQualifiedClassName(moduleDescriptor));
         instance = moduleDescriptor.instance;
         if(instance)
         {
            instance.removeEventListener(ModuleEvent.COMMAND,this.onModuleCommand);
            if(moduleDescriptor.capabilities[IScriptCapability])
            {
               instance.removeEventListener(ModuleEvent.API_CHANGE,this.onApiChange);
            }
            this.uiEventDispatcher.removeEventListener(KeyboardEvent.KEY_DOWN,instance.onKeyDown);
            this.videoDataDispatcher.removeEventListener(VideoDataEvent.CHANGE,instance.onVideoDataChange);
            if(Boolean(instance.stageAmbassador.focus) && (instance.stageAmbassador.focus == instance || Sprite(instance).contains(instance.stageAmbassador.focus)))
            {
               instance.stageAmbassador.focus = null;
            }
            try
            {
               instance.destroy();
            }
            catch(error:Error)
            {
               handleModuleError(moduleDescriptor.uid,error);
            }
            if(moduleDescriptor.capabilities[IVideoAdEventProvider])
            {
               instance.removeEventListener(AdEvent.BREAK_START,this.onModuleCommand);
               instance.removeEventListener(AdEvent.BREAK_END,this.onModuleCommand);
               instance.removeEventListener(AdEvent.PLAY,this.onModuleCommand);
               instance.removeEventListener(AdEvent.PAUSE,this.onModuleCommand);
               instance.removeEventListener(AdEvent.END,this.onModuleCommand);
            }
            instance.player = null;
         }
         moduleDescriptor.status = ModuleStatus.UNLOADED;
         moduleDescriptor.instance = null;
         name = getQualifiedClassName(moduleDescriptor);
         if(name in this.unloadCommands)
         {
            for(command in this.unloadCommands[name])
            {
               this.commandHandlers[command].apply(null,this.unloadCommands[name][command]);
            }
            delete this.unloadCommands[name];
         }
         if(moduleDescriptor.loader)
         {
            if(moduleDescriptor.loader.hasOwnProperty("unloadAndStop"))
            {
               moduleDescriptor.loader.unloadAndStop();
            }
            else
            {
               try
               {
                  moduleDescriptor.loader.unload();
               }
               catch(error:ArgumentError)
               {
                  if(error.errorID != 2025)
                  {
                     throw error;
                  }
               }
            }
            moduleDescriptor.loader = null;
         }
      }
   }
}

