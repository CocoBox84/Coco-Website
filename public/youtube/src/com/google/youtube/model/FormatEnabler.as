package com.google.youtube.model
{
   import com.google.utils.Scheduler;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   
   public class FormatEnabler
   {
      
      protected static const MIN_FORMAT_RETRY_INTERVAL:uint = 120000;
      
      protected static const MIN_RETRY_INTERVAL:uint = 30000;
      
      protected var videoData:VideoData;
      
      protected var inProgress:VideoFormat;
      
      protected var nextRetry:uint;
      
      protected var nextFormatRetry:Object = {};
      
      public function FormatEnabler()
      {
         super();
      }
      
      public function enableFormats(param1:VideoData, param2:uint) : void
      {
         var _loc4_:VideoFormat = null;
         if(this.inProgress)
         {
            return;
         }
         var _loc3_:uint = Scheduler.clock();
         if(_loc3_ < this.nextRetry)
         {
            return;
         }
         for each(_loc4_ in param1.formatList)
         {
            if(!_loc4_.enabled)
            {
               this.nextFormatRetry[_loc4_.name] = this.nextFormatRetry[_loc4_.name] || _loc3_ + MIN_FORMAT_RETRY_INTERVAL;
               if(_loc3_ >= this.nextFormatRetry[_loc4_.name])
               {
                  this.nextRetry = _loc3_ + MIN_RETRY_INTERVAL;
                  this.nextFormatRetry[_loc4_.name] = _loc3_ + MIN_FORMAT_RETRY_INTERVAL;
                  this.videoData = param1;
                  this.inProgress = _loc4_;
                  if(_loc4_.formatIndex.canGetSeekPoint(param2))
                  {
                     this.next(new Event(Event.COMPLETE));
                  }
                  else
                  {
                     this.waitForErrorOrComplete(_loc4_.formatIndex);
                     _loc4_.formatIndex.load();
                  }
                  return;
               }
            }
         }
      }
      
      protected function waitForErrorOrComplete(param1:IEventDispatcher) : void
      {
         param1.addEventListener(Event.COMPLETE,this.next);
         param1.addEventListener(ErrorEvent.ERROR,this.next);
         param1.addEventListener(IOErrorEvent.IO_ERROR,this.next);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.next);
      }
      
      protected function next(param1:Event) : void
      {
         if(Boolean(param1) && param1.type == Event.COMPLETE)
         {
            this.videoData.enableFormat(this.inProgress);
            delete this.nextFormatRetry[this.inProgress.name];
         }
         this.stopListening(this.inProgress.formatIndex);
         this.inProgress = null;
      }
      
      protected function stopListening(param1:IEventDispatcher) : void
      {
         param1.removeEventListener(Event.COMPLETE,this.next);
         param1.removeEventListener(ErrorEvent.ERROR,this.next);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,this.next);
         param1.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.next);
      }
   }
}

