package com.google.youtube.ui
{
   import flash.display.DisplayObject;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class MenuItem extends Button implements IMenuItem
   {
      
      public static const PADDING:int = 6;
      
      public static var Bullet:Class = BulletDecorator;
      
      public static var Check:Class = CheckDecorator;
      
      protected var bullet:DisplayObject;
      
      protected var align:String;
      
      protected var lockBullet:Boolean;
      
      protected var selectedValue:Boolean;
      
      protected var paddingValue:int = 6;
      
      protected var selectedBackground:DisplayObject;
      
      public function MenuItem(param1:*, param2:* = null, param3:String = "left", param4:Boolean = true)
      {
         super();
         nominalHeight = nominalHeight || 22;
         this.align = param3;
         this.bullet = param2 is Class ? new param2() : param2;
         labels = {"default":param1};
         labelValue = "default";
         horizontalStretch = 1;
         this.lockBullet = param4;
         this.selectedBackground = new PopupMenuSelectedBackground();
         addChildAt(this.selectedBackground,getChildIndex(background));
         this.selectedBackground.visible = false;
      }
      
      override protected function getStateKey(param1:Object) : String
      {
         return param1 && this.selected && "selected" in param1 ? "selected" : super.getStateKey(param1);
      }
      
      public function get padding() : Number
      {
         return this.paddingValue;
      }
      
      override protected function drawBackground() : void
      {
         Drawing.invisibleRect(background.graphics,0,0,Math.max(nominalWidth,elementContainer.x + elementContainer.width + this.paddingValue),nominalHeight);
      }
      
      public function get selected() : Boolean
      {
         return this.selectedValue;
      }
      
      public function get showBullet() : Boolean
      {
         return Boolean(this.bullet) && contains(this.bullet);
      }
      
      public function set padding(param1:Number) : void
      {
         this.paddingValue = param1;
         redraw();
      }
      
      override protected function drawForeground() : void
      {
      }
      
      override protected function transformText(param1:String, param2:DisplayObject) : String
      {
         var _loc3_:TextField = TextField(param2);
         if(this.align == TextFormatAlign.LEFT)
         {
            _loc3_.autoSize = TextFieldAutoSize.LEFT;
         }
         var _loc4_:TextFormat = Theme.newTextFormat();
         _loc4_.align = this.align;
         _loc4_.color = forState(Theme.getConstant("MENU_TEXT_COLORS"));
         _loc3_.defaultTextFormat = _loc4_;
         _loc3_.text = param1;
         return param1;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this.selectedValue = param1;
         this.selectedBackground.visible = param1;
         if(this.lockBullet && this.bullet && param1)
         {
            addChild(this.bullet);
         }
         else if(this.lockBullet && this.bullet && contains(this.bullet))
         {
            removeChild(this.bullet);
         }
         if(this.bullet)
         {
            this.bullet.alpha = param1 ? 1 : 0.5;
         }
         redraw();
      }
      
      public function set showBullet(param1:Boolean) : void
      {
         if(!this.lockBullet && this.bullet && param1)
         {
            addChild(this.bullet);
         }
         else if(!this.lockBullet && this.bullet && contains(this.bullet))
         {
            removeChild(this.bullet);
         }
         redraw();
      }
      
      override protected function alignContents() : void
      {
         var _loc2_:DisplayObject = null;
         if(this.bullet)
         {
            this.bullet.x = 4 + this.paddingValue;
            this.bullet.y = Math.round((nominalHeight - this.bullet.height) / 2);
         }
         elementContainer.y = this.lockBullet ? 0 : -2;
         elementContainer.x = this.bullet ? this.bullet.x + 10 : this.paddingValue;
         if(this.align == TextFormatAlign.RIGHT)
         {
            elementContainer.x = Math.max(elementContainer.x,nominalWidth - elementContainer.width - this.paddingValue);
         }
         var _loc1_:int = 0;
         while(_loc1_ < elementContainer.numChildren)
         {
            _loc2_ = elementContainer.getChildAt(_loc1_);
            _loc2_.y = Math.round((nominalHeight - _loc2_.height) / 2);
            _loc1_++;
         }
         this.selectedBackground.y = 2;
         this.selectedBackground.x = 4;
         this.selectedBackground.width = nominalWidth - 8;
         this.selectedBackground.height = nominalHeight - 4;
      }
   }
}

