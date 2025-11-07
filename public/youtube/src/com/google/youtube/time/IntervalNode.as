package com.google.youtube.time
{
   import flash.utils.Dictionary;
   
   public class IntervalNode extends SkipNode
   {
      
      public var endpointMarkers:Dictionary = new Dictionary();
      
      public var owners:int = 0;
      
      public var markers:Array = [];
      
      public function IntervalNode(param1:Object)
      {
         super(param1);
      }
      
      public function addMarker(param1:int, param2:Object) : void
      {
         if(!this.markers[param1])
         {
            this.markers[param1] = new Dictionary();
         }
         this.markers[param1][param2] = true;
      }
      
      public function hasMarker(param1:int, param2:Object) : Boolean
      {
         return Boolean(this.markers[param1]) && Boolean(this.markers[param1][param2]);
      }
      
      public function removeMarker(param1:int, param2:Object) : void
      {
         if(this.markers[param1])
         {
            delete this.markers[param1][param2];
         }
      }
   }
}

