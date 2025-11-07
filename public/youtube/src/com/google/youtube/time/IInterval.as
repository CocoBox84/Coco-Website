package com.google.youtube.time
{
   public interface IInterval
   {
      
      function get start() : int;
      
      function get end() : int;
      
      function contains(param1:int, param2:int = 0) : Boolean;
   }
}

