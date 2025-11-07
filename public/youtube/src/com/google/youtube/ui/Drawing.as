package com.google.youtube.ui
{
   import flash.display.BitmapData;
   import flash.display.GradientType;
   import flash.display.Graphics;
   import flash.geom.Matrix;
   
   public class Drawing
   {
      
      internal static const DRAWING:Drawing = new Drawing(null);
      
      protected static const MATRIX:Matrix = new Matrix();
      
      internal var graphics:Graphics;
      
      public function Drawing(param1:Graphics)
      {
         super();
         this.graphics = param1;
      }
      
      public static function invisibleRect(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         param1.clear();
         param1.beginFill(0,0);
         param1.drawRect(param2,param3,param4,param5);
         param1.endFill();
      }
      
      public function fill(param1:*, param2:* = null, param3:Array = null, param4:Number = 0, param5:Number = 0, param6:Number = 0, param7:Number = 0, param8:Number = 0, param9:String = null) : Drawing
      {
         if(param1 is Array)
         {
            if(param2 is Number)
            {
               param2 = this.buildArray(param1.length,param2,param2);
            }
            else if(!(param2 is Array))
            {
               param2 = this.buildArray(param1.length,1,1);
            }
            param3 ||= this.buildArray(param1.length,0,255,true);
            param9 ||= GradientType.LINEAR;
            MATRIX.createGradientBox(param5,param6,Math.PI / 180 * param4,param7,param8);
            this.graphics.beginGradientFill(param9,param1,param2,param3,MATRIX);
         }
         else if(param1 is Number)
         {
            if(param2 == null)
            {
               param2 = 1;
            }
            this.graphics.beginFill(param1,param2);
         }
         return this;
      }
      
      public function rect(param1:Number, param2:Number, param3:Number, param4:Number) : Drawing
      {
         this.graphics.drawRect(param1,param2,param3,param4);
         return this;
      }
      
      protected function buildArray(param1:int, param2:Number, param3:Number, param4:Boolean = false) : Array
      {
         if(param1 == 1)
         {
            return [param2];
         }
         var _loc5_:Array = [];
         var _loc6_:int = 0;
         while(_loc6_ < param1)
         {
            if(param4)
            {
               _loc5_[_loc5_.length] = Math.floor(param2 + (param3 - param2) / (param1 - 1) * _loc6_);
            }
            else
            {
               _loc5_[_loc5_.length] = param2 + (param3 - param2) / (param1 - 1) * _loc6_;
            }
            _loc6_++;
         }
         return _loc5_;
      }
      
      public function clear() : Drawing
      {
         this.graphics.clear();
         return this;
      }
      
      public function curve(param1:Number, param2:Number, ... rest) : Drawing
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc4_:Number = param1;
         var _loc5_:Number = param2;
         this.graphics.moveTo(param1,param2);
         var _loc6_:int = 0;
         while(_loc6_ < rest.length)
         {
            _loc7_ = Number(rest[_loc6_]);
            _loc8_ = Number(rest[_loc6_ + 1]);
            _loc9_ = Number(rest[_loc6_ + 2]);
            this.graphics.curveTo(_loc4_ + (_loc7_ - _loc4_) / 2 + (_loc8_ - _loc5_) / 2 * _loc9_,_loc5_ + (_loc8_ - _loc5_) / 2 - (_loc7_ - _loc4_) / 2 * _loc9_,_loc7_,_loc8_);
            _loc4_ = _loc7_;
            _loc5_ = _loc8_;
            _loc6_ += 3;
         }
         return this;
      }
      
      public function circle(param1:Number, param2:Number, param3:Number) : Drawing
      {
         this.graphics.drawCircle(param1,param2,param3);
         return this;
      }
      
      public function roundRect(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Drawing
      {
         this.graphics.drawRoundRect(param1,param2,param3,param4,param5);
         return this;
      }
      
      public function line(param1:Number, param2:Number, ... rest) : Drawing
      {
         this.graphics.moveTo(param1,param2);
         var _loc4_:int = 0;
         while(_loc4_ < rest.length)
         {
            this.graphics.lineTo(rest[_loc4_],rest[_loc4_ + 1]);
            _loc4_ += 2;
         }
         return this;
      }
      
      public function stroke(param1:Number, param2:* = null, param3:* = null, param4:Array = null, param5:Number = 0, param6:Number = 0, param7:Number = 0, param8:Number = 0, param9:Number = 0, param10:String = null) : Drawing
      {
         if(param2 is Array)
         {
            if(!(param3 is Array))
            {
               param3 = null;
            }
            param3 ||= this.buildArray(param2.length,1,1);
            param4 ||= this.buildArray(param2.length,0,255,true);
            param10 ||= GradientType.LINEAR;
            MATRIX.createGradientBox(param6,param7,Math.PI / 180 * param5,param8,param9);
            this.graphics.lineStyle(param1);
            this.graphics.lineGradientStyle(param10,param2,param3,param4,MATRIX);
         }
         else if(param2 is Number)
         {
            if(param3 == null)
            {
               param3 = 1;
            }
            this.graphics.lineStyle(param1,param2,param3);
         }
         else
         {
            this.graphics.lineStyle(param1);
         }
         return this;
      }
      
      public function bitmapFill(param1:BitmapData, param2:Matrix = null) : Drawing
      {
         this.graphics.beginBitmapFill(param1,param2);
         return this;
      }
      
      public function end() : Drawing
      {
         this.graphics.endFill();
         this.graphics.lineStyle();
         return this;
      }
   }
}

