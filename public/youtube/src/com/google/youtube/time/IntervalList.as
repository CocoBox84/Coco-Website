package com.google.youtube.time
{
   import flash.utils.Dictionary;
   
   public class IntervalList extends SkipList
   {
      
      public function IntervalList(param1:Function = null)
      {
         super(param1);
      }
      
      private function adjustMarkersOnInsert(param1:SkipNode, param2:Array) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = undefined;
         var _loc6_:Array = null;
         var _loc5_:Dictionary = new Dictionary();
         _loc3_ = 0;
         while(_loc3_ < param1.level && Boolean(param1.forward[_loc3_ + 1]))
         {
            _loc6_ = [];
            for(_loc4_ in _loc5_)
            {
               if(!_loc4_.contains(int(param1.value),int(param1.forward[_loc3_ + 1].value)))
               {
                  IntervalNode(param1).addMarker(_loc3_,_loc4_);
                  _loc6_.push(_loc4_);
               }
               else
               {
                  this.removeMarkers(_loc4_,param1.forward[_loc3_],param1.forward[_loc3_ + 1],_loc3_);
               }
            }
            for each(_loc4_ in _loc6_)
            {
               delete _loc5_[_loc4_];
            }
            for(_loc4_ in param2[_loc3_].markers[_loc3_])
            {
               if(_loc4_.contains(int(param1.value),int(param1.forward[_loc3_ + 1].value)))
               {
                  this.removeMarkers(_loc4_,param1.forward[_loc3_],param1.forward[_loc3_ + 1],_loc3_);
                  _loc5_[_loc4_] = true;
               }
               else
               {
                  IntervalNode(param1).addMarker(_loc3_,_loc4_);
               }
            }
            _loc3_++;
         }
         for(_loc4_ in _loc5_)
         {
            IntervalNode(param1).addMarker(_loc3_,_loc4_);
         }
         for(_loc4_ in IntervalNode(param2[_loc3_]).markers[_loc3_])
         {
            IntervalNode(param1).addMarker(_loc3_,_loc4_);
         }
         _loc5_ = new Dictionary();
         _loc3_ = 0;
         while(_loc3_ < param1.level && !this.isHead(param2[_loc3_ + 1]))
         {
            _loc6_ = [];
            for(_loc4_ in _loc5_)
            {
               if(Boolean(_loc4_.contains(int(param2[_loc3_].value),int(param1.value))) && !_loc4_.contains(int(param2[_loc3_ + 1].value),int(param1.value)))
               {
                  IntervalNode(param2[_loc3_]).addMarker(_loc3_,_loc4_);
                  _loc6_.push(_loc4_);
               }
               else
               {
                  this.removeMarkers(_loc4_,param2[_loc3_ + 1],param1,_loc3_);
               }
            }
            for each(_loc4_ in _loc6_)
            {
               delete _loc5_[_loc4_];
            }
            for(_loc4_ in param2[_loc3_].markers[_loc3_])
            {
               if(_loc4_.contains(int(param2[_loc3_ + 1].value),int(param1.value)))
               {
                  this.removeMarkers(_loc4_,param2[_loc3_ + 1],param1,_loc3_);
                  _loc5_[_loc4_] = true;
               }
            }
            _loc3_++;
         }
         for(_loc4_ in _loc5_)
         {
            IntervalNode(param2[_loc3_]).addMarker(_loc3_,_loc4_);
         }
      }
      
      override protected function removeNode(param1:SkipNode, param2:Array) : SkipNode
      {
         this.adjustMarkersOnRemove(param1,param2);
         return super.removeNode(param1,param2);
      }
      
      public function findIntervalsAfter(param1:Object, param2:Object = null) : Array
      {
         var _loc3_:Array = [];
         var _loc4_:SkipNode = findAfter(param1);
         var _loc5_:SkipNode = param2 === null ? null : findAfter(param2);
         while(Boolean(_loc4_) && _loc4_ != _loc5_)
         {
            _loc3_ = _loc3_.concat(this.keys(IntervalNode(_loc4_).endpointMarkers));
            _loc4_ = _loc4_.next;
         }
         return _loc3_;
      }
      
      public function removeInterval(param1:IInterval) : void
      {
         var interval:IInterval = param1;
         var path:Array = [];
         var startNode:SkipNode = find(interval.start,path);
         var endNode:SkipNode = find(interval.end);
         if(!startNode || !endNode)
         {
            throw new ArgumentError("Interval not found: " + interval);
         }
         this.walkMarkers(interval,startNode,endNode,function(param1:IntervalNode, param2:int):void
         {
            if(!param1.hasMarker(param2,interval))
            {
               throw new ArgumentError("Interval not found: " + interval);
            }
            param1.removeMarker(param2,interval);
         });
         delete IntervalNode(startNode).endpointMarkers[interval];
         if(--IntervalNode(startNode).owners == 0)
         {
            this.removeNode(startNode,path);
         }
         endNode = find(interval.end,path);
         if(--IntervalNode(endNode).owners == 0)
         {
            this.removeNode(endNode,path);
         }
      }
      
      private function isHead(param1:SkipNode) : Boolean
      {
         return param1.value === null;
      }
      
      private function adjustMarkersOnRemove(param1:SkipNode, param2:Array) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = undefined;
         var _loc5_:Dictionary = new Dictionary();
         _loc3_ = param1.level;
         while(_loc3_ >= 0)
         {
            for(_loc4_ in _loc5_)
            {
               this.placeMarkers(_loc4_,param2[_loc3_ + 1],param2[_loc3_],_loc3_);
               if(Boolean(param1.forward[_loc3_]) && Boolean(_loc4_.contains(param2[_loc3_].value,param1.forward[_loc3_].value)))
               {
                  IntervalNode(param2[_loc3_]).addMarker(_loc3_,_loc4_);
                  delete _loc5_[_loc4_];
               }
            }
            for(_loc4_ in param2[_loc3_].markers[_loc3_])
            {
               if(!param1.forward[_loc3_] || !_loc4_.contains(param2[_loc3_].value,param1.forward[_loc3_].value))
               {
                  IntervalNode(param2[_loc3_]).removeMarker(_loc3_,_loc4_);
                  _loc5_[_loc4_] = true;
               }
            }
            _loc3_--;
         }
         _loc5_ = new Dictionary();
         _loc3_ = param1.level;
         while(_loc3_ >= 0)
         {
            for(_loc4_ in _loc5_)
            {
               this.placeMarkers(_loc4_,param1.forward[_loc3_],param1.forward[_loc3_ + 1],_loc3_);
               if(Boolean(param1.forward[_loc3_]) && Boolean(_loc4_.contains(param2[_loc3_].value,param1.forward[_loc3_].value)))
               {
                  delete _loc5_[_loc4_];
               }
            }
            for(_loc4_ in IntervalNode(param1).markers[_loc3_])
            {
               if(Boolean(param1.forward[_loc3_]) && (this.isHead(param2[_loc3_]) || !_loc4_.contains(param2[_loc3_].value,param1.forward[_loc3_].value)))
               {
                  _loc5_[_loc4_] = true;
               }
            }
            _loc3_--;
         }
      }
      
      private function walkMarkers(param1:IInterval, param2:SkipNode, param3:SkipNode, param4:Function) : void
      {
         var _loc5_:int = 0;
         var _loc6_:IntervalNode = IntervalNode(param2);
         while(Boolean(_loc6_.forward[_loc5_]) && param1.contains(int(_loc6_.value),int(_loc6_.forward[_loc5_].value)))
         {
            while(_loc5_ < _loc6_.level && _loc6_.forward[_loc5_ + 1] && param1.contains(int(_loc6_.value),int(_loc6_.forward[_loc5_ + 1].value)))
            {
               _loc5_++;
            }
            if(_loc6_.forward[_loc5_])
            {
               param4(_loc6_,_loc5_);
               _loc6_ = _loc6_.forward[_loc5_];
            }
         }
         while(_loc6_ != param3)
         {
            while(_loc5_ > 0 && (!_loc6_.forward[_loc5_] || !param1.contains(int(_loc6_.value),int(_loc6_.forward[_loc5_].value))))
            {
               _loc5_--;
            }
            param4(_loc6_,_loc5_);
            _loc6_ = _loc6_.forward[_loc5_];
         }
      }
      
      private function placeMarkers(param1:IInterval, param2:SkipNode, param3:SkipNode, param4:int) : void
      {
         while(Boolean(param2) && param2 != param3)
         {
            IntervalNode(param2).addMarker(param4,param1);
            param2 = param2.forward[param4];
         }
      }
      
      private function keys(param1:Dictionary) : Array
      {
         var _loc3_:* = undefined;
         var _loc2_:Array = [];
         for(_loc3_ in param1)
         {
            _loc2_.push(_loc3_);
         }
         return _loc2_;
      }
      
      public function findIntervals(param1:Object) : Array
      {
         var _loc5_:* = undefined;
         var _loc2_:Array = [];
         var _loc3_:SkipNode = head;
         var _loc4_:int = level;
         while(_loc4_ >= 0)
         {
            while(Boolean(_loc3_.forward[_loc4_]) && _loc3_.forward[_loc4_].value <= param1)
            {
               _loc3_ = _loc3_.forward[_loc4_];
            }
            _loc2_ = _loc2_.concat(this.keys(IntervalNode(_loc3_).markers[_loc4_]));
            _loc4_--;
         }
         if(_loc3_.value == param1)
         {
            for(_loc5_ in IntervalNode(_loc3_).endpointMarkers)
            {
               if(_loc5_.start == _loc5_.end)
               {
                  _loc2_.push(_loc5_);
               }
            }
         }
         return _loc2_;
      }
      
      override protected function makeNode(param1:Object) : SkipNode
      {
         return new IntervalNode(param1);
      }
      
      override protected function insertNode(param1:Object, param2:Array) : SkipNode
      {
         var _loc3_:SkipNode = super.insertNode(param1,param2);
         this.adjustMarkersOnInsert(_loc3_,param2);
         return _loc3_;
      }
      
      private function removeMarkers(param1:IInterval, param2:SkipNode, param3:SkipNode, param4:int) : void
      {
         while(Boolean(param2) && param2 != param3)
         {
            IntervalNode(param2).removeMarker(param4,param1);
            param2 = param2.forward[param4];
         }
      }
      
      public function insertInterval(param1:IInterval) : void
      {
         var interval:IInterval = param1;
         var startNode:SkipNode = insert(interval.start);
         var endNode:SkipNode = insert(interval.end);
         IntervalNode(startNode).endpointMarkers[interval] = true;
         ++IntervalNode(startNode).owners;
         ++IntervalNode(endNode).owners;
         this.walkMarkers(interval,startNode,endNode,function(param1:IntervalNode, param2:int):void
         {
            if(param1.hasMarker(param2,interval))
            {
               throw new ArgumentError("Interval already exists: " + interval);
            }
            param1.addMarker(param2,interval);
         });
      }
   }
}

