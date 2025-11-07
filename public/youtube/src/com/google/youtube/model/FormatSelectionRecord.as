package com.google.youtube.model
{
   import flash.geom.Rectangle;
   
   public class FormatSelectionRecord
   {
      
      public static const ADAPTIVE:String = "a";
      
      public static const INITIAL:String = "i";
      
      public static const MANUAL:String = "m";
      
      public static const RESIZE:String = "r";
      
      public var switchTime:Number = NaN;
      
      public var evalTime:Number = NaN;
      
      public var viewportRect:Rectangle;
      
      public var readAheadBuffer:Number = NaN;
      
      public var format:VideoFormat;
      
      public var trigger:String;
      
      public var bandwidthEstimate:Number = NaN;
      
      public var viewportFormat:VideoFormat;
      
      public var oldFormat:VideoFormat;
      
      public function FormatSelectionRecord()
      {
         super();
      }
      
      public function get isViewFormat() : Boolean
      {
         return this.format == this.viewportFormat;
      }
   }
}

