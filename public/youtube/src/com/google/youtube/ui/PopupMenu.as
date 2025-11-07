package com.google.youtube.ui
{
   import com.google.youtube.util.Layout;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class PopupMenu extends UIElement
   {
      
      public var container:Sprite = new Sprite();
      
      protected var layout:Layout;
      
      protected var border:Boolean;
      
      protected var highlight:Highlight = new Highlight();
      
      public function PopupMenu(param1:Boolean = false)
      {
         super();
         this.layout = new Layout(this.container,Layout.FLOW_DOWN);
         useHandCursor = false;
         this.border = param1;
         addChild(this.highlight);
         addChild(this.container);
      }
      
      public function add(... rest) : void
      {
         var _loc2_:DisplayObject = null;
         this.layout.add.apply(this.layout,rest);
         for each(_loc2_ in rest)
         {
            if(_loc2_ is UIElement)
            {
               UIElement(_loc2_).classOrderPriority = classOrderPriority + UIElementOrder.CHILD_ORDER_OFFSET;
            }
            _loc2_.addEventListener(Event.RESIZE,this.onElementResize);
            _loc2_.addEventListener(MouseEvent.ROLL_OVER,this.onElementRollOver);
            _loc2_.addEventListener(MouseEvent.ROLL_OUT,this.onElementRollOut);
         }
         setSize(this.container.width,this.container.height);
      }
      
      protected function onElementRollOut(param1:MouseEvent) : void
      {
         this.highlight.visible = false;
      }
      
      public function remove(... rest) : void
      {
         var _loc2_:DisplayObject = null;
         this.layout.remove.apply(this.layout,rest);
         for each(_loc2_ in rest)
         {
            _loc2_.removeEventListener(Event.RESIZE,this.onElementResize);
            _loc2_.removeEventListener(MouseEvent.ROLL_OVER,this.onElementRollOver);
            _loc2_.removeEventListener(MouseEvent.ROLL_OUT,this.onElementRollOut);
         }
         setSize(this.container.width,this.container.height);
      }
      
      public function order(... rest) : void
      {
         this.layout.order.apply(this.layout,rest);
      }
      
      protected function onElementResize(param1:Event) : void
      {
         this.layout.realign();
         setSize(this.container.width,this.container.height);
      }
      
      override protected function drawBackground() : void
      {
         if(this.border)
         {
            drawGradientBackground();
            return;
         }
         var _loc1_:Number = Theme.getConstant("POPUP_MENU_BORDER");
         drawing(background.graphics).clear().fill(Theme.getConstant("POPUP_MENU_COLOR"),Theme.getConstant("POPUP_MENU_ALPHA")).roundRect(0,0,nominalWidth,nominalHeight,Theme.getConstant("POPUP_MENU_RADIUS")).fill(0,0).rect(-_loc1_,-_loc1_,nominalWidth + _loc1_ * 2,nominalHeight + _loc1_ * 2).end();
      }
      
      protected function onElementRollOver(param1:MouseEvent) : void
      {
         if(!(param1.target is MenuItem) || !param1.target.enabled)
         {
            return;
         }
         var _loc2_:Rectangle = param1.target.getBounds(background);
         this.highlight.x = _loc2_.x;
         this.highlight.width = _loc2_.width;
         this.highlight.y = _loc2_.y;
         this.highlight.height = _loc2_.height;
         this.highlight.visible = true;
      }
      
      override protected function redraw() : void
      {
         super.redraw();
         this.layout.realign();
         dispatchEvent(new Event(Event.RESIZE));
      }
   }
}

