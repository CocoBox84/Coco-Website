package com.google.youtube.model.tag
{
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.util.FlvUtils;
   import flash.utils.ByteArray;
   
   public class TagFormat
   {
      
      protected var metadataValue:ByteArray;
      
      protected var audioHeaderValue:ByteArray;
      
      protected var videoHeaderValue:ByteArray;
      
      public var videoFormat:VideoFormat;
      
      public function TagFormat(param1:VideoFormat)
      {
         super();
         this.videoFormat = param1;
      }
      
      public function get audioHeader() : ByteArray
      {
         return this.audioHeaderValue || this.videoFormat.formatIndex.audioHeader;
      }
      
      public function get videoHeader() : ByteArray
      {
         return this.videoHeaderValue || this.videoFormat.formatIndex.videoHeader;
      }
      
      public function setAacAudioSpecificConfig(param1:ByteArray) : TagFormat
      {
         var _loc3_:TagFormat = null;
         var _loc2_:ByteArray = new ByteArray();
         FlvUtils.writeFrameHeader(_loc2_,FlvUtils.TAG_TYPE_AUDIO,0);
         FlvUtils.writeAacSequenceHeaderPreamble(_loc2_);
         _loc2_.writeBytes(param1);
         FlvUtils.writeFrameTrailer(_loc2_);
         if(!this.audioHeader || this.bytesMatch(this.audioHeader,_loc2_))
         {
            this.audioHeaderValue = this.audioHeaderValue || _loc2_;
            return this;
         }
         _loc3_ = new TagFormat(this.videoFormat);
         _loc3_.audioHeaderValue = _loc2_;
         _loc3_.videoHeaderValue = this.videoHeaderValue;
         _loc3_.metadataValue = this.metadataValue;
         return _loc3_;
      }
      
      public function get metadata() : ByteArray
      {
         return this.metadataValue || this.videoFormat.formatIndex.metadata;
      }
      
      protected function bytesMatch(param1:ByteArray, param2:ByteArray) : Boolean
      {
         if(param1.length != param2.length)
         {
            return false;
         }
         var _loc3_:int = 0;
         while(_loc3_ < param1.position)
         {
            if(param1[_loc3_] != param2[_loc3_])
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public function setAvcDecoderConfiguration(param1:ByteArray) : TagFormat
      {
         var _loc3_:TagFormat = null;
         var _loc2_:ByteArray = new ByteArray();
         FlvUtils.writeFrameHeader(_loc2_,FlvUtils.TAG_TYPE_VIDEO,0);
         FlvUtils.writeAvcSequenceHeaderPreamble(_loc2_);
         _loc2_.writeBytes(param1);
         FlvUtils.writeFrameTrailer(_loc2_);
         if(!this.videoHeader || this.bytesMatch(this.videoHeader,_loc2_))
         {
            this.videoHeaderValue = this.videoHeaderValue || _loc2_;
            return this;
         }
         _loc3_ = new TagFormat(this.videoFormat);
         _loc3_.videoHeaderValue = _loc2_;
         _loc3_.audioHeaderValue = this.audioHeaderValue;
         _loc3_.metadataValue = this.metadataValue;
         return _loc3_;
      }
   }
}

