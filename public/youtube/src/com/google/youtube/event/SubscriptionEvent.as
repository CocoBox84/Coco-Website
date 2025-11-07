package com.google.youtube.event
{
   import flash.events.Event;
   
   public class SubscriptionEvent extends Event
   {
      
      public static var SUBSCRIBED:String;
      
      public static var ERROR:String;
      
      public static var UNSUBSCRIBE:String;
      
      public static var OPEN_LOGIN_DIALOG:String;
      
      public static var SUBSCRIBE_TO_CHANNEL:String;
      
      public static var UNSUBSCRIBED:String;
      
      public var token:String;
      
      public var id:String;
      
      public function SubscriptionEvent(param1:String, param2:String = null, param3:String = null)
      {
         this.token = param2;
         this.id = param3;
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new SubscriptionEvent(type,this.token,this.id);
      }
   }
}

registerEvents(SubscriptionEvent);

