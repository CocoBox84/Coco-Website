package com.google.youtube.application
{
   import flash.events.Event;
   
   public class AppStateChangeEvent extends Event
   {
      
      public static const STATE_CHANGE:String = "STATE_CHANGE";
      
      public var state:IAppState;
      
      public var oldState:IAppState;
      
      public function AppStateChangeEvent(param1:String, param2:IAppState, param3:IAppState)
      {
         this.state = param2;
         this.oldState = param3;
         super(param1,false,true);
      }
      
      override public function clone() : Event
      {
         return new AppStateChangeEvent(type,this.state,this.oldState);
      }
   }
}

