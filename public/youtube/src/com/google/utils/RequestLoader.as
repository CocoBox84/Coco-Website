package com.google.utils
{
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.sendToURL;
   
   public class RequestLoader extends EventDispatcher
   {
      
      protected static const DEFAULT_FORMAT:String = "text";
      
      public var data:*;
      
      public function RequestLoader()
      {
         super();
      }
      
      protected function parseLoadedData(param1:*) : void
      {
         this.data = param1;
      }
      
      protected function onLoadError(param1:Event) : void
      {
         if(hasEventListener(param1.type))
         {
            dispatchEvent(param1);
         }
      }
      
      public function sendRequest(param1:URLRequest) : void
      {
         var event:ErrorEvent = null;
         var request:URLRequest = param1;
         try
         {
            sendToURL(request);
         }
         catch(e:SecurityError)
         {
            event = new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR);
            event.text = e.message;
            onLoadError(event);
         }
         catch(e:Error)
         {
            event = new ErrorEvent(ErrorEvent.ERROR);
            event.text = e.message;
            onLoadError(event);
         }
      }
      
      public function loadRequest(param1:URLRequest, param2:String = "text") : URLLoader
      {
         var event:ErrorEvent = null;
         var request:URLRequest = param1;
         var format:String = param2;
         var loader:URLLoader = new URLLoader();
         loader.dataFormat = format;
         loader.addEventListener(Event.COMPLETE,this.onLoadComplete);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         try
         {
            loader.load(request);
         }
         catch(error:SecurityError)
         {
            event = new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR);
            event.text = error.message;
            onLoadError(event);
         }
         catch(error:Error)
         {
            event = new ErrorEvent(ErrorEvent.ERROR);
            event.text = error.message;
            onLoadError(event);
         }
         return loader;
      }
      
      protected function onLoadComplete(param1:Event) : void
      {
         this.parseLoadedData(param1.target.data);
         dispatchEvent(param1);
      }
   }
}

