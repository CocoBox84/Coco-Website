package com.google.youtube.players
{
   public interface IVideoInfoProvider extends IVideoUrlProvider
   {
      
      function get maxBufferLength() : Number;
      
      function get bufferLengthAfterVideoStarts() : Number;
      
      function get defaultBufferLength() : Number;
   }
}

