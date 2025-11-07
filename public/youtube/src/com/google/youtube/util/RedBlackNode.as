package com.google.youtube.util
{
   public class RedBlackNode
   {
      
      protected static const RED:Boolean = true;
      
      protected static const BLACK:Boolean = false;
      
      protected var right:RedBlackNode;
      
      protected var left:RedBlackNode;
      
      public var payload:Object;
      
      protected var rbcolor:Boolean;
      
      protected var key:uint;
      
      public function RedBlackNode(param1:uint, param2:Object, param3:Boolean)
      {
         super();
         this.key = param1;
         this.payload = param2;
         this.rbcolor = param3;
      }
      
      public static function insert(param1:RedBlackNode, param2:uint, param3:Object) : RedBlackNode
      {
         if(!param1)
         {
            return new RedBlackNode(param2,param3,RED);
         }
         if(param2 == param1.key)
         {
            param1.key = param2;
            param1.payload = param3;
         }
         else if(param2 < param1.key)
         {
            param1.left = insert(param1.left,param2,param3);
         }
         else
         {
            param1.right = insert(param1.right,param2,param3);
         }
         return param1.fixUp();
      }
      
      public static function rotateRight(param1:RedBlackNode) : RedBlackNode
      {
         var _loc2_:RedBlackNode = param1.left;
         param1.left = _loc2_.right;
         _loc2_.right = param1;
         _loc2_.rbcolor = _loc2_.right.rbcolor;
         _loc2_.right.rbcolor = RED;
         return _loc2_;
      }
      
      public static function deleteItem(param1:RedBlackNode, param2:uint) : RedBlackNode
      {
         var _loc3_:RedBlackNode = null;
         if(param2 < param1.key)
         {
            if(!isRed(param1.left) && !isRed(param1.left.left))
            {
               param1 = moveRedLeft(param1);
            }
            param1.left = deleteItem(param1.left,param2);
         }
         else
         {
            if(isRed(param1.left))
            {
               param1 = rotateRight(param1);
            }
            if(param2 == param1.key && param1.right == null)
            {
               return null;
            }
            if(!isRed(param1.right) && !isRed(param1.right.left))
            {
               param1 = moveRedRight(param1);
            }
            if(param2 == param1.key)
            {
               _loc3_ = minNode(param1.right);
               param1.key = _loc3_.key;
               param1.payload = _loc3_.payload;
               param1.right = deleteMin(param1.right);
            }
            else
            {
               param1.right = deleteItem(param1.right,param2);
            }
         }
         return param1.fixUp();
      }
      
      public static function maxNode(param1:RedBlackNode) : RedBlackNode
      {
         while(Boolean(param1) && Boolean(param1.right))
         {
            param1 = param1.right;
         }
         return param1;
      }
      
      public static function deleteMin(param1:RedBlackNode) : RedBlackNode
      {
         if(param1.left == null)
         {
            return null;
         }
         if(!isRed(param1.left) && !isRed(param1.left.left))
         {
            param1 = moveRedLeft(param1);
         }
         param1.left = deleteMin(param1.left);
         return param1.fixUp();
      }
      
      public static function rotateLeft(param1:RedBlackNode) : RedBlackNode
      {
         var _loc2_:RedBlackNode = param1.right;
         param1.right = _loc2_.left;
         _loc2_.left = param1;
         _loc2_.rbcolor = _loc2_.left.rbcolor;
         _loc2_.left.rbcolor = RED;
         return _loc2_;
      }
      
      public static function getAll(param1:RedBlackNode, param2:Array) : Array
      {
         if(param1)
         {
            getAll(param1.left,param2);
            param2.push(param1.payload);
            getAll(param1.right,param2);
         }
         return param2;
      }
      
      public static function maxDepth(param1:RedBlackNode) : uint
      {
         if(param1 == null)
         {
            return 0;
         }
         var _loc2_:uint = RedBlackNode.maxDepth(param1.left);
         var _loc3_:uint = RedBlackNode.maxDepth(param1.right);
         return 1 + Math.max(_loc2_,_loc3_);
      }
      
      public static function isRed(param1:RedBlackNode) : Boolean
      {
         return param1 ? param1.rbcolor == RED : false;
      }
      
      public static function moveRedLeft(param1:RedBlackNode) : RedBlackNode
      {
         param1.colorFlip();
         if(isRed(param1.right.left))
         {
            param1.right = rotateRight(param1.right);
            param1 = rotateLeft(param1);
            param1.colorFlip();
         }
         return param1;
      }
      
      public static function count(param1:RedBlackNode) : uint
      {
         if(param1 == null)
         {
            return 0;
         }
         return count(param1.left) + 1 + count(param1.right);
      }
      
      public static function lessThan(param1:RedBlackNode, param2:uint) : RedBlackNode
      {
         var _loc3_:RedBlackNode = null;
         while(param1)
         {
            if(param2 > param1.key)
            {
               if(!_loc3_ || param1.key > _loc3_.key)
               {
                  _loc3_ = param1;
               }
               param1 = param1.right;
            }
            else
            {
               param1 = param1.left;
            }
         }
         return _loc3_;
      }
      
      public static function minNode(param1:RedBlackNode) : RedBlackNode
      {
         while(Boolean(param1) && Boolean(param1.left))
         {
            param1 = param1.left;
         }
         return param1;
      }
      
      public static function greaterThanOrEqual(param1:RedBlackNode, param2:uint) : RedBlackNode
      {
         var _loc3_:RedBlackNode = null;
         while(param1)
         {
            if(param2 == param1.key)
            {
               return param1;
            }
            if(param2 < param1.key)
            {
               if(!_loc3_ || param1.key < _loc3_.key)
               {
                  _loc3_ = param1;
               }
               param1 = param1.left;
            }
            else
            {
               param1 = param1.right;
            }
         }
         return _loc3_;
      }
      
      public static function lessThanOrEqual(param1:RedBlackNode, param2:uint) : RedBlackNode
      {
         var _loc3_:RedBlackNode = null;
         while(param1)
         {
            if(param2 == param1.key)
            {
               return param1;
            }
            if(param2 > param1.key)
            {
               if(!_loc3_ || param1.key > _loc3_.key)
               {
                  _loc3_ = param1;
               }
               param1 = param1.right;
            }
            else
            {
               param1 = param1.left;
            }
         }
         return _loc3_;
      }
      
      public static function getNode(param1:RedBlackNode, param2:uint) : RedBlackNode
      {
         while(param1)
         {
            if(param2 == param1.key)
            {
               return param1;
            }
            if(param2 < param1.key)
            {
               param1 = param1.left;
            }
            else
            {
               param1 = param1.right;
            }
         }
         return null;
      }
      
      public static function deleteMax(param1:RedBlackNode) : RedBlackNode
      {
         if(isRed(param1.left))
         {
            param1 = rotateRight(param1);
         }
         if(param1.right == null)
         {
            return null;
         }
         if(!isRed(param1.right) && !isRed(param1.right.left))
         {
            param1 = moveRedRight(param1);
         }
         param1.right = deleteMax(param1.right);
         return param1.fixUp();
      }
      
      public static function greaterThan(param1:RedBlackNode, param2:uint) : RedBlackNode
      {
         var _loc3_:RedBlackNode = null;
         while(param1)
         {
            if(param2 < param1.key)
            {
               if(!_loc3_ || param1.key < _loc3_.key)
               {
                  _loc3_ = param1;
               }
               param1 = param1.left;
            }
            else
            {
               param1 = param1.right;
            }
         }
         return _loc3_;
      }
      
      public static function moveRedRight(param1:RedBlackNode) : RedBlackNode
      {
         param1.colorFlip();
         if(isRed(param1.left.left))
         {
            param1 = rotateRight(param1);
            param1.colorFlip();
         }
         return param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "";
         if(this.left)
         {
            _loc1_ += this.left.toString() + ",";
         }
         _loc1_ += this.payload.toString();
         if(this.right)
         {
            _loc1_ += "," + this.right.toString();
         }
         return _loc1_;
      }
      
      public function colorFlip() : void
      {
         this.rbcolor = !this.rbcolor;
         this.left.rbcolor = !this.left.rbcolor;
         this.right.rbcolor = !this.right.rbcolor;
      }
      
      public function makeBlack() : void
      {
         this.rbcolor = BLACK;
      }
      
      public function fixUp() : RedBlackNode
      {
         var _loc1_:RedBlackNode = this;
         if(isRed(_loc1_.right))
         {
            _loc1_ = rotateLeft(_loc1_);
         }
         if(isRed(_loc1_.left) && isRed(_loc1_.left.left))
         {
            _loc1_ = rotateRight(_loc1_);
         }
         if(isRed(_loc1_.left) && isRed(_loc1_.right))
         {
            _loc1_.colorFlip();
         }
         return _loc1_;
      }
   }
}

