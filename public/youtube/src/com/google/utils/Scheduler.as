package com.google.utils
{
   import com.google.events.SchedulerEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getTimer;
   
   public class Scheduler extends EventDispatcher
   {
      
      protected static var ticker:Sprite;
      
      protected static var head:Scheduler;
      
      protected static var current:Scheduler;
      
      protected static var stage:Object;
      
      public static var clock:Function = getTimer;
      
      protected static const TIMEOUT:int = 1000;
      
      protected static const CANONICAL_END_EVENT:SchedulerEvent = new SchedulerEvent(SchedulerEvent.END,0);
      
      protected static const CANONICAL_TICK_EVENT:SchedulerEvent = new SchedulerEvent(SchedulerEvent.TICK,0);
      
      protected static const MAX_FPS:Number = 24;
      
      protected static const MIN_FPS:Number = 4;
      
      protected static var blank:Scheduler = new Scheduler();
      
      protected static var clockHandler:Function = run;
      
      protected static var lastExecuted:Number = 0;
      
      protected var interval:Number = 0;
      
      protected var lastTick:Number = -1;
      
      protected var timeout:Number = Infinity;
      
      protected var start:Number;
      
      protected var elapsedTimeAtPause:Number = 0;
      
      protected var endHandler:Function;
      
      protected var next:Scheduler;
      
      protected var previous:Scheduler;
      
      protected var lastVisited:Number = -1;
      
      protected var tickHandler:Function = this.noop;
      
      public function Scheduler(param1:Number = Infinity, param2:Number = 0)
      {
         this.endHandler = this.noop;
         super();
         if(!ticker && Boolean(blank))
         {
            ticker = new Sprite();
            resetClockHandler(clockHandler);
         }
         this.timeout = param1;
         this.interval = param2;
         if(blank)
         {
            this.restart();
         }
      }
      
      public static function setInterval(param1:Number, param2:Function) : Scheduler
      {
         var _loc3_:Scheduler = new Scheduler(Infinity,param1);
         _loc3_.addEventListener(SchedulerEvent.TICK,param2);
         return _loc3_;
      }
      
      public static function resetClockHandler(param1:Function = null) : void
      {
         param1 ||= run;
         if(ticker)
         {
            ticker.removeEventListener(Event.ENTER_FRAME,clockHandler);
            ticker.addEventListener(Event.ENTER_FRAME,param1,false,0,true);
         }
         clockHandler = param1;
      }
      
      protected static function run(param1:Event = null) : void
      {
         var minInterval:Number;
         var schedule:Scheduler = null;
         var elapsed:Number = NaN;
         var frameRate:Number = NaN;
         var event:Event = param1;
         var t:Number = clock();
         var timeElapsed:Number = t - lastExecuted;
         lastExecuted = t;
         if(timeElapsed >= TIMEOUT || Boolean(current))
         {
            return;
         }
         current = head;
         minInterval = Infinity;
         while(Boolean(current) && current.lastVisited < t)
         {
            schedule = current;
            schedule.lastVisited = t;
            elapsed = t - schedule.start;
            if(schedule.isTickable(t))
            {
               CANONICAL_TICK_EVENT.elapsed = elapsed;
               schedule.lastTick = t;
               schedule.dispatchEvent(CANONICAL_TICK_EVENT);
            }
            if(elapsed >= schedule.timeout)
            {
               CANONICAL_END_EVENT.elapsed = elapsed;
               schedule.stop();
               schedule.dispatchEvent(CANONICAL_END_EVENT);
            }
            else
            {
               minInterval = Math.min(minInterval,schedule.interval);
            }
            current = current.next;
         }
         current = null;
         blank.next = null;
         if(stage)
         {
            minInterval = Math.max(minInterval,1);
            frameRate = Math.max(MIN_FPS,Math.min(1000 / minInterval,MAX_FPS));
            try
            {
               if(stage.frameRate != frameRate)
               {
                  stage.frameRate = frameRate;
               }
            }
            catch(error:SecurityError)
            {
               stage = null;
            }
         }
      }
      
      public static function composeClockHandler(param1:Function) : void
      {
         var f:Function = param1;
         var handler:Function = function(... rest):void
         {
            rest.unshift(run);
            f.apply(null,rest);
         };
         resetClockHandler(handler);
      }
      
      public static function setTimeout(param1:Number, param2:Function) : Scheduler
      {
         var _loc3_:Scheduler = new Scheduler(param1,Infinity);
         _loc3_.addEventListener(SchedulerEvent.END,param2);
         return _loc3_;
      }
      
      public static function setFrameRateOf(param1:Object) : void
      {
         Scheduler.stage = param1;
      }
      
      override public function dispatchEvent(param1:Event) : Boolean
      {
         switch(param1.type)
         {
            case SchedulerEvent.END:
               this.endHandler(param1);
               break;
            case SchedulerEvent.TICK:
               this.tickHandler(param1);
               break;
            default:
               super.dispatchEvent(param1);
         }
         return true;
      }
      
      public function isTickable(param1:Number) : Boolean
      {
         return param1 - this.lastTick >= this.interval;
      }
      
      public function stop() : void
      {
         if(current == this || current == blank && blank.next == this)
         {
            blank.next = this.next;
            current = blank;
         }
         if(this.previous)
         {
            this.previous.next = this.next;
         }
         if(this.next)
         {
            this.next.previous = this.previous;
         }
         if(head == this)
         {
            head = this.next;
         }
         this.next = this.previous = null;
         this.elapsedTimeAtPause = 0;
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         switch(param1)
         {
            case SchedulerEvent.END:
               this.endHandler = this.endHandler == this.noop ? param2 : super.dispatchEvent;
               break;
            case SchedulerEvent.TICK:
               this.tickHandler = this.tickHandler == this.noop ? param2 : super.dispatchEvent;
         }
         super.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function restart() : void
      {
         this.elapsedTimeAtPause = 0;
         this.start = clock();
         this.lastTick = this.start;
         if(!this.previous && !this.next)
         {
            if(Boolean(head) && head != this)
            {
               head.previous = this;
               this.next = head;
            }
            head = this;
         }
      }
      
      override public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this.endHandler = param1 == SchedulerEvent.END && this.endHandler == param2 ? this.noop : this.endHandler;
         this.tickHandler = param1 == SchedulerEvent.TICK && this.tickHandler == param2 ? this.noop : this.tickHandler;
         super.removeEventListener(param1,param2,param3);
      }
      
      protected function noop(param1:Event) : void
      {
      }
      
      public function resume() : void
      {
         var _loc1_:Number = NaN;
         if(!this.isRunning())
         {
            _loc1_ = this.elapsedTimeAtPause;
            this.restart();
            this.start -= _loc1_;
         }
      }
      
      public function isRunning() : Boolean
      {
         return Boolean(this.next) || Boolean(this.previous) || head == this;
      }
      
      public function pause() : void
      {
         if(this.isRunning())
         {
            this.stop();
            this.elapsedTimeAtPause = clock() - this.start;
         }
      }
   }
}

