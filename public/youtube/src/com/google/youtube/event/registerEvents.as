package com.google.youtube.event
{
   import flash.utils.describeType;
   
   public function registerEvents(param1:Class) : void
   {
      var variable:* = undefined;
      var eventClass:Class = param1;
      var type:XML = describeType(eventClass);
      for each(variable in type..variable.(@type == "String"))
      {
         eventClass[variable.@name] = type.@name + "." + variable.@name;
      }
   }
}

