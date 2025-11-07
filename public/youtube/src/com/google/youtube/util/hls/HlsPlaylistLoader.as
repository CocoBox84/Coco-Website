package com.google.youtube.util.hls
{
   import com.google.utils.Scheduler;
   import com.google.utils.Url;
   import flash.errors.EOFError;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   
   public class HlsPlaylistLoader extends EventDispatcher
   {
      
      public static var enableRangeRequests:Boolean;
      
      public static var enableStartSeqRequests:Boolean = true;
      
      protected static const SCHEDULER:Object = Scheduler;
      
      public static var maxChunkToProcess:uint = 65536;
      
      protected var data:ByteArray = new ByteArray();
      
      protected var trailingBytes:ByteArray;
      
      protected var reschedule:Scheduler;
      
      protected var playlist:HlsPlaylist;
      
      protected var urlStream:URLStream = new URLStream();
      
      protected var complete:Boolean;
      
      protected var parser:HlsParser;
      
      public function HlsPlaylistLoader(param1:String, param2:HlsParser = null, param3:URLStream = null)
      {
         super();
         this.playlist = new HlsPlaylist(param1,null);
         param2 ||= new HlsParser();
         this.parser = param2;
         param3 ||= new URLStream();
         this.urlStream = param3;
         param3.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         param3.addEventListener(Event.COMPLETE,this.onProgress);
         param3.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.dispatchEvent);
         param3.addEventListener(IOErrorEvent.IO_ERROR,this.dispatchEvent);
      }
      
      override public function dispatchEvent(param1:Event) : Boolean
      {
         if(param1 is ErrorEvent)
         {
            this.trailingBytes = null;
            this.playlist = new HlsPlaylist(this.playlist.url,null);
         }
         return super.dispatchEvent(param1);
      }
      
      public function load(param1:Array) : void
      {
         var _loc2_:URLRequest = null;
         var _loc3_:Url = null;
         var _loc4_:Url = null;
         if(this.urlStream.connected)
         {
            this.urlStream.close();
         }
         this.data.length = 0;
         this.complete = false;
         this.playlist.siblingPlaylists = param1;
         if(this.playlist.dvr && enableStartSeqRequests)
         {
            _loc3_ = new Url(this.playlist.url);
            _loc3_.queryVars.start_seq = this.playlist.chunkUrl.length;
            _loc2_ = new URLRequest(_loc3_.recombineUrl());
         }
         else if(this.playlist.dvr && Boolean(this.trailingBytes))
         {
            _loc4_ = new Url(this.playlist.url);
            _loc4_.queryVars.range = this.playlist.byteLength - this.trailingBytes.length + "-";
            _loc2_ = new URLRequest(_loc4_.recombineUrl());
         }
         else
         {
            _loc2_ = new URLRequest(this.playlist.url);
            this.parser.parsePlaylist(this.data,this.playlist);
         }
         this.urlStream.load(_loc2_);
      }
      
      public function copyResult(param1:HlsPlaylist) : void
      {
         this.parser.copyPlaylist(this.playlist,param1);
      }
      
      protected function onProgress(param1:Event) : void
      {
         var discard:int;
         var event:Event = param1;
         if(this.reschedule)
         {
            this.reschedule.stop();
            this.reschedule = null;
         }
         if(event.type == Event.COMPLETE)
         {
            this.complete = true;
         }
         if(this.urlStream.bytesAvailable)
         {
            try
            {
               this.urlStream.readBytes(this.data,this.data.length,Math.min(this.urlStream.bytesAvailable,maxChunkToProcess));
            }
            catch(error:EOFError)
            {
               urlStream.close();
               dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
               return;
            }
         }
         if(this.trailingBytes)
         {
            if(this.data.length < this.trailingBytes.length && !this.complete)
            {
               return;
            }
            if(!this.overlapMatches())
            {
               this.urlStream.close();
               this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
               return;
            }
            this.data.position += this.trailingBytes.length;
            this.trailingBytes = null;
         }
         this.parser.continueParsingPlaylist(this.data,this.playlist);
         discard = this.data.position - this.reloadOverlap;
         if(discard > 0)
         {
            this.data.position = discard;
            this.data.readBytes(this.data,0);
            this.data.length -= discard;
            this.data.position = this.reloadOverlap;
         }
         if(this.complete && !this.urlStream.bytesAvailable)
         {
            if(this.playlist.dvr && enableRangeRequests && !enableStartSeqRequests)
            {
               this.trailingBytes = new ByteArray();
               this.trailingBytes.writeBytes(this.data,0,this.data.position);
               this.data.length = 0;
            }
            this.dispatchEvent(new Event(Event.COMPLETE));
         }
         else if(this.urlStream.bytesAvailable)
         {
            this.reschedule = SCHEDULER.setTimeout(0,this.onProgress);
         }
      }
      
      protected function get reloadOverlap() : int
      {
         return enableRangeRequests ? 128 : 0;
      }
      
      protected function overlapMatches() : Boolean
      {
         var _loc1_:uint = 0;
         while(_loc1_ < this.trailingBytes.length)
         {
            if(this.data[_loc1_] != this.trailingBytes[_loc1_])
            {
               return false;
            }
            _loc1_++;
         }
         return true;
      }
   }
}

