package com.google.youtube.ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class SeekBarSharkToothMarker extends SeekBarMarker
   {
      
      private var flipped:Boolean;
      
      public function SeekBarSharkToothMarker(param1:Number, param2:Number, param3:String = null, param4:Boolean = false)
      {
         super(param1,param2,Theme.getConstant("SHARK_TOOTH_COLOR"),param3);
         allowScale = true;
         this.flipped = param4;
      }
      
      override public function createShape(param1:Number, param2:Number) : DisplayObject
      {
         var _loc3_:Sprite = new Sprite();
         var _loc4_:Sprite = Theme.newMaskedIcon(gradientColor,this.flipped ? new SharkToothNotchFlipped() : new SharkToothNotch());
         _loc4_.y = (param2 - _loc4_.height) / 2;
         _loc3_.addChild(_loc4_);
         return _loc3_;
      }
      
      override public function createMagnifiedShape(param1:Number, param2:Number) : DisplayObject
      {
         var _loc3_:Sprite = new Sprite();
         var _loc4_:Sprite = Theme.newMaskedIcon(gradientColor,this.flipped ? new SharkToothNotchFlipped() : new SharkToothNotch());
         _loc4_.height = param2;
         _loc4_.scaleX = _loc4_.scaleY;
         _loc3_.addChild(_loc4_);
         return _loc3_;
      }
   }
}

