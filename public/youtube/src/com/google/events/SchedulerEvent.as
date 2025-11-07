package com.google.events
{
   import flash.events.Event;
   
   public class SchedulerEvent extends Event
   {
      
      public static const TICK:String = "TICK";
      
      public static const END:String = "END";
      
      public var elapsed:Number;
      
      public function SchedulerEvent(param1:String, param2:Number)
      {
         this.elapsed = param2;
         super(param1,false,false);
      }
      
      override public function clone() : Event
      {
         return new SchedulerEvent(type,this.elapsed);
      }
   }
}

