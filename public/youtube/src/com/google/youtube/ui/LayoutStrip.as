package com.google.youtube.ui
{
   import com.google.youtube.util.Layout;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class LayoutStrip extends UIElement
   {
      
      protected var right:Array;
      
      protected var left:Array;
      
      protected var layout:Layout;
      
      protected var sections:Object = {};
      
      public function LayoutStrip(param1:Array, param2:Array)
      {
         super();
         this.left = param1;
         this.right = param2;
         mouseEnabled = false;
         this.layout = new Layout(this);
      }
      
      protected function alignSection(param1:DisplayObjectContainer, param2:Number) : Number
      {
         if(!param1 || !param1.numChildren)
         {
            return param2;
         }
         var _loc3_:DisplayObject = param1.getChildAt(param1.numChildren - 1);
         var _loc4_:Number = _loc3_.x + _loc3_.width;
         if(param2 < 0)
         {
            param2 -= _loc4_;
            param1.x = nominalWidth + param2;
         }
         else
         {
            param1.x = param2;
            param2 += _loc4_;
         }
         param1.y = (nominalHeight - param1.height) / 2;
         return param2;
      }
      
      public function section(param1:String) : Layout
      {
         var container:Sprite = null;
         var name:String = param1;
         if(name in this.sections)
         {
            return this.sections[name];
         }
         container = new Sprite();
         container.name = name;
         container.addEventListener(Event.RESIZE,function(param1:Event):void
         {
            if(container != param1.target && container.name in sections)
            {
               sections[container.name].realign();
            }
            realign();
         });
         this.layout.add(container);
         return this.sections[name] = this.createSection(container);
      }
      
      protected function createSection(param1:DisplayObjectContainer) : Layout
      {
         return new LayoutSection(param1);
      }
      
      public function realign() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         _loc2_ = 0;
         _loc1_ = 0;
         while(_loc1_ < this.left.length)
         {
            _loc2_ = this.alignSection(DisplayObjectContainer(getChildByName(this.left[_loc1_])),_loc2_);
            _loc1_++;
         }
         _loc2_ = -Number.MIN_VALUE;
         _loc1_ = int(this.right.length - 1);
         while(_loc1_ >= 0)
         {
            _loc2_ = this.alignSection(DisplayObjectContainer(getChildByName(this.right[_loc1_])),_loc2_);
            _loc1_--;
         }
      }
      
      public function order(... rest) : void
      {
         this.layout.order.apply(this.layout,rest);
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         super.setSize(param1,param2);
         this.realign();
      }
   }
}

import com.google.youtube.util.Layout;
import flash.display.DisplayObjectContainer;
import flash.events.Event;

class LayoutSection extends Layout
{
   
   public function LayoutSection(param1:DisplayObjectContainer)
   {
      super(param1,Layout.FLOW_RIGHT);
   }
   
   override protected function alignAt(param1:int) : void
   {
      super.alignAt(param1);
      container.dispatchEvent(new Event(Event.RESIZE));
   }
}
