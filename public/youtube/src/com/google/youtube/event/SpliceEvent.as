package com.google.youtube.event
{
   public class SpliceEvent extends VideoEvent
   {
      
      public static var COMPLETE:String;
      
      public static var START:String;
      
      public var oldFormat:String;
      
      public var format:String;
      
      public function SpliceEvent(param1:String, param2:String = null, param3:String = null, param4:Object = null, param5:Boolean = false)
      {
         super(param1,param4,param5);
         this.oldFormat = param2;
         this.format = param3;
      }
   }
}

registerEvents(SpliceEvent);

