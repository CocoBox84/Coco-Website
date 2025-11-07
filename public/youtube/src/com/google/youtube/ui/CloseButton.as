package com.google.youtube.ui
{
   import com.google.ui.CloseButton;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.WatchMessages;
   import flash.text.TextFormat;
   
   public class CloseButton extends Button
   {
      
      public static const DEFAULT_SIZE:int = 22;
      
      public static const CLICK_PADDING:int = 5;
      
      protected var closeButton:com.google.ui.CloseButton;
      
      protected var textFormatValue:TextFormat;
      
      protected var clickPadding:int;
      
      public function CloseButton(param1:IMessages = null, param2:String = "", param3:TextFormat = null, param4:int = 5)
      {
         super();
         this.textFormatValue = param3;
         this.clickPadding = param4;
         this.build();
         if(param1)
         {
            param1.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
         }
         else
         {
            accessibleName = "X";
         }
         if(param2 != "")
         {
            this.closeString = param2;
         }
         setSize(DEFAULT_SIZE,DEFAULT_SIZE);
         mouseChildren = true;
      }
      
      public function get closeString() : String
      {
         return this.closeButton.text;
      }
      
      private function build() : void
      {
         this.closeButton = new com.google.ui.CloseButton();
         this.closeButton.padding = this.clickPadding;
         if(this.textFormatValue)
         {
            this.closeButton.textFormat = this.textFormatValue;
         }
         addChild(this.closeButton);
      }
      
      protected function onMessageUpdate(param1:MessageEvent) : void
      {
         if(this.closeButton.text == "")
         {
            this.closeButton.text = accessibleName = param1.messages.getMessage(WatchMessages.CLOSE);
         }
      }
      
      override protected function redraw() : void
      {
         super.redraw();
         this.closeButton.setSize(nominalWidth,nominalHeight);
      }
      
      public function set closeString(param1:String) : void
      {
         this.closeButton.text = param1;
         accessibleName = param1;
         this.redraw();
      }
      
      override protected function alignContents() : void
      {
         contents.x = 0;
         contents.y = 0;
      }
   }
}

