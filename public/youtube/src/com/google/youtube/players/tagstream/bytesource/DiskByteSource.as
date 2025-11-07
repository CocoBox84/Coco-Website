package com.google.youtube.players.tagstream.bytesource
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.players.tagstream.PipelineEventDispatcher;
   import com.google.youtube.util.MediaLocation;
   import flash.utils.ByteArray;
   
   public class DiskByteSource extends PipelineEventDispatcher implements IByteSource
   {
      
      protected var output:HttpDiskByteSource;
      
      protected var cache:BufferCache;
      
      protected var position:uint;
      
      protected var writer:CacheWriter;
      
      public function DiskByteSource(param1:VideoFormat, param2:MediaLocation)
      {
         super();
         this.cache = new BufferCache(param1);
         this.writer = new CacheWriter(this.cache,param1,param2);
         forwardEvents(this.writer,true);
      }
      
      public static function get available() : Boolean
      {
         return HttpDiskByteSource.available;
      }
      
      public function info(param1:PlayerInfo) : void
      {
         this.writer.info(param1);
      }
      
      public function get bytesLoaded() : uint
      {
         return this.writer.bytesLoaded;
      }
      
      public function get loadedTime() : uint
      {
         return this.writer.loadedTime;
      }
      
      public function read(param1:ByteArray, param2:uint, param3:uint) : uint
      {
         var _loc4_:uint = this.output.read(param1,param2,param3);
         if(_loc4_ == 0 && this.output.eof)
         {
            this.nextOutput();
         }
         this.position += _loc4_;
         this.writer.outputPosition = this.position;
         return _loc4_;
      }
      
      public function close() : void
      {
         this.writer.stop();
         stopForwardingEvents(this.writer,true);
      }
      
      public function open(param1:SeekPoint) : void
      {
         this.writer.startFilling(param1.byteOffset);
         this.position = param1.byteOffset;
         this.output = this.cache.getBufferAt(param1.byteOffset) || this.writer.loadingBuffer;
      }
      
      protected function nextOutput() : void
      {
         var _loc1_:HttpDiskByteSource = this.cache.getBufferAt(this.output.end);
         _loc1_ ||= this.writer.loadingBuffer;
         this.output = _loc1_ ? _loc1_ : this.output;
      }
      
      public function get eof() : Boolean
      {
         return Boolean(this.output) && this.output.eof && this.output.last;
      }
   }
}

