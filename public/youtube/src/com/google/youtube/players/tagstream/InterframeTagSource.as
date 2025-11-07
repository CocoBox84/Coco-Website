package com.google.youtube.players.tagstream
{
   import com.google.youtube.model.PlayerInfo;
   import com.google.youtube.model.SeekPoint;
   import com.google.youtube.model.tag.DataTag;
   import com.google.youtube.model.tag.DataTagWithSeekTags;
   
   public class InterframeTagSource extends PipelineEventDispatcher implements ITagSource
   {
      
      protected var initialTime:uint;
      
      protected var firstTag:DataTagWithSeekTags;
      
      protected var upstream:ITagSource;
      
      protected var desiredTimestamp:uint;
      
      public function InterframeTagSource(param1:ITagSource, param2:uint = 0)
      {
         super();
         this.upstream = param1;
         this.desiredTimestamp = param2;
         forwardEvents(param1,true);
      }
      
      public function pop() : DataTag
      {
         var _loc1_:DataTag = null;
         while(true)
         {
            _loc1_ = this.upstream.pop();
            if(!_loc1_)
            {
               break;
            }
            if(_loc1_.timestamp >= this.desiredTimestamp)
            {
               if(this.firstTag)
               {
                  this.firstTag.setTarget(_loc1_);
                  _loc1_ = this.firstTag;
                  this.firstTag = null;
               }
               this.desiredTimestamp = 0;
               return _loc1_;
            }
            if(!this.firstTag)
            {
               this.firstTag = new DataTagWithSeekTags();
            }
            this.firstTag.addSeekTag(_loc1_);
         }
         return null;
      }
      
      public function get eof() : Boolean
      {
         return this.upstream.eof;
      }
      
      public function close() : void
      {
         this.upstream.close();
         stopForwardingEvents(this.upstream,true);
      }
      
      public function open(param1:SeekPoint) : void
      {
         this.desiredTimestamp = param1.desiredTimestamp;
         this.initialTime = param1.timestamp;
         this.upstream.open(param1);
      }
      
      public function info(param1:PlayerInfo) : void
      {
         this.upstream.info(param1);
      }
   }
}

