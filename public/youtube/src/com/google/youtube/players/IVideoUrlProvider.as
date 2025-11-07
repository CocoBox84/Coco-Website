package com.google.youtube.players
{
   import com.google.utils.RequestVariables;
   import com.google.youtube.model.VideoData;
   import com.google.youtube.model.VideoFormat;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   
   public interface IVideoUrlProvider
   {
      
      function getPlaybackLoggingRequest(param1:VideoData, param2:RequestVariables = null) : URLRequest;
      
      function getVideoFormatUrlRequest(param1:VideoData, param2:VideoFormat, param3:RequestVariables = null, param4:Boolean = false) : URLRequest;
      
      function getVideoWatchRequest(param1:VideoData) : URLRequest;
      
      function getVideoEmbedCode(param1:VideoData) : String;
      
      function getVideoUrl(param1:VideoData, param2:RequestVariables = null) : String;
      
      function getVideoUrlRequest(param1:VideoData, param2:RequestVariables = null, param3:Boolean = false) : URLRequest;
      
      function getWatermarkDestinationRequest(param1:VideoData) : URLRequest;
      
      function applyGetVideoInfo(param1:URLVariables) : void;
      
      function getVideoWatchUrl(param1:VideoData) : String;
      
      function getVideoInfoRequest(param1:VideoData) : URLRequest;
      
      function getStillUrl(param1:VideoData, param2:Number = 430, param3:Number = 320) : String;
      
      function get baseUrl() : String;
   }
}

