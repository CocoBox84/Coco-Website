package com.google.utils
{
   public interface IStatProducer
   {
      
      function getBufferEmptyEvents() : Number;
      
      function getMediaDuration() : Number;
      
      function getElapsedTime() : Number;
      
      function getLoggingOptions() : Object;
      
      function getVerySmoothBandwidth() : Number;
      
      function getBytesLoaded() : Number;
      
      function getMediaTime() : Number;
      
      function getSmoothedBandwidth() : Number;
      
      function getExternalState() : int;
   }
}

