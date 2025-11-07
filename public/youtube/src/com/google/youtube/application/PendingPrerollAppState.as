package com.google.youtube.application
{
   public class PendingPrerollAppState extends BaseAppState implements IBlockingAppState
   {
      
      public function PendingPrerollAppState(param1:VideoApplication)
      {
         super(param1);
      }
      
      override public function seekVideo() : IAppState
      {
         return this;
      }
      
      override public function pauseVideo() : IAppState
      {
         return new PendingPrerollPausedAppState(application);
      }
      
      override public function playVideo() : IAppState
      {
         return this;
      }
   }
}

