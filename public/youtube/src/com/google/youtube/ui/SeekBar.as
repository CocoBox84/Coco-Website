package com.google.youtube.ui
{
   import com.google.utils.StringUtils;
   import com.google.youtube.event.SeekEvent;
   import com.google.youtube.event.TweenEvent;
   import com.google.youtube.event.VideoProgressEvent;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.util.Tween;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class SeekBar extends UIElement
   {
      
      public static var SEEK_HEIGHT:int = Theme.getConstant("SEEK_HEIGHT");
      
      public static var INVISIBLE_HEIGHT:int = Theme.getConstant("INVISIBLE_HEIGHT");
      
      public static var ACTUAL_HEIGHT:int = SEEK_HEIGHT + INVISIBLE_HEIGHT;
      
      public static const MAGNIFIER_DURATION_CUTOFF:Number = 5400;
      
      public static const CARBON_FIBER:BitmapData = new CarbonFiber();
      
      public static const CARBON_FIBER_LIGHT:BitmapData = new CarbonFiberLight();
      
      protected var clipStart:Number;
      
      protected var magnifier:SeekBarMagnifier;
      
      protected var markersContainer:Sprite = new Sprite();
      
      protected var dragBounds:Rectangle;
      
      protected var bar:Sprite = new Sprite();
      
      protected var sharkTeethContainer:Sprite = new Sprite();
      
      protected var handleTween:Tween;
      
      protected var handle:MovieClip;
      
      protected var markersMap:Dictionary = new Dictionary();
      
      protected var liveVisibleValue:Boolean;
      
      protected var barFade:Shape;
      
      protected var durationValue:Number = 0;
      
      protected var messages:IMessages;
      
      protected var fadeTween:Tween;
      
      protected var debounceRollOver:Boolean;
      
      protected var barProgress:DisplayObject;
      
      protected var clipLive:Number;
      
      protected var clipEnd:Number;
      
      protected var thumbnailTooltip:ThumbnailTooltip;
      
      protected var markers:Array = [];
      
      protected var barOutsideOfClip:Shape;
      
      protected var sharkTeeth:Array = [];
      
      protected var margin:int = 9;
      
      protected var clearClipContainer:Sprite = new Sprite();
      
      protected var barInvisible:DisplayObject;
      
      protected var lastProgress:VideoProgressEvent = new VideoProgressEvent(VideoProgressEvent.PROGRESS);
      
      protected var liveValue:Boolean;
      
      protected var barLoaded:DisplayObject;
      
      protected var barEmpty:DisplayObject;
      
      protected var region:Sprite;
      
      public function SeekBar(param1:IMessages = null, param2:Boolean = false)
      {
         this.messages = param1;
         super();
         this.createChildren();
         this.fadeTween = new Tween(this.bar);
         this.fadeTween.addEventListener(TweenEvent.UPDATE,this.onTween);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         tabEnabled = true;
         isAccessible = true;
         if(param1)
         {
            param1.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
         }
         this.updateTooltip();
         if(param2)
         {
            this.magnifier = new SeekBarMagnifier(param1);
            this.magnifier.setLabel(VideoControls.FADE,false);
            this.magnifier.tween.addEventListener(TweenEvent.UPDATE,this.onMagnifierTween);
         }
      }
      
      public static function newDropShadow() : DropShadowFilter
      {
         return new DropShadowFilter(2,90,0,0.5,4,4,1);
      }
      
      protected function onMessageUpdate(param1:MessageEvent) : void
      {
         accessibleName = param1.messages.getMessage(WatchMessages.SEEK_SLIDER);
         this.redraw();
      }
      
      public function getFillMatrix() : Matrix
      {
         var _loc1_:Matrix = new Matrix();
         _loc1_.translate(0,INVISIBLE_HEIGHT);
         return _loc1_;
      }
      
      protected function createChildren() : void
      {
         this.bar.y = -ACTUAL_HEIGHT + Theme.getConstant("SEEK_OFFSET");
         addChild(this.bar);
         this.region = new Sprite();
         this.region.y = -INVISIBLE_HEIGHT * 2 - 1;
         this.region.mouseEnabled = false;
         this.region.alpha = 0;
         this.barFade = new Shape();
         this.barFade.alpha = 0;
         this.barInvisible = new Shape();
         Drawing.invisibleRect(Shape(this.barInvisible).graphics,0,0,1,INVISIBLE_HEIGHT);
         this.barEmpty = new Shape();
         drawing(Shape(this.barEmpty).graphics).fill(Theme.getConstant("EMPTY_COLOR"),Theme.getConstant("EMPTY_ALPHA")).rect(0,INVISIBLE_HEIGHT,1,SEEK_HEIGHT).end();
         this.barLoaded = new Shape();
         drawing(Shape(this.barLoaded).graphics).fill(Theme.getConstant("LOADED_COLOR"),Theme.getConstant("LOADED_ALPHA")).rect(0,INVISIBLE_HEIGHT,1,SEEK_HEIGHT).end();
         this.barLoaded.visible = false;
         this.barProgress = new Shape();
         drawing(Shape(this.barProgress).graphics).fill(Theme.getConstant("PROGRESS_BAR"),Theme.getConstant("PROGRESS_BAR_ALPHAS"),Theme.getConstant("PROGRESS_BAR_RATIOS"),90,1,SEEK_HEIGHT,0,INVISIBLE_HEIGHT).rect(0,INVISIBLE_HEIGHT,1,SEEK_HEIGHT).end();
         this.barProgress.visible = false;
         this.barOutsideOfClip = new Shape();
         this.barOutsideOfClip.alpha = 0.75;
         this.clearClipContainer.visible = false;
         this.bar.addChild(this.barInvisible);
         this.bar.addChild(this.barEmpty);
         this.bar.addChild(this.barLoaded);
         this.bar.addChild(this.barProgress);
         this.bar.addChild(this.barOutsideOfClip);
         this.bar.addChild(this.markersContainer);
         this.bar.addChild(this.sharkTeethContainer);
         this.bar.addChild(this.clearClipContainer);
         this.bar.mouseChildren = false;
         this.bar.mouseEnabled = false;
         this.createHandle();
         this.handle.useHandCursor = false;
         addChild(this.handle);
         this.handleTween = new Tween(this.handle);
      }
      
      protected function updateTooltip(param1:MouseEvent = null, param2:Boolean = false) : void
      {
         var _loc3_:Point = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         var _loc7_:SeekBarMarker = null;
         var _loc8_:String = null;
         tooltipText = "";
         this.hideThumbnailTooltip();
         if(this.dragBounds)
         {
            return;
         }
         if(param1 && param2 && labelValue != VideoControls.FADE)
         {
            _loc3_ = globalToLocal(new Point(param1.stageX,param1.stageY));
            _loc4_ = _loc3_.x;
            _loc5_ = this.convertPosToTime(_loc4_);
            _loc6_ = this.isTimeOutOfRange(_loc5_);
            if(_loc6_ == "")
            {
               this.highlightClip = false;
               return;
            }
            _loc7_ = this.getClosestMarkerToTime(_loc5_);
            this.highlightClip = _loc7_ is SeekBarSharkToothMarker;
            _loc8_ = _loc7_ ? _loc7_.tooltip : null;
            if((Boolean(_loc8_)) && !_loc6_)
            {
               _loc5_ = _loc7_.startTime;
               _loc4_ = this.convertTimeToPos(_loc5_);
               if(this.showMagnifier)
               {
                  _loc4_ = this.magnifier.x + this.magnifier.convertTimeToPos(_loc5_) - this.magnifier.scrollRect.x;
               }
            }
            if(this.thumbnailTooltip && !_loc6_ && !(_loc7_ is SeekBarSharkToothMarker))
            {
               this.thumbnailTooltip.time = _loc5_;
               this.thumbnailTooltip.tooltip = _loc8_;
               this.showThumbnailTooltip();
               this.thumbnailTooltip.alignWith(this,new Point(_loc4_,this.tooltipOffset));
            }
            else
            {
               tooltipText = _loc6_ || _loc8_ || StringUtils.formatTime(_loc5_ * 1000,true);
               showTooltip(false);
               if(tooltip)
               {
                  tooltip.alignWith(this,new Point(_loc4_,this.tooltipOffset));
               }
            }
         }
         else
         {
            this.highlightClip = false;
         }
      }
      
      public function get numMarkers() : int
      {
         return this.markers.length;
      }
      
      public function get highlightClip() : Boolean
      {
         return this.clearClipContainer.visible;
      }
      
      protected function createDragBounds() : void
      {
         this.dragBounds = new Rectangle(this.convertTimeToPos(0),this.handle.y,this.convertTimeToPos(this.durationValue) - this.convertTimeToPos(0),0);
      }
      
      override public function get height() : Number
      {
         return -this.bar.y >= 0 ? -this.bar.y - INVISIBLE_HEIGHT : 0;
      }
      
      public function onVideoProgress(param1:VideoProgressEvent) : void
      {
         if(this.lastProgress.time != param1.time || this.lastProgress.bytesLoaded != param1.bytesLoaded || this.lastProgress.bytesTotal != param1.bytesTotal || this.lastProgress.loadedFraction != param1.loadedFraction)
         {
            this.lastProgress = param1;
            this.redraw();
         }
         if(this.showMagnifier && contains(this.magnifier))
         {
            this.magnifier.onVideoProgress(param1);
         }
      }
      
      public function set duration(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(this.durationValue != param1 && !isNaN(param1))
         {
            this.durationValue = param1;
            this.redraw();
            this.drawMarkers();
         }
         if(this.showMagnifier)
         {
            _loc2_ = this.convertPosToTime(this.margin + 1);
            this.magnifier.zoomScale = _loc2_ / SeekBarMagnifier.DESIRED_TIME_PER_PIXEL;
            this.magnifier.duration = param1;
         }
      }
      
      public function addMarker(param1:SeekBarMarker) : void
      {
         var _loc2_:Array = null;
         var _loc6_:DisplayObject = null;
         if(this.markersMap[param1])
         {
            return;
         }
         _loc2_ = [];
         this.markers.push(param1);
         this.markersMap[param1] = _loc2_;
         if(this.showMagnifier)
         {
            this.magnifier.addMarker(param1);
         }
         if(!this.durationValue)
         {
            return;
         }
         var _loc3_:Number = Math.round(param1.startTime <= 0 ? 0 : this.convertTimeToPos(param1.startTime));
         var _loc4_:Number = param1.endTime >= this.durationValue ? nominalWidth : this.convertTimeToPos(param1.endTime);
         var _loc5_:DisplayObject = this.getMarkerShape(param1,_loc4_ - _loc3_,SEEK_HEIGHT);
         _loc5_.x = _loc3_;
         _loc5_.y = INVISIBLE_HEIGHT;
         this.markersContainer.addChild(_loc5_);
         _loc2_.push(_loc5_);
         if(param1.shadowed)
         {
            _loc5_.filters = [Theme.newDropShadow()];
         }
         if(param1 is SeekBarSharkToothMarker)
         {
            _loc6_ = this.getClearClip();
            _loc6_.x = _loc5_.x - _loc6_.width / 2;
            _loc6_.y = _loc5_.y + (SEEK_HEIGHT - _loc6_.height) / 2;
            this.clearClipContainer.addChild(_loc6_);
            _loc2_.push(_loc6_);
         }
      }
      
      protected function redrawRuler() : void
      {
      }
      
      override public function onMouseUp(param1:MouseEvent) : void
      {
         this.debounceRollOver = true;
         super.onMouseUp(param1);
         this.updateTooltip(param1,false);
         if(this.dragBounds)
         {
            this.dragBounds = null;
            this.handle.stopDrag();
            dispatchEvent(new SeekEvent(SeekEvent.COMPLETE,this.convertPosToTime(this.handle.x,true)));
         }
      }
      
      protected function createHandle() : void
      {
         this.handle = new VideoThumb();
         var _loc1_:int = int(Theme.getConstant("SEEK_OFFSET") || 0);
         var _loc2_:int = int(Theme.getConstant("SEEK_HANDLE_OFFSET") || 0);
         var _loc3_:Shape = new Shape();
         drawing(_loc3_.graphics).fill(Theme.getConstant("PROGRESS_BAR"),Theme.getConstant("PROGRESS_BAR_ALPHAS"),Theme.getConstant("PROGRESS_BAR_RATIOS"),90,1,SEEK_HEIGHT,0,INVISIBLE_HEIGHT).circle(0,SEEK_HEIGHT,SEEK_HEIGHT - 2);
         this.handle.addChildAt(_loc3_,0);
         this.handle.y = -SEEK_HEIGHT - 3 + _loc1_ - _loc2_;
         this.handle.visible = false;
         this.handle.filters = Theme.getSeekHandleFilters();
      }
      
      public function set highlightClip(param1:Boolean) : void
      {
         if(param1 != this.highlightClip)
         {
            this.clearClipContainer.visible = param1;
            this.redraw();
         }
      }
      
      public function getMarkerShape(param1:SeekBarMarker, param2:Number = 1, param3:Number = 1) : DisplayObject
      {
         return param1.createShape(param2,param3);
      }
      
      public function removeMarkers() : void
      {
         while(this.markersContainer.numChildren)
         {
            this.markersContainer.removeChildAt(0);
         }
         while(this.clearClipContainer.numChildren)
         {
            this.clearClipContainer.removeChildAt(0);
         }
         this.markers = [];
         this.markersMap = new Dictionary();
         if(this.showMagnifier)
         {
            this.magnifier.removeMarkers();
         }
      }
      
      protected function addMagnifier() : void
      {
         if(!contains(this.magnifier))
         {
            this.magnifier.setSize(nominalWidth,nominalHeight);
            this.magnifier.onVideoProgress(this.lastProgress);
            addChildAt(this.magnifier,0);
            addChild(this.region);
            addChild(this.handle);
            this.bar.addChild(this.barFade);
         }
         this.magnifier.setLabel(VideoControls.DEFAULT,true);
      }
      
      public function set isLive(param1:Boolean) : void
      {
         this.liveVisibleValue = param1;
         if(this.showMagnifier)
         {
            this.magnifier.isLive = param1;
         }
      }
      
      protected function get tooltipOffset() : Number
      {
         var _loc1_:Number = -SEEK_HEIGHT;
         if(this.showMagnifier && contains(this.magnifier))
         {
            _loc1_ -= SEEK_HEIGHT * SeekBarMagnifier.ZOOM_SCALE_Y + Tooltip.STAGE_PADDING;
         }
         return _loc1_;
      }
      
      protected function get showMagnifier() : Boolean
      {
         return Boolean(this.magnifier) && this.durationValue > MAGNIFIER_DURATION_CUTOFF;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         if(!param1)
         {
            this.setLabel(VideoControls.FADE,false);
         }
         if(this.showMagnifier)
         {
            this.magnifier.enabled = param1;
         }
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         if(int(param1) == nominalWidth && int(param2) == nominalHeight)
         {
            return;
         }
         super.setSize(param1,param2);
         this.barEmpty.width = nominalWidth;
         this.barInvisible.width = nominalWidth;
         this.drawMarkers();
         if(this.thumbnailTooltip)
         {
            this.thumbnailTooltip.barWidth = param1;
         }
         if(this.showMagnifier)
         {
            this.magnifier.setSize(param1,param2);
         }
      }
      
      protected function getClosestMarkerToTime(param1:Number) : SeekBarMarker
      {
         var _loc3_:SeekBarMarker = null;
         var _loc4_:int = 0;
         var _loc2_:Number = this.convertTimeToPos(param1);
         for each(_loc3_ in this.markers)
         {
            _loc4_ = _loc3_ is SeekBarSharkToothMarker ? 10 : 3;
            if(Math.abs(this.convertTimeToPos(_loc3_.startTime) - _loc2_) < _loc4_)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function getClearClip() : DisplayObject
      {
         return Theme.newMaskedIcon(Theme.getConstant("BACKGROUND_GRADIENT_COLORS"),new ClearClipIcon(),new ClearClipIconOverlay());
      }
      
      public function set videoData(param1:VideoData) : void
      {
         var _loc2_:SeekBarMarker = null;
         this.hideThumbnailTooltip();
         this.thumbnailTooltip = null;
         if(param1.mosaicLoader)
         {
            this.thumbnailTooltip = new ThumbnailTooltip(param1.mosaicLoader);
            this.thumbnailTooltip.barWidth = nominalWidth;
         }
         if(this.showMagnifier)
         {
            this.magnifier.videoData = param1;
         }
         if(this.clipStart != param1.clipStart || this.clipEnd != param1.clipEnd)
         {
            this.clipStart = param1.clipStart;
            this.clipEnd = param1.clipEnd;
            for each(_loc2_ in this.sharkTeeth)
            {
               this.removeMarker(_loc2_);
            }
            this.sharkTeeth = [];
            if(this.clipStart)
            {
               _loc2_ = new SeekBarSharkToothMarker(this.clipStart,this.clipStart,this.messages.getMessage(WatchMessages.WATCH_ALL));
               this.addMarker(_loc2_);
               this.sharkTeeth.push(_loc2_);
            }
            if(this.clipEnd)
            {
               _loc2_ = new SeekBarSharkToothMarker(this.clipEnd,this.clipEnd,this.messages.getMessage(WatchMessages.WATCH_ALL),true);
               this.addMarker(_loc2_);
               this.sharkTeeth.push(_loc2_);
            }
         }
         this.redraw();
      }
      
      public function showThumbnailTooltip() : void
      {
         if(Boolean(root) && Boolean(this.thumbnailTooltip))
         {
            DisplayObjectContainer(root).addChild(this.thumbnailTooltip);
         }
      }
      
      public function drawMarkers() : void
      {
         if(!this.durationValue)
         {
            return;
         }
         var _loc1_:Array = this.markers;
         this.removeMarkers();
         var _loc2_:int = 0;
         var _loc3_:int = int(_loc1_.length);
         while(_loc2_ < _loc3_)
         {
            this.addMarker(_loc1_[_loc2_]);
            _loc2_++;
         }
      }
      
      public function convertTimeToPos(param1:Number) : Number
      {
         if(this.durationValue <= 0)
         {
            return this.margin;
         }
         param1 = Math.min(param1,this.durationValue);
         return param1 * (nominalWidth - 2 * this.margin) / this.durationValue + this.margin;
      }
      
      override public function setLabel(param1:String, param2:Boolean = true) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         param1 = enabled ? param1 : VideoControls.FADE;
         var _loc3_:Number = Number(Theme.getConstant("SEEK_OFFSET") || 0);
         if(labelValue != param1)
         {
            labelValue = param1;
            if(labelValue == VideoControls.FADE)
            {
               _loc4_ = (nominalHeight + 1.5) / ACTUAL_HEIGHT;
               this.fadeTween.easeIn().to({
                  "y":-ACTUAL_HEIGHT * _loc4_ + _loc3_,
                  "scaleY":_loc4_
               },param2 ? 500 : 0);
               this.handleTween.easeIn().to({
                  "scaleX":0.1,
                  "scaleY":0.1,
                  "y":0,
                  "visible":false
               },param2 ? 500 : 0);
               if(this.showMagnifier)
               {
                  this.magnifier.setLabel(param1,param2);
               }
            }
            else
            {
               _loc5_ = int(Theme.getConstant("SEEK_HANDLE_OFFSET") || 0);
               this.fadeTween.easeOut().to({
                  "y":-ACTUAL_HEIGHT + _loc3_,
                  "scaleY":1
               },param2 ? 100 : 0);
               this.handleTween.easeOut().from({"visible":true}).to({
                  "scaleX":1,
                  "scaleY":1,
                  "y":-SEEK_HEIGHT - 3 + _loc3_ - _loc5_
               },param2 ? 100 : 0);
            }
         }
      }
      
      override public function onRollOut(param1:MouseEvent) : void
      {
         this.debounceRollOver = false;
         super.onRollOut(param1);
         this.updateTooltip(param1,false);
         if(this.showMagnifier && !(stateValue is IMouseDownState))
         {
            this.magnifier.setLabel(VideoControls.FADE,true);
         }
      }
      
      override public function onMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Number = NaN;
         super.onMouseDown(param1);
         if(enabled)
         {
            if(this.showMagnifier && param1.target is SeekBarMagnifier)
            {
               return;
            }
            _loc2_ = globalToLocal(new Point(param1.stageX,param1.stageY));
            _loc3_ = this.convertPosToTime(_loc2_.x,true);
            if(this.getClosestMarkerToTime(_loc3_) is SeekBarSharkToothMarker)
            {
               dispatchEvent(new SeekEvent(SeekEvent.CLEAR_CLIP,_loc3_));
               return;
            }
            this.createDragBounds();
            this.handle.x = this.convertTimeToPos(_loc3_);
            this.handle.startDrag(false,this.dragBounds);
            dispatchEvent(new SeekEvent(SeekEvent.START,_loc3_));
            if(this.showMagnifier)
            {
               this.removeMagnifier();
            }
         }
         this.updateTooltip(param1,false);
      }
      
      private function onTween(param1:TweenEvent) : void
      {
         dispatchEvent(new TweenEvent(TweenEvent.UPDATE,true));
      }
      
      public function set isPeggedToLive(param1:Boolean) : void
      {
         this.liveValue = param1;
         if(this.showMagnifier)
         {
            this.magnifier.isPeggedToLive = param1;
         }
      }
      
      private function onMagnifierTween(param1:TweenEvent) : void
      {
         this.region.alpha = this.magnifier.alpha * this.magnifier.alpha;
         this.barFade.alpha = this.region.alpha;
         if(this.magnifier.alpha == 0)
         {
            this.removeMagnifier();
         }
      }
      
      public function hideThumbnailTooltip() : void
      {
         if(root && this.thumbnailTooltip && DisplayObjectContainer(root).contains(this.thumbnailTooltip))
         {
            DisplayObjectContainer(root).removeChild(this.thumbnailTooltip);
         }
      }
      
      protected function removeMagnifier() : void
      {
         if(contains(this.magnifier))
         {
            this.magnifier.onRollOut(null);
            removeChild(this.magnifier);
            removeChild(this.region);
            this.bar.removeChild(this.barFade);
         }
      }
      
      public function removeMarker(param1:SeekBarMarker) : void
      {
         var _loc2_:DisplayObject = null;
         if(this.markersMap[param1])
         {
            this.markers.splice(this.markers.indexOf(param1),1);
            for each(_loc2_ in this.markersMap[param1])
            {
               _loc2_.parent.removeChild(_loc2_);
            }
            delete this.markersMap[param1];
         }
         if(this.showMagnifier)
         {
            this.magnifier.removeMarker(param1);
         }
      }
      
      public function convertPosToTime(param1:Number, param2:Boolean = false) : Number
      {
         var _loc5_:SeekBarMarker = null;
         var _loc3_:Number = (param1 - this.margin) * this.durationValue / (nominalWidth - 2 * this.margin);
         var _loc4_:Number = _loc3_ < 0 ? 0 : (_loc3_ > this.durationValue ? this.durationValue : _loc3_);
         if(param2)
         {
            _loc5_ = this.getClosestMarkerToTime(_loc4_);
            if((Boolean(_loc5_)) && Boolean(_loc5_.tooltip))
            {
               _loc4_ = _loc5_.startTime;
            }
         }
         return _loc4_;
      }
      
      protected function isTimeOutOfRange(param1:Number) : String
      {
         if(Boolean(this.clipLive) && param1 > this.clipLive)
         {
            if(this.liveValue)
            {
               return "";
            }
            return this.messages.getMessage(WatchMessages.GOTO_LIVE_TOOLTIP);
         }
         return null;
      }
      
      protected function setRegion(param1:Number = NaN, param2:Number = NaN) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(!isNaN(param1) && !isNaN(param2))
         {
            _loc3_ = this.convertTimeToPos(param1);
            _loc4_ = this.convertTimeToPos(param2);
            if(_loc4_ - _loc3_ < 10)
            {
               _loc5_ = (10 - (_loc4_ - _loc3_)) / 2;
               _loc3_ -= _loc5_;
               _loc4_ += _loc5_;
            }
            drawing(this.barFade.graphics).clear().fill(0,0.4).rect(0,INVISIBLE_HEIGHT,_loc3_ - 2,SEEK_HEIGHT).rect(_loc4_,INVISIBLE_HEIGHT,nominalWidth - _loc4_ - 2,SEEK_HEIGHT);
            this.redrawRuler();
         }
      }
      
      override protected function redraw() : void
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         if(!this.barLoaded || !this.barProgress)
         {
            accessibleDescription = "0% " + accessibleName;
            return;
         }
         var _loc1_:Number = Math.ceil(this.convertTimeToPos(0));
         var _loc2_:Number = Math.floor(this.convertTimeToPos(this.durationValue));
         var _loc3_:Number = Math.ceil(this.convertTimeToPos(this.clipStart || 0));
         _loc3_ = _loc3_ <= _loc1_ ? 0 : (_loc3_ >= _loc2_ ? nominalWidth : _loc3_);
         var _loc4_:Number = this.convertTimeToPos(this.lastProgress.time);
         _loc4_ = _loc4_ <= _loc3_ ? _loc3_ : (_loc4_ >= _loc2_ ? nominalWidth : _loc4_);
         var _loc5_:Number = this.lastProgress.loadedFraction * (nominalWidth - _loc3_);
         var _loc6_:Number = _loc3_ + _loc5_;
         _loc6_ = _loc6_ <= _loc4_ ? _loc4_ : (_loc6_ >= _loc2_ ? nominalWidth : _loc6_);
         if(!this.dragBounds)
         {
            this.handle.x = int(_loc4_ <= _loc1_ ? _loc1_ : (_loc4_ >= _loc2_ ? _loc2_ : _loc4_));
         }
         if(this.liveValue)
         {
            this.clipLive = this.convertPosToTime(_loc4_);
         }
         else if(this.liveVisibleValue)
         {
            this.clipLive = this.convertPosToTime(_loc6_);
         }
         var _loc7_:Number = Number(this.clipEnd || this.clipLive);
         var _loc8_:Number = _loc7_ ? this.convertTimeToPos(_loc7_) : nominalWidth;
         this.barLoaded.x = _loc3_;
         if(_loc6_ > _loc3_)
         {
            this.barLoaded.width = Math.min(_loc8_,_loc6_) - _loc3_;
            this.barLoaded.visible = true;
         }
         else
         {
            this.barLoaded.visible = false;
         }
         this.barProgress.x = _loc3_;
         if(_loc4_ > _loc3_)
         {
            this.barProgress.width = Math.min(_loc8_,_loc4_) - _loc3_;
            this.barProgress.visible = true;
         }
         else
         {
            this.barProgress.visible = false;
         }
         this.barOutsideOfClip.graphics.clear();
         if(this.clipStart)
         {
            drawing(this.barOutsideOfClip.graphics).bitmapFill(this.highlightClip ? CARBON_FIBER_LIGHT : CARBON_FIBER,this.getFillMatrix()).rect(0,INVISIBLE_HEIGHT,this.convertTimeToPos(this.clipStart),SEEK_HEIGHT);
         }
         if(Boolean(this.clipEnd) || Boolean(this.clipLive))
         {
            _loc9_ = this.convertTimeToPos(this.clipEnd || this.clipLive);
            drawing(this.barOutsideOfClip.graphics).bitmapFill(this.highlightClip ? CARBON_FIBER_LIGHT : CARBON_FIBER,this.getFillMatrix()).rect(_loc9_,INVISIBLE_HEIGHT,nominalWidth - _loc9_,SEEK_HEIGHT);
         }
         if(this.durationValue > 0 && this.lastProgress.time >= 0)
         {
            _loc10_ = Math.min(this.lastProgress.time,this.durationValue);
            accessibleDescription = Math.round(_loc10_ / this.durationValue * 100).toString() + "% " + accessibleName;
         }
         else
         {
            accessibleDescription = "0% " + accessibleName;
         }
         this.redrawRuler();
      }
      
      public function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Number = NaN;
         if(param1.buttonDown && !this.dragBounds)
         {
            return;
         }
         if(enabled)
         {
            _loc2_ = globalToLocal(new Point(param1.stageX,param1.stageY));
            _loc3_ = this.convertPosToTime(_loc2_.x,true);
            if(this.dragBounds)
            {
               dispatchEvent(new SeekEvent(SeekEvent.SEEK,this.convertPosToTime(this.handle.x)));
               if(this.showMagnifier)
               {
                  this.removeMagnifier();
               }
               this.updateTooltip(param1,false);
            }
            else if(this.showMagnifier)
            {
               if(param1.target is SeekBarMagnifier)
               {
                  this.addMagnifier();
                  this.updateTooltip(param1,false);
               }
               else if(this.isTimeOutOfRange(_loc3_) != null)
               {
                  this.removeMagnifier();
                  this.updateTooltip(param1,true);
               }
               else
               {
                  this.addMagnifier();
                  this.magnifier.zoom = _loc3_;
                  this.magnifier.x = Math.max(2,Math.min(nominalWidth - this.magnifier.scrollRect.width - 2,this.convertTimeToPos(_loc3_) - this.magnifier.scrollRect.width / 2));
                  this.setRegion(this.magnifier.zoomStart,this.magnifier.zoomEnd);
                  this.updateTooltip(param1,true);
               }
            }
            else
            {
               this.updateTooltip(param1,true);
            }
            param1.updateAfterEvent();
         }
      }
      
      override public function onRollOver(param1:MouseEvent) : void
      {
         super.onRollOver(param1);
         if(this.debounceRollOver)
         {
            this.debounceRollOver = false;
            return;
         }
         if(!(stateValue is IMouseDownState))
         {
            this.onMouseMove(param1);
         }
      }
   }
}

