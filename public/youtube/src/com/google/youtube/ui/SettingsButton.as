package com.google.youtube.ui
{
   import com.google.youtube.event.PlaybackRateEvent;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.QualityChangeEvent;
   import com.google.youtube.model.VideoQuality;
   import com.google.youtube.model.WatchMessages;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class SettingsButton extends ControlButton
   {
      
      protected static const ARROW_SIZE:int = 5;
      
      protected var titleContainer:Sprite = new Sprite();
      
      protected var qualityLabelStrings:Object;
      
      protected var spinButton:Button = new Button();
      
      protected var hdIcon:Sprite = new HdGearIcon();
      
      protected var gearHeight:Number;
      
      protected var menuItems:Object = {};
      
      protected var speedMenuItems:Object = {};
      
      protected var speedTitleContainer:Sprite = new Sprite();
      
      protected var button:Button = new Button();
      
      protected var numSpeedMenuItems:int;
      
      protected var speedMenu:PopupMenu = new PopupMenu();
      
      protected var speedTitle:TextField = Theme.newTextField();
      
      protected var speedLabelStrings:Object;
      
      protected var title:TextField = Theme.newTextField();
      
      protected var menu:PopupMenu = new PopupMenu();
      
      protected var slowBubble:Sprite = new Sprite();
      
      public var showBubble:Boolean;
      
      protected var neverPlayHighQuality:Boolean;
      
      public function SettingsButton(param1:IMessages, param2:Boolean)
      {
         this.neverPlayHighQuality = param2;
         this.showBubble = param2;
         super(param1);
         this.menu.classOrderPriority = classOrderPriority;
         mouseChildren = true;
         tabChildren = true;
         this.qualityLabelStrings = {
            "highres":param1.getMessage(WatchMessages.ORIGINAL),
            "hd1080":"1080p",
            "hd720":"720p",
            "large":"480p",
            "medium":"360p",
            "small":"240p",
            "light":"240p Light",
            "tiny":"144p",
            "auto":param1.getMessage(WatchMessages.AUTO)
         };
         this.speedLabelStrings = {
            "0.25":"0.25x",
            "0.5":"0.5x",
            "1":param1.getMessage(WatchMessages.NORMAL_SPEED),
            "2":"2.0x",
            "3":"3.0x"
         };
         this.button.labels = {
            "normal":Theme.newButton(GearIcon),
            "active":Theme.newActiveButton(GearIcon)
         };
         this.spinButton.labels = {
            "normal":Theme.newButton(GearSpinIcon),
            "active":Theme.newActiveButton(GearSpinIcon)
         };
         this.button.setLabel("normal");
         this.spinButton.setLabel("normal");
         this.gearHeight = new GearIcon().height;
         labels = {
            "normal":this.button,
            "spin":this.spinButton
         };
         this.build();
         setLabel("normal");
         this.setQualityLabel("medium");
         this.setSpeedLabel("1");
         tooltipMessage = WatchMessages.CHANGE_QUALITY;
         param1.addEventListener(MessageEvent.UPDATE,this.onLabelsMessageUpdate);
         this.hdIcon.mouseEnabled = false;
         this.hdIcon.x = nominalWidth;
      }
      
      protected function bullet(param1:String) : void
      {
         var _loc2_:MenuItem = null;
         for each(_loc2_ in this.menuItems)
         {
            _loc2_.showBullet = _loc2_ == this.menuItems[param1];
         }
      }
      
      override protected function getStateKey(param1:Object) : String
      {
         return contains(this.menu) ? "over" : super.getStateKey(param1);
      }
      
      public function setSpeed(param1:Number) : void
      {
         this.setSpeedLabel(String(param1));
      }
      
      protected function speedClickHandler(param1:EventDispatcher, param2:String) : Function
      {
         var dispatcher:EventDispatcher = param1;
         var label:String = param2;
         return function(param1:MouseEvent):void
         {
            dispatcher.dispatchEvent(new PlaybackRateEvent(PlaybackRateEvent.RATE_CHANGE,parseFloat(label)));
            param1.stopPropagation();
            setSpeedLabel(label);
            hideMenu();
            setState(stateValue.onRollOut());
         };
      }
      
      override public function onMessageUpdate(param1:MessageEvent = null) : void
      {
         super.onMessageUpdate(param1);
         if(contents is TextField)
         {
            accessibleName = TextField(contents).text + " " + messages.getMessage(WatchMessages.QUALITY);
         }
      }
      
      protected function onLabelsMessageUpdate(param1:MessageEvent) : void
      {
         this.qualityLabelStrings["highres"] = param1.messages.getMessage(WatchMessages.ORIGINAL);
         this.menuItems["highres"].labels["default"] = this.qualityLabelStrings["highres"];
         this.qualityLabelStrings["auto"] = param1.messages.getMessage(WatchMessages.AUTO);
         this.menuItems["auto"].labels["default"] = this.qualityLabelStrings["auto"];
         this.menuItems["auto"].dispatchEvent(new Event(Event.RESIZE));
         this.speedLabelStrings["1"] = param1.messages.getMessage(WatchMessages.NORMAL_SPEED);
         this.speedMenuItems["1"].labels["default"] = this.speedLabelStrings["1"];
         this.title.text = messages.getMessage(WatchMessages.QUALITY_TITLE);
         this.speedTitle.text = messages.getMessage(WatchMessages.SPEED_TITLE);
         this.buildSlowBubble();
         setLabel(getLabel());
      }
      
      public function addSpeeds(param1:Array) : void
      {
         var _loc2_:Number = NaN;
         for each(_loc2_ in param1)
         {
            this.speedMenu.add(this.speedMenuItems[String(_loc2_)]);
         }
         this.numSpeedMenuItems = param1.length;
      }
      
      protected function clickHandler(param1:EventDispatcher, param2:String) : Function
      {
         var dispatcher:EventDispatcher = param1;
         var label:String = param2;
         return function(param1:MouseEvent):void
         {
            if(!param1.target.enabled)
            {
               return;
            }
            dispatcher.dispatchEvent(new QualityChangeEvent(QualityChangeEvent.CHANGE,new VideoQuality(label)));
            param1.stopPropagation();
            setQualityLabel(label);
            if(showBubble && (label == "tiny" || label == "small" || label == "medium"))
            {
               return;
            }
            hideMenu();
            setState(stateValue.onRollOut());
         };
      }
      
      protected function onToggleChange(param1:Event) : void
      {
         this.neverPlayHighQuality = CheckButton(param1.currentTarget).checked;
         dispatchEvent(new QualityChangeEvent(QualityChangeEvent.SETTINGS_CHANGE,this.neverPlayHighQuality ? VideoQuality.MEDIUM : VideoQuality.AUTO));
         param1.stopImmediatePropagation();
      }
      
      protected function highlight(param1:String) : void
      {
         var _loc2_:MenuItem = null;
         for each(_loc2_ in this.menuItems)
         {
            _loc2_.selected = _loc2_ == this.menuItems[param1];
         }
      }
      
      public function setAuto(param1:Boolean) : void
      {
         if(param1)
         {
            this.highlight("auto");
            if(this.menu.contains(this.slowBubble))
            {
               this.menu.removeChild(this.slowBubble);
            }
         }
      }
      
      override protected function onAddedToStage(param1:Event) : void
      {
         super.onAddedToStage(param1);
         stageAmbassador.addEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown);
      }
      
      override protected function alignContents() : void
      {
         super.alignContents();
         var _loc1_:int = 0;
         while(_loc1_ < elementContainer.numChildren)
         {
            elementContainer.getChildAt(_loc1_).y = Math.round((nominalHeight - this.gearHeight) / 2);
            _loc1_++;
         }
      }
      
      public function hideMenu() : void
      {
         if(contains(this.menu))
         {
            removeChild(this.menu);
            tooltipMessage = WatchMessages.CHANGE_QUALITY;
            redraw();
         }
         if(contains(this.speedMenu))
         {
            removeChild(this.speedMenu);
         }
         this.button.setLabel("normal");
         this.spinButton.setLabel("normal");
      }
      
      public function add(... rest) : void
      {
         var args:Array = rest;
         this.menu.add.apply(null,args.map(function(param1:*, param2:int, param3:Array):*
         {
            return menuItems[param1];
         }));
         args.forEach(function(param1:*, param2:int, param3:Array):void
         {
            menuItems[param1].enabled = true;
         });
      }
      
      protected function onStageMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         if(_loc2_ != this && !contains(_loc2_))
         {
            this.hideMenu();
         }
      }
      
      override protected function createBackground() : void
      {
         backgrounds = {
            "up":Theme.getClass("LiteBgUp"),
            "over":Theme.getClass("LiteBgOver"),
            "down":Theme.getClass("LiteBgDown")
         };
      }
      
      public function clear() : void
      {
         var _loc1_:MenuItem = null;
         for each(_loc1_ in this.menuItems)
         {
            this.menu.remove(_loc1_);
         }
         for each(_loc1_ in this.speedMenuItems)
         {
            this.speedMenu.remove(_loc1_);
         }
      }
      
      public function setQualityLabel(param1:String, param2:Boolean = true) : void
      {
         var _loc3_:MenuItem = null;
         this.highlight(param1);
         if(param1 != "auto")
         {
            this.bullet(param1);
         }
         this.hdIcon.visible = param1.indexOf("hd") == 0;
         if(this.showBubble && (param1 == "tiny" || param1 == "small" || param1 == "medium"))
         {
            _loc3_ = this.menuItems[param1];
            this.menu.addChild(this.slowBubble);
            this.slowBubble.x = _loc3_.x + 2;
            this.slowBubble.y = this.menu.height - this.slowBubble.height / 2 + Theme.getConstant("POPUP_MENU_BORDER");
         }
         else if(this.menu.contains(this.slowBubble))
         {
            this.menu.removeChild(this.slowBubble);
         }
         if(messages)
         {
            this.onMessageUpdate();
         }
      }
      
      public function showLoaded() : void
      {
         setLabel("normal");
      }
      
      override public function onClick(param1:MouseEvent) : void
      {
         super.onClick(param1);
         if(!enabled)
         {
            return;
         }
         var _loc2_:Boolean = contains(this.menu);
         if(_loc2_)
         {
            this.hideMenu();
         }
         else
         {
            this.showMenu();
         }
      }
      
      protected function build() : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:MenuItem = null;
         this.slowBubble.useHandCursor = false;
         var _loc1_:Shape = new Shape();
         Drawing.invisibleRect(_loc1_.graphics,0,0,1,4);
         var _loc2_:TextFormat = this.title.defaultTextFormat;
         _loc2_.leftMargin = 20;
         _loc2_.rightMargin = 20;
         this.title.defaultTextFormat = _loc2_;
         this.title.mouseEnabled = false;
         this.titleContainer.useHandCursor = false;
         this.titleContainer.addChild(this.title);
         this.speedTitle.defaultTextFormat = _loc2_;
         this.speedTitle.mouseEnabled = false;
         this.speedTitleContainer.useHandCursor = false;
         this.speedTitleContainer.addChild(this.speedTitle);
         this.buildSlowBubble();
         for(_loc3_ in this.qualityLabelStrings)
         {
            _loc4_ = [this.qualityLabelStrings[_loc3_],new HdDecorator()];
            _loc4_[1].visible = _loc3_.indexOf("hd") == 0;
            _loc5_ = new MenuItem(_loc4_,MenuItem.Bullet,TextFormatAlign.LEFT,false);
            _loc5_.addEventListener(MouseEvent.CLICK,this.clickHandler(this,_loc3_));
            this.menuItems[_loc3_] = _loc5_;
         }
         for(_loc3_ in this.speedLabelStrings)
         {
            _loc5_ = new MenuItem(this.speedLabelStrings[_loc3_],MenuItem.Bullet);
            _loc5_.addEventListener(MouseEvent.CLICK,this.speedClickHandler(this,_loc3_));
            this.speedMenuItems[_loc3_] = _loc5_;
         }
         this.menu.order(this.titleContainer,this.menuItems["highres"],this.menuItems["hd1080"],this.menuItems["hd720"],this.menuItems["large"],this.menuItems["medium"],this.menuItems["small"],this.menuItems["tiny"],this.menuItems["auto"],_loc1_);
         this.menu.add(_loc1_,this.titleContainer);
         this.speedMenu.order(this.speedTitleContainer,this.speedMenuItems["0.25"],this.speedMenuItems["0.5"],this.speedMenuItems["1"],this.speedMenuItems["2"],this.speedMenuItems["3"]);
         this.speedMenu.add(this.speedTitleContainer);
         addChild(this.hdIcon);
      }
      
      protected function setSpeedLabel(param1:String) : void
      {
         var _loc2_:MenuItem = null;
         for each(_loc2_ in this.speedMenuItems)
         {
            _loc2_.selected = _loc2_ == this.speedMenuItems[param1];
         }
      }
      
      override protected function onRemovedFromStage(param1:Event) : void
      {
         super.onRemovedFromStage(param1);
         stageAmbassador.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown);
      }
      
      public function disableQuality(param1:String) : void
      {
         this.menuItems[param1].enabled = false;
      }
      
      protected function buildSlowBubble() : void
      {
         var _loc1_:TextField = null;
         while(this.slowBubble.numChildren)
         {
            this.slowBubble.removeChildAt(0);
         }
         _loc1_ = Theme.newTextField();
         _loc1_.text = messages.getMessage(WatchMessages.SLOW_CONNECTION);
         var _loc2_:CheckButton = new CheckButton();
         _loc2_.text = messages.getMessage(WatchMessages.NEVER_PLAY_HIGH);
         _loc2_.width = _loc1_.width + 10;
         if(this.neverPlayHighQuality)
         {
            _loc2_.checked = true;
         }
         var _loc3_:int = _loc1_.height + _loc2_.height;
         var _loc4_:int = _loc1_.width + 20;
         _loc1_.y = -_loc3_ / 2;
         _loc2_.y = _loc1_.y + _loc1_.height + 5;
         _loc1_.x = -_loc4_;
         _loc2_.x = _loc1_.x;
         this.slowBubble.addChild(_loc1_);
         this.slowBubble.addChild(_loc2_);
         var _loc5_:int = -_loc4_ - ARROW_SIZE * 2;
         var _loc6_:int = -_loc3_ / 2 - ARROW_SIZE;
         var _loc7_:Number = Theme.getConstant("POPUP_MENU_BORDER");
         _loc4_ += ARROW_SIZE;
         _loc3_ += ARROW_SIZE * 2;
         drawing(this.slowBubble.graphics).clear().fill(0,0).rect(_loc5_ - _loc7_,_loc6_ - _loc7_,_loc4_ + _loc7_ * 2,_loc3_ + _loc7_ * 2).fill(Theme.getConstant("POPUP_MENU_COLOR"),Theme.getConstant("POPUP_MENU_ALPHA")).rect(_loc5_,_loc6_,_loc4_,_loc3_);
         _loc2_.addEventListener(MouseEvent.CLICK,this.onToggleChange);
         this.slowBubble.addChild(_loc2_);
      }
      
      protected function showMenu() : void
      {
         var _loc1_:MenuItem = null;
         var _loc2_:Rectangle = null;
         if(!contains(this.menu))
         {
            addChild(this.menu);
            _loc2_ = this.menu.container.getBounds(this.menu);
            if(this.numSpeedMenuItems > 1)
            {
               addChild(this.speedMenu);
               _loc2_ = _loc2_.union(this.speedMenu.container.getBounds(this.speedMenu));
            }
            this.menu.x = (nominalWidth - _loc2_.width) / 2;
            this.menu.y = -_loc2_.bottom - Theme.getConstant("POPUP_MENU_BORDER");
            this.menu.height = _loc2_.height;
            this.speedMenu.x = (nominalWidth - _loc2_.width) / 2 + this.menu.width;
            this.speedMenu.y = -_loc2_.bottom - Theme.getConstant("POPUP_MENU_BORDER");
            this.speedMenu.height = _loc2_.height;
            tooltipText = null;
            redraw();
         }
         for each(_loc1_ in this.menuItems)
         {
            if(_loc1_.selected)
            {
               this.slowBubble.x = _loc1_.x + 2;
               this.slowBubble.y = this.menu.height - this.slowBubble.height / 2 + Theme.getConstant("POPUP_MENU_BORDER");
               break;
            }
         }
         this.button.setLabel("active");
         this.spinButton.setLabel("active");
      }
      
      public function showLoading() : void
      {
         setLabel("spin");
      }
   }
}

