package com.google.youtube.model
{
   import com.google.utils.RequestLoader;
   import com.google.utils.RequestVariables;
   import com.google.utils.Scheduler;
   import com.google.utils.StringUtils;
   import com.google.utils.Url;
   import com.google.youtube.event.GetVideoInfoEvent;
   import com.google.youtube.event.SubscriptionEvent;
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.modules.ad.AdModuleDescriptor;
   import com.google.youtube.modules.akamaihd.AkamaiHdModuleDescriptor;
   import com.google.youtube.modules.enhance.EnhanceModuleDescriptor;
   import com.google.youtube.modules.flashaccess.FlashAccessModuleDescriptor;
   import com.google.youtube.modules.fresca.FrescaModuleDescriptor;
   import com.google.youtube.modules.multicamera.MultiCameraModuleDescriptor;
   import com.google.youtube.modules.ratings.RatingsModuleDescriptor;
   import com.google.youtube.modules.streaminglib.StreamingLibModuleDescriptor;
   import com.google.youtube.modules.threed.ThreeDModuleDescriptor;
   import com.google.youtube.modules.ypc.YpcLicenseCheckerModuleDescriptor;
   import com.google.youtube.modules.ypc.YpcModuleDescriptor;
   import com.google.youtube.modules.yva.YvaModuleDescriptor;
   import com.google.youtube.players.PlayerType;
   import com.google.youtube.util.SignatureDecipher;
   import com.google.youtube.util.UrlValidator;
   import com.google.youtube.util.dash.LiveMpdParser;
   import com.google.youtube.util.dash.MpdParser;
   import com.google.youtube.util.hls.HlsParser;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.geom.Rectangle;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.utils.getTimer;
   
   public class VideoData extends EventDispatcher
   {
      
      public static const AUTO_CROP:int = -1;
      
      protected static const BASE_64:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + "abcdefghijklmnopqrstuvwxyz" + "0123456789-_";
      
      private static const DEFAULT_THUMBNAIL_URL:String = "http://i.ytimg.com/vi/default.jpg";
      
      private static const VIDEO_TOKEN_TIMEOUT:Number = 18000000;
      
      private static const STREAM_AUTH_TIMEOUT:Number = 280000;
      
      private static const MACHINE_TAG_REGEX:RegExp = /^([a-zA-A0-9]*\:[a-zA-A0-9]*)=(.*)$/;
      
      private static const YOUTUBE_LOGO_REGEX:RegExp = /\/img\/watermark\/youtube_(hd_)?watermark(-vfl\S{6})?.png$/;
      
      private static const LEGACY_YOUTUBE_LOGO_REGEX:RegExp = /\/swf\/(hd)?logo(-vfl(\d{7,15}|\S{6}))?.swf$/;
      
      protected static const ALL_VIDEOS:Object = {};
      
      public static const LIVE_EVENT_EXTEND_FACTOR:Number = 1.2;
      
      public static const CONVERSION_VIEW:String = "view";
      
      public static const CONVERSION_LIKE:String = "like";
      
      public static const CONVERSION_DISLIKE:String = "dislike";
      
      public static const CONVERSION_ADVIEW:String = "adview";
      
      public static const ADVERTISER_EVENT_IMPRESSION:String = "part2viewed";
      
      public static const ADVERTISER_EVENT_PROGRESS_25:String = "videoplaytime25";
      
      public static const ADVERTISER_EVENT_PROGRESS_50:String = "videoplaytime50";
      
      public static const ADVERTISER_EVENT_PROGRESS_75:String = "videoplaytime75";
      
      public static const ADVERTISER_EVENT_COMPLETE:String = "videoplaytime100";
      
      public static const ADVERTISER_EVENT_ENGAGED_VIEW:String = "adview";
      
      public static const ADVERTISER_EVENT_FOLLOW_ON_VIEW:String = "conversionview";
      
      public static const ADVERTISER_VIDEO_VIEW:String = "ADVERTISER_VIDEO_VIEW";
      
      public static const DEFAULT_MUFFLE:Number = 1;
      
      public static const LOUDNESS_TARGET_DECIBELS:Number = -18;
      
      public static const LOUDNESS_CUTOFF_DECIBELS:Number = -15;
      
      public var partnerId:String = "";
      
      protected var subtitlesModuleValue:String = "";
      
      protected var authKeyValue:String = "";
      
      protected var videoIdValue:String = "";
      
      protected var threeDModuleValue:String = "";
      
      public var adaptiveByDefault:Boolean = false;
      
      public var oobVouchers:Boolean;
      
      protected var playbackIdTokenValue:String = "";
      
      protected var initialDetailedPingJitter:Number = 0;
      
      protected var metaDataLoaded:Boolean = false;
      
      public var threeDEnabledValue:Boolean = false;
      
      protected var durationValue:Number = 0;
      
      public var isHlsLiveOnly:Boolean = false;
      
      protected var isMp4Value:Boolean = false;
      
      protected var promotedVideoProgress25BeaconUrlValue:String;
      
      protected var isHlsVariantPlaylist:Boolean = false;
      
      protected var maxresImageUrlValue:String = "";
      
      public var threeDLayoutPreview:int = 0;
      
      protected var sourceIdValue:String = "";
      
      public var ratingsModule:String = "";
      
      protected var playlistLoader:RequestLoader;
      
      public var clientPlaybackNonce:String = "";
      
      public var muffleFactor:Number = 1;
      
      protected var mediaIdValue:String = "";
      
      protected var partnerTrackingPlaybackTypeValue:String = "";
      
      protected var keyframesValue:Object;
      
      public var isGetVideoLoggable:Boolean = true;
      
      protected var hasStereo3DFormats:Boolean = false;
      
      protected var watermarkHdValue:String = "";
      
      protected var infringeValue:Boolean = false;
      
      public var skipKansasLoggingValue:Boolean = false;
      
      protected var sdImageUrlValue:String = "";
      
      public var playerDefaultVideoIdsToHtml5:Number = -1;
      
      public var checkPolicyFile:Boolean = false;
      
      public var flashAccessModule:String = "";
      
      public var userSubscribedToChannel:String = "";
      
      protected var trackingTokenValue:String = "";
      
      public var allowEmbed:Boolean = true;
      
      protected var setAwesomeLoader:RequestLoader;
      
      protected var videoHeightValue:Number = 240;
      
      public var cdnListIndex:Number = 0;
      
      public var isLive:Boolean = false;
      
      protected var formatListValue:Array = [];
      
      public var mosaicLoader:MosaicLoader;
      
      public var claimedEmbedVideo:Boolean = false;
      
      protected var dateUrlSigned:Date;
      
      protected var promotedVideoImpressionBeaconUrlValue:String;
      
      protected var suppressShareValue:Boolean = false;
      
      public var requiresPlayerSizeValidation:Boolean = false;
      
      protected var longDetailedPingJitter:Number = 0;
      
      public var url:String = "";
      
      protected var rawVideoInfoValue:URLVariables = new URLVariables();
      
      public var userGoalsModule:String = "";
      
      public var autoPlay:Boolean;
      
      public var author:String = "";
      
      protected var isAdvertiserVideoValue:Boolean = false;
      
      protected var isRealTimeLoggable:Boolean = false;
      
      public var isDoubleclickTracked:Boolean = false;
      
      public var oauthToken:String;
      
      protected var interstitialValue:String = "";
      
      public var brandedSmallBannerImageLink:String = "";
      
      protected var promotedVideoProgress75BeaconUrlValue:String;
      
      public var isGetVideoInfoLoaded:Boolean = false;
      
      protected var watermarkUrlValue:String = "";
      
      protected var multiCameraModuleValue:String = "";
      
      protected var flvUrlValue:String = "";
      
      protected var ratingValue:Number = 0;
      
      public var subscribeRequest:URLRequest;
      
      public var videoStoryboard:VideoStoryboard;
      
      public var externalUserId:String = "";
      
      protected var titleValue:String = "";
      
      public var ypcPreview:Boolean = false;
      
      public var conversionViewPingThreshold:Number = 0;
      
      public var brandedSmallBannerImageUrl:String = "";
      
      protected var requiresTimeOffsetValue:Boolean = false;
      
      protected var sourceDataValue:String = "";
      
      protected var videoBitrateValue:Number = 0;
      
      protected var viewCountValue:String = "";
      
      public var sentCardioPlayback:Boolean = false;
      
      protected var totalBytesValue:Number = 0;
      
      protected var pingMessage:String = "";
      
      public var isSlateShowing:Boolean = false;
      
      public var playlistUrl:String;
      
      protected var videoWidthValue:Number = 320;
      
      protected var adModuleValue:String = "";
      
      protected var streamingTextModuleValue:String = "";
      
      protected var promotedVideoCompleteBeaconUrlValue:String;
      
      protected var authTimeoutValue:Number;
      
      protected var errorCodeValue:String = "";
      
      public var brandedPlaylist:String = "";
      
      public var finskyToken:String = "";
      
      public var cdnList:Array = [];
      
      protected var httpHostHeaderValue:String = "";
      
      public var cropOverride:Number;
      
      public var unsubscribeRequest:URLRequest;
      
      protected var partnerTrackingChannelTokenValue:String = "";
      
      public var sdetail:String = "";
      
      protected var partnerTrackingOidValue:String = "";
      
      protected var thirdPartyFlvUrlValue:String = "";
      
      protected var ypcModuleValue:String = "";
      
      protected var promotedVideoBillableUrlValue:String;
      
      protected var pingUrl:String = "";
      
      public var sentConversionViewPing:Boolean = false;
      
      public var cuedClickToPlay:Boolean;
      
      protected var promotedVideoProgress50BeaconUrlValue:String;
      
      public var enableCardioBeforePlayback:Boolean = false;
      
      public var numberOfWatchTimePingsSent:Number = 0;
      
      protected var ypcLicenseCheckerModuleValue:String = "";
      
      protected var regionModuleValue:String = "";
      
      public var prerolls:Array = [];
      
      public var backgroundColor:Number;
      
      protected var enhanceModuleValue:String = "";
      
      public var subscriptionToken:String = "";
      
      protected var endscreenModuleValue:String = "";
      
      protected var yvaModuleValue:String = "";
      
      public var perceptualLoudnessDb:Number = NaN;
      
      public var scriptedPlayback:Boolean = false;
      
      public var isDrmUpdated:Boolean = false;
      
      protected var disableSeekOnTime:Boolean = false;
      
      public var canWatchLater:Boolean = true;
      
      public var clipStart:Number = NaN;
      
      public var oceanSig:String;
      
      protected var frescaModuleValue:String = "";
      
      protected var ivModuleValue:String = "";
      
      public var videoUrl:String = "";
      
      public var scriptedClickToPlay:Boolean = false;
      
      protected var tokenValue:String = "";
      
      public var delayedViewcountThreshold:Number = 0;
      
      public var trackPoint:int = 1;
      
      protected var getVideoInfoLoader:URLLoader;
      
      public var streamingLibModule:String = "";
      
      public var liveMpdParser:LiveMpdParser;
      
      protected var subscriptionId:String = "";
      
      protected var promotedVideoConversionUrlValue:String;
      
      public var adobePassToken:String = "";
      
      public var isPlaybackLogged:Boolean = false;
      
      protected var secondsToExpirationValue:Number = NaN;
      
      public var isLiveMonitor:Boolean = false;
      
      public var cycToken:String = "";
      
      public var needsLiveUpdate:Boolean = false;
      
      public var featureType:String;
      
      protected var audioTrackValue:String;
      
      protected var thumbnailUrlsValue:Array = [];
      
      public var clipEnd:Number = NaN;
      
      protected var watermarkValue:String = "";
      
      public var accountPlaybackToken:String;
      
      protected var csiPageType:String = "";
      
      public var isTmi:Boolean = false;
      
      protected var aspectOverrideValue:Number = 0;
      
      public var timelineData:TimelineData = new TimelineData();
      
      public var isRetrying:Boolean = false;
      
      public var netConnectionClosedEventCount:uint = 0;
      
      protected var authUserValue:String = "";
      
      protected var keywords:Object = {};
      
      public var watchAjaxToken:String = "";
      
      public var videoFileByteOffset:Number = 0;
      
      public var isDelayedViewcountLogged:Boolean = false;
      
      protected var formatValue:VideoFormat = new VideoFormat();
      
      protected var startSecondsValue:Number = NaN;
      
      protected var imageUrlValue:String = "";
      
      protected var suggestionsValue:Array = [];
      
      public var isDashEnabled:Boolean = false;
      
      public var enableCardioRealtimeAnalytics:Boolean = false;
      
      protected var videoQualityValue:VideoQuality = new VideoQuality();
      
      protected var commentsModuleValue:String = "";
      
      protected var akamaiHdModuleValue:String = "";
      
      protected var partnerTrackingTokenValue:String = "";
      
      public var conversionConfig:Object = {};
      
      public function VideoData(param1:Object, param2:Object = null)
      {
         super();
         if(param1 is String)
         {
            this.videoIdValue = String(param1);
            this.resetPlaybackNonce({"video_id":this.videoIdValue});
         }
         else
         {
            this.copyObject(param1,param1);
            this.resetPlaybackNonce(param1);
            this.applyFlashVars(param1,param2);
         }
      }
      
      public static function parseKeywords(param1:String) : Object
      {
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc2_:Object = {};
         var _loc3_:Array = param1.split(",");
         var _loc4_:Number = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = unescape(_loc3_[_loc4_]);
            if(0 != _loc5_.length)
            {
               _loc6_ = MACHINE_TAG_REGEX.exec(_loc5_);
               if(_loc6_)
               {
                  _loc2_[_loc6_[1]] = _loc6_[2];
               }
               else
               {
                  _loc2_[_loc5_] = true;
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function get partnerTrackingChannelToken() : String
      {
         return this.partnerTrackingChannelTokenValue;
      }
      
      public function get thumbnailUrls() : Array
      {
         return this.thumbnailUrlsValue;
      }
      
      public function get videoQuality() : VideoQuality
      {
         return this.videoQualityValue;
      }
      
      public function get requiresTimeOffset() : Boolean
      {
         return this.requiresTimeOffsetValue;
      }
      
      protected function findKeyframeForSeconds(param1:Number, param2:Number, param3:Number) : KeyframeTuple
      {
         if(param2 >= param3)
         {
            if(param1 < this.keyframesValue.times[param3])
            {
               return new KeyframeTuple(this.keyframesValue.times[param3 - 1],this.keyframesValue.filepositions[param3 - 1]);
            }
            return new KeyframeTuple(this.keyframesValue.times[param3],this.keyframesValue.filepositions[param3]);
         }
         var _loc4_:Number = Math.floor((param2 + param3) / 2);
         if(param1 < this.keyframesValue.times[_loc4_])
         {
            return this.findKeyframeForSeconds(param1,param2,_loc4_);
         }
         if(param1 > this.keyframesValue.times[_loc4_])
         {
            return this.findKeyframeForSeconds(param1,_loc4_ + 1,param3);
         }
         return new KeyframeTuple(this.keyframesValue.times[_loc4_],this.keyframesValue.filepositions[_loc4_]);
      }
      
      public function get mediaId() : String
      {
         return this.mediaIdValue;
      }
      
      public function getFormatForQualityAndRect(param1:VideoQuality, param2:Rectangle) : VideoFormat
      {
         if(param1.equals(VideoQuality.AUTO))
         {
            return this.getFormatForRect(param2);
         }
         return this.getFormatForQuality(param1);
      }
      
      protected function parseFormatList(param1:String, param2:String, param3:String = null, param4:Boolean = true) : Array
      {
         var _loc7_:Object = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:VideoFormat = null;
         var _loc12_:String = null;
         if(!param1 && !param2 && !param3)
         {
            return [];
         }
         var _loc5_:Array = [];
         var _loc6_:Object = {};
         if(param2)
         {
            _loc7_ = this.parseFormatStreamMap(param2);
         }
         else
         {
            _loc7_ = this.parseUrlEncodedStreamMap(param3);
         }
         var _loc8_:Boolean = Boolean(this.threeDModule) && param4;
         for each(_loc9_ in param1.split(","))
         {
            _loc10_ = _loc9_.split("/")[0];
            if(_loc7_[_loc10_])
            {
               _loc11_ = new VideoFormat(_loc9_,_loc7_[_loc10_].stream,_loc7_[_loc10_].conn,_loc7_[_loc10_].fallbackHost,_loc7_[_loc10_].stereo3d,_loc7_[_loc10_].type);
               _loc12_ = _loc11_.quality + (_loc11_.isStereo3D ? "_stereo3d" : "");
               if(_loc11_.isSupported() && !_loc6_[_loc12_])
               {
                  _loc5_.push(_loc11_);
                  _loc6_[_loc12_] = true;
                  if(_loc11_.isStereo3D)
                  {
                     this.hasStereo3DFormats = true;
                  }
               }
               if(_loc11_.isM2Ts)
               {
                  HlsParser.makeHlsFormat(_loc11_);
               }
            }
         }
         return _loc5_;
      }
      
      public function get aspectOverride() : Number
      {
         if(this.enhanceModule)
         {
            return this.videoWidth / this.videoHeight / 2;
         }
         return this.aspectOverrideValue || 0;
      }
      
      protected function parseMachineTags() : void
      {
         var _loc1_:String = this.getMachineTagValue("yt:stretch");
         if(_loc1_ == "16:9" || _loc1_ == "4:3")
         {
            this.aspectOverrideValue = StringUtils.parseRatio(_loc1_);
         }
         var _loc2_:String = this.getMachineTagValue("yt:crop");
         if(_loc2_)
         {
            if(_loc2_ == "16:9" || _loc2_ == "24:10" || _loc2_ == "4:3")
            {
               this.cropOverride = StringUtils.parseRatio(_loc2_);
            }
            else if(_loc2_ == "fullwidth")
            {
               this.cropOverride = Infinity;
            }
            else if(_loc2_ == "off")
            {
               this.cropOverride = NaN;
            }
         }
         var _loc3_:String = this.getMachineTagValue("yt:bgcolor");
         if(_loc3_)
         {
            if(_loc3_.charAt(0) == "#")
            {
               _loc3_ = _loc3_.substring(1);
            }
            if(_loc3_.length == 6)
            {
               this.backgroundColor = parseInt(_loc3_,16);
            }
            else if(_loc3_.length == 3)
            {
               this.backgroundColor = parseInt(_loc3_.charAt(0) + _loc3_.charAt(0) + _loc3_.charAt(1) + _loc3_.charAt(1) + _loc3_.charAt(2) + _loc3_.charAt(2),16);
            }
         }
      }
      
      public function get watermark() : String
      {
         return this.watermarkValue;
      }
      
      public function isDataValid() : Boolean
      {
         return Boolean(this.flvUrlValue) || Boolean(this.thirdPartyFlvUrlValue) || Boolean(this.videoIdValue) || int(this.partnerId) == PlayerType.EDITOR_PREVIEW;
      }
      
      public function get yvaModule() : String
      {
         return this.yvaModuleValue;
      }
      
      public function isHlsVariantPlaylistReady() : Boolean
      {
         return this.isDataReady() && !this.playlistLoader;
      }
      
      public function get threeDModule() : String
      {
         return this.threeDModuleValue;
      }
      
      protected function parseFormatStreamMap(param1:String) : Object
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc2_:Object = {};
         for each(_loc3_ in param1.split(","))
         {
            _loc4_ = _loc3_.split("|");
            if(UrlValidator.isTrustedDomain(_loc4_[1]) || UrlValidator.isRtmp(_loc4_[2]))
            {
               _loc2_[_loc4_[0]] = {
                  "stream":_loc4_[1],
                  "conn":_loc4_[2],
                  "fallbackHost":_loc4_[3]
               };
            }
         }
         return _loc2_;
      }
      
      public function get adModule() : String
      {
         return this.adModuleValue;
      }
      
      public function get watermarkHd() : String
      {
         return this.watermarkHdValue;
      }
      
      protected function onLiveMpdXml(param1:Event) : void
      {
         this.liveMpdParser = new LiveMpdParser(this.playlistUrl);
         this.liveMpdParser.parseString(this.playlistLoader.data);
         this.resetPlaylistLoader();
         if(this.liveMpdParser.isValid)
         {
            this.formatListValue = this.liveMpdParser.getFormats();
            dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this,VideoDataEvent.VIDEO_INFO));
         }
         else
         {
            dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
         }
      }
      
      protected function setupThumbnailUrls(param1:String) : void
      {
         var _loc2_:String = UrlValidator.isTrustedDomain(param1) ? param1 : DEFAULT_THUMBNAIL_URL;
         this.thumbnailUrlsValue.push(_loc2_);
         this.thumbnailUrlsValue.push(_loc2_.split("/default.jpg").join("/1.jpg"));
         this.thumbnailUrlsValue.push(_loc2_.split("/default.jpg").join("/2.jpg"));
         this.thumbnailUrlsValue.push(_loc2_.split("/default.jpg").join("/3.jpg"));
      }
      
      protected function onGetVideoInfoError(param1:ErrorEvent) : void
      {
         this.resetGetVideoInfoLoader();
         dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,param1.text));
      }
      
      public function needsPrerolls() : Boolean
      {
         return Boolean(this.prerolls.length);
      }
      
      protected function onGetVideoInfo(param1:Event) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         this.resetGetVideoInfoLoader();
         var _loc2_:URLLoader = URLLoader(param1.target);
         if(_loc2_.data && _loc2_.data.status == "ok")
         {
            this.applyGetVideoInfo(_loc2_.data);
         }
         else
         {
            _loc3_ = "GetVideoInfoError";
            _loc4_ = 0;
            if(_loc2_.data)
            {
               if(_loc2_.data.reason)
               {
                  _loc3_ = _loc3_ + ":" + _loc2_.data.reason;
               }
               _loc4_ = parseInt(_loc2_.data.errorcode);
            }
            dispatchEvent(new VideoErrorEvent(VideoErrorEvent.ERROR,_loc3_,_loc4_));
         }
      }
      
      public function get rawVideoInfo() : Object
      {
         return this.copyObject(this.rawVideoInfoValue,{});
      }
      
      public function getPromotedVideoBeaconRequest(param1:String) : URLRequest
      {
         var _loc2_:String = null;
         switch(param1)
         {
            case ADVERTISER_EVENT_IMPRESSION:
               _loc2_ = this.promotedVideoImpressionBeaconUrlValue;
               break;
            case ADVERTISER_EVENT_PROGRESS_25:
               _loc2_ = this.promotedVideoProgress25BeaconUrlValue;
               break;
            case ADVERTISER_EVENT_PROGRESS_50:
               _loc2_ = this.promotedVideoProgress50BeaconUrlValue;
               break;
            case ADVERTISER_EVENT_PROGRESS_75:
               _loc2_ = this.promotedVideoProgress75BeaconUrlValue;
               break;
            case ADVERTISER_EVENT_COMPLETE:
               _loc2_ = this.promotedVideoCompleteBeaconUrlValue;
         }
         return _loc2_ ? new URLRequest(_loc2_) : null;
      }
      
      protected function parseUrlEncodedSuggestedVideoVars(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:VideoData = null;
         var _loc7_:Array = null;
         var _loc2_:Array = [];
         for each(_loc3_ in param1.split(","))
         {
            _loc4_ = {};
            for each(_loc5_ in _loc3_.split("&"))
            {
               _loc7_ = _loc5_.split("=",2);
               _loc4_[_loc7_[0]] = this.decodeUriComponent(_loc7_[1]);
            }
            if(!_loc4_.list)
            {
               _loc6_ = new VideoData({});
               _loc6_.applyRelatedVideoFlashArgs(_loc4_);
               _loc2_.push(_loc6_);
            }
         }
         this.suggestionsValue = _loc2_;
      }
      
      public function get canRetry() : Boolean
      {
         return !this.isTransportRtmp() && !this.partnerId && !this.isRetrying;
      }
      
      public function disableCurrentFormat() : void
      {
         if(this.formatValue.enabled)
         {
            this.formatValue.enabled = false;
            dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this,VideoDataEvent.FORMAT_DISABLED));
         }
      }
      
      protected function applyCommonVideoInfo(param1:Object) : void
      {
         if(param1.author)
         {
            this.author = param1.author;
         }
         if(param1.title)
         {
            this.titleValue = param1.title;
         }
         if(param1.length_seconds)
         {
            this.durationValue = Number(param1.length_seconds);
         }
         if(param1.subscribed)
         {
            this.userSubscribedToChannel = param1.subscribed;
         }
         if(param1.storyboard_spec)
         {
            this.videoStoryboard = new VideoStoryboard(param1.storyboard_spec);
            this.videoStoryboard.removeOrInitializeDefaultLevel(this.durationValue);
            this.mosaicLoader = new MosaicLoader(this.videoStoryboard);
         }
         else if(param1.live_storyboard_spec)
         {
            this.videoStoryboard = VideoStoryboard.fromLiveFormat(param1.live_storyboard_spec);
            this.mosaicLoader = new LiveMosaicLoader(this.videoStoryboard,this.isLive);
         }
      }
      
      public function applyMetaData(param1:Object) : void
      {
         if(!this.metaDataLoaded)
         {
            if(param1.totalduration is Number && Boolean(param1.totalduration))
            {
               this.durationValue = param1.totalduration;
            }
            else if(Boolean(param1.tags) && Boolean(param1.tags.gstd))
            {
               this.durationValue = param1.tags.gstd / 1000;
            }
            else if(param1.duration is Number && Boolean(param1.duration))
            {
               this.durationValue = param1.duration;
            }
         }
         if(param1.width is Number && param1.width > 0 && (param1.height is Number && param1.height > 0))
         {
            this.videoWidthValue = param1.width;
            this.videoHeightValue = param1.height;
         }
         var _loc2_:String = this.pingUrl;
         var _loc3_:String = this.pingMessage;
         if(param1.requiresTimeOffset)
         {
            this.requiresTimeOffsetValue = true;
         }
         this.isMp4Value = param1.moovposition is Number || param1.moovPosition is Number;
         if(this.isMp4Value)
         {
            this.applyMp4MetaData(param1);
         }
         else
         {
            this.applyFlvMetaData(param1);
         }
         if(_loc2_ != this.pingUrl || _loc3_ != this.pingMessage)
         {
            this.pingBack();
         }
         this.metaDataLoaded = true;
         dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this,VideoDataEvent.METADATA));
      }
      
      public function get frescaModule() : String
      {
         return this.frescaModuleValue;
      }
      
      protected function applyRelatedVideoFlashArgs(param1:Object) : void
      {
         this.applyCommonVideoInfo(param1);
         if(param1.id)
         {
            this.videoIdValue = param1.id;
         }
         if(param1.title)
         {
            this.titleValue = param1.title;
         }
         if(param1.view_count)
         {
            this.viewCountValue = param1.view_count;
         }
         if(param1.rating)
         {
            this.ratingValue = parseFloat(param1.rating);
         }
         if(param1.url)
         {
            this.url = param1.url;
         }
         if(param1.thumbnailUrl)
         {
            this.setupThumbnailUrls(param1.thumbnailUrl);
         }
         if(param1.feature_type)
         {
            this.featureType = param1.feature_type;
         }
         this.copyObject(param1,this.rawVideoInfoValue);
      }
      
      public function get infringe() : Boolean
      {
         return this.infringeValue;
      }
      
      public function calledSetAwesome() : Boolean
      {
         return this.setAwesomeLoader != null;
      }
      
      public function hasQuality(param1:VideoQuality) : Boolean
      {
         var _loc2_:VideoFormat = null;
         for each(_loc2_ in this.formatListValue)
         {
            if(_loc2_.quality.equals(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      protected function hash(param1:Number) : Number
      {
         var _loc2_:Number = 0.059886774281039834 * param1;
         _loc2_ += 21845.33332824707;
         param1 = _loc2_ | 0;
         _loc2_ -= param1;
         _loc2_ *= param1;
         param1 = _loc2_ | 0;
         _loc2_ -= param1;
         param1 ^= _loc2_ * 4294967296;
         return param1 >>> 0;
      }
      
      public function getVideoInfo(param1:URLRequest) : void
      {
         var request:URLRequest = param1;
         var cachedVideo:VideoData = ALL_VIDEOS[this.videoId];
         if(!this.isDataReady() && this.videoId && cachedVideo && cachedVideo.isDataReady())
         {
            Scheduler.setTimeout(0,this.reuseGetVideoInfo);
            return;
         }
         if(this.getVideoInfoLoader)
         {
            return;
         }
         this.getVideoInfoLoader = new URLLoader();
         this.getVideoInfoLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
         this.getVideoInfoLoader.addEventListener(Event.COMPLETE,this.onGetVideoInfo);
         this.getVideoInfoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onGetVideoInfoError);
         this.getVideoInfoLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onGetVideoInfoError);
         try
         {
            this.getVideoInfoLoader.load(request);
         }
         catch(error:Error)
         {
            onGetVideoInfoError(new ErrorEvent(ErrorEvent.ERROR,false,false,error.message));
         }
      }
      
      public function get httpHostHeader() : String
      {
         return this.httpHostHeaderValue || this.extractHostFromUrl(this.formatValue.url) || this.extractHostFromUrl(this.flvUrlValue);
      }
      
      public function get promotedVideoBillableUrl() : String
      {
         return this.promotedVideoBillableUrlValue;
      }
      
      protected function applyMp4MetaData(param1:Object) : void
      {
         if(!param1 || !param1.tags)
         {
            return;
         }
         if(param1.tags.gshh is String)
         {
            this.httpHostHeaderValue = param1.tags.gshh;
         }
         if(!this.isTransportRtmp())
         {
            this.startSeconds = param1.tags.gsst ? parseInt(param1.tags.gsst) / 1000 : 0;
         }
         this.sourceDataValue = param1.tags.gssd || "";
         this.pingMessage = param1.tags.gspm ? param1.tags.gspm : "";
         this.pingUrl = param1.tags.gspu ? param1.tags.gspu : "";
         this.videoFileByteOffset = Math.floor(this.startSeconds * (param1.bytesTotal / (this.duration - this.startSeconds)));
      }
      
      protected function loadSubscription(param1:URLRequest) : void
      {
         param1.data.session_token = this.subscriptionToken;
         var _loc2_:RequestLoader = new RequestLoader();
         _loc2_.addEventListener(Event.COMPLETE,this.onSubscriptionLoaded);
         _loc2_.loadRequest(param1);
      }
      
      public function getMachineTagValue(param1:String) : String
      {
         if(!(this.keywords[param1] is String))
         {
            return null;
         }
         return this.keywords[param1];
      }
      
      private function get isConversionTracked() : Boolean
      {
         return Boolean(this.conversionConfig.focEnabled) || Boolean(this.conversionConfig.rmktEnabled);
      }
      
      public function isTransportRtmp() : Boolean
      {
         return this.formatValue.isTransportRtmp();
      }
      
      public function get akamaiHdModule() : String
      {
         return this.akamaiHdModuleValue;
      }
      
      public function get formatList() : Array
      {
         return this.formatListValue;
      }
      
      public function get partnerTrackingPlaybackType() : String
      {
         return this.partnerTrackingPlaybackTypeValue;
      }
      
      public function subscribe() : void
      {
         if(!this.subscriptionToken)
         {
            dispatchEvent(new SubscriptionEvent(SubscriptionEvent.OPEN_LOGIN_DIALOG));
         }
         else
         {
            this.subscribeRequest.data.c = this.externalUserId;
            this.loadSubscription(this.subscribeRequest);
         }
      }
      
      public function get isMp4() : Boolean
      {
         return this.isMp4Value;
      }
      
      public function get viewCount() : String
      {
         return this.viewCountValue;
      }
      
      protected function parseSuggestedVideoVars(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Array = null;
         var _loc8_:Number = NaN;
         var _loc9_:String = null;
         var _loc10_:VideoData = null;
         var _loc2_:Array = [];
         for(_loc3_ in param1)
         {
            if(_loc3_.indexOf("rv.") != -1)
            {
               _loc7_ = _loc3_.split(".");
               if(_loc7_.length == 3)
               {
                  _loc8_ = parseInt(_loc7_[1]);
                  _loc9_ = _loc7_[2];
                  if(_loc2_[_loc8_] == undefined)
                  {
                     _loc2_[_loc8_] = {};
                  }
                  _loc2_[_loc8_][_loc9_] = param1[_loc3_];
               }
            }
         }
         _loc4_ = [];
         _loc5_ = _loc2_.length;
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            _loc10_ = new VideoData({});
            _loc10_.applyRelatedVideoFlashArgs(_loc2_[_loc6_]);
            _loc4_.push(_loc10_);
            _loc6_++;
         }
         if(_loc4_.length)
         {
            this.suggestionsValue = _loc4_;
         }
      }
      
      protected function pingBack() : void
      {
         if(!this.pingMessage || !this.pingUrl)
         {
            return;
         }
         var _loc1_:XML = new XML(this.pingMessage);
         var _loc2_:RequestLoader = new RequestLoader();
         var _loc3_:String = this.pingUrl;
         _loc3_ += -1 == _loc3_.indexOf("?") ? "?" : "&";
         _loc3_ += "psalt=" + _loc1_.Msg.@psalt;
         _loc2_.loadRequest(new URLRequest(_loc3_));
      }
      
      public function get thirdPartyFlvUrl() : String
      {
         return this.thirdPartyFlvUrlValue;
      }
      
      public function get commentsModule() : String
      {
         return this.commentsModuleValue;
      }
      
      public function get trackingToken() : String
      {
         return this.trackingTokenValue;
      }
      
      public function resetPlaybackNonce(param1:Object) : String
      {
         var _loc4_:* = undefined;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc9_:* = undefined;
         var _loc10_:String = null;
         var _loc2_:Array = [Math.random() * uint.MAX_VALUE,Math.random() * uint.MAX_VALUE,Math.random() * uint.MAX_VALUE];
         param1 = this.copyObject(param1,{
            "getTimer":getTimer(),
            "totalMemory":System.totalMemory,
            "Capabilities.serverString":Capabilities.serverString
         });
         var _loc3_:Number = 0;
         for each(_loc4_ in param1)
         {
            if(_loc4_ is Number)
            {
               _loc2_[_loc3_ % 3] = this.hash(_loc2_[_loc3_ % 3] ^ _loc4_);
               _loc3_++;
            }
            else if(_loc4_ is String)
            {
               _loc9_ = 0;
               while(_loc9_ < _loc4_.length)
               {
                  _loc2_[_loc3_ % 3] = this.hash(_loc2_[_loc3_ % 3] ^ _loc4_.charCodeAt(_loc9_));
                  _loc3_++;
                  _loc9_++;
               }
            }
         }
         _loc5_ = new Array(33).join("0");
         _loc6_ = "";
         _loc7_ = 0;
         while(_loc7_ < 3)
         {
            _loc10_ = _loc2_[_loc7_].toString(2);
            _loc6_ += _loc5_.slice(0,32 - _loc10_.length) + _loc10_;
            _loc7_++;
         }
         var _loc8_:Array = [];
         _loc7_ = 0;
         while(_loc7_ < _loc6_.length)
         {
            _loc8_.push(BASE_64.charAt(parseInt(_loc6_.substr(_loc7_,6),2)));
            _loc7_ += 6;
         }
         this.clientPlaybackNonce = _loc8_.join("");
         return this.clientPlaybackNonce;
      }
      
      public function get videoHeight() : Number
      {
         return this.videoHeightValue;
      }
      
      public function get authUser() : String
      {
         return this.authUserValue;
      }
      
      public function get partnerTrackingToken() : String
      {
         return this.partnerTrackingTokenValue;
      }
      
      public function get duration() : Number
      {
         if(this.format.isHls)
         {
            if(!this.durationValue || !this.isLive && this.formatValue.hlsPlaylist.duration)
            {
               this.durationValue = this.formatValue.hlsPlaylist.duration;
            }
            else if(this.durationValue < this.formatValue.hlsPlaylist.duration)
            {
               this.durationValue *= LIVE_EVENT_EXTEND_FACTOR;
            }
         }
         return this.durationValue;
      }
      
      public function get rating() : Number
      {
         return this.ratingValue;
      }
      
      protected function reuseGetVideoInfo(... rest) : void
      {
         var _loc2_:VideoData = ALL_VIDEOS[this.videoId];
         if(Boolean(_loc2_) && _loc2_.isGetVideoInfoLoaded)
         {
            this.applyGetVideoInfo(_loc2_.rawVideoInfoValue);
            this.dateUrlSigned = _loc2_.dateUrlSigned;
         }
      }
      
      public function get partnerTrackingOid() : String
      {
         return this.partnerTrackingOidValue;
      }
      
      public function get subtitlesModule() : String
      {
         return this.subtitlesModuleValue;
      }
      
      public function set flvUrl(param1:String) : void
      {
         this.flvUrlValue = param1;
      }
      
      public function get ypcModule() : String
      {
         return this.ypcModuleValue;
      }
      
      public function get isPartnerWatermark() : Boolean
      {
         return Boolean(this.watermarkValue) && !YOUTUBE_LOGO_REGEX.test(this.watermarkValue) && !LEGACY_YOUTUBE_LOGO_REGEX.test(this.watermarkValue);
      }
      
      protected function onHlsVariantPlaylist(param1:Event) : void
      {
         var _loc2_:String = this.playlistLoader.data;
         this.resetPlaylistLoader();
         var _loc3_:HlsParser = new HlsParser();
         this.formatListValue = _loc3_.parseVariantPlaylist(_loc2_,this.playlistUrl,this.isLiveMonitor);
         this.formatListValue.sortOn("name",Array.DESCENDING | Array.NUMERIC);
         dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this,VideoDataEvent.VIDEO_INFO));
      }
      
      public function get multiCameraModule() : String
      {
         return this.multiCameraModuleValue;
      }
      
      public function setErrorCode(param1:String) : void
      {
         this.errorCodeValue = param1;
      }
      
      public function canSeekOnTime() : Boolean
      {
         return !(this.formatValue.name == "" && Boolean(this.keyframesValue) || this.disableSeekOnTime);
      }
      
      protected function isValidAudioTrack(param1:String) : Boolean
      {
         var _loc2_:VideoFormat = null;
         for each(_loc2_ in this.formatListValue)
         {
            if(param1 == _loc2_.audioTrack.name)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getAvailableQualityLevels() : Array
      {
         var _loc3_:VideoFormat = null;
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < this.formatList.length)
         {
            _loc3_ = this.formatList[_loc2_];
            if(this.isFormatAvailable(_loc3_))
            {
               _loc1_.push(_loc3_.quality);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      protected function decodeUriComponent(param1:String) : String
      {
         return decodeURIComponent(param1.split("+").join(" "));
      }
      
      public function isPlaybackLoggable() : Boolean
      {
         return this.isGetVideoLoggable && (this.isTransportRtmp() || this.partnerId || Boolean(this.formatValue.url));
      }
      
      public function isFormatAvailable(param1:VideoFormat) : Boolean
      {
         if(this.threeDEnabledValue != param1.isStereo3D && this.hasStereo3DFormats)
         {
            return false;
         }
         if(Boolean(this.audioTrackValue) && this.audioTrackValue != param1.audioTrack.name)
         {
            return false;
         }
         if(!this.audioTrackValue && !param1.audioTrack.isDefault)
         {
            return false;
         }
         return true;
      }
      
      public function get videoWidth() : Number
      {
         return this.videoWidthValue;
      }
      
      public function findClosestKeyframeBefore(param1:Number) : KeyframeTuple
      {
         var _loc2_:KeyframeTuple = null;
         if(this.keyframesValue)
         {
            _loc2_ = this.findKeyframeForSeconds(param1,0,this.keyframesValue.times.length - 1);
         }
         return _loc2_;
      }
      
      public function isDataReady() : Boolean
      {
         var _loc1_:Number = NaN;
         if(this.needsLiveUpdate)
         {
            return false;
         }
         if(Boolean(this.flvUrlValue) || Boolean(this.thirdPartyFlvUrlValue) || int(this.partnerId) == PlayerType.EDITOR_PREVIEW)
         {
            return true;
         }
         if(!this.videoIdValue)
         {
            return false;
         }
         if(!isNaN(this.authTimeoutValue))
         {
            _loc1_ = this.authTimeoutValue;
         }
         else
         {
            _loc1_ = this.isTransportRtmp() ? STREAM_AUTH_TIMEOUT : VIDEO_TOKEN_TIMEOUT;
         }
         if(this.authTimeoutValue == 0)
         {
            return false;
         }
         return Boolean(this.dateUrlSigned) && _loc1_ > new Date().getTime() - this.dateUrlSigned.getTime();
      }
      
      public function get ivModule() : String
      {
         return this.ivModuleValue;
      }
      
      public function get imageUrl() : String
      {
         return this.imageUrlValue;
      }
      
      public function get ypcLicenseCheckerModule() : String
      {
         return this.ypcLicenseCheckerModuleValue;
      }
      
      public function get threeDEnabled() : Boolean
      {
         return this.threeDEnabledValue;
      }
      
      public function isSeekEnabled(param1:Number = NaN) : Boolean
      {
         if(param1 == Infinity && this.isLive)
         {
            return true;
         }
         var _loc2_:Boolean = this.isHls && !this.isHlsLiveOnly;
         return _loc2_ || !this.partnerId || this.partnerId != String(PlayerType.YOUTUBE_LIVE) && this.partnerId != String(PlayerType.AKAMAI_LIVE) && this.partnerId != String(PlayerType.GOOGLE_LIVE);
      }
      
      protected function applyCommonLoadedInfo(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:* = undefined;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:Object = null;
         var _loc11_:Array = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:Number = NaN;
         if(param1.partnerid)
         {
            this.partnerId = param1.partnerid;
         }
         if(param1.oauth_token)
         {
            this.oauthToken = param1.oauth_token;
         }
         if(param1.allow_embed)
         {
            this.allowEmbed = param1.allow_embed == "1";
         }
         if(param1.live_playback)
         {
            this.isLive = true;
         }
         if(param1.dash)
         {
            this.isDashEnabled = param1.dash == "1";
         }
         if(this.isLive && this.isDashEnabled && UrlValidator.isTrustedDomain(param1.dashmpd))
         {
            this.playlistUrl = param1.dashmpd;
            this.getPlaylist(this.onLiveMpdXml);
         }
         else if(this.isDashEnabled && UrlValidator.isTrustedDomain(param1.dashmpd))
         {
            this.playlistUrl = param1.dashmpd;
            this.getPlaylist(this.onMpdXml);
         }
         else if(UrlValidator.isTrustedDomain(param1.hlsvp))
         {
            this.isHlsVariantPlaylist = true;
            this.playlistUrl = param1.hlsvp;
            this.getPlaylist(this.onHlsVariantPlaylist);
         }
         else
         {
            this.setFormatList(param1.fmt_list,param1.fmt_stream_map,param1.url_encoded_fmt_stream_map);
            if(this.formatListValue.length && this.videoWidthValue == 320 && this.videoHeightValue == 240)
            {
               this.videoWidthValue = this.formatListValue[0].size.width;
               this.videoHeightValue = this.formatListValue[0].size.height;
            }
         }
         if(param1.hlsdvr == "0")
         {
            this.isHlsLiveOnly = this.isHls && this.isLive;
         }
         if(param1.abd == "1")
         {
            this.adaptiveByDefault = true;
         }
         if(param1.idup == "1")
         {
            this.isDrmUpdated = true;
         }
         if(this.isLive && (isNaN(this.startSecondsValue) || !this.isSeekEnabled()))
         {
            this.startSeconds = Infinity;
         }
         if(UrlValidator.isTrustedSwf(param1.interstitial))
         {
            this.interstitialValue = param1.interstitial;
         }
         if(UrlValidator.isTrustedSwf(param1.iv3_module))
         {
            this.ivModuleValue = param1.iv3_module;
         }
         if(UrlValidator.isTrustedSwf(param1.cc3_module))
         {
            this.subtitlesModuleValue = param1.cc3_module;
         }
         if(UrlValidator.isTrustedSwf(param1.multicamera_module))
         {
            this.multiCameraModuleValue = param1.multicamera_module;
         }
         if(UrlValidator.isTrustedSwf(param1.comments_module))
         {
            this.commentsModuleValue = param1.comments_module;
         }
         if(UrlValidator.isTrustedSwf(param1.st_module))
         {
            this.streamingTextModuleValue = param1.st_module;
         }
         if(UrlValidator.isTrustedSwf(param1.endscreen_module))
         {
            this.endscreenModuleValue = param1.endscreen_module;
         }
         if(UrlValidator.isTrustedSwf(param1.threed_module))
         {
            this.threeDModuleValue = param1.threed_module;
            this.checkPolicyFile = true;
         }
         if(UrlValidator.isTrustedSwf(param1.region_module))
         {
            this.regionModuleValue = param1.region_module;
         }
         if(UrlValidator.isTrustedSwf(param1.enhance_module))
         {
            this.enhanceModuleValue = param1.enhance_module;
         }
         if(UrlValidator.isTrustedSwf(param1.fresca_module))
         {
            this.frescaModuleValue = param1.fresca_module;
         }
         if(param1.mediaid)
         {
            this.mediaIdValue = param1.mediaid;
         }
         if(param1.no_get_video_log == "1")
         {
            this.isGetVideoLoggable = false;
         }
         if(param1.tmi == "1")
         {
            this.isTmi = true;
         }
         if(UrlValidator.isTrustedSwf(param1.ad3_module))
         {
            this.adModuleValue = param1.ad3_module;
            if(param1.cev)
            {
               this.requiresPlayerSizeValidation = true;
               this.prerolls.push(AdModuleDescriptor.ID + ModuleDescriptor.VALIDATE_SIZE_PREROLL);
            }
         }
         if(UrlValidator.isTrustedSwf(param1.yva_module))
         {
            this.yvaModuleValue = param1.yva_module;
         }
         if(UrlValidator.isTrustedSwf(param1.ypc_module))
         {
            this.ypcModuleValue = param1.ypc_module;
            this.prerolls.push(YpcModuleDescriptor.ID);
         }
         if(UrlValidator.isTrustedSwf(param1.akamaihd_module))
         {
            this.akamaiHdModuleValue = param1.akamaihd_module;
         }
         if(UrlValidator.isTrustedSwf(param1.ypc_license_checker_module))
         {
            this.ypcLicenseCheckerModuleValue = param1.ypc_license_checker_module;
            this.prerolls.push(YpcLicenseCheckerModuleDescriptor.ID);
         }
         if(UrlValidator.isTrustedSwf(param1.flashaccess_module))
         {
            this.flashAccessModule = param1.flashaccess_module;
            this.prerolls.push(FlashAccessModuleDescriptor.ID);
         }
         if(param1.disable_seek_on_time)
         {
            this.disableSeekOnTime = param1.disable_seek_on_time == "1";
         }
         if(param1.ypc_preview)
         {
            this.ypcPreview = param1.ypc_preview == "1";
         }
         if(param1.ad_preroll)
         {
            this.prerolls.push(AdModuleDescriptor.ID);
         }
         if(param1.ratings_preroll)
         {
            this.prerolls.push(RatingsModuleDescriptor.ID);
         }
         if(param1.streaminglib_preroll)
         {
            this.prerolls.push(StreamingLibModuleDescriptor.ID);
         }
         if(param1.threed_preroll)
         {
            this.prerolls.push(ThreeDModuleDescriptor.ID);
         }
         if(param1.enhance_preroll)
         {
            this.prerolls.push(EnhanceModuleDescriptor.ID);
         }
         if(param1.yva_preroll)
         {
            this.prerolls.push(YvaModuleDescriptor.ID);
         }
         if(param1.akamaihd_preroll)
         {
            this.prerolls.push(AkamaiHdModuleDescriptor.ID);
         }
         if(param1.multicamera_preroll)
         {
            this.prerolls.push(MultiCameraModuleDescriptor.ID);
         }
         if(param1.fresca_preroll)
         {
            this.prerolls.push(FrescaModuleDescriptor.ID);
         }
         if(param1.ptk)
         {
            this.partnerTrackingTokenValue = param1.ptk;
         }
         if(param1.oid)
         {
            this.partnerTrackingOidValue = param1.oid;
         }
         if(param1.ptchn)
         {
            this.partnerTrackingChannelTokenValue = param1.ptchn;
         }
         if(param1.pltype)
         {
            this.partnerTrackingPlaybackTypeValue = param1.pltype;
         }
         if(param1.plid)
         {
            this.playbackIdTokenValue = param1.plid;
         }
         if(param1.enable_cardio == "1")
         {
            this.enableCardioRealtimeAnalytics = true;
         }
         if(param1.enable_cardio_before_playback == "1")
         {
            this.enableCardioBeforePlayback = true;
         }
         if(UrlValidator.isTrustedSwf(param1.ratings3_module))
         {
            this.ratingsModule = param1.ratings3_module;
         }
         if(UrlValidator.isTrustedSwf(param1.streaminglib_module))
         {
            this.streamingLibModule = param1.streaminglib_module;
         }
         if(UrlValidator.isTrustedSwf(param1.usergoals_module))
         {
            this.userGoalsModule = param1.usergoals_module;
         }
         if(param1.sourceid)
         {
            this.sourceIdValue = param1.sourceid;
         }
         if(param1.vq)
         {
            this.videoQualityValue = new VideoQuality(param1.vq);
         }
         if(param1.watermark)
         {
            this.parseWatermark(param1.watermark);
         }
         if(param1.branded_playlist)
         {
            this.brandedPlaylist = param1.branded_playlist;
         }
         if(param1.branded_small_banner_image_url)
         {
            this.brandedSmallBannerImageUrl = param1.branded_small_banner_image_url;
         }
         if(param1.branded_small_banner_image_map)
         {
            this.parseBrandedSmallBannerImageLink(param1.branded_small_banner_image_map);
         }
         if(param1.thumbnail_url)
         {
            this.setupThumbnailUrls(param1.thumbnail_url.toString());
         }
         if(param1.keywords)
         {
            _loc3_ = parseKeywords(param1.keywords);
            for(_loc4_ in _loc3_)
            {
               this.keywords[_loc4_] = _loc3_[_loc4_];
            }
            this.parseMachineTags();
         }
         if(param1.auth_timeout != null)
         {
            if(param1.auth_timeout > 0)
            {
               this.authTimeoutValue = Math.max(140000,param1.auth_timeout);
            }
            else
            {
               this.authTimeoutValue = 0;
            }
         }
         if(param1.ste)
         {
            this.secondsToExpirationValue = parseInt(param1.ste);
            if(!isNaN(this.secondsToExpirationValue) && this.secondsToExpirationValue < 0)
            {
               this.secondsToExpirationValue = NaN;
            }
         }
         if(param1.authkey)
         {
            this.authKeyValue = param1.authkey;
         }
         if(param1.authuser)
         {
            this.authUserValue = param1.authuser;
         }
         if(param1.advideo == "1")
         {
            this.isAdvertiserVideoValue = true;
         }
         this.conversionConfig.socialEnabled = Boolean(param1.socialEnabled == "1" && param1.uid && param1.aid);
         this.conversionConfig.uid = param1.uid;
         this.conversionConfig.aid = param1.aid;
         var _loc2_:Boolean = Boolean(param1.baseUrl) && UrlValidator.isRemarketingDomain(param1.baseUrl);
         if(_loc2_)
         {
            this.conversionConfig.rmktEnabled = Boolean(param1.rmktEnabled == "1" && param1.uid);
            this.conversionConfig.focEnabled = Boolean(param1.focEnabled == "1" && param1.uid);
            this.conversionConfig.baseUrl = param1.baseUrl;
            if(param1.ppe)
            {
               this.conversionConfig.ppe = param1.ppe;
            }
         }
         else
         {
            this.conversionConfig.rmktEnabled = false;
            this.conversionConfig.focEnabled = false;
         }
         if(Boolean(param1.rmktPingThreshold) && Boolean(param1.length_seconds))
         {
            this.conversionViewPingThreshold = Math.min(Number(param1.rmktPingThreshold),Number(param1.length_seconds));
         }
         if(param1.cev)
         {
            this.claimedEmbedVideo = true;
         }
         if(param1.pyv_view_beacon_url)
         {
            this.promotedVideoImpressionBeaconUrlValue = param1.pyv_view_beacon_url;
         }
         if(param1.pyv_quartile25_beacon_url)
         {
            this.promotedVideoProgress25BeaconUrlValue = param1.pyv_quartile25_beacon_url;
         }
         if(param1.pyv_quartile50_beacon_url)
         {
            this.promotedVideoProgress50BeaconUrlValue = param1.pyv_quartile50_beacon_url;
         }
         if(param1.pyv_quartile75_beacon_url)
         {
            this.promotedVideoProgress75BeaconUrlValue = param1.pyv_quartile75_beacon_url;
         }
         if(param1.pyv_quartile100_beacon_url)
         {
            this.promotedVideoCompleteBeaconUrlValue = param1.pyv_quartile100_beacon_url;
         }
         if(Boolean(param1.pyv_billable_url) && UrlValidator.isPromotedVideoDomain(param1.pyv_billable_url))
         {
            this.promotedVideoBillableUrlValue = param1.pyv_billable_url;
         }
         if(Boolean(param1.pyv_conv_url) && UrlValidator.isPromotedVideoDomain(param1.pyv_conv_url))
         {
            this.promotedVideoConversionUrlValue = param1.pyv_conv_url;
         }
         if(param1.watch_ajax_token)
         {
            this.watchAjaxToken = param1.watch_ajax_token;
         }
         if(param1.threed_layout_preview)
         {
            this.threeDLayoutPreview = param1.threed_layout_preview;
            this.hasStereo3DFormats = false;
         }
         if(param1.fmt_names)
         {
            _loc5_ = param1.fmt_names.split(",");
            _loc6_ = int(_loc5_.length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc8_ = _loc5_[_loc7_];
               _loc9_ = _loc8_.split(":");
               _loc10_ = {};
               _loc10_.partnerId = _loc9_[0];
               _loc11_ = _loc9_[1].split("|");
               _loc12_ = _loc11_[0];
               _loc13_ = _loc11_[1];
               if(Boolean(param1[_loc13_]) && Boolean(param1[_loc12_]))
               {
                  _loc10_.fmt_list = param1[_loc13_];
                  _loc10_.fmt_stream_map = param1[_loc12_];
               }
               this.cdnList.push(_loc10_);
               _loc7_++;
            }
         }
         if(!this.suggestions.length)
         {
            if(param1.rvs)
            {
               this.parseUrlEncodedSuggestedVideoVars(param1.rvs);
            }
            else
            {
               this.parseSuggestedVideoVars(param1);
            }
         }
         if(param1.loudness)
         {
            this.perceptualLoudnessDb = param1.loudness;
            if(this.perceptualLoudnessDb > LOUDNESS_CUTOFF_DECIBELS && this.perceptualLoudnessDb < 0)
            {
               _loc14_ = LOUDNESS_TARGET_DECIBELS - this.perceptualLoudnessDb;
               this.muffleFactor = Math.pow(10,_loc14_ / 20);
            }
         }
         if(param1.hbid)
         {
            this.playerDefaultVideoIdsToHtml5 = Number(param1.hbid);
         }
         if(param1.idpj)
         {
            this.initialDetailedPingJitter = Number(param1.idpj);
         }
         if(param1.ldpj)
         {
            this.longDetailedPingJitter = Number(param1.ldpj);
         }
         if(param1.account_playback_token)
         {
            this.accountPlaybackToken = param1.account_playback_token;
         }
         if(param1.oob_vouchers)
         {
            this.oobVouchers = param1.oob_vouchers == "1";
         }
         if(param1.skip_kansas_logging)
         {
            this.skipKansasLoggingValue = true;
         }
         if(param1.delay)
         {
            this.delayedViewcountThreshold = Number(param1.delay);
         }
      }
      
      protected function parseUrlEncodedStreamMap(param1:String) : Object
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:Url = null;
         var _loc2_:Object = {};
         for each(_loc3_ in param1.split(","))
         {
            _loc4_ = {};
            for each(_loc5_ in _loc3_.split("&"))
            {
               _loc6_ = _loc5_.split("=",2);
               _loc4_[_loc6_[0]] = this.decodeUriComponent(_loc6_[1]);
            }
            if(UrlValidator.isTrustedDomain(_loc4_.url) || UrlValidator.isRtmp(_loc4_.conn) || UrlValidator.isTrustedDomain(_loc4_.stream))
            {
               if(Boolean(_loc4_.sig) || Boolean(_loc4_.s))
               {
                  _loc7_ = new Url(_loc4_.url);
                  _loc7_.queryVars["signature"] = _loc4_.sig || SignatureDecipher.decipher(_loc4_.s);
                  _loc4_.url = _loc7_.recombineUrl();
               }
               _loc2_[_loc4_.itag] = {
                  "stream":_loc4_.url || _loc4_.stream,
                  "conn":_loc4_.conn,
                  "fallbackHost":_loc4_.fallback_host,
                  "stereo3d":_loc4_.stereo3d == "1",
                  "type":_loc4_.type
               };
            }
         }
         return _loc2_;
      }
      
      public function get token() : String
      {
         return this.tokenValue;
      }
      
      public function get suppressShare() : Boolean
      {
         return this.suppressShareValue;
      }
      
      public function set audioTrack(param1:String) : void
      {
         if(this.audioTrackValue != param1 && this.isValidAudioTrack(param1))
         {
            this.audioTrackValue = param1;
            if(!this.isFormatAvailable(this.formatValue))
            {
               dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this,VideoDataEvent.FORMAT_DISABLED));
            }
         }
      }
      
      public function get endscreenModule() : String
      {
         return this.endscreenModuleValue;
      }
      
      public function get isHls() : Boolean
      {
         return this.isHlsVariantPlaylist || this.formatValue.isHls;
      }
      
      public function get title() : String
      {
         return this.titleValue;
      }
      
      protected function applyFlashVars(param1:Object, param2:Object = null) : void
      {
         param2 ||= {};
         this.applyCommonLoadedInfo(param1);
         this.applyCommonVideoInfo(param1);
         if(param1.ftok)
         {
            this.finskyToken = param1.ftok;
         }
         if(param1.aptok)
         {
            this.adobePassToken = param1.aptok;
         }
         if(param1.autoplay)
         {
            this.autoPlay = param1.autoplay == "1";
         }
         if(param2.cctp)
         {
            this.cuedClickToPlay = param2.cctp == "1";
         }
         if(Boolean(param1.flvurl) && UrlValidator.isTrustedDomain(param1.flvurl))
         {
            this.flvUrlValue = param1.flvurl;
         }
         if(param1.thirdPartyFlvUrl)
         {
            this.thirdPartyFlvUrlValue = param1.thirdPartyFlvUrl;
         }
         if(UrlValidator.isTrustedDomain(param1.iurl))
         {
            this.imageUrlValue = param1.iurl;
         }
         if(UrlValidator.isTrustedDomain(param1.iurlsd))
         {
            this.sdImageUrlValue = param1.iurlsd;
         }
         if(UrlValidator.isTrustedDomain(param1.iurlmaxres))
         {
            this.maxresImageUrlValue = param1.iurlmaxres;
         }
         if(param1.infringe == "1")
         {
            this.infringeValue = true;
         }
         if(param1.sdetail)
         {
            this.sdetail = param1.sdetail;
         }
         if(param1.can_watch_later)
         {
            this.canWatchLater = param1.can_watch_later == "1";
         }
         if(param1.csi_page_type)
         {
            this.csiPageType = param1.csi_page_type;
         }
         if(param1.cyc)
         {
            this.cycToken = param1.cyc;
         }
         if(param1.start)
         {
            this.startSeconds = Number(param1.start);
            if(param1.resume != "1" && !this.isLive)
            {
               this.clipStart = this.startSeconds;
            }
         }
         if(param1.end)
         {
            this.clipEnd = Number(param1.end) || NaN;
         }
         if(param1.ss == "1")
         {
            this.suppressShareValue = true;
         }
         if(Boolean(param1.t) || Boolean(param1.token))
         {
            if(param1.t)
            {
               this.token = param1.t;
            }
            else if(param1.token)
            {
               this.token = param1.token;
            }
            this.dateUrlSigned = new Date();
            if(Boolean(param1.timestamp) && param1.timestamp * 1000 < this.dateUrlSigned.getTime())
            {
               this.dateUrlSigned.setTime(param1.timestamp * 1000);
            }
         }
         if(Boolean(param1.track_embed) && param1.track_embed == "1")
         {
            this.trackingTokenValue = "1";
         }
         if(param1.tk)
         {
            this.trackingTokenValue = param1.tk;
         }
         if(param1.video_id)
         {
            this.videoIdValue = param1.video_id;
         }
         if(param1.docid)
         {
            this.videoIdValue = param1.docid;
         }
         if(Boolean(param1.sw) && Math.random() * 100 < 10)
         {
            this.isRealTimeLoggable = true;
         }
         if(param1.is_doubleclick_tracked == "1")
         {
            this.isDoubleclickTracked = true;
         }
         if(param1.ajax_preroll)
         {
            this.prerolls.push("ajax_preroll");
         }
         if(param1.livemonitor == "1")
         {
            this.isLiveMonitor = true;
         }
         if(param1.osig)
         {
            this.oceanSig = param1.osig;
         }
         this.copyObject(param1,this.rawVideoInfoValue);
      }
      
      public function get videoBitrate() : Number
      {
         return this.videoBitrateValue;
      }
      
      public function get sourceData() : String
      {
         return this.sourceDataValue;
      }
      
      public function get regionModule() : String
      {
         return this.regionModuleValue;
      }
      
      public function getExternalVideoData(param1:Boolean) : Object
      {
         return !param1 ? this.rawVideoInfo : {
            "video_id":this.videoId,
            "title":this.title,
            "author":this.author
         };
      }
      
      public function get watermarkUrl() : String
      {
         return this.watermarkUrlValue;
      }
      
      public function get sourceId() : String
      {
         return this.sourceIdValue;
      }
      
      public function callSetAwesome(param1:URLRequest) : void
      {
         this.setAwesomeLoader = new RequestLoader();
         this.setAwesomeLoader.loadRequest(param1);
      }
      
      public function getFormatForRect(param1:Rectangle) : VideoFormat
      {
         var _loc7_:VideoFormat = null;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc2_:VideoFormat = new VideoFormat();
         var _loc3_:int = param1.width;
         var _loc4_:int = param1.height;
         var _loc5_:Number = 16 / 9;
         if(_loc3_ > Math.round(_loc5_ * _loc4_))
         {
            _loc3_ = Math.round(_loc5_ * _loc4_);
         }
         var _loc6_:int = _loc3_ * _loc4_;
         for each(_loc7_ in this.formatListValue)
         {
            _loc8_ = _loc7_.size.width * _loc7_.size.height;
            _loc9_ = _loc7_.quality == VideoQuality.MEDIUM ? 0.26 : 0.85;
            if(_loc8_ * _loc9_ < _loc6_ && this.isFormatAllowedToPlay(_loc7_))
            {
               return _loc7_;
            }
            _loc2_ = _loc7_;
         }
         return _loc2_;
      }
      
      public function hasTag(param1:String) : Boolean
      {
         return param1 in this.keywords;
      }
      
      public function get isPauseEnabled() : Boolean
      {
         return !(this.isHlsLiveOnly || this.partnerId == String(PlayerType.AKAMAI_LIVE));
      }
      
      protected function resetGetVideoInfoLoader() : void
      {
         this.getVideoInfoLoader.removeEventListener(Event.COMPLETE,this.onGetVideoInfo);
         this.getVideoInfoLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onGetVideoInfoError);
         this.getVideoInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onGetVideoInfoError);
         this.getVideoInfoLoader = null;
      }
      
      public function getFormatForQuality(param1:VideoQuality) : VideoFormat
      {
         var _loc3_:VideoFormat = null;
         var _loc2_:VideoFormat = new VideoFormat();
         for each(_loc3_ in this.formatListValue)
         {
            if(this.isFormatAllowedToPlay(_loc3_))
            {
               _loc2_ = _loc3_;
               if(param1 >= _loc3_.quality)
               {
                  return _loc3_;
               }
            }
         }
         return _loc2_;
      }
      
      public function getAudioTracks() : Array
      {
         var _loc3_:VideoFormat = null;
         var _loc1_:Object = {};
         var _loc2_:Array = [];
         for each(_loc3_ in this.formatListValue)
         {
            if(!_loc1_[_loc3_.audioTrack.name])
            {
               _loc2_.push(_loc3_.audioTrack);
               _loc1_[_loc3_.audioTrack.name] = true;
            }
         }
         _loc2_.sortOn("name");
         return _loc2_;
      }
      
      public function get enhanceModule() : String
      {
         return this.enhanceModuleValue;
      }
      
      public function unsubscribe() : void
      {
         this.unsubscribeRequest.data.s = this.subscriptionId;
         this.loadSubscription(this.unsubscribeRequest);
      }
      
      public function get flvUrl() : String
      {
         return this.flvUrlValue;
      }
      
      public function get suggestions() : Array
      {
         return this.suggestionsValue;
      }
      
      public function get maxresImageUrl() : String
      {
         return this.maxresImageUrlValue;
      }
      
      protected function parseWatermark(param1:String) : void
      {
         var _loc2_:Array = param1.split(",");
         switch(_loc2_.length)
         {
            case 3:
               this.watermarkHdValue = _loc2_[2];
            case 2:
               this.watermarkValue = _loc2_[1];
               this.watermarkUrlValue = _loc2_[0];
         }
         if(!UrlValidator.isTrustedDomain(this.watermarkValue))
         {
            this.watermarkValue = null;
         }
         if(!UrlValidator.isTrustedDomain(this.watermarkHdValue))
         {
            this.watermarkHdValue = null;
         }
      }
      
      protected function parseBrandedSmallBannerImageLink(param1:String) : void
      {
         var imageMap:XML = null;
         var value:String = param1;
         try
         {
            imageMap = XML(value);
            this.brandedSmallBannerImageLink = imageMap.area["href"];
         }
         catch(e:Error)
         {
            brandedSmallBannerImageLink = "";
         }
      }
      
      public function get videoId() : String
      {
         return this.videoIdValue;
      }
      
      public function get playbackIdToken() : String
      {
         return this.playbackIdTokenValue;
      }
      
      public function get audioTrack() : String
      {
         return this.audioTrackValue;
      }
      
      protected function copyObject(param1:Object, param2:Object) : Object
      {
         var _loc3_:String = null;
         for(_loc3_ in param1)
         {
            param2[_loc3_] = String(param1[_loc3_]);
         }
         return param2;
      }
      
      public function setMosaicSpecRequest(param1:URLRequest) : void
      {
         var _loc2_:URLLoader = new URLLoader();
         _loc2_.dataFormat = URLLoaderDataFormat.VARIABLES;
         _loc2_.addEventListener(Event.COMPLETE,this.onGetMosaicSpec);
         _loc2_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onGetMosaicSpecError);
         _loc2_.load(param1);
      }
      
      public function get interstitial() : String
      {
         return this.interstitialValue;
      }
      
      public function hasFormat() : Boolean
      {
         return this.formatValue && !this.formatValue.equals(new VideoFormat()) || Boolean(this.flvUrlValue) || Boolean(this.thirdPartyFlvUrlValue);
      }
      
      public function getLoggingOptions() : Object
      {
         var _loc1_:Object = {};
         if(this.sdetail)
         {
            _loc1_.sdetail = encodeURIComponent(this.sdetail);
         }
         if(this.playbackIdTokenValue)
         {
            _loc1_.plid = this.playbackIdTokenValue;
         }
         if(this.formatValue.name != "")
         {
            _loc1_.fmt = this.formatValue.name;
         }
         if(this.formatValue.audioName != "")
         {
            _loc1_.afmt = this.formatValue.audioName;
         }
         if(this.errorCodeValue)
         {
            _loc1_.ec = this.errorCodeValue;
            this.errorCodeValue = "";
         }
         if(this.partnerId)
         {
            _loc1_.partnerid = this.partnerId;
         }
         if(this.autoPlay)
         {
            _loc1_.autoplay = 1;
         }
         if(this.keyframesValue)
         {
            _loc1_.haskeyframes = 1;
         }
         if(this.cuedClickToPlay)
         {
            _loc1_.cctp = 1;
         }
         if(this.claimedEmbedVideo)
         {
            _loc1_.cev = 1;
         }
         if(this.scriptedClickToPlay)
         {
            _loc1_.sctp = 1;
         }
         if(this.scriptedPlayback)
         {
            _loc1_.splay = 1;
         }
         if(this.isTransportRtmp())
         {
            _loc1_.sprot = 1;
         }
         if(this.partnerTrackingTokenValue)
         {
            _loc1_.ptk = this.partnerTrackingTokenValue;
         }
         if(this.userSubscribedToChannel)
         {
            _loc1_.subscribed = this.userSubscribedToChannel;
         }
         if(this.sourceIdValue)
         {
            _loc1_.sourceid = this.sourceIdValue;
         }
         if(this.sourceDataValue)
         {
            _loc1_.sd = this.sourceDataValue;
         }
         if(this.metaDataLoaded)
         {
            _loc1_.md = 1;
         }
         if(this.payPerStream)
         {
            _loc1_.pps = 1;
         }
         if(this.csiPageType)
         {
            _loc1_.csipt = this.csiPageType;
         }
         if(this.netConnectionClosedEventCount > 0)
         {
            _loc1_.ncc = this.netConnectionClosedEventCount;
         }
         if(this.enableRealtimeLogging)
         {
            _loc1_.rtl = 1;
         }
         if(this.conversionConfig.rmktEnabled)
         {
            _loc1_.rmkt = 1;
         }
         if(this.videoStoryboard)
         {
            _loc1_.hasstoryboard = 1;
         }
         if(this.muffleFactor != DEFAULT_MUFFLE)
         {
            _loc1_.audiofactor = this.muffleFactor;
         }
         if(this.playerDefaultVideoIdsToHtml5 > -1)
         {
            _loc1_.hbid = this.playerDefaultVideoIdsToHtml5;
         }
         if(!isNaN(this.initialDetailedPingJitter))
         {
            _loc1_.idpj = this.initialDetailedPingJitter;
         }
         if(!isNaN(this.longDetailedPingJitter))
         {
            _loc1_.ldpj = this.longDetailedPingJitter;
         }
         if(this.isLive)
         {
            _loc1_.live = this.isSeekEnabled() ? "dvr" : "live";
         }
         if(this.clipEnd)
         {
            _loc1_.end = this.clipEnd;
         }
         if(this.clipStart)
         {
            _loc1_.start = this.clipStart;
         }
         if(this.delayedViewcountThreshold > 0 && !this.isDelayedViewcountLogged)
         {
            _loc1_.delay = this.delayedViewcountThreshold;
         }
         if(this.adaptiveByDefault)
         {
            _loc1_.abd = 1;
         }
         if(this.clientPlaybackNonce)
         {
            _loc1_.cpn = this.clientPlaybackNonce;
         }
         return _loc1_;
      }
      
      public function setFormatList(param1:String, param2:String, param3:String = null) : void
      {
         this.formatListValue = this.parseFormatList(param1,param2,param3);
      }
      
      public function get payPerStream() : Boolean
      {
         return !isNaN(this.secondsToExpirationValue);
      }
      
      protected function getPlaylist(param1:Function) : void
      {
         if(this.playlistLoader)
         {
            return;
         }
         this.playlistLoader = new RequestLoader();
         this.playlistLoader.addEventListener(Event.COMPLETE,param1);
         this.playlistLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onPlaylistError);
         this.playlistLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onPlaylistError);
         var _loc2_:URLRequest = new URLRequest(this.playlistUrl);
         _loc2_.data = new RequestVariables();
         _loc2_.data.cpn = this.clientPlaybackNonce;
         this.playlistLoader.loadRequest(_loc2_,URLLoaderDataFormat.TEXT);
      }
      
      public function enableFormat(param1:VideoFormat) : void
      {
         if(!param1.enabled && this.formatListValue.indexOf(param1) >= 0)
         {
            param1.enabled = true;
            dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this,VideoDataEvent.FORMAT_DISABLED));
         }
      }
      
      public function onPrerollReady(param1:String) : void
      {
         var uid:String = param1;
         this.prerolls = this.prerolls.filter(function(param1:*, param2:int, param3:Array):Boolean
         {
            return uid != param1;
         });
      }
      
      protected function extractHostFromUrl(param1:String) : String
      {
         return param1 && param1.split("/",3).join("/") || "";
      }
      
      public function setEnded(param1:Boolean, param2:Number) : void
      {
         if(param1)
         {
            if(this.isHls && this.durationValue != this.format.hlsPlaylist.duration)
            {
               this.durationValue = this.format.hlsPlaylist.duration;
            }
            else
            {
               this.durationValue = param2;
            }
            dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this));
         }
      }
      
      public function get stream() : String
      {
         return this.formatValue.url;
      }
      
      public function set startSeconds(param1:Number) : void
      {
         if(param1 != this.startSecondsValue)
         {
            this.startSecondsValue = param1;
            dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this));
         }
      }
      
      public function get sdImageUrl() : String
      {
         return this.sdImageUrlValue;
      }
      
      public function get totalBytes() : Number
      {
         return this.totalBytesValue;
      }
      
      public function get enableRealtimeLogging() : Boolean
      {
         return this.isRealTimeLoggable;
      }
      
      protected function applyFlvMetaData(param1:Object) : void
      {
         var _loc2_:KeyframeTuple = null;
         this.pingUrl = param1.purl || "";
         this.pingMessage = param1.pmsg || "";
         if(param1.bytelength is Number)
         {
            this.totalBytesValue = param1.bytelength;
         }
         else if(param1.filesize is Number)
         {
            this.totalBytesValue = param1.filesize;
         }
         if(param1.videodatarate is Number)
         {
            this.videoBitrateValue = param1.videodatarate;
         }
         if(param1.httphostheader is String)
         {
            this.httpHostHeaderValue = param1.httphostheader;
         }
         this.sourceDataValue = param1.sourcedata is String ? param1.sourcedata : "";
         if(param1.haskeyframes)
         {
            this.keyframesValue = param1.keyframes;
         }
         if(param1.starttime is Number)
         {
            if(!this.isTransportRtmp() || this.isTransportRtmp() && this.isAlwaysBuffered() || param1.starttime > 0)
            {
               this.startSeconds = param1.starttime;
            }
            this.videoFileByteOffset = Math.floor(this.startSeconds * (param1.bytesTotal / (this.duration - this.startSeconds)));
         }
         else if(this.keyframesValue)
         {
            _loc2_ = this.findClosestKeyframeBefore(this.startSeconds);
            this.videoFileByteOffset = this.startSeconds == 0 ? 0 : _loc2_.byteOffset;
         }
      }
      
      public function get isAdvertiserVideo() : Boolean
      {
         return this.isConversionTracked || Boolean(this.promotedVideoBillableUrlValue) || this.isAdvertiserVideoValue;
      }
      
      public function get authKey() : String
      {
         return this.authKeyValue;
      }
      
      public function applyGetVideoInfo(param1:URLVariables) : void
      {
         this.applyCommonLoadedInfo(param1);
         this.applyCommonVideoInfo(param1);
         if(param1.token)
         {
            this.token = param1.token;
            this.dateUrlSigned = new Date();
         }
         if(param1.muted == "1")
         {
            this.infringeValue = true;
         }
         if(Boolean(param1.track_embed) && param1.track_embed == "1")
         {
            this.trackingTokenValue = param1.track_embed;
         }
         this.needsLiveUpdate = false;
         var _loc2_:Boolean = true;
         if(this.ypcModuleValue)
         {
            _loc2_ = false;
         }
         else if(Boolean(this.frescaModuleValue) && !this.formatListValue.length)
         {
            _loc2_ = false;
         }
         if(_loc2_)
         {
            ALL_VIDEOS[this.videoId] = this;
         }
         else
         {
            delete ALL_VIDEOS[this.videoId];
         }
         if(!this.isGetVideoInfoLoaded)
         {
            this.copyObject(param1,this.rawVideoInfoValue);
            dispatchEvent(new GetVideoInfoEvent(GetVideoInfoEvent.INFO,param1));
            dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this,VideoDataEvent.VIDEO_INFO));
         }
         this.isGetVideoInfoLoaded = true;
      }
      
      public function get secondsToExpiration() : Number
      {
         return this.secondsToExpirationValue;
      }
      
      protected function onGetMosaicSpecError(param1:Event) : void
      {
      }
      
      public function get promotedVideoConversionUrl() : String
      {
         return this.promotedVideoConversionUrlValue;
      }
      
      protected function onPlaylistError(param1:ErrorEvent) : void
      {
         this.resetPlaylistLoader();
         dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,param1.text));
      }
      
      protected function onGetMosaicSpec(param1:Event) : void
      {
         var _loc2_:URLLoader = URLLoader(param1.target);
         if(_loc2_.data && _loc2_.data.status == "ok")
         {
            this.videoStoryboard = new VideoStoryboard(_loc2_.data.mosaic_spec);
            this.videoStoryboard.removeOrInitializeDefaultLevel(this.durationValue);
            this.mosaicLoader = new MosaicLoader(this.videoStoryboard);
            dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this));
         }
      }
      
      protected function onSubscriptionLoaded(param1:Event) : void
      {
         var _loc2_:XML = XML(param1.target.data);
         this.subscriptionId = _loc2_.html_content..response.id || "";
         if(this.subscriptionId)
         {
            dispatchEvent(new SubscriptionEvent(SubscriptionEvent.SUBSCRIBED));
         }
         else
         {
            dispatchEvent(new SubscriptionEvent(SubscriptionEvent.UNSUBSCRIBED));
         }
      }
      
      protected function resetPlaylistLoader() : void
      {
         this.playlistLoader.removeEventListener(Event.COMPLETE,this.onHlsVariantPlaylist);
         this.playlistLoader.removeEventListener(Event.COMPLETE,this.onMpdXml);
         this.playlistLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onPlaylistError);
         this.playlistLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onPlaylistError);
         this.playlistLoader = null;
      }
      
      public function get startSeconds() : Number
      {
         return this.startSecondsValue || 0;
      }
      
      public function get isHd() : Boolean
      {
         return Boolean(this.formatValue.quality) && this.formatValue.quality.isHd();
      }
      
      public function get keyframes() : Object
      {
         return this.keyframesValue;
      }
      
      public function isAlwaysBuffered() : Boolean
      {
         return int(this.partnerId) == PlayerType.GOOGLE_RTMP;
      }
      
      public function isFormatAllowedToPlay(param1:VideoFormat) : Boolean
      {
         return this.isFormatAvailable(param1) && param1.enabled;
      }
      
      protected function onMpdXml(param1:Event) : void
      {
         var _loc2_:MpdParser = new MpdParser();
         _loc2_.parseString(this.playlistLoader.data);
         this.resetPlaylistLoader();
         if(_loc2_.valid)
         {
            this.formatListValue = _loc2_.getFormats();
            this.durationValue = Number(_loc2_.getDurationSeconds());
            dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this,VideoDataEvent.VIDEO_INFO));
         }
         else
         {
            dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Invalid MPD"));
         }
      }
      
      public function set threeDEnabled(param1:Boolean) : void
      {
         this.threeDEnabledValue = param1;
         dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this,VideoDataEvent.VIDEO_INFO));
      }
      
      public function set token(param1:String) : void
      {
         this.tokenValue = param1;
      }
      
      public function get streamingTextModule() : String
      {
         return this.streamingTextModuleValue;
      }
      
      public function set format(param1:VideoFormat) : void
      {
         if(!param1.equals(this.formatValue))
         {
            this.formatValue = param1;
            if(this.isSeekEnabled() && param1.hlsPlaylist && this.mosaicLoader is LiveMosaicLoader)
            {
               LiveMosaicLoader(this.mosaicLoader).hlsPlaylist = param1.hlsPlaylist;
            }
            dispatchEvent(new VideoDataEvent(VideoDataEvent.CHANGE,this,VideoDataEvent.FORMAT_CHANGE));
         }
         if(this.isTransportRtmp())
         {
            this.isRealTimeLoggable = true;
         }
      }
      
      public function get format() : VideoFormat
      {
         return this.formatValue;
      }
   }
}

