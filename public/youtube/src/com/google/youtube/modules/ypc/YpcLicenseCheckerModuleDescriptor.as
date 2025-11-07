package com.google.youtube.modules.ypc
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.ModuleDescriptor;
   
   public class YpcLicenseCheckerModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "ypclc";
      
      public function YpcLicenseCheckerModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         loadPolicy = MODULE_LOAD_ALWAYS;
      }
   }
}

