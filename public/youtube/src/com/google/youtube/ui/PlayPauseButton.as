package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.WatchMessages;
   
   public class PlayPauseButton extends ControlButton
   {
      
      public function PlayPauseButton(param1:IMessages = null)
      {
         nominalWidth = 55;
         super(param1);
         labels = {
            "play":Theme.newButton(PlayIcon),
            "pause":Theme.newButton(PauseIcon),
            "stop":Theme.newButton(StopIcon),
            "replay":Theme.newButton(ReplayIcon)
         };
         this.showPlay();
      }
      
      public function showPause() : void
      {
         setLabel("pause");
         if(messages)
         {
            accessibleName = messages.getMessage(WatchMessages.PAUSE);
            tooltipMessage = null;
         }
      }
      
      public function showPlay() : void
      {
         setLabel("play");
         if(messages)
         {
            accessibleName = messages.getMessage(WatchMessages.PLAY);
            tooltipMessage = null;
         }
      }
      
      public function showResume() : void
      {
         setLabel("play");
         if(messages)
         {
            accessibleName = messages.getMessage(WatchMessages.PLAY);
            tooltipMessage = WatchMessages.GOTO_LIVE_TOOLTIP;
         }
      }
      
      public function showReplay() : void
      {
         setLabel("replay");
         if(messages)
         {
            accessibleName = messages.getMessage(WatchMessages.REPLAY);
            tooltipMessage = null;
         }
      }
      
      public function showStop() : void
      {
         setLabel("stop");
         if(messages)
         {
            accessibleName = messages.getMessage(WatchMessages.STOP_DOWNLOAD);
            tooltipMessage = null;
         }
      }
   }
}

