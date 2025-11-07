package com.google.youtube.util
{
   public class RedBlackTree
   {
      
      protected var root:RedBlackNode;
      
      public function RedBlackTree()
      {
         super();
      }
      
      protected static function payloadOrNull(param1:RedBlackNode) : Object
      {
         return param1 ? param1.payload : null;
      }
      
      public function find(param1:uint) : Object
      {
         return payloadOrNull(RedBlackNode.getNode(this.root,param1));
      }
      
      public function maxNode() : Object
      {
         return payloadOrNull(RedBlackNode.maxNode(this.root));
      }
      
      public function deleteMin() : void
      {
         this.root = RedBlackNode.deleteMin(this.root);
         if(this.root)
         {
            this.root.makeBlack();
         }
      }
      
      public function deleteMax() : void
      {
         this.root = RedBlackNode.deleteMax(this.root);
         if(this.root)
         {
            this.root.makeBlack();
         }
      }
      
      public function getAll() : Array
      {
         return RedBlackNode.getAll(this.root,new Array());
      }
      
      public function toString() : String
      {
         return "RedBlackTree(" + this.root.toString() + ")";
      }
      
      public function get empty() : Boolean
      {
         return this.root == null;
      }
      
      public function count() : uint
      {
         return RedBlackNode.count(this.root);
      }
      
      public function minNode() : Object
      {
         return payloadOrNull(RedBlackNode.minNode(this.root));
      }
      
      public function greaterThanOrEqual(param1:uint) : Object
      {
         return payloadOrNull(RedBlackNode.greaterThanOrEqual(this.root,param1));
      }
      
      public function lessThanOrEqual(param1:uint) : Object
      {
         return payloadOrNull(RedBlackNode.lessThanOrEqual(this.root,param1));
      }
      
      public function insert(param1:uint, param2:Object) : void
      {
         this.root = RedBlackNode.insert(this.root,param1,param2);
      }
      
      public function lessThan(param1:uint) : Object
      {
         return payloadOrNull(RedBlackNode.lessThan(this.root,param1));
      }
      
      public function greaterThan(param1:uint) : Object
      {
         return payloadOrNull(RedBlackNode.greaterThan(this.root,param1));
      }
      
      public function deleteItem(param1:uint) : void
      {
         this.root = RedBlackNode.deleteItem(this.root,param1);
         this.root.makeBlack();
      }
      
      public function maxDepth() : uint
      {
         return RedBlackNode.maxDepth(this.root);
      }
   }
}

