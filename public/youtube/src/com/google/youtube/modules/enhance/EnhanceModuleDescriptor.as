package com.google.youtube.modules.enhance
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.IConfigCapability;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.IScriptCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   
   public class EnhanceModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "enhance";
      
      public function EnhanceModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         capabilities[IConfigCapability] = true;
         capabilities[IScriptCapability] = true;
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
      }
      
      override public function shouldUnload() : Boolean
      {
         return false;
      }
   }
}

