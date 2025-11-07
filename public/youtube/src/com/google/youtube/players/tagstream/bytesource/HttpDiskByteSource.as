package com.google.youtube.players.tagstream.bytesource
{
   import com.google.youtube.util.MediaLocation;
   import com.google.youtube.util.getDefinition;
   import flash.net.URLStream;
   
   public class HttpDiskByteSource extends HttpByteSource
   {
      
      protected static var URLDiskStream:Class = getDefinition("flash.net.URLDiskStream");
      
      public var last:Boolean;
      
      public function HttpDiskByteSource(param1:MediaLocation)
      {
         super(param1);
      }
      
      public static function get available() : Boolean
      {
         return Boolean(URLDiskStream);
      }
      
      public function get desiredLength() : uint
      {
         return seekPointCopy ? seekPointCopy.byteLength : 0;
      }
      
      public function get position() : uint
      {
         return URLDiskStream(urlStream).position;
      }
      
      public function get end() : uint
      {
         return this.getStart() + this.length;
      }
      
      public function streamClose() : void
      {
         if(urlStream)
         {
            URLDiskStream(urlStream).streamClose();
         }
      }
      
      override protected function getUrlStream() : URLStream
      {
         return new URLDiskStream();
      }
      
      public function set position(param1:uint) : void
      {
         URLDiskStream(urlStream).position = param1;
      }
      
      public function getStart() : uint
      {
         return seekPointCopy ? seekPointCopy.byteOffset : 0;
      }
      
      public function get length() : uint
      {
         return urlStream ? uint(URLDiskStream(urlStream).length) : 0;
      }
   }
}

