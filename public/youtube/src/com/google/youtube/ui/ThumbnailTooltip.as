package com.google.youtube.ui
{
   import com.google.utils.StringUtils;
   import com.google.youtube.model.MosaicLoader;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class ThumbnailTooltip extends Sprite
   {
      
      public static const PADDING:Number = 2;
      
      public static const TEXT_COLOR:uint = 14935011;
      
      protected static const THUMB_WIDTH:int = 108;
      
      protected static const THUMB_HEIGHT:int = 60;
      
      public var barWidth:Number = 0;
      
      protected var indicator:Shape = new Shape();
      
      protected var tooltipText:TextField;
      
      protected var timeText:TextField;
      
      protected var timeTextBackground:Shape = new Shape();
      
      protected var thumbnail:VideoStoryboardThumbnail;
      
      protected var background:Shape = new Shape();
      
      protected var mosaicLoader:MosaicLoader;
      
      public function ThumbnailTooltip(param1:MosaicLoader)
      {
         super();
         this.mosaicLoader = param1;
         mouseEnabled = false;
         mouseChildren = false;
         this.thumbnail = new VideoStoryboardThumbnail(param1);
         this.thumbnail.width = THUMB_WIDTH;
         this.thumbnail.height = THUMB_HEIGHT;
         this.thumbnail.x = PADDING;
         this.thumbnail.y = PADDING;
         var _loc2_:TextFormat = Theme.newTextFormat();
         _loc2_.align = TextFormatAlign.CENTER;
         _loc2_.color = TEXT_COLOR;
         this.timeText = Theme.newTextField(_loc2_);
         Theme.autoSizeTextFieldToWidth(this.timeText,this.thumbnail.width);
         this.timeText.y = this.nominalHeight - this.timeText.textHeight - Theme.TEXT_PADDING - PADDING;
         this.timeText.x = PADDING;
         _loc2_.align = TextFormatAlign.LEFT;
         _loc2_.leading = -2;
         this.tooltipText = Theme.newTextField(_loc2_);
         this.tooltipText.autoSize = TextFieldAutoSize.NONE;
         this.tooltipText.width = THUMB_WIDTH - PADDING * 2;
         this.tooltipText.height = THUMB_HEIGHT;
         this.tooltipText.x = THUMB_WIDTH + PADDING * 3;
         this.tooltipText.y = this.thumbnail.y;
         this.tooltipText.wordWrap = true;
         this.drawBackground();
         drawing(this.indicator.graphics).clear().fill(Theme.getConstant("TOOLTIP_COLOR"),Theme.getConstant("TOOLTIP_ALPHA")).line(-Tooltip.TIP_SIZE,0,Tooltip.TIP_SIZE,0,0,Tooltip.TIP_SIZE);
         this.indicator.x = this.thumbnail.x + width / 2;
         this.indicator.y = this.background.height;
         addChild(this.background);
         addChild(this.thumbnail);
         addChild(this.indicator);
         addChild(this.timeTextBackground);
         addChild(this.timeText);
         addChild(this.tooltipText);
      }
      
      public function set tooltip(param1:String) : void
      {
         if(this.tooltipText)
         {
            this.tooltipText.text = param1 || "";
            this.drawBackground();
         }
      }
      
      protected function get nominalWidth() : Number
      {
         return THUMB_WIDTH + PADDING * 2;
      }
      
      protected function get expandedWidth() : Number
      {
         return this.nominalWidth + (this.tooltipText.text != "" ? PADDING + Math.min(THUMB_WIDTH,this.tooltipText.textWidth + Theme.TEXT_PADDING) : 0);
      }
      
      protected function drawBackground() : void
      {
         var _loc1_:Number = this.nominalWidth;
         if(this.tooltipText.text != "")
         {
            _loc1_ += THUMB_WIDTH + PADDING;
         }
         drawing(this.background.graphics).clear().fill(Theme.getConstant("TOOLTIP_COLOR"),Theme.getConstant("TOOLTIP_ALPHA")).roundRect(0,0,this.expandedWidth,this.nominalHeight - PADDING,Tooltip.CORNER_RADIUS).fill(0).rect(this.thumbnail.x,this.thumbnail.y,THUMB_WIDTH,THUMB_HEIGHT);
      }
      
      public function set time(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this.timeText)
         {
            this.timeText.text = StringUtils.formatTime(param1 * 1000,true);
            _loc2_ = this.timeText.textWidth + Theme.TEXT_PADDING * 2;
            _loc3_ = this.timeText.textHeight;
            drawing(this.timeTextBackground.graphics).clear().fill(Theme.getConstant("TOOLTIP_COLOR"),Theme.getConstant("TOOLTIP_ALPHA") / 2).rect(this.timeText.x + (this.timeText.width - _loc2_) / 2,this.timeText.y + (this.timeText.height - _loc3_) / 2,_loc2_,_loc3_);
         }
         this.thumbnail.time = param1;
      }
      
      protected function get nominalHeight() : Number
      {
         return THUMB_HEIGHT + PADDING * 3;
      }
      
      public function alignWith(param1:DisplayObject, param2:Point) : void
      {
         var _loc3_:Point = parent.globalToLocal(param1.localToGlobal(param2));
         y = _loc3_.y - this.nominalHeight;
         this.x = _loc3_.x;
      }
      
      override public function set x(param1:Number) : void
      {
         var _loc2_:Number = param1;
         _loc2_ -= this.nominalWidth / 2;
         super.x = Math.max(Tooltip.STAGE_PADDING,Math.min(this.barWidth - this.expandedWidth - Tooltip.STAGE_PADDING,_loc2_));
         this.indicator.x = Math.max(this.indicator.width,Math.min(this.expandedWidth - this.indicator.width,this.nominalWidth / 2 + _loc2_ - x));
      }
   }
}

