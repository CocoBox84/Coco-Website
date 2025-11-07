package com.google.youtube.ui
{
   import com.google.utils.SafeLoader;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.Shape;
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class VideoStill extends LayoutElement implements ILayoutElement
   {
      
      protected static const DEFAULT_WIDTH:Number = 480;
      
      protected static const DEFAULT_HEIGHT:Number = 360;
      
      protected static const FUDGE:Number = 4;
      
      protected var cornerRadius:Number;
      
      protected var nominalWidth:Number = 480;
      
      protected var selection:Shape = new Shape();
      
      protected var defaultBackground:Shape = new Shape();
      
      protected var loader:Loader = new SafeLoader();
      
      protected var maskShape:Shape = new Shape();
      
      protected var spinner:AnimatedElement = new AnimatedElement(new MiniSpinner());
      
      protected var nominalHeight:Number = 360;
      
      protected var url:String;
      
      public function VideoStill(param1:Number = 0)
      {
         this.cornerRadius = param1;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoad);
         this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         super(this.loader);
         horizontalStretch = 1;
         verticalStretch = 1;
         addChild(this.spinner);
         addChild(this.loader);
         addChild(this.maskShape);
         mask = this.maskShape;
         this.redraw();
      }
      
      protected function showDefault() : void
      {
         addChildAt(this.defaultBackground,0);
      }
      
      public function get selected() : Boolean
      {
         return contains(this.selection);
      }
      
      override public function get width() : Number
      {
         return this.nominalWidth;
      }
      
      override public function set width(param1:Number) : void
      {
         this.nominalWidth = param1;
         this.redraw();
      }
      
      override public function set height(param1:Number) : void
      {
         this.nominalHeight = param1;
         this.redraw();
      }
      
      protected function onAddedToStage(param1:Event) : void
      {
         if(contains(this.spinner) && Boolean(this.url))
         {
            this.load(this.url);
         }
      }
      
      protected function onLoad(param1:Event) : void
      {
         var bmp:Bitmap = null;
         var event:Event = param1;
         try
         {
            bmp = event.target.loader.content as Bitmap;
            if(bmp)
            {
               bmp.smoothing = true;
            }
         }
         catch(e:SecurityError)
         {
         }
         this.removeSpinner();
         this.redraw();
      }
      
      override public function get height() : Number
      {
         return this.nominalHeight;
      }
      
      protected function closeLoader() : void
      {
         try
         {
            this.loader.close();
         }
         catch(error:IOError)
         {
         }
      }
      
      public function load(param1:String) : void
      {
         var _loc2_:LoaderContext = null;
         if(!param1)
         {
            this.showDefault();
            return;
         }
         if(contains(this.defaultBackground))
         {
            removeChild(this.defaultBackground);
         }
         if(contains(this.spinner) || this.url != param1)
         {
            this.closeLoader();
            this.url = param1;
            addChild(this.spinner);
            _loc2_ = new LoaderContext();
            _loc2_.checkPolicyFile = true;
            this.loader.load(new URLRequest(param1),_loc2_);
         }
      }
      
      private function removeSpinner() : void
      {
         if(contains(this.spinner))
         {
            removeChild(this.spinner);
         }
      }
      
      protected function redraw() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:int = 0;
         if(this.selected)
         {
            _loc1_ = 1;
         }
         drawing(this.maskShape.graphics).clear().fill(0).roundRect(-_loc1_,-_loc1_,this.nominalWidth + _loc1_ * 2,this.nominalHeight + _loc1_ * 2,this.cornerRadius).end();
         drawing(this.defaultBackground.graphics).clear().fill(0).rect(0,0,this.nominalWidth,this.nominalHeight).end();
         drawing(this.selection.graphics).clear().stroke(_loc1_,10855845).roundRect(-_loc1_ / 2,-_loc1_ / 2,this.nominalWidth + _loc1_,this.nominalHeight + _loc1_,this.cornerRadius).end();
         this.spinner.x = this.nominalWidth / 2;
         this.spinner.y = this.nominalHeight / 2;
         if(Boolean(childValue.width) && Boolean(childValue.height))
         {
            _loc2_ = childValue.width / childValue.height;
            if(this.nominalWidth / this.nominalHeight > _loc2_)
            {
               childValue.width = this.nominalWidth;
               childValue.height = this.nominalWidth / _loc2_;
               if(Math.abs(childValue.height - this.nominalHeight) < FUDGE)
               {
                  childValue.height = this.nominalHeight;
               }
               childValue.x = 0;
               childValue.y = Math.round((this.nominalHeight - childValue.height) / 2);
            }
            else
            {
               childValue.height = this.nominalHeight;
               childValue.width = this.nominalHeight * _loc2_;
               if(Math.abs(childValue.width - this.nominalWidth) < FUDGE)
               {
                  childValue.width = this.nominalWidth;
               }
               childValue.x = Math.round((this.nominalWidth - childValue.width) / 2);
               childValue.y = 0;
            }
         }
      }
      
      protected function onRemovedFromStage(param1:Event) : void
      {
         this.closeLoader();
      }
      
      protected function onLoadError(param1:Event) : void
      {
         this.removeSpinner();
         this.showDefault();
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(param1)
         {
            addChild(this.selection);
         }
         else if(this.selected)
         {
            removeChild(this.selection);
         }
         this.redraw();
      }
   }
}

