package com.google.youtube.ui
{
   import com.google.events.SchedulerEvent;
   import com.google.youtube.util.StageAmbassador;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class Preloader extends AnimatedElement
   {
      
      private var snake:Array = [];
      
      public var enabled:Boolean = true;
      
      private var dir:Number;
      
      protected var stageAmbassador:StageAmbassador;
      
      private var queue:Array = [];
      
      protected var spinner:MovieClip = new PreloaderAsset();
      
      public function Preloader(param1:StageAmbassador)
      {
         super(null,36);
         this.stageAmbassador = param1;
         addChild(this.spinner);
         this.spinner.scaleX = 2;
         this.spinner.scaleY = 2;
         horizontalRegistration = 0.5;
         verticalRegistration = 0.5;
         mouseEnabled = false;
      }
      
      override protected function onAddedToStage(param1:Event) : void
      {
         super.onAddedToStage(param1);
         this.stageAmbassador.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false,100);
      }
      
      private function collide(param1:int, param2:int) : DisplayObject
      {
         var _loc4_:Array = null;
         var _loc5_:DisplayObject = null;
         var _loc3_:Rectangle = parent.getBounds(this);
         _loc3_.bottom = -_loc3_.top;
         _loc3_.inflate(-4,-4);
         if(_loc3_.contains(param1,param2))
         {
            _loc4_ = getObjectsUnderPoint(localToGlobal(new Point(param1,param2)));
            for each(_loc5_ in _loc4_)
            {
               while(_loc5_)
               {
                  if(_loc5_ is DotAsset)
                  {
                     return _loc5_;
                  }
                  _loc5_ = _loc5_.parent;
               }
            }
            return null;
         }
         return this;
      }
      
      public function get interactive() : Boolean
      {
         return !contains(this.spinner);
      }
      
      private function onDie(param1:SchedulerEvent) : void
      {
         var _loc2_:int = int(this.snake[0].currentFrame);
         if(_loc2_ < 10)
         {
            visible = _loc2_ % 2 == 1;
         }
         else
         {
            this.reset();
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      override protected function onRemovedFromStage(param1:Event) : void
      {
         super.onRemovedFromStage(param1);
         this.stageAmbassador.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         this.reset();
      }
      
      private function grow(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:MovieClip = new DotAsset();
         _loc4_.addFrameScript(10,_loc4_.stop);
         _loc4_.scaleX = 2;
         _loc4_.scaleY = 2;
         _loc4_.x = param1;
         _loc4_.y = param2;
         this.snake.unshift(addChild(_loc4_));
         if(param3)
         {
            this.snake.push(null,null,null,null,null,null,null);
            do
            {
               param1 = int(parent.width * (Math.random() - 0.5)) & 0xFFFFFFF8;
               param2 = int(parent.height * (Math.random() - 0.5)) & 0xFFFFFFF8;
            }
            while(this.collide(param1,param2));
            
            _loc4_ = new DotAsset();
            _loc4_.rotation = 1;
            _loc4_.scaleX = 2;
            _loc4_.scaleY = 2;
            _loc4_.x = param1;
            _loc4_.y = param2;
            addChild(_loc4_);
         }
      }
      
      private function reset() : void
      {
         this.dir = NaN;
         this.queue = [];
         this.snake = [];
         if(!contains(this.spinner))
         {
            while(numChildren)
            {
               removeChildAt(numChildren - 1);
            }
            addChild(this.spinner);
         }
         pacemaker.removeEventListener(SchedulerEvent.TICK,this.onTick);
         pacemaker.removeEventListener(SchedulerEvent.TICK,this.onDie);
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = param1.keyCode - 37;
         if(!this.enabled || Boolean(_loc2_ >> 2))
         {
            return;
         }
         if(contains(this.spinner))
         {
            if(_loc2_ == 0 || _loc2_ == 2)
            {
               return;
            }
            removeChild(this.spinner);
            _loc3_ = this.spinner.currentFrame;
            _loc4_ = _loc3_ <= 6 || _loc3_ >= 22 ? -8 : (_loc3_ >= 10 && _loc3_ <= 18 ? 8 : 0);
            _loc5_ = _loc3_ >= 4 && _loc3_ <= 12 ? -8 : (_loc3_ >= 16 ? 8 : 0);
            _loc2_ = _loc3_ >= 19 ? 0 : (_loc3_ >= 13 ? 3 : (_loc3_ >= 7 ? 2 : 1));
            this.grow(_loc4_,_loc5_,true);
            pacemaker.addEventListener(SchedulerEvent.TICK,this.onTick);
         }
         if(_loc2_ % 2 != (this.queue.length ? this.queue[0] : this.dir) % 2)
         {
            this.queue.unshift(_loc2_);
         }
         param1.stopImmediatePropagation();
      }
      
      private function onTick(param1:SchedulerEvent) : void
      {
         if(this.queue.length)
         {
            this.dir = this.queue.pop();
         }
         var _loc2_:int = this.snake[0].x + [-8,0,8,0][this.dir];
         var _loc3_:int = this.snake[0].y + [0,-8,0,8][this.dir];
         var _loc4_:DisplayObject = this.collide(_loc2_,_loc3_);
         if(_loc4_)
         {
            if(_loc4_ is DotAsset && Boolean(_loc4_.rotation))
            {
               removeChild(_loc4_);
               this.grow(_loc2_,_loc3_,true);
            }
            else
            {
               pacemaker.removeEventListener(SchedulerEvent.TICK,this.onTick);
               pacemaker.addEventListener(SchedulerEvent.TICK,this.onDie);
            }
            return;
         }
         this.grow(_loc2_,_loc3_,false);
         var _loc5_:DisplayObject = this.snake.pop();
         if(_loc5_)
         {
            removeChild(_loc5_);
         }
      }
   }
}

