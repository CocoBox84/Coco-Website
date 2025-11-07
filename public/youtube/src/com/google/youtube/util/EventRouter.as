package com.google.youtube.util
{
   import flash.utils.Dictionary;
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   
   use namespace flash_proxy;
   
   public dynamic class EventRouter extends Proxy
   {
      
      private var functions:Dictionary;
      
      private var delegateValue:Object;
      
      public function EventRouter(param1:Object)
      {
         super();
         this.delegate = param1;
         this.functions = new Dictionary();
      }
      
      public function set delegate(param1:Object) : void
      {
         this.delegateValue = param1;
      }
      
      override flash_proxy function getProperty(param1:*) : *
      {
         var methodName:* = param1;
         if(methodName == "delegate")
         {
            return this.delegateValue;
         }
         if(!this.functions[methodName])
         {
            this.functions[methodName] = function():void
            {
               arguments.unshift(methodName.toString());
               onCallback.apply(this,arguments);
            };
         }
         return this.functions[methodName];
      }
      
      private function onCallback(param1:String, ... rest) : void
      {
         if(Boolean(this.delegateValue) && Boolean(this.delegateValue.hasOwnProperty(param1)))
         {
            this.delegateValue[param1].apply(this.delegateValue,rest);
         }
      }
      
      public function get delegate() : Object
      {
         return this.delegateValue;
      }
      
      override flash_proxy function callProperty(param1:*, ... rest) : *
      {
         rest.unshift(param1);
         this.onCallback.apply(this,rest);
      }
   }
}

