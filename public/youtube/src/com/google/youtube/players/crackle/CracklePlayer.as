package com.google.youtube.players.crackle
{
   import com.google.youtube.event.AdEvent;
   import com.google.youtube.players.IVideoUrlProvider;
   import com.google.youtube.players.PlayerAdapter;
   import flash.events.Event;
   
   public class CracklePlayer extends PlayerAdapter
   {
      
      public function CracklePlayer(param1:IVideoUrlProvider)
      {
         super(param1);
         volume = 1;
      }
      
      override protected function addEventListeners() : void
      {
         super.addEventListeners();
         guestAddEventListener("cp_video_meta_data_arrived",this.onMetaData);
      }
      
      override protected function removeEventListeners() : void
      {
         super.removeEventListeners();
         guestRemoveEventListener("cp_video_meta_data_arrived",this.onMetaData);
      }
      
      override public function isAdPlayControllable() : Boolean
      {
         return false;
      }
      
      override public function getAdTimes() : Array
      {
         var _loc5_:int = 0;
         var _loc1_:Array = [];
         var _loc2_:Array = super.getAdTimes();
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = int(_loc2_[_loc4_]);
            if(!isNaN(_loc5_) && _loc5_ >= 0)
            {
               _loc1_.push(Math.round(_loc5_ / 1000));
            }
            _loc4_++;
         }
         return _loc1_;
      }
      
      protected function onMetaData(param1:Event) : void
      {
         dispatchEvent(new AdEvent(AdEvent.META_LOAD));
      }
      
      override protected function guestGetAdState(param1:Object) : Number
      {
         switch(param1.msg)
         {
            case "playing":
               return AD_STATE_PLAYING;
            case "stopped":
            case "end":
               return AD_STATE_COMPLETED;
            default:
               return AD_STATE_EMPTY;
         }
      }
      
      override protected function guestGetPlayerState(param1:Object) : Number
      {
         switch(param1.msg)
         {
            case "end":
               return PLAYER_STATE_COMPLETED;
            case "playing":
               return PLAYER_STATE_PLAYING;
            case "paused":
               return PLAYER_STATE_PAUSED;
            default:
               return -1;
         }
      }
      
      override protected function applyStateAndEventNameOverrides() : void
      {
         super.applyStateAndEventNameOverrides();
         API_ADD_EVENT_LISTENER = "addEventListener";
         API_CLEAR = "cpClearVideo";
         API_PLAY = "cpPlayVideo";
         API_PAUSE = "cpPauseVideo";
         API_SEEK = "cpSeekTo";
         API_GET_VOLUME = "cpPlayerVolume";
         API_SET_VOLUME = "cpSetVolume";
         API_GET_TIME = "cpCurrentTime";
         API_GET_DURATION = "cpDuration";
         API_GET_BYTES_LOADED = "cpVideoBytesLoaded";
         API_GET_BYTES_TOTAL = API_GET_BYTES_LOADED;
         API_GET_AD_INSERTION_POINTS = "cpGetAdInsertionPoints";
         API_SET_SIZE = "cpSetSize";
         EVENT_VIDEO_LOADED = "cp_player_ready";
         EVENT_PLAYHEAD_UPDATE = "cp_video_playhead_moved";
         EVENT_STATE_CHANGE = "cp_video_status_changed";
         EVENT_AD_STATE_CHANGE = "cp_video_ad_status_changed";
         EVENT_LOAD_ERROR = "cp_video_error";
      }
      
      override public function seek(param1:Number, param2:Boolean = true) : void
      {
         param1 = Math.min(param1,getDuration() - 2);
         super.seek(param1,param2);
      }
      
      override protected function getAdType() : Number
      {
         return AD_TYPE_INSTREAM;
      }
      
      override public function getHasAdUI() : Boolean
      {
         return true;
      }
      
      override public function setVolume(param1:Number) : void
      {
         super.setVolume(param1 / 100);
      }
      
      override public function getVolume() : Number
      {
         return super.getVolume() * 100;
      }
   }
}

