package com.google.youtube.application
{
   public class StartedAppState extends BaseAppState
   {
      
      public function StartedAppState(param1:VideoApplication)
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
      
      override public function activateVideoPlayer() : IAppState
      {
         return this;
      }
      
      override public function pauseVideo() : IAppState
      {
         return this;
      }
      
      override public function playVideo() : IAppState
      {
         return this;
      }
   }
}

