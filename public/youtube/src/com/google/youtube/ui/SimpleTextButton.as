package com.google.youtube.ui
{
   import flash.display.DisplayObject;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class SimpleTextButton extends Button
   {
      
      public static const PADDING:int = 0;
      
      protected var paddingValue:int = 0;
      
      protected var textFiltersValue:Array;
      
      protected var textFormatValue:TextFormat;
      
      protected var isHyperlink:Boolean = false;
      
      public function SimpleTextButton(param1:String, param2:TextFormat = null, param3:Array = null, param4:Boolean = false)
      {
         this.textFormatValue = param2 || Theme.newTextFormat();
         this.isHyperlink = param4;
         if(param4)
         {
            this.textFormatValue.underline = true;
         }
         this.textFiltersValue = param3;
         super(param1);
      }
      
      public function set padding(param1:Number) : void
      {
         this.paddingValue = param1;
         redraw();
      }
      
      public function get padding() : Number
      {
         return this.paddingValue;
      }
      
      override protected function transformText(param1:String, param2:DisplayObject) : String
      {
         var _loc3_:TextField = TextField(param2);
         if(this.isHyperlink)
         {
            this.textFormatValue.color = forState(Theme.getConstant("MENU_TEXT_COLORS"));
         }
         _loc3_.defaultTextFormat = this.textFormatValue;
         _loc3_.filters = this.textFiltersValue;
         _loc3_.text = param1;
         return param1;
      }
      
      override protected function alignContents() : void
      {
         nominalWidth = elementContainer.width + this.paddingValue * 2;
         super.alignContents();
      }
   }
}

