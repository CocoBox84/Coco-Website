package com.google.youtube.application
{
   import com.google.youtube.model.VideoDataEvent;
   
   public class UnbuiltAppState extends NotStartedAppState
   {
      
      public function UnbuiltAppState(param1:VideoApplication)
      {
         super(param1);
      }
      
      override public function onVideoDataChange(param1:VideoDataEvent) : IAppState
      {
         return this;
      }
   }
}

