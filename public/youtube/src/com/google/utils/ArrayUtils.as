package com.google.utils
{
   import flash.utils.Dictionary;
   
   public class ArrayUtils
   {
      
      public function ArrayUtils()
      {
         super();
      }
      
      public static function shuffle(param1:Array) : Array
      {
         var _loc4_:Number = NaN;
         var _loc5_:Object = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:int = int(param1.length);
         var _loc3_:Array = param1.slice();
         var _loc6_:int = 0;
         while(_loc6_ < _loc2_)
         {
            _loc5_ = _loc3_[_loc6_];
            _loc4_ = Math.floor(Math.random() * _loc2_);
            _loc3_[_loc6_] = _loc3_[_loc4_];
            _loc3_[_loc4_] = _loc5_;
            _loc6_++;
         }
         return _loc3_;
      }
      
      public static function unique(param1:Array) : Array
      {
         var _loc5_:Object = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:Dictionary = new Dictionary();
         var _loc3_:Array = new Array();
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1[_loc4_];
            if(!_loc2_[_loc5_])
            {
               _loc3_.push(_loc5_);
               _loc2_[_loc5_] = true;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function isEmpty(param1:Array) : Boolean
      {
         return param1 == null || param1.length == 0;
      }
      
      public static function remove(param1:Array, param2:Array) : Array
      {
         var filterFunction:Function;
         var source:Array = param1;
         var toRemove:Array = param2;
         if(isEmpty(source))
         {
            return [];
         }
         if(isEmpty(toRemove))
         {
            return source.concat();
         }
         filterFunction = function(param1:Object, param2:int, param3:Array):Boolean
         {
            return toRemove.indexOf(param1) == -1;
         };
         return source.filter(filterFunction);
      }
      
      public static function search(param1:Object, param2:Array, param3:Function) : int
      {
         var _loc4_:* = 0;
         var _loc7_:int = 0;
         if(!param2)
         {
            return -1;
         }
         var _loc5_:int = -1;
         var _loc6_:int = int(param2.length);
         while(_loc5_ < _loc6_ - 1)
         {
            _loc4_ = _loc5_ + _loc6_ >> 1;
            _loc7_ = param3(param1,param2[_loc4_]);
            if(_loc7_ == 0)
            {
               return _loc4_;
            }
            if(_loc7_ < 0)
            {
               _loc6_ = _loc4_;
            }
            else
            {
               _loc5_ = _loc4_;
            }
         }
         return _loc5_;
      }
      
      public static function getItemIndex(param1:Object, param2:Array) : int
      {
         if(!param2)
         {
            return -1;
         }
         var _loc3_:int = int(param2.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(param2[_loc4_] == param1)
            {
               return _loc4_;
            }
            _loc4_++;
         }
         return -1;
      }
      
      public static function sparseSlice(param1:Array, param2:int, param3:int = 2147483647) : Array
      {
         var _loc5_:* = undefined;
         var _loc4_:Array = [];
         if(param2 < 0)
         {
            param2 = param1.length + param2;
         }
         if(param3 < 0)
         {
            param3 = param1.length + param3;
         }
         for(_loc5_ in param1)
         {
            if(_loc5_ >= param2 && _loc5_ < param3)
            {
               _loc4_[_loc5_] = param1[_loc5_];
            }
         }
         return _loc4_;
      }
      
      public static function filterByValues(param1:Array, param2:String, param3:Array) : Array
      {
         var items:Array = param1;
         var itemProperty:String = param2;
         var propertyValues:Array = param3;
         var filterFunction:Function = function(param1:Object, param2:int, param3:Array):Boolean
         {
            var _loc4_:String = null;
            for each(_loc4_ in propertyValues)
            {
               if(param1 != null && param1[itemProperty] == _loc4_)
               {
                  return true;
               }
            }
            return false;
         };
         return items != null ? items.filter(filterFunction) : null;
      }
      
      public static function equals(param1:Array, param2:Array) : Boolean
      {
         if(param1 === param2)
         {
            return true;
         }
         if(param1 == null && param2 == null)
         {
            return true;
         }
         if(param1 == null || param2 == null || param1.length != param2.length)
         {
            return false;
         }
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] != param2[_loc3_])
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
   }
}

