package com.google.youtube.event
{
   import flash.events.Event;
   
   public class VolumeEvent extends Event
   {
      
      public static var CHANGE:String;
      
      public static var MUTE:String;
      
      public static var UNMUTE:String;
      
      public var volume:Number;
      
      public function VolumeEvent(param1:String, param2:Number = NaN, param3:Boolean = false)
      {
         this.volume = param2;
         super(param1,param3,false);
      }
      
      override public function clone() : Event
      {
         return new VolumeEvent(type,this.volume);
      }
   }
}

registerEvents(VolumeEvent);

