package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.WatchMessages;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   
   public class LargePlayButton extends UIElement
   {
      
      private var movieClip:MovieClip;
      
      public function LargePlayButton(param1:IMessages)
      {
         super();
         horizontalStretch = 1;
         verticalStretch = 1;
         buttonMode = true;
         mouseChildren = false;
         this.movieClip = new LargePlayButtonSymbol();
         this.movieClip.gotoAndStop("up");
         this.movieClip.filters = [new GlowFilter(16777215,0.075,10,10)];
         child = this.movieClip;
         accessibleName = param1.getMessage(WatchMessages.PLAY);
      }
      
      override public function onRollOut(param1:MouseEvent) : void
      {
         this.movieClip.gotoAndStop("up");
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         this.resetScale();
      }
      
      override public function onRollOver(param1:MouseEvent) : void
      {
         this.movieClip.gotoAndStop("over");
      }
      
      protected function resetScale() : void
      {
         var _loc1_:Number = Theme.getScaleFactor(width,height);
         this.movieClip.scaleX = _loc1_;
         this.movieClip.scaleY = _loc1_;
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         this.resetScale();
      }
      
      override protected function redraw() : void
      {
         super.redraw();
         this.movieClip.x = Math.floor(nominalWidth / 2);
         this.movieClip.y = Math.floor(nominalHeight / 2);
      }
   }
}

