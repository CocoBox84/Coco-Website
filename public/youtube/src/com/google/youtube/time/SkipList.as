package com.google.youtube.time
{
   public class SkipList
   {
      
      protected static const MAX_LEVEL:int = 15;
      
      protected static const P:Number = 0.25;
      
      protected var head:SkipNode;
      
      protected var level:int = 0;
      
      protected var randomGenerator:Function;
      
      public function SkipList(param1:Function = null)
      {
         super();
         this.head = this.makeNode(null);
         this.randomGenerator = param1 || Math.random;
      }
      
      private function randomLevel() : uint
      {
         var _loc1_:uint = 0;
         while(this.randomGenerator() < P && _loc1_ <= this.level)
         {
            _loc1_++;
         }
         return _loc1_ > MAX_LEVEL ? uint(MAX_LEVEL) : _loc1_;
      }
      
      public function findAfter(param1:Object) : SkipNode
      {
         var _loc2_:Array = [];
         var _loc3_:SkipNode = this.find(param1,_loc2_);
         return _loc3_ ? _loc3_.next : _loc2_[0].next;
      }
      
      protected function removeNode(param1:SkipNode, param2:Array) : SkipNode
      {
         var _loc3_:int = 0;
         while(_loc3_ <= param1.level)
         {
            param2[_loc3_].forward[_loc3_] = param1.forward[_loc3_];
            _loc3_++;
         }
         while(!this.head.forward[this.level] && this.level > 0)
         {
            --this.level;
         }
         return param1;
      }
      
      public function remove(param1:Object) : SkipNode
      {
         var _loc2_:Array = [];
         var _loc3_:SkipNode = this.find(param1,_loc2_);
         if(_loc3_)
         {
            return this.removeNode(_loc3_,_loc2_);
         }
         return _loc3_;
      }
      
      public function get length() : uint
      {
         var _loc1_:uint = 0;
         var _loc2_:SkipNode = this.first;
         while(_loc2_ != null)
         {
            _loc1_++;
            _loc2_ = _loc2_.next;
         }
         return _loc1_;
      }
      
      public function find(param1:Object, param2:Array = null) : SkipNode
      {
         var _loc3_:SkipNode = this.head;
         var _loc4_:int = this.level;
         while(_loc4_ >= 0)
         {
            while(Boolean(_loc3_.forward[_loc4_]) && _loc3_.forward[_loc4_].value < param1)
            {
               _loc3_ = _loc3_.forward[_loc4_];
            }
            if(param2)
            {
               param2[_loc4_] = _loc3_;
            }
            _loc4_--;
         }
         _loc3_ = _loc3_.next;
         if(Boolean(_loc3_) && _loc3_.value == param1)
         {
            return _loc3_;
         }
         return null;
      }
      
      protected function makeNode(param1:Object) : SkipNode
      {
         return new SkipNode(param1);
      }
      
      public function insert(param1:Object) : SkipNode
      {
         var _loc2_:Array = [];
         var _loc3_:SkipNode = this.find(param1,_loc2_);
         if(_loc3_)
         {
            return _loc3_;
         }
         return this.insertNode(param1,_loc2_);
      }
      
      protected function insertNode(param1:Object, param2:Array) : SkipNode
      {
         var _loc3_:int = 0;
         var _loc4_:int = int(this.randomLevel());
         while(this.level < _loc4_)
         {
            var _loc6_:*;
            param2[_loc6_ = ++this.level] = this.head;
         }
         var _loc5_:SkipNode = this.makeNode(param1);
         _loc3_ = 0;
         while(_loc3_ <= _loc4_)
         {
            _loc5_.forward[_loc3_] = param2[_loc3_].forward[_loc3_];
            param2[_loc3_].forward[_loc3_] = _loc5_;
            _loc3_++;
         }
         return _loc5_;
      }
      
      public function get first() : SkipNode
      {
         return this.head.next || null;
      }
   }
}

