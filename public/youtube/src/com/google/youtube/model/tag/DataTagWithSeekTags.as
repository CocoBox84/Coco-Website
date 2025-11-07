package com.google.youtube.model.tag
{
   import com.google.youtube.util.FlvUtils;
   import flash.net.NetStream;
   import flash.utils.ByteArray;
   
   public class DataTagWithSeekTags extends DataTag
   {
      
      protected var seekTags:Array = [];
      
      public function DataTagWithSeekTags()
      {
         super();
      }
      
      public function addSeekTag(param1:DataTag) : void
      {
         if(FlvUtils.getTagType(param1) == FlvUtils.TAG_TYPE_VIDEO)
         {
            if(FlvUtils.isKeyFrame(param1))
            {
               this.seekTags = [];
            }
            this.seekTags.push(param1.clone());
         }
      }
      
      public function setTarget(param1:DataTag) : void
      {
         position = 0;
         param1.position = 0;
         param1.readBytes(this);
         format = param1.format;
      }
      
      override public function feed(param1:NetStream) : void
      {
         var _loc3_:DataTag = null;
         var _loc2_:ByteArray = new ByteArray();
         FlvUtils.writeBeginSeekTag(_loc2_,format.videoFormat.name,timestamp);
         Object(param1).appendBytes(_loc2_);
         for each(_loc3_ in this.seekTags)
         {
            _loc3_.feed(param1);
         }
         _loc2_.length = _loc2_.position = 0;
         FlvUtils.writeEndSeekTag(_loc2_,format.videoFormat.name,timestamp);
         Object(param1).appendBytes(_loc2_);
         super.feed(param1);
      }
      
      override public function clone() : DataTag
      {
         var _loc1_:DataTagWithSeekTags = new DataTagWithSeekTags();
         position = 0;
         readBytes(_loc1_);
         _loc1_.format = format;
         _loc1_.seekTags = this.seekTags;
         return _loc1_;
      }
   }
}

