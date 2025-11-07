package com.google.utils
{
   internal class EventListenerSettings
   {
      
      private static const NULL_ARGUMENT_ERROR:String = " cannot be null.";
      
      private var nameValue:String;
      
      private var priorityValue:int;
      
      private var useCaptureValue:Boolean;
      
      private var callbackValue:Function;
      
      public function EventListenerSettings(param1:String, param2:Function, param3:int = 0, param4:Boolean = false)
      {
         super();
         if(param1 == null)
         {
            throw new ArgumentError("name" + NULL_ARGUMENT_ERROR);
         }
         if(param2 == null)
         {
            throw new ArgumentError("callback" + NULL_ARGUMENT_ERROR);
         }
         this.nameValue = param1;
         this.callbackValue = param2;
         this.priorityValue = param3;
         this.useCaptureValue = param4;
      }
      
      public function get callback() : Function
      {
         return this.callbackValue;
      }
      
      public function get name() : String
      {
         return this.nameValue;
      }
      
      public function get priority() : int
      {
         return this.priorityValue;
      }
      
      public function get useCapture() : Boolean
      {
         return this.useCaptureValue;
      }
   }
}

