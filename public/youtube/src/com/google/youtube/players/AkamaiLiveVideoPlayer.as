package com.google.youtube.players
{
   import flash.events.Event;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   
   public class AkamaiLiveVideoPlayer extends AkamaiRTMPVideoPlayer
   {
      
      private const EMPTY_BUFFER_TIMEOUT:Number = 10000;
      
      protected var unpublishNotified:Boolean = false;
      
      public function AkamaiLiveVideoPlayer(param1:IVideoInfoProvider)
      {
         super(param1);
      }
      
      override protected function isValidBufferEmpty() : Boolean
      {
         return true;
      }
      
      public function onFCSubscribe(param1:Object) : void
      {
         switch(param1.code)
         {
            case "NetStream.Play.Start":
               connectStream();
               if(streamValue)
               {
                  streamValue.play(videoData.stream);
               }
               break;
            case "NetStream.Play.StreamNotFound":
               handleCDNRetry();
               break;
            default:
               trace("onFCSubscribe " + param1.code);
         }
      }
      
      override protected function isEnded() : Boolean
      {
         var _loc1_:Number = NaN;
         if(Boolean(bufferEmptyStart) && new Date().time - bufferEmptyStart.time > this.EMPTY_BUFFER_TIMEOUT)
         {
            _loc1_ = videoData.cdnList.length;
            if(videoData.cdnListIndex < _loc1_ - 1)
            {
               progressScheduler.stop();
               handleCDNRetry();
            }
         }
         return false;
      }
      
      override protected function playStream() : Boolean
      {
         try
         {
            streamValue.play(videoData.videoUrl);
         }
         catch(e:SecurityError)
         {
            onError(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR,e.message));
            return false;
         }
         logPlayback();
         return true;
      }
      
      public function onFCUnsubscribe(param1:Object) : void
      {
         switch(param1.code)
         {
            case "NetStream.Play.Stop":
               if(this.unpublishNotified)
               {
                  disconnectStream();
                  break;
               }
               handleCDNRetry();
               break;
            default:
               trace("onFCUnsubscribe " + param1.code);
         }
      }
      
      override protected function onRequestLoadComplete(param1:Event) : void
      {
         super.onRequestLoadComplete(param1);
         if(netConnection && videoData && Boolean(videoData.stream))
         {
            netConnection.call("FCSubscribe",null,videoData.stream);
         }
      }
      
      override protected function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Stop":
               break;
            case "NetConnection.Connect.Success":
               if(param1.target === netConnection)
               {
                  closeNetConnection(fallbackNetConnection);
                  break;
               }
               closeNetConnection(netConnection);
               netConnection = fallbackNetConnection;
               fallbackNetConnection = null;
               break;
            case "NetStream.Buffer.Empty":
               bufferEmptyStart = new Date();
               break;
            case "NetStream.Buffer.Full":
            case "NetStream.Play.Start":
            case "NetStream.Seek.Notify":
               bufferEmptyStart = null;
               super.onNetStatus(param1);
               break;
            case "NetStream.Play.UnpublishNotify":
               this.unpublishNotified = true;
               break;
            case "NetStream.Play.StreamNotFound":
               handleCDNRetry();
               break;
            default:
               super.onNetStatus(param1);
         }
      }
      
      override public function seek(param1:Number, param2:Boolean = true) : void
      {
         if(param1 == Infinity)
         {
            param1 = 1;
         }
         super.seek(param1,param2);
      }
      
      override protected function increaseTargetBufferLength(param1:Number) : void
      {
      }
      
      override public function resetStream(param1:Boolean = true) : void
      {
         super.resetStream(param1);
         var _loc2_:Boolean = Boolean(serverIpRequestLoader);
         if(Boolean(videoData) && Boolean(netConnection))
         {
            netConnection.call("FCSubscribe",null,videoData.stream);
         }
         if(_loc2_)
         {
            resetFallbackConn();
         }
      }
   }
}

