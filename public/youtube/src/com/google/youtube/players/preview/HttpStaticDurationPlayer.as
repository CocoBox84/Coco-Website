package com.google.youtube.players.preview
{
   import com.google.youtube.players.HTTPVideoPlayer;
   import com.google.youtube.players.IVideoInfoProvider;
   
   public class HttpStaticDurationPlayer extends HTTPVideoPlayer
   {
      
      public function HttpStaticDurationPlayer(param1:IVideoInfoProvider)
      {
         super(param1);
      }
      
      override public function onMetaData(param1:Object) : void
      {
         param1.totalduration = param1.duration = videoData.duration;
         super.onMetaData(param1);
      }
   }
}

