package com.google.youtube.players
{
   import com.google.utils.RequestVariables;
   import com.google.youtube.event.LogEvent;
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.event.VideoProgressEvent;
   import com.google.youtube.model.FailureReport;
   import com.google.youtube.model.VideoData;
   import flash.events.Event;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.NetConnection;
   import flash.net.ObjectEncoding;
   
   public class RTMPVideoPlayer extends HTTPVideoPlayer
   {
      
      protected var bufferLengthAfterVideoStarts:Number = 60;
      
      public function RTMPVideoPlayer(param1:IVideoInfoProvider)
      {
         super(param1);
      }
      
      override public function splice(param1:VideoData = null) : void
      {
         disconnectStream();
         play(videoData);
      }
      
      override public function onPlayStatus(param1:Object) : void
      {
         switch(param1.code)
         {
            case "NetStream.Play.Complete":
               dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS,getDuration(),this.getBytesLoaded(),this.getBytesTotal()));
               this.setPlayerState(new EndedState(this));
               disconnectStream();
               videoData.startSeconds = 0;
         }
      }
      
      override public function getBytesTotal() : Number
      {
         return Boolean(streamValue) && Boolean(streamValue.currentFPS) ? 1 : 0;
      }
      
      override protected function onError(param1:Event) : void
      {
         this.logPlaybackFailure();
         onCDNFailover();
      }
      
      protected function logPlaybackFailure(param1:String = "", param2:String = "") : void
      {
         var _loc3_:RequestVariables = new RequestVariables();
         var _loc4_:VideoErrorEvent = new VideoErrorEvent(VideoErrorEvent.ERROR,param1);
         _loc3_.ec = FailureReport.getErrorCode(_loc4_);
         if(param2)
         {
            _loc3_.status = param2;
         }
         dispatchEvent(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,_loc3_));
      }
      
      override protected function setPlayerState(param1:IPlayerState) : void
      {
         super.setPlayerState(param1);
         if((state is IPausedState || state is SeekingState) && Boolean(streamValue))
         {
            streamValue.bufferTime = videoInfoProvider.defaultBufferLength;
         }
      }
      
      override protected function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetConnection.Connect.IdleTimeout":
               disconnectStream();
               break;
            case "NetConnection.Connect.Failed":
            case "NetConnection.Connect.Rejected":
            case "NetStream.Play.Failure":
               if(!videoData.isRetrying)
               {
                  videoData.isRetrying = true;
                  disconnectStream();
                  play(videoData);
                  break;
               }
               this.logPlaybackFailure(param1.info.code,param1.info.status || "");
               onCDNFailover();
               break;
            case "NetStream.Play.StreamNotFound":
               this.logPlaybackFailure(param1.info.code,param1.info.status || "");
               onCDNFailover();
               break;
            case "NetStream.Buffer.Full":
               increaseTargetBufferLength(this.bufferLengthAfterVideoStarts);
               super.onNetStatus(param1);
               break;
            case "NetStream.Play.Stop":
               break;
            default:
               super.onNetStatus(param1);
         }
      }
      
      override protected function playStream() : Boolean
      {
         var startTime:Number = NaN;
         try
         {
            startTime = videoData.startSeconds ? videoData.startSeconds * 0.001 : 0;
            streamValue.play(videoData.videoUrl,startTime);
         }
         catch(e:SecurityError)
         {
            onError(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR,e.message));
            return false;
         }
         logPlayback();
         return true;
      }
      
      public function close() : void
      {
      }
      
      override public function getBytesLoaded() : Number
      {
         return this.getBytesTotal();
      }
      
      override public function initiatePlayback() : void
      {
         super.initiatePlayback();
         if(Boolean(videoData) && !videoData.isDataReady())
         {
            closeNetConnection(netConnection);
         }
      }
      
      override public function resetStream(param1:Boolean = true) : void
      {
         var _loc2_:uint = NetConnection.defaultObjectEncoding;
         NetConnection.defaultObjectEncoding = ObjectEncoding.AMF0;
         super.resetStream(param1);
         NetConnection.defaultObjectEncoding = _loc2_;
      }
   }
}

