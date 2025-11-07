package com.google.youtube.players.preview
{
   import com.google.youtube.event.VideoProgressEvent;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.players.IVideoInfoProvider;
   import flash.events.NetStatusEvent;
   
   public class HttpEditorPreviewVideoPlayer extends HttpStaticDurationPlayer
   {
      
      private var maxTime:Number = 0;
      
      public function HttpEditorPreviewVideoPlayer(param1:IVideoInfoProvider)
      {
         super(param1);
      }
      
      override protected function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Stop":
               if(getDuration() - getTime() > 1)
               {
                  return;
               }
         }
         super.onNetStatus(param1);
      }
      
      override public function getBytesTotal() : Number
      {
         var _loc1_:Number = streamValue ? streamValue.time : 0;
         this.maxTime = Math.max(this.maxTime,_loc1_);
         return this.maxTime == 0 ? 0 : getBytesLoaded() * getDuration() / this.maxTime;
      }
      
      override public function seek(param1:Number, param2:Boolean = true) : void
      {
         super.seek(param1,param2 && !videoData.flvUrl);
      }
      
      override public function setVideoData(param1:VideoData) : void
      {
         this.maxTime = 0;
         super.setVideoData(param1);
         dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS,getTime(),getBytesLoaded(),this.getBytesTotal()));
      }
      
      override public function onMetaData(param1:Object) : void
      {
         param1.requiresTimeOffset = true;
         super.onMetaData(param1);
      }
   }
}

