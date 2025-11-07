package com.google.youtube.ui
{
   import com.google.youtube.time.TimeRange;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   
   public class SeekBarMarker
   {
      
      public var allowScale:Boolean;
      
      public var tooltip:String;
      
      public var endTime:Number = 1;
      
      public var startTime:Number = 0;
      
      public var gradientColor:Array;
      
      public var shadowed:Boolean;
      
      public function SeekBarMarker(param1:Number, param2:Number, param3:Array = null, param4:String = null)
      {
         if(!isNaN(param1) && param1 >= 0)
         {
            this.startTime = param1;
         }
         if(!isNaN(param2) && param2 >= 0)
         {
            this.endTime = param2;
         }
         this.gradientColor = param3 || [16763904,16763904];
         this.tooltip = param4;
         super();
      }
      
      public static function fromTimeRange(param1:TimeRange, param2:Array = null) : SeekBarMarker
      {
         return new SeekBarMarker(param1.start / 1000,param1.end / 1000,param2);
      }
      
      public function createShape(param1:Number, param2:Number) : DisplayObject
      {
         param1 = Math.max(param1,4);
         var _loc3_:Shape = new Shape();
         drawing(_loc3_.graphics).fill(this.gradientColor,null,null,90,1,param2).rect(0,0,param1,param2).end();
         return _loc3_;
      }
      
      public function createMagnifiedShape(param1:Number, param2:Number) : DisplayObject
      {
         return this.createShape(param1,param2);
      }
   }
}

