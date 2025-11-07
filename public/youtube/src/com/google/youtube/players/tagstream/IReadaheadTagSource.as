package com.google.youtube.players.tagstream
{
   public interface IReadaheadTagSource extends ITagSource
   {
      
      function get loadedTime() : Number;
      
      function get peekTime() : int;
      
      function stop() : void;
      
      function isCached(param1:uint) : Boolean;
      
      function getBuffers() : Array;
      
      function get gopTimes() : Array;
   }
}

