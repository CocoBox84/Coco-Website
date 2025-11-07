package com.google.youtube.model
{
   import com.google.youtube.util.BinarySearch;
   
   public class KeyframeMap
   {
      
      protected var highWord:Array;
      
      protected var timestamps:Array;
      
      protected var lowWord:Array;
      
      public function KeyframeMap(param1:Array, param2:Array, param3:Array = null)
      {
         super();
         this.timestamps = param1;
         this.lowWord = param2;
         this.highWord = param3;
      }
      
      protected function nullTableError() : void
      {
         throw new Error();
      }
      
      public function getSeekPoint(param1:uint) : SeekPoint
      {
         var _loc2_:int = BinarySearch.lessThanOrEqual(this.timestamps,param1);
         if(!this.timestamps)
         {
            this.nullTableError();
         }
         if(!this.timestamps.length)
         {
            this.emptyTableError();
         }
         if(_loc2_ < 0)
         {
            this.notFoundError();
         }
         return _loc2_ < 0 ? null : this.getSeekPointForIndex(_loc2_,param1);
      }
      
      protected function emptyTableError() : void
      {
         throw new Error();
      }
      
      protected function getSeekPointForIndex(param1:uint, param2:int) : SeekPoint
      {
         var _loc3_:SeekPoint = new SeekPoint();
         _loc3_.byteOffset = this.joinWords(param1);
         _loc3_.timestamp = this.timestamps[param1];
         _loc3_.desiredTimestamp = Math.max(param2,_loc3_.timestamp);
         return _loc3_;
      }
      
      public function getMax() : SeekPoint
      {
         return this.timestamps.length ? this.getSeekPointForIndex(this.timestamps.length - 1,0) : null;
      }
      
      public function getNextSeekPoint(param1:uint) : SeekPoint
      {
         var _loc2_:int = BinarySearch.greaterThanOrEqual(this.timestamps,param1);
         if(!this.timestamps)
         {
            this.nullTableError();
         }
         if(!this.timestamps.length)
         {
            this.emptyTableError();
         }
         return _loc2_ < 0 ? null : this.getSeekPointForIndex(_loc2_,param1);
      }
      
      protected function notFoundError() : void
      {
         throw new Error();
      }
      
      public function push(param1:SeekPoint) : void
      {
         this.timestamps.push(param1.timestamp);
         this.lowWord.push(param1.byteOffset & 0x0FFFFFFF);
         this.highWord.push(param1.byteOffset >> 28);
      }
      
      protected function joinWords(param1:int) : uint
      {
         var _loc2_:uint = uint(this.lowWord[param1]);
         if(this.highWord)
         {
            _loc2_ |= this.highWord[param1] << 28 & 0xFFFFFFFF;
         }
         return _loc2_;
      }
   }
}

