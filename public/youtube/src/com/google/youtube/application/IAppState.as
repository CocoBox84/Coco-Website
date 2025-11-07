package com.google.youtube.application
{
   import com.google.youtube.model.VideoDataEvent;
   import com.google.youtube.time.CueRangeEvent;
   
   public interface IAppState
   {
      
      function onPrerollReady(param1:String = null) : IAppState;
      
      function seekVideo() : IAppState;
      
      function pauseVideo() : IAppState;
      
      function onVideoDataChange(param1:VideoDataEvent) : IAppState;
      
      function playVideo() : IAppState;
      
      function onCueRangeLockBlockExit(param1:CueRangeEvent) : IAppState;
      
      function onCueRangeLockBlockEnter(param1:CueRangeEvent, param2:Boolean = false) : IAppState;
   }
}

