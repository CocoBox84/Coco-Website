package com.google.youtube.event
{
   import flash.events.Event;
   import flash.geom.Rectangle;
   
   public class ResizeEvent extends Event
   {
      
      public static var DISPLAY:String;
      
      public static var VIEWPORT:String;
      
      public var rect:Rectangle;
      
      public var unmodifiedRect:Rectangle;
      
      public function ResizeEvent(param1:String, param2:Rectangle, param3:Rectangle = null)
      {
         this.rect = param2.clone();
         this.unmodifiedRect = (param3 || param2).clone();
         super(param1,false,false);
      }
      
      override public function clone() : Event
      {
         return new ResizeEvent(type,this.rect,this.unmodifiedRect);
      }
   }
}

registerEvents(ResizeEvent);

