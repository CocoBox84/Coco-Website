package com.google.youtube.model
{
   import com.google.utils.RequestVariables;
   import com.google.youtube.event.ExternalEvent;
   import flash.events.EventDispatcher;
   
   public class Environment extends EventDispatcher
   {
      
      private var contextValue:Object = {};
      
      protected var rawParametersValue:Object = {};
      
      public function Environment(param1:Object)
      {
         super();
         this.context = param1;
      }
      
      public function handleError(param1:Error, param2:RequestVariables = null) : void
      {
         trace(param1.getStackTrace());
      }
      
      public function get context() : Object
      {
         return this.contextValue;
      }
      
      public function get rawParameters() : Object
      {
         return this.rawParametersValue;
      }
      
      public function broadcastExternal(param1:ExternalEvent) : void
      {
      }
      
      public function getLoggingOptions() : Object
      {
         return {};
      }
      
      public function addCallback(param1:String, param2:Function) : void
      {
      }
      
      public function set context(param1:Object) : void
      {
         if(Boolean(param1) && Boolean(param1.parameters))
         {
            this.contextValue = param1;
         }
      }
   }
}

