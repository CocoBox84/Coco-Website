package com.google.youtube.util.dash
{
   import com.google.utils.Url;
   import com.google.youtube.model.VideoFormat;
   import flash.utils.ByteArray;
   
   public class MpdParser
   {
      
      protected static const ON_DEMAND_PROFILE:String = "urn:mpeg:dash:profile:isoff-on-demand:2011";
      
      protected static const DASH_FMP4_H264_ULTRALOW:String = "160";
      
      protected static const DASH_FMP4_H264_LOW:String = "133";
      
      protected static const DASH_FMP4_H264_MED:String = "134";
      
      protected static const DASH_FMP4_H264_HIGH:String = "135";
      
      protected static const DASH_FMP4_H264_720P:String = "136";
      
      protected static const DASH_FMP4_H264_1080P:String = "137";
      
      protected static const DASH_FMP4_H264_HIGHRES:String = "138";
      
      protected static const DASH_FMP4_HE_AAC_LOW:String = "139";
      
      protected static const DASH_FMP4_AAC_MED:String = "140";
      
      protected static const DASH_FMP4_AAC_HIGH:String = "141";
      
      protected var mpd:XML;
      
      public function MpdParser()
      {
         super();
      }
      
      protected function getTiedAudioRepresentation(param1:XML) : XML
      {
         var preferences:Array;
         var id:String = null;
         var audioList:XMLList = null;
         var video:XML = param1;
         default xml namespace = this.mpd.namespace();
         preferences = this.getTiedAudioIdPreferences(video);
         for each(id in preferences)
         {
            audioList = this.audioAdaptationSet.Representation.(@id == id);
            if(audioList.length())
            {
               return audioList[0];
            }
         }
         return null;
      }
      
      protected function getVideoFormat(param1:XML, param2:XML) : VideoFormat
      {
         default xml namespace = this.mpd.namespace();
         var _loc3_:String = [param2.@width,param2.@height].join("x");
         var _loc4_:Url = new Url(this.mpd.BaseURL[0]);
         var _loc5_:String = param2.BaseURL[0];
         var _loc6_:String = Url.resolve(_loc5_,_loc4_).recombineUrl();
         var _loc7_:String = [this.getItag(param2),_loc3_,10,1,0].join("/");
         var _loc8_:String = [this.getItag(param1),param1.@audioSamplingRate].join("/");
         var _loc9_:VideoFormat = new VideoFormat([_loc7_,_loc8_].join(":"),_loc6_);
         var _loc10_:String = param1.BaseURL[0];
         _loc9_.audioUrl = Url.resolve(_loc10_,_loc4_).recombineUrl();
         _loc9_.audioByteRateValue = uint(param1.@bandwidth) / 8;
         _loc9_.videoByteRateValue = uint(param2.@bandwidth) / 8;
         _loc9_.audioIndexSegmentByteRange = this.getIndexSegmentRange(param1);
         _loc9_.audioInitializationSegmentByteRange = this.getInitSegmentRange(param1);
         _loc9_.videoIndexSegmentByteRange = this.getIndexSegmentRange(param2);
         _loc9_.videoInitializationSegmentByteRange = this.getInitSegmentRange(param2);
         return _loc9_;
      }
      
      public function parseString(param1:String) : void
      {
         this.mpd = new XML(param1);
         default xml namespace = this.mpd.namespace();
      }
      
      public function getFormats() : Array
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         default xml namespace = this.mpd.namespace();
         var _loc1_:Array = [];
         for each(_loc2_ in this.videoAdaptationSet.Representation)
         {
            _loc3_ = this.getTiedAudioRepresentation(_loc2_);
            _loc1_.push(this.getVideoFormat(_loc3_,_loc2_));
         }
         _loc1_.sortOn("quality",Array.DESCENDING | Array.NUMERIC);
         return _loc1_;
      }
      
      protected function getItag(param1:XML) : String
      {
         default xml namespace = this.mpd.namespace();
         return param1.@id;
      }
      
      protected function toUint(param1:String, ... rest) : uint
      {
         default xml namespace = this.mpd.namespace();
         return uint(param1);
      }
      
      protected function getInitSegmentRange(param1:XML) : Array
      {
         default xml namespace = this.mpd.namespace();
         var _loc2_:String = param1.SegmentBase.Initialization.@range[0];
         return _loc2_.split("-").map(this.toUint);
      }
      
      protected function getTiedAudioIdPreferences(param1:XML) : Array
      {
         default xml namespace = this.mpd.namespace();
         switch(String(param1.@id[0]))
         {
            case DASH_FMP4_H264_ULTRALOW:
               return [DASH_FMP4_HE_AAC_LOW,DASH_FMP4_AAC_MED,DASH_FMP4_AAC_HIGH];
            case DASH_FMP4_H264_LOW:
            case DASH_FMP4_H264_MED:
               return [DASH_FMP4_AAC_MED,DASH_FMP4_AAC_HIGH,DASH_FMP4_HE_AAC_LOW];
            case DASH_FMP4_H264_HIGH:
            case DASH_FMP4_H264_720P:
            case DASH_FMP4_H264_1080P:
            case DASH_FMP4_H264_HIGHRES:
               return [DASH_FMP4_AAC_HIGH,DASH_FMP4_AAC_MED,DASH_FMP4_HE_AAC_LOW];
            default:
               return [DASH_FMP4_AAC_MED,DASH_FMP4_AAC_HIGH,DASH_FMP4_HE_AAC_LOW];
         }
      }
      
      public function parse(param1:ByteArray) : void
      {
         this.mpd = new XML(param1);
         default xml namespace = this.mpd.namespace();
      }
      
      protected function get videoAdaptationSet() : XML
      {
         default xml namespace = this.mpd.namespace();
         return this.mpd.Period.AdaptationSet.(@mimeType == "video/mp4")[0];
      }
      
      public function getDurationSeconds() : Number
      {
         default xml namespace = this.mpd.namespace();
         return MpdUtils.parseDuration(this.mpd.@mediaPresentationDuration[0]);
      }
      
      protected function get audioAdaptationSet() : XML
      {
         default xml namespace = this.mpd.namespace();
         return this.mpd.Period.AdaptationSet.(@mimeType == "audio/mp4")[0];
      }
      
      public function get valid() : Boolean
      {
         default xml namespace = this.mpd.namespace();
         return this.mpd.@profiles[0] == ON_DEMAND_PROFILE && this.mpd.Period.length() == 1 && this.mpd.@mediaPresentationDuration.length() > 0 && !isNaN(this.getDurationSeconds()) && this.mpd.Period.AdaptationSet.length() == 2 && this.mpd.Period.AdaptationSet.(@mimeType == "audio/mp4").length() == 1 && this.mpd.Period.AdaptationSet.(@mimeType == "video/mp4").length() == 1;
      }
      
      protected function getIndexSegmentRange(param1:XML) : Array
      {
         default xml namespace = this.mpd.namespace();
         var _loc2_:String = param1.SegmentBase.@indexRange[0];
         return _loc2_.split("-").map(this.toUint);
      }
   }
}

