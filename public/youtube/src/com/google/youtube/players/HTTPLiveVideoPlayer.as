package com.google.youtube.players
{
   import com.google.utils.Scheduler;
   import com.google.youtube.model.VideoData;
   import flash.events.Event;
   import flash.events.NetStatusEvent;
   
   public class HTTPLiveVideoPlayer extends HTTPVideoPlayer implements IVideoAdAware
   {
      
      protected var endScheduler:Scheduler;
      
      protected var startScheduler:Scheduler;
      
      public function HTTPLiveVideoPlayer(param1:IVideoInfoProvider)
      {
         super(param1);
         this.endScheduler = Scheduler.setInterval(6000,this.onRetryTimeout);
         this.endScheduler.stop();
         this.startScheduler = Scheduler.setInterval(6000,this.onActiveButEmptyTimeout);
         this.startScheduler.stop();
      }
      
      override public function onPlayStatus(param1:Object) : void
      {
         this.endScheduler.stop();
         super.onPlayStatus(param1);
      }
      
      override public function seek(param1:Number, param2:Boolean = true) : void
      {
         var _loc3_:VideoData = videoData;
         videoData = null;
         play(_loc3_);
      }
      
      override protected function onNetStatus(param1:NetStatusEvent) : void
      {
         this.endScheduler.stop();
         if(param1.info.code == "NetConnection.Connect.Success")
         {
            this.startScheduler.restart();
         }
         else
         {
            this.startScheduler.stop();
         }
         if(param1.info.code == "NetStream.Buffer.Empty")
         {
            bufferEmptyStart = new Date();
         }
         else if(param1.info.code != "NetStream.Buffer.Flush" && param1.info.code != "NetStream.Play.Stop")
         {
            bufferEmptyStart = null;
         }
         if(param1.info.code == "NetStream.Play.StreamNotFound")
         {
            handleCDNRetry();
            return;
         }
         super.onNetStatus(param1);
      }
      
      public function onAdBreakStart() : void
      {
         disconnectStream();
      }
      
      override protected function setPlayerState(param1:IPlayerState) : void
      {
         super.setPlayerState(param1);
         if(state is IPlayingState || state is ErrorState || state is EndedState)
         {
            this.startScheduler.stop();
            this.endScheduler.stop();
         }
      }
      
      override public function getBytesTotal() : Number
      {
         return super.getBytesLoaded();
      }
      
      override protected function isEnded() : Boolean
      {
         if(Boolean(bufferEmptyStart) && new Date().valueOf() - bufferEmptyStart.valueOf() > 10000)
         {
            if(!this.endScheduler.isRunning())
            {
               this.endScheduler.restart();
               retryCount = RETRY_LIMIT - 1;
            }
         }
         return false;
      }
      
      protected function onActiveButEmptyTimeout(param1:Event = null) : void
      {
         this.startScheduler.restart();
         handleCDNRetry();
      }
      
      override public function destroy() : void
      {
         this.startScheduler.stop();
         this.endScheduler.stop();
         super.destroy();
      }
      
      override protected function isValidBufferEmpty() : Boolean
      {
         return true;
      }
      
      public function onAdBreakEnd() : void
      {
         play(getVideoData());
      }
      
      protected function onRetryTimeout(param1:Event = null) : void
      {
         this.endScheduler.stop();
         progressScheduler.stop();
         if(videoData && videoData.cdnList.length && videoData.cdnListIndex == 0)
         {
            onCDNFailover();
         }
         else
         {
            this.setPlayerState(new EndedState(this));
         }
      }
   }
}

