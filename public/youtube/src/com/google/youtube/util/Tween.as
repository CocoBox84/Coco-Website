package com.google.youtube.util
{
   import com.google.events.SchedulerEvent;
   import com.google.utils.Scheduler;
   import com.google.youtube.event.TweenEvent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.BitmapFilter;
   
   public class Tween extends EventDispatcher
   {
      
      public static var SchedulerSource:Class = Scheduler;
      
      protected var scheduler:Scheduler;
      
      protected var duration:Number;
      
      protected var toVars:Object;
      
      protected var targetValue:Object;
      
      protected var easeFunction:Function = linear;
      
      protected var filterTargets:Array;
      
      protected var fromVars:Object;
      
      public function Tween(param1:Object = null)
      {
         super();
         this.targetValue = param1;
      }
      
      public static function easeOut(param1:Number) : Number
      {
         return easeIn(param1 - 1) + 1;
      }
      
      public static function easeIn(param1:Number) : Number
      {
         return param1 * param1 * param1;
      }
      
      public static function linear(param1:Number) : Number
      {
         return param1;
      }
      
      public function cancel() : Tween
      {
         var _loc1_:String = null;
         this.cancelScheduler();
         for(_loc1_ in this.fromVars)
         {
            this.target[_loc1_] = this.fromVars[_loc1_];
         }
         this.dispatchEvent(new TweenEvent(TweenEvent.END));
         return this;
      }
      
      public function pause() : Tween
      {
         return this.cancelScheduler();
      }
      
      public function easeOut() : Tween
      {
         return this.ease(Tween.easeOut);
      }
      
      public function fadeIn(param1:Number = 500) : Tween
      {
         var durationValue:Number = param1;
         if(this.targetValue is BitmapFilter)
         {
            addEventListener(TweenEvent.END,function(param1:TweenEvent):void
            {
               removeEventListener(TweenEvent.END,arguments.callee);
               removeFilter();
            });
            return this.to({"alpha":1},durationValue);
         }
         return this.from({"visible":true}).to({"alpha":1},durationValue);
      }
      
      protected function snapshotTargetKeys(param1:Object) : Object
      {
         var _loc3_:String = null;
         var _loc2_:Object = {};
         for(_loc3_ in param1)
         {
            _loc2_[_loc3_] = this.target[_loc3_];
         }
         return _loc2_;
      }
      
      override public function dispatchEvent(param1:Event) : Boolean
      {
         if(hasEventListener(param1.type))
         {
            return super.dispatchEvent(param1);
         }
         return false;
      }
      
      protected function update(param1:SchedulerEvent) : Tween
      {
         var _loc3_:String = null;
         var _loc4_:DisplayObject = null;
         var _loc2_:Number = this.easeFunction(Math.min(param1.elapsed / this.duration,1));
         for(_loc3_ in this.toVars)
         {
            if(!isNaN(this.toVars[_loc3_]))
            {
               this.targetValue[_loc3_] = this.fromVars[_loc3_] + (this.toVars[_loc3_] - this.fromVars[_loc3_]) * _loc2_;
            }
         }
         for each(_loc4_ in this.filterTargets)
         {
            _loc4_.filters = [this.targetValue];
         }
         this.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
         return this;
      }
      
      public function get target() : Object
      {
         return this.targetValue;
      }
      
      public function finish(param1:SchedulerEvent = null) : Tween
      {
         var _loc2_:String = null;
         this.cancelScheduler();
         for(_loc2_ in this.toVars)
         {
            this.target[_loc2_] = this.toVars[_loc2_];
         }
         this.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
         this.dispatchEvent(new TweenEvent(TweenEvent.END));
         return this;
      }
      
      protected function removeFilter() : void
      {
         var _loc1_:DisplayObject = null;
         if(this.targetValue.alpha == 0)
         {
            for each(_loc1_ in this.filterTargets)
            {
               _loc1_.filters = [];
            }
         }
      }
      
      protected function cancelScheduler() : Tween
      {
         if(this.scheduler)
         {
            this.scheduler.removeEventListener(SchedulerEvent.TICK,this.update);
            this.scheduler.removeEventListener(SchedulerEvent.END,this.finish);
            this.scheduler.stop();
            this.scheduler = null;
         }
         return this;
      }
      
      public function set target(param1:Object) : void
      {
         this.cancelScheduler();
         this.targetValue = param1;
      }
      
      public function ease(param1:Function) : Tween
      {
         this.easeFunction = param1;
         return this;
      }
      
      public function from(param1:Object) : Tween
      {
         return this.to(param1);
      }
      
      public function fadeOut(param1:Number = 500) : Tween
      {
         var durationValue:Number = param1;
         if(this.targetValue is BitmapFilter)
         {
            addEventListener(TweenEvent.END,function(param1:TweenEvent):void
            {
               removeEventListener(TweenEvent.END,arguments.callee);
               removeFilter();
            });
            return this.to({"alpha":0},durationValue);
         }
         return this.to({
            "alpha":0,
            "visible":false
         },durationValue);
      }
      
      public function easeIn() : Tween
      {
         return this.ease(Tween.easeIn);
      }
      
      public function play() : Tween
      {
         this.cancelScheduler();
         this.scheduler = new SchedulerSource(this.duration);
         this.scheduler.addEventListener(SchedulerEvent.TICK,this.update);
         this.scheduler.addEventListener(SchedulerEvent.END,this.finish);
         this.dispatchEvent(new TweenEvent(TweenEvent.START));
         return this;
      }
      
      public function filter(... rest) : Tween
      {
         this.filterTargets = rest;
         return this;
      }
      
      public function to(param1:Object, param2:Number = 0) : Tween
      {
         if(!this.targetValue)
         {
            return this;
         }
         this.toVars = param1;
         this.duration = param2;
         if(!this.duration)
         {
            this.dispatchEvent(new TweenEvent(TweenEvent.START));
            return this.finish();
         }
         this.fromVars = this.snapshotTargetKeys(param1);
         return this.play();
      }
   }
}

