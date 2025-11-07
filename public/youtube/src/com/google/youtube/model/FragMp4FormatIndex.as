package com.google.youtube.model
{
   import com.google.youtube.util.BinarySearch;
   import flash.net.URLRequest;
   
   public class FragMp4FormatIndex extends Mp4FormatIndex
   {
      
      protected var headerSize:int;
      
      protected var url:String;
      
      public function FragMp4FormatIndex(param1:String, param2:int)
      {
         super();
         this.url = param1;
         this.headerSize = param2;
      }
      
      override public function get isFragmented() : Boolean
      {
         return true;
      }
      
      override public function getSeekPoint(param1:uint) : SeekPoint
      {
         return requestMoovInBand(param1) ? getSeekPointWithMoov() : this.getPrevSeekPoint(param1);
      }
      
      override public function canGetAnySeekPoint() : Boolean
      {
         return loaded;
      }
      
      protected function getSeekPointForIndex(param1:uint, param2:uint) : SeekPoint
      {
         var _loc3_:Array = moovValue.indexTimestamps;
         var _loc4_:Array = moovValue.indexOffsets;
         var _loc5_:SeekPoint = new SeekPoint();
         _loc5_.timestamp = _loc3_[param1];
         _loc5_.byteOffset = _loc4_[param1];
         _loc5_.desiredTimestamp = Math.max(param2,_loc5_.timestamp);
         return _loc5_;
      }
      
      override protected function getHeaderRequest() : URLRequest
      {
         return new URLRequest(this.url + "&range=0-" + (this.headerSize - 1));
      }
      
      protected function getPrevSeekPoint(param1:uint) : SeekPoint
      {
         var _loc2_:Array = moovValue.indexTimestamps;
         var _loc3_:int = BinarySearch.lessThanOrEqual(_loc2_,param1);
         return _loc3_ < 0 ? null : this.getSeekPointForIndex(_loc3_,param1);
      }
      
      override public function getNextSeekPoint(param1:uint) : SeekPoint
      {
         var _loc2_:Array = moovValue.indexTimestamps;
         var _loc3_:int = BinarySearch.greaterThanOrEqual(_loc2_,param1);
         return _loc3_ < 0 ? null : this.getSeekPointForIndex(_loc3_,param1);
      }
      
      override public function canGetSeekPoint(param1:uint) : Boolean
      {
         return param1 == 0 || loaded;
      }
      
      override public function get fileSize() : Number
      {
         return loaded ? moov.getFileSize() : NaN;
      }
   }
}

