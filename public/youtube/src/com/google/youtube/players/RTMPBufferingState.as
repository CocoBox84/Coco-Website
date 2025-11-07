package com.google.youtube.players
{
   import flash.events.NetStatusEvent;
   
   public class RTMPBufferingState extends BufferingState
   {
      
      public function RTMPBufferingState(param1:IVideoPlayer)
      {
         super(param1);
      }
      
      override public function onNetStatus(param1:NetStatusEvent) : IPlayerState
      {
         switch(param1.info.code)
         {
            case "NetStream.Buffer.Full":
               return this;
            default:
               return super.onNetStatus(param1);
         }
      }
   }
}

