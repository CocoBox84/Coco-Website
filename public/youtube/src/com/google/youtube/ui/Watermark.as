package com.google.youtube.ui
{
   import com.google.utils.SafeLoader;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.WatchMessages;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.net.URLRequest;
   
   public class Watermark extends UIElement
   {
      
      protected var messages:IMessages;
      
      protected var watermarkAsset:DisplayObject;
      
      public function Watermark(param1:IMessages)
      {
         super();
         horizontalRegistrationValue = 1;
         verticalRegistrationValue = 1;
         horizontalMarginValue = -8;
         verticalMarginValue = -8;
         buttonMode = true;
         background.mouseEnabled = true;
         tabEnabled = false;
         this.messages = param1;
         param1.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
      }
      
      protected function onMessageUpdate(param1:MessageEvent = null) : void
      {
         this.messages.getMessage(WatchMessages.WATERMARK);
         tooltipText = this.watermarkAsset is DefaultWatermark ? this.messages.getMessage(WatchMessages.URL_NAVIGATE) : "";
      }
      
      override protected function onStateChanged() : void
      {
         if(!this.watermarkAsset)
         {
            return;
         }
         if(stateValue is IRollOverState)
         {
            this.watermarkAsset.alpha = 0.8;
            filters = [new GlowFilter(0,0.25,4,4,2,2)];
            this.showTooltip(false);
         }
         else
         {
            this.watermarkAsset.alpha = 0.6;
            filters = [];
            hideTooltip();
         }
      }
      
      protected function align() : void
      {
         this.watermarkAsset.x = -this.watermarkAsset.width;
         this.watermarkAsset.y = -this.watermarkAsset.height;
         Drawing.invisibleRect(background.graphics,this.watermarkAsset.x,this.watermarkAsset.y,this.watermarkAsset.width,this.watermarkAsset.height);
      }
      
      override public function showTooltip(param1:Boolean = true) : void
      {
         super.showTooltip(param1);
         if(tooltip)
         {
            tooltip.alignWith(this,new Point(this.watermarkAsset.x / 2,this.watermarkAsset.y));
         }
      }
      
      public function setWatermark(param1:*) : void
      {
         var request:URLRequest = null;
         var asset:* = param1;
         if(this.watermarkAsset is Loader && Loader(this.watermarkAsset).contentLoaderInfo.url == asset)
         {
            return;
         }
         if(asset is Class && this.watermarkAsset is asset)
         {
            return;
         }
         this.clearWatermark();
         if(asset is Class)
         {
            this.watermarkAsset = new asset();
            addChild(this.watermarkAsset);
            this.align();
         }
         else
         {
            this.watermarkAsset = new SafeLoader();
            Loader(this.watermarkAsset).contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaderComplete);
            Loader(this.watermarkAsset).contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoaderError);
            Loader(this.watermarkAsset).contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoaderError);
            request = new URLRequest(asset);
            try
            {
               Loader(this.watermarkAsset).load(request);
               addChild(this.watermarkAsset);
            }
            catch(e:SecurityError)
            {
               onLoaderError(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR,false,false,e.message));
            }
         }
         this.watermarkAsset.alpha = 0.6;
         this.onMessageUpdate();
      }
      
      protected function resetScale() : void
      {
         var _loc1_:Number = Theme.getScaleFactor(x,y);
         scaleX = _loc1_;
         scaleY = _loc1_;
      }
      
      protected function onLoaderComplete(param1:Event) : void
      {
         this.align();
      }
      
      public function getWatermark() : DisplayObject
      {
         return this.watermarkAsset;
      }
      
      override public function set x(param1:Number) : void
      {
         super.x = param1;
         this.resetScale();
      }
      
      public function hide() : void
      {
         hideTooltip();
         tween.fadeOut();
      }
      
      override public function set y(param1:Number) : void
      {
         super.y = param1;
         this.resetScale();
      }
      
      protected function onLoaderError(param1:ErrorEvent) : void
      {
         if(contains(this.watermarkAsset))
         {
            removeChild(this.watermarkAsset);
         }
      }
      
      public function clearWatermark() : void
      {
         if(this.watermarkAsset)
         {
            if(contains(this.watermarkAsset))
            {
               removeChild(this.watermarkAsset);
            }
            if(this.watermarkAsset is Loader)
            {
               Loader(this.watermarkAsset).contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoaderComplete);
               Loader(this.watermarkAsset).contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoaderError);
               Loader(this.watermarkAsset).contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoaderError);
            }
            this.watermarkAsset = null;
            background.graphics.clear();
         }
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         mouseEnabled = enabled;
         buttonMode = enabled;
         if(param1)
         {
            this.show();
         }
         else
         {
            this.hide();
         }
      }
      
      public function show() : void
      {
         tween.fadeIn();
      }
   }
}

