package com.google.youtube.ui
{
   import com.google.utils.Scheduler;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.IConfigCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.modules.ModuleEvent;
   import com.google.youtube.modules.ModuleStatus;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ModuleButton extends ControlButton
   {
      
      protected static const TOOLTIP_ON_LOAD_TIMEOUT:Number = 5000;
      
      protected var configPanel:DisplayObject;
      
      public var module:ModuleDescriptor;
      
      public function ModuleButton(param1:ModuleDescriptor, param2:IMessages = null)
      {
         this.module = param1;
         super(param2);
         mouseChildren = true;
         tabChildren = true;
         labels = {
            "unloaded":this.module.iconInactive,
            "loaded":this.module.iconActive,
            "error":this.module.iconInactive
         };
         setLabel("unloaded");
         this.module.addEventListener(ModuleEvent.CHANGE,this.onModuleChange,false,0,true);
         this.module.addEventListener(ModuleEvent.BUTTON_VISIBILITY_CHANGE,this.onVisibilityChange,false,0,true);
         name = this.module.uid;
         accessibleName = this.module.description;
         tooltipMessage = this.module.tooltipMessage;
         visible = this.module.visible;
      }
      
      protected function hideConfigPanel() : void
      {
         if(Boolean(this.configPanel) && contains(this.configPanel))
         {
            removeChild(this.configPanel);
         }
      }
      
      private function onVisibilityChange(param1:ModuleEvent) : void
      {
         visible = this.module.visible;
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      protected function showConfigPanel() : void
      {
         if(Boolean(this.configPanel) && !contains(this.configPanel))
         {
            this.onConfigPanelResize();
            addChild(this.configPanel);
         }
      }
      
      override public function get width() : Number
      {
         return this.module.visible ? super.width : 0;
      }
      
      override public function get height() : Number
      {
         return this.module.visible ? super.height : 0;
      }
      
      override public function onMouseUp(param1:MouseEvent) : void
      {
         super.onMouseUp(param1);
         if(this.configPanel && enabled && !(stateValue is IRollOverState))
         {
            this.hideConfigPanel();
         }
      }
      
      public function showLoaded() : void
      {
         if(IConfigCapability in this.module.capabilities)
         {
            this.configPanel = IConfigCapability(this.module.instance).configPanel;
            this.configPanel.addEventListener(Event.RESIZE,this.onConfigPanelResize);
         }
         setLabel("loaded");
         hideNotification();
         if(visible && this.module.showTooltipOnLoad)
         {
            showTooltip();
            Scheduler.setTimeout(TOOLTIP_ON_LOAD_TIMEOUT,function(param1:Event):void
            {
               hideTooltip();
            });
         }
      }
      
      override protected function createBackground() : void
      {
         backgrounds = {
            "up":Theme.getClass("LiteBgUp"),
            "over":Theme.getClass("LiteBgOver"),
            "down":Theme.getClass("LiteBgDown")
         };
      }
      
      public function showError() : void
      {
         setLabel("error");
         showNotification(new AlertIcon());
      }
      
      override public function onClick(param1:MouseEvent) : void
      {
         super.onClick(param1);
         if(this.configPanel)
         {
            if(param1.target != this)
            {
               param1.stopImmediatePropagation();
               return;
            }
            if(enabled && !param1.buttonDown)
            {
               hideTooltip();
               if(contains(this.configPanel))
               {
                  this.hideConfigPanel();
               }
               else
               {
                  this.showConfigPanel();
               }
            }
         }
      }
      
      override public function onRollOut(param1:MouseEvent) : void
      {
         super.onRollOut(param1);
         hideTooltip();
      }
      
      override public function onRollOver(param1:MouseEvent) : void
      {
         showTooltip(false);
         super.onRollOver(param1);
      }
      
      protected function onModuleChange(param1:ModuleEvent) : void
      {
         accessibleName = param1.module.description;
         tooltipMessage = this.module.tooltipMessage;
         switch(param1.module.status)
         {
            case ModuleStatus.UNLOADED:
               this.showUnloaded();
               break;
            case ModuleStatus.LOADING:
               this.showLoading();
               break;
            case ModuleStatus.LOADED:
               this.showLoaded();
               break;
            case ModuleStatus.ERROR:
               this.showError();
         }
      }
      
      public function showUnloaded() : void
      {
         if(this.configPanel)
         {
            this.configPanel.removeEventListener(Event.RESIZE,this.onConfigPanelResize);
            if(contains(this.configPanel))
            {
               removeChild(this.configPanel);
            }
            this.configPanel = null;
         }
         setLabel("unloaded");
         hideNotification();
      }
      
      protected function onConfigPanelResize(param1:Event = null) : void
      {
         if(this.configPanel)
         {
            this.configPanel.x = -this.configPanel.width + nominalWidth;
            this.configPanel.y = -this.configPanel.height - Theme.getConstant("POPUP_MENU_BORDER");
         }
      }
      
      public function showLoading() : void
      {
         setLabel("unloaded");
         showNotification(new AnimatedElement(new MiniSpinner()));
      }
   }
}

