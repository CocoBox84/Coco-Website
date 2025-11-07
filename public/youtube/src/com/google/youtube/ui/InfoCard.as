package com.google.youtube.ui
{
   import com.google.utils.RequestLoader;
   import com.google.youtube.event.ActionBarEvent;
   import com.google.youtube.event.SubscriptionEvent;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.model.YouTubeEnvironment;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class InfoCard extends UIElement
   {
      
      protected static const LIKE_PANEL_WIDTH:Number = 165;
      
      protected var metadataRequestValue:URLRequest = new URLRequest();
      
      protected var container:Sprite = new Sprite();
      
      protected var subscribersTextField:TextField = Theme.newTextField();
      
      protected var subscriberCount:String;
      
      protected var metadataLoaded:Boolean;
      
      protected var authorImage:VideoStill = new VideoStill();
      
      protected var spinner:AnimatedElement = new AnimatedElement(new MiniSpinner());
      
      protected var subscribeButton:SubscribeButton;
      
      protected var authorButton:Button;
      
      protected var errorTextField:TextField;
      
      protected var videoDataValue:VideoData;
      
      protected var descriptionTextField:TextField = Theme.newTextField(Theme.newTextFormat(Theme.H5_TEXT_SIZE));
      
      protected var uiCreated:Boolean;
      
      protected var authorPanel:Sprite = new Sprite();
      
      protected var messages:IMessages;
      
      protected var authorText:TextField = Theme.newTextField(Theme.newTextFormat(Theme.H4_TEXT_SIZE));
      
      protected var viewCount:String;
      
      protected var descriptionPanel:Sprite = new Sprite();
      
      protected var loadingTextField:TextField;
      
      protected var likeTextField:TextField = Theme.newTextField();
      
      protected var likeBar:Sprite = new Sprite();
      
      protected var viewsTextField:TextField = Theme.newTextField();
      
      public function InfoCard(param1:IMessages)
      {
         this.authorButton = new Button(this.authorText);
         super();
         this.messages = param1;
         horizontalStretch = 1;
         verticalStretch = 1;
         param1.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         super.setSize(param1,param2);
         dispatchEvent(new Event(Event.RESIZE));
      }
      
      protected function createDescriptionPanel() : void
      {
         var fadeOutMask:Sprite = null;
         var fadeOutClickArea:Sprite = null;
         fadeOutMask = new Sprite();
         fadeOutClickArea = new Sprite();
         fadeOutClickArea.buttonMode = true;
         fadeOutClickArea.addEventListener(MouseEvent.CLICK,this.onDescriptionClick);
         this.descriptionTextField.mask = fadeOutMask;
         fadeOutMask.cacheAsBitmap = true;
         this.descriptionTextField.cacheAsBitmap = true;
         addEventListener(Event.RESIZE,function(param1:Event):void
         {
            var _loc2_:Number = width - descriptionPanel.x - 30;
            var _loc3_:Number = height - descriptionPanel.y - 10;
            descriptionTextField.width = _loc2_;
            descriptionTextField.scrollRect = new Rectangle(0,0,_loc2_,_loc3_);
            drawing(fadeOutMask.graphics).clear().fill(0).rect(0,0,_loc2_,_loc3_ - 40).fill([0,0],[1,0],null,90,_loc2_,40,0,_loc3_ - 40).rect(0,_loc3_ - 40,_loc2_,40).end();
            drawing(fadeOutClickArea.graphics).clear().fill(0,0,null,90,_loc2_,40).rect(0,0,_loc2_,40).end();
            fadeOutClickArea.y = _loc3_ - 40;
         });
         this.descriptionTextField.multiline = true;
         this.descriptionTextField.wordWrap = true;
         this.descriptionTextField.selectable = true;
         this.descriptionTextField.mouseEnabled = true;
         this.descriptionPanel.addChild(this.descriptionTextField);
         this.descriptionPanel.addChild(fadeOutClickArea);
         this.descriptionPanel.addChild(fadeOutMask);
      }
      
      public function init() : void
      {
         if(!this.metadataLoaded)
         {
            this.loadMetadata();
         }
      }
      
      protected function onMessageUpdate(param1:MessageEvent) : void
      {
         if(Boolean(this.subscribersTextField) && Boolean(this.subscriberCount))
         {
            this.formatSubscribersTextField();
         }
         if(Boolean(this.viewsTextField) && Boolean(this.viewCount))
         {
            this.formatViewsTextField();
         }
         if(this.loadingTextField)
         {
            this.loadingTextField.text = this.messages.getMessage(WatchMessages.LOADING);
         }
         if(this.errorTextField)
         {
            this.errorTextField.text = this.messages.getMessage(WatchMessages.ERROR_GENERIC);
         }
      }
      
      override protected function drawBackground() : void
      {
         drawSolidBackground(0,0.9);
      }
      
      public function set videoData(param1:VideoData) : void
      {
         if(this.videoDataValue)
         {
            this.videoDataValue.removeEventListener(SubscriptionEvent.SUBSCRIBED,this.onSubscribed);
            this.videoDataValue.removeEventListener(SubscriptionEvent.UNSUBSCRIBED,this.onUnsubscribed);
         }
         this.videoDataValue = param1;
         this.videoDataValue.addEventListener(SubscriptionEvent.SUBSCRIBED,this.onSubscribed);
         this.videoDataValue.addEventListener(SubscriptionEvent.UNSUBSCRIBED,this.onUnsubscribed);
      }
      
      protected function onLoadError(param1:Event) : void
      {
         this.onError();
      }
      
      protected function createAuthorPanel() : void
      {
         this.createAuthorImage();
         var _loc1_:TextFormat = Theme.newTextFormat(Theme.H4_TEXT_SIZE);
         this.authorButton.addEventListener(MouseEvent.CLICK,this.onAuthorClick);
         this.authorButton.x = this.authorImage.width + 10;
         this.authorButton.y = 10;
         this.subscribersTextField.y = this.authorButton.y + 20;
         this.subscribersTextField.x = this.authorButton.x;
         this.authorPanel.addChild(this.authorImage);
         this.authorPanel.addChild(this.authorButton);
         this.authorPanel.addChild(this.subscribersTextField);
      }
      
      protected function createLikePanel() : DisplayObject
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.addChild(this.likeBar);
         this.likeTextField.y = 7;
         _loc1_.addChild(this.likeTextField);
         return _loc1_;
      }
      
      protected function loadMetadata() : void
      {
         var _loc2_:RequestLoader = null;
         if(Boolean(this.errorTextField) && contains(this.errorTextField))
         {
            removeChild(this.errorTextField);
         }
         var _loc1_:TextFormat = Theme.newTextFormat();
         _loc1_.color = Theme.WHITE;
         this.loadingTextField = Theme.newTextField(_loc1_);
         this.loadingTextField.text = this.messages.getMessage(WatchMessages.LOADING);
         this.loadingTextField.x = 60;
         this.loadingTextField.y = 32;
         addChild(this.loadingTextField);
         this.spinner.x = 40;
         this.spinner.y = 40;
         addChild(this.spinner);
         if(this.metadataRequestValue)
         {
            _loc2_ = new RequestLoader();
            _loc2_.addEventListener(Event.COMPLETE,this.onMetadataLoaded);
            _loc2_.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
            _loc2_.loadRequest(this.metadataRequestValue);
         }
         else
         {
            this.onError();
         }
      }
      
      protected function formatSubscribersTextField() : void
      {
         var _loc3_:TextFormat = null;
         var _loc1_:String = this.messages.getMessage(WatchMessages.SUBSCRIBERS);
         var _loc2_:int = int(_loc1_.indexOf("NUM_SUBSCRIBERS"));
         if(_loc2_ >= 0)
         {
            _loc1_ = _loc1_.replace("NUM_SUBSCRIBERS",this.subscriberCount);
            this.subscribersTextField.text = _loc1_;
            this.subscribersTextField.setTextFormat(Theme.newTextFormat());
            _loc3_ = Theme.newTextFormat(Theme.H5_TEXT_SIZE);
            this.subscribersTextField.setTextFormat(_loc3_,_loc2_,_loc2_ + this.subscriberCount.length);
         }
      }
      
      protected function onSubscribeClick(param1:MouseEvent) : void
      {
         if(this.subscribeButton.subscribed)
         {
            this.videoDataValue.unsubscribe();
         }
         else
         {
            this.videoDataValue.subscribe();
         }
      }
      
      public function set metadataRequest(param1:URLRequest) : void
      {
         if(Boolean(param1) && this.metadataRequestValue.url != param1.url)
         {
            this.metadataRequestValue = param1;
            if(this.metadataLoaded)
            {
               this.metadataLoaded = false;
               this.loadMetadata();
            }
         }
      }
      
      protected function onUnsubscribed(param1:SubscriptionEvent) : void
      {
         if(this.subscribeButton)
         {
            this.subscribeButton.subscribed = false;
         }
      }
      
      protected function onSubscribed(param1:SubscriptionEvent) : void
      {
         if(this.subscribeButton)
         {
            this.subscribeButton.subscribed = true;
         }
      }
      
      protected function createUiElements() : void
      {
         this.createAuthorPanel();
         this.authorPanel.x = 20;
         this.authorPanel.y = 10;
         this.container.addChild(this.authorPanel);
         this.viewsTextField.x = 20;
         this.viewsTextField.y = 70;
         this.container.addChild(this.viewsTextField);
         var _loc1_:DisplayObject = this.createLikePanel();
         _loc1_.x = 20;
         _loc1_.y = 100;
         this.container.addChild(_loc1_);
         this.createDescriptionPanel();
         this.descriptionPanel.x = _loc1_.x + LIKE_PANEL_WIDTH + 30;
         this.descriptionPanel.y = 75;
         this.container.addChild(this.descriptionPanel);
         this.subscribeButton = new SubscribeButton(this.messages);
         this.subscribeButton.addEventListener(MouseEvent.CLICK,this.onSubscribeClick);
         this.subscribeButton.y = 35;
         this.container.addChild(this.subscribeButton);
         dispatchEvent(new Event(Event.RESIZE));
      }
      
      protected function fillMetadata(param1:XML) : void
      {
         var _loc2_:String = param1..video_info..description || "";
         var _loc3_:String = param1..user_info..username || "";
         var _loc4_:String = param1..user_info..external_id || "";
         var _loc5_:String = param1..user_info..public_name || "";
         var _loc6_:String = param1..user_info..image_url || "";
         var _loc7_:int = parseInt(param1..video_info..likes_count_unformatted || "");
         _loc7_ = isNaN(_loc7_) ? 0 : _loc7_;
         var _loc8_:int = parseInt(param1..video_info..dislikes_count_unformatted || "");
         _loc8_ = isNaN(_loc8_) ? 0 : _loc8_;
         var _loc9_:String = param1..video_info..likes_dislikes_string || "";
         this.videoDataValue.subscriptionToken = param1..video_info..subscription_ajax_token || "";
         this.viewCount = param1..video_info..view_count || "";
         this.subscriberCount = param1..user_info..subscriber_count || "";
         if(contains(this.spinner))
         {
            removeChild(this.spinner);
         }
         if(contains(this.loadingTextField))
         {
            removeChild(this.loadingTextField);
         }
         if(this.videoDataValue)
         {
            this.videoDataValue.author = _loc3_;
            this.videoDataValue.externalUserId = _loc4_;
         }
         if(!this.uiCreated)
         {
            this.createUiElements();
            this.uiCreated = true;
         }
         this.descriptionTextField.text = _loc2_;
         this.likeTextField.text = _loc9_;
         this.authorImage.load(_loc6_);
         this.authorText.text = _loc5_;
         this.authorButton.setSize(this.authorText.width,this.authorText.height);
         this.createLikeBar(_loc7_,_loc8_);
         this.formatViewsTextField();
         this.formatSubscribersTextField();
         this.subscribeButton.x = Math.max(this.descriptionPanel.x,this.authorPanel.x + this.authorPanel.width + 10);
         if(!contains(this.container))
         {
            addChild(this.container);
         }
      }
      
      protected function onMetadataLoaded(param1:Event) : void
      {
         var response:XML = null;
         var content:XML = null;
         var event:Event = param1;
         try
         {
            response = XML(event.target.data);
         }
         catch(error:TypeError)
         {
            onError();
         }
         if(Boolean(response.return_code) && Boolean(response.return_code.toString()) && response.return_code.toString() != YouTubeEnvironment.AJAX_SUCCESS)
         {
            this.onError();
         }
         else if(!response.html_content)
         {
            this.onError();
         }
         else
         {
            content = response.html_content[0];
            this.fillMetadata(content);
            this.metadataLoaded = true;
         }
      }
      
      protected function formatViewsTextField() : void
      {
         var _loc3_:TextFormat = null;
         var _loc1_:String = this.messages.getMessage(WatchMessages.INFO_CARD_VIEWS);
         var _loc2_:int = int(_loc1_.indexOf("NUM_VIEWS"));
         if(_loc2_ >= 0 && Boolean(this.viewCount))
         {
            _loc1_ = _loc1_.replace("NUM_VIEWS",this.viewCount);
            this.viewsTextField.text = _loc1_;
            this.viewsTextField.setTextFormat(Theme.newTextFormat());
            _loc3_ = Theme.newTextFormat(Theme.H3_TEXT_SIZE);
            this.viewsTextField.setTextFormat(_loc3_,_loc2_,_loc2_ + this.viewCount.length);
         }
      }
      
      protected function onAuthorClick(param1:MouseEvent) : void
      {
         dispatchEvent(new ActionBarEvent(ActionBarEvent.NAVIGATE_TO_VIDEO_CHANNEL));
      }
      
      protected function createLikeBar(param1:int, param2:int) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc3_:Number = LIKE_PANEL_WIDTH;
         var _loc4_:Number = 4;
         this.likeBar.graphics.clear();
         if(param1 + param2 <= 0)
         {
            drawing(this.likeBar.graphics).stroke(1,Theme.getConstant("HIGHLIGHT_COLOR"),0.25).roundRect(0,0,_loc3_,_loc4_,1).end();
         }
         else
         {
            _loc5_ = param1 / (param1 + param2);
            this.likeBar.graphics.beginFill(419588);
            this.likeBar.graphics.drawRect(0,0,_loc3_ * _loc5_,_loc4_);
            this.likeBar.graphics.endFill();
            _loc6_ = _loc3_ * (1 - _loc5_);
            _loc7_ = _loc3_ - _loc6_;
            this.likeBar.graphics.beginFill(13108480);
            this.likeBar.graphics.drawRect(_loc7_,0,_loc6_,_loc4_);
            this.likeBar.graphics.endFill();
            this.likeBar.graphics.beginFill(16777215);
            this.likeBar.graphics.drawRect(int(_loc7_),0,1,_loc4_);
            this.likeBar.graphics.endFill();
         }
      }
      
      protected function onDescriptionClick(param1:MouseEvent) : void
      {
         dispatchEvent(new ActionBarEvent(ActionBarEvent.NAVIGATE_TO_YOUTUBE));
      }
      
      protected function onError() : void
      {
         if(contains(this.spinner))
         {
            removeChild(this.spinner);
         }
         if(Boolean(this.loadingTextField) && contains(this.loadingTextField))
         {
            removeChild(this.loadingTextField);
         }
         if(contains(this.container))
         {
            removeChild(this.container);
         }
         if(!this.errorTextField)
         {
            this.errorTextField = Theme.newTextField();
            this.errorTextField.x = 32;
            this.errorTextField.y = 32;
            this.errorTextField.text = this.messages.getMessage(WatchMessages.ERROR_GENERIC);
         }
         if(!contains(this.errorTextField))
         {
            addChild(this.errorTextField);
         }
      }
      
      protected function createAuthorImage() : DisplayObject
      {
         this.authorImage.width = 45;
         this.authorImage.height = 45;
         this.authorImage.buttonMode = true;
         this.authorImage.addEventListener(MouseEvent.CLICK,this.onAuthorClick);
         return this.authorImage;
      }
      
      protected function createPadding(param1:Number, param2:Number = 1) : DisplayObject
      {
         var _loc3_:Sprite = new Sprite();
         drawing(_loc3_.graphics).fill(0,0).rect(0,0,param1,param2).end();
         return _loc3_;
      }
   }
}

