package com.google.youtube.model
{
   import com.google.youtube.util.AutoLoader;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class MosaicLoader extends EventDispatcher
   {
      
      protected var storyboard:VideoStoryboard;
      
      protected var loader:AutoLoader;
      
      protected var queue:Array = [];
      
      protected var bitmapData:Array = [];
      
      protected var loading:QueuedMosaicLoad;
      
      public function MosaicLoader(param1:VideoStoryboard)
      {
         super();
         this.storyboard = param1;
         this.loader = new AutoLoader();
         this.loader.addEventListener(Event.COMPLETE,this.onLoadComplete);
         this.loader.addEventListener(ErrorEvent.ERROR,this.onLoadError);
      }
      
      protected function loadNext() : void
      {
         var urlRequest:URLRequest = null;
         var context:LoaderContext = null;
         if(Boolean(this.queue.length) && !this.loading)
         {
            this.loading = this.queue.pop();
            if(this.storyboard.getLevel(this.loading.level).getBitmapData(this.loading.mosaic))
            {
               this.loading = null;
               this.loadNext();
            }
            else
            {
               urlRequest = new URLRequest(this.storyboard.getUrl(this.loading.level,this.loading.mosaic));
               context = new LoaderContext();
               context.checkPolicyFile = true;
               try
               {
                  this.loader.load(urlRequest,context);
               }
               catch(e:Error)
               {
                  loadError();
               }
            }
         }
      }
      
      public function getRect(param1:int) : Rectangle
      {
         var _loc3_:VideoStoryboardLevel = null;
         var _loc4_:int = 0;
         var _loc2_:int = this.storyboard.numLevels - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = this.storyboard.getLevel(_loc2_);
            _loc4_ = _loc3_.getMosaic(param1);
            if(_loc2_ == 0 || Boolean(_loc3_.getBitmapData(_loc4_)))
            {
               return _loc3_.getRect(param1);
            }
            _loc2_--;
         }
         return null;
      }
      
      protected function onLoadError(param1:Event) : void
      {
         this.loadError();
      }
      
      protected function loadError() : void
      {
         var _loc1_:BitmapData = new BitmapData(1,1,true,0);
         this.storyboard.getLevel(this.loading.level).setBitmapData(this.loading.mosaic,_loc1_);
         this.loading = null;
         this.loadNext();
      }
      
      protected function onLoadComplete(param1:Event) : void
      {
         var bitmapData:BitmapData = null;
         var event:Event = param1;
         try
         {
            bitmapData = Bitmap(this.loader.content).bitmapData;
         }
         catch(e:Error)
         {
            loadError();
            return;
         }
         this.storyboard.getLevel(this.loading.level).setBitmapData(this.loading.mosaic,bitmapData);
         this.loading = null;
         this.loadNext();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function getMosaic(param1:int, param2:Boolean = false) : BitmapData
      {
         var _loc4_:VideoStoryboardLevel = null;
         var _loc5_:int = 0;
         if(!this.queue.length)
         {
            this.loadMosaic(0,this.storyboard.getLevel(0).getMosaic(param1));
         }
         var _loc3_:int = this.storyboard.numLevels - 1;
         while(_loc3_ >= 0)
         {
            _loc4_ = this.storyboard.getLevel(_loc3_);
            _loc5_ = _loc4_.getMosaic(param1);
            if(_loc4_.getBitmapData(_loc5_))
            {
               return _loc4_.getBitmapData(_loc5_);
            }
            this.loadMosaic(_loc3_,_loc5_,param2);
            _loc3_--;
         }
         return null;
      }
      
      public function getIntervalPercentageForTime(param1:Number) : Number
      {
         var _loc3_:VideoStoryboardLevel = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         param1 *= 1000;
         var _loc2_:int = this.storyboard.numLevels - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = this.storyboard.getLevel(_loc2_);
            _loc4_ = param1 / _loc3_.interval;
            _loc5_ = _loc3_.getMosaic(_loc4_);
            if(_loc2_ == 0 || Boolean(_loc3_.getBitmapData(_loc5_)))
            {
               return param1 % _loc3_.interval / _loc3_.interval;
            }
            _loc2_--;
         }
         return 0;
      }
      
      public function getFrameForTime(param1:Number) : int
      {
         var _loc3_:VideoStoryboardLevel = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         param1 *= 1000;
         var _loc2_:int = this.storyboard.numLevels - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = this.storyboard.getLevel(_loc2_);
            _loc4_ = param1 / _loc3_.interval;
            _loc5_ = _loc3_.getMosaic(_loc4_);
            if(_loc2_ == 0 || Boolean(_loc3_.getBitmapData(_loc5_)))
            {
               return _loc4_;
            }
            _loc2_--;
         }
         return -1;
      }
      
      internal function loadMosaic(param1:int, param2:int, param3:Boolean = false) : void
      {
         var _loc6_:QueuedMosaicLoad = null;
         var _loc4_:VideoStoryboardLevel = this.storyboard.getLevel(param1);
         if(param1 < 0 || param2 < 0 || param1 >= this.storyboard.numLevels || _loc4_.numMosaics && param2 >= _loc4_.numMosaics)
         {
            return;
         }
         if(!param3 && (_loc4_.width >= 320 || _loc4_.height >= 180))
         {
            return;
         }
         if(_loc4_.getBitmapData(param2))
         {
            return;
         }
         if(this.loading && this.loading.level == param1 && this.loading.mosaic == param2)
         {
            return;
         }
         var _loc5_:int = int(this.queue.length - 1);
         while(_loc5_ >= 0)
         {
            _loc6_ = this.queue[_loc5_];
            if(_loc6_.level == param1 && _loc6_.mosaic == param2)
            {
               this.queue.push(this.queue.splice(_loc5_,1)[0]);
               return;
            }
            if(_loc6_.level == param1 && _loc4_.shouldCancel(_loc6_.mosaic,param2))
            {
               this.queue.splice(_loc5_,1);
            }
            _loc5_--;
         }
         this.queue.push(new QueuedMosaicLoad(param1,param2));
         this.loadNext();
      }
      
      public function loadLevel(param1:int = 0) : void
      {
         var _loc2_:VideoStoryboardLevel = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.storyboard.numLevels > 0)
         {
            _loc2_ = this.storyboard.getLevel(param1);
            if(_loc2_.numMosaics <= VideoStoryboardLevel.MAX_MOSAICS_TO_PRELOAD)
            {
               _loc3_ = 0;
               _loc4_ = _loc2_.numMosaics;
               while(_loc3_ < _loc4_)
               {
                  this.loadMosaic(0,_loc3_);
                  _loc3_++;
               }
            }
         }
      }
   }
}

class QueuedMosaicLoad
{
   
   public var mosaic:int;
   
   public var level:int;
   
   public function QueuedMosaicLoad(param1:int, param2:int)
   {
      super();
      this.level = param1;
      this.mosaic = param2;
   }
}
