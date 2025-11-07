package com.google.youtube.model
{
   import com.google.utils.RequestLoader;
   import com.google.youtube.event.ShuffleEvent;
   import flash.net.URLRequest;
   
   public class Playlist extends RequestLoader
   {
      
      protected static const PLAYLIST_ID_LENGTH:int = 16;
      
      protected static const LIST_URL:String = "list_ajax";
      
      protected static const SEARCH_URL:String = "search_ajax";
      
      protected static const LIST_ACTION:String = "action_get_list";
      
      protected static const USER_PLAYLIST_UPLOADS_TYPE:String = "user_uploads";
      
      protected static const USER_PLAYLIST_UPLOADS_ACTION:String = "action_get_user_uploads_by_user";
      
      protected static const USER_PLAYLIST_FAVORITES_TYPE:String = "user_favorites";
      
      protected static const USER_PLAYLIST_FAVORITES_ACTION:String = "action_get_favorited_by_user";
      
      protected static const SEARCH:String = "search";
      
      protected var items:Array;
      
      protected var useMusicOneBox:Boolean;
      
      public var loaded:Boolean = false;
      
      protected var loading:Boolean = false;
      
      protected var order:Array;
      
      protected var indexValue:int;
      
      public var title:String = "";
      
      public var listId:ListId;
      
      protected var baseUrl:String;
      
      public var loop:Boolean;
      
      protected var lengthValue:int;
      
      public var startSeconds:Number = 0;
      
      protected var shuffleValue:Boolean;
      
      public function Playlist(param1:Object, param2:Boolean = false, param3:Boolean = false, param4:int = 0, param5:Number = 0, param6:String = "", param7:Boolean = true)
      {
         var _loc9_:int = 0;
         this.items = [];
         this.order = [];
         super();
         this.index = param4;
         this.baseUrl = param6 || YouTubeEnvironment.LIVE_BASE_URL;
         if(param1.mob == "1")
         {
            this.useMusicOneBox = true;
         }
         if(param1.video_id)
         {
            this.items[param4] = new VideoData(param1);
         }
         if(param1.api)
         {
            if(param1.api is String && param1.api.length == PLAYLIST_ID_LENGTH)
            {
               param1.list = ListId.PLAYLIST + param1.api;
            }
            else
            {
               param1.playlist = param1.api;
            }
         }
         var _loc8_:Array = [];
         if(param1.list)
         {
            switch(param1.listType)
            {
               case USER_PLAYLIST_UPLOADS_TYPE:
                  this.loadUserUploadsByUsername(param1.list);
                  break;
               case USER_PLAYLIST_FAVORITES_TYPE:
                  this.loadUserFavoritesByUsername(param1.list);
                  break;
               case SEARCH:
                  this.loadSearch(param1.list);
                  break;
               default:
                  this.listId = ListId.fromString(param1.list);
                  if(!param1.playlist_title && param7)
                  {
                     this.loadPlaylistById(this.listId.id);
                     break;
                  }
                  this.title = param1.playlist_title;
                  this.lengthValue = param1.playlist_length;
            }
         }
         else if(param1.playlist is String)
         {
            _loc8_ = param1.playlist.split(",");
         }
         else if(param1.playlist is Array)
         {
            _loc8_ = param1.playlist;
         }
         if(_loc8_.length)
         {
            if(param4 > 0)
            {
               this.items = [];
            }
            _loc9_ = 0;
            while(_loc9_ < _loc8_.length)
            {
               if(_loc8_[_loc9_])
               {
                  this.items.push(new VideoData(_loc8_[_loc9_]));
               }
               _loc9_++;
            }
            this.resetOrder();
            this.loaded = true;
         }
         this.shuffle = param3;
         this.loop = param2;
         this.startSeconds = param5;
      }
      
      public function loadUserFavoritesByUsername(param1:String) : void
      {
         if(this.loading)
         {
            return;
         }
         this.listId = new ListId(ListId.FAVORITED_LIST,"PLAYER_" + param1);
         this.loadPlaylist(USER_PLAYLIST_FAVORITES_ACTION,"username=" + param1);
      }
      
      public function getVideo(param1:int = -1) : VideoData
      {
         if(!this.loaded)
         {
            if(!this.loading && this.listId && this.listId.type == ListId.PLAYLIST)
            {
               this.loadPlaylistById(this.listId.id);
            }
            return null;
         }
         if(param1 < 0)
         {
            param1 = this.index;
         }
         else if(param1 >= this.items.length && this.loop)
         {
            param1 = 0;
         }
         return param1 in this.items ? this.items[this.order[param1]] : null;
      }
      
      public function get isResumableList() : Boolean
      {
         return Boolean(this.listId) && this.listId.type == ListId.WATCH_LATER_LIST;
      }
      
      public function loadPlaylistById(param1:String = null, param2:String = null) : void
      {
         if(this.loading)
         {
            return;
         }
         if(this.listId)
         {
            param1 = this.listId.id;
            param2 = this.listId.type;
         }
         else if(!param1)
         {
            return;
         }
         param2 ||= ListId.PLAYLIST;
         this.loadPlaylist(LIST_ACTION,"list=" + param2 + param1);
      }
      
      public function get index() : int
      {
         return this.indexValue;
      }
      
      public function getVideos() : Array
      {
         return this.items.concat();
      }
      
      public function get shuffle() : Boolean
      {
         return this.shuffleValue;
      }
      
      public function set index(param1:int) : void
      {
         this.indexValue = Math.max(0,param1);
         this.startSeconds = 0;
      }
      
      public function loadPlaylist(param1:String, param2:String = null) : void
      {
         var _loc3_:URLRequest = new URLRequest();
         _loc3_.url = this.baseUrl + LIST_URL + "?" + param1 + "=1&style=xml";
         if(param2)
         {
            _loc3_.url += "&" + param2;
         }
         this.loading = true;
         loadRequest(_loc3_);
      }
      
      protected function resetOrder() : void
      {
         var _loc1_:int = this.index in this.order ? int(this.order[this.index]) : this.index;
         this.order = [];
         var _loc2_:int = 0;
         while(_loc2_ < this.items.length)
         {
            this.order.push(_loc2_);
            _loc2_++;
         }
         this.index = _loc1_;
      }
      
      override protected function parseLoadedData(param1:*) : void
      {
         var loadedData:XML = null;
         var currentIndex:int = 0;
         var item:XML = null;
         var data:* = param1;
         var dataItems:Array = [];
         var videoData:VideoData = this.items.length ? this.items[this.index] : null;
         try
         {
            loadedData = XML(data);
            this.title = loadedData.title;
            currentIndex = 0;
            for each(item in loadedData.video)
            {
               dataItems.push(new VideoData({
                  "video_id":String(item.encrypted_id),
                  "author":String(item.author),
                  "title":String(item.title),
                  "length_seconds":String(item.length_seconds),
                  "start":(Number(item.start) ? String(item.start) : NaN),
                  "end":(Number(item.end) ? String(item.end) : NaN),
                  "list":String(this.listId)
               }));
               if(Boolean(videoData) && item.encrypted_id == videoData.videoId)
               {
                  this.indexValue = currentIndex;
               }
               currentIndex++;
            }
            this.items = dataItems;
            this.resetOrder();
            this.loading = false;
            this.loaded = true;
         }
         catch(e:Error)
         {
         }
      }
      
      public function get length() : Number
      {
         return this.loaded ? this.items.length : this.lengthValue;
      }
      
      public function getNext() : VideoData
      {
         return this.getVideo(++this.index >= this.items.length && this.loop ? (this.index = 0) : this.index);
      }
      
      public function hasNext() : Boolean
      {
         return this.loop ? true : this.index + 1 < this.items.length;
      }
      
      public function loadSearch(param1:String) : void
      {
         this.listId = new ListId(ListId.SEARCH_RESULTS_LIST,param1);
         var _loc2_:URLRequest = new URLRequest();
         _loc2_.url = this.baseUrl + SEARCH_URL + "?search_query=" + param1 + "&style=xml&embeddable=1";
         if(this.useMusicOneBox)
         {
            _loc2_.url += "&mob=1";
         }
         this.loading = true;
         loadRequest(_loc2_);
      }
      
      protected function shuffleVideos() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:int = int(this.order[this.index]);
         var _loc2_:int = 1;
         while(_loc2_ < this.order.length)
         {
            _loc3_ = Math.floor(Math.random() * (_loc2_ + 1));
            _loc4_ = int(this.order[_loc2_]);
            this.order[_loc2_] = this.order[_loc3_];
            this.order[_loc3_] = _loc4_;
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this.order.length)
         {
            if(this.order[_loc2_] == _loc1_)
            {
               this.index = _loc2_;
            }
            _loc2_++;
         }
      }
      
      public function getPrevious() : VideoData
      {
         return this.getVideo(--this.index < 0 && this.loop ? (this.index = this.length - 1) : this.index);
      }
      
      public function loadUserUploadsByUsername(param1:String) : void
      {
         if(this.loading)
         {
            return;
         }
         this.listId = new ListId(ListId.USER_UPLOADS_LIST,"PLAYER_" + param1);
         this.loadPlaylist(USER_PLAYLIST_UPLOADS_ACTION,"username=" + param1);
      }
      
      public function set shuffle(param1:Boolean) : void
      {
         this.shuffleValue = param1;
         this.resetOrder();
         if(this.shuffleValue)
         {
            this.shuffleVideos();
         }
         dispatchEvent(new ShuffleEvent(ShuffleEvent.CHANGE));
      }
   }
}

