package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.WatchMessages;
   
   public class SizeButton extends ControlButton
   {
      
      protected var small:Boolean;
      
      public function SizeButton(param1:IMessages = null, param2:Boolean = true)
      {
         this.small = param2;
         super(param1);
         var _loc3_:Class = param2 ? SmallPlayerIcon : LargerPlayerIcon;
         tooltipMessage = param2 ? WatchMessages.SHRINK : WatchMessages.EXPAND;
         labels = {
            "normal":Theme.newButton(_loc3_),
            "active":Theme.newActiveButton(_loc3_)
         };
         setLabel("normal");
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         alpha = 1;
      }
      
      public function showSmall() : void
      {
         this.enabled = !this.small;
         setLabel(this.small ? "active" : "normal");
      }
      
      public function showLarge() : void
      {
         this.enabled = this.small;
         setLabel(!this.small ? "active" : "normal");
      }
   }
}

