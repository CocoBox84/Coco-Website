package com.google.youtube.model
{
   public class VideoStoryboard
   {
      
      private var urlPattern:String;
      
      private var indexOffset:int;
      
      private var levels:Array;
      
      public function VideoStoryboard(param1:String)
      {
         var _loc4_:Array = null;
         var _loc5_:VideoStoryboardLevel = null;
         this.levels = [];
         super();
         var _loc2_:Array = param1.split("|");
         this.urlPattern = _loc2_[0];
         var _loc3_:int = 1;
         while(_loc3_ < _loc2_.length && _loc3_ < 4)
         {
            _loc4_ = _loc2_[_loc3_].split("#");
            _loc5_ = new VideoStoryboardLevel(_loc3_ != 0);
            _loc5_.width = int(_loc4_[0]);
            _loc5_.height = int(_loc4_[1]);
            _loc5_.frames = int(_loc4_[2]);
            _loc5_.columns = int(_loc4_[3]);
            _loc5_.rows = int(_loc4_[4]);
            _loc5_.interval = int(_loc4_[5]);
            _loc5_.urlPattern = _loc4_[6];
            _loc5_.signature = _loc4_[7];
            _loc5_.init();
            this.levels.push(_loc5_);
            _loc3_++;
         }
      }
      
      public static function fromLiveFormat(param1:String) : VideoStoryboard
      {
         var _loc5_:Array = null;
         var _loc2_:Array = [];
         var _loc3_:Array = param1.split("|");
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_].split("#");
            _loc2_.push([_loc5_[1],_loc5_[2],0,_loc5_[3],_loc5_[4],0,_loc5_[0],""].join("#"));
            _loc4_++;
         }
         return new VideoStoryboard("$N|" + _loc2_.join("|"));
      }
      
      public function removeOrInitializeDefaultLevel(param1:Number) : void
      {
         if(this.numLevels > 1 && this.getLevel(0).urlPattern.indexOf("default") != -1)
         {
            this.levels.splice(0,1);
            this.indexOffset = 1;
            this.getLevel(0).clearBitmapDataCache = false;
            this.getLevel(0).init();
         }
         else
         {
            this.getLevel(0).interval = param1 * 1000 / this.getLevel(0).frames;
         }
      }
      
      public function getUrl(param1:int, param2:int) : String
      {
         var _loc3_:VideoStoryboardLevel = this.getLevel(param1);
         var _loc4_:String = this.urlPattern;
         _loc4_ = _loc4_.replace("$N",_loc3_.urlPattern);
         _loc4_ = _loc4_.replace("$L",(this.indexOffset + param1).toString());
         _loc4_ = _loc4_.replace("$M",param2.toString());
         if(_loc3_.signature)
         {
            _loc4_ += "?sigh=" + _loc3_.signature;
         }
         return _loc4_;
      }
      
      public function get numLevels() : int
      {
         return this.levels.length;
      }
      
      public function getLevel(param1:int) : VideoStoryboardLevel
      {
         return this.levels[param1];
      }
   }
}

