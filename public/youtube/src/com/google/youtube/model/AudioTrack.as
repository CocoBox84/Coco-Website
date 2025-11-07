package com.google.youtube.model
{
   public class AudioTrack
   {
      
      public static const DEFAULT:AudioTrack = new AudioTrack("Default","und",true);
      
      protected var nameValue:String;
      
      protected var languageValue:String;
      
      protected var isDefaultValue:Boolean;
      
      public function AudioTrack(param1:String, param2:String, param3:Boolean)
      {
         super();
         this.nameValue = param1;
         this.languageValue = param2;
         this.isDefaultValue = param3;
      }
      
      public function get isDefault() : Boolean
      {
         return this.isDefaultValue;
      }
      
      public function get language() : String
      {
         return this.languageValue;
      }
      
      public function get name() : String
      {
         return this.nameValue;
      }
   }
}

