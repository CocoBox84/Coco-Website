package com.google.ui
{
   import com.google.testing.unittest;
   import flash.text.TextField;
   
   use namespace unittest;
   
   public class TextFieldFactory
   {
      
      private static var textFieldClass:Class = TextField;
      
      public function TextFieldFactory()
      {
         super();
      }
      
      public static function createTextField() : TextField
      {
         return new textFieldClass();
      }
      
      unittest static function setTextFieldClass(param1:Class) : void
      {
         textFieldClass = param1;
      }
   }
}

