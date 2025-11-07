package com.google.youtube.ui
{
   import com.google.youtube.ui.themes.DarkTheme;
   import com.google.youtube.ui.themes.LightTheme;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class Theme
   {
      
      public static const DARK_THEME:String = "dark";
      
      public static const LIGHT_THEME:String = "light";
      
      public static const PRIMARY_BUTTON_THEME:String = "PRIMARY_BUTTON_THEME";
      
      public static const SUBSCRIBE_BUTTON_THEME:String = "SUBSCRIBE_BUTTON_THEME";
      
      protected static const THEME_CONSTANTS:Object = {
         "dark":{
            "CONTROLS_BACKGROUND_COLOR":2039583,
            "CONTROLS_BACKGROUND_ALPHA":0.9,
            "BEVEL_COLOR":16777215,
            "DROP_SHADOW_COLOR":0,
            "GLOW_COLOR":16777215,
            "GLOW_ALPHA":0.15,
            "FOREGROUND_TEXT_COLOR":10066329,
            "FOREGROUND_TEXT_COLOR_HOVER":16777215,
            "ICON_COLORS":[7697781,7697781],
            "ICON_OVER_COLORS":[9803157,9803157],
            "ICON_ACTIVE_COLORS":[14540253,14540253],
            "ICON_ACTIVE_OVER_COLORS":[16777215,16777215]
         },
         "light":{
            "CONTROLS_BACKGROUND_COLOR":14737632,
            "CONTROLS_BACKGROUND_ALPHA":0.9,
            "BEVEL_COLOR":0,
            "DROP_SHADOW_COLOR":16777215,
            "GLOW_COLOR":0,
            "GLOW_ALPHA":0,
            "FOREGROUND_TEXT_COLOR":6710886,
            "FOREGROUND_TEXT_COLOR_HOVER":0,
            "ICON_COLORS":[5066061,5066061],
            "ICON_OVER_COLORS":[4013373,4013373],
            "ICON_ACTIVE_COLORS":[1118481,1118481],
            "ICON_ACTIVE_OVER_COLORS":[0,0]
         },
         "PRIMARY_BUTTON_THEME":{"BUTTON_GRADIENT_COLORS":{
            "up":[4494823,21414],
            "down":[83080,1531558],
            "over":[617426,21414]
         }},
         "SUBSCRIBE_BUTTON_THEME":{
            "BUTTON_GRADIENT_COLORS":{
               "up":[3684408,1381653],
               "down":[1381653,2434341],
               "over":[3684408,2434341]
            },
            "BUTTON_RADIUS":5
         },
         "common":{
            "BACKGROUND_GRADIENT_COLORS":[2763306,2763306],
            "BACKGROUND_GRADIENT_HEIGHT":80,
            "BUTTON_GRADIENT_COLORS":{
               "up":[0,0],
               "down":[6098703,6098703],
               "over":[12132127,12132127]
            },
            "BUTTON_RADIUS":0,
            "DISABLED_ALPHA":0,
            "DISABLED_COLOR":0,
            "DISABLED_SHADOW_COLOR":0,
            "DROP_SHADOW_BLUR":0,
            "EMPTY_COLOR":2039583,
            "EMPTY_ALPHA":0.5,
            "HIGHLIGHT_COLOR":16777215,
            "ICON_ENABLED_ALPHA":1,
            "ICON_DISABLED_ALPHA":0.5,
            "INVISIBLE_HEIGHT":4,
            "LINE_COLOR":3289650,
            "LOADED_COLOR":7697781,
            "LOADED_ALPHA":1,
            "MENU_TEXT_COLORS":{
               "up":12303291,
               "down":16777215,
               "over":16777215,
               "selected":16777215
            },
            "MENU_HIGHLIGHT_COLOR":12132127,
            "MENU_HIGHLIGHT_ALPHA":1,
            "POPUP_MENU_COLOR":2039583,
            "POPUP_MENU_ALPHA":0.9,
            "POPUP_MENU_RADIUS":0,
            "POPUP_MENU_BORDER":12,
            "PROGRESS_BAR":[12132127,12132127],
            "PROGRESS_BAR_ZOOM":[12132127,12132127],
            "PROGRESS_BAR_ALPHAS":[1,1],
            "PROGRESS_RATIOS":[0,255],
            "SEEK_HANDLE_OFFSET":2,
            "SEEK_HEIGHT":8,
            "SEEK_OFFSET":3,
            "SEEK_MAGNIFY_COLOR":3223857,
            "SHADOW_COLOR":0,
            "SHARK_TOOTH_COLOR":[15395562,15395562],
            "TOOLTIP_ALPHA":0.9,
            "TOOLTIP_COLOR":2039583
         }
      };
      
      public static const DEFAULT_FONT_FAMILY:String = "Arial Unicode MS,Arial Unicode,Arial,Arimo,_sans";
      
      public static const LANGUAGE_FONT_FAMILY_MAP:Object = {
         "hi":"Devanagari MT",
         "ja":"TakaoPGothic",
         "th":"Thonburi,Waree",
         "zh":"WenQuanYi Micro Hei,Droid Sans Fallback"
      };
      
      public static const H1_TEXT_SIZE:int = 32;
      
      public static const H2_TEXT_SIZE:int = 24;
      
      public static const H3_TEXT_SIZE:int = 18;
      
      public static const H4_TEXT_SIZE:int = 16;
      
      public static const H5_TEXT_SIZE:int = 12;
      
      public static const H6_TEXT_SIZE:int = 11;
      
      public static const DEFAULT_TEXT_SIZE:int = H6_TEXT_SIZE;
      
      public static const BLACK:uint = 0;
      
      public static const GRAY:uint = 3355443;
      
      public static const WHITE:uint = 16777215;
      
      protected static const REFERENCE_HEIGHT:Number = 360;
      
      protected static const REFERENCE_WIDTH:Number = 480;
      
      protected static const MIN_SCALE:Number = 0.53;
      
      public static const TEXT_PADDING:int = 5;
      
      protected static var themeValue:String = DARK_THEME;
      
      public static var fontFamily:String = DEFAULT_FONT_FAMILY;
      
      public function Theme()
      {
         super();
      }
      
      public static function getScaleFactor(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         if(param1 / param2 > REFERENCE_WIDTH / REFERENCE_HEIGHT)
         {
            _loc3_ = param2;
            _loc4_ = REFERENCE_HEIGHT;
         }
         else
         {
            _loc3_ = param1;
            _loc4_ = REFERENCE_WIDTH;
         }
         return Math.max(MIN_SCALE,Math.min(_loc3_ / _loc4_,1));
      }
      
      public static function newButtonDropShadow() : DropShadowFilter
      {
         return new DropShadowFilter(1,90,getConstant("DROP_SHADOW_COLOR"),1,getConstant("DROP_SHADOW_BLUR"),getConstant("DROP_SHADOW_BLUR"),1,3,false,false,false);
      }
      
      public static function getIconFilters() : Array
      {
         if(themeValue == DARK_THEME)
         {
            return [newButtonDropShadow()];
         }
         return [];
      }
      
      public static function newTextField(param1:TextFormat = null) : TextField
      {
         var _loc2_:TextField = new TextField();
         _loc2_.defaultTextFormat = param1 || newTextFormat();
         _loc2_.selectable = false;
         _loc2_.mouseEnabled = false;
         _loc2_.autoSize = TextFieldAutoSize.LEFT;
         return _loc2_;
      }
      
      public static function setActiveInterfaceLanguage(param1:String) : void
      {
         fontFamily = getFont(param1) || DEFAULT_FONT_FAMILY;
      }
      
      public static function newActiveButton(param1:Class, param2:Class = null) : Object
      {
         return {
            "up":newMaskedIcon(getConstant("ICON_ACTIVE_COLORS"),new param1(),param2 ? new param2() : null,true),
            "over":newMaskedIcon(getConstant("ICON_ACTIVE_OVER_COLORS"),new param1(),param2 ? new param2() : null,true)
         };
      }
      
      public static function getConstant(param1:String, param2:String = null) : *
      {
         if(!param2)
         {
            param2 = themeValue;
         }
         return param1 in THEME_CONSTANTS[param2] ? THEME_CONSTANTS[param2][param1] : THEME_CONSTANTS["common"][param1];
      }
      
      public static function newButtonGlow() : GlowFilter
      {
         return new GlowFilter(getConstant("GLOW_COLOR"),getConstant("GLOW_ALPHA"),15,15,1);
      }
      
      public static function newDropShadow() : DropShadowFilter
      {
         return new DropShadowFilter(1,45,0,0.75,1,1,1,3,false,false,false);
      }
      
      public static function setActiveTheme(param1:String) : void
      {
         if(param1 in THEME_CONSTANTS)
         {
            themeValue = param1;
         }
      }
      
      public static function newTextFormat(param1:int = 11, param2:int = 16777215) : TextFormat
      {
         return new TextFormat(fontFamily,param1,param2);
      }
      
      public static function getClass(param1:String) : Class
      {
         var _loc2_:Class = themeValue == DARK_THEME ? DarkTheme : LightTheme;
         var _loc3_:Class = DarkTheme;
         return _loc2_[param1] || _loc3_[param1];
      }
      
      public static function setActiveColor(param1:Array) : void
      {
         THEME_CONSTANTS.common.PROGRESS_BAR = param1;
      }
      
      public static function getFont(param1:String) : String
      {
         param1 = param1.split(/[-_]/)[0];
         if(LANGUAGE_FONT_FAMILY_MAP[param1])
         {
            return [LANGUAGE_FONT_FAMILY_MAP[param1],DEFAULT_FONT_FAMILY].join(",");
         }
         return fontFamily;
      }
      
      public static function newMaskedIcon(param1:Array, param2:Sprite, param3:Sprite = null, param4:Boolean = false) : Sprite
      {
         var _loc8_:Array = null;
         var _loc9_:Sprite = null;
         var _loc5_:Sprite = new Sprite();
         param2.cacheAsBitmap = true;
         var _loc6_:Rectangle = param2.getBounds(param2);
         var _loc7_:Shape = new Shape();
         drawing(_loc7_.graphics).fill(param1,null,null,90,_loc6_.width,_loc6_.height,_loc6_.x,_loc6_.y).rect(_loc6_.x,_loc6_.y,_loc6_.width,_loc6_.height);
         _loc7_.cacheAsBitmap = true;
         _loc5_.addChild(_loc7_);
         _loc5_.addChild(param2);
         _loc5_.mask = param2;
         _loc5_.cacheAsBitmap = true;
         _loc5_.filters = getIconFilters();
         if(param4)
         {
            _loc8_ = _loc5_.filters;
            _loc8_.push(newButtonGlow());
            _loc5_.filters = _loc8_;
         }
         if(param3)
         {
            _loc9_ = new Sprite();
            _loc9_.addChild(_loc5_);
            _loc9_.addChild(param3);
            return _loc9_;
         }
         return _loc5_;
      }
      
      public static function getSeekHandleFilters() : Array
      {
         if(themeValue == LIGHT_THEME)
         {
            return [new DropShadowFilter(2,90,0,0.25,3,3)];
         }
         return [];
      }
      
      public static function autoSizeTextFieldToWidth(param1:TextField, param2:Number) : void
      {
         if(!param1.text)
         {
            param1.text = " ";
         }
         param1.autoSize = TextFieldAutoSize.NONE;
         param1.multiline = true;
         param1.wordWrap = true;
         param1.width = param2;
         param1.height = param1.textHeight + TEXT_PADDING;
      }
      
      public static function newButton(param1:Class, param2:Class = null) : Object
      {
         return {
            "up":newMaskedIcon(getConstant("ICON_COLORS"),new param1(),param2 ? new param2() : null,false),
            "over":newMaskedIcon(getConstant("ICON_OVER_COLORS"),new param1(),param2 ? new param2() : null,true)
         };
      }
   }
}

