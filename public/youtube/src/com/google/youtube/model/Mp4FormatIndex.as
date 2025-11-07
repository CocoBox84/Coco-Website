package com.google.youtube.model
{
   import com.google.utils.mp4.Parser;
   import com.google.youtube.event.FallbackEvent;
   import com.google.youtube.util.DataReadUrlStream;
   import com.google.youtube.util.FlvUtils;
   import flash.errors.EOFError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public class Mp4FormatIndex extends EventDispatcher implements IFormatIndex
   {
      
      protected var scriptTag:ByteArray;
      
      protected var state:String = "unload";
      
      protected var urlStream:DataReadUrlStream;
      
      protected var aacTag:ByteArray;
      
      protected var moovValue:Parser;
      
      protected var avcTag:ByteArray;
      
      public function Mp4FormatIndex()
      {
         super();
      }
      
      public function getSeekPoint(param1:uint) : SeekPoint
      {
         return null;
      }
      
      public function get audioHeader() : ByteArray
      {
         return this.aacTag;
      }
      
      public function get loaded() : Boolean
      {
         return this.state == Event.COMPLETE;
      }
      
      public function onResetPoint(param1:SeekPoint) : void
      {
      }
      
      public function get moov() : Parser
      {
         return this.moovValue;
      }
      
      public function canGetAnySeekPoint() : Boolean
      {
         return false;
      }
      
      public function createFormatTags() : void
      {
         if(this.moov.hasVideoTrak)
         {
            this.avcTag = new ByteArray();
            FlvUtils.writeFrameHeader(this.avcTag,FlvUtils.TAG_TYPE_VIDEO,0);
            FlvUtils.writeAvcSequenceHeaderPreamble(this.avcTag);
            this.avcTag.writeBytes(this.moov.getAvcConfigBytes());
            FlvUtils.writeFrameTrailer(this.avcTag);
         }
         if(this.moov.hasAudioTrak)
         {
            this.aacTag = new ByteArray();
            FlvUtils.writeFrameHeader(this.aacTag,FlvUtils.TAG_TYPE_AUDIO,0);
            FlvUtils.writeAacSequenceHeaderPreamble(this.aacTag);
            this.aacTag.writeBytes(this.moovValue.getAudioSpecificConfig());
            FlvUtils.writeFrameTrailer(this.aacTag);
         }
         if(this.moov.hasVideoTrak)
         {
            this.scriptTag = new ByteArray();
            FlvUtils.writeScriptTag(this.scriptTag,"onMetaData",0,{
               "width":this.moovValue.getVideoStreamWidth(),
               "height":this.moovValue.getVideoStreamHeight()
            });
         }
      }
      
      protected function requestMoovInBand(param1:uint) : Boolean
      {
         return param1 == 0 && this.state == Event.UNLOAD;
      }
      
      protected function getHeaderRequest() : URLRequest
      {
         return null;
      }
      
      public function get videoHeader() : ByteArray
      {
         return this.avcTag;
      }
      
      public function onSeekPoint(param1:SeekPoint, param2:Boolean) : void
      {
      }
      
      public function get fileSize() : Number
      {
         return NaN;
      }
      
      public function set moov(param1:Parser) : void
      {
         this.moovValue = param1;
         this.createFormatTags();
         this.state = Event.COMPLETE;
      }
      
      public function load() : void
      {
         if(this.state == Event.UNLOAD)
         {
            this.moovValue = new Parser();
            this.urlStream = new DataReadUrlStream();
            this.urlStream.addEventListener(IOErrorEvent.IO_ERROR,dispatchEvent);
            this.urlStream.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
            this.urlStream.addEventListener(Event.COMPLETE,this.onProgress);
            this.urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,dispatchEvent);
            this.urlStream.load(this.getHeaderRequest());
            this.state = Event.OPEN;
         }
      }
      
      public function getNextSeekPoint(param1:uint) : SeekPoint
      {
         return null;
      }
      
      protected function getSeekPointWithMoov() : SeekPoint
      {
         return new SeekPoint();
      }
      
      public function get metadata() : ByteArray
      {
         return this.scriptTag;
      }
      
      public function canGetSeekPoint(param1:uint) : Boolean
      {
         return false;
      }
      
      protected function onProgress(param1:Event) : void
      {
         var p:ProgressEvent = null;
         var event:Event = param1;
         if(event is ProgressEvent)
         {
            p = ProgressEvent(event);
            if(p.bytesLoaded == p.bytesTotal)
            {
               return;
            }
         }
         try
         {
            if(this.moov.readAtoms(this.urlStream))
            {
               this.closeUrlStream();
               this.createFormatTags();
               this.state = Event.COMPLETE;
               dispatchEvent(new Event(Event.COMPLETE));
            }
         }
         catch(e:EOFError)
         {
            closeUrlStream();
            dispatchEvent(new FallbackEvent(FallbackEvent.FALLBACK,FallbackEvent.MP4_EOF));
         }
         catch(e:TypeError)
         {
            closeUrlStream();
            dispatchEvent(new FallbackEvent(FallbackEvent.FALLBACK,FallbackEvent.MP4_PARSE));
         }
      }
      
      public function getTimeFromByte(param1:uint) : uint
      {
         return 0;
      }
      
      protected function closeUrlStream() : void
      {
         if(this.urlStream.connected)
         {
            this.urlStream.close();
         }
         this.urlStream.removeEventListener(IOErrorEvent.IO_ERROR,dispatchEvent);
         this.urlStream.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this.urlStream.removeEventListener(Event.COMPLETE,this.onProgress);
         this.urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,dispatchEvent);
      }
      
      public function get isFragmented() : Boolean
      {
         return false;
      }
   }
}

