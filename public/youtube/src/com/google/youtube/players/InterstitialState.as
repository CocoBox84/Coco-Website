package com.google.youtube.players
{
   import com.google.youtube.model.VideoData;
   
   public class InterstitialState extends GuestPlayerState
   {
      
      public function InterstitialState(param1:IVideoPlayer)
      {
         super(param1);
      }
      
      override public function play(param1:VideoData = null) : IPlayerState
      {
         if(videoPlayer.showInterstitial())
         {
            return null;
         }
         super.play(videoPlayer.getVideoData());
         return new GuestPlayerState(videoPlayer);
      }
      
      override public function seek(param1:Number, param2:Boolean) : IPlayerState
      {
         return this;
      }
      
      override public function pause() : IPlayerState
      {
         return this;
      }
   }
}

