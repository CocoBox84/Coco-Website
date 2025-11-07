package com.google.youtube.util
{
   public class BinarySearch
   {
      
      public function BinarySearch()
      {
         super();
      }
      
      protected static function binarySearch(param1:Array, param2:uint, param3:int, param4:int) : int
      {
         var _loc5_:int = 0;
         do
         {
            _loc5_ = (param3 + param4) / 2;
            if(param2 > param1[_loc5_])
            {
               param3 = _loc5_ + 1;
            }
            else
            {
               param4 = _loc5_ - 1;
            }
         }
         while(param1[_loc5_] != param2 && param3 <= param4);
         
         return _loc5_;
      }
      
      public static function greaterThanOrEqual(param1:Array, param2:uint, param3:int = 0, param4:int = -1) : int
      {
         if(param4 < 0)
         {
            param4 = int(param1.length - 1);
         }
         var _loc5_:uint = uint(binarySearch(param1,param2,param3,param4));
         if(param1[_loc5_] < param2 && _loc5_ == param4)
         {
            return -1;
         }
         return param1[_loc5_] < param2 && _loc5_ < param4 ? _loc5_ + 1 : int(_loc5_);
      }
      
      public static function lessThanOrEqual(param1:Array, param2:uint, param3:int = 0, param4:int = -1) : int
      {
         if(param4 < 0)
         {
            param4 = int(param1.length - 1);
         }
         var _loc5_:uint = uint(binarySearch(param1,param2,param3,param4));
         if(param1[_loc5_] > param2 && _loc5_ == param3)
         {
            return -1;
         }
         return param1[_loc5_] > param2 && _loc5_ > param3 ? int(_loc5_ - 1) : int(_loc5_);
      }
   }
}

