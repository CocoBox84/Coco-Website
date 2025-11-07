package com.google.youtube.players.tagstream
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.tag.DataTag;
   import com.google.youtube.time.TimeRange;
   import com.google.youtube.util.FlvUtils;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   
   public class QueueTagSource extends PipelineEventDispatcher implements IReadaheadTagSource
   {
      
      public static var maxQueueMillis:uint = 40000;
      
      public static var maxQueueBytes:uint = 50331648;
      
      protected var keyframeTimes:Array = [];
      
      protected var queue:Array = [];
      
      protected var upstream:ITagSource;
      
      protected var queueBytes:uint;
      
      public function QueueTagSource(param1:ITagSource)
      {
         super();
         this.upstream = param1;
         forwardEvents(param1,false);
         param1.addEventListener(ProgressEvent.PROGRESS,this.maybeFillQueue);
      }
      
      public function getBuffers() : Array
      {
         return this.queue.length ? [new TimeRange(this.peekTime,this.loadedTime)] : [];
      }
      
      protected function maybeFillQueue(param1:Event = null) : void
      {
         var _loc3_:DataTag = null;
         if(!this.upstream)
         {
            return;
         }
         var _loc2_:uint = uint(this.queue.length + 10);
         while(!this.full && this.queue.length < _loc2_)
         {
            _loc3_ = this.upstream.pop();
            if(!_loc3_)
            {
               break;
            }
            this.append(_loc3_.clone());
            this.queueBytes += _loc3_.length;
         }
         if(Boolean(param1) && Boolean(this.queue.length))
         {
            dispatchEvent(param1);
         }
      }
      
      public function get peekTime() : int
      {
         return this.queue.length ? int(this.queue[0].timestamp) : -1;
      }
      
      public function stop() : void
      {
         if(this.upstream)
         {
            this.upstream.close();
            stopForwardingEvents(this.upstream,false);
            this.upstream.removeEventListener(ProgressEvent.PROGRESS,this.maybeFillQueue);
            this.upstream = null;
         }
      }
      
      public function open(param1:SeekPoint) : void
      {
         this.queue = [];
         this.upstream.open(param1);
      }
      
      public function pop() : DataTag
      {
         if(!this.queue.length)
         {
            this.maybeFillQueue();
         }
         var _loc1_:DataTag = this.shift();
         if(_loc1_)
         {
            this.queueBytes -= _loc1_.length;
            this.maybeFillQueue();
         }
         return _loc1_;
      }
      
      protected function get full() : Boolean
      {
         if(this.queueBytes >= maxQueueBytes)
         {
            return true;
         }
         if(!this.queue.length)
         {
            return false;
         }
         return this.loadedTime - this.peekTime >= maxQueueMillis;
      }
      
      protected function append(param1:DataTag) : void
      {
         if(FlvUtils.isKeyFrame(param1))
         {
            this.keyframeTimes.push(param1.timestamp);
         }
         this.queue.push(param1);
      }
      
      public function get gopTimes() : Array
      {
         return this.keyframeTimes;
      }
      
      protected function shift() : DataTag
      {
         var _loc1_:DataTag = this.queue.shift();
         if(Boolean(_loc1_) && _loc1_.timestamp == this.keyframeTimes[0])
         {
            this.keyframeTimes.shift();
         }
         return _loc1_;
      }
      
      public function isCached(param1:uint) : Boolean
      {
         return false;
      }
      
      public function info(param1:PlayerInfo) : void
      {
         param1.loadedTime = this.loadedTime;
         if(this.upstream)
         {
            this.upstream.info(param1);
         }
      }
      
      public function get loadedTime() : Number
      {
         return this.queue.length ? Number(this.queue[this.queue.length - 1].timestamp) : 0;
      }
      
      public function close() : void
      {
         this.stop();
         this.queue = [];
      }
      
      public function get eof() : Boolean
      {
         return !this.queue.length && Boolean(this.upstream) && this.upstream.eof;
      }
   }
}

