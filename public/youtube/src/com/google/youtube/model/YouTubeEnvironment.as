package com.google.youtube.model
{
   import com.google.utils.RequestLoader;
   import com.google.utils.RequestVariables;
   import com.google.utils.Url;
   import com.google.youtube.event.AddCallbackEvent;
   import com.google.youtube.event.ExternalEvent;
   import com.google.youtube.players.IVideoInfoProvider;
   import com.google.youtube.ui.Theme;
   import com.google.youtube.util.ExternalInterfaceWrapper;
   import com.google.youtube.util.SignatureDecipher;
   import com.google.youtube.util.StageAmbassador;
   import com.google.youtube.util.StreamingStats;
   import com.google.youtube.util.UrlValidator;
   import com.google.youtube.util.hls.HlsPlaylist;
   import com.google.youtube.util.hls.HlsPlaylistLoader;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.geom.Rectangle;
   import flash.net.ObjectEncoding;
   import flash.net.SharedObject;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.utils.describeType;
   
   public class YouTubeEnvironment extends Environment implements IModuleEnvironment, IVideoInfoProvider
   {
      
      public static const EXTERNAL_READY_HANDLER:String = "onYouTubePlayerReady";
      
      public static const VALID_READY_HANDLER:RegExp = /^[a-zA-Z_$][a-zA-Z0-9._$]*$/;
      
      public static const EMBED_IFRAME_TEMPLATE:String = "<iframe width=\"640\" height=\"360\" src=\"{video_url}\"" + " frameborder=\"0\" allowfullscreen></iframe>";
      
      public static const EMBED_HTML_URL_REGEXP:RegExp = /{video_url}/g;
      
      public static const HOSTS_REGEXP:RegExp = /^(https?:\/\/([\w-.]+\.youtube(?:education)?\.com)\/)/;
      
      private static const AD_FORMAT_REGEXP:RegExp = /^(\d*)_((\d*)_?(\d*)?)$/;
      
      public static const EXTERNAL_URL_GETTER:String = "document.location.href.toString";
      
      protected static const EXTERNAL_REFERRER_GETTER:String = "document.referrer.toString";
      
      public static const YOUTUBE_REPORT_ISSUE_URL:String = "www.google.com/support/youtube/bin/request.py";
      
      public static const PLAY_REPORT_ISSUE_URL:String = "http://support.google.com/googleplay/";
      
      public static const GET_MOSAIC_SPEC_URL:String = "get_mosaic_spec?";
      
      public static const GET_VIDEO_URL:String = "get_video?";
      
      public static const GET_VIDEO_INFO_URL:String = "get_video_info";
      
      public static const API_VIDEO_INFO_URL:String = "api_video_info";
      
      public static const SET_AWESOME_URL:String = "set_awesome?";
      
      public static const LIKE_URL:String = "watch_actions_ajax?action_like_video=1";
      
      public static const DISLIKE_URL:String = "watch_actions_ajax?action_dislike_video=1";
      
      public static const TOKEN_AJAX_URL:String = "token_ajax";
      
      public static const THUMBNAIL_SHARDS:Number = 4;
      
      public static const S2_URL:String = "s2.youtube.com/s";
      
      public static const USER_WATCH_URL:String = "user_watch?";
      
      public static const VIDEO_WATCH_URL:String = "watch?";
      
      public static const ACCOUNT_PLAYBACK_URL:String = "account_playback";
      
      public static const ADD_TO_AJAX_URL:String = "addto_ajax?";
      
      public static const CHANNEL_ID_URL:String = "channel/UC";
      
      public static const CHANNEL_URL:String = "user/";
      
      public static const CHANNEL_SUBSCRIBE_URL:String = "subscription_center";
      
      public static const CHANNEL_CAMPAIGN_TAB_COMPONENT:String = "campaign";
      
      public static const VIDEO_METADATA_URL:String = "get_video_metadata";
      
      public static const EMBED_URL:String = "embed/";
      
      public static const SUBSCRIPTION_URL:String = "subscription_ajax";
      
      public static const AUTO_HIDE_OFF:int = 0;
      
      public static const AUTO_HIDE_ON:int = 1;
      
      public static const AUTO_HIDE_FADE:int = 2;
      
      public static const AUTO_HIDE_AUTO_EMBEDS:int = 3;
      
      public static const LIKE_SENTIMENT:int = 0;
      
      public static const DISLIKE_SENTIMENT:int = 1;
      
      public static const AJAX_SUCCESS:String = "0";
      
      public static const AJAX_DUPLICATE:String = "6";
      
      public static var LIVE_BASE_URL:String = "http://www.youtube.com/";
      
      public static var LIVE_BASE_IMG_URL:String = "http://i.ytimg.com/";
      
      protected static const LOG_ERROR_PROB:Number = 0.01;
      
      protected static const MAX_ERROR_COUNT:Number = 1;
      
      protected static const MAX_STACK_LENGTH:Number = 1200;
      
      protected static const STREAMING_STATS_PROB:Number = 0.1;
      
      public static const ATTRIB_ALLOWED_VALUES:Array = ["ad-trueview-indisplay-pv","ad-trueview-insearch"];
      
      public static const PLAYER_STYLE_AD_FORMAT_TYPE_MAP:Object = {
         "yva":AD_FORMAT_TYPE_YVA,
         "instream":AD_FORMAT_TYPE_INSTREAM,
         "trueview-instream":AD_FORMAT_TYPE_INSTREAM,
         "trueview-inslate":AD_FORMAT_TYPE_USER_CHOICE,
         "trueview-indisplay-ctp":AD_FORMAT_TYPE_INDISPLAY
      };
      
      public static const ATTRIB_AD_FORMAT_TYPE_MAP:Object = {
         "ad-trueview-indisplay-pv":AD_FORMAT_TYPE_INDISPLAY,
         "ad-trueview-insearch":AD_FORMAT_TYPE_INSEARCH
      };
      
      public static const AD_FORMAT_TYPE_NONE:uint = 0;
      
      public static const AD_FORMAT_TYPE_INSTREAM:uint = 2;
      
      public static const AD_FORMAT_TYPE_USER_CHOICE:uint = 4;
      
      public static const AD_FORMAT_TYPE_INDISPLAY:uint = 6;
      
      public static const AD_FORMAT_TYPE_INSEARCH:uint = 7;
      
      public static const AD_FORMAT_TYPE_YVA:uint = 8;
      
      public static const AD_FORMAT_TYPE_ENGAGEMENT_AD:uint = 9;
      
      public static const AD_FORMAT_SUB_TYPE_NONE:uint = 0;
      
      public static const AD_FORMAT_SUB_TYPE_SKIPPABLE:uint = 1;
      
      public var showPreloader:Boolean = true;
      
      protected var playerStyleValue:String = "";
      
      public var allowFullScreen:Boolean = true;
      
      public var periodicBufferHealthStatsExperiment:Boolean = false;
      
      public var fastSpliceExperiment:Boolean = false;
      
      public var experiments:Experiments;
      
      public var showInfoOnlyInFullScreen:Boolean = true;
      
      public var referrer:String = "";
      
      protected var toastedAndButteredSlicedBread:String = "";
      
      public var fullScreenHd:Boolean = false;
      
      protected var policyDefaultsApplied:Boolean = false;
      
      public var apiInterface:Array;
      
      public var showYouTubeButtonOverride:Boolean = false;
      
      protected var logWatchValue:Boolean = false;
      
      public var playNext:String = "";
      
      public var showLogo:Boolean = true;
      
      public var gestures:Boolean = true;
      
      public var videoQualityPref:VideoQuality;
      
      public var watchXlbUrl:String = "";
      
      public var plusOneInlineAnnotationExperiment:Boolean = false;
      
      public var hosted:Boolean = false;
      
      protected var adSenseAdFormatLoggingValue:uint;
      
      public var devApiKey:String = "";
      
      public var sourceFeature:String = "";
      
      public var stageVideoForbidden:Boolean = false;
      
      public var adSenseAdGroupCreativeId:String = "";
      
      public var loaderUrl:String = "";
      
      public var showLargePlayButton:Boolean = true;
      
      protected var userGenderValue:String = "";
      
      public var movePromotedVideoBillingTo5SecsExperiment:Boolean = false;
      
      public var deviceModel:String = "";
      
      public var enableSizeButton:Boolean = true;
      
      public var fullScreenSourceRectExperiment:Boolean = false;
      
      protected var csiArgs:Object;
      
      public var deviceBrowserVersion:String = "";
      
      public var enableKeyboard:Boolean = true;
      
      protected var isPlaybackLoggableValue:Boolean = true;
      
      protected var isYouTubeLoggedValue:Boolean = true;
      
      protected var viewAttribution:String = "";
      
      protected var userAgeValue:String = "";
      
      public var deviceOsVersion:String = "";
      
      public var sendSegmentsToTempLogs:Boolean = false;
      
      public var framer:String;
      
      public var contextMenuItems:Array;
      
      public var showPopout:Boolean = false;
      
      public var openChunksEarly:Boolean = false;
      
      public var maxBufferLengthValue:Number = 5;
      
      public var query:String = "";
      
      public var contentRegion:String = "";
      
      public var maybeHosted:Boolean = false;
      
      public var deviceBrand:String = "";
      
      public var lastStackTrace:String;
      
      public var backgroundColor:Number = 0;
      
      public var audioTrackPref:String;
      
      public var deviceOs:String = "";
      
      public var csiLogged:Boolean = false;
      
      public var playlistModule:String;
      
      public var enableRateControl:Boolean = false;
      
      public var showControls:Boolean = true;
      
      public var devicePlatform:String = "";
      
      public var eurl:String = "";
      
      public var movePromotedVideoBillingTo7SecsExperiment:Boolean = false;
      
      protected var videoStatsNamespaceValue:String = "yt";
      
      public var deviceNetwork:String = "";
      
      public var vssResumeableExperiment:Boolean = false;
      
      public var moreAudioNormalizationExperiment:Boolean = false;
      
      public var sessionToken:String = "";
      
      public var showDefaultYouTubeWatermark:Boolean = false;
      
      public var enableCsiLogging:Boolean = false;
      
      protected var adFormatSubTypeValue:uint;
      
      public var adaptiveExperiment:Boolean = false;
      
      protected var eventLabelValue:String = "";
      
      public var suppressEndScreenShare:Boolean = false;
      
      protected var reportAbuseUrl:String = "http://www.google.com/support/bin/static.py?page=ts.cs&ts=1114905";
      
      public var enableDiskByteSource:Boolean = false;
      
      public var useSsl:Boolean = false;
      
      protected var csiTimings:Object;
      
      public var tagQueueReadaheadExperiment:Boolean = false;
      
      protected var baseUrlValue:String = "";
      
      public var enableDvrTagSource:Boolean = true;
      
      public var samplingWeight:String = "";
      
      public var streamingStatsExperiment:Boolean = false;
      
      public var showInfo:Boolean = true;
      
      public var addCsiToLoggingOptions:Boolean = false;
      
      public var BASE_YT_URL:String = "";
      
      public var playerWide:Boolean = false;
      
      public var playerApiIdValue:String = "";
      
      public var adChannel:String;
      
      public var preferYouTubeTitleTip:Boolean = false;
      
      public var autoHideControls:int = 2;
      
      public var halfSpeedPlaybackExperiment:Boolean = false;
      
      public var messages:IMessages;
      
      public var disableM2TsAudio:Boolean;
      
      public var enableQualityMenu:Boolean = true;
      
      protected var adFormatTypeValue:uint;
      
      public var useDualSplicers:Boolean = false;
      
      public var autoPlay:Boolean = true;
      
      public var defaultBufferLengthValue:Number = 2;
      
      public var consider720LowDef:Boolean = false;
      
      public var heartbeatServerURL:String = "ypc_license_server";
      
      public var deviceInterface:String = "";
      
      public var dvrCacheLimit:uint = 16777216;
      
      public var jsApiCallbackValue:String = "onYouTubePlayerReady";
      
      protected var adFormatValue:String;
      
      public var embellishEmbed:Boolean = false;
      
      public var noSpecialTreatment240p:Boolean = false;
      
      protected var showRelatedVideosValue:Boolean = true;
      
      public var fallbackQualityExperiment:Boolean = false;
      
      public var interfaceLanguage:String = "en_US";
      
      public var viewportRect:Rectangle;
      
      protected var enableJsApiValue:Boolean = false;
      
      public var showReportAbuse:Boolean = false;
      
      public var theme:String;
      
      protected var contentVideoIdentifier:String = "";
      
      public var interactivePreloader:Boolean = true;
      
      public var deviceInterfaceVersion:String = "";
      
      protected var videoStatsEnabledValue:Boolean = true;
      
      public var playlist:Playlist;
      
      public var playerId:String = "";
      
      public var tagStreamingForbiddenExperiment:Boolean = false;
      
      public var initialVideoData:VideoData;
      
      public var errorCount:Number = 0;
      
      public var tagStreamingDvrNoTimeLimit:Boolean = false;
      
      public var deviceBrowser:String = "";
      
      public var videoStatsVersion2Experiment:Boolean = false;
      
      public function YouTubeEnvironment(param1:Object, param2:String = "", param3:String = "")
      {
         var mergeAllParamsWith:Function;
         var trustedParams:Object;
         var allParams:Object = null;
         var url:String = null;
         var xml:XML = null;
         var xmlParams:XMLList = null;
         var needsUnescape:Boolean = false;
         var param:XML = null;
         var value:String = null;
         var contextValue:Object = param1;
         var defaultEventLabel:String = param2;
         var defaultPlayerStyle:String = param3;
         this.contextMenuItems = [];
         this.viewportRect = new Rectangle(0,0,640,360);
         this.apiInterface = [];
         this.experiments = new Experiments();
         this.csiTimings = {"fs":new Date().valueOf()};
         this.csiArgs = {};
         this.videoQualityPref = VideoQuality.AUTO;
         SharedObject.defaultObjectEncoding = ObjectEncoding.AMF0;
         super(contextValue);
         this.eventLabelValue = EventLabel.EMBEDDED;
         allParams = {
            "el":defaultEventLabel,
            "ps":defaultPlayerStyle
         };
         trustedParams = {};
         mergeAllParamsWith = function(param1:Object):void
         {
            var _loc2_:String = null;
            for(_loc2_ in param1)
            {
               allParams[_loc2_] = String(param1[_loc2_]);
            }
         };
         if(context.loaderURL == context.url)
         {
            try
            {
               if(context.sharedEvents is IEventDispatcher)
               {
                  context.sharedEvents.addEventListener(AddCallbackEvent.ADD_CALLBACK,this.onAddCallback);
                  context.sharedEvents.addEventListener(ExternalEvent.EXTERNAL,this.onExternalEvent);
               }
               if(ExternalInterfaceWrapper.available)
               {
                  url = ExternalInterfaceWrapper.call(EXTERNAL_URL_GETTER);
                  if(url == context.loaderURL)
                  {
                     url = ExternalInterfaceWrapper.call(EXTERNAL_REFERRER_GETTER);
                  }
                  this.loaderUrl = url;
               }
            }
            catch(e:SecurityError)
            {
            }
         }
         else if(context.loader)
         {
            try
            {
               if(Boolean(context.loader.root) && UrlValidator.isEmbedLoadingDomain(context.loaderURL))
               {
                  if(context.loader.root.loaderInfo.loaderURL == context.loader.root.loaderInfo.url)
                  {
                     if(ExternalInterfaceWrapper.available)
                     {
                        try
                        {
                           this.loaderUrl = ExternalInterfaceWrapper.call(EXTERNAL_URL_GETTER);
                        }
                        catch(e:SecurityError)
                        {
                        }
                     }
                  }
                  else
                  {
                     this.loaderUrl = context.loader.root.loaderInfo.loaderURL;
                     this.hosted = true;
                  }
                  mergeAllParamsWith(context.loader.root.loaderInfo.parameters);
                  xml = describeType(context.loader.root);
                  xmlParams = xml.metadata.(@name == "Params").arg;
                  needsUnescape = xmlParams.(@key == "escape").@value == "&amp;";
                  for each(param in xmlParams)
                  {
                     value = String(param.@value);
                     if(needsUnescape)
                     {
                        try
                        {
                           value = new XML(value).toString();
                        }
                        catch(e:Error)
                        {
                        }
                     }
                     allParams[param.@key] = value;
                     trustedParams[param.@key] = value;
                  }
               }
               else
               {
                  this.loaderUrl = context.loaderURL;
                  this.hosted = true;
               }
            }
            catch(e:SecurityError)
            {
               loaderUrl = context.loaderURL;
               hosted = true;
            }
         }
         this.loaderUrl = this.loaderUrl || "";
         mergeAllParamsWith(context.parameters);
         this.applyFlashVars(allParams,trustedParams);
         rawParametersValue = allParams;
         this.allowCrossDomainAccess();
      }
      
      public static function getThumbnailUrl(param1:String, param2:String = "default.jpg") : String
      {
         var _loc3_:Number = param1.charCodeAt(0) % THUMBNAIL_SHARDS + 1;
         var _loc4_:String = LIVE_BASE_IMG_URL + "vi/" + escape(param1) + "/" + escape(param2);
         return _loc4_.replace("i.","i" + _loc3_ + ".");
      }
      
      public function get isPlaybackLoggable() : Boolean
      {
         return this.isPlaybackLoggableValue;
      }
      
      public function getAddToTokenAjaxRequest(param1:ListId, param2:String) : URLRequest
      {
         var _loc3_:String = null;
         if(Boolean(param1) && param1.type == ListId.WATCH_LATER_LIST)
         {
            _loc3_ = "?action_get_wl_token=1";
         }
         else
         {
            _loc3_ = "?action_get_addto_token=1&video_id=" + param2;
         }
         return new URLRequest(this.BASE_YT_URL + TOKEN_AJAX_URL + _loc3_ + "&eurl=" + encodeURIComponent(this.eurl));
      }
      
      public function getVideoWatchUrl(param1:VideoData) : String
      {
         if(!param1)
         {
            return "";
         }
         var _loc2_:URLRequest = this.getVideoWatchRequest(param1);
         return _loc2_.url + _loc2_.data.toString();
      }
      
      override public function addCallback(param1:String, param2:Function) : void
      {
         this.apiInterface.push(param1);
         if(context.sharedEvents is IEventDispatcher)
         {
            context.sharedEvents.dispatchEvent(new AddCallbackEvent(AddCallbackEvent.ADD_CALLBACK,param1,this.guardApi(param2)));
         }
      }
      
      public function getVideoChannelUrl(param1:VideoData) : String
      {
         var _loc2_:String = "";
         if(param1)
         {
            if(param1.externalUserId)
            {
               _loc2_ = this.BASE_YT_URL + CHANNEL_ID_URL + param1.externalUserId;
            }
            else if(param1.author)
            {
               _loc2_ = this.BASE_YT_URL + CHANNEL_URL + param1.author;
            }
         }
         return _loc2_;
      }
      
      public function logCsi(param1:VideoData, param2:Date = null, param3:Boolean = false) : void
      {
         var _loc4_:Array = null;
         if(this.enableCsiLogging && !this.csiLogged)
         {
            this.addCsiToLoggingOptions = param3;
            _loc4_ = ["fs",this.csiTimings.fs];
            if(this.csiTimings.fvb)
            {
               _loc4_.push("fvb",this.csiTimings.fvb);
            }
            if(this.csiTimings.vri)
            {
               _loc4_.push("gv",this.csiTimings.vri);
            }
            else
            {
               _loc4_.push("gv",this.csiTimings.gv);
            }
            if(this.csiTimings.fvf)
            {
               _loc4_.push("fvf",this.csiTimings.fvf);
            }
            if(param2)
            {
               _loc4_.push("vr",param2.valueOf());
               this.csiTimings.vr = param2.valueOf();
            }
            this.csiArgs.fmt = "";
            if(param1.format)
            {
               this.csiArgs.fmt = param1.format.name;
            }
            this.csiArgs.plid = param1.playbackIdToken;
            _loc4_.cpn = param1.clientPlaybackNonce;
            this.csiArgs.asv = 3;
            if(param1.isTransportRtmp())
            {
               this.csiArgs.sprot = 1;
            }
            this.csiArgs.fv = escape(Capabilities.version);
            this.csiArgs.docid = param1.videoId;
            if(param1.playerDefaultVideoIdsToHtml5 > -1)
            {
               this.csiArgs.hbid = param1.playerDefaultVideoIdsToHtml5;
            }
            this.callExternal("reportFlashTiming",_loc4_,this.csiArgs.fmt,this.csiArgs.asv,this.csiArgs.plid,this.csiArgs.sprot,this.csiArgs.fv,this.csiArgs.manu);
            this.callExternal("reportTimingMaps",this.csiTimings,this.csiArgs);
            this.csiLogged = true;
         }
      }
      
      public function getStillUrl(param1:VideoData, param2:Number = 430, param3:Number = 320) : String
      {
         if((param2 > 900 || param3 > 600) && Boolean(param1.maxresImageUrl))
         {
            return param1.maxresImageUrl;
         }
         if((param2 > 430 || param3 > 320) && Boolean(param1.sdImageUrl))
         {
            return param1.sdImageUrl;
         }
         if(param1.imageUrl)
         {
            return param1.imageUrl;
         }
         if(param1.videoId)
         {
            return getThumbnailUrl(param1.videoId,"hqdefault.jpg");
         }
         return "";
      }
      
      public function getPlaybackLoggingRequest(param1:VideoData, param2:RequestVariables = null) : URLRequest
      {
         if(param2 == null)
         {
            param2 = new RequestVariables();
         }
         param2.noflv = 1;
         if(param1.isTmi)
         {
            param2.tmi = 1;
         }
         var _loc3_:URLRequest = this.getVideoUrlRequest(param1,param2,true);
         _loc3_.url = this.BASE_YT_URL + GET_VIDEO_URL;
         return _loc3_;
      }
      
      public function getVideoWatchRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:* = null;
         var _loc3_:RequestVariables = new RequestVariables();
         if(!param1.videoId)
         {
            _loc2_ = this.BASE_YT_URL;
         }
         else if(param1.url)
         {
            _loc2_ = param1.url + "&";
         }
         else
         {
            _loc2_ = this.BASE_YT_URL + VIDEO_WATCH_URL;
            _loc3_.v = param1.videoId;
            if(Boolean(this.playlist) && Boolean(this.playlist.listId))
            {
               _loc3_.list = this.playlist.listId;
            }
         }
         if(this.eventLabel)
         {
            _loc3_.feature = "player_" + this.eventLabel;
         }
         var _loc4_:URLRequest = new URLRequest(_loc2_);
         _loc4_.data = _loc3_;
         return _loc4_;
      }
      
      public function get defaultBufferLength() : Number
      {
         return this.defaultBufferLengthValue;
      }
      
      public function applyProtocol(param1:String) : String
      {
         return this.forceProtocol(param1,this.useSsl);
      }
      
      public function get isAdPlayback() : Boolean
      {
         return UrlValidator.isTrustedAdDomain(this.loaderUrl) && this.eventLabel == EventLabel.ADUNIT && this.adFormatTypeValue != AD_FORMAT_TYPE_NONE;
      }
      
      public function getVideoChannelRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:String = this.getVideoChannelUrl(param1);
         return _loc2_ ? new URLRequest(_loc2_) : null;
      }
      
      private function applyCommonLoadedInfo(param1:Object) : void
      {
         if(param1.user_gender)
         {
            this.userGenderValue = param1.user_gender;
         }
         if(param1.user_age)
         {
            this.userAgeValue = param1.user_age;
         }
         if(param1.logwatch)
         {
            this.logWatchValue = true;
         }
         if(param1.fexp)
         {
            this.experiments.importExperimentIdsFromSrc(param1.fexp,Experiments.SRC_YT);
            if(this.experiments.isExperimentActive("908493"))
            {
               this.openChunksEarly = true;
            }
            if(this.experiments.isExperimentActive("908476"))
            {
               this.adaptiveExperiment = true;
            }
            else if(this.experiments.isExperimentActive("908477"))
            {
               this.adaptiveExperiment = true;
               this.useDualSplicers = true;
            }
            else if(this.experiments.isExperimentActive("913529"))
            {
               this.adaptiveExperiment = true;
            }
            else if(this.experiments.isExperimentActive("908456"))
            {
               this.fastSpliceExperiment = true;
               this.adaptiveExperiment = true;
            }
            else if(this.experiments.isExperimentActive("918011"))
            {
               this.adaptiveExperiment = true;
               this.fastSpliceExperiment = true;
               this.tagQueueReadaheadExperiment = true;
            }
            else if(this.experiments.isExperimentActive("908457"))
            {
               this.adaptiveExperiment = true;
               this.consider720LowDef = true;
            }
            else if(this.experiments.isExperimentActive("908488"))
            {
               this.openChunksEarly = true;
            }
            else if(this.experiments.isExperimentActive("908491"))
            {
               this.openChunksEarly = true;
               this.adaptiveExperiment = true;
            }
            else if(this.experiments.isExperimentActive("908494"))
            {
               this.openChunksEarly = false;
               this.adaptiveExperiment = true;
            }
            else if(this.experiments.isExperimentActive("908492"))
            {
               this.fastSpliceExperiment = true;
               this.adaptiveExperiment = true;
               this.useDualSplicers = true;
               this.openChunksEarly = true;
            }
            else if(this.experiments.isExperimentActive("908497"))
            {
               this.adaptiveExperiment = true;
               this.noSpecialTreatment240p = true;
            }
            if(this.experiments.isExperimentActive("904429"))
            {
               this.stageVideoForbidden = true;
            }
            if(this.experiments.isExperimentActive("909709"))
            {
               this.plusOneInlineAnnotationExperiment = true;
            }
            if(this.experiments.isExperimentActive("904448"))
            {
               this.tagStreamingForbiddenExperiment = true;
            }
            else if(this.experiments.isExperimentActive("913553"))
            {
               this.tagStreamingForbiddenExperiment = false;
            }
            if(this.experiments.isExperimentActive("913411"))
            {
               this.moreAudioNormalizationExperiment = true;
            }
            if(this.experiments.isExperimentActive("904828"))
            {
               this.videoStatsVersion2Experiment = true;
            }
            if(this.experiments.isExperimentActive("908467"))
            {
               StageAmbassador.useRaceConditionWorkaround = true;
            }
            if(this.experiments.isExperimentActive("913559"))
            {
               this.vssResumeableExperiment = true;
            }
            if(this.experiments.isExperimentActive("906375"))
            {
               this.movePromotedVideoBillingTo5SecsExperiment = true;
            }
            if(this.experiments.isExperimentActive("906376"))
            {
               this.movePromotedVideoBillingTo7SecsExperiment = true;
            }
            if(this.experiments.isExperimentActive("913421"))
            {
               this.fullScreenSourceRectExperiment = true;
            }
         }
         if(param1.sliced_bread)
         {
            this.openChunksEarly = true;
            this.fastSpliceExperiment = false;
            this.adaptiveExperiment = true;
            this.enableDiskByteSource = true;
            this.halfSpeedPlaybackExperiment = true;
            this.streamingStatsExperiment = true;
            this.fullScreenSourceRectExperiment = true;
         }
         if(Boolean(param1.dashmpd) || Boolean(param1.hlsvp))
         {
            this.fastSpliceExperiment = true;
            this.adaptiveExperiment = true;
            this.enableDvrTagSource = false;
            this.tagQueueReadaheadExperiment = true;
            this.fallbackQualityExperiment = true;
         }
         if(param1.hlsrange)
         {
            HlsPlaylistLoader.enableRangeRequests = true;
         }
         if(param1.hlsstartseq == "0")
         {
            HlsPlaylistLoader.enableStartSeqRequests = false;
         }
         if(param1.hls_live_chunk_readahead)
         {
            HlsPlaylist.liveChunkReadahead = param1.hls_live_chunk_readahead;
         }
         if(param1.hls_monitor_live_chunk_readahead)
         {
            HlsPlaylist.monitorLiveChunkReadahead = param1.hls_monitor_live_chunk_readahead;
         }
         if(param1.hls_max_live_seconds_readahead)
         {
            HlsPlaylist.maxLiveSecondsReadahead = param1.hls_max_live_seconds_readahead;
         }
         if(param1.hls_monitor_max_live_seconds_readahead)
         {
            HlsPlaylist.monitorMaxLiveSecondsReadahead = param1.hls_monitor_max_live_seconds_readahead;
         }
         if(param1.disable_m2ts_audio)
         {
            this.disableM2TsAudio = true;
         }
         if(param1.heartbeat_server_url)
         {
            this.heartbeatServerURL = param1.heartbeat_server_url;
         }
      }
      
      public function resetCsi() : void
      {
         this.csiArgs = {};
         this.csiTimings = {
            "fs":new Date().valueOf(),
            "gv":new Date().valueOf()
         };
         this.csiLogged = false;
         this.addCsiToLoggingOptions = false;
      }
      
      public function callExternal(param1:String, ... rest) : Object
      {
         var result:Object = null;
         var functionName:String = param1;
         var args:Array = rest;
         if(this.enableJsApi && ExternalInterfaceWrapper.available)
         {
            args.unshift(functionName);
            try
            {
               result = ExternalInterfaceWrapper.call.apply(null,args);
            }
            catch(error:Error)
            {
            }
         }
         return result;
      }
      
      public function get reportPeriodicBufferHealth() : Boolean
      {
         return this.periodicBufferHealthStatsExperiment;
      }
      
      public function getSpeedTestRequest() : URLRequest
      {
         return new URLRequest(LIVE_BASE_URL + "my_speed");
      }
      
      public function get enableJsApi() : Boolean
      {
         return this.enableJsApiValue;
      }
      
      public function get showYouTubeButton() : Boolean
      {
         return this.showYouTubeButtonOverride || this.showYouTubeEmbedBranding && this.showControls && !this.preferYouTubeTitleTip;
      }
      
      public function getSourceHost(param1:VideoData) : String
      {
         var _loc2_:String = null;
         if(param1.isTransportRtmp())
         {
            _loc2_ = param1.format.conn;
         }
         else if(param1.flvUrl)
         {
            _loc2_ = param1.flvUrl;
         }
         else
         {
            _loc2_ = this.getVideoUrlRequest(param1,null).url;
         }
         var _loc3_:Url = new Url(_loc2_);
         var _loc4_:String = "_fcs_vhost";
         return _loc4_ in _loc3_.queryVars ? _loc3_.queryVars[_loc4_] : _loc3_.hostname;
      }
      
      public function getSentimentRequest(param1:VideoData, param2:int, param3:RequestVariables = null) : URLRequest
      {
         if(!param1.watchAjaxToken || !(param2 in [LIKE_SENTIMENT,DISLIKE_SENTIMENT]))
         {
            return null;
         }
         if(!param3)
         {
            param3 = new RequestVariables();
         }
         if(Boolean(this.playlist) && Boolean(this.playlist.listId))
         {
            param3.list = this.playlist.listId;
         }
         if(!param3.feature && Boolean(this.eventLabel))
         {
            param3.feature = "player_" + this.eventLabel;
         }
         var _loc4_:String = this.BASE_YT_URL;
         _loc4_ = _loc4_ + (param2 == LIKE_SENTIMENT ? LIKE_URL : DISLIKE_URL);
         _loc4_ = _loc4_ + ("&" + param3);
         var _loc5_:URLRequest = new URLRequest(_loc4_);
         var _loc6_:RequestVariables = new RequestVariables();
         _loc6_.video_id = param1.videoId;
         _loc6_.session_token = param1.watchAjaxToken;
         _loc5_.data = _loc6_;
         _loc5_.method = URLRequestMethod.POST;
         return _loc5_;
      }
      
      public function get autoQuality() : Boolean
      {
         return this.videoQualityPref.equals(VideoQuality.AUTO);
      }
      
      public function getVideoUrl(param1:VideoData, param2:RequestVariables = null) : String
      {
         if(param1.flvUrl)
         {
            return param1.flvUrl + (this.playerStyleValue == PlayerStyle.BLOGGER && param1.startSeconds > 0 ? "&begin=" + Math.round(param1.startSeconds * 1000) : "");
         }
         if(param1.thirdPartyFlvUrl)
         {
            if(this.isAdPlayback)
            {
               return param1.thirdPartyFlvUrl;
            }
            return "";
         }
         var _loc3_:URLRequest = param1.format.name ? this.getVideoFormatUrlRequest(param1,param1.format,param2) : this.getVideoUrlRequest(param1,param2);
         return _loc3_.url + _loc3_.data;
      }
      
      public function applyTimingArgs(param1:Object = null, param2:Object = null) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         for(_loc3_ in param1)
         {
            if(!this.csiTimings[_loc3_])
            {
               this.csiTimings[_loc3_] = param1[_loc3_];
            }
         }
         for(_loc4_ in param2)
         {
            if(!this.csiArgs[_loc4_])
            {
               this.csiArgs[_loc4_] = param2[_loc4_];
            }
         }
      }
      
      public function get logWatch() : Boolean
      {
         return this.logWatchValue;
      }
      
      protected function applyFlashVars(param1:Object, param2:Object = null) : void
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:Boolean = false;
         var _loc9_:String = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         param2 ||= {};
         if(param1.ssl)
         {
            this.useSsl = param1.ssl == "1";
         }
         LIVE_BASE_URL = this.applyProtocol(LIVE_BASE_URL);
         if(Boolean(param1.BASE_YT_URL) && UrlValidator.isTrustedDomain(param1.BASE_YT_URL))
         {
            this.BASE_YT_URL = param1.BASE_YT_URL;
         }
         else if(Boolean(context.loaderURL) && Boolean(context.loaderURL.match(HOSTS_REGEXP)))
         {
            this.BASE_YT_URL = context.loaderURL.match(HOSTS_REGEXP)[1];
         }
         else if(Boolean(this.loaderUrl) && Boolean(this.loaderUrl.match(HOSTS_REGEXP)))
         {
            this.BASE_YT_URL = this.loaderUrl.match(HOSTS_REGEXP)[1];
         }
         else
         {
            this.BASE_YT_URL = LIVE_BASE_URL;
         }
         this.BASE_YT_URL = this.applyProtocol(this.BASE_YT_URL);
         if(Boolean(param1.BASE_URL) && UrlValidator.isTrustedDomain(param1.BASE_URL))
         {
            this.baseUrlValue = param1.BASE_URL;
         }
         LIVE_BASE_IMG_URL = this.applyProtocol(LIVE_BASE_IMG_URL);
         var _loc3_:Boolean = this.isTrustedLoader;
         if(Boolean(param1.el) && (_loc3_ || EventLabel.ALLOW_OVERRIDE.indexOf(param1.el) >= 0))
         {
            this.eventLabelValue = param1.el;
         }
         if(Boolean(param1.ps) && (_loc3_ || PlayerStyle.ALLOW_OVERRIDE.indexOf(param1.ps) >= 0))
         {
            this.playerStyleValue = param1.ps;
         }
         this.adFormatTypeValue = AD_FORMAT_TYPE_NONE;
         this.adFormatSubTypeValue = AD_FORMAT_SUB_TYPE_NONE;
         if(param1.attrib)
         {
            this.viewAttribution = param1.attrib;
            if(ATTRIB_ALLOWED_VALUES.indexOf(this.viewAttribution) >= 0)
            {
               this.adFormatTypeValue = ATTRIB_AD_FORMAT_TYPE_MAP[this.viewAttribution];
            }
         }
         if(UrlValidator.isTrustedAdDomain(this.loaderUrl))
         {
            if(PlayerStyle.AD_PLAYER_STYLES.indexOf(param1.ps) >= 0)
            {
               this.playerStyleValue = param1.ps;
               this.eventLabelValue = EventLabel.ADUNIT;
               this.adFormatTypeValue = PLAYER_STYLE_AD_FORMAT_TYPE_MAP[this.playerStyle];
               this.adFormatSubTypeValue = this.playerStyle == PlayerStyle.TRUEVIEW_INSTREAM ? AD_FORMAT_SUB_TYPE_SKIPPABLE : AD_FORMAT_SUB_TYPE_NONE;
            }
         }
         if(Boolean(param1.adformat) && param1.adformat.search(AD_FORMAT_REGEXP) != -1)
         {
            _loc4_ = param1.adformat;
            _loc5_ = AD_FORMAT_REGEXP.exec(_loc4_);
            _loc6_ = uint(_loc5_[3]);
            _loc7_ = _loc5_.length > 4 ? uint(_loc5_[4]) : AD_FORMAT_SUB_TYPE_NONE;
            _loc8_ = _loc6_ != AD_FORMAT_TYPE_INDISPLAY && _loc6_ != AD_FORMAT_TYPE_INSEARCH && _loc6_ != AD_FORMAT_TYPE_ENGAGEMENT_AD;
            if(UrlValidator.isTrustedAdDomain(this.loaderUrl) || !_loc8_)
            {
               this.adFormatValue = _loc4_;
               this.adFormatTypeValue = _loc6_;
               this.adFormatSubTypeValue = _loc7_;
               if(_loc8_)
               {
                  this.eventLabelValue = EventLabel.ADUNIT;
               }
            }
         }
         this.adSenseAdFormatLoggingValue = 0;
         if(this.adFormatTypeValue)
         {
            switch(this.adFormatTypeValue)
            {
               case AD_FORMAT_TYPE_YVA:
                  this.adSenseAdFormatLoggingValue = 2;
                  break;
               case AD_FORMAT_TYPE_INSTREAM:
                  this.adSenseAdFormatLoggingValue = 3;
                  break;
               case AD_FORMAT_TYPE_INDISPLAY:
                  this.adSenseAdFormatLoggingValue = 5;
                  break;
               case AD_FORMAT_TYPE_USER_CHOICE:
                  this.adSenseAdFormatLoggingValue = 6;
            }
         }
         if(param2.eurl)
         {
            this.eurl = param2.eurl;
         }
         else if(Boolean(param1.eurl) && _loc3_)
         {
            this.eurl = param1.eurl;
         }
         else
         {
            this.eurl = this.loaderUrl.substring(0,127);
         }
         if(param1.referrer)
         {
            this.referrer = param1.referrer;
         }
         this.applyPolicyDefaults();
         this.applyCommonLoadedInfo(param1);
         if(param1.ad_channel)
         {
            this.adChannel = param1.ad_channel;
         }
         if(param1.autohide)
         {
            this.autoHideControls = parseInt(param1.autohide);
         }
         if(param1.autoplay)
         {
            this.autoPlay = param1.autoplay == "1";
         }
         if(param1.bgcolor)
         {
            _loc9_ = param1.bgcolor;
            if(_loc9_.charAt(0) == "#")
            {
               _loc9_ = _loc9_.substring(1);
            }
            if(_loc9_.length == 6)
            {
               this.backgroundColor = parseInt(_loc9_,16);
            }
            else if(_loc9_.length == 3)
            {
               this.backgroundColor = parseInt(_loc9_.charAt(0) + _loc9_.charAt(0) + _loc9_.charAt(1) + _loc9_.charAt(1) + _loc9_.charAt(2) + _loc9_.charAt(2),16);
            }
         }
         this.csiLogged = this.csiLogged || !this.autoPlay;
         if(param1.controls)
         {
            this.showControls = param1.controls != "0";
         }
         if(param1.cr)
         {
            this.contentRegion = param1.cr;
         }
         param2.cctp = this.isIframeEmbed ? param1.cctp : null;
         if(param1.defaultbufferlength)
         {
            _loc10_ = parseInt(param1.defaultbufferlength);
            if(!isNaN(_loc10_))
            {
               this.defaultBufferLengthValue = _loc10_;
            }
         }
         if(param1.c)
         {
            this.deviceInterface = param1.c;
         }
         if(param1.cbrand)
         {
            this.deviceBrand = param1.cbrand;
         }
         if(param1.cbr)
         {
            this.deviceBrowser = param1.cbr;
         }
         if(param1.cbrver)
         {
            this.deviceBrowserVersion = param1.cbrver;
         }
         if(param1.cmodel)
         {
            this.deviceModel = param1.cmodel;
         }
         if(param1.cnetwork)
         {
            this.deviceNetwork = param1.cnetwork;
         }
         if(param1.cos)
         {
            this.deviceOs = param1.cos;
         }
         if(param1.cosver)
         {
            this.deviceOsVersion = param1.cosver;
         }
         if(param1.cplatform)
         {
            this.devicePlatform = param1.cplatform;
         }
         if(param1.cver)
         {
            this.deviceInterfaceVersion = param1.cver;
         }
         if(param1.disablekb)
         {
            this.enableKeyboard = param1.disablekb != "1";
         }
         if(param1.enablecsi)
         {
            this.enableCsiLogging = param1.enablecsi == "1";
         }
         if(param1.enablejsapi)
         {
            this.enableJsApi = param1.enablejsapi == "1";
         }
         if(param1.enablesizebutton)
         {
            this.enableSizeButton = param1.enablesizebutton == "1";
         }
         if(param1.enableratecontrol)
         {
            this.enableRateControl = param1.enableratecontrol == "1";
         }
         if(param1.feature)
         {
            this.sourceFeature = param1.feature;
         }
         else if(param1.f)
         {
            this.sourceFeature = param1.f;
         }
         if(param1.fexp)
         {
            if(this.experiments.isExperimentActive("904701") || this.experiments.isExperimentActive("904706"))
            {
               this.defaultBufferLengthValue = 0.5;
            }
            else if(this.experiments.isExperimentActive("904702"))
            {
               this.defaultBufferLengthValue = 1;
            }
            else if(this.experiments.isExperimentActive("904703"))
            {
               this.defaultBufferLengthValue = 1.5;
            }
            else if(this.experiments.isExperimentActive("904704"))
            {
               this.defaultBufferLengthValue = 2.5;
            }
         }
         if(param1.framer)
         {
            this.framer = param1.framer;
         }
         if(param1.fs)
         {
            this.allowFullScreen = param1.fs != "0";
         }
         if(param1.fshd)
         {
            this.fullScreenHd = param1.fshd == "1";
            this.adaptiveExperiment = this.adaptiveExperiment && !this.fullScreenHd;
         }
         if(param1.gestures)
         {
            this.gestures = param1.gestures == "1";
         }
         if(param1.hl)
         {
            this.interfaceLanguage = param1.hl;
         }
         if(Boolean(param1.jsapicallback) && _loc3_)
         {
            this.jsApiCallback = param1.jsapicallback;
         }
         if(param1.maxbufferlength)
         {
            _loc11_ = parseInt(param1.maxbufferlength);
            if(!isNaN(_loc11_))
            {
               this.maxBufferLengthValue = _loc11_;
            }
         }
         if(param1.mbhosted)
         {
            this.maybeHosted = true;
         }
         if(Boolean(param1.nochrome) && _loc3_)
         {
            this.showPreloader = param1.nochrome != "1";
            this.showLargePlayButton = param1.nochrome != "1";
         }
         if(Boolean(param1.nologo) && _loc3_)
         {
            this.showLogo = param1.nologo != "1";
         }
         if(param1.playerapiid)
         {
            this.playerApiId = param1.playerapiid;
         }
         if(param1.player_id)
         {
            this.playerId = param1.player_id;
         }
         if(param1.player_wide)
         {
            this.playerWide = param1.player_wide == "1";
         }
         if(Boolean(param1.playlist) || Boolean(param1.list))
         {
            this.playlist = new Playlist(param1,param1.loop == "1",param1.shuffle == "1",int(param1.index) || 0,0,this.BASE_YT_URL,this.eventLabel != EventLabel.DETAIL_PAGE);
         }
         if(UrlValidator.isTrustedSwf(param1.playlist_module))
         {
            this.playlistModule = param1.playlist_module;
         }
         if(param1.playNext)
         {
            this.playNext = param1.playNext;
         }
         if(param1.q)
         {
            this.query = param1.q;
         }
         if(param1.rel)
         {
            this.showRelatedVideosValue = param1.rel != "0";
         }
         if(param1.showinfo)
         {
            this.showInfo = param1.showinfo != "0";
            this.embellishEmbed = this.showInfo;
         }
         if(param1.showpopout)
         {
            this.showPopout = param1.showpopout == "1";
         }
         if(param1.sk)
         {
            this.sessionToken = param1.sk;
         }
         if(param1.ss)
         {
            this.suppressEndScreenShare = param1.ss == "1";
         }
         if(param1.sw)
         {
            this.samplingWeight = param1.sw;
         }
         if(param1.theme)
         {
            this.theme = param1.theme;
         }
         if(param1.color == "white")
         {
            Theme.setActiveColor([15658734,8947848]);
         }
         else if(this.isAdPlayback && param1.color == "yellow")
         {
            Theme.setActiveColor([16705386,14725137]);
         }
         else if(param1.modestbranding)
         {
            this.preferYouTubeTitleTip = param1.modestbranding == "1";
         }
         if(param1.vq)
         {
            this.videoQualityPref = new VideoQuality(param1.vq);
            this.adaptiveExperiment = this.adaptiveExperiment && this.videoQualityPref.equals(VideoQuality.AUTO);
         }
         if(param1.stagevideo)
         {
            this.stageVideoForbidden = param1.stagevideo == "0";
         }
         if(param1.sendtmp)
         {
            this.sendSegmentsToTempLogs = param1.sendtmp == "1";
         }
         if(param1.content_v)
         {
            this.contentVideoIdentifier = param1.content_v;
         }
         if(param1.agcid)
         {
            this.adSenseAdGroupCreativeId = param1.agcid;
         }
         this.initialVideoData = new VideoData(param1,param2);
         if(this.eventLabel == EventLabel.DETAIL_PAGE || this.initialVideoData.cuedClickToPlay)
         {
            this.initialVideoData.autoPlay = false;
         }
         if(UrlValidator.isTrustedDomain(param1.watch_xlb))
         {
            this.watchXlbUrl = param1.watch_xlb;
         }
      }
      
      public function getAddToRequest(param1:VideoData, param2:String, param3:ListId, param4:Boolean, param5:String = "") : URLRequest
      {
         var _loc8_:String = null;
         if(!param3 && !param5)
         {
            return null;
         }
         if(!param5)
         {
            if(param3.type == ListId.WATCH_LATER_LIST)
            {
               if(param4)
               {
                  _loc8_ = "action_add_to_watch_later_list=1";
               }
               else
               {
                  _loc8_ = "action_delete_from_watch_later_list=1";
               }
            }
            else if(param4)
            {
               _loc8_ = "action_add_to_playlist=1&playlist_id=" + param3.id;
            }
            else
            {
               _loc8_ = "action_delete_from_playlist=1&playlist_id=" + param3.id;
            }
            param5 = this.BASE_YT_URL + ADD_TO_AJAX_URL + _loc8_ + "&feature=player_" + this.eventLabel + "&eurl=" + encodeURIComponent(this.eurl);
         }
         var _loc6_:URLRequest = new URLRequest(param5);
         var _loc7_:RequestVariables = new RequestVariables();
         _loc7_.video_ids = param1.videoId;
         _loc7_.session_token = param2;
         _loc6_.data = _loc7_;
         _loc6_.method = URLRequestMethod.POST;
         return _loc6_;
      }
      
      public function getSharedObject(param1:String, param2:String) : Object
      {
         var result:Object = null;
         var so:SharedObject = null;
         var objectName:String = param1;
         var key:String = param2;
         try
         {
            so = SharedObject.getLocal(objectName,"/");
            result = so.data[key];
         }
         catch(error:Error)
         {
         }
         return result;
      }
      
      public function get playerApiId() : String
      {
         return this.playerApiIdValue;
      }
      
      public function getErrorLoggingRequestVariables(param1:RequestVariables = null) : RequestVariables
      {
         param1 = this.getLoggingRequestVariables(param1);
         if(ImportBuildInfo.BUILD_CHANGELIST)
         {
            param1.cl = ImportBuildInfo.BUILD_CHANGELIST;
         }
         if(ImportBuildInfo.TIMESTAMP)
         {
            param1.ts = ImportBuildInfo.TIMESTAMP;
         }
         return param1;
      }
      
      public function get eventLabel() : String
      {
         return this.eventLabelValue;
      }
      
      public function getConversionPixelRequest(param1:VideoData, param2:String) : URLRequest
      {
         var _loc4_:URLRequest = null;
         var _loc3_:RequestVariables = this.createConversionRequestVariables(param1,param2);
         if(_loc3_)
         {
            _loc4_ = new URLRequest(param1.conversionConfig.baseUrl);
            _loc4_.data = _loc3_;
            return _loc4_;
         }
         return null;
      }
      
      public function getCardioLoggingRequest(param1:VideoData, param2:RequestVariables) : URLRequest
      {
         param2.fmt = 0;
         if(Boolean(this.playlist) && Boolean(this.playlist.listId))
         {
            param2.list = this.playlist.listId;
         }
         var _loc3_:URLRequest = this.getPlaybackLoggingRequest(param1,param2);
         _loc3_.url = this.BASE_YT_URL + "live_204";
         if(param1.playbackIdToken)
         {
            param2.plid = param1.playbackIdToken;
         }
         if(param1.clientPlaybackNonce)
         {
            param2.cpn = param1.clientPlaybackNonce;
         }
         if(_loc3_.data.t)
         {
            delete _loc3_.data.t;
         }
         return _loc3_;
      }
      
      public function getPromotedVideoBillingRequest(param1:VideoData) : URLRequest
      {
         if(!param1.promotedVideoBillableUrl)
         {
            return null;
         }
         return new URLRequest(param1.promotedVideoBillableUrl);
      }
      
      public function getVideoFormatUrlRequest(param1:VideoData, param2:VideoFormat, param3:RequestVariables = null, param4:Boolean = false) : URLRequest
      {
         var _loc6_:Url = null;
         var _loc5_:URLRequest = new URLRequest();
         if(!param3)
         {
            param3 = new RequestVariables();
         }
         if(!param4 && param2 && Boolean(param2.url))
         {
            if(param1.partnerTrackingToken)
            {
               param3.ptk = param1.partnerTrackingToken;
            }
            if(param1.partnerTrackingChannelToken)
            {
               param3.ptchn = param1.partnerTrackingChannelToken;
            }
            if(param1.clientPlaybackNonce)
            {
               param3.cpn = param1.clientPlaybackNonce;
            }
            _loc5_.url = param2.url;
            if(param1.isRetrying)
            {
               if(param2.fallbackHost)
               {
                  if(param1.isTransportRtmp())
                  {
                     _loc6_ = new Url(param2.conn);
                     _loc6_.hostname = param2.fallbackHost;
                     param2.conn = _loc6_.recombineUrl();
                  }
                  else
                  {
                     _loc6_ = new Url(param2.url);
                     _loc6_.hostname = param2.fallbackHost;
                     _loc5_.url = _loc6_.recombineUrl() + "&";
                  }
               }
               param3.playretry = 1;
            }
         }
         else
         {
            if(param2.name)
            {
               param3.fmt = param2.name;
            }
            _loc5_.url = this.BASE_YT_URL + GET_VIDEO_URL;
            param3.video_id = param1.videoId;
            if(param1.token)
            {
               param3.t = param1.token;
            }
            if(param1.partnerTrackingToken)
            {
               param3.ptk = param1.partnerTrackingToken;
            }
            if(param1.clientPlaybackNonce)
            {
               param3.cpn = param1.clientPlaybackNonce;
            }
            if(this.eventLabel)
            {
               param3.el = this.eventLabel;
            }
            if(this.playerStyle)
            {
               param3.ps = this.playerStyle;
            }
            if(this.adFormatValue)
            {
               param3.adformat = this.adFormatValue;
            }
            if(this.eurl)
            {
               param3.eurl = encodeURIComponent(this.eurl);
            }
            if(this.framer)
            {
               param3.framer = encodeURIComponent(this.framer);
            }
            if(param1.autoPlay)
            {
               param3.autoplay = "1";
            }
            if(param1.scriptedPlayback)
            {
               param3.splay = "1";
            }
            if(param1.cycToken)
            {
               param3.cyc = param1.cycToken;
            }
            param3.asv = "3";
         }
         if(!param1.isTransportRtmp() && isNaN(param3.start) && isNaN(param3.begin))
         {
            if(Boolean(param1.keyframes) && Boolean(param1.videoFileByteOffset))
            {
               param3.start = param1.videoFileByteOffset;
            }
            else if(param1.startSeconds > 0)
            {
               if(param1.canSeekOnTime())
               {
                  param3.begin = Math.floor(param1.startSeconds * 1000);
               }
               else
               {
                  param3.start = param1.startSeconds;
               }
            }
         }
         _loc5_.data = param3;
         if(_loc5_.data.toString().length)
         {
            if(_loc5_.url.indexOf("?") == -1)
            {
               _loc5_.url += "?";
            }
            else if(_loc5_.url.substr(-1) != "?" && _loc5_.url.substr(-1) != "&")
            {
               _loc5_.url += "&";
            }
         }
         return _loc5_;
      }
      
      public function getShareUrl(param1:VideoData) : String
      {
         return this.BASE_YT_URL + "share_popup" + "?v=" + escape(param1.videoId) + (Boolean(this.playlist) && Boolean(this.playlist.listId) ? "&list=" + escape(this.playlist.listId.toString()) : "");
      }
      
      public function set enableJsApi(param1:Boolean) : void
      {
         var functionName:String = null;
         var value:Boolean = param1;
         if(!this.enableJsApiValue && value)
         {
            this.enableJsApiValue = true;
            if(context.loaderURL == context.url)
            {
               try
               {
                  functionName = "addEventListener";
                  this.addExternalCallback(functionName,this.addExternalEventListener);
                  this.apiInterface.push(functionName);
               }
               catch(e:SecurityError)
               {
               }
            }
         }
      }
      
      public function getUnsubscribeRequest() : URLRequest
      {
         return this.getSubscriptionActionRequest("action_remove_subscriptions");
      }
      
      public function forceProtocol(param1:String, param2:Boolean) : String
      {
         var _loc3_:Array = param1.split("//");
         var _loc4_:* = "http" + (param2 ? "s" : "") + ":";
         if(_loc3_.length < 2)
         {
            _loc3_.unshift(_loc4_);
         }
         else
         {
            _loc3_[0] = _loc4_;
         }
         return _loc3_.join("//");
      }
      
      protected function onAddCallback(param1:AddCallbackEvent) : void
      {
         this.addExternalCallback(param1.functionName,param1.closure);
      }
      
      public function popupShareWindow(param1:VideoData) : void
      {
         var _loc2_:* = "window.open(\'" + this.getShareUrl(param1) + "\', \'_blank\',\'width=660,height=400,location=0," + "statusbar=0,menubar=0,scrollbars=1,toolbar=0\',\'\');";
         navigateToURL(new URLRequest("javascript:" + escape(_loc2_) + " void(0);"),"_self");
      }
      
      public function get showEndScreen() : Boolean
      {
         var _loc1_:Boolean = this.eventLabel != EventLabel.CHANNEL_PAGE && this.eventLabel != EventLabel.DETAIL_PAGE && this.eventLabel != EventLabel.EMBEDDED && this.eventLabel != EventLabel.POPOUT;
         _loc1_ ||= Boolean(this.playerStyle) && this.playerStyle != PlayerStyle.OLYMPICS && this.playerStyle != PlayerStyle.DEFAULT && this.playerStyle != PlayerStyle.POPUP;
         return !_loc1_;
      }
      
      protected function getSubscriptionActionRequest(param1:String) : URLRequest
      {
         var _loc2_:URLRequest = new URLRequest(this.BASE_YT_URL + SUBSCRIPTION_URL);
         _loc2_.method = URLRequestMethod.POST;
         var _loc3_:RequestVariables = new RequestVariables();
         _loc3_[param1] = 1;
         _loc3_.flash = 1;
         _loc2_.data = _loc3_;
         return _loc2_;
      }
      
      public function set playerStyle(param1:String) : void
      {
         this.playerStyleValue = param1;
      }
      
      public function getApiInterface() : Array
      {
         return this.apiInterface;
      }
      
      public function getMosaicSpecRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:RequestVariables = new RequestVariables();
         _loc2_.video_id = param1.videoId;
         var _loc3_:URLRequest = new URLRequest(this.BASE_YT_URL + GET_MOSAIC_SPEC_URL);
         _loc3_.data = _loc2_;
         return _loc3_;
      }
      
      public function getDoubleclickTrackRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:URLRequest = new URLRequest(this.applyProtocol("ad.doubleclick.net/activity;src=1185014;ytb=1;yatw=") + param1.videoId + ";");
         if(this.query)
         {
            _loc2_.url += "yatq=" + encodeURIComponent(this.query) + ";";
         }
         _loc2_.method = URLRequestMethod.POST;
         return _loc2_;
      }
      
      public function get bufferLengthAfterVideoStarts() : Number
      {
         return 2;
      }
      
      public function getVideoUrlRequest(param1:VideoData, param2:RequestVariables = null, param3:Boolean = false) : URLRequest
      {
         return this.getVideoFormatUrlRequest(param1,this.getFormat(param1),param2,param3);
      }
      
      public function get showYouTubeTitleTip() : Boolean
      {
         return this.showYouTubeEmbedBranding && this.showInfo && (this.preferYouTubeTitleTip || !this.showControls);
      }
      
      public function getChannelSubscribeRequest() : URLRequest
      {
         return this.getSubscriptionActionRequest("action_create_subscription_to_channel");
      }
      
      public function get videoStatsV2Url() : String
      {
         return this.applyProtocol((this.isYouTubeLoggedValue ? "s.youtube" : "s.video.google") + ".com");
      }
      
      public function get maxBufferLength() : Number
      {
         return this.maxBufferLengthValue;
      }
      
      public function getAccountPlaybackUrl() : String
      {
         return this.BASE_YT_URL + ACCOUNT_PLAYBACK_URL;
      }
      
      public function getConversionAdViewPixelRequest(param1:VideoData) : URLRequest
      {
         if(!param1.conversionConfig.focEnabled || !this.isPaidView || !this.adSenseAdFormatLoggingValue)
         {
            return null;
         }
         var _loc2_:RequestVariables = new RequestVariables();
         _loc2_.foc_id = encodeURIComponent(param1.conversionConfig.uid);
         _loc2_.evid = param1.videoId;
         _loc2_.adformat = this.adSenseAdFormatLoggingValue;
         _loc2_.label = "followon_" + VideoData.CONVERSION_ADVIEW;
         if(this.adSenseAdGroupCreativeId)
         {
            _loc2_.agcid = encodeURIComponent(this.adSenseAdGroupCreativeId);
         }
         var _loc3_:URLRequest = new URLRequest(param1.conversionConfig.baseUrl);
         _loc3_.data = _loc2_;
         return _loc3_;
      }
      
      public function get baseUrl() : String
      {
         return this.baseUrlValue || LIVE_BASE_URL;
      }
      
      public function get isTrustedLoader() : Boolean
      {
         return UrlValidator.isTrustedDomain(this.loaderUrl) || UrlValidator.isBrandingPartner(this.loaderUrl);
      }
      
      public function set playerApiId(param1:String) : void
      {
         this.playerApiIdValue = encodeURIComponent(param1);
      }
      
      protected function applyPolicyDefaults() : void
      {
         if(this.policyDefaultsApplied)
         {
            return;
         }
         this.policyDefaultsApplied = true;
         this.allowFullScreen = !this.hosted;
         this.enableKeyboard = !this.hosted;
         this.interactivePreloader = !this.hosted;
         this.messages = new WatchMessages(this.BASE_YT_URL);
         switch(this.eventLabel)
         {
            case EventLabel.ADUNIT:
               this.showInfo = false;
               this.tagStreamingForbiddenExperiment = true;
               break;
            case EventLabel.CHANNEL_PAGE:
               this.messages = new WatchMessages(this.BASE_YT_URL);
               this.enableJsApi = true;
               this.enableSizeButton = false;
               this.showInfoOnlyInFullScreen = false;
            case EventLabel.POPOUT:
               Theme.setActiveTheme(Theme.DARK_THEME);
               break;
            case EventLabel.DETAIL_PAGE:
               this.enableJsApi = true;
               this.eurl = "";
               break;
            case EventLabel.EMBEDDED:
               this.autoPlay = false;
               this.autoHideControls = AUTO_HIDE_AUTO_EMBEDS;
               this.enableSizeButton = false;
               this.showDefaultYouTubeWatermark = true;
               this.showInfoOnlyInFullScreen = false;
               this.suppressEndScreenShare = !ExternalInterfaceWrapper.allowScriptAccess;
               break;
            case EventLabel.LEANBACK:
               this.enableSizeButton = false;
               this.interactivePreloader = false;
               this.suppressEndScreenShare = true;
               this.autoPlay = false;
               this.gestures = false;
               this.showControls = false;
               this.showInfo = false;
               break;
            case EventLabel.PREVIEW:
               this.enableQualityMenu = false;
               this.enableSizeButton = false;
               break;
            case EventLabel.PREVIEW_PAGE:
               this.enableSizeButton = false;
               break;
            case EventLabel.VIDEO_EDITOR:
               this.videoStatsEnabledValue = false;
               this.isPlaybackLoggableValue = false;
               this.autoPlay = false;
               this.enableQualityMenu = false;
               this.enableSizeButton = false;
               this.allowFullScreen = false;
               this.gestures = false;
               this.showInfo = false;
               break;
            default:
               this.enableSizeButton = false;
         }
         switch(this.playerStyle)
         {
            case PlayerStyle.CHROMELESS:
            case PlayerStyle.VEVO:
               this.enableJsApi = false;
               this.enableKeyboard = false;
               this.gestures = false;
               this.showControls = false;
               this.showInfo = false;
               break;
            case PlayerStyle.GOOGLE_LIVE:
               this.videoStatsNamespaceValue = "gl";
               this.enableSizeButton = false;
               this.suppressEndScreenShare = true;
               this.isPlaybackLoggableValue = false;
               this.isYouTubeLoggedValue = false;
               this.showLogo = false;
               break;
            case PlayerStyle.AD:
            case PlayerStyle.TESTING:
               this.videoStatsNamespaceValue = "adt";
               this.enableSizeButton = false;
               this.suppressEndScreenShare = true;
               this.isPlaybackLoggableValue = false;
               this.isYouTubeLoggedValue = false;
               this.showLogo = false;
               break;
            case PlayerStyle.BLOGGER:
               this.videoStatsNamespaceValue = "bl";
               this.enableSizeButton = false;
               this.suppressEndScreenShare = true;
               this.isPlaybackLoggableValue = false;
               this.isYouTubeLoggedValue = false;
               this.showLogo = false;
               this.showReportAbuse = true;
               break;
            case PlayerStyle.PICASAWEB:
               this.videoStatsNamespaceValue = "pw";
               this.enableSizeButton = false;
               this.suppressEndScreenShare = true;
               this.isPlaybackLoggableValue = false;
               this.isYouTubeLoggedValue = false;
               this.showLogo = false;
               this.showReportAbuse = true;
               break;
            case PlayerStyle.PLAY:
               this.videoStatsNamespaceValue = "gp";
               this.showLogo = false;
               this.showReportAbuse = false;
               this.showDefaultYouTubeWatermark = false;
               break;
            case PlayerStyle.GOOGLE_DOCS:
               this.videoStatsNamespaceValue = "gd";
               this.enableSizeButton = false;
               this.suppressEndScreenShare = true;
               this.isPlaybackLoggableValue = false;
               this.isYouTubeLoggedValue = false;
               this.showLogo = false;
               this.showReportAbuse = true;
               break;
            case PlayerStyle.GOOGLE_BOOKS:
               this.videoStatsNamespaceValue = "gb";
               this.enableJsApi = true;
               this.suppressEndScreenShare = true;
               this.isPlaybackLoggableValue = false;
               this.isYouTubeLoggedValue = false;
               this.showLogo = false;
               this.showReportAbuse = false;
               break;
            case PlayerStyle.GOOGLE_MEDIA_ADS:
               this.showYouTubeButtonOverride = true;
               break;
            case PlayerStyle.TRUEVIEW_INDISPLAY_CTP:
               this.allowFullScreen = false;
               this.enableSizeButton = false;
               this.enableQualityMenu = false;
               this.suppressEndScreenShare = true;
               break;
            case PlayerStyle.YVA:
               this.allowFullScreen = true;
               this.enableKeyboard = true;
               this.enableSizeButton = false;
         }
      }
      
      public function get videoStatsNamespace() : String
      {
         return this.videoStatsNamespaceValue;
      }
      
      private function getLoggingRequestVariables(param1:RequestVariables = null) : RequestVariables
      {
         if(!param1)
         {
            param1 = new RequestVariables();
         }
         if(this.eventLabel)
         {
            param1.el = this.eventLabel;
         }
         if(this.playerStyle)
         {
            param1.ps = this.playerStyle;
         }
         if(this.adFormatValue)
         {
            param1.adformat = this.adFormatValue;
         }
         if(this.experiments.exportExperimentIds())
         {
            param1.fexp = this.experiments.exportExperimentIds();
         }
         param1.fv = Capabilities.version;
         param1.scoville = 1;
         return param1;
      }
      
      public function getFormat(param1:VideoData) : VideoFormat
      {
         var _loc2_:VideoFormat = param1.getFormatForQualityAndRect(this.videoQualityPref,this.viewportRect);
         if(!_loc2_.url && Boolean(param1.format.url))
         {
            _loc2_.url = param1.format.url;
         }
         return _loc2_;
      }
      
      protected function sanitizeStackTrace(param1:String) : String
      {
         param1 = param1.split("\n").slice(1).join("\n");
         param1 = param1.replace(/at +/g,"at ");
         param1 = param1.replace(/MethodInfo-\d+/g,"MethodInfo-XXXX");
         if(param1.length > MAX_STACK_LENGTH)
         {
            param1 = param1.substr(0,MAX_STACK_LENGTH - 200) + param1.substr(-200);
         }
         return encodeURIComponent(param1);
      }
      
      public function getReportIssueRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:String = this.playerStyle == PlayerStyle.PLAY ? PLAY_REPORT_ISSUE_URL : YOUTUBE_REPORT_ISSUE_URL;
         var _loc3_:URLRequest = new URLRequest(this.applyProtocol(_loc2_));
         var _loc4_:RequestVariables = new RequestVariables();
         if(this.playerStyle == PlayerStyle.PLAY)
         {
            _loc4_.p = "movies_playback";
         }
         _loc4_.contact_type = "playbackissue";
         _loc4_.plid = param1.playbackIdToken;
         _loc4_.cpn = param1.clientPlaybackNonce;
         _loc4_.v = param1.videoId;
         if(param1.format.name)
         {
            _loc4_.fmt = param1.format.name;
         }
         if(param1.partnerId)
         {
            _loc4_.partnerid = param1.partnerId;
         }
         if(param1.isTransportRtmp())
         {
            _loc4_.sprot = 1;
         }
         _loc3_.data = _loc4_;
         return _loc3_;
      }
      
      public function set jsApiCallback(param1:String) : void
      {
         if(param1.match(VALID_READY_HANDLER))
         {
            this.jsApiCallbackValue = param1;
         }
      }
      
      public function getVideoMetadataRequest(param1:VideoData) : URLRequest
      {
         if(Boolean(param1) && Boolean(param1.videoId))
         {
            return new URLRequest(this.BASE_YT_URL + VIDEO_METADATA_URL + "?video_id=" + param1.videoId);
         }
         return null;
      }
      
      public function getWatermarkDestinationRequest(param1:VideoData) : URLRequest
      {
         if(param1.isPartnerWatermark)
         {
            return null;
         }
         return param1 ? this.getVideoWatchRequest(param1) : new URLRequest(this.BASE_YT_URL);
      }
      
      public function getVideoChannelCampaignRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:String = this.getVideoChannelUrl(param1);
         if(!_loc2_)
         {
            return null;
         }
         return new URLRequest(_loc2_ + "/" + CHANNEL_CAMPAIGN_TAB_COMPONENT);
      }
      
      public function get showNextButton() : Boolean
      {
         return this.eventLabel != EventLabel.DETAIL_PAGE && Boolean(this.playlist) && this.playlist.hasNext();
      }
      
      public function get isPaidView() : Boolean
      {
         return this.adFormatTypeValue != AD_FORMAT_TYPE_NONE;
      }
      
      public function get showLikeButton() : Boolean
      {
         return this.preferYouTubeTitleTip == this.embellishEmbed;
      }
      
      public function get isIframeEmbed() : Boolean
      {
         return this.loaderUrl.indexOf(this.BASE_YT_URL + EMBED_URL) == 0;
      }
      
      public function get showYouTubeEmbedBranding() : Boolean
      {
         return this.isYouTubeEmbedPlayer && !this.onSite;
      }
      
      public function getSetAwesomeRequest(param1:VideoData, param2:int, param3:int) : URLRequest
      {
         var _loc4_:URLRequest = new URLRequest(this.BASE_YT_URL + SET_AWESOME_URL);
         var _loc5_:RequestVariables = new RequestVariables();
         _loc5_.video_id = param1.videoId;
         if(Boolean(this.playlist) && Boolean(this.playlist.listId))
         {
            _loc5_.list = this.playlist.listId;
         }
         var _loc6_:Number = Math.min(Math.max(param2 / param1.duration,0),1);
         _loc5_.w = _loc6_;
         _loc5_.l = param1.duration;
         _loc5_.tpmt = param3;
         _loc5_.plid = param1.playbackIdToken;
         _loc5_.cpn = param1.clientPlaybackNonce;
         if(this.eventLabel)
         {
            _loc5_.el = this.eventLabel;
         }
         if(this.playerStyle)
         {
            _loc5_.ps = this.playerStyle;
         }
         if(this.adFormatValue)
         {
            _loc5_.adformat = this.adFormatValue;
         }
         if(param1.autoPlay)
         {
            _loc5_.autoplay = "1";
         }
         if(param1.scriptedPlayback)
         {
            _loc5_.splay = "1";
         }
         if(param1.partnerId)
         {
            _loc5_.partnerid = param1.partnerId;
         }
         if(param1.playerDefaultVideoIdsToHtml5 > -1)
         {
            _loc5_.hbid = param1.playerDefaultVideoIdsToHtml5;
         }
         if(param1.oauthToken)
         {
            _loc5_.access_token = param1.oauthToken;
         }
         if(this.eurl)
         {
            _loc5_.eurl = encodeURIComponent(this.eurl);
         }
         if(this.framer)
         {
            _loc5_.framer = encodeURIComponent(this.framer);
         }
         if(this.sourceFeature)
         {
            _loc5_.feature = this.sourceFeature;
         }
         if(this.referrer)
         {
            _loc5_.referrer = encodeURIComponent(this.referrer);
         }
         if(this.deviceBrand)
         {
            _loc5_.cbrand = this.deviceBrand;
         }
         if(this.deviceBrowser)
         {
            _loc5_.cbr = this.deviceBrowser;
         }
         if(this.deviceBrowserVersion)
         {
            _loc5_.cbrver = this.deviceBrowserVersion;
         }
         if(this.deviceInterface)
         {
            _loc5_.c = this.deviceInterface;
         }
         if(this.deviceInterfaceVersion)
         {
            _loc5_.cver = this.deviceInterfaceVersion;
         }
         if(this.deviceModel)
         {
            _loc5_.cmodel = this.deviceModel;
         }
         if(this.deviceNetwork)
         {
            _loc5_.cnetwork = this.deviceNetwork;
         }
         if(this.deviceOs)
         {
            _loc5_.cos = this.deviceOs;
         }
         if(this.deviceOsVersion)
         {
            _loc5_.cosver = this.deviceOsVersion;
         }
         if(this.devicePlatform)
         {
            _loc5_.cplatform = this.devicePlatform;
         }
         _loc4_.data = _loc5_;
         return _loc4_;
      }
      
      private function createConversionRequestVariables(param1:VideoData, param2:String) : RequestVariables
      {
         var _loc4_:RequestVariables = null;
         var _loc3_:Boolean = Boolean(param1.conversionConfig.focEnabled) && this.canSendFollowOnPings(param1);
         if(_loc3_ || Boolean(param1.conversionConfig.rmktEnabled))
         {
            _loc4_ = new RequestVariables();
            if(param1.conversionConfig.rmktEnabled)
            {
               _loc4_.label = "default";
               _loc4_.data = encodeURIComponent(this.createDoubleClickDataParam(param1,param2));
            }
            if(_loc3_)
            {
               _loc4_.label = encodeURIComponent("followon_" + param2);
               _loc4_.foc_id = encodeURIComponent(param1.conversionConfig.uid);
            }
            return _loc4_;
         }
         return null;
      }
      
      public function set eventLabel(param1:String) : void
      {
         this.eventLabelValue = param1;
      }
      
      public function getVideoEmbedCode(param1:VideoData) : String
      {
         var _loc2_:String = "";
         if(param1.allowEmbed)
         {
            _loc2_ = EMBED_IFRAME_TEMPLATE.replace(EMBED_HTML_URL_REGEXP,this.BASE_YT_URL + EMBED_URL + param1.videoId + "?feature=player_" + this.eventLabel);
         }
         return _loc2_;
      }
      
      public function getErrorLoggingRequest(param1:Error, param2:RequestVariables = null) : URLRequest
      {
         var _loc5_:URLRequest = null;
         var _loc3_:String = param1.getStackTrace();
         var _loc4_:Number = 0;
         param2 ||= new RequestVariables();
         if(Math.random() < LOG_ERROR_PROB)
         {
            _loc4_ = Math.round(1 / LOG_ERROR_PROB);
         }
         if(_loc4_ > 0 || Boolean(_loc3_))
         {
            param2 = this.getErrorLoggingRequestVariables(param2);
            delete param2.fexp;
            param2.event = "aserror";
            param2.error = encodeURIComponent(param1.name);
            param2.errorid = param1.errorID;
            param2.msg = encodeURIComponent(param1.message);
            param2.eurl = encodeURIComponent(this.eurl);
            if(_loc3_)
            {
               param2.stack = this.sanitizeStackTrace(_loc3_);
               this.lastStackTrace = param2.stack;
            }
            param2.weight = _loc4_;
            _loc5_ = new URLRequest(this.BASE_YT_URL + "player_204");
            _loc5_.data = param2;
            return _loc5_;
         }
         return null;
      }
      
      public function get isYouTubeEmbedPlayer() : Boolean
      {
         return this.isEmbedded && (!this.playerStyle || this.playerStyle == PlayerStyle.DEFAULT || this.playerStyle == PlayerStyle.CHROMELESS || this.playerStyle == PlayerStyle.CUSTOM_SMALL);
      }
      
      public function getLoggingRequest(param1:VideoData, param2:RequestVariables = null) : URLRequest
      {
         var _loc3_:* = null;
         param2 = this.getLoggingRequestVariables(param2);
         param2.v = param1.videoId;
         param2.plid = param1.playbackIdToken;
         param2.cpn = param1.clientPlaybackNonce;
         if(param1.partnerId)
         {
            param2.partnerid = param1.partnerId;
         }
         if(param1.isTransportRtmp())
         {
            param2.sprot = 1;
         }
         if(param1.userSubscribedToChannel)
         {
            param2.subscribed = param1.userSubscribedToChannel;
         }
         if(param2.event == FailureReport.EVENT_MESSAGE || param2.event == StreamingStats.EVENT_MESSAGE)
         {
            _loc3_ = this.applyProtocol((this.isYouTubeLoggedValue ? "s.youtube" : "video.google") + ".com/stream_204");
         }
         else
         {
            _loc3_ = this.BASE_YT_URL + "player_204";
         }
         var _loc4_:URLRequest = new URLRequest(_loc3_);
         _loc4_.data = param2;
         return _loc4_;
      }
      
      public function getPromotedVideoTrackingRequest(param1:VideoData, param2:String) : URLRequest
      {
         if(!param1.promotedVideoConversionUrl)
         {
            return null;
         }
         var _loc3_:Url = new Url(param1.promotedVideoConversionUrl);
         _loc3_.queryVars["label"] = param2;
         return new URLRequest(_loc3_.recombineUrl());
      }
      
      override public function getLoggingOptions() : Object
      {
         var _loc1_:Object = {"el":this.eventLabel};
         if(this.contentRegion)
         {
            _loc1_.cr = this.contentRegion;
         }
         if(this.devApiKey)
         {
            _loc1_.d = this.devApiKey;
         }
         if(this.deviceBrand)
         {
            _loc1_.cbrand = this.deviceBrand;
         }
         if(this.deviceBrowser)
         {
            _loc1_.cbr = this.deviceBrowser;
         }
         if(this.deviceBrowserVersion)
         {
            _loc1_.cbrver = this.deviceBrowserVersion;
         }
         if(this.deviceInterface)
         {
            _loc1_.c = this.deviceInterface;
         }
         if(this.deviceInterfaceVersion)
         {
            _loc1_.cver = this.deviceInterfaceVersion;
         }
         if(this.deviceModel)
         {
            _loc1_.cmodel = this.deviceModel;
         }
         if(this.deviceNetwork)
         {
            _loc1_.cnetwork = this.deviceNetwork;
         }
         if(this.deviceOs)
         {
            _loc1_.cos = this.deviceOs;
         }
         if(this.deviceOsVersion)
         {
            _loc1_.cosver = this.deviceOsVersion;
         }
         if(this.devicePlatform)
         {
            _loc1_.cplatform = this.devicePlatform;
         }
         if(this.eurl)
         {
            _loc1_.eurl = encodeURIComponent(this.eurl);
         }
         if(this.framer)
         {
            _loc1_.framer = encodeURIComponent(this.framer);
         }
         if(this.referrer)
         {
            _loc1_.referrer = encodeURIComponent(this.referrer);
         }
         if(this.experiments.exportExperimentIds())
         {
            _loc1_.fexp = this.experiments.exportExperimentIds();
         }
         if(this.hosted)
         {
            _loc1_.hosted = 1;
         }
         if(this.maybeHosted)
         {
            _loc1_.mbhosted = 1;
         }
         if(this.isIframeEmbed)
         {
            _loc1_.iframe = 1;
         }
         if(this.interfaceLanguage)
         {
            _loc1_.hl = this.interfaceLanguage;
         }
         if(this.playerStyle)
         {
            _loc1_.ps = this.playerStyle;
         }
         if(this.adFormatValue)
         {
            _loc1_.adformat = this.adFormatValue;
         }
         if(this.query)
         {
            _loc1_.q = encodeURIComponent(this.query);
         }
         if(this.sessionToken)
         {
            _loc1_.vid = this.sessionToken;
         }
         if(this.toastedAndButteredSlicedBread)
         {
            _loc1_.tabsb = this.toastedAndButteredSlicedBread;
         }
         if(Boolean(this.userGenderValue) && Boolean(this.userAgeValue))
         {
            _loc1_.uga = encodeURIComponent(this.userGenderValue + this.userAgeValue);
         }
         if(this.addCsiToLoggingOptions && Boolean(this.csiTimings.vr))
         {
            _loc1_.vr = this.csiTimings.vr;
         }
         if(this.videoQualityPref)
         {
            _loc1_.vq = this.videoQualityPref;
         }
         if(this.sendSegmentsToTempLogs)
         {
            _loc1_.sendtmp = "1";
         }
         if(this.viewAttribution)
         {
            _loc1_.attrib = this.viewAttribution;
         }
         if(this.contentVideoIdentifier)
         {
            _loc1_.content_v = this.contentVideoIdentifier;
         }
         if(this.resumablePlayback)
         {
            _loc1_.ssrt = "1";
         }
         return _loc1_;
      }
      
      public function get isYouTubePlayer() : Boolean
      {
         return this.isYouTubeEmbedPlayer || this.onSite;
      }
      
      protected function addExternalEventListener(param1:String, param2:String, param3:Boolean = false) : void
      {
         var eventType:String = param1;
         var functionName:String = param2;
         var useCapture:Boolean = param3;
         addEventListener(eventType,function(param1:Event):void
         {
            ExternalInterfaceWrapper.call(functionName,param1.hasOwnProperty("data") ? Object(param1).data : null);
         });
      }
      
      private function canSendFollowOnPings(param1:VideoData) : Boolean
      {
         return !(this.isPaidView || param1.promotedVideoBillableUrl);
      }
      
      protected function guardApi(param1:Function) : Function
      {
         var f:Function = param1;
         return function(... rest):*
         {
            var args:Array = rest;
            try
            {
               return f.apply(null,args);
            }
            catch(error:ArgumentError)
            {
               if(error.errorID != 1063)
               {
                  handleError(error);
               }
               trace(error.toString());
            }
            catch(error:Error)
            {
               handleError(error);
               trace(error.toString());
            }
         };
      }
      
      public function get playerStyle() : String
      {
         return this.playerStyleValue;
      }
      
      public function get resumablePlayback() : Boolean
      {
         return this.vssResumeableExperiment && Boolean(this.playlist) && this.playlist.isResumableList;
      }
      
      public function getReportAbuseRequest() : URLRequest
      {
         return new URLRequest(this.reportAbuseUrl);
      }
      
      public function get willAutoplay() : Boolean
      {
         var _loc2_:Object = null;
         var _loc1_:Boolean = Boolean(this.playlist) && this.playlist.hasNext();
         if(this.eventLabel == EventLabel.DETAIL_PAGE)
         {
            _loc2_ = this.callExternal("yt.www.lists.getState");
            if(_loc2_ && _loc2_.hasOwnProperty("autoPlay") && Boolean(_loc2_.autoPlay))
            {
               _loc1_ = Boolean(_loc2_.autoPlay);
            }
         }
         return _loc1_;
      }
      
      protected function allowCrossDomainAccess() : void
      {
         Security.allowDomain("gdata.youtube.com");
         Security.allowDomain("pagead2.googlesyndication.com");
         Security.allowDomain("s0.2mdn.net");
         Security.allowDomain("s1.2mdn.net");
         Security.allowDomain("s.ytimg.com");
         Security.allowDomain("static.doubleclick.net");
         Security.allowDomain("www.youtube.com");
         Security.allowDomain("youtube.com");
         var _loc1_:Array = this.loaderUrl.match(HOSTS_REGEXP);
         if(!this.hosted && Boolean(_loc1_))
         {
            Security.allowDomain(_loc1_[2]);
         }
      }
      
      public function getPartnerLoggingRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:URLRequest = new URLRequest();
         _loc2_.url = this.BASE_YT_URL + "ptracking";
         var _loc3_:RequestVariables = new RequestVariables();
         if(param1.videoId)
         {
            _loc3_.video_id = param1.videoId;
         }
         if(param1.partnerTrackingToken)
         {
            _loc3_.ptk = param1.partnerTrackingToken;
         }
         if(param1.playbackIdToken)
         {
            _loc3_.plid = param1.playbackIdToken;
         }
         if(param1.clientPlaybackNonce)
         {
            _loc3_.cpn = param1.clientPlaybackNonce;
         }
         if(param1.partnerTrackingOid)
         {
            _loc3_.oid = param1.partnerTrackingOid;
         }
         if(param1.partnerTrackingChannelToken)
         {
            _loc3_.ptchn = param1.partnerTrackingChannelToken;
         }
         if(param1.partnerTrackingPlaybackType)
         {
            _loc3_.pltype = param1.partnerTrackingPlaybackType;
         }
         if(this.contentVideoIdentifier)
         {
            _loc3_.content_v = this.contentVideoIdentifier;
         }
         _loc2_.data = _loc3_;
         return _loc2_;
      }
      
      public function get showRelatedVideos() : Boolean
      {
         return this.showRelatedVideosValue && this.showEndScreen;
      }
      
      public function get jsApiCallback() : String
      {
         return this.jsApiCallbackValue;
      }
      
      public function applyGdataDevParams(param1:Object) : void
      {
         if(param1.f)
         {
            this.sourceFeature = param1.f;
         }
         if(param1.d)
         {
            this.devApiKey = param1.d;
         }
      }
      
      public function setSharedObject(param1:String, param2:String = null, param3:Object = null) : void
      {
         var so:SharedObject = null;
         var objectName:String = param1;
         var key:String = param2;
         var value:Object = param3;
         try
         {
            so = SharedObject.getLocal(objectName,"/");
            if(key)
            {
               so.data[key] = value;
            }
            else
            {
               so.clear();
            }
            so.flush();
         }
         catch(error:Error)
         {
         }
      }
      
      public function getUserWatchRequest(param1:VideoData, param2:RequestVariables = null) : URLRequest
      {
         if(param2 == null)
         {
            param2 = new RequestVariables();
         }
         if(Boolean(this.playlist) && Boolean(this.playlist.listId))
         {
            param2.list = this.playlist.listId;
            param2.list_index = this.playlist.index;
         }
         if(this.referrer)
         {
            param2.referrer = encodeURIComponent(this.referrer);
         }
         if(param1.playbackIdToken)
         {
            param2.plid = param1.playbackIdToken;
         }
         if(param1.clientPlaybackNonce)
         {
            param2.cpn = param1.clientPlaybackNonce;
         }
         if(this.sourceFeature)
         {
            param2.feature = this.sourceFeature;
         }
         if(param1.skipKansasLoggingValue)
         {
            param2.skl = "1";
         }
         if(param1.oauthToken)
         {
            param2.access_token = param1.oauthToken;
         }
         var _loc3_:URLRequest = this.getVideoUrlRequest(param1,param2,true);
         _loc3_.url = this.BASE_YT_URL + USER_WATCH_URL;
         return _loc3_;
      }
      
      override public function broadcastExternal(param1:ExternalEvent) : void
      {
         if(context.sharedEvents)
         {
            context.sharedEvents.dispatchEvent(new ExternalEvent(ExternalEvent.EXTERNAL,param1));
         }
         switch(param1.type)
         {
            case ExternalEvent.READY:
               this.callExternal(this.jsApiCallback,param1.data);
               break;
            case ExternalEvent.API_CHANGE:
               this.callExternal(param1.type);
         }
      }
      
      private function createDoubleClickDataParam(param1:VideoData, param2:String) : String
      {
         var _loc3_:* = "type=" + encodeURIComponent(param2) + ";utuid=" + encodeURIComponent(param1.conversionConfig.uid) + ";utvid=" + encodeURIComponent(param1.videoId);
         if(this.eventLabel)
         {
            _loc3_ += ";el=" + encodeURIComponent(this.eventLabel);
         }
         if(this.playerStyle)
         {
            _loc3_ += ";ps=" + encodeURIComponent(this.playerStyle);
         }
         if(ATTRIB_ALLOWED_VALUES.indexOf(this.viewAttribution) >= 0)
         {
            _loc3_ += ";feature=pyv";
         }
         if(param1.conversionConfig.ppe)
         {
            _loc3_ += ";ppe=" + encodeURIComponent(param1.conversionConfig.ppe);
         }
         return _loc3_;
      }
      
      public function get showWatchLaterButton() : Boolean
      {
         return this.showYouTubeEmbedBranding || this.onSite && this.eventLabel != EventLabel.VIDEO_EDITOR;
      }
      
      public function get videoStatsEnabled() : Boolean
      {
         return this.videoStatsEnabledValue;
      }
      
      public function get reportStreamingStats() : Boolean
      {
         return this.streamingStatsExperiment || Math.random() < STREAMING_STATS_PROB;
      }
      
      public function get isSkippableInStream() : Boolean
      {
         return this.adFormatTypeValue == AD_FORMAT_TYPE_INSTREAM && this.adFormatSubTypeValue == AD_FORMAT_SUB_TYPE_SKIPPABLE;
      }
      
      public function getS2LoggingRequest(param1:VideoData, param2:RequestVariables = null) : URLRequest
      {
         param2 ||= new RequestVariables();
         var _loc3_:URLRequest = new URLRequest(this.applyProtocol(S2_URL));
         _loc3_.data = param2;
         param2.ns = "yt";
         param2.docid = param1.videoId;
         if(param1.clientPlaybackNonce)
         {
            param2.cpn = param1.clientPlaybackNonce;
         }
         if(param1.playbackIdToken)
         {
            param2.plid = param1.playbackIdToken;
         }
         if(param1.format.name)
         {
            param2.fmt = param1.format.name;
         }
         if(this.eventLabel)
         {
            param2.el = this.eventLabel;
         }
         if(this.playerStyle)
         {
            param2.ps = this.playerStyle;
         }
         if(this.adFormatValue)
         {
            param2.adformat = this.adFormatValue;
         }
         if(this.sessionToken)
         {
            param2.vid = this.sessionToken;
         }
         if(param1.isTransportRtmp())
         {
            param2.sprot = 1;
         }
         param2.asv = 3;
         param2.yttk = 1;
         return _loc3_;
      }
      
      public function get onSite() : Boolean
      {
         var _loc1_:* = this.eventLabel == EventLabel.DETAIL_PAGE;
         return _loc1_ || this.eurl.indexOf(this.BASE_YT_URL) == 0;
      }
      
      public function getAccountPlaybackSaveRequest(param1:String, param2:VideoQuality) : URLRequest
      {
         var _loc3_:String = this.getAccountPlaybackUrl() + "?action_save=1&feature=player_" + this.eventLabel + "&eurl=" + encodeURIComponent(this.eurl);
         var _loc4_:URLRequest = new URLRequest(_loc3_);
         var _loc5_:RequestVariables = new RequestVariables();
         _loc5_.session_token = param1;
         _loc5_.quality = param2.equals(VideoQuality.MEDIUM) ? 1 : 0;
         _loc4_.data = _loc5_;
         _loc4_.method = URLRequestMethod.POST;
         return _loc4_;
      }
      
      override public function handleError(param1:Error, param2:RequestVariables = null) : void
      {
         var _loc3_:URLRequest = null;
         var _loc4_:RequestLoader = null;
         if(this.shouldLogError(param1))
         {
            _loc3_ = this.getErrorLoggingRequest(param1,param2);
            if(_loc3_)
            {
               _loc4_ = new RequestLoader();
               _loc4_.loadRequest(_loc3_);
            }
         }
         ++this.errorCount;
         super.handleError(param1,param2);
      }
      
      public function applyGetVideoInfo(param1:URLVariables) : void
      {
         if(this.videoQualityPref == VideoQuality.AUTO)
         {
            this.videoQualityPref = new VideoQuality(param1.vq);
         }
         this.applyCommonLoadedInfo(param1);
      }
      
      public function get isEmbedded() : Boolean
      {
         return this.eventLabelValue == EventLabel.EMBEDDED;
      }
      
      public function getWatchTimePixelRequest(param1:VideoData, param2:String) : URLRequest
      {
         var _loc3_:RequestVariables = null;
         var _loc4_:URLRequest = null;
         if(param1.numberOfWatchTimePingsSent >= 1 || !param1.conversionConfig.focEnabled || this.isPaidView)
         {
            return null;
         }
         if(param2 == VideoData.ADVERTISER_EVENT_COMPLETE)
         {
            _loc3_ = new RequestVariables();
            _loc3_.label = "followon_positive_action";
            _loc3_.value = Math.round(param1.duration);
            _loc3_.foc_id = param1.conversionConfig.uid;
            _loc4_ = new URLRequest(param1.conversionConfig.baseUrl);
            _loc4_.data = _loc3_;
            return _loc4_;
         }
         return null;
      }
      
      public function get videostatsUrl() : String
      {
         return this.applyProtocol((this.isYouTubeLoggedValue ? "s.youtube" : "video.google") + ".com/s");
      }
      
      public function getPlaylistsRequest() : URLRequest
      {
         return new URLRequest(this.BASE_YT_URL + ADD_TO_AJAX_URL + "action_get_playlists=1&style=xml");
      }
      
      public function get isStaticDuration() : Boolean
      {
         return this.eventLabel == EventLabel.PREVIEW_PAGE;
      }
      
      public function addExternalCallback(param1:String, param2:Function) : void
      {
         var functionName:String = param1;
         var closure:Function = param2;
         if(this.enableJsApi && ExternalInterfaceWrapper.available)
         {
            try
            {
               ExternalInterfaceWrapper.addCallback(functionName,closure);
            }
            catch(e:SecurityError)
            {
            }
         }
      }
      
      protected function onExternalEvent(param1:ExternalEvent) : void
      {
         var event:ExternalEvent = param1;
         try
         {
            dispatchEvent(Event(event.data));
         }
         catch(error:Error)
         {
         }
      }
      
      public function getVideoInfoRequest(param1:VideoData) : URLRequest
      {
         var _loc2_:URLRequest = null;
         switch(this.playerStyle)
         {
            case PlayerStyle.CHROMELESS:
            case PlayerStyle.VEVO:
               _loc2_ = new URLRequest(this.BASE_YT_URL + API_VIDEO_INFO_URL);
               break;
            default:
               _loc2_ = new URLRequest(this.BASE_YT_URL + GET_VIDEO_INFO_URL);
         }
         var _loc3_:RequestVariables = new RequestVariables();
         _loc3_.video_id = param1.videoId;
         if(this.eventLabel)
         {
            _loc3_.el = this.eventLabel;
         }
         if(param1.ypcPreview)
         {
            _loc3_.ypc_preview = "1";
         }
         if(this.playerStyle)
         {
            _loc3_.ps = this.playerStyle;
         }
         if(this.adFormatValue)
         {
            _loc3_.adformat = this.adFormatValue;
         }
         if(this.eurl)
         {
            _loc3_.eurl = encodeURIComponent(this.eurl);
         }
         if(this.interfaceLanguage)
         {
            _loc3_.hl = this.interfaceLanguage;
         }
         if(this.adChannel)
         {
            _loc3_.ad_channel = this.adChannel;
         }
         if(param1.authKey)
         {
            _loc3_.authkey = param1.authKey;
         }
         if(param1.adobePassToken)
         {
            _loc3_.aptok = encodeURIComponent(param1.adobePassToken);
         }
         if(param1.cycToken)
         {
            _loc3_.cyc = param1.cycToken;
         }
         if(param1.finskyToken)
         {
            _loc3_.ftok = param1.finskyToken;
         }
         if(param1.oauthToken)
         {
            _loc3_.access_token = param1.oauthToken;
         }
         if(Boolean(this.playlist) && Boolean(this.playlist.listId))
         {
            _loc3_.list = this.playlist.listId;
         }
         if(param1.isLiveMonitor)
         {
            _loc3_.livemonitor = "1";
         }
         if(param1.scriptedPlayback)
         {
            _loc3_.splay = "1";
         }
         if(this.adSenseAdGroupCreativeId)
         {
            _loc3_.agcid = this.adSenseAdGroupCreativeId;
         }
         _loc3_.sts = SignatureDecipher.TIMESTAMP;
         _loc3_.asv = 3;
         _loc2_.data = _loc3_;
         return _loc2_;
      }
      
      protected function shouldLogError(param1:Error) : Boolean
      {
         if(this.errorCount >= MAX_ERROR_COUNT)
         {
            return false;
         }
         switch(param1.errorID)
         {
            case 1502:
               return Math.random() < 0.1;
            case 2047:
               return StageAmbassador.hosted;
            case 2060:
               return this.onSite;
            default:
               return true;
         }
      }
   }
}

import com.google.BuildInfo;

class ImportBuildInfo
{
   
   public static const BUILD_CHANGELIST:String = Object(BuildInfo).hasOwnProperty("BUILD_CHANGELIST") ? BuildInfo["BUILD_CHANGELIST"] : null;
   
   public static const TIMESTAMP:String = BuildInfo.TIMESTAMP;
   
   public function ImportBuildInfo()
   {
      super();
   }
}
