package com.google.youtube.ui
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class VideoTitleTextButton extends Button
   {
      
      protected var youtubeText:TextField;
      
      protected var textField:TextField = Theme.newTextField(Theme.newTextFormat(Theme.H4_TEXT_SIZE));
      
      protected var fadeOutMask:Sprite = new Sprite();
      
      public function VideoTitleTextButton(param1:Boolean = false)
      {
         this.textField.alpha = 0.8;
         super();
         this.textField.mask = this.fadeOutMask;
         this.textField.text = " ";
         addChild(this.fadeOutMask);
         addChild(this.textField);
         this.textField.x = 10;
         this.fadeOutMask.cacheAsBitmap = true;
         this.textField.cacheAsBitmap = true;
         if(param1)
         {
            this.youtubeText = Theme.newTextField();
            this.youtubeText.text = "YouTube";
            this.youtubeText.alpha = 0.8;
            addChild(this.youtubeText);
         }
      }
      
      public function set text(param1:String) : void
      {
         this.textField.text = param1 || " ";
         visible = Boolean(param1) || Boolean(this.youtubeText);
         this.redraw();
      }
      
      override public function onRollOut(param1:MouseEvent) : void
      {
         this.setUnderline(false);
         this.textField.alpha = 0.8;
         if(this.youtubeText)
         {
            this.youtubeText.alpha = 0.8;
         }
      }
      
      override protected function redraw() : void
      {
         if(this.youtubeText)
         {
            this.youtubeText.x = nominalWidth - (this.youtubeText.width + 5);
            this.youtubeText.y = this.textField.y + this.textField.height - this.youtubeText.height;
         }
         var _loc1_:int = 40;
         var _loc2_:int = this.youtubeText ? int(this.youtubeText.width + 50) : 40;
         drawing(this.fadeOutMask.graphics).clear().fill(0).rect(0,0,nominalWidth - _loc2_,this.textField.height).fill([0,0],[1,0],null,0,_loc1_,this.textField.height,nominalWidth - _loc2_).rect(nominalWidth - _loc2_,0,_loc1_,this.textField.height).end();
      }
      
      protected function setUnderline(param1:Boolean) : void
      {
         var _loc2_:TextFormat = this.textField.getTextFormat();
         _loc2_.underline = param1;
         this.textField.defaultTextFormat = _loc2_;
         this.textField.setTextFormat(_loc2_);
      }
      
      override public function onRollOver(param1:MouseEvent) : void
      {
         this.setUnderline(true);
         this.textField.alpha = 1;
         if(this.youtubeText)
         {
            this.youtubeText.alpha = 1;
         }
      }
   }
}

