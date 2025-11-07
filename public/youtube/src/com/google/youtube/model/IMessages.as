package com.google.youtube.model
{
   import flash.events.IEventDispatcher;
   
   public interface IMessages extends IEventDispatcher
   {
      
      function getMessage(param1:String, param2:Object = null) : String;
      
      function load(param1:String, param2:String = null) : void;
   }
}

