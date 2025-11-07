package com.google.utils
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class GuardedLoader extends Loader
   {
      
      private var loaderContext:LoaderContext = new LoaderContext();
      
      public function GuardedLoader()
      {
         super();
         contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onIoError);
         contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete);
      }
      
      protected function onIoError(param1:IOErrorEvent) : void
      {
      }
      
      override public function load(param1:URLRequest, param2:LoaderContext = null) : void
      {
         super.load(param1,param2 || this.loaderContext);
      }
      
      protected function onSecurityError(param1:SecurityErrorEvent) : void
      {
      }
      
      protected function onComplete(param1:Event) : void
      {
      }
   }
}

