package com.google.youtube.model.tag
{
   import com.google.youtube.model.VideoFormat;
   import flash.utils.ByteArray;
   
   public class SplitTagFormat extends TagFormat
   {
      
      protected var video:TagFormat;
      
      protected var audio:TagFormat;
      
      public function SplitTagFormat(param1:TagFormat = null, param2:TagFormat = null)
      {
         super(null);
         this.audio = param1;
         this.video = param2;
      }
      
      public function setAudioTagFormat(param1:TagFormat) : SplitTagFormat
      {
         videoFormat = videoFormat || param1.videoFormat;
         this.audio = this.audio || param1;
         return this == param1 || this.audio == param1 ? this : new SplitTagFormat(param1,this.video);
      }
      
      public function setVideoTagFormat(param1:TagFormat) : SplitTagFormat
      {
         videoFormat = videoFormat || param1.videoFormat;
         this.video = this.video || param1;
         return this == param1 || this.video == param1 ? this : new SplitTagFormat(this.audio,param1);
      }
      
      override public function get audioHeader() : ByteArray
      {
         return this.audio ? this.audio.audioHeader : null;
      }
      
      override public function get videoHeader() : ByteArray
      {
         return this.video ? this.video.videoHeader : null;
      }
   }
}

