package com.google.youtube.application
{
   public class ApplicationLayerManager
   {
      
      protected var applicationLayersById:Object = {};
      
      protected var propertyHandlerMap:Object = {};
      
      protected var applicationLayers:Array = [];
      
      public function ApplicationLayerManager()
      {
         super();
      }
      
      public function clearLayer(param1:String) : void
      {
         this.applyLayerUsingKeys(this.pullLayer(param1));
      }
      
      public function registerHandler(param1:String, param2:Function) : void
      {
         this.propertyHandlerMap[param1] = param2;
      }
      
      protected function pullLayer(param1:String) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         if(param1 in this.applicationLayersById)
         {
            _loc2_ = this.applicationLayersById[param1];
            delete this.applicationLayersById[param1];
            _loc3_ = Number(this.applicationLayers.indexOf(_loc2_));
            this.applicationLayers.splice(_loc3_,1);
            return _loc2_;
         }
         return null;
      }
      
      public function setLayer(param1:String, param2:Object = null) : void
      {
         var _loc4_:String = null;
         var _loc3_:Object = this.pullLayer(param1) || {};
         for(_loc4_ in param2)
         {
            _loc3_[_loc4_] = param2[_loc4_];
         }
         this.applicationLayers.push(_loc3_);
         this.applicationLayersById[param1] = _loc3_;
         this.applyLayerUsingKeys(_loc3_);
      }
      
      protected function applyLayerUsingKeys(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            if(_loc2_ in this.propertyHandlerMap)
            {
               this.propertyHandlerMap[_loc2_](this.getProperty(_loc2_));
            }
         }
      }
      
      protected function getProperty(param1:String) : *
      {
         var _loc2_:Number = this.applicationLayers.length - 1;
         while(_loc2_ >= 0)
         {
            if(param1 in this.applicationLayers[_loc2_])
            {
               return this.applicationLayers[_loc2_][param1];
            }
            _loc2_--;
         }
         return undefined;
      }
      
      public function registerHandlers(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            this.registerHandler(_loc2_,param1[_loc2_]);
         }
      }
   }
}

