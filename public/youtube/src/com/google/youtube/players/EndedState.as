package com.google.youtube.players
{
   import com.google.youtube.model.StatsPlayerState;
   import com.google.youtube.model.VideoData;
   import flash.events.NetStatusEvent;
   
   public class EndedState extends BasePlayerState implements IEndedState, IStatsProviderState
   {
      
      public function EndedState(param1:IVideoPlayer)
      {
         super(param1);
      }
      
      override public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         return this;
      }
      
      override public function play(param1:VideoData = null) : IPlayerState
      {
         var _loc2_:Number = NaN;
         if(!param1 && videoPlayer.getVideoData() && Boolean(videoPlayer.stream))
         {
            _loc2_ = Number(videoPlayer.getVideoData().clipStart || 0);
            videoPlayer.stream.resume();
            return videoPlayer is TagStreamPlayer ? seekUnbuffered(_loc2_) : seek(_loc2_,true);
         }
         return super.play(param1 || videoPlayer.getVideoData());
      }
      
      public function get statsStateId() : String
      {
         return StatsPlayerState.ENDED;
      }
      
      override public function pause() : IPlayerState
      {
         return this;
      }
   }
}

