package com.google.utils
{
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   
   public class EventListenerGroup
   {
      
      private static const NULL_ARGUMENT_ERROR:String = " cannot be null.";
      
      private static const EVENT_GROUP_DISPOSED:String = "EventListenerGroup disposed.";
      
      private static const ADD_EVENT_NOT_ALLOWED_AFTER_EVENT_REMOVAL:String = "addEventCallback not allowed after event removal.";
      
      private var targetValue:IEventDispatcher;
      
      private var disposed:Boolean;
      
      private var attachedEventListeners:Array;
      
      private var useWeakReference:Boolean;
      
      private var originalEventListeners:Array;
      
      private var manuallyRemoveEventListeners:Boolean;
      
      public function EventListenerGroup(param1:IEventDispatcher, param2:Boolean = false, param3:Boolean = true)
      {
         super();
         if(param1 == null)
         {
            throw new ArgumentError("target" + NULL_ARGUMENT_ERROR);
         }
         this.targetValue = param1;
         this.manuallyRemoveEventListeners = param2;
         this.useWeakReference = param3;
         this.originalEventListeners = [];
         this.attachedEventListeners = [];
      }
      
      public function dispose() : void
      {
         if(!this.disposed)
         {
            this.removeEventListeners();
            this.originalEventListeners = null;
            this.attachedEventListeners = null;
            this.targetValue = null;
            this.disposed = true;
         }
      }
      
      private function removeEventListeners() : void
      {
         var _loc1_:EventListenerSettings = null;
         for each(_loc1_ in this.attachedEventListeners)
         {
            this.target.removeEventListener(_loc1_.name,_loc1_.callback,_loc1_.useCapture);
         }
         this.attachedEventListeners = [];
      }
      
      public function get target() : IEventDispatcher
      {
         return this.targetValue;
      }
      
      private function createAutoRemoveEventListenerGroupCallback(param1:Function) : Function
      {
         var currentEventCallback:Function = param1;
         return function(param1:Event):void
         {
            removeEventListeners();
            currentEventCallback.call(target,param1);
         };
      }
      
      public function registerOriginalEventListeners() : void
      {
         var _loc1_:EventListenerSettings = null;
         if(this.disposed)
         {
            throw new IllegalOperationError(EVENT_GROUP_DISPOSED);
         }
         if(this.attachedEventListeners.length == 0)
         {
            for each(_loc1_ in this.originalEventListeners)
            {
               this.addEventListenerHelper(_loc1_);
            }
         }
      }
      
      private function addEventListenerHelper(param1:EventListenerSettings) : void
      {
         var _loc2_:EventListenerSettings = null;
         if(this.manuallyRemoveEventListeners)
         {
            _loc2_ = param1;
         }
         else
         {
            _loc2_ = new EventListenerSettings(param1.name,this.createAutoRemoveEventListenerGroupCallback(param1.callback),param1.priority);
         }
         this.target.addEventListener(_loc2_.name,_loc2_.callback,_loc2_.useCapture,_loc2_.priority,this.useWeakReference);
         this.attachedEventListeners.push(_loc2_);
      }
      
      public function addEventCallback(param1:String, param2:Function, param3:int = 0, param4:Boolean = false) : void
      {
         if(this.disposed)
         {
            throw new IllegalOperationError(EVENT_GROUP_DISPOSED);
         }
         if(this.originalEventListeners.length != this.attachedEventListeners.length)
         {
            throw new IllegalOperationError(ADD_EVENT_NOT_ALLOWED_AFTER_EVENT_REMOVAL);
         }
         var _loc5_:EventListenerSettings = new EventListenerSettings(param1,param2,param3,param4);
         this.originalEventListeners.push(_loc5_);
         this.addEventListenerHelper(_loc5_);
      }
   }
}

