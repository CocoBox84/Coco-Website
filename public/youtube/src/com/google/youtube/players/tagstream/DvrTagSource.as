package com.google.youtube.players.tagstream
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.tag.DataTag;
   import com.google.youtube.model.tag.Gop;
   import com.google.youtube.time.TimeRange;
   import com.google.youtube.util.FlvUtils;
   import com.google.youtube.util.RedBlackTree;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.utils.Dictionary;
   
   public class DvrTagSource extends PipelineEventDispatcher implements IReadaheadTagSource
   {
      
      protected static var activeDvr:DvrTagSource;
      
      public static var cache:Object = {};
      
      protected static var cacheSize:uint = 0;
      
      public static var CACHE_LIMIT:uint = 50331648;
      
      public static var READ_AHEAD:uint = 40000;
      
      public static const READ_AHEAD_LIMIT:uint = 50;
      
      protected static const emptyGop:Gop = new Gop();
      
      protected static var inUseDvrsByCache:Dictionary = new Dictionary();
      
      protected var seekPoint:SeekPoint;
      
      protected var allowReadahead:Boolean = true;
      
      protected var pipeline:ITagSource;
      
      protected var pipelineOpened:Boolean = false;
      
      protected var popCache:RedBlackTree;
      
      protected var firstKeyframe:Boolean = true;
      
      protected var parseGopTime:uint = 0;
      
      protected var videoFormat:VideoFormat;
      
      protected var parseGop:Gop = new Gop();
      
      protected var popGopTime:uint = 0;
      
      protected var popGop:Gop;
      
      protected var cacheKey:String;
      
      public function DvrTagSource(param1:ITagSource, param2:String, param3:VideoFormat, param4:Boolean = true)
      {
         super();
         this.pipeline = param1;
         cache[param2] = cache[param2] || new Dictionary();
         cache[param2][param3] = cache[param2][param3] || new RedBlackTree();
         this.popCache = cache[param2][param3];
         this.cacheKey = param2;
         this.videoFormat = param3;
         this.allowReadahead = param4;
      }
      
      protected static function deleteInactiveCacheGop(param1:String, param2:VideoFormat) : Boolean
      {
         var _loc3_:RedBlackTree = RedBlackTree(cache[param1][param2]);
         var _loc4_:uint = inUseDvrsByCache[_loc3_] ? uint(inUseDvrsByCache[_loc3_].popGopTime) : 0;
         var _loc5_:uint = activeDvr ? activeDvr.popGopTime : 0;
         var _loc6_:Gop = Gop(_loc3_.minNode());
         var _loc7_:Gop = Gop(_loc3_.maxNode());
         var _loc8_:int = _loc7_.timestamp - _loc5_;
         var _loc9_:int = _loc5_ - _loc6_.timestamp;
         if(_loc6_.timestamp < _loc4_ || _loc9_ > _loc8_)
         {
            _loc3_.deleteMin();
            cacheSize -= _loc6_.byteLength;
         }
         else
         {
            _loc3_.deleteMax();
            cacheSize -= _loc7_.byteLength;
         }
         if(_loc3_.empty)
         {
            delete cache[param1][param2];
         }
         return true;
      }
      
      protected static function deleteCacheGop() : Boolean
      {
         var _loc1_:RedBlackTree = null;
         var _loc2_:VideoFormat = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:Boolean = false;
         for(_loc3_ in cache)
         {
            if(!(Boolean(activeDvr) && _loc3_ == activeDvr.cacheKey))
            {
               for(_loc4_ in cache[_loc3_])
               {
                  _loc2_ = VideoFormat(_loc4_);
                  if(!cache[_loc3_][_loc2_].empty)
                  {
                     return deleteInactiveCacheGop(_loc3_,_loc2_);
                  }
               }
            }
         }
         if(activeDvr)
         {
            for each(_loc5_ in [true,false])
            {
               for(_loc4_ in cache[activeDvr.cacheKey])
               {
                  _loc2_ = VideoFormat(_loc4_);
                  _loc1_ = cache[activeDvr.cacheKey][_loc2_];
                  if(_loc1_ != activeDvr.popCache)
                  {
                     if(!(_loc5_ && Boolean(inUseDvrsByCache[_loc1_])))
                     {
                        if(!_loc1_.empty)
                        {
                           return deleteInactiveCacheGop(activeDvr.cacheKey,_loc2_);
                        }
                     }
                  }
               }
            }
            return activeDvr.deleteActiveCacheGop();
         }
         return false;
      }
      
      protected function computeSeekPoint(param1:uint) : void
      {
         var _loc2_:Gop = this.last(this.findContainingGop(param1));
         var _loc3_:uint = param1;
         if(_loc2_)
         {
            if(_loc2_.last)
            {
               this.pipeline = null;
               this.parseGopTime = _loc2_.endtimestamp;
               return;
            }
            _loc3_ = _loc2_.endtimestamp;
         }
         this.seekPoint = this.videoFormat.formatIndex.getSeekPoint(_loc3_);
         this.parseGopTime = _loc2_ ? _loc3_ : this.seekPoint.timestamp;
         this.videoFormat.formatIndex.onResetPoint(this.seekPoint);
      }
      
      public function stop() : void
      {
         if(this.pipeline)
         {
            this.pipeline.close();
            this.pipeline.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
            stopForwardingEvents(this.pipeline,false);
            this.pipeline = null;
         }
         if(this == activeDvr)
         {
            activeDvr = null;
         }
      }
      
      public function get eof() : Boolean
      {
         return Boolean(this.popGop) && this.popGop.last;
      }
      
      public function getBuffers() : Array
      {
         var _loc3_:Gop = null;
         var _loc1_:Array = [];
         var _loc2_:Gop = Gop(this.popCache.minNode());
         while(_loc2_)
         {
            _loc3_ = this.last(_loc2_);
            _loc1_.push(new TimeRange(_loc2_.timestamp,_loc3_.endtimestamp));
            _loc2_ = Gop(this.popCache.greaterThan(_loc3_.timestamp));
         }
         return _loc1_;
      }
      
      public function close() : void
      {
         this.stop();
         this.parseGop = null;
         this.parseGopTime = 0;
         this.popGop = null;
         this.popGopTime = 0;
         inUseDvrsByCache[this.popCache] = null;
      }
      
      protected function advance() : Gop
      {
         var _loc2_:DataTag = null;
         while(cacheSize > CACHE_LIMIT && deleteCacheGop())
         {
         }
         if(this.shouldOpenNow)
         {
            this.openSeekPoint();
         }
         var _loc1_:int = int(READ_AHEAD_LIMIT);
         while(true)
         {
            _loc2_ = this.pipeline.pop();
            if(!(this.needReadAhead && _loc1_ && (Boolean(_loc2_))))
            {
               break;
            }
            if(_loc2_.timestamp >= this.parseGopTime)
            {
               this.insert(_loc2_.clone());
            }
            _loc1_--;
         }
         if(this.pipeline && this.pipeline.eof && Boolean(this.parseGop))
         {
            this.parseGop.last = true;
            this.parseGopTime = this.parseGop.endtimestamp;
            this.add(this.parseGop);
            this.videoFormat.formatIndex.onSeekPoint(this.parseGop.getSeekPoint(),true);
            this.parseGop = null;
         }
         if(this.popGop)
         {
            return this.popGop.exhausted ? this.nextPopGop() : this.popGop;
         }
         return emptyGop;
      }
      
      protected function last(param1:Gop) : Gop
      {
         var _loc2_:Gop = null;
         while(true)
         {
            _loc2_ = this.next(param1);
            if(!_loc2_)
            {
               break;
            }
            param1 = _loc2_;
         }
         return param1;
      }
      
      public function get gopTimes() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:Gop = this.popGop;
         while(_loc2_)
         {
            _loc1_.push(_loc2_.timestamp);
            _loc2_ = this.next(_loc2_);
         }
         if(this.popGop != this.parseGop)
         {
            _loc1_.push(this.parseGopTime);
         }
         return _loc1_;
      }
      
      protected function add(param1:Gop) : void
      {
         this.popCache.insert(param1.timestamp,param1);
         cacheSize += param1.byteLength;
      }
      
      protected function onProgress(param1:Event) : void
      {
         this.advance();
         dispatchEvent(param1);
      }
      
      public function info(param1:PlayerInfo) : void
      {
         param1.loadedTime = this.loadedTime;
         if(this.pipeline)
         {
            this.pipeline.info(param1);
         }
      }
      
      protected function detectFilledGap() : void
      {
         var _loc1_:Gop = this.find(this.parseGop.timestamp);
         if(_loc1_)
         {
            this.pipeline.close();
            this.pipelineOpened = false;
            this.firstKeyframe = true;
            this.parseGop = new Gop();
            this.computeSeekPoint(_loc1_.timestamp);
            if(this.shouldOpenNow)
            {
               this.openSeekPoint();
            }
         }
      }
      
      protected function insert(param1:DataTag) : void
      {
         if(FlvUtils.isKeyFrame(param1))
         {
            if(this.firstKeyframe)
            {
               this.onFirstKeyFrame(param1);
            }
            else
            {
               this.onNextKeyFrame(param1);
            }
            this.videoFormat.formatIndex.onSeekPoint(this.parseGop.getSeekPoint(),false);
            this.detectFilledGap();
         }
         else
         {
            this.parseGop.push(param1);
         }
      }
      
      protected function find(param1:uint) : Gop
      {
         return Gop(this.popCache.find(param1));
      }
      
      public function open(param1:SeekPoint) : void
      {
         activeDvr = this;
         inUseDvrsByCache[this.popCache] = this;
         this.popGop = this.findContainingGop(param1.desiredTimestamp);
         if(this.popGop)
         {
            this.popGop.begin();
            this.popGopTime = this.popGop.timestamp;
         }
         else
         {
            this.popGopTime = param1.timestamp;
         }
         this.pipeline.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         forwardEvents(this.pipeline,false);
         this.computeSeekPoint(param1.desiredTimestamp);
         if(this.shouldOpenNow)
         {
            this.openSeekPoint();
         }
      }
      
      protected function openSeekPoint() : void
      {
         if(this.pipeline)
         {
            this.parseGop = new Gop();
            this.pipeline.open(this.seekPoint);
            this.pipelineOpened = true;
         }
      }
      
      public function get peekTime() : int
      {
         var _loc1_:DataTag = this.advance().peek();
         return _loc1_ ? int(_loc1_.timestamp) : -1;
      }
      
      protected function deleteActiveCacheGop() : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(this.popCache.empty)
         {
            return false;
         }
         var _loc1_:Gop = Gop(this.popCache.minNode());
         var _loc2_:Gop = Gop(this.popCache.maxNode());
         var _loc3_:* = _loc1_.timestamp < this.popGopTime;
         var _loc4_:* = _loc2_.timestamp > this.parseGopTime;
         if(!_loc3_ && !_loc4_)
         {
            return false;
         }
         if(_loc3_ && !_loc4_)
         {
            this.popCache.deleteMin();
            cacheSize -= _loc1_.byteLength;
         }
         else if(!_loc3_ && _loc4_)
         {
            this.popCache.deleteMax();
            cacheSize -= _loc2_.byteLength;
         }
         else if(_loc3_ && _loc4_)
         {
            _loc5_ = _loc2_.timestamp - this.popGopTime;
            _loc6_ = this.popGopTime - _loc1_.timestamp;
            if(_loc6_ > _loc5_)
            {
               this.popCache.deleteMin();
               cacheSize -= _loc1_.byteLength;
            }
            else
            {
               this.popCache.deleteMax();
               cacheSize -= _loc2_.byteLength;
            }
         }
         return true;
      }
      
      protected function nextPopGop() : Gop
      {
         var _loc1_:Gop = this.next(this.popGop) || this.maybeUseParseGop();
         if(_loc1_)
         {
            this.popGop = _loc1_;
            this.popGopTime = this.popGop.timestamp;
            this.popGop.begin();
         }
         return this.popGop;
      }
      
      protected function get needReadAhead() : Boolean
      {
         return this.allowReadahead && this.pipeline && this.popGopTime + READ_AHEAD > this.parseGopTime && cacheSize <= CACHE_LIMIT;
      }
      
      public function pop() : DataTag
      {
         return this.advance().next();
      }
      
      protected function findContainingGop(param1:uint) : Gop
      {
         var _loc2_:Gop = Gop(this.popCache.lessThanOrEqual(param1));
         return Boolean(_loc2_) && _loc2_.endtimestamp > param1 ? _loc2_ : null;
      }
      
      protected function onNextKeyFrame(param1:DataTag) : void
      {
         var _loc2_:Gop = this.parseGop.peelAudio();
         _loc2_.push(param1);
         if(_loc2_.timestamp == this.parseGop.timestamp)
         {
            this.parseGop.append(_loc2_);
            return;
         }
         this.parseGop.endtimestamp = _loc2_.timestamp;
         _loc2_.byteOffset = this.parseGop.byteOffset + this.parseGop.byteLength;
         this.add(this.parseGop);
         this.parseGop = _loc2_;
         this.parseGopTime = this.parseGop.timestamp;
      }
      
      public function isCached(param1:uint) : Boolean
      {
         return Boolean(this.findContainingGop(param1));
      }
      
      public function get loadedTime() : Number
      {
         return Boolean(this.parseGop) && Boolean(this.parseGop.byteLength) ? this.parseGop.lastTimestamp : this.parseGopTime;
      }
      
      protected function next(param1:Gop) : Gop
      {
         return param1 && param1.complete && !param1.last ? this.find(param1.endtimestamp) : null;
      }
      
      protected function maybeUseParseGop() : Gop
      {
         return this.popGop.complete && !this.popGop.last && this.parseGop && this.popGop != this.parseGop && this.parseGop.timestamp == this.popGop.endtimestamp ? this.parseGop : null;
      }
      
      protected function get shouldOpenNow() : Boolean
      {
         return !this.pipelineOpened && this.needReadAhead;
      }
      
      protected function onFirstKeyFrame(param1:DataTag) : void
      {
         this.parseGop.push(param1);
         this.popGop = this.popGop || this.parseGop;
         this.firstKeyframe = false;
      }
   }
}

