package com.google.youtube.util
{
   import com.google.utils.Scheduler;
   import com.google.youtube.event.MouseActivityEvent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class MouseActivity extends EventDispatcher
   {
      
      protected var timeout:Scheduler;
      
      protected var stageAmbassador:StageAmbassador;
      
      protected var eventSource:DisplayObject;
      
      protected var last:Point = new Point(-1,-1);
      
      public function MouseActivity(param1:StageAmbassador, param2:DisplayObject, param3:uint = 2000)
      {
         super();
         this.stageAmbassador = param1;
         this.eventSource = param2;
         this.timeout = Scheduler.setTimeout(param3,this.onIdle);
         param2.addEventListener(Event.ACTIVATE,this.touch);
         param2.addEventListener(MouseEvent.MOUSE_MOVE,this.touch,true);
         param2.addEventListener(MouseEvent.MOUSE_DOWN,this.touch,true);
         param2.addEventListener(MouseEvent.MOUSE_UP,this.touch,true);
         param2.addEventListener(MouseEvent.MOUSE_WHEEL,this.touch,true);
         param2.addEventListener(MouseEvent.ROLL_OUT,this.onIdle);
         param2.addEventListener(Event.DEACTIVATE,this.onIdle);
         param1.addEventListener(Event.MOUSE_LEAVE,this.onIdle);
         param2.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      protected function onEnterFrame(param1:Event) : void
      {
         if(this.checkMouse())
         {
            this.touch(param1);
         }
      }
      
      protected function onIdle(param1:Event) : void
      {
         this.timeout.stop();
         this.checkMouse();
         dispatchEvent(new MouseActivityEvent(MouseActivityEvent.IDLE));
      }
      
      protected function checkMouse() : Boolean
      {
         var _loc1_:Point = new Point(this.stageAmbassador.mouseX,this.stageAmbassador.mouseY);
         if(!this.last.equals(_loc1_) && _loc1_.equals(_loc1_))
         {
            this.last = _loc1_;
            return true;
         }
         return false;
      }
      
      public function touch(param1:Event = null) : void
      {
         var _loc2_:Boolean = this.timeout.isRunning();
         this.timeout.restart();
         if(!_loc2_)
         {
            dispatchEvent(new MouseActivityEvent(MouseActivityEvent.ACTIVE));
         }
      }
   }
}

