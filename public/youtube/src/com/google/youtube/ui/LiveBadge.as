package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.WatchMessages;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   public class LiveBadge extends Sprite
   {
      
      protected var liveBadge:Sprite;
      
      protected var liveText:TextField;
      
      public function LiveBadge(param1:IMessages, param2:Boolean)
      {
         super();
         this.liveText = Theme.newTextField(Theme.newTextFormat(10));
         this.liveText.y = -4;
         this.liveBadge = param2 ? new LiveBadgeIcon() : new LiveBadgeIconDisabled();
         this.liveText.x = 10;
         param1.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
         addChild(this.liveBadge);
         addChild(this.liveText);
      }
      
      protected function onMessageUpdate(param1:MessageEvent) : void
      {
         this.liveText.text = param1.messages.getMessage(WatchMessages.LIVE);
         this.liveBadge.width = this.liveText.width + 14;
      }
      
      override public function get height() : Number
      {
         return this.liveBadge.height;
      }
   }
}

