package com.google.youtube.util
{
   import com.google.youtube.event.StageVideoStatusEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   
   use namespace flash_proxy;
   
   public dynamic class StageAmbassador extends Proxy
   {
      
      protected static var fullScreenAllowedValue:Boolean = true;
      
      protected static var stageAllowedValue:Boolean = true;
      
      protected static var stageVideoAvailableWithoutFullscreen:Boolean = false;
      
      protected static var stageVideoAvailableWithoutFullscreenTested:Boolean = false;
      
      protected static var stageVideoAvailabilityTested:Boolean = false;
      
      protected static var stageHasFocusValue:Boolean = false;
      
      public static var hosted:Boolean = false;
      
      public static var stageVideoAvailableValue:Boolean = false;
      
      public static var useRaceConditionWorkaround:Boolean = false;
      
      protected static const StageVideoAvailabilityEvent:Object = getDefinition("flash.events.StageVideoAvailabilityEvent",{"STAGE_VIDEO_AVAILABILITY":"stageVideoAvailability"});
      
      flash_proxy var element:DisplayObjectContainer;
      
      private var postAddedToStageListeners:Array = [];
      
      public function StageAmbassador(param1:DisplayObjectContainer = null)
      {
         super();
         this.flash_proxy::element = param1;
         if(this.addedToStage)
         {
            this.addEventListener(Event.ACTIVATE,this.onStageFocus);
            this.addEventListener(Event.DEACTIVATE,this.onStageBlur);
            this.addEventListener(MouseEvent.CLICK,this.onStageClick,true,0,true);
            this.testStageAvailability();
         }
         else if(!stageVideoAvailabilityTested && Boolean(param1))
         {
            param1.addEventListener(Event.ADDED_TO_STAGE,this.testStageAvailability);
         }
      }
      
      protected function onStageVideoAvailabilityEvent(param1:Event) : void
      {
         stageVideoAvailableValue = Boolean(param1.hasOwnProperty("availability")) && param1["availability"] == "available";
         if(!stageVideoAvailableWithoutFullscreenTested && !this.isFullScreen())
         {
            stageVideoAvailableWithoutFullscreen = stageVideoAvailableValue;
            stageVideoAvailableWithoutFullscreenTested = true;
         }
         this.rebroadcastStageVideoAvailability();
      }
      
      public function isFullScreen() : Boolean
      {
         return this.displayState == StageDisplayState.FULL_SCREEN;
      }
      
      protected function rebroadcastStageVideoAvailability() : void
      {
         if(stageVideoAvailableValue)
         {
            this.dispatchEvent(new StageVideoStatusEvent(StageVideoStatusEvent.AVAILABLE));
         }
         else
         {
            this.dispatchEvent(new StageVideoStatusEvent(StageVideoStatusEvent.UNAVAILABLE));
         }
      }
      
      protected function testStageAvailability(param1:Event = null) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(!stageVideoAvailabilityTested)
         {
            stageVideoAvailabilityTested = true;
            if(StageVideoAvailabilityEvent)
            {
               this.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY,this.onStageVideoAvailabilityEvent);
            }
         }
         if(this.addedToStage && Boolean(this.postAddedToStageListeners.length))
         {
            _loc2_ = this.postAddedToStageListeners;
            this.postAddedToStageListeners = [];
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               this.addEventListener.apply(null,_loc2_[_loc3_]);
               _loc3_++;
            }
         }
      }
      
      private function onStageClick(param1:Event) : void
      {
         if(!stageHasFocusValue)
         {
            this.dispatchEvent(new Event(Event.ACTIVATE,false,false));
         }
      }
      
      public function get addedToStage() : Boolean
      {
         return stageAllowedValue && Boolean(this.flash_proxy::element) && Boolean(this.flash_proxy::element.stage);
      }
      
      public function get stageVideoAvailable() : Boolean
      {
         if(useRaceConditionWorkaround)
         {
            return !hosted && this.flash_proxy::hasProperty("stageVideos") && Boolean(this.stageVideos) && this.stageVideos.length > 0;
         }
         return !hosted && stageVideoAvailableValue && (this.isFullScreen() || stageVideoAvailableWithoutFullscreen) && this.flash_proxy::hasProperty("stageVideos") && Boolean(this.stageVideos) && this.stageVideos.length > 0;
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = true) : void
      {
         var type:String = param1;
         var listener:Function = param2;
         var useCapture:Boolean = param3;
         var priority:int = param4;
         var useWeakReference:Boolean = param5;
         if(stageVideoAvailabilityTested && StageVideoAvailabilityEvent && Object(StageVideoAvailabilityEvent).hasOwnProperty("STAGE_VIDEO_AVAILABILITY") && type == Object(StageVideoAvailabilityEvent)["STAGE_VIDEO_AVAILABILITY"])
         {
            this.rebroadcastStageVideoAvailability();
         }
         if(this.addedToStage)
         {
            try
            {
               this.flash_proxy::element.stage.addEventListener(type,listener,useCapture,priority,useWeakReference);
            }
            catch(e:SecurityError)
            {
               stageAllowedValue = false;
            }
         }
         else
         {
            this.postAddedToStageListeners.push(arguments);
         }
      }
      
      override flash_proxy function hasProperty(param1:*) : Boolean
      {
         var name:* = param1;
         if(this.addedToStage)
         {
            try
            {
               return this.flash_proxy::element.stage.hasOwnProperty(name);
            }
            catch(e:SecurityError)
            {
               stageAllowedValue = false;
            }
         }
         return false;
      }
      
      public function get stageAllowed() : Boolean
      {
         return stageAllowedValue;
      }
      
      override flash_proxy function getProperty(param1:*) : *
      {
         var name:* = param1;
         if(this.addedToStage)
         {
            try
            {
               return this.flash_proxy::element.stage[name];
            }
            catch(e:SecurityError)
            {
               stageAllowedValue = false;
            }
         }
      }
      
      public function get fullScreenAllowed() : Boolean
      {
         return stageAllowedValue && fullScreenAllowedValue;
      }
      
      private function onStageBlur(param1:Event) : void
      {
         stageHasFocusValue = false;
      }
      
      override flash_proxy function setProperty(param1:*, param2:*) : void
      {
         var name:* = param1;
         var value:* = param2;
         try
         {
            if(this.addedToStage)
            {
               this.flash_proxy::element.stage[name] = value;
            }
         }
         catch(e:SecurityError)
         {
            if(e.errorID == 2152)
            {
               fullScreenAllowedValue = false;
            }
            else
            {
               stageAllowedValue = false;
            }
         }
      }
      
      private function onStageFocus(param1:Event) : void
      {
         stageHasFocusValue = true;
      }
      
      override flash_proxy function callProperty(param1:*, ... rest) : *
      {
         var methodName:* = param1;
         var args:Array = rest;
         if(this.addedToStage)
         {
            try
            {
               return this.flash_proxy::element.stage[methodName].apply(null,args);
            }
            catch(e:SecurityError)
            {
               stageAllowedValue = false;
            }
         }
      }
      
      public function resize() : void
      {
         this.dispatchEvent(new Event(Event.RESIZE));
      }
      
      public function get stageHasFocus() : Boolean
      {
         return stageHasFocusValue;
      }
   }
}

