package com.google.youtube.model
{
   import flash.events.IEventDispatcher;
   import flash.utils.ByteArray;
   
   public interface IFormatIndex extends IEventDispatcher
   {
      
      function onResetPoint(param1:SeekPoint) : void;
      
      function canGetSeekPoint(param1:uint) : Boolean;
      
      function getSeekPoint(param1:uint) : SeekPoint;
      
      function get audioHeader() : ByteArray;
      
      function load() : void;
      
      function get videoHeader() : ByteArray;
      
      function getNextSeekPoint(param1:uint) : SeekPoint;
      
      function canGetAnySeekPoint() : Boolean;
      
      function getTimeFromByte(param1:uint) : uint;
      
      function get metadata() : ByteArray;
      
      function onSeekPoint(param1:SeekPoint, param2:Boolean) : void;
      
      function get fileSize() : Number;
   }
}

