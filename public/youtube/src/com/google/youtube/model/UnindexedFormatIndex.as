package com.google.youtube.model
{
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   
   public class UnindexedFormatIndex extends EventDispatcher implements IFormatIndex
   {
      
      public function UnindexedFormatIndex()
      {
         super();
      }
      
      public function onResetPoint(param1:SeekPoint) : void
      {
      }
      
      public function canGetSeekPoint(param1:uint) : Boolean
      {
         return true;
      }
      
      public function getSeekPoint(param1:uint) : SeekPoint
      {
         return new SeekPoint();
      }
      
      public function get audioHeader() : ByteArray
      {
         return null;
      }
      
      public function canGetAnySeekPoint() : Boolean
      {
         return true;
      }
      
      public function getNextSeekPoint(param1:uint) : SeekPoint
      {
         return new SeekPoint();
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
      }
      
      public function getTimeFromByte(param1:uint) : uint
      {
         return 0;
      }
      
      public function get metadata() : ByteArray
      {
         return null;
      }
      
      public function get videoHeader() : ByteArray
      {
         return null;
      }
   }
}

