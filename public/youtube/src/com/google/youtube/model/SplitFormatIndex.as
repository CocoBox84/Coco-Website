package com.google.youtube.model
{
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.utils.ByteArray;
   
   public class SplitFormatIndex extends EventDispatcher implements IFormatIndex
   {
      
      public var audio:IFormatIndex;
      
      public var video:IFormatIndex;
      
      public function SplitFormatIndex(param1:IFormatIndex, param2:IFormatIndex)
      {
         super();
         this.audio = param1;
         this.video = param2;
         param1.addEventListener(Event.COMPLETE,this.onLoadComplete);
         param1.addEventListener(IOErrorEvent.IO_ERROR,dispatchEvent);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,dispatchEvent);
         param1.addEventListener(ErrorEvent.ERROR,dispatchEvent);
         param2.addEventListener(Event.COMPLETE,this.onLoadComplete);
         param2.addEventListener(IOErrorEvent.IO_ERROR,dispatchEvent);
         param2.addEventListener(SecurityErrorEvent.SECURITY_ERROR,dispatchEvent);
         param2.addEventListener(ErrorEvent.ERROR,dispatchEvent);
      }
      
      public function onResetPoint(param1:SeekPoint) : void
      {
      }
      
      public function getSeekPoint(param1:uint) : SeekPoint
      {
         var _loc2_:SeekPoint = new SeekPoint();
         _loc2_.desiredTimestamp = param1;
         _loc2_.audio = this.audio.getSeekPoint(param1);
         _loc2_.video = this.video.getSeekPoint(param1);
         _loc2_.timestamp = Math.min(_loc2_.audio.timestamp,_loc2_.video.timestamp);
         return _loc2_;
      }
      
      public function get audioHeader() : ByteArray
      {
         return this.audio.audioHeader;
      }
      
      public function getNextSeekPoint(param1:uint) : SeekPoint
      {
         var _loc2_:SeekPoint = new SeekPoint();
         _loc2_.audio = this.audio.getNextSeekPoint(param1);
         _loc2_.video = this.video.getNextSeekPoint(param1);
         _loc2_.timestamp = Math.min(_loc2_.audio.timestamp,_loc2_.video.timestamp);
         _loc2_.desiredTimestamp = Math.max(_loc2_.audio.desiredTimestamp,_loc2_.video.desiredTimestamp);
         return _loc2_;
      }
      
      public function onSeekPoint(param1:SeekPoint, param2:Boolean) : void
      {
      }
      
      public function get fileSize() : Number
      {
         return NaN;
      }
      
      public function load() : void
      {
         this.audio.load();
         this.video.load();
      }
      
      public function canGetAnySeekPoint() : Boolean
      {
         return this.audio.canGetAnySeekPoint() && this.video.canGetAnySeekPoint();
      }
      
      public function get metadata() : ByteArray
      {
         return this.video.metadata;
      }
      
      public function get videoHeader() : ByteArray
      {
         return this.video.videoHeader;
      }
      
      public function canGetSeekPoint(param1:uint) : Boolean
      {
         return this.audio.canGetSeekPoint(param1) && this.video.canGetSeekPoint(param1);
      }
      
      public function getTimeFromByte(param1:uint) : uint
      {
         throw new Error();
      }
      
      protected function onLoadComplete(param1:Event) : void
      {
         if(this.audio.canGetAnySeekPoint() && this.video.canGetAnySeekPoint())
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
   }
}

