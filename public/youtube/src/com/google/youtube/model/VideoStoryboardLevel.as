package com.google.youtube.model
{
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   
   public class VideoStoryboardLevel
   {
      
      public static const MAX_MOSAICS_TO_PRELOAD:int = 10;
      
      private static const MAX_PIXEL_WIDTH_CACHE:int = 8640;
      
      public var interval:Number;
      
      public var width:int;
      
      private var bitmapDataCache:Array = [];
      
      public var rows:int;
      
      public var columns:int;
      
      public var urlPattern:String;
      
      public var frames:int;
      
      public var height:int;
      
      public var signature:String;
      
      private var bitmapData:Array = [];
      
      public var clearBitmapDataCache:Boolean;
      
      public function VideoStoryboardLevel(param1:Boolean = false)
      {
         super();
         this.clearBitmapDataCache = param1;
      }
      
      public function getMosaic(param1:int) : int
      {
         return Math.floor(param1 / (this.rows * this.columns));
      }
      
      public function get numMosaics() : int
      {
         return Math.ceil(this.frames / (this.rows * this.columns));
      }
      
      public function shouldCancel(param1:int, param2:int) : Boolean
      {
         return this.clearBitmapDataCache && this.columns * this.width * Math.abs(param1 - param2) > MAX_PIXEL_WIDTH_CACHE;
      }
      
      public function init() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = this.numMosaics;
         while(_loc1_ < _loc2_)
         {
            this.bitmapData.push(null);
            _loc1_++;
         }
         if(this.numMosaics == 0 || this.numMosaics > MAX_MOSAICS_TO_PRELOAD)
         {
            this.clearBitmapDataCache = true;
         }
      }
      
      public function getRect(param1:int) : Rectangle
      {
         if(param1 < 0 || this.frames && param1 >= this.frames)
         {
            return null;
         }
         param1 %= this.rows * this.columns;
         var _loc2_:int = this.width * (param1 % this.columns);
         var _loc3_:int = this.height * Math.floor(param1 / this.columns);
         return new Rectangle(_loc2_ + 1,_loc3_ + 1,this.width - 2,this.height - 2);
      }
      
      public function getBitmapData(param1:int) : BitmapData
      {
         var _loc2_:int = 0;
         if(param1 < 0 || this.numMosaics && param1 >= this.numMosaics)
         {
            return null;
         }
         if(this.clearBitmapDataCache && Boolean(this.bitmapData[param1]))
         {
            _loc2_ = int(this.bitmapDataCache.indexOf(param1));
            if(_loc2_ != -1)
            {
               this.bitmapDataCache.push(this.bitmapDataCache.splice(_loc2_,1)[0]);
            }
         }
         return this.bitmapData[param1];
      }
      
      public function setBitmapData(param1:int, param2:BitmapData) : void
      {
         var _loc3_:int = 0;
         if(param1 < 0 || this.numMosaics && param1 >= this.numMosaics)
         {
            return;
         }
         this.bitmapData[param1] = param2;
         if(this.clearBitmapDataCache)
         {
            if(this.bitmapDataCache.length * this.columns * this.width > MAX_PIXEL_WIDTH_CACHE)
            {
               _loc3_ = int(this.bitmapDataCache.shift());
               this.bitmapData[_loc3_] = null;
            }
            this.bitmapDataCache.push(param1);
         }
      }
   }
}

