package com.google.youtube.ui
{
   import com.google.youtube.util.Layout;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.FrameLabel;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class Button extends UIElement
   {
      
      public var backgrounds:Object = {};
      
      protected var contents:DisplayObject;
      
      protected var elementContainer:Sprite = new Sprite();
      
      protected var elementCache:Object = {};
      
      protected var layout:Layout;
      
      protected var labelsValue:Object = {};
      
      public function Button(param1:* = null)
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         tabChildren = false;
         this.elementContainer.mouseEnabled = false;
         this.elementContainer.tabEnabled = false;
         addChild(this.elementContainer);
         this.layout = new Layout(this.elementContainer,Layout.FLOW_RIGHT);
         if(param1)
         {
            this.labels["default"] = param1;
            setLabel("default");
         }
         addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
      }
      
      protected function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.target == this && (param1.keyCode == 13 || param1.keyCode == 32))
         {
            stageAmbassador.focus = this;
         }
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         var _loc3_:* = undefined;
         var _loc4_:DisplayObject = null;
         super.setSize(param1,param2);
         for each(_loc3_ in this.backgrounds)
         {
            _loc4_ = _loc3_ as DisplayObject;
            if((Boolean(_loc4_)) && background.contains(_loc4_))
            {
               _loc4_.width = nominalWidth;
               _loc4_.height = nominalHeight;
            }
         }
      }
      
      protected function getStateKey(param1:Object) : String
      {
         if(!param1)
         {
            return null;
         }
         if(enabled)
         {
            return stateValue is IMouseDownState && "down" in param1 ? "down" : (stateValue is IRollOverState && "over" in param1 ? "over" : "up");
         }
         return "disabled" in param1 ? "disabled" : "up";
      }
      
      protected function getElement(param1:*) : DisplayObject
      {
         var _loc2_:DisplayObject = null;
         if(param1 is DisplayObject)
         {
            _loc2_ = param1;
         }
         else if(param1 is Class)
         {
            _loc2_ = new param1();
         }
         else
         {
            _loc2_ = this.createText();
         }
         if(_loc2_ is InteractiveObject)
         {
            InteractiveObject(_loc2_).mouseEnabled = false;
            InteractiveObject(_loc2_).tabEnabled = false;
         }
         if(_loc2_ is DisplayObjectContainer)
         {
            DisplayObjectContainer(_loc2_).mouseChildren = false;
         }
         return _loc2_;
      }
      
      protected function forState(param1:Object) : *
      {
         var _loc2_:String = this.getStateKey(param1);
         if(Boolean(_loc2_) && _loc2_ in param1)
         {
            return param1[_loc2_];
         }
         return null;
      }
      
      protected function createText() : DisplayObject
      {
         var _loc1_:TextField = new TextField();
         _loc1_.autoSize = TextFieldAutoSize.CENTER;
         _loc1_.selectable = false;
         _loc1_.width = nominalWidth;
         return _loc1_;
      }
      
      public function get labels() : Object
      {
         return this.labelsValue;
      }
      
      override protected function drawBackground() : void
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         var _loc4_:DisplayObject = null;
         var _loc1_:* = this.forState(this.backgrounds);
         for(_loc2_ in this.backgrounds)
         {
            _loc3_ = this.backgrounds[_loc2_];
            _loc4_ = _loc3_ as DisplayObject;
            if(!_loc4_ || !background.contains(_loc4_))
            {
               _loc4_ ||= new _loc3_();
               _loc4_.width = nominalWidth;
               _loc4_.height = nominalHeight;
               if(_loc4_ is InteractiveObject)
               {
                  InteractiveObject(_loc4_).mouseEnabled = false;
                  InteractiveObject(_loc4_).tabEnabled = false;
               }
               this.backgrounds[_loc2_] = _loc4_;
               background.addChild(_loc4_);
            }
            if(_loc3_ == _loc1_)
            {
               if(_loc4_ is MovieClip)
               {
                  this.gotoState(MovieClip(_loc4_));
               }
               _loc4_.visible = true;
            }
            else
            {
               _loc4_.visible = false;
            }
         }
      }
      
      override protected function onStateChanged() : void
      {
         super.onStateChanged();
         this.redraw();
      }
      
      protected function gotoState(param1:MovieClip) : void
      {
         var _loc3_:FrameLabel = null;
         var _loc4_:String = null;
         var _loc2_:Object = {};
         for each(_loc3_ in param1.currentLabels)
         {
            _loc2_[_loc3_.name] = _loc3_.name;
         }
         _loc4_ = this.forState(_loc2_);
         if(_loc4_)
         {
            param1.gotoAndStop(_loc4_);
         }
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         useHandCursor = param1;
      }
      
      override protected function redraw() : void
      {
         var _loc5_:* = undefined;
         var _loc6_:DisplayObject = null;
         if(!labelValue)
         {
            super.redraw();
            return;
         }
         var _loc1_:* = this.forState(this.labels[labelValue]) || this.labels[labelValue];
         if(_loc1_ == null)
         {
            throw new ArgumentError("Undefined label \'" + labelValue + "\'");
         }
         _loc1_ = [].concat(_loc1_);
         while(this.elementContainer.numChildren)
         {
            this.layout.remove(this.elementContainer.getChildAt(0));
         }
         var _loc2_:Array = [];
         var _loc3_:String = this.getStateKey(this.labels[labelValue]);
         this.elementCache[labelValue] = this.elementCache[labelValue] || {};
         this.elementCache[labelValue][_loc3_] = this.elementCache[labelValue][_loc3_] || [];
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_.length)
         {
            _loc5_ = _loc1_[_loc4_];
            _loc6_ = this.elementCache[labelValue][_loc3_][_loc4_];
            if(!_loc6_)
            {
               _loc6_ = this.getElement(_loc5_);
               this.elementCache[labelValue][_loc3_][_loc4_] = _loc6_;
            }
            if(_loc6_ is MovieClip)
            {
               this.gotoState(MovieClip(_loc6_));
            }
            else if(_loc6_ is Button)
            {
               Button(_loc6_).setState(stateValue);
            }
            if(!(_loc5_ is DisplayObject || _loc5_ is Class))
            {
               _loc2_.push(this.transformText(_loc5_.toString(),_loc6_));
            }
            this.layout.add(_loc6_);
            _loc4_++;
         }
         if(this.elementContainer.numChildren)
         {
            this.contents = this.elementContainer.getChildAt(0);
         }
         if(!accessibleName)
         {
            accessibleName = _loc2_.join(" ") || labelValue;
         }
         nominalWidth = nominalWidth || int(this.elementContainer.width);
         nominalHeight = nominalHeight || int(this.elementContainer.height);
         this.alignContents();
         super.redraw();
      }
      
      protected function transformText(param1:String, param2:DisplayObject) : String
      {
         var _loc3_:TextField = TextField(param2);
         var _loc4_:TextFormat = Theme.newTextFormat();
         _loc4_.align = TextFormatAlign.CENTER;
         _loc4_.leftMargin = 4;
         _loc4_.rightMargin = 4;
         _loc3_.defaultTextFormat = _loc4_;
         _loc3_.text = param1;
         return param1;
      }
      
      public function set labels(param1:Object) : void
      {
         this.labelsValue = param1;
         this.redraw();
      }
      
      protected function alignContents() : void
      {
         var _loc3_:DisplayObject = null;
         var _loc1_:int = Math.round((nominalWidth - this.elementContainer.width) / 2);
         var _loc2_:int = 0;
         while(_loc2_ < this.elementContainer.numChildren)
         {
            _loc3_ = this.elementContainer.getChildAt(_loc2_);
            _loc3_.x += _loc1_;
            _loc3_.y = Math.round((nominalHeight - _loc3_.height) / 2);
            _loc2_++;
         }
      }
   }
}

