package com.google.youtube.players
{
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.model.Environment;
   import com.google.youtube.util.getDefinition;
   import com.google.youtube.util.hasDefinition;
   import flash.events.Event;
   import flash.events.NetStatusEvent;
   import flash.geom.Rectangle;
   import flash.net.NetStream;
   
   public class AkamaiHDLiveVideoPlayer extends HTTPVideoPlayer implements IVideoAdAware
   {
      
      protected static const HDNETSTREAM_CLASSNAME:String = "com.akamai.hd.HDNetStream";
      
      protected static const HDEVENT_CLASSNAME:String = "com.akamai.hd.HDEvent";
      
      protected static const TOKEN_SERVICE_CLASSNAME:String = "com.google.youtube.modules.akamaihd.EdgeAuthTokenService";
      
      public static const SEEKSTATE_TIMEOUT:Number = 3000;
      
      public static const SEEKSTATE_INTERVAL:Number = 500;
      
      public static const HEAD_OF_STREAM:Number = -1;
      
      public static const UNLIMITED_DVR:Number = -1;
      
      protected var EdgeAuthTokenService:Class;
      
      protected var hdEventClassName:String;
      
      protected var lastKnownDuration:int = 0;
      
      protected var hdNetStreamClassName:String;
      
      protected var HDNetStream:Class;
      
      protected var edgeAuthTokenServiceClassName:String;
      
      protected var dvrWindow:Number = 0;
      
      protected var HDEvent:Class;
      
      public function AkamaiHDLiveVideoPlayer(param1:IVideoInfoProvider, param2:String = "com.akamai.hd.HDNetStream", param3:String = "com.akamai.hd.HDEvent", param4:String = "com.google.youtube.modules.akamaihd.EdgeAuthTokenService")
      {
         super(param1);
         this.hdNetStreamClassName = param2;
         this.hdEventClassName = param3;
         this.edgeAuthTokenServiceClassName = param4;
      }
      
      public static function isLoadable() : Boolean
      {
         return hasDefinition(HDNETSTREAM_CLASSNAME);
      }
      
      protected function onAkamaiDataMessage(param1:Object) : void
      {
         var event:Object = param1;
         if(Boolean(event) && Boolean(event.data))
         {
            try
            {
               dispatchCuePoint(event.data.value.name,event.data.value.time);
            }
            catch(e:Error)
            {
               Environment(videoUrlProviderValue).handleError(e);
            }
         }
      }
      
      override public function getVideoRect() : Rectangle
      {
         return new Rectangle(0,0,videoData.videoWidth,videoData.videoHeight);
      }
      
      override public function getTime() : Number
      {
         if(state is SeekingState && SeekingState(state).seekTime == HEAD_OF_STREAM)
         {
            return this.getDuration();
         }
         return super.getTime();
      }
      
      override protected function onNetStatus(param1:NetStatusEvent) : void
      {
         if(param1.info.code == "NetStream.Play.StreamNotFound")
         {
            handleCDNRetry();
            return;
         }
         super.onNetStatus(param1);
      }
      
      override public function getDuration() : Number
      {
         if(Boolean(this.dvrWindow) && this.dvrWindow != UNLIMITED_DVR)
         {
            return this.dvrWindow;
         }
         if(Boolean(streamValue) && Boolean(streamValue.hasOwnProperty("duration")))
         {
            return Object(streamValue).duration;
         }
         return super.getDuration();
      }
      
      override public function destroy() : void
      {
         if(streamValue)
         {
            streamValue.removeEventListener(this.HDEvent.DATA_MESSAGE,this.onAkamaiDataMessage);
            streamValue.removeEventListener(this.HDEvent.DVR_WINDOW,this.onDvrWindow);
            streamValue.removeEventListener(this.HDEvent.DVR_WINDOW_CLOSED,this.onDvrWindowClosed);
         }
         super.destroy();
      }
      
      override public function getLoadedFraction() : Number
      {
         if(this.dvrWindow && streamValue && Boolean(streamValue.hasOwnProperty("duration")))
         {
            return Math.min(this.dvrWindow,Object(streamValue).duration) / this.dvrWindow;
         }
         return super.getLoadedFraction();
      }
      
      public function onAdBreakEnd() : void
      {
         this.seek(HEAD_OF_STREAM);
      }
      
      override protected function connectStream() : void
      {
         if(!this.initHDCoreLibrary())
         {
            setPlayerState(new UnrecoverableErrorState(this,new VideoErrorEvent(VideoErrorEvent.ERROR)));
            return;
         }
         super.connectStream();
         if(streamValue.hasOwnProperty("resumeDVRAtLive"))
         {
            Object(streamValue).resumeDVRAtLive = false;
         }
         streamValue.addEventListener(this.HDEvent.DATA_MESSAGE,this.onAkamaiDataMessage);
         streamValue.addEventListener(this.HDEvent.DVR_WINDOW,this.onDvrWindow);
         streamValue.addEventListener(this.HDEvent.DVR_WINDOW_CLOSED,this.onDvrWindowClosed);
      }
      
      public function onAdBreakStart() : void
      {
      }
      
      public function onDvrWindow(param1:Event) : void
      {
         if(this.HDEvent(param1).data != 0)
         {
            this.dvrWindow = this.HDEvent(param1).data;
         }
      }
      
      public function onDvrWindowClosed(param1:Event) : void
      {
         if(streamValue)
         {
            streamValue.seek(0);
            setPlayerState(new SeekingState(this,0));
         }
      }
      
      private function initHDCoreLibrary() : Boolean
      {
         if(!this.HDEvent || !this.HDNetStream || !this.EdgeAuthTokenService)
         {
            if(hasDefinition(this.hdEventClassName))
            {
               this.HDEvent = getDefinition(this.hdEventClassName) as Class;
            }
            if(hasDefinition(this.hdNetStreamClassName))
            {
               this.HDNetStream = getDefinition(this.hdNetStreamClassName) as Class;
            }
            if(hasDefinition(this.edgeAuthTokenServiceClassName))
            {
               this.EdgeAuthTokenService = getDefinition(this.edgeAuthTokenServiceClassName) as Class;
            }
         }
         return Boolean(this.HDEvent) && Boolean(this.HDNetStream) && Boolean(this.EdgeAuthTokenService);
      }
      
      override public function seek(param1:Number, param2:Boolean = true) : void
      {
         if(param1 == Infinity)
         {
            param1 = HEAD_OF_STREAM;
         }
         if(streamValue)
         {
            if(state is SeekingState)
            {
               setPlayerState(state.seek(param1,param2));
               return;
            }
            streamValue.seek(param1);
            setPlayerState(new SeekingState(this,param1,param2));
            videoData.startSeconds = 0;
         }
      }
      
      override public function getNewNetStream() : NetStream
      {
         var _loc1_:NetStream = new this.HDNetStream(netConnection);
         Object(_loc1_).tokenService = new this.EdgeAuthTokenService(videoData.videoId,videoData.cdnListIndex);
         Object(_loc1_).displayObject = stage;
         return _loc1_;
      }
      
      override internal function setStream(param1:NetStream) : void
      {
         super.setStream(param1);
         this.initHDCoreLibrary();
         if(streamValue.hasOwnProperty("resumeDVRAtLive"))
         {
            Object(streamValue).resumeDVRAtLive = false;
         }
         streamValue.addEventListener(this.HDEvent.DATA_MESSAGE,this.onAkamaiDataMessage);
         streamValue.addEventListener(this.HDEvent.DVR_WINDOW,this.onDvrWindow);
         streamValue.addEventListener(this.HDEvent.DVR_WINDOW_CLOSED,this.onDvrWindowClosed);
      }
   }
}

