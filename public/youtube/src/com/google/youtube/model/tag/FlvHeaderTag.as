package com.google.youtube.model.tag
{
   import com.google.youtube.util.FlvUtils;
   import flash.net.NetStream;
   import flash.utils.ByteArray;
   
   public class FlvHeaderTag implements ITag
   {
      
      public function FlvHeaderTag()
      {
         super();
      }
      
      public function feed(param1:NetStream) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         FlvUtils.writeFlvHeader(_loc2_);
         Object(param1).appendBytes(_loc2_);
      }
   }
}

