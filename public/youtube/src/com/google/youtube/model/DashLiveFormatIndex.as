package com.google.youtube.model
{
   import com.google.youtube.util.BinarySearch;
   import com.google.youtube.util.dash.LiveMpdParser;
   import flash.net.URLRequest;
   
   public class DashLiveFormatIndex extends Mp4FormatIndex
   {
      
      protected static const CHUNKS_FROM_HEAD:int = 2;
      
      protected var mpd:LiveMpdParser;
      
      protected var itag:String;
      
      public function DashLiveFormatIndex(param1:LiveMpdParser, param2:String)
      {
         super();
         this.mpd = param1;
         this.itag = param2;
         param1.scheduleUpdate();
      }
      
      override public function canGetSeekPoint(param1:uint) : Boolean
      {
         return this.mpd.isValid && loaded;
      }
      
      override protected function getHeaderRequest() : URLRequest
      {
         return this.mpd.isValid ? new URLRequest(this.mpd.getInitializationUrl(this.itag)) : null;
      }
      
      override public function getNextSeekPoint(param1:uint) : SeekPoint
      {
         if(!this.mpd.isValid)
         {
            return null;
         }
         var _loc2_:Array = this.mpd.getStartTimes(this.itag);
         var _loc3_:int = BinarySearch.greaterThanOrEqual(_loc2_,param1);
         if(_loc3_ < 0)
         {
            return null;
         }
         var _loc4_:SeekPoint = new SeekPoint();
         _loc4_.sequence = _loc3_;
         _loc4_.timestamp = _loc2_[_loc3_];
         _loc4_.desiredTimestamp = param1;
         return _loc4_;
      }
      
      override public function getTimeFromByte(param1:uint) : uint
      {
         return 0;
      }
      
      public function getLiveSeekPoint() : SeekPoint
      {
         if(!this.mpd.isValid)
         {
            return null;
         }
         var _loc1_:Array = this.mpd.getStartTimes(this.itag);
         var _loc2_:int = Math.max(0,_loc1_.length - CHUNKS_FROM_HEAD);
         var _loc3_:SeekPoint = new SeekPoint();
         _loc3_.sequence = _loc2_ + this.mpd.getSegmentStartNumber();
         _loc3_.timestamp = _loc1_[_loc2_];
         _loc3_.desiredTimestamp = _loc1_[_loc2_];
         return _loc3_;
      }
      
      public function getChunkUrl(param1:int) : String
      {
         if(!this.mpd.isValid)
         {
            return null;
         }
         var _loc2_:int = param1 - this.mpd.getSegmentStartNumber();
         if(_loc2_ < 0)
         {
            return null;
         }
         return this.mpd.getUrlByIndex(this.itag,_loc2_);
      }
      
      override public function get isFragmented() : Boolean
      {
         return true;
      }
      
      override public function getSeekPoint(param1:uint) : SeekPoint
      {
         if(!this.mpd.isValid)
         {
            return null;
         }
         var _loc2_:Array = this.mpd.getStartTimes(this.itag);
         if(!_loc2_.length)
         {
            return null;
         }
         var _loc3_:int = BinarySearch.lessThanOrEqual(_loc2_,param1);
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         var _loc4_:SeekPoint = new SeekPoint();
         _loc4_.sequence = _loc3_ + this.mpd.getSegmentStartNumber();
         _loc4_.timestamp = _loc2_[_loc3_];
         _loc4_.desiredTimestamp = param1;
         return _loc4_;
      }
      
      override public function canGetAnySeekPoint() : Boolean
      {
         return this.mpd.isValid && loaded;
      }
   }
}

