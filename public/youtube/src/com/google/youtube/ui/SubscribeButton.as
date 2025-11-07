package com.google.youtube.ui
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.WatchMessages;
   
   public class SubscribeButton extends Button
   {
      
      protected static const HEIGHT:int = 24;
      
      protected static const HORIZONTAL_PADDING:int = 10;
      
      public function SubscribeButton(param1:IMessages)
      {
         super();
         labels = {
            "subscribe":{"up":[SubscribeIcon,param1.getMessage(WatchMessages.SUBSCRIBE)]},
            "unsubscribe":{
               "up":[SubscribedIcon,param1.getMessage(WatchMessages.SUBSCRIBED)],
               "over":[UnsubscribeIcon,param1.getMessage(WatchMessages.UNSUBSCRIBE)]
            }
         };
         setLabel("subscribe");
      }
      
      override protected function drawBackground() : void
      {
         var _loc1_:Object = Theme.getConstant("BUTTON_GRADIENT_COLORS",Theme.SUBSCRIBE_BUTTON_THEME);
         var _loc2_:int = Theme.getConstant("BUTTON_RADIUS",Theme.SUBSCRIBE_BUTTON_THEME);
         var _loc3_:* = forState(_loc1_);
         drawing(background.graphics).clear().stroke(1,Theme.getConstant("HIGHLIGHT_COLOR"),0.25).fill(_loc3_,null,null,90,nominalWidth,nominalHeight - 10).roundRect(0.5,0.5,int(nominalWidth) - 1,int(nominalHeight) - 1,_loc2_).end();
      }
      
      public function get subscribed() : Boolean
      {
         return labelValue == "unsubscribe";
      }
      
      public function set subscribed(param1:Boolean) : void
      {
         if(param1)
         {
            setLabel("unsubscribe");
         }
         else
         {
            setLabel("subscribe");
         }
      }
      
      override protected function drawForeground() : void
      {
         var _loc1_:int = Theme.getConstant("BUTTON_RADIUS",Theme.SUBSCRIBE_BUTTON_THEME);
         var _loc2_:Drawing = drawing(foreground.graphics).clear();
         if(enabled)
         {
            _loc2_.fill(0,0);
         }
         else
         {
            _loc2_.fill([Theme.getConstant("DISABLED_COLOR"),Theme.getConstant("DISABLED_SHADOW_COLOR")],[Theme.getConstant("DISABLED_ALPHA"),Theme.getConstant("DISABLED_ALPHA")],[35,255],90,nominalWidth,nominalHeight);
         }
         _loc2_.roundRect(0.5,0.5,int(nominalWidth) - 1,int(nominalHeight) - 1,_loc1_).end();
      }
      
      override protected function alignContents() : void
      {
         nominalHeight = HEIGHT;
         nominalWidth = elementContainer.width + HORIZONTAL_PADDING * 2;
         super.alignContents();
      }
   }
}

