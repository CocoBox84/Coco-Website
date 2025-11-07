package com.google.youtube.model
{
   import flash.events.Event;
   
   public class QualityChangeEvent extends Event
   {
      
      public static var CHANGE:String;
      
      public static var SETTINGS_CHANGE:String;
      
      public var quality:VideoQuality;
      
      public function QualityChangeEvent(param1:String, param2:VideoQuality = null, param3:Boolean = false)
      {
         this.quality = param2;
         super(param1,param3,false);
      }
      
      override public function clone() : Event
      {
         return new QualityChangeEvent(type,this.quality,bubbles);
      }
   }
}

import com.google.youtube.event.registerEvents;

registerEvents(QualityChangeEvent);

