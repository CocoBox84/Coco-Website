package com.google.youtube.ui
{
   import com.google.youtube.time.IInterval;
   import flash.geom.Point;
   
   public class IntervalMap extends UIElement
   {
      
      protected var dataValue:Array = [];
      
      protected var maxValue:int;
      
      public function IntervalMap()
      {
         super();
      }
      
      override protected function drawBackground() : void
      {
         drawing(background.graphics).clear().fill(16777215,0.1).rect(0,0,nominalWidth,nominalHeight).end();
      }
      
      public function set data(param1:Array) : void
      {
         this.dataValue = param1;
         this.redraw();
      }
      
      override protected function redraw() : void
      {
         var _loc3_:IInterval = null;
         var _loc4_:IntervalShape = null;
         var _loc5_:Point = null;
         background.graphics.clear();
         if(!this.maxValue)
         {
            return;
         }
         var _loc1_:int = numChildren - 1;
         while(_loc1_ >= 0)
         {
            if(getChildAt(_loc1_) is IntervalShape)
            {
               removeChildAt(_loc1_);
            }
            _loc1_--;
         }
         var _loc2_:Number = nominalWidth / this.maxValue;
         for each(_loc3_ in this.dataValue)
         {
            _loc4_ = new IntervalShape(_loc3_);
            _loc5_ = localToGlobal(new Point(Math.ceil(_loc3_.start * _loc2_),0));
            while(hitTestPoint(_loc5_.x + 1,_loc5_.y + 1,true))
            {
               _loc5_.y += nominalHeight + 1;
            }
            _loc5_ = globalToLocal(_loc5_);
            _loc4_.x = _loc5_.x;
            _loc4_.y = _loc5_.y;
            _loc4_.width = Math.floor(_loc3_.end * _loc2_ - _loc4_.x) || 1;
            _loc4_.height = nominalHeight;
            addChild(_loc4_);
         }
         this.drawBackground();
      }
      
      public function set max(param1:int) : void
      {
         if(this.maxValue != param1)
         {
            this.maxValue = param1;
            this.redraw();
         }
      }
      
      public function get data() : Array
      {
         return this.dataValue;
      }
      
      public function get max() : int
      {
         return this.maxValue;
      }
   }
}

import com.google.youtube.time.IInterval;
import flash.display.Sprite;
import flash.events.MouseEvent;

class IntervalShape extends Sprite
{
   
   public var interval:IInterval;
   
   public function IntervalShape(param1:IInterval)
   {
      super();
      this.interval = param1;
      addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
      addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      alpha = 0.5;
      drawing(graphics).stroke(0,0,0.5).fill(16777215).rect(0,0,1,1).end();
   }
   
   public function onRollOver(param1:MouseEvent) : void
   {
      alpha = 1;
   }
   
   public function onRollOut(param1:MouseEvent) : void
   {
      alpha = 0.5;
   }
}
