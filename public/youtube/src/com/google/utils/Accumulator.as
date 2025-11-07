package com.google.utils
{
   public class Accumulator
   {
      
      protected var max:Number;
      
      protected var count:int;
      
      protected var min:Number;
      
      protected var sum:Number;
      
      public function Accumulator()
      {
         super();
         this.clear();
      }
      
      public function add(param1:Number) : void
      {
         if(!isNaN(param1))
         {
            this.sum += param1;
            if(this.count == 0 || param1 < this.min)
            {
               this.min = param1;
            }
            if(this.count == 0 || param1 > this.max)
            {
               this.max = param1;
            }
            ++this.count;
         }
      }
      
      public function clear() : void
      {
         this.sum = 0;
         this.count = 0;
      }
      
      public function getMax() : Number
      {
         return this.max;
      }
      
      public function getCount() : Number
      {
         return this.count;
      }
      
      public function getMean() : Number
      {
         if(this.count > 0)
         {
            return this.sum / this.count;
         }
         return NaN;
      }
      
      public function getMin() : Number
      {
         return this.min;
      }
   }
}

