package com.google.youtube.model.tag
{
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.util.FlvUtils;
   
   public class Gop
   {
      
      protected var lastValue:Boolean;
      
      protected var byteLengthValue:uint;
      
      protected var lastVideoIndex:int = -1;
      
      public var endtimestamp:uint;
      
      protected var frames:Array = [];
      
      protected var iterator:uint;
      
      public var byteOffset:uint;
      
      public function Gop()
      {
         super();
      }
      
      protected function get trailingAudio() : Boolean
      {
         return Boolean(this.frames.length) && FlvUtils.getTagType(this.frames[this.frames.length - 1]) == FlvUtils.TAG_TYPE_AUDIO;
      }
      
      public function getSeekPoint() : SeekPoint
      {
         var _loc1_:SeekPoint = new SeekPoint();
         _loc1_.timestamp = this.timestamp;
         _loc1_.byteOffset = this.byteOffset;
         return _loc1_;
      }
      
      public function get byteLength() : uint
      {
         return this.byteLengthValue;
      }
      
      public function get exhausted() : Boolean
      {
         return this.complete && this.iterator == this.frames.length;
      }
      
      protected function pop() : DataTag
      {
         var _loc1_:DataTag = this.frames.pop();
         this.byteLengthValue -= _loc1_ ? _loc1_.length : 0;
         return _loc1_;
      }
      
      public function get last() : Boolean
      {
         return this.lastValue;
      }
      
      public function push(param1:DataTag) : void
      {
         this.byteLengthValue += param1.length;
         if(FlvUtils.getTagType(param1) == FlvUtils.TAG_TYPE_VIDEO)
         {
            this.lastVideoIndex = this.frames.length;
         }
         this.frames.push(param1);
      }
      
      public function peek() : DataTag
      {
         return this.iterator <= this.lastVideoIndex || this.complete ? this.frames[this.iterator] : null;
      }
      
      public function get timestamp() : uint
      {
         return this.frames.length ? uint(this.frames[0].timestamp) : 0;
      }
      
      public function get lastTimestamp() : uint
      {
         return this.frames.length > 0 ? uint(this.frames[this.frames.length - 1].timestamp) : 0;
      }
      
      public function peelAudio() : Gop
      {
         var _loc1_:Gop = new Gop();
         var _loc2_:Array = [];
         while(this.trailingAudio)
         {
            _loc2_.push(this.pop());
         }
         while(_loc2_.length)
         {
            _loc1_.push(_loc2_.pop());
         }
         return _loc1_;
      }
      
      public function begin() : void
      {
         this.iterator = 0;
      }
      
      public function set last(param1:Boolean) : void
      {
         this.lastValue = param1;
         if(param1)
         {
            this.endtimestamp = this.frames.length ? uint(this.frames[this.frames.length - 1].timestamp) : 0;
         }
      }
      
      public function append(param1:Gop) : void
      {
         this.last = param1.lastValue;
         this.byteLengthValue += param1.byteLengthValue;
         if(param1.lastVideoIndex >= 0)
         {
            this.lastVideoIndex = this.frames.length + param1.lastVideoIndex;
         }
         this.frames = this.frames.concat(param1.frames);
      }
      
      public function next() : DataTag
      {
         return this.iterator < this.frames.length && (this.iterator <= this.lastVideoIndex || this.complete) ? this.frames[this.iterator++] : null;
      }
      
      public function get complete() : Boolean
      {
         return this.endtimestamp != 0;
      }
   }
}

