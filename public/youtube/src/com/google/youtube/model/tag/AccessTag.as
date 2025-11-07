package com.google.youtube.model.tag
{
   import com.google.youtube.util.FlvUtils;
   import flash.net.NetStream;
   import flash.utils.ByteArray;
   
   public class AccessTag implements ITag
   {
      
      private var ts:uint;
      
      public function AccessTag(param1:uint)
      {
         super();
         this.ts = param1;
      }
      
      public function feed(param1:NetStream) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         FlvUtils.writeScriptedAccess(_loc2_,this.ts);
         Object(param1).appendBytes(_loc2_);
      }
   }
}

