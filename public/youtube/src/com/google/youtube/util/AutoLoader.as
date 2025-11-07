package com.google.youtube.util
{
   import com.google.utils.EventListenerGroup;
   import com.google.utils.SafeLoader;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class AutoLoader extends SafeLoader
   {
      
      public static const UNLOADED:int = 0;
      
      public static const LOADING:int = 1;
      
      public static const LOADED:int = 2;
      
      public static const ERROR:int = 3;
      
      private static const SWF:String = "application/x-shockwave-flash";
      
      protected var stateValue:int = 0;
      
      protected var nominalHeight:uint;
      
      protected var events:EventListenerGroup;
      
      protected var nominalWidth:uint;
      
      protected var progress:EventListenerGroup;
      
      public var allowSwf:Boolean;
      
      public function AutoLoader()
      {
         super();
      }
      
      protected function onLoad(param1:Event) : void
      {
         this.stateValue = LOADED;
         if(!this.verifyContent())
         {
            return;
         }
         if(Boolean(this.nominalWidth) && Boolean(this.nominalHeight))
         {
            width = this.nominalWidth;
            height = this.nominalHeight;
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function onError(param1:Event = null) : void
      {
         this.destroy();
         this.stateValue = ERROR;
         dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
      }
      
      protected function onProgress(param1:Event) : void
      {
         this.verifyContent();
      }
      
      protected function verifyContent() : Boolean
      {
         if(contentLoaderInfo.contentType == SWF && !this.allowSwf)
         {
            this.onError(null);
            return false;
         }
         return true;
      }
      
      public function get state() : int
      {
         return this.stateValue;
      }
      
      override public function load(param1:URLRequest, param2:LoaderContext = null) : void
      {
         var request:URLRequest = param1;
         var context:LoaderContext = param2;
         this.destroy();
         this.stateValue = LOADING;
         this.events = new EventListenerGroup(contentLoaderInfo);
         this.events.addEventCallback(Event.INIT,this.onLoad);
         this.events.addEventCallback(IOErrorEvent.IO_ERROR,this.onError);
         this.events.addEventCallback(SecurityErrorEvent.SECURITY_ERROR,this.onError);
         this.progress = new EventListenerGroup(contentLoaderInfo,true);
         this.progress.addEventCallback(HTTPStatusEvent.HTTP_STATUS,this.onProgress);
         this.progress.addEventCallback(ProgressEvent.PROGRESS,this.onProgress);
         try
         {
            super.load(request,context);
         }
         catch(e:Error)
         {
            onError();
         }
      }
      
      public function setSize(param1:uint, param2:uint) : void
      {
         this.nominalWidth = param1;
         this.nominalHeight = param2;
         if(this.stateValue == LOADED)
         {
            this.width = param1;
            this.height = param2;
         }
      }
      
      public function destroy() : void
      {
         if(this.events)
         {
            this.events.dispose();
            this.events = null;
         }
         if(this.progress)
         {
            this.progress.dispose();
            this.progress = null;
         }
         switch(this.stateValue)
         {
            case LOADING:
               try
               {
                  close();
                  break;
               }
               catch(e:Error)
               {
                  break;
               }
               break;
            case LOADED:
               this.unload();
         }
      }
      
      override public function unload() : void
      {
         this.stateValue = UNLOADED;
         super.unload();
      }
   }
}

