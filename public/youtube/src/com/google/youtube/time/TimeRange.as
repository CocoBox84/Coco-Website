package com.google.youtube.time
{
   import com.google.utils.StringUtils;
   
   public class TimeRange implements IInterval
   {
      
      public static const NULL_TIMERANGE:TimeRange = new TimeRange(-1,-1);
      
      public static const AFTER_MEDIA_END:TimeRange = new TimeRange(CueRange.AFTER_MEDIA_END,CueRange.AFTER_MEDIA_END);
      
      public static const ALL_MEDIA:TimeRange = new TimeRange(CueRange.BEFORE_MEDIA_START,CueRange.AFTER_MEDIA_END);
      
      protected var endValue:int;
      
      protected var startValue:int;
      
      public function TimeRange(param1:int, param2:int)
      {
         super();
         this.startValue = param1;
         this.endValue = param2;
      }
      
      public static function fromDuration(param1:int, param2:int) : TimeRange
      {
         return new TimeRange(param1,param1 + param2);
      }
      
      public static function fromEndTime(param1:int, param2:int) : TimeRange
      {
         return new TimeRange(param1,param2);
      }
      
      public function get start() : int
      {
         return this.startValue;
      }
      
      public function toString() : String
      {
         return "(" + StringUtils.formatTime(this.startValue) + "-" + StringUtils.formatTime(this.endValue) + ")";
      }
      
      public function contains(param1:int, param2:int = 0) : Boolean
      {
         return param1 >= this.startValue && (param1 < this.endValue || param1 == this.endValue && this.startValue == this.endValue) && (param2 == 0 || param1 < param2 && param2 <= this.endValue);
      }
      
      public function get end() : int
      {
         return this.endValue;
      }
   }
}

