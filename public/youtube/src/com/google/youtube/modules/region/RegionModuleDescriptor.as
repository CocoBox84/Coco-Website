package com.google.youtube.modules.region
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.IScriptCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   
   public class RegionModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "region";
      
      public function RegionModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         capabilities[IScriptCapability] = true;
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
      }
   }
}

