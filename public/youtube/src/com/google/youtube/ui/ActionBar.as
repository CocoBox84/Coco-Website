package com.google.youtube.ui
{
   import com.google.youtube.event.ActionBarEvent;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.VideoData;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   
   public class ActionBar extends LayoutStrip
   {
      
      protected static const HEIGHT:Number = 26;
      
      protected static const LIKE_MIN_WIDTH:Number = 420;
      
      protected static const MORE_INFO_MIN_WIDTH:Number = 350;
      
      protected static const UP_STATE_ALPHA:Number = 0.8;
      
      protected var infoButton:Button = new Button();
      
      protected var limitMoreInfoToFullScreen:Boolean;
      
      protected var preventMoreInfo:Boolean;
      
      protected var infoCard:InfoCard;
      
      protected var titleButton:VideoTitleTextButton;
      
      protected var videoDataValue:VideoData;
      
      protected var likeButton:Button = new Button();
      
      protected var shareButton:Button = new Button();
      
      protected var highlight:Highlight = new Highlight();
      
      protected var dislikeButton:Button = new Button();
      
      protected var likeEnabled:Boolean;
      
      public function ActionBar(param1:IMessages, param2:Boolean, param3:Boolean, param4:Boolean, param5:Boolean, param6:Boolean)
      {
         this.likeEnabled = param2;
         this.preventMoreInfo = param5;
         this.limitMoreInfoToFullScreen = param6;
         nominalHeight = HEIGHT;
         super(["primary"],["secondary_like","secondary"]);
         horizontalStretch = 1;
         verticalStretch = 1;
         this.dislikeButton.labels = {
            "default":this.newActionBarButton(DislikeIcon),
            "active":this.newActionBarButton(DislikeIcon),
            "other_active":this.newActionBarDimmedButton(DislikeIcon)
         };
         this.dislikeButton.setLabel("default");
         this.likeButton.labels = {
            "default":this.newActionBarButton(LikeIcon),
            "active":this.newActionBarButton(LikeIcon),
            "other_active":this.newActionBarDimmedButton(LikeIcon)
         };
         this.likeButton.setLabel("default");
         this.shareButton.labels = {
            "default":this.newActionBarButton(ShareIcon),
            "active":this.newActionBarButton(ShareIcon),
            "other_active":this.newActionBarDimmedButton(ShareIcon)
         };
         this.shareButton.setLabel("default");
         this.infoButton.labels = {
            "default":this.newActionBarButton(AboutIcon),
            "active":this.newActionBarButton(AboutIcon),
            "other_active":this.newActionBarDimmedButton(AboutIcon)
         };
         this.infoButton.setLabel("default");
         this.likeButton.addEventListener(MouseEvent.CLICK,this.onEndScreenLike);
         this.addRollOverHandlers(this.likeButton);
         this.dislikeButton.addEventListener(MouseEvent.CLICK,this.onEndScreenDislike);
         this.addRollOverHandlers(this.dislikeButton);
         this.shareButton.addEventListener(MouseEvent.CLICK,this.onEndScreenShare);
         this.addRollOverHandlers(this.shareButton);
         this.shareButton.horizontalMargin = 8;
         this.titleButton = new VideoTitleTextButton(param4);
         this.titleButton.mouseEnabled = !param5;
         if(this.titleButton.mouseEnabled)
         {
            this.titleButton.addEventListener(MouseEvent.CLICK,this.onTitleClick);
         }
         this.infoCard = new InfoCard(param1);
         this.infoCard.y = HEIGHT;
         this.addRollOverHandlers(this.infoButton);
         this.infoButton.addEventListener(MouseEvent.CLICK,this.onMoreInfoClick);
         this.infoButton.horizontalMargin = 3;
         section("primary").add(this.titleButton);
         if(param3)
         {
            section("secondary").add(this.shareButton);
         }
         param1.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
         if(stageAmbassador.addedToStage)
         {
            this.updateButtons();
         }
      }
      
      protected function addRollOverHandlers(param1:LayoutElement) : void
      {
         var button:LayoutElement = param1;
         var handler:Function = function(param1:MouseEvent):void
         {
            if(button.mouseEnabled)
            {
               button.alpha = param1.type == MouseEvent.ROLL_OVER ? 1 : UP_STATE_ALPHA;
            }
         };
         button.addEventListener(MouseEvent.ROLL_OVER,handler);
         button.addEventListener(MouseEvent.ROLL_OUT,handler);
         button.alpha = UP_STATE_ALPHA;
      }
      
      protected function onEndScreenDislike(param1:MouseEvent) : void
      {
         this.likeButton.setLabel("other_active");
         this.likeButton.mouseEnabled = true;
         this.dislikeButton.setLabel("active");
         this.dislikeButton.mouseEnabled = false;
         dispatchEvent(new ActionBarEvent(ActionBarEvent.DISLIKE,this.videoDataValue));
      }
      
      protected function onMoreInfoClick(param1:MouseEvent) : void
      {
         if(contains(this.infoCard))
         {
            this.hideInfoCard();
         }
         else
         {
            this.showInfoCard();
         }
      }
      
      protected function newActionBarButton(param1:Class) : Object
      {
         return {
            "up":Theme.newMaskedIcon(Theme.getConstant("ICON_ACTIVE_OVER_COLORS","dark"),new param1(),null,false),
            "over":Theme.newMaskedIcon(Theme.getConstant("ICON_ACTIVE_OVER_COLORS","dark"),new param1(),null,true)
         };
      }
      
      protected function checkLikeVisibility() : void
      {
         if(this.getContainer("secondary_like"))
         {
            this.getContainer("secondary_like").visible = width >= LIKE_MIN_WIDTH;
         }
      }
      
      public function set videoData(param1:VideoData) : void
      {
         this.videoDataValue = param1;
         this.updateLike();
         if(this.infoCard)
         {
            this.infoCard.videoData = param1;
         }
         this.dislikeButton.setLabel("default");
         this.dislikeButton.mouseEnabled = true;
         this.likeButton.setLabel("default");
         this.likeButton.mouseEnabled = true;
         this.titleButton.text = this.videoDataValue.title;
         this.adjustTitleWidth();
         section("primary").realign();
         layout.realign();
         this.updateButtons();
      }
      
      protected function getContainer(param1:String) : DisplayObjectContainer
      {
         return DisplayObjectContainer(getChildByName(param1));
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         if(this.infoCard)
         {
            this.infoCard.width = param1;
         }
         this.checkLikeVisibility();
         this.checkMoreInfoVisibility();
         this.adjustTitleWidth();
      }
      
      override public function set height(param1:Number) : void
      {
         if(this.infoCard)
         {
            this.infoCard.height = param1 - HEIGHT;
         }
      }
      
      public function hideInfoCard() : void
      {
         if(contains(this.infoCard))
         {
            removeChild(this.infoCard);
         }
         this.infoButton.setLabel("default");
         if(this.infoButton.contains(this.highlight))
         {
            this.infoButton.removeChild(this.highlight);
         }
         this.shareButton.setLabel("default");
         this.redraw();
         dispatchEvent(new ActionBarEvent(ActionBarEvent.COLLAPSE));
      }
      
      protected function onMessageUpdate(param1:MessageEvent = null) : void
      {
         section("secondary").realign();
         this.adjustTitleWidth();
         layout.realign();
      }
      
      public function onTitleClick(param1:MouseEvent) : void
      {
         dispatchEvent(new ActionBarEvent(ActionBarEvent.NAVIGATE_TO_YOUTUBE));
      }
      
      public function set metadataRequest(param1:URLRequest) : void
      {
         this.infoCard.metadataRequest = param1;
      }
      
      override protected function redraw() : void
      {
         super.redraw();
         drawing(graphics).clear().fill(Theme.getConstant("BACKGROUND_GRADIENT_COLORS","dark"),[UP_STATE_ALPHA,UP_STATE_ALPHA],null,90,1,height).rect(0,0,width,height).end();
      }
      
      protected function checkMoreInfoVisibility() : void
      {
         if(this.getContainer("secondary"))
         {
            this.getContainer("secondary").visible = width >= MORE_INFO_MIN_WIDTH;
         }
      }
      
      override protected function drawForeground() : void
      {
      }
      
      override protected function onAddedToStage(param1:Event) : void
      {
         super.onAddedToStage(param1);
         stageAmbassador.addEventListener(FullScreenEvent.FULL_SCREEN,this.updateButtons);
         this.updateButtons();
      }
      
      protected function updateLike() : void
      {
         if(!this.likeEnabled || !this.videoDataValue.watchAjaxToken)
         {
            return;
         }
         if(!contains(this.likeButton))
         {
            section("secondary_like").add(this.likeButton,this.dislikeButton);
         }
         this.checkLikeVisibility();
         this.adjustTitleWidth();
      }
      
      protected function updateButtons(param1:FullScreenEvent = null) : void
      {
         var _loc2_:Boolean = stageAmbassador.isFullScreen() || !this.limitMoreInfoToFullScreen;
         var _loc3_:Boolean = _loc2_ && !this.preventMoreInfo && Boolean(this.videoDataValue) && Boolean(this.videoDataValue.videoId);
         if(_loc3_)
         {
            section("secondary").add(this.infoButton);
         }
         else
         {
            section("secondary").remove(this.infoButton);
            this.hideInfoCard();
         }
         visible = this.titleButton.visible || _loc3_;
      }
      
      protected function newActionBarDimmedButton(param1:Class) : Object
      {
         return {
            "up":Theme.newMaskedIcon(Theme.getConstant("ICON_COLORS","dark"),new param1(),null,false),
            "over":Theme.newMaskedIcon(Theme.getConstant("ICON_ACTIVE_OVER_COLORS","dark"),new param1(),null,true)
         };
      }
      
      protected function showInfoCard() : void
      {
         this.infoCard.init();
         if(!contains(this.infoCard))
         {
            addChild(this.infoCard);
         }
         this.infoButton.setLabel("active");
         this.highlight.width = this.infoButton.width;
         this.highlight.height = 3;
         this.highlight.y = this.infoButton.height - 2;
         this.infoButton.addChild(this.highlight);
         this.shareButton.setLabel("other_active");
         this.redraw();
         dispatchEvent(new ActionBarEvent(ActionBarEvent.EXPAND));
      }
      
      protected function adjustTitleWidth() : void
      {
         var _loc1_:Number = width;
         var _loc2_:DisplayObjectContainer = this.getContainer("secondary_like");
         if(Boolean(_loc2_) && _loc2_.visible)
         {
            _loc1_ = _loc2_.x;
         }
         else
         {
            _loc2_ = this.getContainer("secondary");
            if(_loc2_ && _loc2_.visible && Boolean(_loc2_.width))
            {
               _loc1_ = _loc2_.x;
            }
         }
         this.titleButton.width = _loc1_;
      }
      
      protected function onEndScreenShare(param1:MouseEvent) : void
      {
         dispatchEvent(new ActionBarEvent(ActionBarEvent.SHARE,this.videoDataValue));
      }
      
      protected function onEndScreenLike(param1:MouseEvent) : void
      {
         this.dislikeButton.setLabel("other_active");
         this.dislikeButton.mouseEnabled = true;
         this.likeButton.setLabel("active");
         this.likeButton.mouseEnabled = false;
         dispatchEvent(new ActionBarEvent(ActionBarEvent.LIKE,this.videoDataValue));
      }
   }
}

