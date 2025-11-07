package com.google.youtube.model.tag
{
   import com.google.youtube.util.FlvUtils;
   import flash.net.NetStream;
   import flash.utils.ByteArray;
   
   public class DataTag extends ByteArray implements ITag
   {
      
      public var format:TagFormat;
      
      public function DataTag()
      {
         super();
      }
      
      public function set compositionTimeOffset(param1:int) : void
      {
         FlvUtils.setCompositionTimeOffset(this,param1);
      }
      
      public function feed(param1:NetStream) : void
      {
         Object(param1).appendBytes(this);
      }
      
      public function get timestamp() : uint
      {
         return FlvUtils.getTimestamp(this);
      }
      
      public function get compositionTimeOffset() : int
      {
         return FlvUtils.getCompositionTimeOffset(this);
      }
      
      public function set timestamp(param1:uint) : void
      {
         FlvUtils.setTimestamp(this,param1);
      }
      
      public function clone() : DataTag
      {
         var _loc1_:DataTag = new DataTag();
         position = 0;
         readBytes(_loc1_);
         _loc1_.format = this.format;
         return _loc1_;
      }
   }
}

