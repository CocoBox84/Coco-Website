package com.google.youtube.players
{
   import com.google.utils.RequestLoader;
   import com.google.utils.RequestVariables;
   import com.google.utils.Scheduler;
   import com.google.youtube.event.LogEvent;
   import com.google.youtube.event.VideoErrorEvent;
   import com.google.youtube.model.FailureReport;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.util.getDefinition;
   import com.google.youtube.util.hasDefinition;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.StatusEvent;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class FlashAccessVideoPlayer extends HTTPVideoPlayer
   {
      
      protected static const BASE64DECODER_CLASSNAME:String = "mx.utils.Base64Decoder";
      
      protected static const DRMContentData:Object = getDefinition("flash.net.drm.DRMContentData");
      
      protected static const DRMManager:Object = getDefinition("flash.net.drm.DRMManager");
      
      protected static const DRMStatusEvent:Object = getDefinition("flash.events.DRMStatusEvent");
      
      protected static const DRMErrorEvent:Object = getDefinition("flash.events.DRMErrorEvent");
      
      protected static const LoadVoucherSetting:Object = getDefinition("flash.net.drm.LoadVoucherSetting");
      
      protected static const SystemUpdater:Object = getDefinition("flash.system.SystemUpdater");
      
      protected static const SystemUpdaterType:Object = getDefinition("flash.system.SystemUpdaterType");
      
      protected static const PRELOAD_BAD_METADATA:int = 10001;
      
      protected static const PRELOAD_NO_BASE64DECODER:int = 10002;
      
      protected static const DRM_UPDATE_IO_ERROR:int = 10003;
      
      protected static const DRM_UPDATE_SECURITY_ERROR:int = 10004;
      
      protected static const DRM_UPDATE_DOWNLOAD_FAILING:int = 10005;
      
      protected static const FLASH_ACCESS_TIMEOUT_ERROR:int = 10007;
      
      protected static const DRM_UPDATE_FAILED_NOT_SUPPORTED:int = 10008;
      
      protected static const DRM_UPDATE_FAILED_NOT_AVAILABLE:int = 10009;
      
      protected static const DRM_UPDATE_FAILED_INCOMPATIBLE:int = 10010;
      
      protected static const DRM_UPDATE_FAILED:int = 10011;
      
      public static var SUPPORTED:Boolean = Boolean(DRMStatusEvent) && Boolean(DRMErrorEvent) && Boolean(LoadVoucherSetting) && Boolean(SystemUpdater) && Boolean(SystemUpdaterType);
      
      protected static const FLASH_ACCESS_TIMEOUT:int = 60000;
      
      protected static const FLASH_ACCESS_TIMEOUT_MAX_NUM:int = 5;
      
      protected var bufferFilled:Boolean = false;
      
      protected var Base64Decoder:Class;
      
      protected var systemUpdater:Object;
      
      protected var timetable:RequestVariables = new RequestVariables();
      
      protected var metadataLoader:RequestLoader;
      
      protected var isPlaybackStarted:Boolean = false;
      
      protected var isDrmUpdated:Boolean = false;
      
      protected var startupTime:int = getTimer();
      
      protected var flashAccessTimedOut:Boolean = false;
      
      protected var flashAccessTimeoutScheduler:Scheduler = Scheduler.setInterval(FLASH_ACCESS_TIMEOUT,this.onFlashAccessTimeout);
      
      protected var isDrmUpdating:Boolean = false;
      
      public function FlashAccessVideoPlayer(param1:IVideoInfoProvider)
      {
         this.flashAccessTimeoutScheduler.stop();
         super(param1);
      }
      
      protected function onMetadataLoaded(param1:Event) : void
      {
         var flxsMetadata:ByteArray = null;
         var flxsMetadataAsString:String = null;
         var base64Decoder:Object = null;
         var drmContentData:ByteArray = null;
         var drmManager:Object = null;
         var event:Event = param1;
         this.disableMetadataLoaderListeners();
         if(!this.loadBase64Decoder())
         {
            this.logFlashAccessMetadataPreloadError(PRELOAD_NO_BASE64DECODER);
            return;
         }
         try
         {
            flxsMetadata = this.extractFlxsValue(this.metadataLoader.data);
            if(!flxsMetadata)
            {
               this.logFlashAccessMetadataPreloadError(PRELOAD_BAD_METADATA);
               return;
            }
            flxsMetadata.position = 0;
            flxsMetadataAsString = flxsMetadata.readUTFBytes(flxsMetadata.length);
            base64Decoder = new this.Base64Decoder();
            base64Decoder.decode(flxsMetadataAsString);
            drmContentData = new DRMContentData(base64Decoder.toByteArray());
            drmManager = DRMManager.getDRMManager();
            drmManager.loadVoucher(drmContentData,LoadVoucherSetting.ALLOW_SERVER);
            this.timetable.preload_metadata_end = this.getTimestamp();
         }
         catch(error:Error)
         {
            logFlashAccessMetadataPreloadError(error.errorID);
         }
      }
      
      override public function destroy() : void
      {
         this.flashAccessTimeoutScheduler.stop();
         super.destroy();
      }
      
      override public function setVideoData(param1:VideoData) : void
      {
         if(Boolean(param1) && param1.isDrmUpdated)
         {
            this.isDrmUpdated = true;
         }
         super.setVideoData(param1);
      }
      
      protected function raiseCustomDrmError(param1:int) : void
      {
         this.onDrmError(new DRMErrorEvent("",false,false,"",param1,0));
      }
      
      protected function extractFlxsValue(param1:ByteArray) : ByteArray
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:ByteArray = new ByteArray();
         param1.position = 0;
         while(param1.bytesAvailable >= 8)
         {
            _loc2_ = param1.readUnsignedInt();
            _loc3_ = param1.readUnsignedInt();
            if(_loc3_ == 1718384755)
            {
               param1.readBytes(_loc4_,0,_loc2_ - 9);
               return _loc4_;
            }
            param1.position -= 7;
         }
         return null;
      }
      
      override protected function connectStream() : void
      {
         if(!SUPPORTED)
         {
            this.disconnectStream();
            this.setPlayerState(new UnrecoverableErrorState(this,new VideoErrorEvent(VideoErrorEvent.ERROR),WatchMessages.DRM_NEED_FLASH_UPGRADE));
            return;
         }
         this.timetable.timeout_num = 0;
         this.flashAccessTimeoutScheduler.restart();
         if(!this.isDrmUpdated)
         {
            this.updateDrm();
            return;
         }
         this.timetable.connect_stream = this.getTimestamp();
         if(videoData.oobVouchers)
         {
            this.preloadFlashAccessMetadata();
         }
         super.connectStream();
         if(streamValue)
         {
            streamValue.addEventListener(DRMStatusEvent.DRM_STATUS,this.onDrmStatus);
            streamValue.addEventListener(DRMErrorEvent.DRM_ERROR,this.onDrmError);
            streamValue.addEventListener(StatusEvent.STATUS,this.onStatusEvent);
         }
      }
      
      protected function disableMetadataLoaderListeners() : void
      {
         this.metadataLoader.removeEventListener(Event.COMPLETE,this.onMetadataLoaded);
         this.metadataLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onMetadataLoadFailed);
         this.metadataLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onMetadataLoadFailed);
         this.metadataLoader.removeEventListener(ErrorEvent.ERROR,this.onMetadataLoadFailed);
      }
      
      override public function onMetaData(param1:Object) : void
      {
         this.timetable.on_metadata = this.getTimestamp();
         super.onMetaData(param1);
      }
      
      override protected function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Buffer.Full":
               this.timetable.buffer_full = this.getTimestamp();
               this.bufferFilled = true;
               super.onNetStatus(param1);
               break;
            default:
               super.onNetStatus(param1);
         }
      }
      
      protected function onMetadataLoadFailed(param1:Event) : void
      {
         this.logFlashAccessMetadataPreloadError(Object(param1).errorID);
         this.disableMetadataLoaderListeners();
      }
      
      protected function onFlashAccessTimeout(param1:Event) : void
      {
         if(!this.bufferFilled && !(state is ErrorState))
         {
            if(this.timetable.timeout_num >= FLASH_ACCESS_TIMEOUT_MAX_NUM)
            {
               this.flashAccessTimeoutScheduler.stop();
               this.raiseCustomDrmError(FLASH_ACCESS_TIMEOUT_ERROR);
            }
            if(this.timetable.drm_update_progress_num == 0 && !this.isDrmUpdated)
            {
               this.raiseCustomDrmError(DRM_UPDATE_DOWNLOAD_FAILING);
            }
            this.flashAccessTimedOut = true;
            this.timetable.timeout_num += 1;
            this.timetable.ec = FailureReport.FLASH_ACCESS_TIMEOUT_ERROR_CODE;
            dispatchEvent(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,this.timetable));
         }
         else
         {
            this.flashAccessTimeoutScheduler.stop();
         }
      }
      
      protected function onDrmStatus(param1:Event) : void
      {
         this.timetable.license_obtained = this.getTimestamp();
         if(this.isPlaybackStarted)
         {
            this.timetable.already_playing = 1;
            this.logTimetable();
         }
      }
      
      protected function updateDrm() : void
      {
         if(this.isDrmUpdating)
         {
            return;
         }
         this.isDrmUpdating = true;
         this.timetable.drm_update_begin = this.getTimestamp();
         this.timetable.drm_update_progress_num = 0;
         if(!this.systemUpdater)
         {
            this.systemUpdater = new SystemUpdater();
            this.systemUpdater.addEventListener(Event.COMPLETE,this.onDrmUpdate);
            this.systemUpdater.addEventListener(Event.CANCEL,this.onDrmUpdate);
            this.systemUpdater.addEventListener(IOErrorEvent.IO_ERROR,this.onDrmUpdate);
            this.systemUpdater.addEventListener(ProgressEvent.PROGRESS,this.onDrmUpdate);
            this.systemUpdater.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onDrmUpdate);
            this.systemUpdater.addEventListener(StatusEvent.STATUS,this.onDrmUpdate);
         }
         this.systemUpdater.update(SystemUpdaterType.DRM);
      }
      
      protected function getTimestamp() : Number
      {
         return getTimer() - this.startupTime;
      }
      
      protected function preloadFlashAccessMetadata() : void
      {
         var _loc1_:String = null;
         var _loc2_:URLRequest = null;
         if(!this.metadataLoader)
         {
            this.timetable.preload_metadata_begin = this.getTimestamp();
            this.metadataLoader = new RequestLoader();
            _loc1_ = videoData.format.url;
            if(!_loc1_)
            {
               _loc1_ = videoData.flvUrl;
            }
            _loc2_ = new URLRequest(_loc1_ + "&range=0-10239");
            this.metadataLoader.addEventListener(Event.COMPLETE,this.onMetadataLoaded);
            this.metadataLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onMetadataLoadFailed);
            this.metadataLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onMetadataLoadFailed);
            this.metadataLoader.addEventListener(ErrorEvent.ERROR,this.onMetadataLoadFailed);
            this.metadataLoader.loadRequest(_loc2_,URLLoaderDataFormat.BINARY);
         }
      }
      
      protected function onDrmError(param1:Event) : void
      {
         var _loc2_:RequestVariables = new RequestVariables();
         _loc2_.eid = Object(param1).errorID;
         _loc2_.seid = Object(param1).subErrorID;
         _loc2_.ec = FailureReport.FLASH_ACCESS_ERROR_CODE;
         if(this.flashAccessTimedOut)
         {
            _loc2_.timeout = 1;
         }
         dispatchEvent(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,_loc2_));
         var _loc3_:String = WatchMessages.ERROR_GENERIC;
         switch(Object(param1).errorID)
         {
            case 3343:
            case DRM_UPDATE_FAILED_NOT_SUPPORTED:
               _loc3_ = WatchMessages.DRM_OS_NOT_SUPPORTED;
               break;
            case DRM_UPDATE_FAILED_INCOMPATIBLE:
               _loc3_ = WatchMessages.DRM_NEED_FLASH_UPGRADE;
               break;
            case 3304:
            case 3305:
               switch(Object(param1).subErrorID)
               {
                  case 305:
                  case 303:
                     break;
                  case 110:
                     _loc3_ = WatchMessages.ERROR_NOT_SIGNED_IN;
                     break;
                  case 107:
                     _loc3_ = WatchMessages.DRM_PROXY_NOT_ALLOWED;
                     break;
                  case 105:
                  case 112:
                  case 113:
                  case 114:
                  case 115:
                     _loc3_ = WatchMessages.DRM_NEED_FLASH_UPGRADE;
               }
         }
         this.disconnectStream();
         this.setPlayerState(new UnrecoverableErrorState(this,new VideoErrorEvent("FlashAccess:" + _loc2_.eid + ":" + _loc2_.seid),_loc3_));
      }
      
      protected function onStatusEvent(param1:StatusEvent) : void
      {
         switch(param1.code)
         {
            case "DRM.encryptedFLV":
               this.timetable.encrypted_flv = this.getTimestamp();
         }
      }
      
      private function loadBase64Decoder() : Boolean
      {
         if(!this.Base64Decoder)
         {
            if(hasDefinition(BASE64DECODER_CLASSNAME))
            {
               this.Base64Decoder = getDefinition(BASE64DECODER_CLASSNAME) as Class;
            }
         }
         return Boolean(this.Base64Decoder);
      }
      
      protected function onDrmUpdate(param1:Event) : void
      {
         var _loc2_:int = 0;
         switch(param1.type)
         {
            case "cancel":
               this.timetable.drm_update_cancel = this.getTimestamp();
               break;
            case "complete":
               this.isDrmUpdated = true;
               this.isDrmUpdating = false;
               this.timetable.drm_update_complete = this.getTimestamp();
               this.connectStream();
               break;
            case "ioError":
               this.timetable.drm_update_io_error = this.getTimestamp();
               this.raiseCustomDrmError(DRM_UPDATE_IO_ERROR);
               break;
            case "progress":
               this.timetable.drm_update_progress = this.getTimestamp();
               this.timetable.drm_update_progress_num += 1;
               this.timetable.drm_update_progress_bytes = ProgressEvent(param1).bytesLoaded;
               break;
            case "securityError":
               this.timetable.drm_update_security_error = this.getTimestamp();
               this.raiseCustomDrmError(DRM_UPDATE_SECURITY_ERROR);
               break;
            case "status":
               this.timetable.drm_update_status = this.getTimestamp();
               _loc2_ = DRM_UPDATE_FAILED;
               switch(StatusEvent(param1).code)
               {
                  case "DRM.UpdateFailedNotSupported":
                     _loc2_ = DRM_UPDATE_FAILED_NOT_SUPPORTED;
                     break;
                  case "DRM.UpdateFailedNotCurrentlyAvailable":
                     _loc2_ = DRM_UPDATE_FAILED_NOT_AVAILABLE;
                     break;
                  case "DRM.UpdateNeededButIncompatible":
                     _loc2_ = DRM_UPDATE_FAILED_INCOMPATIBLE;
               }
               this.raiseCustomDrmError(_loc2_);
         }
      }
      
      override protected function setPlayerState(param1:IPlayerState) : void
      {
         if(this.bufferFilled && !this.isPlaybackStarted)
         {
            this.isPlaybackStarted = true;
            this.timetable.startup_end = this.getTimestamp();
            this.logTimetable();
         }
         if(this.bufferFilled || param1 is IBufferingState || param1 is ErrorState)
         {
            super.setPlayerState(param1);
         }
         else
         {
            this.setPlayerState(new BufferingState(this));
         }
      }
      
      override protected function disconnectStream() : void
      {
         if(streamValue)
         {
            streamValue.removeEventListener(DRMStatusEvent.DRM_STATUS,this.onDrmStatus);
            streamValue.removeEventListener(DRMErrorEvent.DRM_ERROR,this.onDrmError);
            streamValue.removeEventListener(StatusEvent.STATUS,this.onStatusEvent);
         }
         super.disconnectStream();
      }
      
      protected function logTimetable() : void
      {
         dispatchEvent(new LogEvent(LogEvent.LOG,"flashaccess",this.timetable));
      }
      
      protected function logFlashAccessMetadataPreloadError(param1:int) : void
      {
         var _loc2_:RequestVariables = new RequestVariables();
         _loc2_.eid = param1;
         _loc2_.ec = FailureReport.FLASH_ACCESS_PRELOAD_ERROR_CODE;
         if(this.flashAccessTimedOut)
         {
            _loc2_.timeout = 1;
         }
         dispatchEvent(new LogEvent(LogEvent.LOG,FailureReport.EVENT_MESSAGE,_loc2_));
      }
   }
}

