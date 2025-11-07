package com.google.youtube.application
{
   import com.google.youtube.model.VideoDataEvent;
   
   public class PendingUserInputAppState extends BaseAppState implements IBlockingAppState
   {
      
      public function PendingUserInputAppState(param1:VideoApplication)
      {
         super(param1);
      }
      
      override public function onPrerollReady(param1:String = null) : IAppState
      {
         super.onPrerollReady(param1);
         return this;
      }
      
      override public function pauseVideo() : IAppState
      {
         return this;
      }
      
      override public function onVideoDataChange(param1:VideoDataEvent) : IAppState
      {
         return this;
      }
   }
}

