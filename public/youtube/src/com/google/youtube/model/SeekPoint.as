package com.google.youtube.model
{
   public class SeekPoint
   {
      
      public var sequence:int;
      
      public var video:SeekPoint;
      
      public var currentVideoChunk:uint;
      
      public var currentVideoSample:uint;
      
      public var currentAudioChunk:uint;
      
      public var byteLength:uint;
      
      public var firstDesiredVideoSample:uint;
      
      public var audio:SeekPoint;
      
      public var desiredTimestamp:uint;
      
      public var timestamp:uint;
      
      public var currentAudioSample:uint;
      
      public var firstDesiredAudioSample:uint;
      
      public var byteOffset:uint;
      
      public var skipDiscontinuity:Boolean;
      
      public function SeekPoint()
      {
         super();
      }
      
      public function toString() : String
      {
         var _loc1_:String = "SeekPoint(";
         _loc1_ += "ByteOffset(" + this.byteOffset;
         _loc1_ += "), Timestamp(" + this.timestamp;
         _loc1_ += "), CurrentAudioChunk(" + this.currentAudioChunk;
         _loc1_ += "), CurrentAudioSample(" + this.currentAudioSample;
         _loc1_ += "), firstDesiredAudioSample(" + this.firstDesiredAudioSample;
         _loc1_ += "), CurrentVideoChunk(" + this.currentVideoChunk;
         _loc1_ += "), CurrentVideoSample(" + this.currentVideoSample;
         _loc1_ += "), firstDesiredVideoSample(" + this.firstDesiredVideoSample;
         _loc1_ += "), sequence(" + this.sequence;
         return _loc1_ + "))";
      }
   }
}

