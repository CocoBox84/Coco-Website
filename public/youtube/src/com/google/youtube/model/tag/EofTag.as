package com.google.youtube.model.tag
{
   import com.google.youtube.util.FlvUtils;
   import com.google.youtube.util.getDefinition;
   import flash.net.NetStream;
   import flash.utils.ByteArray;
   
   public class EofTag implements ITag
   {
      
      protected static const NetStreamAppendBytesAction:Object = getDefinition("flash.net.NetStreamAppendBytesAction");
      
      protected var timestampValue:uint;
      
      public function EofTag(param1:uint)
      {
         super();
         this.timestampValue = param1 + 30;
      }
      
      public function feed(param1:NetStream) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         FlvUtils.writeScriptTag(_loc2_,"onPlayStatus",this.timestamp,{"code":"NetStream.Play.Complete"});
         Object(param1).appendBytes(_loc2_);
         Object(param1).appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
      }
      
      public function set timestamp(param1:uint) : void
      {
         this.timestampValue = param1;
      }
      
      public function get timestamp() : uint
      {
         return this.timestampValue;
      }
   }
}

