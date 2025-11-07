package com.google.youtube.model
{
   public class PlayerInfo
   {
      
      public var viewPortWidth:int;
      
      public var playbackBytesPerSecond:Number;
      
      public var hardwarePlayback:Boolean;
      
      public var droppedFrames:uint;
      
      public var decodeBufferSeconds:Number;
      
      public var playhead:Number;
      
      public var hasSeamless:Boolean;
      
      public var loadedTime:Number;
      
      public var viewPortHeight:int;
      
      public var splicingNow:Boolean;
      
      public function PlayerInfo()
      {
         super();
      }
      
      public function get hasFullDecodeBuffer() : Boolean
      {
         return this.decodeBufferSeconds > 9;
      }
   }
}

