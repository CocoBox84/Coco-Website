package com.google.youtube.util
{
   import flash.system.ApplicationDomain;
   
   public function hasDefinition(... rest) : Boolean
   {
      var _loc2_:String = null;
      for each(_loc2_ in rest)
      {
         if(!ApplicationDomain.currentDomain.hasDefinition(_loc2_))
         {
            return false;
         }
      }
      return true;
   }
}

