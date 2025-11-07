package com.google.youtube.ui
{
   import com.google.utils.StringUtils;
   import com.google.youtube.event.SeekEvent;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.WatchMessages;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class TimeDisplay extends UIElement
   {
      
      protected static var PADDING_TOP:Number = 3;
      
      protected static var PADDING_SIDE:Number = 4;
      
      protected var timeVisibleValue:Boolean = true;
      
      protected var durationFormatted:String;
      
      protected var durationVisibleValue:Boolean = true;
      
      protected var liveBadge:Button;
      
      protected var primaryFormat:TextFormat;
      
      protected var lastDisplayedTime:Number;
      
      protected var timeValue:Number = 0;
      
      protected var timeDisplay:TextField;
      
      protected var durationValue:Number = 0;
      
      public function TimeDisplay(param1:IMessages)
      {
         super();
         this.durationFormatted = this.formatDuration(this.durationValue);
         this.timeDisplay = Theme.newTextField(Theme.newTextFormat(Theme.DEFAULT_TEXT_SIZE,Theme.getConstant("FOREGROUND_TEXT_COLOR")));
         this.timeDisplay.x = PADDING_SIDE;
         this.timeDisplay.y = PADDING_TOP;
         this.primaryFormat = Theme.newTextFormat(Theme.DEFAULT_TEXT_SIZE,Theme.getConstant("FOREGROUND_TEXT_COLOR_HOVER"));
         addChild(this.timeDisplay);
         this.liveBadge = new Button();
         this.liveBadge.labels = {
            "enabled":new LiveBadge(param1,true),
            "disabled":new LiveBadge(param1,false)
         };
         this.liveBadge.setLabel("enabled");
         this.liveBadge.addEventListener(MouseEvent.CLICK,this.onLiveBadgeClickHandler);
         this.isPeggedToLive = false;
         this.updateTime();
         this.liveBadge.y = Math.ceil(this.timeDisplay.y + (this.timeDisplay.height - this.liveBadge.height) / 2);
         param1.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         this.liveBadge.mouseEnabled = param1;
      }
      
      public function set timeVisible(param1:Boolean) : void
      {
         if(!param1 && contains(this.timeDisplay))
         {
            removeChild(this.timeDisplay);
         }
         else if(param1 && !contains(this.timeDisplay))
         {
            addChild(this.timeDisplay);
         }
         this.timeVisibleValue = param1;
      }
      
      override public function get width() : Number
      {
         return this.timeDisplay.width + PADDING_SIDE * 2 + contains(this.liveBadge) ? this.liveBadge.width : 0;
      }
      
      protected function onMessageUpdate(param1:MessageEvent) : void
      {
         this.liveBadge.tooltipText = param1.messages.getMessage(WatchMessages.GOTO_LIVE_TOOLTIP);
      }
      
      public function get time() : Number
      {
         return isNaN(this.timeValue) || this.timeValue == Infinity ? this.durationValue : this.timeValue;
      }
      
      public function set time(param1:Number) : void
      {
         var _loc2_:* = Math.floor(this.timeValue) != Math.floor(param1);
         this.timeValue = param1;
         if(_loc2_)
         {
            this.updateTime();
         }
      }
      
      public function set isPeggedToLive(param1:Boolean) : void
      {
         this.liveBadge.mouseEnabled = !param1;
         this.liveBadge.setLabel(param1 ? "enabled" : "disabled");
      }
      
      public function set duration(param1:Number) : void
      {
         if(this.durationValue != param1)
         {
            this.durationValue = param1;
            this.durationFormatted = this.formatDuration(this.durationValue);
            this.updateTime(true);
         }
      }
      
      public function formatDuration(param1:Number) : String
      {
         return StringUtils.formatTime(Math.ceil(param1) * 1000,true);
      }
      
      public function set isLive(param1:Boolean) : void
      {
         if(param1)
         {
            addChild(this.liveBadge);
         }
         else if(contains(this.liveBadge))
         {
            removeChild(this.liveBadge);
         }
         this.updateTime(true);
      }
      
      protected function updateTime(param1:Boolean = false) : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc2_:Number = this.time > 0 ? Math.round(this.time) : 0;
         if(_loc2_ != this.lastDisplayedTime || param1)
         {
            if(Math.ceil(this.timeValue) == Math.ceil(this.durationValue))
            {
               _loc3_ = this.durationFormatted;
            }
            else
            {
               _loc5_ = this.durationFormatted.length - int(this.durationFormatted.length / 3);
               _loc3_ = StringUtils.formatTime(_loc2_ * 1000,true,_loc5_);
            }
            _loc4_ = _loc3_.length;
            if(this.durationVisibleValue && this.durationValue != 0 && this.durationFormatted != "")
            {
               _loc3_ = _loc3_.concat(" / ",this.durationFormatted);
            }
            this.timeDisplay.text = _loc3_;
            this.timeDisplay.setTextFormat(this.primaryFormat,0,_loc4_);
            this.lastDisplayedTime = this.timeValue;
            this.liveBadge.x = this.timeVisibleValue ? this.timeDisplay.x + this.timeDisplay.width + PADDING_SIDE * 2 : PADDING_SIDE;
         }
      }
      
      private function onLiveBadgeClickHandler(param1:MouseEvent) : void
      {
         dispatchEvent(new SeekEvent(SeekEvent.COMPLETE,Infinity));
      }
      
      public function set durationVisible(param1:Boolean) : void
      {
         if(this.durationVisibleValue != param1)
         {
            this.durationVisibleValue = param1;
            this.updateTime(true);
         }
      }
   }
}

