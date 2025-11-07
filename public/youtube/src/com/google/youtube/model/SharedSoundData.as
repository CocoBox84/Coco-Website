package com.google.youtube.model
{
   import flash.events.NetStatusEvent;
   import flash.net.ObjectEncoding;
   import flash.net.SharedObject;
   
   public class SharedSoundData
   {
      
      private static var SOUND_DATA_KEY:String = "soundData";
      
      private var isMute:Boolean;
      
      private var cachedVolume:Number = 100;
      
      private var soundSharedObject:SharedObject;
      
      private var soundData:Object;
      
      public function SharedSoundData(param1:Boolean)
      {
         var useSharedObject:Boolean = param1;
         super();
         if(useSharedObject)
         {
            try
            {
               SharedObject.defaultObjectEncoding = ObjectEncoding.AMF0;
               this.soundSharedObject = SharedObject.getLocal(SOUND_DATA_KEY,"/");
               this.soundSharedObject.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
               this.soundData = this.soundSharedObject.data;
            }
            catch(error:Error)
            {
               soundSharedObject = null;
            }
         }
      }
      
      public function isMuted() : Boolean
      {
         return this.isMute;
      }
      
      public function getStoredVolume() : Number
      {
         if(!this.soundSharedObject || isNaN(this.soundData.volume))
         {
            return this.cachedVolume;
         }
         return this.soundData.volume;
      }
      
      public function clearSharedSoundData() : void
      {
         if(!this.soundSharedObject)
         {
            return;
         }
         this.soundSharedObject.clear();
      }
      
      public function unsetMute() : void
      {
         this.isMute = false;
      }
      
      public function getVolume() : Number
      {
         if(this.isMute)
         {
            return 0;
         }
         return this.getStoredVolume();
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         if(param1.info.level == "error")
         {
            this.soundSharedObject = null;
         }
      }
      
      public function setMute() : void
      {
         this.isMute = true;
      }
      
      public function setVolume(param1:Number) : void
      {
         var value:Number = param1;
         value = isNaN(value) ? 100 : Math.max(Math.min(value,100),0);
         this.cachedVolume = value;
         if(!this.soundSharedObject)
         {
            return;
         }
         this.soundData.volume = value;
         try
         {
            this.soundSharedObject.flush();
         }
         catch(error:Error)
         {
         }
      }
   }
}

