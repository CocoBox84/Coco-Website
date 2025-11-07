package com.google.youtube.ui
{
   import com.google.ui.LineStyle;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.WatchMessages;
   import flash.display.Shape;
   
   public class ProgressBar extends UIElement
   {
      
      protected var progressBar:Shape = new Shape();
      
      protected var backgroundLineStyle:LineStyle;
      
      protected var progressBarColors:Array;
      
      protected var progressBarLineStyle:LineStyle;
      
      protected var percentValue:int = 0;
      
      protected var backgroundColors:Array;
      
      public function ProgressBar(param1:IMessages, param2:Array, param3:LineStyle, param4:Array, param5:LineStyle)
      {
         this.backgroundColors = param2;
         this.backgroundLineStyle = param3;
         this.progressBarColors = param4;
         this.progressBarLineStyle = param5;
         super();
         tabEnabled = true;
         isAccessible = true;
         addChild(this.progressBar);
         param1.addEventListener(MessageEvent.UPDATE,this.onMessageUpdate);
      }
      
      public function set percent(param1:int) : void
      {
         if(isNaN(param1) || param1 > 100 || param1 < 0)
         {
            return;
         }
         this.percentValue = param1;
         var _loc2_:int = Math.floor((nominalWidth - this.progressBarLineStyle.thickness) * (this.percentValue / 100));
         drawing(this.progressBar.graphics).clear().fill(this.progressBarColors,[1,1],[0,190],90,_loc2_,nominalHeight - this.progressBarLineStyle.thickness).rect(0,0,_loc2_,nominalHeight - this.progressBarLineStyle.thickness).end();
         accessibleDescription = this.percentValue.toString() + "% " + accessibleName;
      }
      
      protected function onMessageUpdate(param1:MessageEvent) : void
      {
         accessibleName = param1.messages.getMessage(WatchMessages.PROGRESS);
         accessibleDescription = this.percentValue.toString() + "% " + accessibleName;
      }
      
      override protected function redraw() : void
      {
         drawing(background.graphics).clear().fill(this.backgroundColors,[1,1],[0,190],90,nominalWidth,nominalHeight).rect(0,0,nominalWidth - this.backgroundLineStyle.thickness,nominalHeight - this.backgroundLineStyle.thickness).end();
         this.percent = this.percentValue;
      }
   }
}

