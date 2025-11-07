package com.google.youtube.ui
{
   import com.google.utils.Scheduler;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class AnimatedElement extends LayoutElement
   {
      
      protected var pacemaker:Scheduler;
      
      public function AnimatedElement(param1:DisplayObject = null, param2:Number = 24)
      {
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.pacemaker = new Scheduler(Infinity,1000 / param2);
         this.pacemaker.stop();
         super(param1);
      }
      
      protected function onAddedToStage(param1:Event) : void
      {
         this.pacemaker.restart();
      }
      
      protected function onRemovedFromStage(param1:Event) : void
      {
         this.pacemaker.stop();
      }
   }
}

