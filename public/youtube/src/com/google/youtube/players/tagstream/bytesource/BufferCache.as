package com.google.youtube.players.tagstream.bytesource
{
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.util.RedBlackTree;
   import flash.utils.Dictionary;
   
   public class BufferCache
   {
      
      protected static var cache:Dictionary = new Dictionary();
      
      protected var tree:RedBlackTree;
      
      public function BufferCache(param1:VideoFormat)
      {
         super();
         cache[param1] = cache[param1] || new RedBlackTree();
         this.tree = cache[param1];
      }
      
      public function getGap(param1:uint) : Object
      {
         var _loc2_:HttpDiskByteSource = this.getBuffer(param1);
         var _loc3_:HttpDiskByteSource = _loc2_ ? this.lastBuffer(_loc2_) : null;
         if(Boolean(_loc3_) && _loc3_.last)
         {
            return null;
         }
         var _loc4_:Object = {};
         _loc4_.start = _loc2_ ? _loc3_.end : param1;
         var _loc5_:HttpDiskByteSource = HttpDiskByteSource(this.tree.greaterThanOrEqual(_loc4_.start));
         if(_loc5_)
         {
            _loc4_.end = _loc5_.getStart();
         }
         return _loc4_;
      }
      
      public function addBuffer(param1:HttpDiskByteSource) : void
      {
         this.tree.insert(param1.getStart(),param1);
      }
      
      public function get lastByte() : uint
      {
         var _loc1_:HttpDiskByteSource = HttpDiskByteSource(this.tree.maxNode());
         return _loc1_ ? _loc1_.end : 0;
      }
      
      protected function lastBuffer(param1:HttpDiskByteSource) : HttpDiskByteSource
      {
         var _loc2_:HttpDiskByteSource = null;
         while(true)
         {
            _loc2_ = this.getBuffer(param1.end);
            if(!_loc2_)
            {
               break;
            }
            param1 = _loc2_;
         }
         return param1;
      }
      
      public function getBufferAt(param1:uint) : HttpDiskByteSource
      {
         var _loc2_:HttpDiskByteSource = this.getBuffer(param1);
         if(_loc2_)
         {
            _loc2_.position = param1 - _loc2_.getStart();
         }
         return _loc2_;
      }
      
      protected function getBuffer(param1:uint) : HttpDiskByteSource
      {
         var _loc2_:HttpDiskByteSource = HttpDiskByteSource(this.tree.lessThanOrEqual(param1));
         return Boolean(_loc2_) && _loc2_.end > param1 ? _loc2_ : null;
      }
   }
}

