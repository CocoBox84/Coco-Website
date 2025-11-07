package com.google.youtube.modules.ratings
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   
   public class RatingsModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "rate";
      
      public function RatingsModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
      }
   }
}

