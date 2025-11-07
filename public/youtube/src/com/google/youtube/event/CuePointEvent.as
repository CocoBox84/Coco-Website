package com.google.youtube.event
{
   import flash.events.Event;
   
   public class CuePointEvent extends Event
   {
      
      public static var CUE_POINT:String;
      
      public var parameters:Object;
      
      public var name:String;
      
      public var time:Number;
      
      public function CuePointEvent(param1:String, param2:String, param3:Number, param4:Object, param5:Boolean = false)
      {
         this.name = param2;
         this.time = param3;
         this.parameters = param4;
         super(param1,param5,false);
      }
      
      override public function clone() : Event
      {
         return new CuePointEvent(type,this.name,this.time,this.parameters,bubbles);
      }
   }
}

registerEvents(CuePointEvent);

