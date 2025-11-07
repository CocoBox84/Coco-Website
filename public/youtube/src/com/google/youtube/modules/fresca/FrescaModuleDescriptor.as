package com.google.youtube.modules.fresca
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   
   public class FrescaModuleDescriptor extends ModuleDescriptor
   {
      
      public static var savedGdataLoader:Object;
      
      public static const ID:String = "fr";
      
      public function FrescaModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
      }
   }
}

