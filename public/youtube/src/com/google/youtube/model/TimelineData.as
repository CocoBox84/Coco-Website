package com.google.youtube.model
{
   import com.google.youtube.event.TimelineDataEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class TimelineData extends EventDispatcher
   {
      
      protected var dataValue:Array = [];
      
      protected var sorted:Boolean;
      
      public function TimelineData()
      {
         super();
      }
      
      public function add(param1:uint, param2:String, param3:Array) : void
      {
         var _loc4_:Boolean = !this.dataValue.length || param1 >= this.dataValue[this.dataValue.length - 1].time;
         var _loc5_:TimelineDataEvent = _loc4_ ? new TimelineDataEvent(Event.ADDED,param1,param2,param3) : new TimelineDataEvent(Event.CHANGE,param1,param2,param3);
         this.sorted = this.sorted && _loc4_;
         this.dataValue.push(_loc5_);
         dispatchEvent(_loc5_);
      }
      
      public function get data() : Array
      {
         if(!this.sorted)
         {
            this.dataValue.sortOn("time",Array.NUMERIC);
            this.sorted = true;
         }
         return this.dataValue.concat();
      }
   }
}

