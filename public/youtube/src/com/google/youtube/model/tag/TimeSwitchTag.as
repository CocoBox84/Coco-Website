package com.google.youtube.model.tag
{
   import com.google.youtube.util.getDefinition;
   import flash.net.NetStream;
   
   public class TimeSwitchTag implements ITag
   {
      
      protected static const NetStreamAppendBytesAction:Object = getDefinition("flash.net.NetStreamAppendBytesAction");
      
      public function TimeSwitchTag()
      {
         super();
      }
      
      public function feed(param1:NetStream) : void
      {
         Object(param1).appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
      }
   }
}

