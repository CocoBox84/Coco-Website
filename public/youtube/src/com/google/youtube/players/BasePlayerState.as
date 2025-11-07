package com.google.youtube.players
{
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.model.KeyframeTuple;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.util.hls.HlsPlaylist;
   import flash.events.ErrorEvent;
   import flash.events.NetStatusEvent;
   
   public class BasePlayerState implements IPlayerState
   {
      
      protected static var SEEK_TOLERANCE:Number = 0.15;
      
      protected var videoPlayerValue:IVideoPlayer;
      
      public function BasePlayerState(param1:IVideoPlayer)
      {
         super();
         this.videoPlayer = param1;
      }
      
      public function onNewVideoData(param1:GetVideoInfoEvent) : IPlayerState
      {
         return new SeekingState(this.videoPlayer);
      }
      
      public function seek(param1:Number, param2:Boolean) : IPlayerState
      {
         var _loc3_:VideoData = this.videoPlayerValue.getVideoData();
         if(!_loc3_ || !_loc3_.isDataValid())
         {
            return this;
         }
         param1 = Math.max(0,param1);
         if(!this.videoPlayer.stream)
         {
            _loc3_.startSeconds = param1;
            return this.play(_loc3_);
         }
         if(Boolean(_loc3_.duration) && !_loc3_.isLive)
         {
            param1 = Math.min(param1,_loc3_.duration);
         }
         if(param1 < _loc3_.startSeconds && _loc3_.startSeconds != Infinity && !(_loc3_.isTransportRtmp() && !_loc3_.format.isMp4) && !_loc3_.isAlwaysBuffered())
         {
            if(param2)
            {
               return this.seekUnbuffered(param1);
            }
            param1 = _loc3_.startSeconds;
         }
         if(_loc3_.isMp4 || _loc3_.requiresTimeOffset)
         {
            this.videoPlayerValue.stream.seek(param1 - _loc3_.startSeconds);
         }
         else
         {
            this.videoPlayerValue.stream.seek(param1);
         }
         if(_loc3_.isAlwaysBuffered())
         {
            _loc3_.startSeconds = 0;
         }
         return new SeekingState(this.videoPlayerValue,param1,param2);
      }
      
      public function unrecoverableError(param1:String = null) : IPlayerState
      {
         return new UnrecoverableErrorState(this.videoPlayer,new VideoErrorEvent(VideoErrorEvent.ERROR),param1);
      }
      
      protected function seekUnbuffered(param1:Number) : IPlayerState
      {
         var _loc3_:KeyframeTuple = null;
         var _loc2_:VideoData = this.videoPlayerValue.getVideoData();
         if(_loc2_.canSeekOnTime())
         {
            _loc2_.startSeconds = param1;
            this.videoPlayerValue.initiatePlayback();
         }
         else if(_loc2_.keyframes)
         {
            _loc3_ = _loc2_.findClosestKeyframeBefore(param1);
            _loc2_.startSeconds = param1;
            _loc2_.videoFileByteOffset = param1 == 0 ? 0 : _loc3_.byteOffset;
            this.videoPlayerValue.initiatePlayback();
         }
         return new SeekingState(this.videoPlayerValue,param1,true);
      }
      
      public function splice(param1:VideoData) : IPlayerState
      {
         this.videoPlayer.setVideoData(param1);
         if(this.videoPlayer.getVideoData().isDataValid())
         {
            this.videoPlayer.initiateSplice();
            return this;
         }
         return new ErrorState(this.videoPlayer);
      }
      
      public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Stop":
               return new PausedState(this.videoPlayer,true);
            default:
               return this;
         }
      }
      
      protected function recentlyPeggedToLive() : Boolean
      {
         var _loc1_:HlsPlaylist = null;
         if(this.videoPlayer.isPeggedToLive() && this.videoPlayer.getVideoData().isLive)
         {
            _loc1_ = this.videoPlayer.getVideoData().format.hlsPlaylist;
            if(_loc1_ && _loc1_.duration && Boolean(this.videoPlayer.getTime()))
            {
               return _loc1_.liveChunkTime - this.videoPlayer.getTime() < 120;
            }
            return true;
         }
         return this.videoPlayer.isPeggedToLive();
      }
      
      public function onNewVideoDataError(param1:ErrorEvent) : IPlayerState
      {
         return new ErrorState(this.videoPlayer,param1);
      }
      
      public function get isPeggedToLive() : Boolean
      {
         return false;
      }
      
      public function get videoPlayer() : IVideoPlayer
      {
         return this.videoPlayerValue;
      }
      
      public function play(param1:VideoData = null) : IPlayerState
      {
         if(!param1 && this.videoPlayer.getVideoData() && Boolean(this.videoPlayer.stream))
         {
            return this;
         }
         if(param1)
         {
            this.videoPlayer.setVideoData(param1);
         }
         if(Boolean(this.videoPlayer.getVideoData()) && this.videoPlayer.getVideoData().isDataValid())
         {
            this.videoPlayer.initiatePlayback();
            return new SeekingState(this.videoPlayer);
         }
         return new ErrorState(this.videoPlayer);
      }
      
      public function pause() : IPlayerState
      {
         return new PausedState(this.videoPlayer);
      }
      
      public function set videoPlayer(param1:IVideoPlayer) : void
      {
         this.videoPlayerValue = param1;
      }
   }
}

