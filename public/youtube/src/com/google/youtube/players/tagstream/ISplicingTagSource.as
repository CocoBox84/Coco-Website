package com.google.youtube.players.tagstream
{
   import com.google.youtube.model.VideoFormat;
   
   public interface ISplicingTagSource extends ITagSource
   {
      
      function get splicing() : Boolean;
      
      function get target() : VideoFormat;
      
      function splice(param1:ITagSource, param2:VideoFormat) : void;
   }
}

