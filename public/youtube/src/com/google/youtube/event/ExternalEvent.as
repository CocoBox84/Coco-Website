package com.google.youtube.event
{
   import flash.events.Event;
   
   public class ExternalEvent extends Event
   {
      
      public static const ERROR:String = "onError";
      
      public static const READY:String = "onReady";
      
      public static const QUALITY_CHANGE:String = "onPlaybackQualityChange";
      
      public static const PLAYBACK_RATE_CHANGE:String = "onPlaybackRateChange";
      
      public static const STATE_CHANGE:String = "onStateChange";
      
      public static const AD_END:String = "onAdEnd";
      
      public static const AD_START:String = "onAdStart";
      
      public static const ADVERTISER_VIDEO_VIEW:String = "onAdvertiserVideoView";
      
      public static const CUE_RANGE_ENTER:String = "onCueRangeEnter";
      
      public static const CUE_RANGE_EXIT:String = "onCueRangeExit";
      
      public static const PLAYLIST_CLIP_SELECTED:String = "onPlaylistClipSelected";
      
      public static const NEXT_CLICKED:String = "NEXT_CLICKED";
      
      public static const RATE_SENTIMENT:String = "RATE_SENTIMENT";
      
      public static const SHARE_CLICKED:String = "SHARE_CLICKED";
      
      public static const SIZE_CLICKED:String = "SIZE_CLICKED";
      
      public static const WATCH_LATER:String = "WATCH_LATER";
      
      public static const TRACKING:String = "onTracking";
      
      public static const VIDEO_CHANGE:String = "onVideoDataChange";
      
      public static const VIDEO_PROGRESS:String = "onVideoProgress";
      
      public static const VOLUME_CHANGE:String = "onVolumeChange";
      
      public static const API_CHANGE:String = "onApiChange";
      
      public static const NAVIGATE:String = "onNavigate";
      
      public static const TAB_ORDER_CHANGE:String = "onTabOrderChange";
      
      public static const EXTERNAL:String = "EXTERNAL";
      
      public var data:Object;
      
      public function ExternalEvent(param1:String, param2:Object = null)
      {
         this.data = param2;
         super(param1,false,false);
      }
   }
}

