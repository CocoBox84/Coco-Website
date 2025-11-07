package com.google.youtube.event
{
   import flash.events.Event;
   
   public class AddCallbackEvent extends Event
   {
      
      public static const ADD_CALLBACK:String = "ADD_CALLBACK";
      
      public var closure:Function;
      
      public var functionName:String;
      
      public function AddCallbackEvent(param1:String, param2:String, param3:Function)
      {
         this.functionName = param2;
         this.closure = param3;
         super(param1,false,false);
      }
   }
}

