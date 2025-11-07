package com.google.utils
{
   import flash.system.Capabilities;
   import flash.utils.getDefinitionByName;
   
   public class PlayerVersion
   {
      
      protected static var thisVersion:PlayerVersion;
      
      public var minor:Number;
      
      public var major:Number;
      
      public var revision:Number;
      
      public var build:Number;
      
      public function PlayerVersion(param1:Number, param2:Number = 0, param3:Number = 0, param4:Number = 0)
      {
         super();
         this.major = param1;
         this.minor = param2;
         this.revision = param3;
         this.build = param4;
      }
      
      public static function getPlayerVersion() : PlayerVersion
      {
         var _loc1_:Array = null;
         if(!thisVersion)
         {
            _loc1_ = Capabilities.version.split(" ")[1].split(",");
            thisVersion = new PlayerVersion(_loc1_[0],_loc1_[1],_loc1_[2],_loc1_[3]);
         }
         return thisVersion;
      }
      
      public static function getPlayerOs() : String
      {
         return Capabilities.version.split(" ")[0];
      }
      
      public static function isAtLeastVersion(param1:Number, param2:Number = 0, param3:Number = 0, param4:Number = 0) : Boolean
      {
         return getPlayerVersion().isAtLeastVersion(param1,param2,param3,param4);
      }
      
      public function isAtLeastVersion(param1:Number, param2:Number = 0, param3:Number = 0, param4:Number = 0) : Boolean
      {
         if(this.major > param1)
         {
            return true;
         }
         if(this.major < param1)
         {
            return false;
         }
         if(this.minor > param2)
         {
            return true;
         }
         if(this.minor < param2)
         {
            return false;
         }
         if(this.revision > param3)
         {
            return true;
         }
         if(this.revision < param3)
         {
            return false;
         }
         return this.build >= param4;
      }
      
      public function isAtLeastPlayerVersion(param1:PlayerVersion) : Boolean
      {
         return this.isAtLeastVersion(param1.major,param1.minor,param1.revision,param1.build);
      }
   }
}

