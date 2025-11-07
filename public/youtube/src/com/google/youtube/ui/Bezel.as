package com.google.youtube.ui
{
   import com.google.youtube.util.Tween;
   import flash.display.DisplayObject;
   
   public class Bezel extends LayoutElement
   {
      
      public static const PAUSE:DisplayObject = new PauseBezel();
      
      public static const PLAY:DisplayObject = new PlayBezel();
      
      public static const STOP:DisplayObject = new StopBezel();
      
      protected var currentIcon:DisplayObject;
      
      protected var animation:Tween;
      
      public function Bezel()
      {
         super();
         horizontalRegistration = 0.5;
         verticalRegistration = 0.5;
         this.animation = new Tween(this).pause().from({
            "scaleX":0.5,
            "scaleY":0.5,
            "alpha":1,
            "visible":true
         }).to({
            "scaleX":1,
            "scaleY":1,
            "alpha":0,
            "visible":false
         },500);
      }
      
      public function finish() : void
      {
         this.animation.finish();
      }
      
      public function play(param1:DisplayObject) : void
      {
         if(Boolean(this.currentIcon) && contains(this.currentIcon))
         {
            removeChild(this.currentIcon);
         }
         this.currentIcon = addChild(param1);
         this.animation.play();
      }
   }
}

