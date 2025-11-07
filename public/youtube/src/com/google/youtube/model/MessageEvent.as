package com.google.youtube.model
{
   import flash.events.Event;
   
   public class MessageEvent extends Event
   {
      
      public static var UPDATE:String;
      
      public var messages:IMessages;
      
      public function MessageEvent(param1:String, param2:IMessages)
      {
         this.messages = param2;
         super(param1,false,false);
      }
   }
}

import com.google.youtube.event.registerEvents;

registerEvents(MessageEvent);

