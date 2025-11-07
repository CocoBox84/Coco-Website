package com.google.youtube.players.tagstream
{
   import com.google.youtube.event.FallbackEvent;
   import com.google.youtube.event.StreamEvent;
   import flash.events.ErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   
   public class PipelineEventDispatcher extends EventDispatcher
   {
      
      public function PipelineEventDispatcher()
      {
         super();
      }
      
      public static function addErrorListenersTo(param1:IEventDispatcher, param2:Function) : void
      {
         param1.addEventListener(ErrorEvent.ERROR,param2);
         param1.addEventListener(IOErrorEvent.IO_ERROR,param2);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,param2);
         param1.addEventListener(FallbackEvent.FALLBACK,param2);
      }
      
      public static function removeErrorListenersFrom(param1:IEventDispatcher, param2:Function) : void
      {
         param1.removeEventListener(ErrorEvent.ERROR,param2);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,param2);
         param1.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,param2);
         param1.removeEventListener(FallbackEvent.FALLBACK,param2);
      }
      
      protected function stopForwardingEvents(param1:IEventDispatcher, param2:Boolean) : void
      {
         if(param2)
         {
            param1.removeEventListener(ProgressEvent.PROGRESS,dispatchEvent);
         }
         param1.removeEventListener(StreamEvent.STREAM,dispatchEvent);
         removeErrorListenersFrom(param1,dispatchEvent);
      }
      
      protected function forwardEvents(param1:IEventDispatcher, param2:Boolean) : void
      {
         if(param2)
         {
            param1.addEventListener(ProgressEvent.PROGRESS,dispatchEvent);
         }
         param1.addEventListener(StreamEvent.STREAM,dispatchEvent);
         addErrorListenersTo(param1,dispatchEvent);
      }
   }
}

