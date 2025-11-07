package com.google.youtube.modules.endscreen
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   
   public class EndScreenModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "end";
      
      public function EndScreenModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
      }
      
      override public function shouldUnload() : Boolean
      {
         return false;
      }
   }
}

