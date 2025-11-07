package com.google.youtube.modules.yva
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   
   public class YvaModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "yva";
      
      public function YvaModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
      }
   }
}

