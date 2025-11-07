package com.google.youtube.util
{
   public class SlidingPercentile
   {
      
      protected static const SORT_BY_VALUE:int = 0;
      
      protected static const SORT_BY_INDEX:int = 1;
      
      protected var values:Array = [];
      
      protected var sampleIndex:int;
      
      protected var sortedBy:int = -1;
      
      protected var totalWeightValue:Number = 0;
      
      protected var maxWeight:Number;
      
      public function SlidingPercentile(param1:Number)
      {
         super();
         this.maxWeight = param1;
      }
      
      protected function sortByValue() : void
      {
         if(this.sortedBy != SORT_BY_VALUE)
         {
            this.values.sortOn("value",Array.NUMERIC);
            this.sortedBy = SORT_BY_VALUE;
         }
      }
      
      public function addSample(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         this.sortByIndex();
         this.values.push({
            "index":this.sampleIndex++,
            "weight":param1,
            "value":param2
         });
         this.totalWeightValue += param1;
         while(this.totalWeightValue > this.maxWeight)
         {
            _loc3_ = this.totalWeightValue - this.maxWeight;
            if(this.values[0].weight <= _loc3_)
            {
               this.totalWeightValue -= this.values[0].weight;
               this.values.shift();
            }
            else
            {
               this.values[0].weight -= _loc3_;
               this.totalWeightValue -= _loc3_;
            }
         }
      }
      
      protected function sortByIndex() : void
      {
         if(this.sortedBy != SORT_BY_INDEX)
         {
            this.values.sortOn("index",Array.NUMERIC);
            this.sortedBy = SORT_BY_INDEX;
         }
      }
      
      public function percentile(param1:Number) : Number
      {
         var _loc4_:Object = null;
         this.sortByValue();
         var _loc2_:Number = param1 * this.totalWeightValue;
         var _loc3_:Number = 0;
         for each(_loc4_ in this.values)
         {
            _loc3_ += _loc4_.weight;
            if(_loc3_ >= _loc2_)
            {
               return _loc4_.value;
            }
         }
         return this.values.length > 0 ? Number(this.values[this.values.length - 1].value) : NaN;
      }
   }
}

