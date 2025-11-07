package com.google.youtube.ui
{
   import com.google.youtube.util.Layout;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class Dialog extends UIElement
   {
      
      protected static const PADDING:int = 10;
      
      protected var container:Sprite = new Sprite();
      
      protected var layout:Layout;
      
      protected var footer:LayoutStrip;
      
      public function Dialog()
      {
         super();
         this.container.x = PADDING;
         this.container.y = PADDING;
         addChild(this.container);
         this.footer = new LayoutStrip(["left"],["right"]);
         this.layout = new Layout(this.container,Layout.FLOW_DOWN);
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         this.layout.realign();
         super.setSize(this.container.width + 2 * PADDING,this.container.getChildAt(this.container.numChildren - 1).y + this.container.getChildAt(this.container.numChildren - 1).height + 2 * PADDING);
      }
      
      override protected function drawBackground() : void
      {
         drawGradientBackground();
      }
      
      protected function clickHandler(param1:String) : Function
      {
         var eventName:String = param1;
         return function(param1:Event):void
         {
            dispatchEvent(new Event(eventName));
         };
      }
   }
}

