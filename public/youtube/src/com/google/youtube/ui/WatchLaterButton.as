package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.WatchMessages;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class WatchLaterButton extends ControlButton
   {
      
      protected static const TEXTFIELD_GUTTER:int = 4;
      
      protected static const MENU_MARGIN:int = 4;
      
      protected static const ICON_FUDGE_X:int = 6;
      
      protected var menuTextField:TextField;
      
      protected var menuItem:MenuItem;
      
      protected var menu:PopupMenu = new PopupMenu();
      
      public function WatchLaterButton(param1:IMessages)
      {
         super(param1);
         tooltipMessage = WatchMessages.WATCH_LATER;
         labels = {
            "default":Theme.newButton(ClockIcon),
            "complete":this.makeCenteredIcon(CheckIcon),
            "error":this.makeCenteredIcon(AlertIcon),
            "loading":this.makeCenteredIcon(MiniSpinner)
         };
         setLabel("default");
      }
      
      public function hideMenu() : void
      {
         if(contains(this.menu))
         {
            removeChild(this.menu);
         }
      }
      
      override public function showTooltip(param1:Boolean = true) : void
      {
         if(enabled && getLabel() != "error")
         {
            super.showTooltip(false);
         }
      }
      
      override public function onMouseDown(param1:MouseEvent) : void
      {
         super.onMouseDown(param1);
         if(param1.target == this)
         {
            if(!contains(this.menu) && Boolean(this.menuItem))
            {
               this.showMenu();
            }
            else
            {
               this.hideMenu();
            }
         }
      }
      
      public function setMenuMessage(param1:String) : void
      {
         if(!this.menuItem)
         {
            mouseChildren = true;
            this.menuTextField = Theme.newTextField();
            this.menuItem = new MenuItem(this.menuTextField);
            this.menuItem.enabled = false;
            this.menuItem.mouseEnabled = false;
            this.menuItem.mouseChildren = true;
         }
         this.menuTextField.htmlText = param1;
         this.menuTextField.mouseEnabled = true;
         var _loc2_:Point = localToGlobal(new Point(nominalWidth,0));
         var _loc3_:int = _loc2_.x - TEXTFIELD_GUTTER - MenuItem.PADDING - MENU_MARGIN;
         if(this.menuTextField.textWidth > _loc3_)
         {
            this.menuTextField.width = _loc3_;
            this.menuTextField.multiline = true;
            this.menuTextField.wordWrap = true;
         }
         this.menuItem.height = this.menuTextField.height;
         this.menuItem.width = this.menuTextField.width;
         this.menu.add(this.menuItem);
         this.showMenu();
      }
      
      public function reset() : void
      {
         setLabel("default");
         enabled = true;
      }
      
      protected function makeCenteredIcon(param1:Class) : LayoutElement
      {
         var _loc2_:DisplayObject = new param1();
         _loc2_.x = ICON_FUDGE_X;
         _loc2_.y = _loc2_.height / 2;
         return new LayoutElement(_loc2_);
      }
      
      protected function showMenu() : void
      {
         addChild(this.menu);
         var _loc1_:Rectangle = this.menu.getBounds(this.menu);
         this.menu.x = nominalWidth - _loc1_.right;
         this.menu.y = -_loc1_.bottom;
      }
   }
}

