package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.VideoData;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public class SeekBarMagnifier extends SeekBar
   {
      
      protected static const MINIMUM_ZOOM:Number = 3;
      
      public static const DESIRED_TIME_PER_PIXEL:Number = 0.5;
      
      public static const ZOOM_SCALE_Y:Number = MINIMUM_ZOOM;
      
      protected static const ZOOM_WIDTH:Number = 200;
      
      protected static const RULER_INTERVAL:Number = 60;
      
      private var zoomScaleX:Number = 3;
      
      private var overlay:Shape = new Shape();
      
      private var zoomValue:Number = 0;
      
      private var noise:BitmapData = new BitmapData(320,SeekBar.SEEK_HEIGHT * ZOOM_SCALE_Y,true,0);
      
      private var yValue:Number;
      
      public function SeekBarMagnifier(param1:IMessages = null)
      {
         this.noise.noise(32,80,112,7,true);
         super(param1,false);
         this.setLabel(VideoControls.FADE,false);
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         if(int(param1 * this.zoomScaleX) == nominalWidth && int(param2 * ZOOM_SCALE_Y) == nominalHeight)
         {
            return;
         }
         super.setSize(param1 * this.zoomScaleX,param2 * ZOOM_SCALE_Y);
         if(thumbnailTooltip)
         {
            thumbnailTooltip.barWidth = param1;
         }
         bar.scaleY = param2 * ZOOM_SCALE_Y / VideoControls.GUTTER_HEIGHT;
         this.yValue = Math.ceil(-SeekBar.SEEK_HEIGHT * ZOOM_SCALE_Y - SeekBar.INVISIBLE_HEIGHT * (ZOOM_SCALE_Y - 1));
         y = this.yValue;
         this.zoom = this.zoom;
      }
      
      override protected function createHandle() : void
      {
         handle = new MagnifiedVideoThumb();
         handle.height = SeekBar.SEEK_HEIGHT * ZOOM_SCALE_Y - 2;
         handle.y = 1;
         handle.mouseEnabled = false;
      }
      
      override protected function getClosestMarkerToTime(param1:Number) : SeekBarMarker
      {
         var _loc3_:SeekBarMarker = null;
         var _loc2_:Number = convertTimeToPos(param1);
         for each(_loc3_ in markers)
         {
            if(_loc3_ is SeekBarSharkToothMarker && Math.abs(convertTimeToPos(_loc3_.startTime) - _loc2_) < 20 || Math.abs(param1 - _loc3_.startTime) < 4)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      override public function getClearClip() : DisplayObject
      {
         var _loc1_:DisplayObject = super.getClearClip();
         _loc1_.scaleX = ZOOM_SCALE_Y;
         return _loc1_;
      }
      
      override public function onMouseUp(param1:MouseEvent) : void
      {
         super.onMouseUp(param1);
         if(!(stateValue is RollOverState))
         {
            this.setLabel(VideoControls.FADE,true);
         }
      }
      
      public function get zoomStart() : Number
      {
         return scrollRect ? convertPosToTime(scrollRect.x) : 0;
      }
      
      override public function set videoData(param1:VideoData) : void
      {
         super.videoData = param1;
         if(thumbnailTooltip)
         {
            thumbnailTooltip.barWidth = nominalWidth / this.zoomScaleX;
         }
      }
      
      public function get zoom() : Number
      {
         return this.zoomValue;
      }
      
      public function get zoomEnd() : Number
      {
         return scrollRect ? convertPosToTime(scrollRect.x + scrollRect.width) : 0;
      }
      
      override public function getMarkerShape(param1:SeekBarMarker, param2:Number = 1, param3:Number = 1) : DisplayObject
      {
         var _loc4_:DisplayObject = param1.createMagnifiedShape(param2,param3);
         if(param1.allowScale)
         {
            _loc4_.scaleX = ZOOM_SCALE_Y;
         }
         return _loc4_;
      }
      
      override public function getFillMatrix() : Matrix
      {
         var _loc1_:Matrix = new Matrix();
         _loc1_.translate(0,INVISIBLE_HEIGHT);
         _loc1_.scale(ZOOM_SCALE_Y,1);
         return _loc1_;
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         bar.removeChild(barInvisible);
         bar.y = -SeekBar.INVISIBLE_HEIGHT * ZOOM_SCALE_Y;
         this.overlay.blendMode = BlendMode.OVERLAY;
         this.overlay.alpha = 0.3;
         addChild(this.overlay);
      }
      
      override protected function createDragBounds() : void
      {
         dragBounds = new Rectangle(scrollRect.x,handle.y,scrollRect.width - handle.width,0);
      }
      
      public function set zoom(param1:Number) : void
      {
         this.zoomValue = param1;
         var _loc2_:Number = convertTimeToPos(param1) - ZOOM_WIDTH / 2;
         if(convertPosToTime(_loc2_) == 0)
         {
            _loc2_ = 0;
         }
         var _loc3_:Number = _loc2_ + ZOOM_WIDTH;
         if(convertPosToTime(_loc3_) == durationValue)
         {
            _loc3_ = convertTimeToPos(durationValue);
            _loc2_ = _loc3_ - ZOOM_WIDTH;
         }
         scrollRect = new Rectangle(_loc2_,0,ZOOM_WIDTH,SeekBar.SEEK_HEIGHT * ZOOM_SCALE_Y);
         if(bar.mask)
         {
            removeChild(bar.mask);
         }
         if(this.overlay.mask)
         {
            removeChild(this.overlay.mask);
         }
         var _loc4_:Number = scrollRect.x;
         var _loc5_:Number = scrollRect.width;
         var _loc6_:Number = scrollRect.height;
         var _loc7_:Shape = new Shape();
         drawing(_loc7_.graphics).fill(0).rect(_loc4_ + 1,1,_loc5_ - 2,_loc6_ - 2);
         bar.mask = _loc7_;
         addChild(bar.mask);
      }
      
      public function set zoomScale(param1:Number) : void
      {
         this.zoomScaleX = Math.max(MINIMUM_ZOOM,param1);
      }
      
      override public function setLabel(param1:String, param2:Boolean = true) : void
      {
         param1 = enabled ? param1 : VideoControls.FADE;
         if(labelValue != param1)
         {
            labelValue = param1;
            if(labelValue == VideoControls.FADE)
            {
               tween.easeIn().to({
                  "alpha":0,
                  "y":this.yValue + SeekBar.SEEK_HEIGHT
               },param2 ? 200 : 0);
               mouseEnabled = false;
               mouseChildren = false;
               this.updateTooltip();
            }
            else
            {
               tween.easeOut().from({"visible":true}).to({
                  "alpha":1,
                  "y":this.yValue
               },param2 ? 200 : 0);
               mouseEnabled = true;
               mouseChildren = true;
            }
         }
      }
      
      override protected function get tooltipOffset() : Number
      {
         return -Tooltip.STAGE_PADDING;
      }
      
      override protected function updateTooltip(param1:MouseEvent = null, param2:Boolean = false) : void
      {
         if(y != this.yValue)
         {
            return;
         }
         super.updateTooltip(param1,param2);
      }
      
      override protected function redrawRuler() : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         drawing(markersContainer.graphics).clear();
         var _loc1_:int = Math.max(1,Math.ceil(this.zoomStart / RULER_INTERVAL - 1));
         var _loc2_:int = Math.floor(this.zoomEnd / RULER_INTERVAL + 1);
         var _loc3_:int = _loc1_;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = 0.3;
            if(_loc3_ % 60 == 0)
            {
               _loc4_ = 0.6;
            }
            else if(_loc3_ % 30 == 0)
            {
               _loc4_ = 0.55;
            }
            else if(_loc3_ % 15 == 0)
            {
               _loc4_ = 0.5;
            }
            _loc5_ = convertTimeToPos(_loc3_ * RULER_INTERVAL) - 1;
            _loc6_ = convertTimeToPos(_loc3_ * RULER_INTERVAL) + 1;
            _loc7_ = Math.max(1,_loc4_ * SeekBar.SEEK_HEIGHT);
            _loc8_ = _loc6_ - _loc5_;
            drawing(markersContainer.graphics).fill(0,0.5).rect(_loc5_,SeekBar.INVISIBLE_HEIGHT,_loc8_,_loc7_).end();
            _loc3_++;
         }
      }
   }
}

