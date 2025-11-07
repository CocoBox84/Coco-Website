package com.google.youtube.players.preview
{
   import com.google.youtube.players.IVideoInfoProvider;
   
   public class HttpPreviewVideoPlayer extends HttpStaticDurationPlayer
   {
      
      public function HttpPreviewVideoPlayer(param1:IVideoInfoProvider)
      {
         super(param1);
      }
      
      override public function seek(param1:Number, param2:Boolean = true) : void
      {
         super.seek(param1,false);
      }
   }
}

