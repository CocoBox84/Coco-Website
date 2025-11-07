package com.google.youtube.time
{
   import com.google.events.SchedulerEvent;
   import com.google.utils.Scheduler;
   import com.google.youtube.players.IEndedState;
   import com.google.youtube.players.IPlayingState;
   import com.google.youtube.players.ISeekingState;
   import com.google.youtube.players.StateChangeEvent;
   import flash.events.EventDispatcher;
   
   public class CueRangeManager extends EventDispatcher
   {
      
      internal static var schedulerSetTimeout:Function = Scheduler.setTimeout;
      
      protected static const UPDATE_INTERVAL:int = 250;
      
      protected static const MAX_SYNC_CHAIN:int = 3;
      
      public var started:Boolean = false;
      
      protected var activeCueRanges:Array = [];
      
      protected var nextEventScheduler:Scheduler;
      
      protected var cueRangesAdded:Boolean;
      
      public var getMediaTime:Function;
      
      private var isSyncing:Boolean = false;
      
      public var allowExclusiveLock:Boolean = true;
      
      protected var cueRanges:Array = [];
      
      protected var lastLockedCueRange:CueRange;
      
      private var hasQueuedSync:Boolean = false;
      
      protected var cueRangesIndex:IntervalList = new IntervalList();
      
      protected var seekingScheduler:Scheduler;
      
      protected var lastMediaTime:int;
      
      public var getPlayerState:Function;
      
      public function CueRangeManager(param1:Function, param2:Function)
      {
         super();
         this.getMediaTime = param1;
         this.getPlayerState = param2;
         this.seekingScheduler = Scheduler.setInterval(UPDATE_INTERVAL,this.sync);
         this.seekingScheduler.stop();
      }
      
      public function stopPlayback() : void
      {
         this.started = false;
         this.stopNextEvent();
      }
      
      public function releaseExclusiveLock(param1:String = null) : void
      {
         if(!this.lastLockedCueRange || this.lastLockedCueRange.id != param1)
         {
            return;
         }
         var _loc2_:CueRange = this.lastLockedCueRange;
         var _loc3_:Array = this.enterCueRanges(this.cueRangesIndex.findIntervals(this.currentMediaTime));
         if(_loc2_ == this.lastLockedCueRange)
         {
            _loc3_.unshift(new CueRangeEvent(CueRangeEvent.LOCK_BLOCK_EXIT,_loc2_));
            this.lastLockedCueRange = null;
         }
         this.handleCueRangeEvents(_loc3_);
         this.onPlayerStateChange(new StateChangeEvent(StateChangeEvent.STATE_CHANGE,this.getPlayerState(),null));
      }
      
      public function removeCueRangesByClassName(param1:String) : void
      {
         var _loc2_:int = int(this.cueRanges.length - 1);
         while(_loc2_ >= 0)
         {
            if(this.cueRanges[_loc2_].className == param1)
            {
               this.removeCueRangeAt(_loc2_);
            }
            _loc2_--;
         }
         this.sync();
      }
      
      protected function removeCueRangeAt(param1:int) : void
      {
         var _loc2_:CueRange = CueRange(this.cueRanges.splice(param1,1)[0]);
         _loc2_.removeEventListener(CueRangeEvent.CHANGE,this.onCueRangeChanged);
         this.cueRangesIndex.removeInterval(_loc2_);
         param1 = int(this.activeCueRanges.indexOf(_loc2_));
         if(param1 >= 0)
         {
            this.activeCueRanges.splice(param1,1);
         }
         dispatchEvent(new CueRangeEvent(CueRangeEvent.REMOVE,_loc2_));
      }
      
      protected function stopNextEvent() : void
      {
         if(this.nextEventScheduler)
         {
            this.nextEventScheduler.stop();
            this.nextEventScheduler = null;
         }
      }
      
      public function reset() : void
      {
         this.stopPlayback();
         this.removeAllCueRanges();
         this.lastLockedCueRange = null;
      }
      
      public function get currentMediaTime() : int
      {
         return this.getPlayerState() is IEndedState ? CueRange.AFTER_MEDIA_END : int(this.getMediaTime() * 1000);
      }
      
      public function addCueRange(... rest) : void
      {
         var _loc3_:CueRange = null;
         this.sync();
         var _loc2_:int = 0;
         while(_loc2_ < rest.length)
         {
            _loc3_ = rest[_loc2_];
            _loc3_.addEventListener(CueRangeEvent.CHANGE,this.onCueRangeChanged);
            this.cueRanges.push(_loc3_);
            this.cueRangesIndex.insertInterval(_loc3_);
            dispatchEvent(new CueRangeEvent(CueRangeEvent.ADD,_loc3_));
            _loc2_++;
         }
         this.cueRangesAdded = true;
         this.sync();
      }
      
      protected function scheduleNextEvent() : void
      {
         var _loc1_:IntervalNode = this.cueRangesIndex.findAfter(this.lastMediaTime) as IntervalNode;
         if(Boolean(_loc1_) && _loc1_.value < CueRange.MEDIA_END)
         {
            this.nextEventScheduler = schedulerSetTimeout(int(_loc1_.value) - this.lastMediaTime,this.sync);
         }
      }
      
      public function onPlayerStateChange(param1:StateChangeEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:CueRange = null;
         if(!this.started || Boolean(this.lastLockedCueRange))
         {
            return;
         }
         this.stopNextEvent();
         if(param1.state is IEndedState)
         {
            this.lastLockedCueRange = null;
            _loc2_ = [];
            _loc3_ = 0;
            while(_loc3_ < this.activeCueRanges.length)
            {
               _loc5_ = this.activeCueRanges[_loc3_];
               if(_loc5_.active && _loc5_.end < CueRange.AFTER_MEDIA_END)
               {
                  _loc2_.push(_loc5_);
                  this.activeCueRanges.splice(_loc3_--,1);
               }
               _loc3_++;
            }
            _loc4_ = this.exitCueRanges(_loc2_).concat(this.enterCueRanges(this.cueRangesIndex.findIntervalsAfter(this.lastMediaTime)));
            this.handleCueRangeEvents(_loc4_);
            return;
         }
         if(param1.state is ISeekingState)
         {
            this.lastMediaTime = this.currentMediaTime;
            this.seekingScheduler.restart();
            this.sync();
         }
         else
         {
            this.seekingScheduler.stop();
            if(!(param1.oldState is ISeekingState))
            {
               this.sync();
            }
            else if(param1.state is IPlayingState)
            {
               this.scheduleNextFrame();
            }
         }
      }
      
      public function startPlayback() : void
      {
         this.lastMediaTime = this.currentMediaTime;
         this.started = true;
         this.sync();
      }
      
      protected function onCueRangeChanged(param1:CueRangeEvent) : void
      {
         dispatchEvent(new CueRangeEvent(CueRangeEvent.CHANGE,param1.cueRange));
      }
      
      public function removeAllCueRanges() : void
      {
         var _loc1_:int = int(this.cueRanges.length - 1);
         while(_loc1_ >= 0)
         {
            this.removeCueRangeAt(_loc1_);
            _loc1_--;
         }
         this.sync();
      }
      
      protected function handleCueRangeEvents(param1:Array) : void
      {
         var _loc2_:CueRangeEvent = null;
         for each(_loc2_ in param1)
         {
            if(_loc2_.type == CueRangeEvent.ENTER || _loc2_.type == CueRangeEvent.EXIT)
            {
               _loc2_.cueRange.dispatchEvent(_loc2_);
            }
            else
            {
               dispatchEvent(_loc2_);
            }
         }
      }
      
      protected function exitCueRanges(param1:Array) : Array
      {
         var _loc4_:CueRange = null;
         var _loc2_:Array = [];
         if(!param1.length)
         {
            return _loc2_;
         }
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1[_loc3_];
            _loc2_.push(new CueRangeEvent(CueRangeEvent.EXIT,_loc4_));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function removeCueRange(... rest) : void
      {
         var _loc3_:CueRange = null;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < rest.length)
         {
            _loc3_ = rest[_loc2_];
            _loc4_ = int(this.cueRanges.indexOf(_loc3_));
            if(_loc4_ >= 0)
            {
               this.removeCueRangeAt(_loc4_);
            }
            _loc2_++;
         }
         this.sync();
      }
      
      protected function enterCueRanges(param1:Array) : Array
      {
         var _loc4_:CueRange = null;
         var _loc2_:Array = [];
         if(!param1.length)
         {
            return _loc2_;
         }
         param1.sort(CueRange.compare);
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1[_loc3_];
            if(_loc4_.active && this.activeCueRanges.indexOf(_loc4_) == -1 && (!_loc4_.acquireExclusiveLock || this.allowExclusiveLock))
            {
               this.activeCueRanges.push(_loc4_);
               if(_loc4_.acquireExclusiveLock)
               {
                  if(!this.lastLockedCueRange)
                  {
                     _loc2_.push(new CueRangeEvent(CueRangeEvent.LOCK_BLOCK_ENTER,_loc4_));
                  }
                  _loc2_.push(new CueRangeEvent(CueRangeEvent.ENTER,_loc4_));
                  this.lastLockedCueRange = _loc4_;
                  break;
               }
               _loc2_.push(new CueRangeEvent(CueRangeEvent.ENTER,_loc4_));
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      protected function scheduleNextFrame() : void
      {
         var _loc1_:IntervalNode = this.cueRangesIndex.findAfter(Math.max(this.lastMediaTime - 2000,0)) as IntervalNode;
         if(Boolean(_loc1_) && _loc1_.value < CueRange.MEDIA_END)
         {
            this.nextEventScheduler = schedulerSetTimeout(0,this.sync);
         }
      }
      
      public function sync(param1:SchedulerEvent = null) : void
      {
         var syncChainLimit:int;
         var event:SchedulerEvent = param1;
         this.hasQueuedSync = true;
         if(this.isSyncing)
         {
            return;
         }
         syncChainLimit = MAX_SYNC_CHAIN;
         while(this.hasQueuedSync)
         {
            if(!syncChainLimit)
            {
               break;
            }
            this.hasQueuedSync = false;
            this.isSyncing = true;
            try
            {
               this.internalSync(event);
            }
            finally
            {
               this.isSyncing = false;
               syncChainLimit--;
            }
         }
      }
      
      public function internalSync(param1:SchedulerEvent = null) : void
      {
         var _loc4_:Array = null;
         var _loc5_:CueRange = null;
         if(!this.started || Boolean(this.lastLockedCueRange))
         {
            return;
         }
         this.stopNextEvent();
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         while(_loc3_ < this.activeCueRanges.length)
         {
            _loc5_ = this.activeCueRanges[_loc3_];
            if(_loc5_.active && !_loc5_.contains(this.currentMediaTime))
            {
               _loc2_.push(new CueRangeEvent(CueRangeEvent.EXIT,_loc5_));
               this.activeCueRanges.splice(_loc3_--,1);
            }
            _loc3_++;
         }
         if(this.lastMediaTime < this.currentMediaTime)
         {
            _loc4_ = this.cueRangesIndex.findIntervalsAfter(this.lastMediaTime,this.currentMediaTime);
            if(this.cueRangesAdded)
            {
               _loc4_ = _loc4_.concat(this.cueRangesIndex.findIntervals(this.currentMediaTime));
            }
         }
         else
         {
            _loc4_ = this.cueRangesIndex.findIntervals(this.currentMediaTime);
         }
         _loc2_ = _loc2_.concat(this.enterCueRanges(_loc4_));
         this.lastMediaTime = this.currentMediaTime;
         this.cueRangesAdded = false;
         if(this.getPlayerState() is IPlayingState)
         {
            this.scheduleNextEvent();
         }
         this.handleCueRangeEvents(_loc2_);
      }
   }
}

