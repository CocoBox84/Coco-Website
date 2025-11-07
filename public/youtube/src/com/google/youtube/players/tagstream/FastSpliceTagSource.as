package com.google.youtube.players.tagstream
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.tag.DataTag;
   
   public class FastSpliceTagSource extends PipelineEventDispatcher implements ISplicingTagSource
   {
      
      public static var spliceAsap:Boolean;
      
      protected var upstreamReadahead:IReadaheadTagSource;
      
      protected var spliceFormat:VideoFormat;
      
      protected var upstream:ITagSource;
      
      protected var lastTimestamp:uint;
      
      protected var upstreamFormat:VideoFormat;
      
      protected var spliceSource:IReadaheadTagSource;
      
      public function FastSpliceTagSource(param1:ITagSource, param2:VideoFormat)
      {
         super();
         this.spliceSource = IReadaheadTagSource(param1);
         this.spliceFormat = param2;
         this.activateSpliceSource(-1,false);
      }
      
      public function splice(param1:ITagSource, param2:VideoFormat) : void
      {
         var _loc3_:SeekPoint = null;
         this.spliceFormat = param2;
         if(!spliceAsap)
         {
            _loc3_ = param2.formatIndex.getNextSeekPoint(this.lastTimestamp);
         }
         if(!_loc3_ || _loc3_.timestamp > this.upstreamReadahead.loadedTime)
         {
            _loc3_ = param2.formatIndex.getSeekPoint(this.lastTimestamp);
         }
         if(_loc3_)
         {
            this.upstreamReadahead.stop();
            this.openSpliceSource(IReadaheadTagSource(param1),_loc3_);
         }
      }
      
      public function get splicing() : Boolean
      {
         return Boolean(this.spliceSource);
      }
      
      protected function activateSpliceSource(param1:int, param2:Boolean) : void
      {
         while(param1 >= 0 && this.spliceSource.peekTime >= 0 && this.spliceSource.peekTime < param1)
         {
            this.spliceSource.pop();
         }
         this.detachSpliceSource(false);
         this.closeUpstream();
         this.upstream = this.upstreamReadahead = this.spliceSource;
         this.spliceSource = null;
         this.upstreamFormat = this.spliceFormat;
         this.spliceFormat = null;
         if(param2)
         {
            this.upstream = new InterframeTagSource(this.upstreamReadahead,this.lastTimestamp + 1);
         }
         forwardEvents(this.upstream,true);
      }
      
      public function get eof() : Boolean
      {
         return Boolean(this.upstream) && this.upstream.eof;
      }
      
      public function pop() : DataTag
      {
         if(this.spliceSource)
         {
            this.maybeSpliceNow();
         }
         var _loc1_:DataTag = this.upstream.pop();
         if(_loc1_)
         {
            this.lastTimestamp = _loc1_.timestamp;
         }
         return _loc1_;
      }
      
      public function open(param1:SeekPoint) : void
      {
         this.upstream.open(param1);
         this.lastTimestamp = param1.timestamp;
      }
      
      protected function openSpliceSource(param1:IReadaheadTagSource, param2:SeekPoint) : void
      {
         this.detachSpliceSource(true);
         this.spliceSource = param1;
         forwardEvents(this.spliceSource,false);
         this.spliceSource.open(param2);
      }
      
      public function get target() : VideoFormat
      {
         return this.splicing ? this.spliceFormat : this.upstreamFormat;
      }
      
      protected function detachSpliceSource(param1:Boolean) : void
      {
         if(this.spliceSource)
         {
            stopForwardingEvents(this.spliceSource,false);
            if(param1)
            {
               this.spliceSource.close();
               this.spliceSource = null;
               this.spliceFormat = null;
            }
         }
      }
      
      protected function closeUpstream() : void
      {
         if(this.upstream)
         {
            stopForwardingEvents(this.upstream,true);
            this.upstream.close();
            this.upstreamFormat = null;
            this.upstream = null;
         }
      }
      
      public function info(param1:PlayerInfo) : void
      {
         param1.splicingNow = Boolean(this.spliceSource);
         if(this.upstream)
         {
            this.upstream.info(param1);
         }
      }
      
      public function close() : void
      {
         this.closeUpstream();
         this.detachSpliceSource(true);
      }
      
      protected function maybeSpliceNow() : void
      {
         var _loc1_:int = this.upstreamReadahead.peekTime;
         if(_loc1_ < 0)
         {
            this.activateSpliceSource(-1,true);
            return;
         }
         var _loc2_:Array = this.spliceSource.gopTimes.concat();
         while(Boolean(_loc2_.length) && _loc2_[0] <= _loc1_)
         {
            if(_loc2_[0] > this.lastTimestamp)
            {
               this.activateSpliceSource(_loc2_[0],false);
               return;
            }
            if(spliceAsap || _loc2_[_loc2_.length - 1] < _loc1_ - 10000)
            {
               this.activateSpliceSource(_loc2_[0],true);
               return;
            }
            if(!_loc2_[1])
            {
               return;
            }
            if(_loc2_[1] > this.upstreamReadahead.loadedTime)
            {
               this.activateSpliceSource(_loc2_[0],true);
               return;
            }
            _loc2_.shift();
         }
      }
   }
}

