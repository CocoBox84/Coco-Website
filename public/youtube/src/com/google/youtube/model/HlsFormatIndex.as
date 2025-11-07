package com.google.youtube.model
{
   import com.google.youtube.util.BinarySearch;
   import com.google.youtube.util.FlvUtils;
   import com.google.youtube.util.hls.HlsPlaylist;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.utils.ByteArray;
   
   public class HlsFormatIndex extends EventDispatcher implements IFormatIndex
   {
      
      protected var script:ByteArray;
      
      protected var playlist:HlsPlaylist;
      
      public function HlsFormatIndex(param1:HlsPlaylist, param2:uint, param3:uint)
      {
         super();
         this.playlist = param1;
         param1.addEventListener(Event.COMPLETE,this.redispatchIfListening);
         param1.addEventListener(ErrorEvent.ERROR,this.redispatchIfListening);
         param1.addEventListener(IOErrorEvent.IO_ERROR,this.redispatchIfListening);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.redispatchIfListening);
         this.script = new ByteArray();
         var _loc4_:Object = {};
         if(param2)
         {
            _loc4_.width = param2;
         }
         if(param3)
         {
            _loc4_.height = param3;
         }
         FlvUtils.writeScriptTag(this.script,"onMetaData",0,_loc4_);
      }
      
      public function onResetPoint(param1:SeekPoint) : void
      {
      }
      
      public function getSeekPoint(param1:uint) : SeekPoint
      {
         param1 = Math.max(param1,this.playlist.chunkStartTime[this.playlist.firstChunk]);
         var _loc2_:int = BinarySearch.lessThanOrEqual(this.playlist.chunkStartTime,param1,this.playlist.firstChunk);
         return _loc2_ < 0 ? null : this.getSeekPointForSequence(_loc2_,param1);
      }
      
      public function get audioHeader() : ByteArray
      {
         return null;
      }
      
      public function getSeekPointForSequence(param1:uint, param2:uint = 0) : SeekPoint
      {
         var _loc3_:SeekPoint = new SeekPoint();
         _loc3_.sequence = param1;
         _loc3_.timestamp = this.playlist.chunkStartTime[param1];
         _loc3_.desiredTimestamp = Math.max(_loc3_.timestamp,param2);
         return _loc3_;
      }
      
      public function getNextSeekPoint(param1:uint) : SeekPoint
      {
         var _loc2_:int = BinarySearch.greaterThanOrEqual(this.playlist.chunkStartTime,param1,this.playlist.firstChunk);
         return _loc2_ < 0 ? null : this.getSeekPointForSequence(_loc2_,param1);
      }
      
      public function onSeekPoint(param1:SeekPoint, param2:Boolean) : void
      {
      }
      
      public function get fileSize() : Number
      {
         return NaN;
      }
      
      public function get videoHeader() : ByteArray
      {
         return null;
      }
      
      public function load() : void
      {
         this.playlist.load();
      }
      
      public function get metadata() : ByteArray
      {
         return this.script;
      }
      
      protected function redispatchIfListening(param1:Event) : void
      {
         if(hasEventListener(param1.type))
         {
            dispatchEvent(param1);
         }
      }
      
      public function canGetAnySeekPoint() : Boolean
      {
         return this.playlist.vod;
      }
      
      public function getLiveSeekPoint() : SeekPoint
      {
         return this.getSeekPointForSequence(this.playlist.liveChunk);
      }
      
      public function canGetSeekPoint(param1:uint) : Boolean
      {
         if(this.playlist.vod)
         {
            return true;
         }
         param1 = Math.max(param1,this.playlist.chunkStartTime[this.playlist.firstChunk]);
         var _loc2_:int = BinarySearch.lessThanOrEqual(this.playlist.chunkStartTime,param1,this.playlist.firstChunk);
         if(_loc2_ < 0)
         {
            return false;
         }
         return this.playlist.chunkStartTime[_loc2_] + this.playlist.chunkDuration[_loc2_] > param1;
      }
      
      public function getTimeFromByte(param1:uint) : uint
      {
         return 0;
      }
   }
}

