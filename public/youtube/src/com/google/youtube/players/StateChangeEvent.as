package com.google.youtube.players
{
   import flash.events.Event;
   
   public class StateChangeEvent extends Event
   {
      
      public static var STATE_CHANGE:String;
      
      public var state:IPlayerState;
      
      public var oldState:IPlayerState;
      
      public function StateChangeEvent(param1:String, param2:IPlayerState, param3:IPlayerState, param4:Boolean = false)
      {
         this.state = param2;
         this.oldState = param3;
         super(param1,param4,true);
      }
      
      override public function clone() : Event
      {
         return new StateChangeEvent(type,this.state,this.oldState,bubbles);
      }
   }
}

import com.google.youtube.event.registerEvents;

registerEvents(StateChangeEvent);

