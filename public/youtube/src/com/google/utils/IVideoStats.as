package com.google.utils
{
   import com.google.events.SchedulerEvent;
   
   public interface IVideoStats
   {
      
      function get sentInitialPing() : Boolean;
      
      function mediaUpdate(param1:SchedulerEvent = null) : void;
      
      function endPlayback() : void;
      
      function onAdPlay() : void;
      
      function onAdEnd() : void;
      
      function sendReport(param1:Boolean = false, param2:RequestVariables = null) : void;
      
      function startPlayback(param1:String, param2:String, param3:IStatProducer) : void;
      
      function get playbackStarted() : Boolean;
   }
}

