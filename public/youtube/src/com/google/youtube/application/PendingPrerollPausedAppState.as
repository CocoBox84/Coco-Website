package com.google.youtube.application
{
   public class PendingPrerollPausedAppState extends PendingPrerollAppState
   {
      
      public function PendingPrerollPausedAppState(param1:VideoApplication)
      {
         super(param1);
      }
      
      override public function seekVideo() : IAppState
      {
         return new PendingPrerollAppState(application);
      }
      
      override public function pauseVideo() : IAppState
      {
         return this;
      }
      
      override public function playVideo() : IAppState
      {
         return new PendingPrerollAppState(application);
      }
   }
}

