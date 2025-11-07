package com.google.youtube.ui
{
   import com.google.youtube.event.TweenEvent;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.util.Tween;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class ControlButton extends Button
   {
      
      protected static const DEFAULT_WIDTH:int = 30;
      
      protected static const DEFAULT_HEIGHT:int = 25;
      
      protected var notificationIcon:DisplayObject;
      
      protected var notificationTween:Tween;
      
      protected var messages:IMessages;
      
      protected var tooltipMessageValue:String;
      
      protected var originalWidth:int;
      
      protected var bounds:Rectangle;
      
      public function ControlButton(param1:IMessages = null, param2:* = null, param3:int = 0)
      {
         super(param2);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.createBackground();
         setSize(nominalWidth || param3 || DEFAULT_WIDTH,nominalHeight || DEFAULT_HEIGHT);
         this.originalWidth = nominalWidth;
         this.bounds = new Rectangle(0,0,nominalWidth,nominalHeight);
         this.notificationTween = new Tween(this.bounds);
         this.notificationTween.addEventListener(TweenEvent.UPDATE,this.onResize);
         if(param1)
         {
            this.messages = param1;
            param1.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
         }
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         if(this.messages)
         {
            if(param1)
            {
               if(accessibleState)
               {
                  accessibleState = "";
               }
            }
            else
            {
               accessibleState = this.messages.getMessage(WatchMessages.UNAVAILABLE);
            }
         }
         alpha = param1 ? Theme.getConstant("ICON_ENABLED_ALPHA") : Theme.getConstant("ICON_DISABLED_ALPHA");
      }
      
      protected function createBackground() : void
      {
         backgrounds = {
            "up":Theme.getClass("BgUp"),
            "over":Theme.getClass("BgOver"),
            "down":Theme.getClass("BgDown")
         };
      }
      
      protected function showNotification(param1:DisplayObject) : void
      {
         if(Boolean(this.notificationIcon) && contains(this.notificationIcon))
         {
            removeChild(this.notificationIcon);
         }
         this.notificationIcon = param1;
         this.notificationIcon.visible = false;
         if(this.notificationIcon is InteractiveObject)
         {
            InteractiveObject(this.notificationIcon).mouseEnabled = false;
            InteractiveObject(this.notificationIcon).tabEnabled = false;
         }
         this.notificationTween.to({"width":this.originalWidth + 15},100);
         addChild(param1);
      }
      
      public function onMessageUpdate(param1:MessageEvent = null) : void
      {
         if(Boolean(this.messages) && Boolean(this.tooltipMessageValue))
         {
            tooltipText = this.messages.getMessage(this.tooltipMessageValue);
         }
      }
      
      protected function hideNotification() : void
      {
         this.notificationTween.to({"width":this.originalWidth},100);
         if(Boolean(this.notificationIcon) && contains(this.notificationIcon))
         {
            removeChild(this.notificationIcon);
         }
         this.notificationIcon = null;
      }
      
      override public function onMouseDown(param1:MouseEvent) : void
      {
         if(param1.target == this)
         {
            setState(stateValue.onMouseDown());
         }
      }
      
      public function set tooltipMessage(param1:String) : void
      {
         tooltipText = null;
         this.tooltipMessageValue = param1;
         this.onMessageUpdate();
      }
      
      public function onMouseOut(param1:MouseEvent) : void
      {
         setState(stateValue.onRollOut());
      }
      
      protected function onResize(param1:TweenEvent) : void
      {
         nominalWidth = this.bounds.width;
         dispatchEvent(new Event(Event.RESIZE,true));
      }
      
      override protected function transformText(param1:String, param2:DisplayObject) : String
      {
         super.transformText(param1,param2);
         var _loc3_:TextField = TextField(param2);
         _loc3_.textColor = stateValue is IRollOverState ? Theme.getConstant("FOREGROUND_TEXT_COLOR_HOVER") : Theme.getConstant("FOREGROUND_TEXT_COLOR");
         return _loc3_.text;
      }
      
      public function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.target == this)
         {
            setState(stateValue.onRollOver());
         }
      }
      
      override protected function alignContents() : void
      {
         var _loc3_:Rectangle = null;
         var _loc4_:DisplayObject = null;
         if(this.notificationIcon)
         {
            _loc3_ = this.notificationIcon.getBounds(this.notificationIcon);
            this.notificationIcon.x = Math.floor(4 - _loc3_.left);
            this.notificationIcon.y = Math.floor(nominalHeight / 2);
            this.notificationIcon.visible = true;
         }
         var _loc1_:int = Math.floor((nominalWidth - elementContainer.width) / 2);
         var _loc2_:int = 0;
         while(_loc2_ < elementContainer.numChildren)
         {
            _loc4_ = elementContainer.getChildAt(_loc2_);
            _loc4_.x += Math.floor(nominalWidth - this.originalWidth + (this.originalWidth - contents.width) / 2);
            _loc4_.y = Math.floor((nominalHeight - _loc4_.height) / 2);
            _loc2_++;
         }
      }
   }
}

