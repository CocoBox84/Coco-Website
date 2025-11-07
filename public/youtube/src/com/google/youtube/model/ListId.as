package com.google.youtube.model
{
   public class ListId
   {
      
      public static const ACTIVITY_FEED_LIST:String = "AF";
      
      public static const BRANDED_PLAYLIST:String = "BP";
      
      public static const FAVORITED_LIST:String = "FL";
      
      public static const PAID_CONTENT_LIST:String = "PC";
      
      public static const PLAYLIST:String = "PL";
      
      public static const RELATED_VIDEOS_LIST:String = "RV";
      
      public static const REMOTE_QUICKLIST:String = "RQ";
      
      public static const SEARCH_RESULTS_LIST:String = "SR";
      
      public static const USER_LIST:String = "UL";
      
      public static const USER_UPLOADS_LIST:String = "UU";
      
      public static const WATCH_LATER_LIST:String = "WL";
      
      private var idValue:String = "";
      
      private var typeValue:String = "";
      
      public function ListId(param1:String = "", param2:String = "")
      {
         super();
         this.type = param1;
         this.id = param2;
      }
      
      public static function fromString(param1:String) : ListId
      {
         if(Boolean(param1) && param1.length >= 2)
         {
            return new ListId(param1.substr(0,2),param1.substr(2));
         }
         return new ListId();
      }
      
      public function isEmpty() : Boolean
      {
         return !this.type && !this.id;
      }
      
      public function set type(param1:String) : void
      {
         this.typeValue = param1 || "";
      }
      
      public function toString() : String
      {
         return this.type + this.id;
      }
      
      public function get type() : String
      {
         return this.typeValue;
      }
      
      public function get id() : String
      {
         return this.idValue;
      }
      
      public function set id(param1:String) : void
      {
         this.idValue = this.type ? param1 || "" : "";
      }
      
      public function equals(param1:*, param2:Boolean = false) : Boolean
      {
         if(param1)
         {
            if(Boolean(param1.hasOwnProperty("type")) && Boolean(param1.hasOwnProperty("id")))
            {
               return this.type == param1.type && (this.id == param1.id || param2 && (!this.id || !param1.id));
            }
            if(param1 is String)
            {
               return this.equals(fromString(String(param1)),param2);
            }
         }
         return false;
      }
   }
}

