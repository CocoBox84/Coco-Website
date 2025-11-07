package com.google.youtube.ui
{
   import com.google.utils.SafeLoader;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.utils.Timer;
   
   public class Interstitial extends UIElement
   {
      
      protected var timeOut:Number = 6000;
      
      protected var timer:Timer;
      
      protected var request:URLRequest;
      
      protected var loader:Loader;
      
      protected var screenTime:Number = 4000;
      
      public function Interstitial(param1:URLRequest, param2:Number)
      {
         this.screenTime = param2;
         this.request = param1;
         super();
      }
      
      protected function onLoadError(param1:Event) : void
      {
         this.removeEventListeners();
         this.onComplete(param1);
      }
      
      override public function get height() : Number
      {
         return this.loader ? this.loader.height : 1;
      }
      
      public function load() : void
      {
         this.removeEventListeners();
         if(Boolean(this.loader) && contains(this.loader))
         {
            removeChild(this.loader);
         }
         this.loader = new SafeLoader();
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadComplete);
         this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         try
         {
            this.loader.load(this.request);
            addChild(this.loader);
            this.timer = new Timer(this.timeOut,1);
            this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onComplete);
            this.timer.start();
         }
         catch(error:Error)
         {
            onLoadError(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR,error.message));
         }
      }
      
      protected function removeEventListeners() : void
      {
         if(this.loader)
         {
            this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadComplete);
            this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
            this.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         }
         if(this.timer)
         {
            this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onComplete);
         }
      }
      
      override public function get width() : Number
      {
         return this.loader ? this.loader.width : 1;
      }
      
      protected function onLoadComplete(param1:Event) : void
      {
         this.removeEventListeners();
         this.timer = new Timer(this.screenTime,1);
         this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onComplete);
         this.timer.start();
         dispatchEvent(new Event(Event.RESIZE));
      }
      
      protected function onComplete(param1:Event) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

