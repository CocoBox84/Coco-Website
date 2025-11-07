package com.google.youtube.util
{
   public class SignatureDecipher
   {
      
      public static var TIMESTAMP:Number = 135854561051;
      
      public function SignatureDecipher()
      {
         super();
      }
      
      private static function clone_135854561051(param1:Array, param2:Number) : Array
      {
         return param1.slice(param2);
      }
      
      private static function swap_135854561051(param1:Array, param2:Number) : Array
      {
         var _loc3_:String = param1[0];
         var _loc4_:String = param1[param2 % param1.length];
         param1[0] = _loc4_;
         param1[param2] = _loc3_;
         return param1;
      }
      
      public static function decipher(param1:String) : String
      {
         var _loc2_:Array = param1.split("");
         _loc2_ = clone_135854561051(_loc2_,2);
         _loc2_ = swap_135854561051(_loc2_,15);
         _loc2_ = clone_135854561051(_loc2_,1);
         _loc2_ = reverse_135854561051(_loc2_);
         _loc2_ = swap_135854561051(_loc2_,60);
         _loc2_ = clone_135854561051(_loc2_,3);
         _loc2_ = swap_135854561051(_loc2_,42);
         return _loc2_.join("");
      }
      
      private static function reverse_135854561051(param1:Array) : Array
      {
         param1.reverse();
         return param1;
      }
   }
}

