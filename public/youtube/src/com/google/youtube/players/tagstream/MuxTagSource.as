package com.google.youtube.players.tagstream
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.tag.DataTag;
   import com.google.youtube.model.tag.SplitTagFormat;
   import com.google.youtube.util.FlvUtils;
   
   public class MuxTagSource extends PipelineEventDispatcher implements ITagSource
   {
      
      protected var lastVideoTimestamp:uint;
      
      protected var videoQueue:Array = [];
      
      protected var audioQueue:Array = [];
      
      protected var lastAudioTimestamp:uint;
      
      protected var audio:ITagSource;
      
      protected var muxed:ITagSource;
      
      protected var splitFormat:SplitTagFormat;
      
      protected var video:ITagSource;
      
      public function MuxTagSource(param1:ITagSource, param2:ITagSource = null)
      {
         super();
         if(param2)
         {
            this.video = param1;
            this.audio = param2;
         }
         else
         {
            this.muxed = param1;
         }
      }
      
      public function get eof() : Boolean
      {
         return !this.audioQueue[0] && !this.videoQueue[0] && (this.muxed ? this.muxed.eof : this.audio.eof && this.video.eof);
      }
      
      public function get proxy() : Object
      {
         return {
            "audio":this.audio,
            "video":this.video,
            "muxed":this.muxed
         };
      }
      
      public function open(param1:SeekPoint) : void
      {
         if(this.muxed)
         {
            forwardEvents(this.muxed,true);
            this.muxed.open(param1);
         }
         else
         {
            forwardEvents(this.audio,true);
            this.audio.open(param1.audio ? param1.audio : param1);
            forwardEvents(this.video,true);
            this.video.open(param1.video ? param1.video : param1);
            this.splitFormat = new SplitTagFormat();
         }
      }
      
      public function pop() : DataTag
      {
         var _loc1_:DataTag = null;
         if(this.muxed)
         {
            while((!this.audioQueue.length || !this.videoQueue.length) && !this.muxed.eof)
            {
               _loc1_ = this.muxed.pop();
               if(!_loc1_)
               {
                  break;
               }
               if(FlvUtils.getTagType(_loc1_) == FlvUtils.TAG_TYPE_AUDIO)
               {
                  this.audioQueue.push(_loc1_);
               }
               else
               {
                  this.videoQueue.push(_loc1_);
               }
            }
         }
         else
         {
            this.audioQueue[0] = this.audioQueue[0] || this.audio.pop();
            this.videoQueue[0] = this.videoQueue[0] || this.video.pop();
            if(this.audioQueue[0])
            {
               this.splitFormat = this.splitFormat.setAudioTagFormat(this.audioQueue[0].format);
               this.audioQueue[0].format = this.splitFormat;
            }
            if(this.videoQueue[0])
            {
               this.splitFormat = this.splitFormat.setVideoTagFormat(this.videoQueue[0].format);
               this.videoQueue[0].format = this.splitFormat;
            }
         }
         if(!this.audioQueue[0])
         {
            if(this.muxed ? this.muxed.eof : this.audio.eof)
            {
               return this.videoQueue.shift();
            }
            return null;
         }
         if(!this.videoQueue[0])
         {
            if(this.muxed ? this.muxed.eof : this.video.eof)
            {
               return this.audioQueue.shift();
            }
            return null;
         }
         if(this.audioQueue[0].timestamp < this.lastAudioTimestamp && this.videoQueue[0].timestamp >= this.lastVideoTimestamp)
         {
            this.lastVideoTimestamp = this.videoQueue[0].timestamp;
            return this.videoQueue.shift();
         }
         if(this.videoQueue[0].timestamp < this.lastVideoTimestamp && this.audioQueue[0].timestamp >= this.lastAudioTimestamp)
         {
            this.lastAudioTimestamp = this.audioQueue[0].timestamp;
            return this.audioQueue.shift();
         }
         this.lastVideoTimestamp = 0;
         this.lastAudioTimestamp = 0;
         if(this.audioQueue[0].timestamp < this.videoQueue[0].timestamp)
         {
            this.lastAudioTimestamp = this.audioQueue[0].timestamp;
            return this.audioQueue.shift();
         }
         this.lastVideoTimestamp = this.videoQueue[0].timestamp;
         return this.videoQueue.shift();
      }
      
      public function info(param1:PlayerInfo) : void
      {
         if(this.muxed)
         {
            this.muxed.info(param1);
         }
         else
         {
            this.audio.info(param1);
            this.video.info(param1);
         }
      }
      
      public function close() : void
      {
         if(this.muxed)
         {
            this.muxed.close();
            stopForwardingEvents(this.muxed,true);
         }
         else
         {
            this.audio.close();
            stopForwardingEvents(this.audio,true);
            this.video.close();
            stopForwardingEvents(this.video,true);
         }
         this.audioQueue = [];
         this.videoQueue = [];
         this.lastVideoTimestamp = 0;
         this.lastAudioTimestamp = 0;
      }
   }
}

