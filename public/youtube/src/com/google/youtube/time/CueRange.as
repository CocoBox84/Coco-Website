package com.google.youtube.time
{
   import com.google.youtube.ui.SeekBarMarker;
   import flash.events.EventDispatcher;
   
   public class CueRange extends EventDispatcher implements IInterval
   {
      
      public static const BEFORE_MEDIA_START:int = -2147483648;
      
      public static const AFTER_MEDIA_END:int = 2147483647;
      
      public static const MEDIA_START:int = 0;
      
      public static const MEDIA_END:int = AFTER_MEDIA_END - 1;
      
      public static const PRIORITY_YPC_LICENSE_CHECKER:int = 10;
      
      public static const PRIORITY_AD_MODULE_TRACKING:int = 11;
      
      public static const PRIORITY_AD_MODULE:int = 12;
      
      public static const PRIORITY_AD_MODULE_ENDCAP:int = 13;
      
      public static const PRIORITY_YVA_MODULE:int = 14;
      
      public static const PRIORITY_RATINGS_MODULE:int = 15;
      
      public static const PRIORITY_PLAYBYPLAY_MODULE:int = 17;
      
      public static const PRIORITY_PLAYLIST_MODULE:int = 18;
      
      public static const PRIORITY_END_SCREEN:int = 19;
      
      public static const PRIORITY_FRESCA:int = 20;
      
      public static const PRIORITY_DEFAULT:int = 50;
      
      public static const PRIORITY_PREROLL:int = 100;
      
      protected static var cueRangeCount:uint = 0;
      
      public var active:Boolean;
      
      public var acquireExclusiveLock:Boolean;
      
      public var uid:uint;
      
      protected var idValue:String = null;
      
      protected var markerValue:SeekBarMarker;
      
      protected var timeRangeValue:TimeRange;
      
      public var className:String;
      
      protected var priorityValue:int;
      
      public function CueRange(param1:TimeRange, param2:SeekBarMarker = null, param3:String = null, param4:int = 50, param5:Boolean = false, param6:Boolean = true, param7:String = null)
      {
         super();
         this.timeRangeValue = param1;
         this.markerValue = param2;
         this.idValue = param3;
         this.priorityValue = param4;
         this.acquireExclusiveLock = param5;
         this.active = param6;
         this.className = param7;
         this.uid = cueRangeCount++;
      }
      
      public static function compare(param1:CueRange, param2:CueRange) : int
      {
         if(param1.timeRange.start == param2.timeRange.start)
         {
            if(param1.priority == param2.priority)
            {
               return 0;
            }
            if(param1.priority < param2.priority)
            {
               return -1;
            }
            return 1;
         }
         if(param1.timeRange.start < param2.timeRange.start)
         {
            return -1;
         }
         return 1;
      }
      
      public function get end() : int
      {
         return this.timeRange.end;
      }
      
      public function get start() : int
      {
         return this.timeRange.start;
      }
      
      public function get priority() : int
      {
         return this.priorityValue;
      }
      
      public function get timeRange() : TimeRange
      {
         return this.timeRangeValue;
      }
      
      public function set marker(param1:SeekBarMarker) : void
      {
         this.markerValue = param1;
         dispatchEvent(new CueRangeEvent(CueRangeEvent.CHANGE,this));
      }
      
      public function contains(param1:int, param2:int = 0) : Boolean
      {
         return this.timeRange.contains(param1,param2);
      }
      
      public function get marker() : SeekBarMarker
      {
         return this.markerValue;
      }
      
      public function get id() : String
      {
         return this.idValue;
      }
   }
}

