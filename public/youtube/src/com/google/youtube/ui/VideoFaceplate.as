package com.google.youtube.ui
{
   import com.google.ui.LineStyle;
   import com.google.utils.StringUtils;
   import com.google.youtube.event.TweenEvent;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.util.getDefinition;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class VideoFaceplate extends UIElement
   {
      
      public static const PLUSONE_DISPLAYED_EVENT:String = "PLUSONE_DISPLAYED_EVENT";
      
      public static const PLUSONE_ADDED_EVENT:String = "PLUSONE_ADDED_EVENT";
      
      public static const PLUSONE_REMOVED_EVENT:String = "PLUSONE_REMOVED_EVENT";
      
      private static const PROGRESS_BAR_HEIGHT:int = 5;
      
      private static const RTZ_TIME:String = "0:00";
      
      private static const SLOT_ICON_RADIUS:int = 3;
      
      private static const SLOT_ICON_SIZE:int = 9;
      
      private static const SLOT_ICON_SPACING:int = 6;
      
      private static const STATUS_BAR_HEIGHT:int = 19;
      
      private static const PLUSONE_INLINE_ANNOTATION_WIDTH:int = 300;
      
      protected var plusOneAnnotationExperiment:Boolean;
      
      protected var currentAdSlot:int = 0;
      
      protected var videoIdValue:String;
      
      protected var statusBarFormat:TextFormat = Theme.newTextFormat();
      
      protected var shadow:DropShadowFilter;
      
      protected var slotIconHolder:Sprite;
      
      protected var progressBar:ProgressBar;
      
      protected var closeXButton:CloseButton;
      
      protected var timeDisplay:TextField;
      
      protected var statusBar:Sprite;
      
      protected var closeButton:SimpleTextButton;
      
      protected var closeableValue:Boolean;
      
      protected var messages:IMessages;
      
      protected var language:String;
      
      protected var numAdSlots:int;
      
      protected var plusOneContainer:Sprite;
      
      protected var adText:TextField;
      
      public function VideoFaceplate(param1:IMessages, param2:int = 1, param3:String = "en", param4:Boolean = false)
      {
         this.messages = param1;
         this.numAdSlots = param2;
         this.language = StringUtils.isNullOrEmpty(param3) ? param3 : "en";
         this.plusOneAnnotationExperiment = param4;
         this.statusBarFormat.align = TextFormatAlign.CENTER;
         alpha = 0;
         super();
         this.build();
         horizontalStretch = 1;
         verticalStretch = 1;
         horizontalRegistration = 0;
         verticalRegistration = 0;
      }
      
      protected function plusOneButtonReadyHandler(param1:Object) : void
      {
         if(param1.isSignedUp)
         {
            this.repositionPlusOneButton();
            this.plusOneContainer.visible = true;
            dispatchEvent(new Event(PLUSONE_DISPLAYED_EVENT,true));
         }
      }
      
      public function showCloseButton(param1:String = "") : void
      {
         this.destroyCloseButton();
         this.closeableValue = true;
         this.buildCloseButton(param1);
      }
      
      public function updateProgress(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
         if(!isNaN(param1) && param1 >= 0 && !isNaN(param2) && param2 >= 0 && param1 <= param2)
         {
            _loc3_ = Math.ceil(param2 - param1);
            _loc4_ = StringUtils.formatTime(_loc3_ * 1000,true);
            this.timeDisplay.text = _loc4_;
            this.progressBar.percent = Math.round(param1 / param2 * 100);
         }
      }
      
      public function resetProgress() : void
      {
         this.updateProgress(0,0);
      }
      
      protected function onDestroy(param1:TweenEvent) : void
      {
         this.destroyCloseButton();
         tween.removeEventListener(TweenEvent.END,this.onDestroy);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function set adString(param1:String) : void
      {
         this.adText.text = param1;
      }
      
      protected function createPlusOneButton(param1:String) : void
      {
         var _loc2_:Class = getDefinition("com.google.apps.plusone.widget.external.PlusOneButton");
         var _loc3_:Class = getDefinition("com.google.apps.plusone.widget.external.PlusOneButtonConfig");
         var _loc4_:Class = getDefinition("com.google.apps.plusone.widget.external.WidgetEvent");
         var _loc5_:String = "http://www.youtube.com/watch?v=" + param1;
         var _loc6_:String = this.plusOneAnnotationExperiment ? _loc3_.INLINE_ANNOTATION : _loc3_.BUBBLE_ANNOTATION;
         var _loc7_:DisplayObject = new _loc2_(new _loc3_(_loc5_,_loc3_.SIZE_SMALL,true,this.language,_loc6_,PLUSONE_INLINE_ANNOTATION_WIDTH));
         this.plusOneContainer.addChild(_loc7_);
         _loc7_.addEventListener(_loc4_.BUTTON_READY,this.plusOneButtonReadyHandler);
         _loc7_.addEventListener(_loc4_.PLUSONE_ADDED,this.plusOneAddedHandler);
         _loc7_.addEventListener(_loc4_.PLUSONE_REMOVED,this.plusOneRemovedHandler);
      }
      
      protected function handleCloseButtonClick(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      public function hideCloseButton() : void
      {
         this.destroyCloseButton();
         this.closeableValue = false;
      }
      
      protected function plusOneAddedHandler(param1:Object) : void
      {
         dispatchEvent(new Event(PLUSONE_ADDED_EVENT,true));
      }
      
      protected function repositionPlusOneButton() : void
      {
         var _loc1_:uint = this.plusOneContainer.height;
         this.plusOneContainer.x = this.adText.x + this.adText.width + SLOT_ICON_SPACING;
         this.plusOneContainer.y = y - PROGRESS_BAR_HEIGHT + Math.floor(nominalHeight - STATUS_BAR_HEIGHT / 2 - _loc1_ / 2) + 1;
      }
      
      public function get closeable() : Boolean
      {
         return this.closeableValue;
      }
      
      protected function plusOneRemovedHandler(param1:Object) : void
      {
         dispatchEvent(new Event(PLUSONE_REMOVED_EVENT,true));
      }
      
      public function incrementCurrentAdSlot() : void
      {
         ++this.currentAdSlot;
         this.redraw();
      }
      
      protected function build() : void
      {
         var _loc1_:LineStyle = new LineStyle(1,6710886,1);
         this.progressBar = new ProgressBar(this.messages,[13421772,14869218],_loc1_,[16772219,14590981],_loc1_);
         this.progressBar.mouseEnabled = false;
         this.statusBar = new Sprite();
         this.statusBar.mouseEnabled = false;
         this.timeDisplay = Theme.newTextField(this.statusBarFormat);
         this.timeDisplay.autoSize = TextFieldAutoSize.RIGHT;
         this.adText = Theme.newTextField(this.statusBarFormat);
         this.shadow = Theme.newDropShadow();
         this.timeDisplay.filters = [this.shadow];
         this.adText.filters = [this.shadow];
         this.plusOneContainer = new Sprite();
         this.plusOneContainer.visible = false;
         this.timeDisplay.text = RTZ_TIME;
         this.slotIconHolder = new Sprite();
         this.statusBar.addChild(this.timeDisplay);
         this.statusBar.addChild(this.adText);
         this.statusBar.addChild(this.slotIconHolder);
         this.statusBar.addChild(this.plusOneContainer);
         addChild(this.progressBar);
         addChild(this.statusBar);
      }
      
      private function destroyCloseButton() : void
      {
         if(this.closeButton)
         {
            this.closeButton.removeEventListener(MouseEvent.CLICK,this.handleCloseButtonClick);
            this.statusBar.removeChild(this.closeButton);
            this.closeButton = null;
         }
         if(this.closeXButton)
         {
            this.closeXButton.removeEventListener(MouseEvent.CLICK,this.handleCloseButtonClick);
            removeChild(this.closeXButton);
            this.closeXButton = null;
         }
      }
      
      public function set videoId(param1:String) : void
      {
         var videoId:String = param1;
         if(this.videoIdValue == videoId)
         {
            return;
         }
         this.videoIdValue = videoId;
         if(!StringUtils.isNullOrEmpty(videoId))
         {
            try
            {
               this.createPlusOneButton(videoId);
            }
            catch(error:Error)
            {
            }
         }
      }
      
      override protected function redraw() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         this.progressBar.setPosition(x,y + nominalHeight - PROGRESS_BAR_HEIGHT);
         this.progressBar.setSize(nominalWidth,PROGRESS_BAR_HEIGHT);
         drawing(this.statusBar.graphics).clear().fill(0,0.75).rect(x,y + nominalHeight - STATUS_BAR_HEIGHT - PROGRESS_BAR_HEIGHT,nominalWidth,STATUS_BAR_HEIGHT).end();
         this.adText.x = x + SLOT_ICON_SPACING;
         this.adText.y = y - PROGRESS_BAR_HEIGHT + Math.floor(nominalHeight - STATUS_BAR_HEIGHT / 2 - this.adText.height / 2);
         this.timeDisplay.x = x + nominalWidth - this.timeDisplay.width - SLOT_ICON_SPACING;
         this.timeDisplay.y = y - PROGRESS_BAR_HEIGHT + Math.floor(nominalHeight - STATUS_BAR_HEIGHT / 2 - this.timeDisplay.height / 2);
         this.slotIconHolder.graphics.clear();
         this.slotIconHolder.x = this.adText.x + this.adText.width + SLOT_ICON_SPACING;
         this.slotIconHolder.y = y - PROGRESS_BAR_HEIGHT + Math.floor(nominalHeight - STATUS_BAR_HEIGHT / 2 - SLOT_ICON_SIZE / 2);
         if(this.numAdSlots > 1)
         {
            _loc1_ = 0;
            while(_loc1_ < this.numAdSlots)
            {
               _loc2_ = _loc1_ != this.currentAdSlot ? 6710886 : 14590981;
               _loc3_ = _loc1_ != 0 ? SLOT_ICON_SIZE : 0;
               this.slotIconHolder.graphics.beginFill(_loc2_,100);
               this.slotIconHolder.graphics.drawRoundRect((SLOT_ICON_SIZE + SLOT_ICON_SPACING) * _loc1_,0,SLOT_ICON_SIZE,SLOT_ICON_SIZE,SLOT_ICON_RADIUS,SLOT_ICON_RADIUS);
               this.slotIconHolder.graphics.endFill();
               _loc1_++;
            }
         }
         if(this.closeable)
         {
            this.closeButton.x = Math.floor(nominalWidth - this.closeButton.width) / 2;
            this.closeButton.y = y - PROGRESS_BAR_HEIGHT + Math.floor(nominalHeight - STATUS_BAR_HEIGHT / 2 - this.closeButton.height / 2);
            this.closeXButton.x = nominalWidth - this.closeXButton.width - SLOT_ICON_SPACING;
            this.closeXButton.y = y + SLOT_ICON_SPACING;
         }
         this.repositionPlusOneButton();
      }
      
      public function destroy() : void
      {
         tween.fadeOut();
         tween.addEventListener(TweenEvent.END,this.onDestroy);
      }
      
      private function buildCloseButton(param1:String) : void
      {
         this.closeButton = new SimpleTextButton(param1,this.statusBarFormat,[this.shadow]);
         this.closeButton.addEventListener(MouseEvent.CLICK,this.handleCloseButtonClick);
         this.statusBar.addChild(this.closeButton);
         this.closeXButton = new CloseButton(this.messages,param1,this.statusBarFormat);
         this.closeXButton.addEventListener(MouseEvent.CLICK,this.handleCloseButtonClick);
         this.closeXButton.setSize(30,30);
         this.closeXButton.filters = [this.shadow];
         addChild(this.closeXButton);
         this.redraw();
      }
      
      public function show() : void
      {
         tween.fadeIn();
      }
   }
}

