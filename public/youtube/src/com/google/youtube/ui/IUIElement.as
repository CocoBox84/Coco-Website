package com.google.youtube.ui
{
   import flash.display.DisplayObject;
   import flash.events.IEventDispatcher;
   import flash.geom.Rectangle;
   
   public interface IUIElement extends ILayoutElement, IEventDispatcher
   {
      
      function get isAccessible() : Boolean;
      
      function get accessibleName() : String;
      
      function set accessibleName(param1:String) : void;
      
      function setSize(param1:Number, param2:Number) : void;
      
      function set visible(param1:Boolean) : void;
      
      function get accessibleDescription() : String;
      
      function set isAccessible(param1:Boolean) : void;
      
      function get enabled() : Boolean;
      
      function set enabled(param1:Boolean) : void;
      
      function set shortcutKey(param1:String) : void;
      
      function setPosition(param1:Number, param2:Number) : void;
      
      function set accessibleDescription(param1:String) : void;
      
      function setState(param1:IUIState) : IUIState;
      
      function setLabel(param1:String, param2:Boolean = true) : void;
      
      function getState() : IUIState;
      
      function get visible() : Boolean;
      
      function set accessibleState(param1:String) : void;
      
      function get shortcutKey() : String;
      
      function getBounds(param1:DisplayObject) : Rectangle;
      
      function get accessibleState() : String;
      
      function set tabOrderPriority(param1:int) : void;
      
      function get tabOrderPriority() : int;
   }
}

