package com.google.youtube.ui
{
   import com.google.youtube.event.VideoProgressEvent;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.util.Layout;
   import com.google.youtube.util.Tween;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.EventDispatcher;
   
   public class VideoControls extends LayoutStrip
   {
      
      protected static const IDLE:int = 5000;
      
      public static const DEFAULT:String = "DEFAULT";
      
      public static const FADE:String = "FADE";
      
      public static const CONTROLS_HEIGHT:int = 30;
      
      public static const GUTTER_HEIGHT:Number = 3;
      
      public static const OTHER_CONTROLS_WIDTH:Number = 240;
      
      public static const MINIMUM_SECONDARY_WIDTH:Number = 55;
      
      protected var visibleControlsValue:Boolean = true;
      
      protected var seekBar:SeekBar;
      
      protected var messages:IMessages;
      
      protected var fadeTween:Tween;
      
      protected var allowSeekingValue:Boolean = true;
      
      protected var fadeTintValue:uint = 16777215;
      
      protected var uiEventDispatcher:EventDispatcher;
      
      public function VideoControls(param1:IMessages = null, param2:Boolean = true)
      {
         this.seekBar = new SeekBar(param1,true);
         super(["primary","audioTrack","status"],["modules","secondary","size"]);
         order("status","primary","secondary","size",SeekBar,"audioTrack","modules");
         drawing(background.graphics).fill(Theme.getConstant("CONTROLS_BACKGROUND_COLOR"),Theme.getConstant("CONTROLS_BACKGROUND_ALPHA")).rect(0,Theme.getConstant("SEEK_OFFSET") - 0.5,30,26);
         if(param2)
         {
            layout.add(this.seekBar);
         }
         else
         {
            this.seekBar.enabled = false;
         }
         foreground.alpha = 0;
         this.fadeTween = new Tween(foreground);
         verticalRegistration = 1;
         horizontalStretch = 1;
         nominalHeight = CONTROLS_HEIGHT;
         mouseEnabled = true;
      }
      
      public function get size() : Layout
      {
         return section("size");
      }
      
      public function get primary() : Layout
      {
         return section("primary");
      }
      
      public function set videoData(param1:VideoData) : void
      {
         this.seekBar.videoData = param1;
      }
      
      override public function realign() : void
      {
         var _loc3_:VideoControlsSection = null;
         var _loc4_:DisplayObject = null;
         super.realign();
         var _loc1_:int = int(right.length - 1);
         var _loc2_:Number = -Number.MIN_VALUE;
         while(_loc1_ >= 0)
         {
            _loc3_ = VideoControlsSection(sections[right[_loc1_]]);
            _loc4_ = getChildByName(right[_loc1_]);
            _loc2_ = this.alignSection(DisplayObjectContainer(_loc4_),_loc2_);
            if(Boolean(_loc3_) && Boolean(_loc3_.maxWidth))
            {
               _loc2_ += _loc3_.getButtonsWidth() - _loc3_.getButtonsWidth(false);
            }
            _loc1_--;
         }
      }
      
      public function get modules() : Layout
      {
         return section("modules");
      }
      
      override public function get enabled() : Boolean
      {
         return this.seekBar.enabled;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         this.seekBar.enabled = this.allowSeekingValue && param1 && contains(this.seekBar);
      }
      
      override protected function drawBackground() : void
      {
         background.width = nominalWidth;
         background.height = nominalHeight;
      }
      
      public function addMarker(param1:SeekBarMarker) : void
      {
         this.seekBar.addMarker(param1);
      }
      
      public function get audioTrack() : Layout
      {
         return section("audioTrack");
      }
      
      public function get visibleControls() : Boolean
      {
         return this.visibleControlsValue;
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         var _loc6_:Number = NaN;
         var _loc3_:VideoControlsSection = VideoControlsSection(this.modules);
         var _loc4_:VideoControlsSection = VideoControlsSection(this.secondary);
         var _loc5_:Number = param1 - OTHER_CONTROLS_WIDTH;
         if(_loc3_.getButtonsWidth() > _loc5_)
         {
            _loc6_ = MINIMUM_SECONDARY_WIDTH;
         }
         else
         {
            _loc6_ = Math.max(MINIMUM_SECONDARY_WIDTH,param1 - OTHER_CONTROLS_WIDTH - _loc3_.getButtonsWidth());
         }
         _loc4_.maxWidth = _loc6_;
         _loc5_ = param1 - OTHER_CONTROLS_WIDTH - _loc4_.getButtonsWidth(false);
         _loc3_.maxWidth = _loc5_;
         super.setSize(param1,param2);
         this.seekBar.setPosition(0,this.visibleControls ? 0 : param2 - GUTTER_HEIGHT);
         this.seekBar.setSize(nominalWidth,GUTTER_HEIGHT);
      }
      
      public function set visibleControls(param1:Boolean) : void
      {
         var _loc3_:DisplayObject = null;
         this.visibleControlsValue = param1;
         var _loc2_:int = 0;
         while(_loc2_ < numChildren)
         {
            _loc3_ = getChildAt(_loc2_);
            _loc3_.visible = _loc3_ == this.seekBar ? true : param1;
            _loc2_++;
         }
         background.visible = param1;
         this.realign();
      }
      
      public function set isPeggedToLive(param1:Boolean) : void
      {
         this.seekBar.isPeggedToLive = param1;
      }
      
      public function removeMarker(param1:SeekBarMarker) : void
      {
         this.seekBar.removeMarker(param1);
      }
      
      override protected function drawForeground() : void
      {
      }
      
      public function get allowSeeking() : Boolean
      {
         return this.allowSeekingValue;
      }
      
      public function onVideoProgress(param1:VideoProgressEvent) : void
      {
         this.seekBar.onVideoProgress(param1);
      }
      
      override protected function createSection(param1:DisplayObjectContainer) : Layout
      {
         return new VideoControlsSection(param1);
      }
      
      public function set isLive(param1:Boolean) : void
      {
         this.seekBar.isLive = param1;
      }
      
      public function set fadeTint(param1:uint) : void
      {
         this.fadeTintValue = param1;
         this.drawForeground();
      }
      
      public function set allowSeeking(param1:Boolean) : void
      {
         this.allowSeekingValue = param1;
      }
      
      public function get mouseOver() : Boolean
      {
         return stateValue is IRollOverState;
      }
      
      public function get status() : Layout
      {
         return section("status");
      }
      
      public function get secondary() : Layout
      {
         return section("secondary");
      }
      
      public function set duration(param1:Number) : void
      {
         this.seekBar.duration = param1;
      }
      
      override protected function alignSection(param1:DisplayObjectContainer, param2:Number) : Number
      {
         var _loc4_:DisplayObject = null;
         if(!param1 || !param1.numChildren)
         {
            return param2;
         }
         param2 = super.alignSection(param1,param2);
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc3_);
            _loc4_.height = nominalHeight - GUTTER_HEIGHT - 2;
            _loc3_++;
         }
         param1.y = GUTTER_HEIGHT + 1;
         return param2;
      }
      
      override public function setLabel(param1:String, param2:Boolean = true) : void
      {
         if(labelValue != param1)
         {
            labelValue = param1;
            if(param1 == FADE)
            {
               this.fadeTween.to({"alpha":Theme.getConstant("OVERLAY_OPACITY")},param2 ? 500 : 0);
            }
            else
            {
               this.fadeTween.to({"alpha":0},param2 ? 100 : 0);
            }
         }
         this.seekBar.setLabel(param1,param2);
      }
      
      override public function get height() : Number
      {
         return CONTROLS_HEIGHT + this.seekBar.height;
      }
   }
}

