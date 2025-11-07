package com.google.youtube.ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class LayoutElement extends Sprite implements ILayoutElement
   {
      
      protected var verticalStretchValue:Number;
      
      protected var verticalMarginValue:Number = 0;
      
      protected var horizontalMarginValue:Number = 0;
      
      protected var horizontalStretchValue:Number;
      
      protected var childValue:DisplayObject;
      
      protected var verticalRegistrationValue:Number;
      
      protected var horizontalRegistrationValue:Number;
      
      public function LayoutElement(param1:DisplayObject = null)
      {
         super();
         this.child = param1;
      }
      
      public function get horizontalMargin() : Number
      {
         return this.horizontalMarginValue;
      }
      
      public function set verticalMargin(param1:Number) : void
      {
         this.verticalMarginValue = param1;
      }
      
      public function set horizontalStretch(param1:Number) : void
      {
         this.horizontalStretchValue = param1;
      }
      
      public function set horizontalRegistration(param1:Number) : void
      {
         this.horizontalRegistrationValue = param1;
      }
      
      override public function set width(param1:Number) : void
      {
         if(this.childValue)
         {
            this.childValue.width = param1;
         }
         else
         {
            super.width = param1;
         }
      }
      
      public function get horizontalRegistration() : Number
      {
         return this.horizontalRegistrationValue;
      }
      
      public function get child() : DisplayObject
      {
         return this.childValue;
      }
      
      public function set verticalRegistration(param1:Number) : void
      {
         this.verticalRegistrationValue = param1;
      }
      
      public function get verticalStretch() : Number
      {
         return this.verticalStretchValue;
      }
      
      public function set child(param1:DisplayObject) : void
      {
         if(Boolean(this.childValue) && contains(this.childValue))
         {
            removeChild(this.childValue);
         }
         this.childValue = param1;
         if(this.childValue)
         {
            addChild(this.childValue);
         }
      }
      
      public function get horizontalStretch() : Number
      {
         return this.horizontalStretchValue;
      }
      
      public function get verticalMargin() : Number
      {
         return this.verticalMarginValue;
      }
      
      public function get verticalRegistration() : Number
      {
         return this.verticalRegistrationValue;
      }
      
      override public function set height(param1:Number) : void
      {
         if(this.childValue)
         {
            this.childValue.height = param1;
         }
         else
         {
            super.height = param1;
         }
      }
      
      public function set verticalStretch(param1:Number) : void
      {
         this.verticalStretchValue = param1;
      }
      
      public function set horizontalMargin(param1:Number) : void
      {
         this.horizontalMarginValue = param1;
      }
   }
}

