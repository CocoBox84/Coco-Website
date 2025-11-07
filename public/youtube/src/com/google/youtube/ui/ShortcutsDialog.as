package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.WatchMessages;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class ShortcutsDialog extends Dialog
   {
      
      private var topDivider:MenuDivider;
      
      private var messages:IMessages;
      
      private var shortcutText:TextField;
      
      private var doneButton:TextButton;
      
      private var hasPlaylist:Boolean;
      
      private var dialogBounds:Rectangle;
      
      private var title:TextField;
      
      private var shortcutTextElement:LayoutElement;
      
      private var shortcuts:Array = [];
      
      private var bottomDivider:MenuDivider;
      
      public function ShortcutsDialog(param1:IMessages, param2:Boolean)
      {
         super();
         this.build();
         this.messages = param1;
         this.messages.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
         this.hasPlaylist = param2;
         horizontalStretch = 1;
         verticalStretch = 1;
         this.checkShortcuts();
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         super.setSize(Math.min(this.dialogBounds.width,param1),Math.min(this.dialogBounds.height,param2));
         this.topDivider.width = nominalWidth - PADDING * 2;
         this.bottomDivider.width = nominalWidth - PADDING * 2;
         footer.width = nominalWidth - PADDING * 2;
         setPosition(param1 / 2 - nominalWidth / 2,param2 / 2 - nominalHeight / 2);
         nominalWidth = param1;
         nominalHeight = param2;
      }
      
      protected function checkShortcuts() : void
      {
         this.shortcuts = [{
            "key":"K",
            "message":WatchMessages.PLAY_PAUSE
         },{
            "key":"J",
            "message":WatchMessages.SEEK_BACK
         },{
            "key":"L",
            "message":WatchMessages.SEEK_FORWARD
         },{
            "key":"M",
            "message":WatchMessages.TOGGLE_MUTE
         }];
         if(this.hasPlaylist)
         {
            this.shortcuts.push({
               "key":"<shift> N",
               "message":WatchMessages.NEXT
            },{
               "key":"<shift> P",
               "message":WatchMessages.PREVIOUS
            });
         }
         this.onMessageUpdate();
      }
      
      protected function onMessageUpdate(param1:MessageEvent = null) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         this.doneButton.labels["local"] = this.messages.getMessage(WatchMessages.DONE);
         this.doneButton.setLabel("local");
         this.title.text = this.messages.getMessage(WatchMessages.KEYBOARD_SHORTCUTS);
         this.shortcutText.text = "";
         for(_loc2_ in this.shortcuts)
         {
            _loc3_ = this.shortcuts[_loc2_];
            this.shortcutText.appendText(_loc3_.key + ": " + this.messages.getMessage(_loc3_.message) + "\n");
         }
         this.setSize(nominalWidth,nominalHeight);
      }
      
      protected function build() : void
      {
         this.dialogBounds = new Rectangle(0,0,390,240);
         this.title = Theme.newTextField(Theme.newTextFormat(Theme.H5_TEXT_SIZE));
         this.topDivider = new MenuDivider();
         this.topDivider.verticalMargin = 6;
         this.topDivider.horizontalStretch = 1;
         this.shortcutText = Theme.newTextField();
         this.shortcutTextElement = new LayoutElement(this.shortcutText);
         this.shortcutTextElement.verticalMargin = 6;
         this.bottomDivider = new MenuDivider();
         this.bottomDivider.verticalMargin = 6;
         this.bottomDivider.horizontalStretch = 1;
         this.doneButton = new TextButton(" ");
         this.doneButton.addEventListener(MouseEvent.CLICK,clickHandler(Event.COMPLETE));
         this.doneButton.padding = 6;
         footer.section("right").add(this.doneButton);
         footer.verticalMargin = 16;
         layout.add(this.title,this.topDivider,this.shortcutTextElement,this.bottomDivider,footer);
      }
   }
}