import com.google.youtube.util.Layout;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;

class VideoControlsSection extends Layout
{
   
   public var maxWidthValue:Number;
   
   public function VideoControlsSection(param1:DisplayObjectContainer)
   {
      super(param1,Layout.FLOW_RIGHT);
   }
   
   override public function add(... rest) : void
   {
      var _loc2_:int = 0;
      while(_loc2_ < rest.length)
      {
         if(rest[_loc2_] is ModuleButton)
         {
            rest[_loc2_].addEventListener(Event.CHANGE,this.onModuleButtonChange);
         }
         _loc2_++;
      }
      super.add.apply(this,rest);
      this.clipButtons();
   }
   
   public function get maxWidth() : Number
   {
      return this.maxWidthValue;
   }
   
   override public function remove(... rest) : void
   {
      var _loc2_:int = 0;
      while(_loc2_ < rest.length)
      {
         if(rest[_loc2_] is ModuleButton)
         {
            rest[_loc2_].removeEventListener(Event.CHANGE,this.onModuleButtonChange);
         }
         _loc2_++;
      }
      super.remove.apply(this,rest);
      this.clipButtons();
   }
   
   override protected function alignAt(param1:int) : void
   {
      super.alignAt(param1);
      container.dispatchEvent(new Event(Event.RESIZE));
   }
   
   public function clipButtons() : void
   {
      var _loc3_:DisplayObject = null;
      var _loc1_:Number = 0;
      var _loc2_:int = container.numChildren - 1;
      while(_loc2_ >= 0)
      {
         _loc3_ = container.getChildAt(_loc2_);
         if(isNaN(this.maxWidthValue))
         {
            _loc3_.visible = _loc3_ is ModuleButton ? ModuleButton(_loc3_).module.visible : true;
         }
         else
         {
            _loc1_ += _loc3_.width == 0 ? 0 : (_loc3_ is YouTubeButton ? 55 : 30);
            if(_loc3_ is ModuleButton)
            {
               _loc3_.visible = _loc1_ <= this.maxWidthValue && ModuleButton(_loc3_).module.visible;
            }
            else
            {
               _loc3_.visible = _loc1_ <= this.maxWidthValue;
            }
         }
         _loc2_--;
      }
   }
   
   public function getButtonsWidth(param1:Boolean = true) : Number
   {
      var _loc4_:DisplayObject = null;
      var _loc5_:Number = NaN;
      var _loc2_:Number = 0;
      var _loc3_:int = container.numChildren - 1;
      while(_loc3_ >= 0)
      {
         _loc4_ = container.getChildAt(_loc3_);
         _loc5_ = _loc4_.width == 0 ? 0 : (_loc4_ is YouTubeButton ? 55 : 30);
         if(!param1 && _loc2_ + _loc5_ > this.maxWidthValue)
         {
            return _loc2_;
         }
         _loc2_ += _loc5_;
         _loc3_--;
      }
      return _loc2_;
   }
   
   public function set maxWidth(param1:Number) : void
   {
      if(param1 != this.maxWidthValue)
      {
         this.maxWidthValue = param1;
         this.clipButtons();
      }
   }
   
   private function onModuleButtonChange(param1:Event) : void
   {
      this.alignAt(0);
      this.clipButtons();
   }
}
