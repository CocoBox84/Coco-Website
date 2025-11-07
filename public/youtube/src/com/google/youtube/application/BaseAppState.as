package com.google.youtube.application
{
   import com.google.youtube.model.VideoDataEvent;
   import com.google.youtube.time.CueRangeEvent;
   
   public class BaseAppState implements IAppState
   {
      
      public var application:VideoApplication;
      
      public function BaseAppState(param1:VideoApplication)
      {
         super();
         this.application = param1;
      }
      
      public function onPrerollReady(param1:String = null) : IAppState
      {
         if(param1)
         {
            this.application.videoData.onPrerollReady(param1);
         }
         if(this.application.videoData.needsPrerolls())
         {
            return new PendingPrerollAppState(this.application);
         }
         return new StartedAppState(this.application);
      }
      
      public function seekVideo() : IAppState
      {
         return this.activateVideoPlayer();
      }
      
      public function pauseVideo() : IAppState
      {
         return this.activateVideoPlayer();
      }
      
      public function activateVideoPlayer() : IAppState
      {
         if(this.application.videoData.needsPrerolls())
         {
            this.application.loadModules();
            if(this.application.videoData.needsPrerolls())
            {
               return new PendingPrerollAppState(this.application);
            }
            return new StartedAppState(this.application);
         }
         if(this.application.videoData.isDataReady())
         {
            this.application.loadModules();
            return new StartedAppState(this.application);
         }
         return new PendingVideoDataAppState(this.application);
      }
      
      public function playVideo() : IAppState
      {
         return this.activateVideoPlayer();
      }
      
      public function onVideoDataChange(param1:VideoDataEvent) : IAppState
      {
         if(param1.source == VideoDataEvent.NEW_VIDEO_DATA || param1.source == VideoDataEvent.VIDEO_INFO)
         {
            this.application.loadModules();
         }
         if(!this.application.videoData.isDataReady())
         {
            return new PendingVideoDataAppState(this.application);
         }
         return this.onPrerollReady();
      }
      
      public function onCueRangeLockBlockExit(param1:CueRangeEvent) : IAppState
      {
         return new StartedAppState(this.application);
      }
      
      public function onCueRangeLockBlockEnter(param1:CueRangeEvent, param2:Boolean = false) : IAppState
      {
         if(param2)
         {
            return new PendingExclusiveLockPausedAppState(this.application);
         }
         return new PendingExclusiveLockAppState(this.application);
      }
   }
}

