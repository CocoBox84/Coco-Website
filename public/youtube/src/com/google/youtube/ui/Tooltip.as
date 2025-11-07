package com.google.youtube.ui
{
   import com.google.utils.Scheduler;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class Tooltip extends Button
   {
      
      public static var reference:DisplayObjectContainer;
      
      public static var lastTooltip:Tooltip;
      
      public static var resetTimeout:Scheduler;
      
      public static const CORNER_RADIUS:Number = 0;
      
      public static const STAGE_PADDING:Number = 2;
      
      public static const TIP_SIZE:Number = 5;
      
      protected static const BOTTOM:String = "BOTTOM";
      
      protected static const TOP:String = "TOP";
      
      public static const DELAY:Number = 500;
      
      public static const RESET_DELAY:Number = 2000;
      
      public var hasDelay:Boolean;
      
      protected var orientation:String = "BOTTOM";
      
      protected var target:DisplayObject;
      
      protected var offset:Point;
      
      protected var delayTimeout:Scheduler;
      
      public function Tooltip(param1:Boolean = true)
      {
         super();
         enabled = false;
         mouseEnabled = false;
         this.hasDelay = param1;
         if(param1)
         {
            this.delayTimeout = Scheduler.setTimeout(DELAY,this.onDelayTimeout);
            this.delayTimeout.stop();
         }
         if(!resetTimeout)
         {
            resetTimeout = Scheduler.setTimeout(RESET_DELAY,onResetDelayTimeout);
            resetTimeout.stop();
         }
         tabEnabled = false;
         isAccessible = false;
      }
      
      public static function onResetDelayTimeout(param1:Event) : void
      {
         lastTooltip = null;
      }
      
      public function setContents(param1:*) : void
      {
         if(labels["default"] == param1)
         {
            return;
         }
         labelValue = null;
         labels["default"] = param1;
         setLabel("default");
         this.alignTooltip();
      }
      
      override protected function onAddedToStage(param1:Event) : void
      {
         super.onAddedToStage(param1);
         resetTimeout.stop();
         if(Boolean(lastTooltip) && lastTooltip != this)
         {
            lastTooltip.visible = false;
         }
         else if(this.hasDelay)
         {
            visible = false;
            this.delayTimeout.restart();
         }
         if(this.hasDelay)
         {
            lastTooltip = this;
         }
         this.alignTooltip();
      }
      
      protected function alignTooltip() : void
      {
         var _loc2_:Point = null;
         var _loc3_:Point = null;
         var _loc1_:Rectangle = getBounds(parent);
         if(parent)
         {
            if(!this.target)
            {
               this.target = parent;
            }
            if(this.offset)
            {
               _loc2_ = this.target.localToGlobal(this.offset);
            }
            else
            {
               _loc2_ = this.target.localToGlobal(new Point(this.target.width / 2,0));
               if(_loc2_.y < _loc1_.height)
               {
                  _loc2_ = this.target.localToGlobal(new Point(this.target.width / 2,this.target.height + TIP_SIZE));
                  this.orientation = TOP;
               }
               else
               {
                  this.orientation = BOTTOM;
               }
            }
            _loc3_ = parent.globalToLocal(_loc2_);
            x = int(_loc3_.x - _loc1_.width / 2);
            y = this.orientation == TOP ? int(_loc3_.y) : int(_loc3_.y - _loc1_.height);
            redraw();
         }
      }
      
      override protected function drawForeground() : void
      {
      }
      
      public function alignWith(param1:DisplayObject, param2:Point = null) : void
      {
         this.target = param1;
         this.offset = param2;
         this.alignTooltip();
      }
      
      override protected function onRemovedFromStage(param1:Event) : void
      {
         if(this.hasDelay)
         {
            this.delayTimeout.stop();
         }
         if(!visible && lastTooltip == this)
         {
            lastTooltip = null;
         }
         else
         {
            resetTimeout.restart();
         }
      }
      
      override protected function drawBackground() : void
      {
         if(!contents)
         {
            return;
         }
         var _loc1_:Rectangle = contents.getBounds(this);
         var _loc2_:Number = int(_loc1_.y);
         var _loc3_:Number = int(_loc1_.x);
         var _loc4_:Number = _loc3_ + Math.ceil(_loc1_.width);
         var _loc5_:Number = _loc2_ + Math.ceil(_loc1_.height);
         var _loc6_:Number = Math.ceil((_loc4_ - _loc3_) / 2);
         var _loc7_:Graphics = background.graphics;
         _loc7_.clear();
         _loc7_.beginFill(Theme.getConstant("TOOLTIP_COLOR"),Theme.getConstant("TOOLTIP_ALPHA"));
         _loc7_.moveTo(_loc3_ + CORNER_RADIUS,_loc2_);
         if(this.orientation == TOP)
         {
            if(_loc6_ - TIP_SIZE < _loc3_ + CORNER_RADIUS)
            {
               _loc7_.lineTo(_loc3_ + CORNER_RADIUS + TIP_SIZE,_loc2_);
               _loc7_.lineTo(_loc3_ + CORNER_RADIUS,_loc2_ - TIP_SIZE);
               _loc7_.lineTo(_loc3_ + CORNER_RADIUS,_loc2_);
            }
            else if(_loc6_ + TIP_SIZE > _loc4_ - CORNER_RADIUS)
            {
               _loc7_.lineTo(_loc4_ - CORNER_RADIUS,_loc2_);
               _loc7_.lineTo(_loc4_ - CORNER_RADIUS,_loc2_ - TIP_SIZE);
               _loc7_.lineTo(_loc4_ - CORNER_RADIUS - TIP_SIZE,_loc2_);
            }
            else
            {
               _loc7_.lineTo(_loc6_ - TIP_SIZE,_loc2_);
               _loc7_.lineTo(_loc6_,_loc2_ - TIP_SIZE);
               _loc7_.lineTo(_loc6_ + TIP_SIZE,_loc2_);
            }
         }
         _loc7_.lineTo(_loc4_ - CORNER_RADIUS,_loc2_);
         _loc7_.curveTo(_loc4_,_loc2_,_loc4_,_loc2_ + CORNER_RADIUS);
         _loc7_.lineTo(_loc4_,_loc5_ - CORNER_RADIUS);
         _loc7_.curveTo(_loc4_,_loc5_,_loc4_ - CORNER_RADIUS,_loc5_);
         if(this.orientation == BOTTOM)
         {
            if(_loc6_ + TIP_SIZE > _loc4_ - CORNER_RADIUS)
            {
               _loc7_.lineTo(_loc4_ - CORNER_RADIUS,_loc5_);
               _loc7_.lineTo(_loc4_ - CORNER_RADIUS,_loc5_ + TIP_SIZE);
               _loc7_.lineTo(_loc4_ - CORNER_RADIUS - TIP_SIZE,_loc5_);
            }
            else if(_loc6_ - TIP_SIZE < _loc3_ + CORNER_RADIUS)
            {
               _loc7_.lineTo(_loc3_ + CORNER_RADIUS + TIP_SIZE,_loc5_);
               _loc7_.lineTo(_loc3_ + CORNER_RADIUS,_loc5_ + TIP_SIZE);
               _loc7_.lineTo(_loc3_ + CORNER_RADIUS,_loc5_);
            }
            else
            {
               _loc7_.lineTo(_loc6_ + TIP_SIZE,_loc5_);
               _loc7_.lineTo(_loc6_,_loc5_ + TIP_SIZE);
               _loc7_.lineTo(_loc6_ - TIP_SIZE,_loc5_);
            }
         }
         _loc7_.lineTo(_loc3_ + CORNER_RADIUS,_loc5_);
         _loc7_.curveTo(_loc3_,_loc5_,_loc3_,_loc5_ - CORNER_RADIUS);
         _loc7_.lineTo(_loc3_,_loc2_ + CORNER_RADIUS);
         _loc7_.curveTo(_loc3_,_loc2_,_loc3_ + CORNER_RADIUS,_loc2_);
         _loc7_.endFill();
      }
      
      private function onDelayTimeout(param1:Event) : void
      {
         if(lastTooltip == this && !visible)
         {
            visible = true;
         }
      }
      
      override protected function alignContents() : void
      {
         contents.x = 0;
         contents.y = 0;
         var _loc1_:Rectangle = contents.getBounds(reference);
         if(_loc1_.right > reference.width - STAGE_PADDING)
         {
            contents.x = reference.width - STAGE_PADDING - _loc1_.right;
         }
         else if(_loc1_.left < STAGE_PADDING)
         {
            contents.x = STAGE_PADDING - _loc1_.left;
         }
         if(_loc1_.bottom > reference.height - STAGE_PADDING)
         {
            contents.y = reference.height - STAGE_PADDING - _loc1_.bottom;
         }
         else if(_loc1_.top < STAGE_PADDING)
         {
            contents.y = STAGE_PADDING - _loc1_.top;
         }
      }
   }
}

