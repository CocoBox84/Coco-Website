package com.google.youtube.model
{
   import com.google.utils.RequestLoader;
   import flash.net.URLRequest;
   
   public class Messages extends RequestLoader implements IMessages
   {
      
      public static const LOCALE_EN:String = "en_US";
      
      protected var placeholders:Object = {};
      
      protected var loadedLocale:String = "en_US";
      
      protected var base:String;
      
      protected var messages:Object = {};
      
      protected var group:String = "watch";
      
      public function Messages(param1:String)
      {
         super();
         this.base = param1;
         this.load(LOCALE_EN);
      }
      
      protected function register(param1:String, param2:String, param3:Object = null) : void
      {
         param1 = param1.toLowerCase();
         this.messages[param1] = param2;
         this.placeholders[param1] = this.placeholders[param1] || param3;
      }
      
      public function getMessage(param1:String, param2:Object = null) : String
      {
         var _loc5_:String = null;
         if(!param1)
         {
            return "";
         }
         param1 = param1.toLowerCase();
         param2 ||= this.placeholders[param1];
         var _loc3_:String = this.messages[param1] || "";
         var _loc4_:String = Math.random().toString();
         for(_loc5_ in param2)
         {
            _loc3_ = _loc3_.split(_loc5_).join(_loc5_ + _loc4_);
         }
         for(_loc5_ in param2)
         {
            _loc3_ = _loc3_.split(_loc5_ + _loc4_).join(param2[_loc5_]);
         }
         return _loc3_;
      }
      
      protected function registerEn() : void
      {
         this.loadedLocale = LOCALE_EN;
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = true) : void
      {
         super.addEventListener(param1,param2,param3,param4,param5);
         if(param1 == MessageEvent.UPDATE)
         {
            param2(new MessageEvent(MessageEvent.UPDATE,this));
         }
      }
      
      public function load(param1:String, param2:String = null) : void
      {
         if(param1 == LOCALE_EN)
         {
            this.registerEn();
            dispatchEvent(new MessageEvent(MessageEvent.UPDATE,this));
         }
         else if(this.loadedLocale != param1 && Boolean(param2))
         {
            this.loadedLocale = param1;
            loadRequest(new URLRequest(param2));
         }
      }
      
      override protected function parseLoadedData(param1:*) : void
      {
         var xml:XML = null;
         var message:XML = null;
         var key:String = null;
         var value:String = null;
         var data:* = param1;
         if(data is String)
         {
            try
            {
               xml = new XML(data);
               for each(message in xml..msg)
               {
                  key = message.@name;
                  value = message.text()[0];
                  this.register(key,value);
               }
               dispatchEvent(new MessageEvent(MessageEvent.UPDATE,this));
            }
            catch(error:TypeError)
            {
            }
         }
      }
   }
}

