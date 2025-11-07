package com.google.youtube.players.tagstream
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.tag.DataTag;
   import flash.events.IEventDispatcher;
   
   public interface ITagSource extends IEventDispatcher
   {
      
      function pop() : DataTag;
      
      function close() : void;
      
      function open(param1:SeekPoint) : void;
      
      function get eof() : Boolean;
      
      function info(param1:PlayerInfo) : void;
   }
}

