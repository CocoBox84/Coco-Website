package com.google.youtube.model
{
   public class EventLabel
   {
      
      public static const ADUNIT:String = "adunit";
      
      public static const CHANNEL_PAGE:String = "profilepage";
      
      public static const DETAIL_PAGE:String = "detailpage";
      
      public static const EDIT_PAGE:String = "editpage";
      
      public static const EMBEDDED:String = "embedded";
      
      public static const LEAF:String = "leaf";
      
      public static const LEANBACK:String = "leanback";
      
      public static const POPOUT:String = "popout";
      
      public static const PREVIEW:String = "preview";
      
      public static const PREVIEW_PAGE:String = "previewpage";
      
      public static const MOLE:String = "mole";
      
      public static const VIDEO_EDITOR:String = "videoeditor";
      
      public static const ALLOW_OVERRIDE:Array = [EMBEDDED,LEAF,PREVIEW,MOLE];
      
      public function EventLabel()
      {
         super();
      }
   }
}

