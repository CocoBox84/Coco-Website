package com.google.youtube.modules.streaminglib
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.ModuleDescriptor;
   
   public class StreamingLibModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "slib";
      
      public function StreamingLibModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
      }
   }
}

