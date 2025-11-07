package com.google.youtube.modules.akamaihd
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.ModuleDescriptor;
   
   public class AkamaiHdModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "akh";
      
      public function AkamaiHdModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         showButtonValue = false;
      }
   }
}

