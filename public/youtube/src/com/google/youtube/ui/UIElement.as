package com.google.youtube.ui
{
   import com.google.youtube.event.AccessibilityPropertiesEvent;
   import com.google.youtube.util.StageAmbassador;
   import com.google.youtube.util.Tween;
   import flash.accessibility.AccessibilityProperties;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class UIElement extends LayoutElement implements IUIElement
   {
      
      protected var tooltip:Tooltip;
      
      public var layoutOrderPriority:int = 0;
      
      protected var nominalHeight:int;
      
      protected var background:Sprite = new Sprite();
      
      protected var stageAmbassadorValue:StageAmbassador;
      
      protected var foreground:Sprite = new Sprite();
      
      protected var nominalWidth:int;
      
      protected var stateValue:IUIState;
      
      protected var draggingValue:Boolean;
      
      protected var tooltipTextValue:String;
      
      protected var mouseOffStage:Boolean;
      
      public var classOrderPriority:int = -1;
      
      private var accessibleDescriptionValue:String = "";
      
      private var accessibleStateValue:String = "";
      
      protected var tweenValue:Tween;
      
      protected var labelValue:String;
      
      public function UIElement()
      {
         super();
         super.addChild(this.background);
         this.background.mouseEnabled = false;
         super.addChild(this.foreground);
         this.foreground.mouseEnabled = false;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         addEventListener(MouseEvent.CLICK,this.onClick);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
         addEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
         this.stateValue = new EnabledState(this);
         this.classOrderPriority = UIElementOrder.getClassOrderPriority(this);
      }
      
      public function set isAccessible(param1:Boolean) : void
      {
         if(!accessibilityProperties)
         {
            accessibilityProperties = new AccessibilityProperties();
         }
         if(accessibilityProperties.silent == param1 || accessibilityProperties.forceSimple == param1)
         {
            accessibilityProperties.silent = !param1;
            accessibilityProperties.forceSimple = !param1;
            this.updateAccessibilityProperties();
         }
      }
      
      protected function updateAccessibilityProperties() : void
      {
         dispatchEvent(new AccessibilityPropertiesEvent(AccessibilityPropertiesEvent.UPDATE));
      }
      
      override public function get height() : Number
      {
         return this.nominalHeight || super.height;
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         return super.getChildAt(param1 + (Boolean(this.background) && contains(this.background) ? 1 : 0));
      }
      
      public function onFocusIn(param1:FocusEvent) : void
      {
         this.onRollOver(new MouseEvent(MouseEvent.ROLL_OVER,false));
         param1.stopPropagation();
      }
      
      public function get shortcutKey() : String
      {
         return accessibilityProperties ? accessibilityProperties.shortcut : null;
      }
      
      public function onMouseUp(param1:MouseEvent) : void
      {
         this.releaseMouse();
         this.setState(this.stateValue.onMouseUp());
      }
      
      public function getLabel() : String
      {
         return this.labelValue;
      }
      
      public function showTooltip(param1:Boolean = true) : void
      {
         if(Boolean(this.tooltipTextValue) && (!this.tooltip || this.tooltip.hasDelay != param1))
         {
            this.hideTooltip();
            this.tooltip = new Tooltip(param1);
            this.tooltip.alignWith(this);
            this.tooltipText = this.tooltipTextValue;
         }
         if(Boolean(root) && Boolean(this.tooltip))
         {
            DisplayObjectContainer(root).addChild(this.tooltip);
         }
      }
      
      public function get enabled() : Boolean
      {
         return this.stateValue is IEnabledState;
      }
      
      override public function removeChildAt(param1:int) : DisplayObject
      {
         return super.removeChildAt(param1 + (Boolean(this.background) && contains(this.background) ? 1 : 0));
      }
      
      public function setState(param1:IUIState) : IUIState
      {
         if(this.stateValue != param1)
         {
            this.stateValue = param1;
            this.onStateChanged();
         }
         return this.stateValue;
      }
      
      override public function set height(param1:Number) : void
      {
         this.setSize(this.nominalWidth,param1);
      }
      
      public function onFocusOut(param1:FocusEvent) : void
      {
         if(!param1.relatedObject || !param1.currentTarget.contains(param1.relatedObject))
         {
            this.onRollOut(new MouseEvent(MouseEvent.ROLL_OUT,false));
            param1.stopPropagation();
         }
      }
      
      override public function stopDrag() : void
      {
         super.stopDrag();
         this.draggingValue = false;
      }
      
      protected function drawSolidBackground(param1:uint, param2:Number) : void
      {
         drawing(this.background.graphics).clear().fill(param1,param2).rect(0,0,int(this.nominalWidth),int(this.nominalHeight)).end();
      }
      
      public function get accessibleDescription() : String
      {
         return this.accessibleDescriptionValue;
      }
      
      public function get dragging() : Boolean
      {
         return this.draggingValue;
      }
      
      public function hideTooltip() : void
      {
         if(!this.tooltip)
         {
            return;
         }
         if(Boolean(root) && DisplayObjectContainer(root).contains(this.tooltip))
         {
            DisplayObjectContainer(root).removeChild(this.tooltip);
         }
         this.tooltip = null;
      }
      
      protected function onStateChanged() : void
      {
         if(this.stateValue is IRollOverState)
         {
            this.showTooltip();
         }
         else
         {
            this.hideTooltip();
         }
      }
      
      public function get tween() : Tween
      {
         if(!this.tweenValue)
         {
            this.tweenValue = new Tween(this);
         }
         return this.tweenValue;
      }
      
      public function get stageAmbassador() : StageAmbassador
      {
         if(!this.stageAmbassadorValue)
         {
            this.stageAmbassadorValue = new StageAmbassador(this);
         }
         return this.stageAmbassadorValue;
      }
      
      public function get accessibleName() : String
      {
         return accessibilityProperties ? accessibilityProperties.name : null;
      }
      
      public function set shortcutKey(param1:String) : void
      {
         if(!accessibilityProperties)
         {
            accessibilityProperties = new AccessibilityProperties();
         }
         if(accessibilityProperties.shortcut != param1)
         {
            accessibilityProperties.shortcut = param1;
            this.updateAccessibilityProperties();
         }
      }
      
      protected function onStageMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:MouseEvent = null;
         if(this.stateValue is IMouseDownState)
         {
            param1.stopImmediatePropagation();
            _loc2_ = globalToLocal(new Point(param1.stageX,param1.stageY));
            _loc3_ = new MouseEvent(MouseEvent.MOUSE_MOVE,false,false,_loc2_.x,_loc2_.y,param1.relatedObject,param1.ctrlKey,param1.altKey,param1.shiftKey,param1.buttonDown,param1.delta);
            dispatchEvent(_loc3_);
         }
      }
      
      protected function onStageMouseOver(param1:MouseEvent) : void
      {
         this.mouseOffStage = false;
      }
      
      public function get accessibleState() : String
      {
         return this.accessibleStateValue;
      }
      
      public function get tabOrderPriority() : int
      {
         return this.classOrderPriority + this.layoutOrderPriority;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         var _loc2_:Boolean = this.enabled;
         if(param1)
         {
            this.setState(this.stateValue.enable());
         }
         else
         {
            this.setState(this.stateValue.disable());
         }
         if(_loc2_ != this.enabled)
         {
            this.redraw();
         }
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         this.nominalWidth = param1;
         this.nominalHeight = param2;
         this.redraw();
      }
      
      public function get isAccessible() : Boolean
      {
         return accessibilityProperties ? !accessibilityProperties.silent : buttonMode;
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         param2 = Math.min(getChildIndex(this.foreground),param2 + (Boolean(this.background) && contains(this.background) ? 1 : 0));
         return super.addChildAt(param1,param2);
      }
      
      protected function drawBackground() : void
      {
      }
      
      override public function set width(param1:Number) : void
      {
         this.setSize(param1,this.nominalHeight);
      }
      
      public function set tooltipText(param1:String) : void
      {
         this.tooltipTextValue = param1 || "";
         if(!this.tooltipTextValue)
         {
            this.hideTooltip();
         }
         else if(this.tooltip)
         {
            this.tooltip.setContents(this.tooltipTextValue);
         }
         this.accessibleName = this.tooltipTextValue;
      }
      
      protected function onAddedToStage(param1:Event) : void
      {
         this.stageAmbassador.addEventListener(MouseEvent.MOUSE_OVER,this.onStageMouseOver);
         this.stageAmbassador.addEventListener(MouseEvent.MOUSE_OUT,this.onStageMouseOut);
         this.stageAmbassador.addEventListener(MouseEvent.MOUSE_UP,this.onStageMouseUp);
         root.addEventListener(MouseEvent.MOUSE_UP,this.onStageMouseUp);
         this.updateAccessibilityProperties();
         dispatchEvent(new Event(Event.TAB_ENABLED_CHANGE,true));
      }
      
      override public function get numChildren() : int
      {
         return super.numChildren - (Boolean(this.background) && contains(this.background) ? 1 : 0) - (Boolean(this.foreground) && contains(this.foreground) ? 1 : 0);
      }
      
      protected function drawForeground() : void
      {
         var _loc1_:Drawing = drawing(this.foreground.graphics).clear();
         if(this.enabled)
         {
            _loc1_.fill(0,0);
         }
         else
         {
            _loc1_.fill([Theme.getConstant("DISABLED_COLOR"),Theme.getConstant("DISABLED_SHADOW_COLOR")],[Theme.getConstant("DISABLED_ALPHA"),Theme.getConstant("DISABLED_ALPHA")],[0,255],90,this.nominalWidth,this.nominalHeight);
         }
         _loc1_.rect(0,0,this.nominalWidth,this.nominalHeight).end();
      }
      
      public function onRollOut(param1:MouseEvent) : void
      {
         if(this.stateValue is IMouseDownState && (hasEventListener(MouseEvent.MOUSE_MOVE) || this.draggingValue))
         {
            this.captureMouse();
         }
         this.setState(this.stateValue.onRollOut());
      }
      
      override public function startDrag(param1:Boolean = false, param2:Rectangle = null) : void
      {
         this.draggingValue = true;
         super.startDrag(param1,param2);
      }
      
      protected function onStageMouseUp(param1:MouseEvent) : void
      {
         if(this.stateValue is IMouseDownState)
         {
            dispatchEvent(param1);
         }
      }
      
      public function set accessibleName(param1:String) : void
      {
         if(!accessibilityProperties)
         {
            accessibilityProperties = new AccessibilityProperties();
         }
         if(accessibilityProperties.name != param1)
         {
            accessibilityProperties.name = param1;
            this.updateAccessibilityProperties();
         }
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         x = param1;
         y = param2;
      }
      
      override public function get width() : Number
      {
         return this.nominalWidth || super.width;
      }
      
      public function onMouseDown(param1:MouseEvent) : void
      {
         this.setState(this.stateValue.onMouseDown());
      }
      
      public function setLabel(param1:String, param2:Boolean = true) : void
      {
         if(this.labelValue != param1)
         {
            this.labelValue = param1;
            this.redraw();
         }
      }
      
      public function set accessibleDescription(param1:String) : void
      {
         if(!accessibilityProperties)
         {
            accessibilityProperties = new AccessibilityProperties();
         }
         if(this.accessibleDescriptionValue != param1)
         {
            this.accessibleDescriptionValue = param1;
            accessibilityProperties.description = this.accessibleDescriptionValue;
            if(this.accessibleStateValue != "")
            {
               accessibilityProperties.description += " (" + this.accessibleStateValue + ")";
            }
            this.updateAccessibilityProperties();
         }
      }
      
      public function get tooltipText() : String
      {
         return this.tooltipTextValue;
      }
      
      protected function onStageMouseLeave(param1:Event) : void
      {
         if(this.mouseOffStage)
         {
            this.onStageMouseUp(new MouseEvent(MouseEvent.MOUSE_UP,false,false));
         }
      }
      
      public function getState() : IUIState
      {
         return this.stateValue;
      }
      
      protected function releaseMouse() : void
      {
         this.stageAmbassador.removeEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove);
         this.stageAmbassador.removeEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave);
         if(root)
         {
            root.removeEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove);
         }
      }
      
      protected function drawGradientBackground(param1:Array = null) : void
      {
         drawing(this.background.graphics).clear().fill(param1 || Theme.getConstant("POPUP_MENU_COLOR"),param1 ? 1 : Theme.getConstant("POPUP_MENU_ALPHA")).rect(0,0,int(this.nominalWidth),int(this.nominalHeight)).end();
      }
      
      protected function onStageMouseOut(param1:MouseEvent) : void
      {
         this.mouseOffStage = true;
      }
      
      public function onClick(param1:MouseEvent) : void
      {
      }
      
      public function onRollOver(param1:MouseEvent) : void
      {
         this.releaseMouse();
         this.setState(this.stateValue.onRollOver());
      }
      
      protected function onRemovedFromStage(param1:Event) : void
      {
         if(Boolean(this.stageAmbassador.focus) && (this.stageAmbassador.focus == this || contains(this.stageAmbassador.focus)))
         {
            this.stageAmbassador.focus = null;
         }
         this.stageAmbassador.removeEventListener(MouseEvent.MOUSE_OVER,this.onStageMouseOver);
         this.stageAmbassador.removeEventListener(MouseEvent.MOUSE_OUT,this.onStageMouseOut);
         this.stageAmbassador.removeEventListener(MouseEvent.MOUSE_UP,this.onStageMouseUp);
         root.removeEventListener(MouseEvent.MOUSE_UP,this.onStageMouseUp);
         dispatchEvent(new Event(Event.TAB_ENABLED_CHANGE,true));
         this.hideTooltip();
      }
      
      public function set accessibleState(param1:String) : void
      {
         if(!accessibilityProperties)
         {
            accessibilityProperties = new AccessibilityProperties();
         }
         if(this.accessibleStateValue != param1)
         {
            this.accessibleStateValue = param1;
            accessibilityProperties.description = this.accessibleDescriptionValue;
            if(this.accessibleStateValue != "")
            {
               accessibilityProperties.description += " (" + this.accessibleStateValue + ")";
            }
            this.updateAccessibilityProperties();
         }
      }
      
      protected function redraw() : void
      {
         this.drawBackground();
         this.drawForeground();
      }
      
      public function set tabOrderPriority(param1:int) : void
      {
         this.layoutOrderPriority = param1;
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         if(contains(param1))
         {
            removeChild(param1);
         }
         return super.addChildAt(param1,getChildIndex(this.foreground));
      }
      
      protected function captureMouse() : void
      {
         this.stageAmbassador.addEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove);
         this.stageAmbassador.addEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave);
         if(root)
         {
            root.addEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove);
         }
      }
   }
}

