package com.google.youtube.players
{
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.YouTubeEnvironment;
   import com.google.youtube.model.crackle.CrackleEnvironmentDecorator;
   import com.google.youtube.model.googlebooks.GoogleBooksEnvironmentDecorator;
   import com.google.youtube.model.googledocs.GoogleDocsEnvironmentDecorator;
   import com.google.youtube.model.googlelive.GoogleLiveEnvironmentDecorator;
   import com.google.youtube.players.crackle.CracklePlayer;
   import com.google.youtube.players.preview.HttpEditorPreviewVideoPlayer;
   import com.google.youtube.players.preview.HttpPreviewVideoPlayer;
   import com.google.youtube.players.preview.HttpStaticDurationPlayer;
   import com.google.youtube.players.tagstream.AppendBytesNetStream;
   
   public class PlayerFactory
   {
      
      public function PlayerFactory()
      {
         super();
      }
      
      public static function getPlayerClass(param1:VideoData, param2:YouTubeEnvironment) : Class
      {
         if(param1.partnerId)
         {
            switch(int(param1.partnerId))
            {
               case PlayerType.SONY_CRACKLE:
                  return CracklePlayer;
               case PlayerType.RENTAL_PREVIEW:
                  return HttpPreviewVideoPlayer;
               case PlayerType.EDITOR_PREVIEW:
                  return HttpEditorPreviewVideoPlayer;
               case PlayerType.AKAMAI_LIVE:
                  return AkamaiLiveVideoPlayer;
               case PlayerType.GOOGLE_LIVE:
               case PlayerType.YOUTUBE_LIVE:
                  return param1.playlistUrl ? TagStreamPlayer : HTTPLiveVideoPlayer;
               case PlayerType.AKAMAI_HD_LIVE:
                  return AkamaiHDLiveVideoPlayer;
               case PlayerType.GOOGLE_RTMP:
                  return RTMPVideoPlayer;
               case PlayerType.FLASH_ACCESS:
                  return FlashAccessVideoPlayer;
            }
         }
         if(param1.isTransportRtmp())
         {
            return AkamaiRTMPVideoPlayer;
         }
         if(param2.isStaticDuration)
         {
            return HttpStaticDurationPlayer;
         }
         if(param1.format.requiresTagStreamPlayer || param1.threeDModule || !param2.tagStreamingForbiddenExperiment && !param1.partnerId && AppendBytesNetStream.isStreamingAvailable() && param2.autoQuality)
         {
            return TagStreamPlayer;
         }
         return HTTPVideoPlayer;
      }
      
      public static function getPlayer(param1:VideoData, param2:YouTubeEnvironment) : IVideoPlayer
      {
         var _loc3_:IVideoPlayer = null;
         var _loc4_:int = 0;
         if(param1.partnerId is String && Boolean(param1.partnerId.length))
         {
            _loc4_ = int(param1.partnerId);
         }
         var _loc5_:Class = getPlayerClass(param1,param2);
         switch(_loc5_)
         {
            case CracklePlayer:
               return new _loc5_(new CrackleEnvironmentDecorator(_loc4_,param2));
            default:
               switch(_loc4_)
               {
                  case PlayerType.GOOGLE_BOOKS:
                     return new _loc5_(new GoogleBooksEnvironmentDecorator(_loc4_,param2));
                  case PlayerType.GOOGLE_DOCS:
                     return new _loc5_(new GoogleDocsEnvironmentDecorator(_loc4_,param2));
                  case PlayerType.GOOGLE_LIVE:
                     return new _loc5_(new GoogleLiveEnvironmentDecorator(_loc4_,param2));
                  default:
                     return new _loc5_(param2);
               }
         }
      }
   }
}

