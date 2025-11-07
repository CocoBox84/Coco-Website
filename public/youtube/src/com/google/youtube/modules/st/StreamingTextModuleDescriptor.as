package com.google.youtube.modules.st
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.IModuleEnvironment;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.ui.Button;
   import com.google.youtube.ui.Theme;
   
   public class StreamingTextModuleDescriptor extends ModuleDescriptor
   {
      
      public static const ID:String = "st";
      
      public var button:Button = new Button();
      
      public function StreamingTextModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         this.button.labels = {
            "active":Theme.newActiveButton(StreamingTextIcon),
            "inactive":Theme.newButton(StreamingTextIcon)
         };
         this.button.setLabel("inactive");
         iconActive = this.button;
         iconInactive = this.button;
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
      }
      
      override public function shouldLoad(param1:IModuleEnvironment, param2:VideoData) : Boolean
      {
         return super.shouldLoad(param1,param2);
      }
      
      override public function get tooltipMessage() : String
      {
         return WatchMessages.STREAMING_TEXT;
      }
   }
}

