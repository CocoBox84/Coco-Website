package com.google.youtube.ui
{
   import flash.text.TextFormat;
   
   public class TextButton extends SimpleTextButton
   {
      
      public function TextButton(param1:String, param2:TextFormat = null, param3:Array = null)
      {
         super(param1,param2,param3);
      }
      
      override protected function drawBackground() : void
      {
         var _loc1_:Object = Theme.getConstant("BUTTON_GRADIENT_COLORS");
         drawGradientBackground(forState(_loc1_));
      }
   }
}

