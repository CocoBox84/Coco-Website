package com.google.ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   
   public class ResourceButton extends Sprite
   {
      
      public static const CLICK_PADDING:int = 5;
      
      public static const UP_STATE_ALPHA:Number = 0.5;
      
      protected var nominalWidth:uint;
      
      protected var overlay:Sprite;
      
      protected var nominalHeight:uint;
      
      protected var buttonOver:DisplayObject;
      
      protected var paddingValue:uint;
      
      protected var buttonUp:DisplayObject;
      
      protected var button:Sprite;
      
      public function ResourceButton()
      {
         super();
         useHandCursor = true;
         buttonMode = true;
         this.build();
         this.addListeners();
      }
      
      public static function newDropShadow() : DropShadowFilter
      {
         return new DropShadowFilter(1,45,0,0.75,1,1,1,3,false,false,false);
      }
      
      protected function onMouseUp(param1:MouseEvent) : void
      {
         this.showOver();
      }
      
      public function setSize(param1:uint, param2:uint) : void
      {
         this.nominalWidth = param1;
         this.nominalHeight = param2;
         this.button.x = this.button.y = this.paddingValue;
         this.button.width = param1 - 2 * this.paddingValue;
         this.button.height = param2 - 2 * this.paddingValue;
         this.overlay.width = param1;
         this.overlay.height = param2;
      }
      
      protected function onMouseDown(param1:MouseEvent) : void
      {
         this.showUp();
      }
      
      protected function getOverClass() : DisplayObject
      {
         return null;
      }
      
      public function get padding() : uint
      {
         return this.paddingValue;
      }
      
      protected function addListeners() : void
      {
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
      }
      
      public function set padding(param1:uint) : void
      {
         this.paddingValue = param1;
         this.setSize(this.nominalWidth,this.nominalHeight);
      }
      
      protected function getUpClass() : DisplayObject
      {
         return null;
      }
      
      protected function onRollOver(param1:MouseEvent) : void
      {
         this.button.alpha = 1;
         this.showOver();
      }
      
      protected function showOver() : void
      {
         this.button.removeChildAt(0);
         this.button.addChild(this.buttonOver);
      }
      
      protected function build() : void
      {
         this.paddingValue = CLICK_PADDING;
         this.button = new Sprite();
         this.buttonOver = this.getOverClass();
         this.buttonOver.cacheAsBitmap = true;
         this.buttonUp = this.getUpClass();
         this.buttonUp.cacheAsBitmap = true;
         this.button.addChild(this.buttonUp);
         this.button.alpha = UP_STATE_ALPHA;
         addChild(this.button);
         this.overlay = new Sprite();
         this.overlay.graphics.beginFill(0,0);
         this.overlay.graphics.drawRect(0,0,1,1);
         this.overlay.graphics.endFill();
         addChild(this.overlay);
      }
      
      protected function showUp() : void
      {
         this.button.removeChildAt(0);
         this.button.addChild(this.buttonUp);
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         this.button.alpha = UP_STATE_ALPHA;
         this.showUp();
      }
      
      public function destroy() : void
      {
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
      }
   }
}

