package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.WatchMessages;
   
   public class NextButton extends ControlButton
   {
      
      public function NextButton(param1:IMessages = null)
      {
         super(param1,Theme.newButton(NextIcon));
         tooltipMessage = WatchMessages.NEXT;
      }
   }
}

