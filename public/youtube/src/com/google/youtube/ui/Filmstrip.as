package com.google.youtube.ui
{
   import com.google.utils.StringUtils;
   import com.google.youtube.model.MosaicLoader;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class Filmstrip extends UIElement
   {
      
      protected static const THUMB_WIDTH:int = 72;
      
      protected static const THUMB_HEIGHT:int = 40;
      
      protected static const STRIP_OFFSET_FROM_BOTTOM:uint = 10;
      
      protected static const MAX_THUMBS:int = 10;
      
      protected static const LENS_BORDER_COLOR:uint = 13421772;
      
      protected var container:Sprite;
      
      protected var oldLens:VideoStoryboardThumbnail;
      
      protected var lensBackground:Shape;
      
      protected var offset:int = 10;
      
      protected var timeText:TextField;
      
      protected var lensContainer:Sprite;
      
      protected var balloons:Array = [];
      
      protected var timeTextBackground:Shape = new Shape();
      
      protected var timeValue:Number = 0;
      
      protected var thumbnail:VideoStoryboardThumbnail;
      
      protected var mosaicLoader:MosaicLoader;
      
      protected var lens:VideoStoryboardThumbnail;
      
      public function Filmstrip(param1:MosaicLoader)
      {
         super();
         this.mosaicLoader = param1;
         horizontalStretchValue = 1;
         verticalStretchValue = 1;
         this.lens = new VideoStoryboardThumbnail(param1);
         this.oldLens = new VideoStoryboardThumbnail(param1);
         this.lensContainer = new Sprite();
         this.lensContainer.addChild(this.lens);
         this.lensContainer.addChild(this.oldLens);
         this.lensBackground = new Shape();
         var _loc2_:TextFormat = Theme.newTextFormat();
         _loc2_.align = TextFormatAlign.CENTER;
         _loc2_.color = ThumbnailTooltip.TEXT_COLOR;
         this.timeText = Theme.newTextField(_loc2_);
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         var _loc3_:* = width != param1;
         var _loc4_:* = height != param2;
         super.setSize(param1,param2);
         if(_loc3_)
         {
            this.initBalloons();
            this.time = this.timeValue;
         }
         else if(_loc4_)
         {
            this.updateHeight();
         }
      }
      
      protected function initBalloons() : void
      {
         var _loc8_:VideoStoryboardThumbnail = null;
         if(Boolean(this.container) && contains(this.container))
         {
            removeChild(this.container);
         }
         this.container = new Sprite();
         addChild(this.container);
         var _loc1_:uint = Math.min(MAX_THUMBS,Math.ceil(nominalWidth / THUMB_WIDTH));
         var _loc2_:Number = nominalWidth / _loc1_;
         var _loc3_:Number = THUMB_HEIGHT / THUMB_WIDTH * _loc2_;
         this.balloons = [];
         var _loc4_:int = 0;
         var _loc5_:uint = 0;
         while(_loc5_ < _loc1_ + 1)
         {
            _loc8_ = new VideoStoryboardThumbnail(this.mosaicLoader);
            _loc8_.width = _loc2_;
            _loc8_.height = _loc3_;
            _loc8_.x = _loc4_;
            _loc8_.y = nominalHeight - this.offset - _loc8_.height;
            _loc4_ += _loc8_.width;
            this.container.addChild(_loc8_);
            this.balloons.push(_loc8_);
            _loc5_++;
         }
         this.lens.width = _loc2_ * 2;
         this.lens.height = _loc3_ * 2;
         this.oldLens.width = this.lens.width;
         this.oldLens.height = this.lens.height;
         var _loc6_:Number = 0;
         var _loc7_:Number = ThumbnailTooltip.PADDING;
         drawing(this.lensBackground.graphics).clear().fill(Theme.getConstant("TOOLTIP_COLOR"),Theme.getConstant("TOOLTIP_ALPHA")).roundRect(-_loc7_,-_loc7_,this.lens.width + _loc7_ * 2,this.lens.height + _loc7_ * 2 + _loc6_,Tooltip.CORNER_RADIUS).fill(0).rect(0,0,this.lens.width,this.lens.height);
         this.lensBackground.y = nominalHeight - this.offset - this.lensBackground.height;
         this.lensBackground.x = (nominalWidth - this.lens.width) / 2;
         this.lensContainer.scrollRect = new Rectangle(0,0,this.lens.width,this.lens.height);
         this.lensContainer.x = this.lensBackground.x;
         this.lensContainer.y = this.lensBackground.y;
         this.lens.x = 0;
         this.oldLens.x = -this.lens.width;
         this.drawBackgroundGradient();
         Theme.autoSizeTextFieldToWidth(this.timeText,_loc2_ * 2);
         this.timeText.x = this.lensContainer.x;
         addChild(this.lensBackground);
         addChild(this.lensContainer);
         addChild(this.timeTextBackground);
         addChild(this.timeText);
      }
      
      protected function updateHeight() : void
      {
         var _loc1_:VideoStoryboardThumbnail = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(!this.container)
         {
            return;
         }
         this.lensBackground.y = nominalHeight - this.offset - this.lensBackground.height;
         this.lensContainer.y = this.lensBackground.y;
         for each(_loc1_ in this.balloons)
         {
            _loc1_.y = this.lensContainer.y + this.lens.height - _loc1_.height - this.offset;
         }
         this.timeText.y = this.lensContainer.y + this.lens.height - 1;
         this.timeText.y -= this.timeText.textHeight;
         _loc2_ = this.timeText.textWidth + Theme.TEXT_PADDING * 2;
         _loc3_ = this.timeText.textHeight;
         drawing(this.timeTextBackground.graphics).clear().fill(Theme.getConstant("TOOLTIP_COLOR"),Theme.getConstant("TOOLTIP_ALPHA") / 2).rect(this.timeText.x + (this.timeText.width - _loc2_) / 2,this.timeText.y + (this.timeText.height - _loc3_) / 2,_loc2_,_loc3_);
         this.drawBackgroundGradient();
      }
      
      public function set time(param1:Number) : void
      {
         var _loc7_:VideoStoryboardThumbnail = null;
         this.timeValue = param1;
         var _loc2_:uint = uint(this.lens.frame);
         this.lens.time = param1;
         if(this.lens.frame == -1)
         {
            visible = false;
            return;
         }
         visible = true;
         if(_loc2_ != this.lens.frame)
         {
            this.oldLens.frame = _loc2_;
            if(_loc2_ < this.lens.frame)
            {
               this.lens.tween.from({"x":this.lens.width}).to({"x":0},150);
               this.oldLens.tween.from({"x":0}).to({"x":-this.lens.width},150);
            }
            else
            {
               this.lens.tween.from({"x":-this.lens.width}).to({"x":0},150);
               this.oldLens.tween.from({"x":0}).to({"x":this.lens.width},150);
            }
         }
         var _loc3_:uint = uint(this.lens.frame);
         var _loc4_:uint = this.balloons.length;
         var _loc5_:uint = Math.floor(_loc4_ / 2);
         var _loc6_:uint = 0;
         while(_loc6_ < _loc4_)
         {
            _loc7_ = this.balloons[_loc6_];
            _loc7_.frame = _loc3_ + _loc6_ - _loc5_;
            if(_loc6_ == 0)
            {
               this.container.x = this.mosaicLoader.getIntervalPercentageForTime(param1) * -_loc7_.width;
            }
            _loc6_++;
         }
         this.timeText.text = StringUtils.formatTime(param1 * 1000,true);
      }
      
      private function drawBackgroundGradient() : void
      {
         var _loc1_:Number = nominalHeight - this.lensContainer.y + 4;
         drawing(graphics).clear().fill([0,0],[0,0.75],[0,64],90,nominalWidth,_loc1_,0,this.lensContainer.y - 4).rect(0,this.lensContainer.y - 4,nominalWidth,_loc1_);
      }
   }
}

