package com.google.youtube.model
{
   import flash.events.EventDispatcher;
   
   public class Experiments extends EventDispatcher
   {
      
      public static const SRC_YT:String = "yt";
      
      protected var experimentState:Object = {};
      
      public function Experiments()
      {
         super();
      }
      
      public function isExperimentActive(param1:String) : Boolean
      {
         var _loc2_:String = null;
         for(_loc2_ in this.experimentState)
         {
            if(this.experimentState[_loc2_][param1])
            {
               return true;
            }
         }
         return false;
      }
      
      public function importExperimentIdsFromSrc(param1:String, param2:String = "yt") : void
      {
         var _loc3_:Array = param1.split(",");
         var _loc4_:Number = _loc3_.length;
         if(this.experimentState[param2] == null)
         {
            this.experimentState[param2] = {};
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            this.experimentState[param2][_loc3_[_loc5_]] = true;
            _loc5_++;
         }
      }
      
      public function exportExperimentIds() : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc1_:String = "";
         for(_loc2_ in this.experimentState)
         {
            for(_loc3_ in this.experimentState[_loc2_])
            {
               _loc1_ += "," + _loc3_;
            }
         }
         if(_loc1_ == "")
         {
            return null;
         }
         return _loc1_.slice(1);
      }
   }
}

