package com.google.youtube.model
{
   public class VideoQuality
   {
      
      private static var ORDER:Object = {
         "auto":0,
         "tiny":1,
         "light":2,
         "small":3,
         "medium":4,
         "large":5,
         "hd720":6,
         "hd1080":7,
         "highres":8
      };
      
      public static const AUTO:VideoQuality = new VideoQuality("auto");
      
      public static const TINY:VideoQuality = new VideoQuality("tiny");
      
      public static const LIGHT:VideoQuality = new VideoQuality("light");
      
      public static const SMALL:VideoQuality = new VideoQuality("small");
      
      public static const MEDIUM:VideoQuality = new VideoQuality("medium");
      
      public static const LARGE:VideoQuality = new VideoQuality("large");
      
      public static const HD720:VideoQuality = new VideoQuality("hd720");
      
      public static const HD1080:VideoQuality = new VideoQuality("hd1080");
      
      public static const HIGHRES:VideoQuality = new VideoQuality("highres");
      
      private var level:String;
      
      public function VideoQuality(param1:String = null)
      {
         super();
         this.level = validate(param1);
      }
      
      private static function validate(param1:String) : String
      {
         if(param1 in ORDER)
         {
            return param1;
         }
         return AUTO.toString();
      }
      
      public function isHd() : Boolean
      {
         return this >= HD720;
      }
      
      public function valueOf() : Object
      {
         return ORDER[this.level];
      }
      
      public function toString() : String
      {
         return this.level;
      }
      
      public function equals(param1:VideoQuality) : Boolean
      {
         return this.valueOf() == param1.valueOf();
      }
   }
}

