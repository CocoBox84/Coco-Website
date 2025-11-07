package com.google.youtube.ui
{
   import com.google.utils.StringUtils;
   import com.google.youtube.model.IMessages;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextLineMetrics;
   
   public class VideoInfoWindow extends UIElement
   {
      
      private static const BACKGROUND_COLOR:Number = 0;
      
      private static const BACKGROUND_HEIGHT:Number = 80;
      
      private static const BACKGROUND_WIDTH:Number = 160;
      
      private static const PADDING:Number = 6;
      
      protected static const TEMPLATE:String = "timestamp seconds {timestamp}\n" + "{videoWidth}x{videoHeight}, {videoBitrate} average kbps, " + "{volume}% volume\n" + "{playerType}, {streamType}, {streamBitrate} kbps\n" + "{stageFps} stage fps, {videoFps} video fps, " + "{droppedFrames} dropped, {playBitrate} kbps\n" + "{rendering} video rendering, {decoding} video decoding\n" + "{loudness} db, {muffled} audio factor\n";
      
      protected var bufferTooltip:TextField;
      
      protected var playSpark:Sparkline;
      
      protected var closeButton:CloseButton;
      
      protected var textField:TextField;
      
      protected var bufferMap:IntervalMap;
      
      protected var streamSpark:Sparkline;
      
      public function VideoInfoWindow(param1:IMessages)
      {
         super();
         this.closeButton = new CloseButton(param1);
         this.build();
         this.setSize(BACKGROUND_WIDTH,BACKGROUND_HEIGHT);
      }
      
      public function updateVideoInfo(param1:Object) : void
      {
         this.bufferMap.data = param1.videoBuffers;
         this.bufferMap.max = param1.duration * 1000;
         this.streamSpark.push(param1.streamBitrate);
         this.playSpark.push(param1.playBitrate);
         this.textField.text = StringUtils.format(TEMPLATE,param1);
         this.alignWithText(this.streamSpark,1);
         this.alignWithText(this.playSpark,2);
         this.bufferTooltip.x = this.textField.x;
         this.bufferTooltip.y = this.textField.y + this.textField.height;
         this.bufferMap.x = this.bufferTooltip.x;
         this.bufferMap.y = this.bufferTooltip.y + this.bufferTooltip.height;
         this.setSize(foreground.width + 2 * PADDING,foreground.height + 2 * PADDING);
      }
      
      protected function build() : void
      {
         this.closeButton.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         addChild(this.closeButton);
         this.textField = Theme.newTextField();
         this.textField.mouseEnabled = true;
         this.textField.selectable = true;
         this.textField.x = PADDING;
         this.textField.y = PADDING;
         foreground.addChild(this.textField);
         this.playSpark = new Sparkline();
         this.playSpark.setSize(32,10);
         foreground.addChild(this.playSpark);
         this.streamSpark = new Sparkline();
         this.streamSpark.setSize(32,10);
         foreground.addChild(this.streamSpark);
         this.bufferMap = new IntervalMap();
         this.bufferMap.addEventListener(MouseEvent.MOUSE_OVER,function(param1:MouseEvent):void
         {
            if(param1.target.hasOwnProperty("interval"))
            {
               bufferTooltip.text = param1.target.interval;
            }
         });
         this.bufferMap.addEventListener(MouseEvent.MOUSE_OUT,function(param1:MouseEvent):void
         {
            bufferTooltip.text = " ";
         });
         this.bufferMap.setSize(320,6);
         this.bufferTooltip = Theme.newTextField();
         this.bufferTooltip.text = " ";
         foreground.addChild(this.bufferMap);
         foreground.addChild(this.bufferTooltip);
      }
      
      protected function onCloseClick(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      override protected function redraw() : void
      {
         background.graphics.clear();
         background.graphics.beginFill(BACKGROUND_COLOR,0.6);
         background.graphics.lineStyle(1,16777215,0.6);
         background.graphics.drawRoundRect(0.5,0.5,nominalWidth - 1,nominalHeight - 1,6);
         background.graphics.endFill();
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         super.setSize(param1,param2);
         this.closeButton.x = param1 - this.closeButton.getBounds(this.closeButton).right;
         this.closeButton.y = 0;
      }
      
      protected function alignWithText(param1:DisplayObject, param2:int) : void
      {
         var _loc3_:TextLineMetrics = this.textField.getLineMetrics(param2);
         param1.x = int(_loc3_.x + _loc3_.width) + this.textField.x;
         param1.y = int(_loc3_.height) * (param2 + 1) + this.textField.y - param1.height;
      }
   }
}

