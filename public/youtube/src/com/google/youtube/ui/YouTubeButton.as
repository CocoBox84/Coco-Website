package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.WatchMessages;
   
   public class YouTubeButton extends ControlButton
   {
      
      public function YouTubeButton(param1:IMessages)
      {
         nominalWidth = 52;
         super(param1,new (Theme.getClass("LogoIcon"))());
         tooltipMessage = WatchMessages.URL_NAVIGATE;
      }
   }
}

