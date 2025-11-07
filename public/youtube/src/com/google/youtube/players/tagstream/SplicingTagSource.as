package com.google.youtube.players.tagstream
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.VideoFormat;
   import com.google.youtube.model.tag.DataTag;
   
   public class SplicingTagSource extends PipelineEventDispatcher implements ISplicingTagSource
   {
      
      protected static const NORMAL_STATE:int = 0;
      
      protected static const PARSING_STATE:int = 1;
      
      protected static const SPLICING_STATE:int = 2;
      
      protected var activeSource:ITagSource;
      
      protected var spliceFormat:VideoFormat;
      
      protected var activeFormat:VideoFormat;
      
      protected var state:int = 0;
      
      protected var splicePoint:SeekPoint;
      
      protected var spliceSource:ITagSource;
      
      public function SplicingTagSource(param1:ITagSource, param2:VideoFormat)
      {
         super();
         this.activateSource(param1,param2);
      }
      
      public function open(param1:SeekPoint) : void
      {
         this.activeSource.open(param1);
      }
      
      public function get eof() : Boolean
      {
         return Boolean(this.activeSource) && this.activeSource.eof;
      }
      
      public function pop() : DataTag
      {
         var _loc1_:DataTag = this.activeSource ? this.activeSource.pop() : null;
         if(_loc1_)
         {
            if(this.state == PARSING_STATE)
            {
               this.splicePoint = this.spliceFormat.formatIndex.getNextSeekPoint(_loc1_.timestamp);
               this.state = this.splicePoint ? SPLICING_STATE : NORMAL_STATE;
            }
            if(this.state == SPLICING_STATE && _loc1_.timestamp >= this.splicePoint.timestamp)
            {
               this.activateSource(this.spliceSource,this.spliceFormat);
               this.activeSource.open(this.splicePoint);
               this.state = NORMAL_STATE;
               _loc1_ = this.activeSource.pop();
            }
         }
         return _loc1_;
      }
      
      public function splice(param1:ITagSource, param2:VideoFormat) : void
      {
         this.spliceSource = param1;
         this.spliceFormat = param2;
         this.state = PARSING_STATE;
      }
      
      public function get target() : VideoFormat
      {
         return this.splicing ? this.spliceFormat : this.activeFormat;
      }
      
      protected function activateSource(param1:ITagSource, param2:VideoFormat) : void
      {
         this.close();
         this.activeSource = param1;
         this.activeFormat = param2;
         forwardEvents(this.activeSource,true);
      }
      
      public function close() : void
      {
         if(this.activeSource)
         {
            this.activeSource.close();
            stopForwardingEvents(this.activeSource,true);
            this.activeSource = null;
            this.activeFormat = null;
         }
      }
      
      public function get splicing() : Boolean
      {
         return this.state != NORMAL_STATE;
      }
      
      public function info(param1:PlayerInfo) : void
      {
         param1.splicingNow = this.state != NORMAL_STATE;
         if(this.activeSource)
         {
            this.activeSource.info(param1);
         }
      }
   }
}

