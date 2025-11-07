package com.google.utils
{
   import flash.utils.ByteArray;
   
   public interface IDataRead
   {
      
      function get eof() : Boolean;
      
      function read(param1:ByteArray, param2:uint, param3:uint) : uint;
   }
}

