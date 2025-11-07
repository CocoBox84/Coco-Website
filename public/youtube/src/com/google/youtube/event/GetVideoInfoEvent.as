package com.google.youtube.event
{
   import flash.events.Event;
   import flash.net.URLVariables;
   
   public class GetVideoInfoEvent extends Event
   {
      
      public static var INFO:String;
      
      public var data:URLVariables;
      
      public function GetVideoInfoEvent(param1:String, param2:URLVariables = null)
      {
         this.data = param2;
         super(param1,false,false);
      }
      
      override public function clone() : Event
      {
         return new GetVideoInfoEvent(type,this.data);
      }
   }
}

registerEvents(GetVideoInfoEvent);

