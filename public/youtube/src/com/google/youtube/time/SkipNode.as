package com.google.youtube.time
{
   public class SkipNode
   {
      
      public var value:Object;
      
      public var forward:Array = [];
      
      public function SkipNode(param1:Object)
      {
         super();
         this.value = param1;
      }
      
      public function get level() : int
      {
         return this.forward.length - 1;
      }
      
      public function get next() : SkipNode
      {
         return this.forward[0] || null;
      }
   }
}

