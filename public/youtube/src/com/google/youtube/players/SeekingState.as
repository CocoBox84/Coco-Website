package com.google.youtube.players
{
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.model.StatsPlayerState;
   import com.google.youtube.model.VideoData;
   import flash.events.NetStatusEvent;
   
   public class SeekingState extends BasePlayerState implements ISeekingState, IStatsProviderState
   {
      
      protected static const retryThreshold:int = 9;
      
      protected var pendingSeekRequest:Array;
      
      protected var seekTimeValue:Number;
      
      protected var allowSeekAheadValue:Boolean;
      
      protected var retryCount:int = 0;
      
      public function SeekingState(param1:IVideoPlayer, param2:Number = NaN, param3:Boolean = true)
      {
         super(param1);
         if(isNaN(param2) && Boolean(videoPlayer.getVideoData()))
         {
            this.seekTimeValue = videoPlayer.getVideoData().startSeconds;
            this.allowSeekAheadValue = true;
         }
         else
         {
            this.seekTimeValue = param2 || 0;
            this.allowSeekAheadValue = param3;
         }
      }
      
      public function get seekTime() : Number
      {
         return this.seekTimeValue;
      }
      
      public function get statsStateId() : String
      {
         return StatsPlayerState.SEEKING;
      }
      
      public function get allowSeekAhead() : Boolean
      {
         return this.allowSeekAheadValue;
      }
      
      override public function get isPeggedToLive() : Boolean
      {
         var _loc1_:VideoData = videoPlayer.getVideoData();
         if(!_loc1_ || !_loc1_.isLive)
         {
            return false;
         }
         var _loc2_:* = this.seekTime == Infinity;
         var _loc3_:Boolean = _loc1_.format.isHls && Boolean(_loc1_.format.hlsPlaylist) && this.seekTime >= _loc1_.format.hlsPlaylist.liveChunkTime - 0.1;
         var _loc4_:Boolean = int(_loc1_.partnerId) == PlayerType.AKAMAI_LIVE || int(_loc1_.partnerId) == PlayerType.AKAMAI_HD_LIVE && (this.seekTime >= videoPlayer.getDuration() - 1 || this.seekTime == AkamaiHDLiveVideoPlayer.HEAD_OF_STREAM);
         return _loc2_ || _loc3_ || _loc4_;
      }
      
      override public function play(param1:VideoData = null) : IPlayerState
      {
         if(!param1 && Boolean(videoPlayer.getVideoData()))
         {
            return this;
         }
         return super.play(param1);
      }
      
      override public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         var _loc2_:Array = null;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:Number = NaN;
         if(this.pendingSeekRequest)
         {
            _loc2_ = this.pendingSeekRequest;
            this.pendingSeekRequest = null;
            return super.seek.apply(this,_loc2_);
         }
         switch(param1.info.code)
         {
            case "NetConnection.Connect.Closed":
               if(this.retryCount < retryThreshold)
               {
                  ++this.retryCount;
                  if(videoPlayer.getVideoData())
                  {
                     videoPlayer.getVideoData().netConnectionClosedEventCount = this.retryCount;
                     videoPlayer.resetStream(false);
                     this.play(videoPlayer.getVideoData());
                  }
                  break;
               }
               if(this.retryCount == retryThreshold)
               {
                  return new ErrorState(videoPlayer,new VideoErrorEvent(VideoErrorEvent.ERROR,param1.info.code));
               }
               break;
            case "NetStream.Play.Start":
               _loc3_ = videoPlayer.getVideoData().isTransportRtmp() && !videoPlayer.getVideoData().format.isMp4 && !videoPlayer.getVideoData().isAlwaysBuffered();
               _loc4_ = Boolean(videoPlayer.getVideoData().startSeconds) && (videoPlayer.getTime() == 0 || videoPlayer.getTime() == videoPlayer.getVideoData().startSeconds);
               if(_loc3_ && _loc4_)
               {
                  return new RTMPBufferingState(videoPlayer);
               }
               return new BufferingState(videoPlayer);
               break;
            case "NetStream.Seek.Notify":
               if(!videoPlayer.getVideoData().isTransportRtmp() && (param1.target == null || param1.target.bufferLength <= 0.001))
               {
                  videoPlayer.getVideoData().startSeconds = this.seekTimeValue;
                  videoPlayer.resetStream();
                  return this.play(videoPlayer.getVideoData());
               }
               break;
            case "NetStream.Buffer.Full":
               return new PlayingState(videoPlayer);
            case "NetStream.Play.Stop":
               if(!videoPlayer.getVideoData().isMp4)
               {
                  break;
               }
            case "NetStream.Seek.InvalidTime":
               if(this.allowSeekAheadValue && videoPlayer.getBytesLoaded() < videoPlayer.getBytesTotal() && !videoPlayer.getVideoData().isTransportRtmp())
               {
                  return seekUnbuffered(this.seekTimeValue);
               }
               if(parseFloat(param1.info.details))
               {
                  if(videoPlayer.stream)
                  {
                     videoPlayer.stream.seek(parseFloat(param1.info.details));
                  }
                  break;
               }
               if(videoPlayer.getBytesLoaded() == videoPlayer.getBytesTotal() && videoPlayer.getVideoData().isMp4 && !videoPlayer.getVideoData().isTransportRtmp())
               {
                  _loc5_ = videoPlayer.getVideoData().startSeconds;
                  this.seekTimeValue = this.seekTimeValue - 1 > _loc5_ ? this.seekTimeValue - 1 : _loc5_;
                  if(videoPlayer.stream)
                  {
                     videoPlayer.stream.seek(this.seekTimeValue - _loc5_);
                  }
                  return this;
               }
               param1.info.code = "NetStream.Seek.Notify";
               return this.onNetStatus(param1);
               break;
            case "AppendBytesNetStream.Seek.Notify":
               return seekUnbuffered(this.seekTimeValue);
         }
         return this;
      }
      
      override public function pause() : IPlayerState
      {
         return new SeekingPausedState(videoPlayer,this.seekTimeValue,this.allowSeekAheadValue);
      }
      
      override public function seek(param1:Number, param2:Boolean) : IPlayerState
      {
         if(param1 != this.seekTimeValue || param2 != this.allowSeekAheadValue)
         {
            this.pendingSeekRequest = arguments;
         }
         return this;
      }
   }
}

