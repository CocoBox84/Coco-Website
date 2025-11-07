package com.google.youtube.util.dash
{
   public class MpdUtils
   {
      
      protected static const TIME_MATCH:RegExp = /PT(([0-9]+)H)?(([0-9]+)M)?([0-9]*\.?[0-9]+)S/;
      
      public function MpdUtils()
      {
         super();
      }
      
      public static function parseDuration(param1:String) : Number
      {
         var _loc2_:Array = TIME_MATCH.exec(param1);
         if(!_loc2_)
         {
            return NaN;
         }
         var _loc3_:String = _loc2_[2];
         var _loc4_:String = _loc2_[4];
         var _loc5_:String = _loc2_[5];
         var _loc6_:Number = 0;
         if(_loc3_)
         {
            _loc6_ += 3600 * int(_loc3_);
         }
         if(_loc4_)
         {
            _loc6_ += 60 * int(_loc4_);
         }
         if(_loc5_)
         {
            _loc6_ += Number(_loc5_);
         }
         return _loc6_;
      }
   }
}

