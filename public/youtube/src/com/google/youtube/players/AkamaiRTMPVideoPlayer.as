package com.google.youtube.players
{
   import com.google.events.SchedulerEvent;
   import com.google.utils.RequestLoader;
   import com.google.utils.Scheduler;
   import com.google.utils.Url;
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.event.VideoProgressEvent;
   import flash.events.AsyncErrorEvent;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.NetConnection;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class AkamaiRTMPVideoPlayer extends RTMPVideoPlayer
   {
      
      public var serverIp:String = "";
      
      protected var serverIpRequestLoader:RequestLoader;
      
      protected var fallbackNetConnection:NetConnection;
      
      protected var bufferScheduler:Scheduler;
      
      protected var serverIpLoader:URLLoader;
      
      public function AkamaiRTMPVideoPlayer(param1:IVideoInfoProvider)
      {
         super(param1);
         this.bufferScheduler = new Scheduler(10000);
         this.bufferScheduler.stop();
         this.bufferScheduler.addEventListener(SchedulerEvent.TICK,this.onTick);
         this.bufferScheduler.addEventListener(SchedulerEvent.END,this.onEnd);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         closeNetConnection(this.fallbackNetConnection);
      }
      
      override protected function playStream() : Boolean
      {
         var startTime:Number = NaN;
         try
         {
            startTime = Boolean(videoData.startSeconds) && videoData.format.isMp4 ? videoData.startSeconds : 0;
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
      
      protected function resetFallbackConn() : void
      {
         closeNetConnection(this.fallbackNetConnection);
         if(Boolean(videoData) && Boolean(videoData.format.fallbackConn))
         {
            this.fallbackNetConnection = new NetConnection();
            this.fallbackNetConnection.client = proxyNetClient;
            this.fallbackNetConnection.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
            this.fallbackNetConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onError);
            this.fallbackNetConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,onError);
            this.fallbackNetConnection.addEventListener(IOErrorEvent.IO_ERROR,onError);
         }
         if(this.fallbackNetConnection && videoData && Boolean(videoData.format.fallbackConn))
         {
            this.fallbackNetConnection.connect(videoData.format.fallbackConn);
         }
      }
      
      override public function onPlayStatus(param1:Object) : void
      {
         switch(param1.code)
         {
            case "NetStream.Play.Complete":
               dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS,getDuration(),getBytesLoaded(),getBytesTotal()));
               progressScheduler.stop();
               this.setPlayerState(new AkamaiRTMPEndedState(this));
         }
      }
      
      protected function onRequestLoadComplete(param1:Event) : void
      {
         var xml:XML = null;
         var ip:String = null;
         var url:Url = null;
         var event:Event = param1;
         if(this.serverIpRequestLoader)
         {
            this.serverIpRequestLoader.removeEventListener(Event.COMPLETE,this.onRequestLoadComplete);
            this.serverIpRequestLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onRequestLoadComplete);
            this.serverIpRequestLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onRequestLoadComplete);
         }
         if(!(event is ErrorEvent) && this.serverIpLoader && this.serverIpLoader.data)
         {
            try
            {
               xml = new XML(this.serverIpLoader.data);
               ip = xml.ip;
               if(ip)
               {
                  url = new Url(videoData.format.conn);
                  url.queryVars["_fcs_vhost"] = url.hostname;
                  url.queryVars["plid"] = videoData.playbackIdToken;
                  url.hostname = ip;
                  this.serverIp = ip;
                  videoData.format.conn = url.recombineUrl();
                  url.protocol = "rtmpte";
                  videoData.format.fallbackConn = url.recombineUrl();
                  videoData.format.idented = true;
               }
            }
            catch(error:Error)
            {
            }
         }
         super.resetStream();
         this.resetFallbackConn();
      }
      
      protected function onEnd(param1:SchedulerEvent) : void
      {
         this.setPlayerState(new ErrorState(this,new VideoErrorEvent(VideoErrorEvent.ERROR,"streamingerror")));
      }
      
      override protected function setPlayerState(param1:IPlayerState) : void
      {
         if(state is RTMPBufferingState)
         {
            this.bufferScheduler.stop();
         }
         super.setPlayerState(param1);
         if(state is RTMPBufferingState)
         {
            this.bufferScheduler.restart();
         }
      }
      
      override public function resetStream(param1:Boolean = true) : void
      {
         var _loc2_:Url = null;
         var _loc3_:URLRequest = null;
         if(!this.serverIpRequestLoader && videoData && !videoData.format.idented)
         {
            _loc2_ = new Url(videoData.format.conn);
            if(_loc2_)
            {
               _loc3_ = new URLRequest("http://" + _loc2_.hostname + "/fcs/ident");
               this.serverIpRequestLoader = new RequestLoader();
               this.serverIpRequestLoader.addEventListener(Event.COMPLETE,this.onRequestLoadComplete);
               this.serverIpRequestLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onRequestLoadComplete);
               this.serverIpRequestLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onRequestLoadComplete);
               this.serverIpLoader = this.serverIpRequestLoader.loadRequest(_loc3_);
            }
         }
         else
         {
            super.resetStream(param1);
            this.resetFallbackConn();
         }
      }
      
      override public function getLoggingOptions() : Object
      {
         var _loc1_:Object = super.getLoggingOptions();
         if(this.serverIp)
         {
            _loc1_.sip = this.serverIp;
         }
         return _loc1_;
      }
      
      override protected function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetConnection.Connect.Success":
               if(param1.target === netConnection)
               {
                  closeNetConnection(this.fallbackNetConnection);
                  break;
               }
               closeNetConnection(netConnection);
               netConnection = this.fallbackNetConnection;
               this.fallbackNetConnection = null;
         }
         super.onNetStatus(param1);
      }
      
      protected function onTick(param1:SchedulerEvent) : void
      {
         var _loc2_:Number = 0;
         if(Boolean(streamValue) && streamValue.time > 0)
         {
            _loc2_ = streamValue.time;
         }
         if(_loc2_ > 0)
         {
            if(_loc2_ < videoData.startSeconds)
            {
               seek(videoData.startSeconds);
               videoData.startSeconds = 0;
               this.bufferScheduler.stop();
            }
            else
            {
               this.setPlayerState(new PlayingState(this));
            }
         }
      }
   }
}

