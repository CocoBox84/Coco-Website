package com.google.youtube.model
{
   public class Mp3FormatIndex extends FlvFormatIndex
   {
      
      public function Mp3FormatIndex(param1:uint, param2:String, param3:String)
      {
         super(param1,param2,param3);
      }
      
      override protected function getTotalHeaderSize() : uint
      {
         return 0;
      }
      
      override protected function getSeekPointWithHeaders() : SeekPoint
      {
         return new SeekPoint();
      }
   }
}

