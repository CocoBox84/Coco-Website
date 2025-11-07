package com.google.youtube.players
{
   import com.google.youtube.model.VideoData;
   
   public class GuestEndedState extends GuestPlayerState implements IEndedState
   {
      
      public function GuestEndedState(param1:IVideoPlayer)
      {
         super(param1);
      }
      
      override public function play(param1:VideoData = null) : IPlayerState
      {
         if(playerAdapter)
         {
            playerAdapter.executeSeek(0);
            playerAdapter.executePlay();
         }
         return null;
      }
   }
}

