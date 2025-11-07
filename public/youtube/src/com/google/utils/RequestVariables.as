package com.google.utils
{
   public dynamic class RequestVariables
   {
      
      protected static var EXCESSIVE_LENGTH:Number = 256;
      
      protected var hashValue:String = "";
      
      public function RequestVariables()
      {
         super();
      }
      
      public function setHash(param1:String) : void
      {
         this.hashValue = param1;
      }
      
      public function toString() : String
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:* = undefined;
         var _loc1_:String = "";
         var _loc2_:Object = {};
         for(_loc3_ in this)
         {
            _loc5_ = this[_loc3_];
            if(_loc5_ == null || _loc5_ == undefined)
            {
               _loc5_ = "";
            }
            _loc5_ = _loc5_.toString();
            if(_loc5_.length > EXCESSIVE_LENGTH)
            {
               _loc2_[_loc3_] = _loc5_;
            }
            else
            {
               _loc1_ = _loc1_.concat(_loc3_ + "=" + _loc5_ + "&");
            }
         }
         for(_loc4_ in _loc2_)
         {
            _loc1_ = _loc1_.concat(_loc4_ + "=" + _loc2_[_loc4_] + "&");
         }
         if(_loc1_)
         {
            _loc1_ = _loc1_.slice(0,_loc1_.length - 1);
         }
         if(this.hashValue)
         {
            _loc1_ += "#" + this.hashValue;
         }
         return _loc1_;
      }
   }
}

