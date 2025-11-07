package com.google.youtube.modules.playlist
{
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.IModuleEnvironment;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.WatchMessages;
   import com.google.youtube.model.YouTubeEnvironment;
   import com.google.youtube.modules.IControlsCapability;
   import com.google.youtube.modules.IOverlayCapability;
   import com.google.youtube.modules.IResizeableCapability;
   import com.google.youtube.modules.ModuleDescriptor;
   import com.google.youtube.ui.Button;
   import com.google.youtube.ui.Theme;
   import flash.geom.Rectangle;
   
   public class PlaylistModuleDescriptor extends ModuleDescriptor implements IControlsCapability
   {
      
      public static const PLAYLIST_STRIP_HEIGHT:int = 82;
      
      public static const ID:String = "pl";
      
      public var playlistButton:Button = new Button();
      
      public var bottomfeeder:Boolean = false;
      
      public function PlaylistModuleDescriptor(param1:IMessages)
      {
         super(param1,ID);
         capabilities[IOverlayCapability] = true;
         capabilities[IResizeableCapability] = true;
         capabilities[IControlsCapability] = true;
         this.playlistButton.labels = {
            "active":Theme.newActiveButton(PlaylistIcon),
            "inactive":Theme.newButton(PlaylistIcon)
         };
         this.playlistButton.setLabel("inactive");
         iconActive = this.playlistButton;
         iconInactive = this.playlistButton;
         showButton = false;
      }
      
      override public function get tooltipMessage() : String
      {
         return WatchMessages.PLAYLIST;
      }
      
      public function get controlsInset() : Rectangle
      {
         var _loc1_:Rectangle = null;
         if(instance)
         {
            return IControlsCapability(instance).controlsInset;
         }
         if(this.bottomfeeder)
         {
            _loc1_ = new Rectangle();
            _loc1_.bottom = PLAYLIST_STRIP_HEIGHT;
            return _loc1_;
         }
         return new Rectangle();
      }
      
      override public function shouldUnload() : Boolean
      {
         return false;
      }
      
      override public function shouldLoad(param1:IModuleEnvironment, param2:VideoData) : Boolean
      {
         this.bottomfeeder = param1 is YouTubeEnvironment ? Boolean(YouTubeEnvironment(param1).rawParameters.bottomfeeder) : false;
         return param1 is YouTubeEnvironment && Boolean(YouTubeEnvironment(param1).playlist);
      }
      
      public function set controlsRespected(param1:Boolean) : void
      {
         if(instance)
         {
            IControlsCapability(instance).controlsRespected = param1;
         }
      }
   }
}

