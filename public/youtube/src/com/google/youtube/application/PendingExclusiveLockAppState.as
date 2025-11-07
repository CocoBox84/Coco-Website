package com.google.youtube.application
{
   import com.google.youtube.model.VideoDataEvent;
   
   public class PendingExclusiveLockAppState extends BaseAppState implements IBlockingAppState
   {
      
      public function PendingExclusiveLockAppState(param1:VideoApplication)
      {
         super(param1);
      }
      
      override public function onPrerollReady(param1:String = null) : IAppState
      {
         return this;
      }
      
      override public function seekVideo() : IAppState
      {
         return this;
      }
      
      override public function onVideoDataChange(param1:VideoDataEvent) : IAppState
      {
         if(param1.source == VideoDataEvent.NEW_VIDEO_DATA || param1.source == VideoDataEvent.VIDEO_INFO)
         {
            return super.onVideoDataChange(param1);
         }
         return this;
      }
      
      override public function activateVideoPlayer() : IAppState
      {
         return this;
      }
      
      override public function pauseVideo() : IAppState
      {
         return new PendingExclusiveLockPausedAppState(application);
      }
      
      override public function playVideo() : IAppState
      {
         return this;
      }
   }
}

