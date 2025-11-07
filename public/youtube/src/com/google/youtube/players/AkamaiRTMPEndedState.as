package com.google.youtube.players
{
   public class AkamaiRTMPEndedState extends EndedState
   {
      
      public function AkamaiRTMPEndedState(param1:IVideoPlayer)
      {
         super(param1);
      }
      
      override public function seek(param1:Number, param2:Boolean) : IPlayerState
      {
         videoPlayer.getVideoData().startSeconds = param1;
         videoPlayer.stream.play(videoPlayer.getVideoData().stream);
         return new SeekingState(videoPlayer);
      }
   }
}

