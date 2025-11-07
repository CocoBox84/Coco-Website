package com.google.ui
{
   import flash.display.CapsStyle;
   import flash.display.Graphics;
   import flash.display.JointStyle;
   import flash.display.LineScaleMode;
   
   public class LineStyle
   {
      
      public var caps:String = "round";
      
      public var color:uint = 0;
      
      public var joints:String = "round";
      
      public var scaleMode:String = "normal";
      
      public var thickness:Number = 0;
      
      public var pixelHinting:Boolean = true;
      
      public var miterLimit:Number = 3;
      
      public var alpha:Number = 1;
      
      public function LineStyle(param1:Number = NaN, param2:uint = 0, param3:Number = NaN, param4:Boolean = true, param5:String = null, param6:String = null, param7:String = null, param8:Number = NaN)
      {
         super();
         if(!isNaN(param1))
         {
            this.thickness = param1;
         }
         if(!isNaN(param2))
         {
            this.color = param2;
         }
         if(!isNaN(param3))
         {
            this.alpha = param3;
         }
         if(param4 is Boolean)
         {
            this.pixelHinting = param4;
         }
         if(param5 is String && Boolean(param5.length))
         {
            this.scaleMode = param5;
         }
         if(param6 is String && Boolean(param6.length))
         {
            this.caps = param6;
         }
         if(param7 is String && Boolean(param7.length))
         {
            this.joints = param7;
         }
         if(!isNaN(param8))
         {
            this.miterLimit = param8;
         }
      }
      
      public function apply(param1:Graphics) : void
      {
         param1.lineStyle(this.thickness,this.color,this.alpha,this.pixelHinting,this.scaleMode,this.caps,this.joints,this.miterLimit);
      }
      
      public function isValid() : Boolean
      {
         if(this.thickness < 0 || this.thickness > 255)
         {
            return false;
         }
         if(this.alpha < 0 || this.alpha > 1)
         {
            return false;
         }
         if(this.scaleMode != LineScaleMode.NORMAL && this.scaleMode != LineScaleMode.NONE && this.scaleMode != LineScaleMode.VERTICAL)
         {
            return false;
         }
         if(this.caps != CapsStyle.NONE && this.caps != CapsStyle.ROUND && this.caps != CapsStyle.SQUARE)
         {
            return false;
         }
         if(this.joints != JointStyle.MITER && this.joints != JointStyle.ROUND && this.joints != JointStyle.BEVEL)
         {
            return false;
         }
         if(this.miterLimit < 1 || this.miterLimit > 255)
         {
            return false;
         }
         return true;
      }
   }
}

