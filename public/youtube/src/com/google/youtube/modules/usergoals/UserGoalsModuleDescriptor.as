package com.google.youtube.modules.usergoals
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   
   public class UserGoalsModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "usergoals";
      
      public function UserGoalsModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
      }
   }
}

