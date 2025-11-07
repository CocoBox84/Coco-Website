package com.google.youtube.modules.ad
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.players.IVideoAdEventProvider;
   import flash.geom.Rectangle;
   
   public class AdModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "ad";
      
      public function AdModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         requiredSize = new Rectangle(0,0,200,190);
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
         capabilities[IVideoAdEventProvider] = true;
      }
      
      override protected function onMessageUpdate(param1:MessageEvent) : void
      {
         moduleName = param1.messages.getMessage(WatchMessages.ADVERTISEMENT);
      }
   }
}

