package com.google.youtube.players
{
   import com.google.utils.PlayerVersion;
   import com.google.utils.RequestVariables;
   import com.google.utils.SafeLoader;
   import com.google.youtube.event.AdEvent;
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.event.LogEvent;
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.model.FailureReport;
   import com.google.youtube.model.VideoControlType;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.ui.Interstitial;
   import com.google.youtube.ui.drawing;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   
   public class PlayerAdapter extends BaseVideoPlayer implements IVideoAdEventProvider
   {
      
      public static const GUEST_PLAYER_ERROR:String = "GUEST_PLAYER_ERROR";
      
      protected static var DEFAULT_VIDEO_WIDTH:Number = 480;
      
      protected static var DEFAULT_VIDEO_HEIGHT:Number = 360;
      
      protected static var SEEK_TOLERANCE:Number = PROGRESS_INTERVAL / 1000;
      
      protected var contentHeight:int = 360;
      
      protected var AD_TYPE_NONE:Number = 0;
      
      protected var API_GET_AD_TYPE:String = "getAdType";
      
      protected var EVENT_VIDEO_LOADED:String = "EVENT_VIDEO_LOADED";
      
      protected var loader:Loader;
      
      protected var EVENT_AD_STATE_CHANGE:String = "EVENT_AD_STATE_CHANGE";
      
      protected var API_SET_VOLUME:String = "setVolume";
      
      protected var AD_STATE_PLAYING:Number = 2;
      
      protected var EVENT_PLAYER_LOADED:String = "EVENT_PLAYER_LOADED";
      
      protected var interstitial:Interstitial;
      
      protected var API_HAS_AD_UI:String = "hasAdUI";
      
      protected var background:Sprite = new Sprite();
      
      protected var EVENT_LOAD_ERROR:String = "EVENT_LOAD_ERROR";
      
      protected var AD_TYPE_INSTREAM:Number = 2;
      
      protected var PLAYER_STATE_ERROR:Number = 6;
      
      protected var API_IS_AD_PLAY_CONTROLLABLE:String = "isAdPlayControllable";
      
      protected var API_PAUSE:String = "pause";
      
      protected var API_PLAY:String = "play";
      
      protected var PLAYER_STATE_PAUSED:Number = 4;
      
      protected var AD_STATE_PAUSED:Number = 4;
      
      protected var API_GET_AD_INSERTION_POINTS:String = "getAdInsertionPoints";
      
      protected var PLAYER_STATE_PLAYING:Number = 2;
      
      protected var API_GET_AD_STATE:String = "getAdState";
      
      protected var API_AD_PAUSE:String = "adPause";
      
      protected var API_GET_AD_DURATION:String = "getAdDuration";
      
      protected var PLAYER_STATE_LOADING:Number = 0;
      
      protected var API_GET_BYTES_TOTAL:String = "getBytesTotal";
      
      protected var API_REMOVE_EVENT_LISTENER:String = "removeGuestPlayerEventListener";
      
      protected var content:Object;
      
      protected var AD_STATE_ERROR:Number = 6;
      
      protected var API_SET_SIZE:String = "setSize";
      
      protected var API_GET_BYTES_LOADED:String = "getBytesLoaded";
      
      protected var API_AD_PLAY:String = "adPlay";
      
      protected var storedPlayerState:IPlayerState;
      
      protected var EVENT_PLAYHEAD_UPDATE:String = "EVENT_PLAYHEAD_UPDATE";
      
      protected var API_LOAD_MEDIA:String = "loadMedia";
      
      protected var API_GET_AD_TIME:String = "getAdTime";
      
      protected var API_GET_AD_DISPLAY_STRING:String = "getAdDisplayString";
      
      protected var API_SEEK:String = "seek";
      
      protected var PLAYER_STATE_SEEKING:Number = 3;
      
      protected var API_GET_PLAYER_STATE:String = "getPlayerState";
      
      protected var API_GET_DURATION:String = "getDuration";
      
      protected var API_CLEAR:String = "clear";
      
      protected var API_GET_VOLUME:String = "getVolume";
      
      protected var PLAYER_STATE_COMPLETED:Number = 5;
      
      protected var EVENT_IO_ERROR:String = "EVENT_IO_ERROR";
      
      protected var API_ADD_EVENT_LISTENER:String = "addGuestPlayerEventListener";
      
      protected var AD_STATE_COMPLETED:Number = 5;
      
      protected var AD_STATE_EMPTY:Number = 0;
      
      protected var AD_TYPE_OVERLAY:Number = 1;
      
      protected var contentWidth:int = 640;
      
      protected var PLAYER_STATE_BUFFERING:Number = 1;
      
      protected var API_GET_TIME:String = "getTime";
      
      protected var EVENT_STATE_CHANGE:String = "EVENT_STATE_CHANGE";
      
      public function PlayerAdapter(param1:IVideoUrlProvider)
      {
         super(param1);
         this.setPlayerState(new InterstitialState(this));
         addChild(this.background);
         this.applyStateAndEventNameOverrides();
      }
      
      override public function onInterstitialComplete(param1:Event) : void
      {
         super.onInterstitialComplete(param1);
         this.setPlayerState(new GuestPlayerState(this));
         this.play(videoData);
         if(this.interstitial)
         {
            this.interstitial.removeEventListener(Event.COMPLETE,this.onInterstitialComplete);
            this.interstitial.removeEventListener(Event.RESIZE,this.alignInterstitial);
            if(contains(this.interstitial))
            {
               removeChild(this.interstitial);
            }
         }
         dispatchEvent(new AdEvent(AdEvent.END));
         dispatchEvent(new AdEvent(AdEvent.BREAK_END));
      }
      
      override public function stop() : void
      {
         super.stop();
         this.setPlayerState(new GuestPlayerState(this));
         this.guardedApiCall(this.API_CLEAR);
      }
      
      override public function getDuration() : Number
      {
         return this.guardedApiRequest(this.API_GET_DURATION,super.getDuration());
      }
      
      protected function guestGetPlayerState(param1:Object) : Number
      {
         return this.guardedApiRequest(this.API_GET_PLAYER_STATE);
      }
      
      override public function getVolume() : Number
      {
         return this.guardedApiRequest(this.API_GET_VOLUME,super.getVolume());
      }
      
      protected function onVideoLoaded(param1:Event) : void
      {
         this.resizeGuestPlayer();
         this.guardedApiCall(this.API_SET_VOLUME,volume);
         this.executePlay();
      }
      
      public function executePlay() : void
      {
         this.guardedApiCall(this.API_PLAY);
      }
      
      protected function onLoaderProgress(param1:Event) : void
      {
      }
      
      override public function getBytesLoaded() : Number
      {
         return Math.max(this.guardedApiRequest(this.API_GET_BYTES_LOADED,super.getBytesLoaded()),0);
      }
      
      protected function onLoaderComplete(param1:Event) : void
      {
         this.content = this.loader.content;
         progressScheduler.restart();
         this.content.x = this.background.x;
         this.content.y = this.background.y;
         this.resizeGuestPlayer();
         this.addEventListeners();
      }
      
      override protected function setDisplayRect(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         super.setDisplayRect(param1,param2,param3,param4);
         drawing(this.background.graphics).clear().fill(0).rect(0,0,param3,param4).end();
         x = param1;
         y = param2;
         this.contentWidth = param3;
         this.contentHeight = param4;
         this.alignInterstitial();
         this.resizeGuestPlayer();
      }
      
      protected function guardedApiRequest(param1:String, param2:* = null, ... rest) : *
      {
         var method:String = param1;
         var defaultValue:* = param2;
         var args:Array = rest;
         if(Boolean(this.content) && method in this.content)
         {
            try
            {
               return this.content[method].apply(this.content,args);
            }
            catch(error:Error)
            {
               setErrorCode(error.name);
            }
         }
         return defaultValue;
      }
      
      override public function play(param1:VideoData = null) : void
      {
         super.play(param1);
         if(param1)
         {
            videoData.applyMetaData({
               "width":this.contentWidth,
               "height":this.contentHeight
            });
            dispatchEvent(new LogEvent(LogEvent.PLAYBACK,LogEvent.PLAYBACK));
         }
      }
      
      override public function setVolume(param1:Number) : void
      {
         super.setVolume(param1);
         this.guardedApiCall(this.API_SET_VOLUME,volume);
      }
      
      protected function guestAddEventListener(param1:String, param2:Function) : void
      {
         this.guardedApiCall(this.API_ADD_EVENT_LISTENER,param1,param2);
      }
      
      protected function verifyVideoDataConditions() : Boolean
      {
         return videoData.isDataReady();
      }
      
      override public function getTime() : Number
      {
         var _loc1_:Number = NaN;
         if(state is IEndedState)
         {
            _loc1_ = this.getDuration();
         }
         else
         {
            _loc1_ = this.guardedApiRequest(this.API_GET_TIME,super.getTime());
         }
         return _loc1_;
      }
      
      protected function onStateChange(param1:Event) : void
      {
         switch(this.guestGetPlayerState(param1))
         {
            case this.PLAYER_STATE_BUFFERING:
               this.setPlayerState(new GuestBufferingState(this));
               break;
            case this.PLAYER_STATE_PLAYING:
               this.setPlayerState(new GuestPlayingState(this));
               break;
            case this.PLAYER_STATE_PAUSED:
               this.setPlayerState(new GuestPausedState(this));
               break;
            case this.PLAYER_STATE_COMPLETED:
               this.setPlayerState(new GuestEndedState(this));
         }
      }
      
      protected function guestRemoveEventListener(param1:String, param2:Function) : void
      {
         this.guardedApiCall(this.API_REMOVE_EVENT_LISTENER,param1,param2);
      }
      
      protected function setAdState(param1:IPlayerState) : void
      {
         if(!this.storedPlayerState)
         {
            this.storedPlayerState = state;
         }
         else if(param1 == this.storedPlayerState)
         {
            this.storedPlayerState = null;
         }
         this.setPlayerState(param1);
      }
      
      override protected function setPlayerState(param1:IPlayerState) : void
      {
         if(param1)
         {
            super.setPlayerState(param1);
         }
      }
      
      public function getHasAdUI() : Boolean
      {
         return state is BaseAdPlayerState ? this.guardedApiRequest(this.API_HAS_AD_UI,true) : true;
      }
      
      protected function removeEventListeners() : void
      {
         this.guestRemoveEventListener(this.EVENT_VIDEO_LOADED,this.onVideoLoaded);
         this.guestRemoveEventListener(this.EVENT_PLAYHEAD_UPDATE,onProgress);
         this.guestRemoveEventListener(this.EVENT_STATE_CHANGE,this.onStateChange);
         this.guestRemoveEventListener(this.EVENT_AD_STATE_CHANGE,this.onAdStateChange);
         this.guestRemoveEventListener(this.EVENT_LOAD_ERROR,this.onError);
         this.guestRemoveEventListener(this.EVENT_IO_ERROR,this.onError);
         this.guestRemoveEventListener(this.EVENT_PLAYER_LOADED,this.onPlayerReady);
      }
      
      protected function onNewVideoData(param1:GetVideoInfoEvent) : void
      {
         videoUrlProvider.applyGetVideoInfo(param1.data);
         videoData.videoUrl = videoUrlProvider.getVideoUrl(videoData);
         this.setPlayerState(state.onNewVideoData(param1));
      }
      
      protected function resizeGuestPlayer() : void
      {
         this.guardedApiCall(this.API_SET_SIZE,this.contentWidth,this.contentHeight);
      }
      
      public function executePause() : void
      {
         this.guardedApiCall(this.API_PAUSE);
      }
      
      override public function setVideoData(param1:VideoData) : void
      {
         if(videoData != param1)
         {
            if(videoData)
            {
               videoData.removeEventListener(GetVideoInfoEvent.INFO,this.onNewVideoData);
               videoData.removeEventListener(VideoErrorEvent.ERROR,this.onNewVideoDataError);
            }
            if(param1)
            {
               param1.addEventListener(GetVideoInfoEvent.INFO,this.onNewVideoData);
               param1.addEventListener(VideoErrorEvent.ERROR,this.onNewVideoDataError);
            }
            super.setVideoData(param1);
         }
      }
      
      public function adPause() : void
      {
         this.guardedApiCall(this.API_AD_PAUSE);
      }
      
      public function executeSeek(param1:Number) : void
      {
         this.guardedApiCall(this.API_SEEK,param1);
      }
      
      public function getAdTime() : Number
      {
         return this.guardedApiRequest(this.API_GET_AD_TIME,NaN);
      }
      
      protected function applyStateAndEventNameOverrides() : void
      {
      }
      
      override public function getBytesTotal() : Number
      {
         return this.guardedApiRequest(this.API_GET_BYTES_TOTAL,super.getBytesTotal());
      }
      
      public function getAdTimes() : Array
      {
         return this.guardedApiRequest(this.API_GET_AD_INSERTION_POINTS,[]);
      }
      
      protected function onError(param1:Event) : void
      {
         switch(param1.type)
         {
            case this.EVENT_LOAD_ERROR:
            case this.EVENT_IO_ERROR:
               this.onNewVideoDataError(new ErrorEvent(GUEST_PLAYER_ERROR));
               break;
            default:
               this.setErrorCode(param1.type);
         }
      }
      
      public function getVideoId() : String
      {
         return videoData ? videoData.videoId : null;
      }
      
      override public function showInterstitial() : Boolean
      {
         var _loc1_:URLRequest = null;
         if(Boolean(videoData) && Boolean(videoData.interstitial))
         {
            if(!this.interstitial)
            {
               _loc1_ = new URLRequest(videoData.interstitial);
               this.interstitial = new Interstitial(_loc1_,4000);
               this.interstitial.addEventListener(Event.COMPLETE,this.onInterstitialComplete);
               this.interstitial.addEventListener(Event.RESIZE,this.alignInterstitial);
            }
            addChild(this.interstitial);
            this.interstitial.load();
            dispatchEvent(new AdEvent(AdEvent.BREAK_START,{"slots":1}));
            dispatchEvent(new AdEvent(AdEvent.PLAY,{"nolog":true}));
            return true;
         }
         return super.showInterstitial();
      }
      
      public function onAdClose() : void
      {
      }
      
      protected function alignInterstitial(param1:Event = null) : void
      {
         if(this.interstitial)
         {
            this.interstitial.x = (this.contentWidth - this.interstitial.width) / 2;
            this.interstitial.y = (this.contentHeight - this.interstitial.height) / 2;
         }
      }
      
      override public function initiatePlayback() : void
      {
         var _loc1_:URLRequest = null;
         if(state is InterstitialState)
         {
            return;
         }
         super.initiatePlayback();
         if(this.verifyVideoDataConditions())
         {
            if(this.loader is Loader)
            {
               this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoaderComplete);
               this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onNewVideoDataError);
               this.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onLoaderProgress);
               this.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onNewVideoDataError);
            }
            this.loader = new SafeLoader();
            this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaderComplete);
            this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onNewVideoDataError);
            this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onLoaderProgress);
            this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onNewVideoDataError);
            _loc1_ = videoUrlProvider.getVideoUrlRequest(videoData);
            this.loader.load(_loc1_);
         }
         else
         {
            _loc1_ = videoUrlProvider.getVideoInfoRequest(videoData);
            videoData.getVideoInfo(_loc1_);
         }
         if(Boolean(this.loader) && !contains(this.loader))
         {
            addChild(this.loader);
         }
      }
      
      public function getAdDisplayString() : String
      {
         return this.guardedApiRequest(this.API_GET_AD_DISPLAY_STRING,"");
      }
      
      public function getAdDuration() : Number
      {
         return this.guardedApiRequest(this.API_GET_AD_DURATION,NaN);
      }
      
      protected function onAdStateChange(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:* = false;
         var _loc4_:Object = null;
         var _loc5_:RequestVariables = null;
         _loc2_ = this.getAdType();
         switch(this.guestGetAdState(param1))
         {
            case this.AD_STATE_PLAYING:
               _loc3_ = _loc2_ == this.AD_TYPE_INSTREAM;
               _loc4_ = {};
               if(_loc2_ == this.AD_TYPE_INSTREAM)
               {
                  this.setAdState(new AdPlayingState(this));
                  _loc4_[VideoControlType.FULLSCREEN] = true;
                  _loc4_[VideoControlType.VOLUME] = true;
                  if(this.isAdPlayControllable())
                  {
                     _loc4_[VideoControlType.PAUSE] = true;
                  }
                  dispatchEvent(new AdEvent(AdEvent.BREAK_START,{
                     "slots":1,
                     "except":_loc4_
                  }));
               }
               dispatchEvent(new AdEvent(AdEvent.PLAY,{
                  "aft":new Date(),
                  "disable":_loc3_,
                  "except":_loc4_
               }));
               break;
            case this.AD_STATE_PAUSED:
               if(state is BaseAdPlayerState)
               {
                  this.setAdState(new AdPausedState(this));
               }
               dispatchEvent(new AdEvent(AdEvent.PAUSE));
               break;
            case this.AD_STATE_ERROR:
               _loc5_ = new RequestVariables();
               _loc5_.ec = FailureReport.GUEST_PLAYER_AD_FAIL_ERROR_CODE;
               dispatchEvent(new LogEvent(LogEvent.LOG,"aderror",_loc5_));
            case this.AD_STATE_COMPLETED:
               dispatchEvent(new AdEvent(AdEvent.END));
               if(_loc2_ == this.AD_TYPE_INSTREAM)
               {
                  dispatchEvent(new AdEvent(AdEvent.BREAK_END));
               }
               this.setAdState(this.storedPlayerState);
         }
      }
      
      protected function setErrorCode(param1:String) : void
      {
         if(videoData)
         {
            videoData.setErrorCode(param1);
         }
      }
      
      protected function onNewVideoDataError(param1:ErrorEvent) : void
      {
         this.setErrorCode(param1.type);
         this.setPlayerState(state.onNewVideoDataError(param1));
      }
      
      protected function addEventListeners() : void
      {
         this.guestAddEventListener(this.EVENT_VIDEO_LOADED,this.onVideoLoaded);
         this.guestAddEventListener(this.EVENT_PLAYHEAD_UPDATE,onProgress);
         this.guestAddEventListener(this.EVENT_STATE_CHANGE,this.onStateChange);
         this.guestAddEventListener(this.EVENT_AD_STATE_CHANGE,this.onAdStateChange);
         this.guestAddEventListener(this.EVENT_LOAD_ERROR,this.onError);
         this.guestAddEventListener(this.EVENT_IO_ERROR,this.onError);
         this.guestAddEventListener(this.EVENT_PLAYER_LOADED,this.onPlayerReady);
      }
      
      protected function onPlayerReady(param1:Event) : void
      {
         this.guardedApiCall(this.API_LOAD_MEDIA,videoData.mediaId);
      }
      
      protected function guestGetAdState(param1:Object) : Number
      {
         return this.guardedApiRequest(this.API_GET_AD_STATE);
      }
      
      public function isAdPlayControllable() : Boolean
      {
         return this.guardedApiRequest(this.API_IS_AD_PLAY_CONTROLLABLE,false);
      }
      
      protected function getAdType() : Number
      {
         return this.guardedApiRequest(this.API_GET_AD_TYPE,this.AD_TYPE_NONE);
      }
      
      protected function guardedApiCall(param1:String, ... rest) : void
      {
         var method:String = param1;
         var args:Array = rest;
         if(Boolean(this.content) && method in this.content)
         {
            try
            {
               this.content[method].apply(this.content,args);
            }
            catch(error:Error)
            {
               setErrorCode(error.name);
            }
         }
      }
      
      public function adPlay() : void
      {
         this.guardedApiCall(this.API_AD_PLAY);
      }
      
      override public function destroy() : void
      {
         if(this.content)
         {
            try
            {
               if(PlayerVersion.isAtLeastVersion(10))
               {
                  this.loader.unloadAndStop();
               }
               else
               {
                  this.loader.unload();
               }
               if(contains(this.loader))
               {
                  removeChild(this.loader);
               }
               this.removeEventListeners();
               this.content = null;
               this.loader = null;
            }
            catch(error:Error)
            {
               setErrorCode(error.name);
            }
         }
         super.destroy();
      }
   }
}

