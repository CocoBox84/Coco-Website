package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.WatchMessages;
   
   public class FullScreenButton extends ControlButton
   {
      
      public function FullScreenButton(param1:IMessages = null)
      {
         super(param1);
         tooltipMessage = WatchMessages.FULLSCREEN;
         labels = {
            "normal":Theme.newButton(NormalScreenIcon),
            "fullscreen":Theme.newButton(FullScreenIcon)
         };
         setLabel("fullscreen");
         tabEnabled = false;
         isAccessible = false;
      }
      
      public function showFullScreen() : void
      {
         tooltipMessage = WatchMessages.FULLSCREEN;
         setLabel("fullscreen");
      }
      
      public function showNormal() : void
      {
         tooltipMessage = WatchMessages.EXIT_FULLSCREEN;
         setLabel("normal");
      }
   }
}

