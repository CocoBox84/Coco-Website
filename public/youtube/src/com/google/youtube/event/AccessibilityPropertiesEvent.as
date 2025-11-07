package com.google.youtube.event
{
   import flash.accessibility.AccessibilityProperties;
   import flash.events.Event;
   
   public class AccessibilityPropertiesEvent extends Event
   {
      
      public static var UPDATE:String;
      
      public var accessibilityProperties:AccessibilityProperties;
      
      public function AccessibilityPropertiesEvent(param1:String, param2:AccessibilityProperties = null)
      {
         super(param1,true);
         this.accessibilityProperties = param2;
      }
      
      override public function clone() : Event
      {
         return new AccessibilityPropertiesEvent(type,this.accessibilityProperties);
      }
   }
}

registerEvents(AccessibilityPropertiesEvent);

