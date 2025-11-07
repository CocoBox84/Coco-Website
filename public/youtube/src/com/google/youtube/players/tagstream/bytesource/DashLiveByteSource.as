package com.google.youtube.players.tagstream.bytesource
{
   import com.google.youtube.model.DashLiveFormatIndex;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.players.tagstream.PipelineEventDispatcher;
   import com.google.youtube.util.MediaLocation;
   import flash.utils.ByteArray;
   
   public class DashLiveByteSource extends PipelineEventDispatcher implements IByteSource
   {
      
      protected var mediaLocation:MediaLocation;
      
      protected var videoFormat:VideoFormat;
      
      protected var upstream:HttpByteSource;
      
      protected var seq:int;
      
      public function DashLiveByteSource(param1:VideoFormat, param2:MediaLocation)
      {
         super();
         this.mediaLocation = param2;
         this.videoFormat = param1;
      }
      
      protected function get nextChunkReady() : Boolean
      {
         var _loc1_:DashLiveFormatIndex = DashLiveFormatIndex(this.mediaLocation.formatIndex);
         return _loc1_.getChunkUrl(this.seq + 1) != null;
      }
      
      public function open(param1:SeekPoint) : void
      {
         this.seq = param1.sequence;
         this.openNextChunk();
      }
      
      public function info(param1:PlayerInfo) : void
      {
         if(this.upstream)
         {
            this.upstream.info(param1);
         }
      }
      
      protected function openNextChunk() : void
      {
         var _loc1_:DashLiveFormatIndex = DashLiveFormatIndex(this.mediaLocation.formatIndex);
         var _loc2_:MediaLocation = new MediaLocation();
         _loc2_.primaryUrl = _loc1_.getChunkUrl(this.seq);
         this.upstream = new HttpByteSource(_loc2_);
         forwardEvents(this.upstream,true);
         this.upstream.open(new SeekPoint());
      }
      
      public function close() : void
      {
         this.upstream.close();
         stopForwardingEvents(this.upstream,true);
         this.upstream = null;
      }
      
      public function get eof() : Boolean
      {
         return this.videoFormat.dashLiveMpd.isDone && this.upstream && this.upstream.eof && !this.nextChunkReady;
      }
      
      public function read(param1:ByteArray, param2:uint, param3:uint) : uint
      {
         var _loc4_:uint = this.upstream.read(param1,param2,param3);
         if(_loc4_ == 0 && this.upstream.eof && this.nextChunkReady)
         {
            this.close();
            ++this.seq;
            this.openNextChunk();
         }
         return _loc4_;
      }
   }
}

