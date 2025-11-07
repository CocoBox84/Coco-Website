package com.google.youtube.players
{
   import flash.events.IEventDispatcher;
   
   public interface IVideoAdEventProvider extends IEventDispatcher
   {
      
      function getVideoId() : String;
      
      function isAdPlayControllable() : Boolean;
      
      function getAdTimes() : Array;
      
      function onAdClose() : void;
      
      function getAdTime() : Number;
      
      function getAdDisplayString() : String;
      
      function getHasAdUI() : Boolean;
      
      function getAdDuration() : Number;
   }
}

