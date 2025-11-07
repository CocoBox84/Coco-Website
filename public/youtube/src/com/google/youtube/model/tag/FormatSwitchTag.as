package com.google.youtube.model.tag
{
   import com.google.youtube.util.FlvUtils;
   import flash.net.NetStream;
   import flash.utils.ByteArray;
   
   public class FormatSwitchTag implements ITag
   {
      
      protected var oldFormat:TagFormat;
      
      protected var timestamp:uint;
      
      protected var newFormat:TagFormat;
      
      public function FormatSwitchTag(param1:uint, param2:TagFormat, param3:TagFormat)
      {
         super();
         this.timestamp = param1;
         this.oldFormat = param2;
         this.newFormat = param3;
      }
      
      public function feed(param1:NetStream) : void
      {
         var _loc2_:ByteArray = null;
         var _loc3_:ByteArray = null;
         var _loc4_:ByteArray = null;
         var _loc6_:ByteArray = null;
         if(this.oldFormat)
         {
            _loc2_ = new ByteArray();
            FlvUtils.writeEosTag(_loc2_,this.oldFormat.videoFormat.name,0);
            _loc4_ = new ByteArray();
            FlvUtils.writeScriptTag(_loc4_,"onPlayStatus",0,{
               "code":"NetStream.Play.SpliceComplete",
               "oldFormat":this.oldFormat.videoFormat.name,
               "format":this.newFormat.videoFormat.name
            });
         }
         else
         {
            _loc3_ = this.newFormat.metadata;
         }
         var _loc5_:Array = [_loc2_,_loc3_,this.newFormat.audioHeader,this.newFormat.videoHeader,_loc4_];
         for each(_loc6_ in _loc5_)
         {
            if(_loc6_)
            {
               FlvUtils.setTimestamp(_loc6_,this.timestamp);
               Object(param1).appendBytes(_loc6_);
            }
         }
      }
   }
}

