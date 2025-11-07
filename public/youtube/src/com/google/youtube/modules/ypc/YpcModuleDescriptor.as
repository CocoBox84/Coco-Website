package com.google.youtube.modules.ypc
{
   import com.google.utils.PlayerVersion;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.players.IVideoAdEventProvider;
   
   public class YpcModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "ypc";
      
      public function YpcModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         requiredVersion = new PlayerVersion(10);
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
         capabilities[IVideoAdEventProvider] = true;
      }
   }
}

