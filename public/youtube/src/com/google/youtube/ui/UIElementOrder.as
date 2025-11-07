package com.google.youtube.ui
{
   import flash.utils.getQualifiedClassName;
   
   public class UIElementOrder
   {
      
      private static const CLASS_ORDER_PRIORITIES:Object = {
         "VideoTitleTextButton":50000,
         "LargePlayButton":51000,
         "SeekBar":52000,
         "PlayPauseButton":53000,
         "InstantReplayButton":54000,
         "NextButton":55000,
         "AudioTrackButton":56000,
         "VolumeControlButton":57000,
         "TimeDisplay":58000,
         "ControlButton":59000,
         "ModuleButton":560000,
         "PopupMenu":61000,
         "QualityButton":62000,
         "WatchLaterControl":63000,
         "YouTubeButton":64000,
         "SizeButton":65000,
         "FullscreenButton":66000,
         "Watermark":67000,
         "VideoWallStill":68000
      };
      
      public static const CHILD_ORDER_OFFSET:int = 500;
      
      public function UIElementOrder()
      {
         super();
      }
      
      public static function getClassOrderPriority(param1:UIElement) : int
      {
         var _loc2_:String = getQualifiedClassName(param1).split("::")[1];
         if(_loc2_ in CLASS_ORDER_PRIORITIES)
         {
            return CLASS_ORDER_PRIORITIES[_loc2_];
         }
         return -1;
      }
   }
}

