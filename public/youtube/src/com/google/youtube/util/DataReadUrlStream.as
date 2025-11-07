package com.google.youtube.util
{
   import com.google.utils.IDataRead;
   import flash.events.Event;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   
   public class DataReadUrlStream extends URLStream implements IDataRead
   {
      
      protected var complete:Boolean;
      
      public function DataReadUrlStream()
      {
         super();
         addEventListener(Event.COMPLETE,this.onComplete);
      }
      
      protected function onComplete(param1:Event) : void
      {
         this.complete = true;
      }
      
      public function get eof() : Boolean
      {
         return this.complete && (!connected || bytesAvailable == 0);
      }
      
      public function read(param1:ByteArray, param2:uint, param3:uint) : uint
      {
         var _loc4_:uint = Math.min(bytesAvailable,param3);
         readBytes(param1,param2,_loc4_);
         return _loc4_;
      }
   }
}

