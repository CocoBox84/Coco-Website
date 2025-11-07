package com.google.youtube.util.hls
{
   import com.google.utils.Scheduler;
   import com.google.youtube.event.CuePointEvent;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   
   public class HlsPlaylist extends EventDispatcher
   {
      
      protected static const SCHEDULER:Object = Scheduler;
      
      public static var liveChunkReadahead:uint = 4;
      
      public static var maxLiveSecondsReadahead:Number = Infinity;
      
      public static var monitorLiveChunkReadahead:uint = 2;
      
      public static var monitorMaxLiveSecondsReadahead:Number = 20;
      
      protected static const RELOAD_OVERLAP:int = 128;
      
      protected static const MAX_CONSECUTIVE_FAILURES:uint = 4;
      
      protected var lastLoadTime:Number;
      
      public var byteLength:uint;
      
      public var chunkDiscontinuity:Array = [];
      
      protected var loader:HlsPlaylistLoader;
      
      protected var reloadMoratorium:Scheduler;
      
      protected var delayedReload:Boolean;
      
      protected var loadStart:Number;
      
      public var firstChunk:uint;
      
      public var dvr:Boolean;
      
      public var chunkDuration:Array = [];
      
      public var chunkUrl:Array = [];
      
      public var targetDuration:uint;
      
      public var siblingPlaylists:Array = [];
      
      public var vod:Boolean;
      
      public var chunkCuePointParams:Array = [];
      
      protected var unchangedRetries:uint;
      
      protected var isLiveMonitor:Boolean;
      
      public var chunkKeyUrl:Array = [];
      
      protected var failedRetries:uint;
      
      public var chunkStartTime:Array = [];
      
      public var live:Boolean;
      
      public var url:String;
      
      protected var loadInProgress:Boolean;
      
      public var chunkIv:Array = [];
      
      public function HlsPlaylist(param1:String, param2:HlsPlaylistLoader, param3:Boolean = false)
      {
         super();
         this.url = param1;
         this.loader = param2;
         this.isLiveMonitor = param3;
         if(param2)
         {
            param2.addEventListener(Event.COMPLETE,this.onComplete);
            param2.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onError);
            param2.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
            param2.addEventListener(ErrorEvent.ERROR,this.onError);
         }
      }
      
      public function get minPeggedToLiveTime() : Number
      {
         var _loc1_:Number = this.isLiveMonitor ? monitorMaxLiveSecondsReadahead : maxLiveSecondsReadahead;
         return this.duration - _loc1_;
      }
      
      public function getCuePoint(param1:uint) : CuePointEvent
      {
         var _loc2_:Object = this.chunkCuePointParams[param1];
         if(!_loc2_)
         {
            return null;
         }
         var _loc3_:Number = this.chunkStartTime[param1] / 1000;
         var _loc4_:Number = parseFloat(_loc2_.TIME_OFFSET);
         if(_loc4_)
         {
            _loc3_ += _loc4_;
         }
         return new CuePointEvent(CuePointEvent.CUE_POINT,"ADSTART",_loc3_,_loc2_);
      }
      
      protected function startMoratorium(param1:Boolean) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         if(!this.vod)
         {
            this.unchangedRetries = param1 ? 0 : uint(this.unchangedRetries + 1);
            _loc2_ = this.targetDuration ? this.targetDuration : 5000;
            switch(this.unchangedRetries)
            {
               case 0:
                  _loc3_ = uint(this.chunkDuration[this.chunkDuration.length - 1]);
                  break;
               case 1:
                  _loc3_ = 0.5 * _loc2_;
                  break;
               case 2:
                  _loc3_ = 1.5 * _loc2_;
                  break;
               default:
                  _loc3_ = 3 * _loc2_;
            }
            _loc3_ = Math.max(0,_loc3_ - (Scheduler.clock() - this.loadStart));
            if(_loc3_)
            {
               this.reloadMoratorium = SCHEDULER.setTimeout(_loc3_,this.maybeReload);
            }
         }
      }
      
      public function get duration() : Number
      {
         if(!this.chunkStartTime.length)
         {
            return 0;
         }
         return (this.chunkStartTime[this.chunkStartTime.length - 1] + this.chunkDuration[this.chunkStartTime.length - 1]) / 1000;
      }
      
      protected function maybeReload(param1:Event) : void
      {
         this.reloadMoratorium = null;
         if(this.delayedReload)
         {
            this.delayedReload = false;
            this.load();
         }
      }
      
      protected function redispatchIfListening(param1:Event) : void
      {
         if(hasEventListener(param1.type))
         {
            dispatchEvent(param1);
         }
      }
      
      protected function onComplete(param1:Event) : void
      {
         this.failedRetries = 0;
         this.loadInProgress = false;
         var _loc2_:uint = this.firstChunk;
         var _loc3_:uint = this.chunkUrl.length;
         this.loader.copyResult(this);
         this.lastLoadTime = Scheduler.clock();
         this.startMoratorium(_loc3_ != this.chunkUrl.length || _loc2_ != this.firstChunk || this.vod);
         this.redispatchIfListening(param1);
      }
      
      public function get liveChunkTime() : Number
      {
         if(this.vod)
         {
            return this.duration;
         }
         var _loc1_:uint = !this.lastLoadTime ? 0 : uint(Scheduler.clock() - this.lastLoadTime);
         return this.liveChunk in this.chunkStartTime ? (this.chunkStartTime[this.liveChunk] + _loc1_) / 1000 : 0;
      }
      
      public function load() : void
      {
         if(!this.vod && !this.loadInProgress)
         {
            if(this.reloadMoratorium)
            {
               this.delayedReload = true;
            }
            else
            {
               this.loadStart = Scheduler.clock();
               this.loadInProgress = true;
               this.loader.load(this.siblingPlaylists);
            }
         }
      }
      
      public function get liveChunk() : uint
      {
         var _loc1_:uint = this.isLiveMonitor ? monitorLiveChunkReadahead : liveChunkReadahead;
         return Math.max(this.firstChunk,this.chunkUrl.length - _loc1_);
      }
      
      protected function onError(param1:Event) : void
      {
         this.loadInProgress = false;
         this.startMoratorium(false);
         if(++this.failedRetries >= MAX_CONSECUTIVE_FAILURES)
         {
            this.redispatchIfListening(param1);
         }
         else
         {
            this.load();
         }
      }
   }
}

