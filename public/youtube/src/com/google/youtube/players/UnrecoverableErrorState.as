package com.google.youtube.players
{
   import com.google.youtube.model.VideoData;
   import flash.events.ErrorEvent;
   
   public class UnrecoverableErrorState extends ErrorState
   {
      
      public var message:String;
      
      public function UnrecoverableErrorState(param1:IVideoPlayer, param2:ErrorEvent = null, param3:String = null)
      {
         super(param1,param2);
         this.message = param3;
      }
      
      override public function play(param1:VideoData = null) : IPlayerState
      {
         return this;
      }
   }
}

