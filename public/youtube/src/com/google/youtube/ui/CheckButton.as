package com.google.youtube.ui
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class CheckButton extends UIElement
   {
      
      private var checkedValue:Boolean;
      
      private var textField:TextField;
      
      private var button:Button;
      
      public function CheckButton()
      {
         super();
         this.button = new Button();
         this.button.labels = {
            "unchecked":CheckButtonUnchecked,
            "checked":CheckButtonChecked
         };
         addChild(this.button);
         this.checked = false;
         this.textField = Theme.newTextField(Theme.newTextFormat(Theme.DEFAULT_TEXT_SIZE,Theme.getConstant("FOREGROUND_TEXT_COLOR","dark")));
         this.textField.x = this.button.width + 4;
         this.textField.y = -4;
         addChild(this.textField);
         this.redraw();
      }
      
      public function set text(param1:String) : void
      {
         this.textField.text = param1;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         mouseEnabled = param1;
         mouseChildren = param1;
      }
      
      public function get checked() : Boolean
      {
         return this.checkedValue;
      }
      
      override public function onClick(param1:MouseEvent) : void
      {
         this.checked = !this.checked;
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function set checked(param1:Boolean) : void
      {
         this.checkedValue = param1;
         this.button.setLabel(param1 ? "checked" : "unchecked");
      }
      
      override protected function redraw() : void
      {
         super.redraw();
         if(nominalWidth)
         {
            Theme.autoSizeTextFieldToWidth(this.textField,nominalWidth - this.button.width - 4);
            if(nominalHeight)
            {
               this.textField.height = nominalHeight;
            }
         }
      }
      
      public function get text() : String
      {
         return this.textField.text;
      }
   }
}

