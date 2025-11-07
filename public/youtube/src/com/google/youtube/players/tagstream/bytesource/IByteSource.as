package com.google.youtube.players.tagstream.bytesource
{
   import com.google.utils.IDataRead;
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import flash.events.IEventDispatcher;
   
   public interface IByteSource extends IEventDispatcher, IDataRead
   {
      
      function close() : void;
      
      function open(param1:SeekPoint) : void;
      
      function info(param1:PlayerInfo) : void;
   }
}

