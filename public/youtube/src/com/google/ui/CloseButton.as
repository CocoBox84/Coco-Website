package com.google.ui
{
   import flash.accessibility.AccessibilityProperties;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class CloseButton extends ResourceButton
   {
      
      public static const DEFAULT_SIZE:int = 22;
      
      protected static var CloseIcon:Class = CloseButton_CloseIcon;
      
      protected static var CloseIconOver:Class = CloseButton_CloseIconOver;
      
      protected var closeText:TextField;
      
      protected const FONT_LIST:String = "Arial Unicode MS,Arial Unicode,Arial,_sans";
      
      public function CloseButton()
      {
         super();
      }
      
      override public function setSize(param1:uint, param2:uint) : void
      {
         super.setSize(param1,param2);
         this.closeText.y = Math.floor((param2 - this.closeText.height) / 2);
      }
      
      override protected function getUpClass() : DisplayObject
      {
         return new CloseIcon();
      }
      
      public function set textFormat(param1:TextFormat) : void
      {
         this.closeText.defaultTextFormat = param1;
         this.closeText.setTextFormat(param1);
      }
      
      public function get text() : String
      {
         return this.closeText.text;
      }
      
      override protected function build() : void
      {
         super.build();
         var _loc1_:TextFormat = new TextFormat();
         _loc1_.size = 11;
         _loc1_.color = 16777215;
         _loc1_.font = this.FONT_LIST;
         _loc1_.align = TextFormatAlign.RIGHT;
         this.closeText = TextFieldFactory.createTextField();
         this.closeText.defaultTextFormat = _loc1_;
         this.closeText.selectable = false;
         this.closeText.autoSize = TextFieldAutoSize.RIGHT;
         this.closeText.accessibilityProperties = new AccessibilityProperties();
         this.closeText.accessibilityProperties.silent = true;
         this.setSize(DEFAULT_SIZE,DEFAULT_SIZE);
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
         super.onRollOver(param1);
         addChild(this.closeText);
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
         super.onRollOut(param1);
         removeChild(this.closeText);
      }
      
      override protected function getOverClass() : DisplayObject
      {
         return new CloseIconOver();
      }
      
      public function set text(param1:String) : void
      {
         this.closeText.text = param1;
         this.closeText.x = Math.floor(-1 * this.closeText.width);
      }
   }
}

