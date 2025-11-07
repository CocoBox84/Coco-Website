package com.google.youtube.ui
{
   import com.google.youtube.model.MosaicLoader;
   import com.google.youtube.util.Tween;
   import flash.display.Bitmap;
   import flash.events.Event;
   
   public class VideoStoryboardThumbnail extends LayoutElement
   {
      
      protected var container:Bitmap;
      
      protected var stretchToFill:Boolean;
      
      protected var frameValue:int;
      
      protected var nominalWidth:int = 16;
      
      protected var drawBackground:Boolean;
      
      protected var tweenValue:Tween;
      
      protected var nominalHeight:int = 9;
      
      protected var mosaicLoader:MosaicLoader;
      
      public function VideoStoryboardThumbnail(param1:MosaicLoader, param2:Boolean = false, param3:Boolean = true)
      {
         super();
         this.mosaicLoader = param1;
         this.stretchToFill = param2;
         this.drawBackground = param3;
         this.horizontalStretch = 1;
         this.verticalStretch = 1;
         this.container = new Bitmap();
         addChild(this.container);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      override public function set height(param1:Number) : void
      {
         this.nominalHeight = param1;
         this.redraw();
      }
      
      protected function onMosaicLoaderChange(param1:Event) : void
      {
         this.getFrameFromMosaicLoader();
      }
      
      public function set time(param1:int) : void
      {
         this.frame = this.mosaicLoader.getFrameForTime(param1);
      }
      
      override public function set width(param1:Number) : void
      {
         this.nominalWidth = param1;
         this.redraw();
      }
      
      protected function getFrameFromMosaicLoader() : void
      {
         if(!parent)
         {
            return;
         }
         this.container.bitmapData = this.mosaicLoader.getMosaic(this.frameValue,this.nominalHeight > 180);
         if(this.container.bitmapData)
         {
            this.drawBackground = true;
         }
         this.container.smoothing = true;
         this.container.scrollRect = this.mosaicLoader.getRect(this.frameValue);
         visible = this.container.scrollRect != null;
         this.redraw();
      }
      
      public function set frame(param1:int) : void
      {
         this.frameValue = param1;
         this.getFrameFromMosaicLoader();
      }
      
      protected function onAddedToStage(param1:Event) : void
      {
         this.mosaicLoader.loadLevel();
         this.getFrameFromMosaicLoader();
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.mosaicLoader.addEventListener(Event.CHANGE,this.onMosaicLoaderChange);
      }
      
      override public function get height() : Number
      {
         return this.nominalHeight;
      }
      
      override public function get width() : Number
      {
         return this.nominalWidth;
      }
      
      public function set brightness(param1:Number) : void
      {
         this.container.alpha = param1;
      }
      
      public function get tween() : Tween
      {
         if(!this.tweenValue)
         {
            this.tweenValue = new Tween(this);
         }
         return this.tweenValue;
      }
      
      public function get frame() : int
      {
         return this.frameValue;
      }
      
      protected function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.mosaicLoader.removeEventListener(Event.CHANGE,this.onMosaicLoaderChange);
      }
      
      protected function redraw() : void
      {
         drawing(graphics).clear().fill(0,this.drawBackground ? 1 : 0).rect(0,0,this.nominalWidth,this.nominalHeight);
         if(!this.container.scrollRect)
         {
            return;
         }
         if(!this.stretchToFill)
         {
            this.container.scaleX = Math.min(this.nominalWidth / this.container.scrollRect.width,this.nominalHeight / this.container.scrollRect.height);
            this.container.scaleY = this.container.scaleX;
            this.container.x = (this.nominalWidth - this.container.scrollRect.width * this.container.scaleX) / 2;
            this.container.y = (this.nominalHeight - this.container.scrollRect.height * this.container.scaleY) / 2;
         }
         else
         {
            this.container.x = 0;
            this.container.y = 0;
            this.container.scaleX = this.nominalWidth / this.container.scrollRect.width;
            this.container.scaleY = this.nominalHeight / this.container.scrollRect.height;
         }
      }
   }
}

