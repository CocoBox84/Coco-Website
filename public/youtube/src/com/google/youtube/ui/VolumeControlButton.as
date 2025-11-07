package com.google.youtube.ui
{
   import com.google.youtube.event.TweenEvent;
   import com.google.youtube.event.VolumeEvent;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.util.Tween;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class VolumeControlButton extends ControlButton
   {
      
      protected static const VOLUME_EXPONENT:Number = 2;
      
      protected var sliderBg:Sprite = new Sprite();
      
      protected var sliderTween:Tween;
      
      protected var slider:MovieClip;
      
      protected var sliding:Boolean = false;
      
      protected var currentValue:Number;
      
      public function VolumeControlButton(param1:Number, param2:IMessages = null)
      {
         super(param2);
         tooltipMessage = WatchMessages.MUTE;
         mouseChildren = false;
         labels = {
            "state0":Theme.newButton(VolumeIconState0),
            "state1":Theme.newButton(VolumeIconState1),
            "state2":Theme.newButton(VolumeIconState2),
            "state3":Theme.newButton(VolumeIconState3)
         };
         this.build();
         this.currentValue = isNaN(param1) ? 100 : param1;
         this.setValue(this.currentValue);
      }
      
      override public function onMouseUp(param1:MouseEvent) : void
      {
         super.onMouseUp(param1);
         removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         if(!(stateValue is IRollOverState))
         {
            this.slideIn();
         }
      }
      
      override public function onMouseDown(param1:MouseEvent) : void
      {
         super.onMouseDown(param1);
         this.sliding = false;
         this.onMouseMove(param1);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         if(!enabled)
         {
            this.slideIn(false);
         }
      }
      
      override public function get width() : Number
      {
         return int(this.sliderBg.x + this.sliderBg.width);
      }
      
      protected function slideOut() : void
      {
         this.sliderTween.easeOut().to({"x":nominalWidth},100);
      }
      
      override public function showTooltip(param1:Boolean = true) : void
      {
         if(Boolean(messages) && this.currentValue != 0)
         {
            super.showTooltip(param1);
            tooltip.alignWith(this,new Point(nominalWidth / 2,0));
         }
      }
      
      protected function isMuted() : Boolean
      {
         return this.slider.currentFrame == 1;
      }
      
      override public function onClick(param1:MouseEvent) : void
      {
         if(this.sliding)
         {
            return;
         }
         if(this.isMuted())
         {
            dispatchEvent(new VolumeEvent(VolumeEvent.UNMUTE));
            tooltipMessage = WatchMessages.MUTE;
            onMessageUpdate();
            this.setValue(this.currentValue);
         }
         else
         {
            dispatchEvent(new VolumeEvent(VolumeEvent.MUTE));
            tooltipMessage = WatchMessages.UNMUTE;
            onMessageUpdate();
            this.setValue(0);
         }
         this.showTooltip();
      }
      
      protected function build() : void
      {
         this.slider = new (Theme.getClass("Slider"))();
         this.slider.x = 6;
         this.slider.y = int((nominalHeight - this.slider.height) / 2);
         Drawing.invisibleRect(this.sliderBg.graphics,0,0,this.slider.width + 12,nominalHeight);
         this.sliderBg.addChild(this.slider);
         addChild(this.sliderBg);
         this.sliderBg.name = "slider";
         var _loc1_:Shape = Shape(addChild(new Shape()));
         drawing(_loc1_.graphics).fill(16711935).rect(nominalWidth,0,this.sliderBg.width,this.sliderBg.height).end();
         this.sliderBg.x = nominalWidth - this.sliderBg.width;
         this.sliderBg.mask = _loc1_;
         this.sliderTween = new Tween(this.sliderBg);
         this.sliderTween.addEventListener(TweenEvent.UPDATE,this.onSlideUpdate);
      }
      
      public function setValue(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 100;
         }
         if(param1 == 0)
         {
            tooltipMessage = WatchMessages.UNMUTE;
            onMessageUpdate();
         }
         else if(this.isMuted())
         {
            tooltipMessage = WatchMessages.MUTE;
            onMessageUpdate();
         }
         var _loc2_:Number = Math.pow(param1 / 100,1 / VOLUME_EXPONENT) * 100;
         this.slider.gotoAndStop(int(_loc2_) + 1);
         setLabel("state" + Math.min(3,Math.ceil(_loc2_ / 25)));
      }
      
      override public function onRollOut(param1:MouseEvent) : void
      {
         super.onRollOut(param1);
         if(!(stateValue is IMouseDownState))
         {
            this.slideIn();
         }
      }
      
      protected function slideIn(param1:Boolean = true) : void
      {
         this.sliderTween.easeIn().to({"x":nominalWidth - this.sliderBg.width},param1 ? 500 : 0);
      }
      
      public function onMouseMove(param1:MouseEvent) : void
      {
         if(param1.localX >= this.sliderBg.x)
         {
            this.sliding = true;
         }
         if(!this.sliding)
         {
            return;
         }
         var _loc2_:Rectangle = this.slider.getBounds(this);
         this.currentValue = (param1.localX - _loc2_.x) / _loc2_.width;
         this.currentValue = this.currentValue < 0 ? 0 : (this.currentValue > 1 ? 1 : this.currentValue);
         this.currentValue = 100 * Math.pow(this.currentValue,VOLUME_EXPONENT);
         dispatchEvent(new VolumeEvent(VolumeEvent.CHANGE,this.currentValue));
         this.setValue(this.currentValue);
         param1.updateAfterEvent();
      }
      
      protected function onSlideUpdate(param1:TweenEvent) : void
      {
         dispatchEvent(new Event(Event.RESIZE,true));
      }
      
      override public function onRollOver(param1:MouseEvent) : void
      {
         super.onRollOver(param1);
         if(param1.buttonDown || !enabled)
         {
            return;
         }
         this.slideOut();
      }
   }
}

