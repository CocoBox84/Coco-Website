package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class ErrorDisplay extends UIElement
   {
      
      protected static const SIDE_MARGIN_RATIO:Number = 0.2;
      
      protected static const NUM_STATIC_BITMAPS:int = 3;
      
      protected static const STATIC_NOISE_SIZE:int = 100;
      
      protected static const STATIC_NOISE_SCALE:int = 2;
      
      protected static const SCAN_LINE_HEIGHT:int = 75;
      
      protected var errorStackValue:String;
      
      protected var errorMessageKey:String;
      
      protected var currentNoiseBitmap:int;
      
      protected var scanLine:AnimatedElement;
      
      protected var errorStatic:Shape;
      
      protected var staticNoiseBitmaps:Array;
      
      protected var errorDisplay:TextField;
      
      public function ErrorDisplay()
      {
         var _loc3_:BitmapData = null;
         this.errorStatic = new Shape();
         this.staticNoiseBitmaps = [];
         this.scanLine = new AnimatedElement();
         super();
         horizontalStretch = 1;
         verticalStretch = 1;
         var _loc1_:TextFormat = Theme.newTextFormat();
         _loc1_.size = 16;
         this.errorDisplay = Theme.newTextField(_loc1_);
         this.errorDisplay.mouseEnabled = true;
         this.errorDisplay.multiline = true;
         this.errorDisplay.wordWrap = true;
         this.errorDisplay.filters = [Theme.newDropShadow()];
         this.currentNoiseBitmap = 0;
         var _loc2_:uint = 0;
         while(_loc2_ < NUM_STATIC_BITMAPS)
         {
            _loc3_ = new BitmapData(STATIC_NOISE_SIZE,STATIC_NOISE_SIZE);
            _loc3_.noise(Math.round(Math.random() * 1000),0,30,7,true);
            this.staticNoiseBitmaps.push(_loc3_);
            _loc2_++;
         }
         this.errorStatic.scaleX = this.errorStatic.scaleY = STATIC_NOISE_SCALE;
         addChild(this.errorStatic);
         addChild(this.scanLine);
         addChild(this.errorDisplay);
      }
      
      public function setMessage(param1:String, param2:IMessages = null) : void
      {
         if(param2)
         {
            this.errorMessageKey = param1;
            param2.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
         }
         else
         {
            this.errorDisplay.htmlText = "<p align=\'center\'>" + param1 + "</p>";
            this.redraw();
         }
      }
      
      override protected function redraw() : void
      {
         drawing(background.graphics).clear().fill(Theme.BLACK,0.9).rect(0,0,nominalWidth,nominalHeight).end();
         this.errorDisplay.width = nominalWidth * (1 - 2 * SIDE_MARGIN_RATIO);
         this.errorDisplay.x = nominalWidth / 2 - this.errorDisplay.width / 2;
         this.errorDisplay.y = nominalHeight / 2 - this.errorDisplay.height / 2;
         drawing(this.scanLine.graphics).clear().stroke(SCAN_LINE_HEIGHT,Theme.WHITE,0.02).line(0,-SCAN_LINE_HEIGHT,nominalWidth,-SCAN_LINE_HEIGHT);
      }
      
      override protected function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         super.onAddedToStage(param1);
      }
      
      override protected function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         super.onRemovedFromStage(param1);
      }
      
      public function get errorStack() : String
      {
         return this.errorStackValue;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:BitmapData = this.staticNoiseBitmaps[this.currentNoiseBitmap];
         var _loc3_:Matrix = new Matrix();
         _loc3_.translate(Math.random() * STATIC_NOISE_SIZE * 2 - STATIC_NOISE_SIZE,Math.random() * STATIC_NOISE_SIZE * 2 - STATIC_NOISE_SIZE);
         drawing(this.errorStatic.graphics).clear().bitmapFill(_loc2_,_loc3_).rect(0,0,nominalWidth / this.errorStatic.scaleX,nominalHeight / this.errorStatic.scaleY).end();
         this.currentNoiseBitmap = (this.currentNoiseBitmap + 1) % this.staticNoiseBitmaps.length;
         this.scanLine.y = (this.scanLine.y + 7) % (nominalHeight + SCAN_LINE_HEIGHT * 2);
      }
      
      public function onMessageUpdate(param1:MessageEvent) : void
      {
         this.setMessage(param1.messages.getMessage(this.errorMessageKey));
         this.redraw();
      }
   }
}

