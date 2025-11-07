package com.google.youtube.util
{
   import com.google.youtube.ui.ILayoutElement;
   import com.google.youtube.ui.IUIElement;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Rectangle;
   import flash.utils.getQualifiedClassName;
   
   public class Layout
   {
      
      public static const ABSOLUTE:int = 0;
      
      public static const FLOW_DOWN:int = 1;
      
      public static const FLOW_RIGHT:int = 2;
      
      public static const SPECIFICITY_DEFAULT:int = 0;
      
      public static const SPECIFICITY_SUPERCLASS:int = 1;
      
      public static const SPECIFICITY_CLASS:int = 2;
      
      protected var container:DisplayObjectContainer;
      
      protected var reference:Object;
      
      protected var ordering:Array = [];
      
      protected var positioningValue:int;
      
      public function Layout(param1:DisplayObjectContainer, param2:int = 0)
      {
         super();
         this.container = param1;
         this.positioningValue = param2;
         this.alignWith(param1);
      }
      
      public function add(... rest) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < rest.length)
         {
            _loc3_ = rest[_loc2_] as DisplayObject;
            if(Boolean(_loc3_) && !this.container.contains(_loc3_))
            {
               _loc4_ = this.getDepthFor(_loc3_);
               this.container.addChildAt(_loc3_,_loc4_);
               if(this.positioningValue == ABSOLUTE)
               {
                  this.alignAt(_loc4_);
               }
            }
            _loc2_++;
         }
         if(this.positioningValue != ABSOLUTE)
         {
            this.alignAt(0);
         }
      }
      
      public function remove(... rest) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:int = 0;
         while(_loc2_ < rest.length)
         {
            _loc3_ = rest[_loc2_] as DisplayObject;
            if(Boolean(_loc3_) && this.container.contains(_loc3_))
            {
               this.container.removeChild(_loc3_);
            }
            _loc2_++;
         }
         if(this.positioningValue != ABSOLUTE)
         {
            this.alignAt(0);
         }
      }
      
      protected function alignAt(param1:int) : void
      {
         var _loc7_:DisplayObject = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:ILayoutElement = null;
         var _loc11_:IUIElement = null;
         var _loc2_:Object = this.reference is DisplayObject ? new Rectangle(0,0,this.reference.width,this.reference.height) : this.reference;
         var _loc3_:Number = Number(_loc2_.x);
         var _loc4_:Number = Number(_loc2_.y);
         var _loc5_:* = this.positioningValue == FLOW_RIGHT;
         var _loc6_:* = this.positioningValue == FLOW_DOWN;
         while(param1 < this.container.numChildren)
         {
            _loc7_ = this.container.getChildAt(param1) as DisplayObject;
            _loc8_ = 0;
            _loc9_ = 0;
            _loc10_ = _loc7_ as ILayoutElement;
            if(_loc10_)
            {
               _loc8_ = Number(_loc10_.horizontalMargin || 0);
               _loc9_ = Number(_loc10_.verticalMargin || 0);
            }
            if(_loc5_)
            {
               _loc7_.x = _loc3_ + _loc8_;
               _loc3_ = _loc7_.x + _loc7_.width;
            }
            else if(_loc6_)
            {
               _loc7_.y = _loc4_ + _loc9_;
               _loc4_ = _loc7_.y + _loc7_.height;
            }
            if(_loc10_)
            {
               if(!_loc5_)
               {
                  if(!isNaN(_loc10_.horizontalRegistration))
                  {
                     _loc7_.x = _loc3_ + _loc2_.width * _loc10_.horizontalRegistration + _loc8_;
                  }
                  if(!isNaN(_loc10_.horizontalStretch))
                  {
                     _loc7_.width = _loc2_.width * _loc10_.horizontalStretch;
                  }
               }
               if(!_loc6_)
               {
                  if(!isNaN(_loc10_.verticalRegistration))
                  {
                     _loc7_.y = _loc4_ + _loc2_.height * _loc10_.verticalRegistration + _loc9_;
                  }
                  if(!isNaN(_loc10_.verticalStretch))
                  {
                     _loc7_.height = _loc2_.height * _loc10_.verticalStretch;
                  }
               }
            }
            _loc11_ = _loc7_ as IUIElement;
            if((Boolean(_loc11_)) && _loc11_.tabOrderPriority != -1)
            {
               _loc11_.tabOrderPriority = param1;
            }
            if(this.positioningValue == ABSOLUTE)
            {
               break;
            }
            param1++;
         }
      }
      
      public function realign(param1:DisplayObject = null) : void
      {
         var _loc2_:int = 0;
         if(this.positioningValue != ABSOLUTE)
         {
            this.alignAt(0);
            return;
         }
         if(param1)
         {
            this.alignAt(this.container.getChildIndex(param1));
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < this.container.numChildren)
            {
               this.alignAt(_loc2_);
               _loc2_++;
            }
         }
      }
      
      public function order(... rest) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         loop0:
         while(rest.length)
         {
            _loc5_ = [];
            _loc6_ = int.MAX_VALUE;
            while(true)
            {
               _loc4_ = rest.shift();
               if(_loc4_)
               {
                  _loc5_.push(_loc4_);
                  _loc6_ = this.getOrderingFor(_loc4_);
                  if(_loc6_ < _loc3_)
                  {
                     break;
                  }
               }
               if(!(Boolean(rest.length) && _loc6_ == int.MAX_VALUE))
               {
                  while(_loc3_ < _loc6_ && _loc3_ < this.ordering.length)
                  {
                     _loc2_.push(this.ordering[_loc3_]);
                     _loc3_++;
                  }
                  _loc2_ = _loc2_.concat(_loc5_);
                  if(_loc3_ == _loc6_)
                  {
                     _loc3_++;
                  }
                  continue loop0;
               }
            }
            throw ArgumentError("Impossible ordering specified.");
         }
         if(_loc3_ < this.ordering.length)
         {
            _loc2_ = _loc2_.concat(this.ordering.slice(_loc3_));
         }
         this.ordering = _loc2_;
      }
      
      public function set positioning(param1:int) : void
      {
         this.positioningValue = param1;
         this.realign();
      }
      
      public function get positioning() : int
      {
         return this.positioningValue;
      }
      
      public function alignWith(param1:Object) : void
      {
         this.reference = param1;
         this.realign();
      }
      
      protected function getDepthFor(param1:Object) : int
      {
         var _loc2_:int = this.container.numChildren;
         var _loc3_:int = this.getOrderingFor(param1);
         if(this.container.numChildren > 0 && _loc3_ != int.MAX_VALUE)
         {
            _loc2_ = 0;
            while(_loc2_ < this.container.numChildren && _loc3_ > this.getOrderingFor(this.container.getChildAt(_loc2_)))
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      protected function getOrderingFor(param1:Object, param2:int = 0) : int
      {
         var _loc6_:Object = null;
         var _loc3_:int = int.MAX_VALUE;
         var _loc4_:int = SPECIFICITY_DEFAULT;
         var _loc5_:int = param2;
         for(; _loc5_ < this.ordering.length; _loc5_++)
         {
            _loc6_ = this.ordering[_loc5_];
            if(_loc6_ == param1 || _loc6_ is String && param1 is DisplayObject && param1.name == _loc6_)
            {
               return _loc5_;
            }
            if(_loc4_ < SPECIFICITY_CLASS)
            {
               if(_loc6_ == param1.constructor || _loc6_ is String && _loc6_ == getQualifiedClassName(param1))
               {
                  this.ordering[_loc5_] = param1.constructor;
                  _loc4_ = SPECIFICITY_CLASS;
                  _loc3_ = _loc5_;
                  continue;
               }
            }
            if(_loc4_ < SPECIFICITY_SUPERCLASS)
            {
               if(_loc6_ is Class && param1 is Class(_loc6_))
               {
                  _loc4_ = SPECIFICITY_SUPERCLASS;
                  _loc3_ = _loc5_;
               }
            }
         }
         return _loc3_;
      }
   }
}

