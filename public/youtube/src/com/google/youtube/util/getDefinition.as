package com.google.youtube.util
{
   import flash.system.ApplicationDomain;
   
   public function getDefinition(param1:String, param2:Object = null) : *
   {
      return hasDefinition(param1) ? ApplicationDomain.currentDomain.getDefinition(param1) : param2;
   }
}

