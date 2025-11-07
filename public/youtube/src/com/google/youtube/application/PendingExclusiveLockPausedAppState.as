package com.google.youtube.application
{
   public class PendingExclusiveLockPausedAppState extends PendingExclusiveLockAppState
   {
      
      public function PendingExclusiveLockPausedAppState(param1:VideoApplication)
      {
         super(param1);
      }
      
      override public function seekVideo() : IAppState
      {
         return this;
      }
      
      override public function pauseVideo() : IAppState
      {
         return this;
      }
      
      override public function playVideo() : IAppState
      {
         return new PendingExclusiveLockAppState(application);
      }
   }
}

