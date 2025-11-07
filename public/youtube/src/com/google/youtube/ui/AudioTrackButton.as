package com.google.youtube.ui
{
   import com.google.youtube.model.AudioTrack;
   import com.google.youtube.model.AudioTrackChangeEvent;
   import com.google.youtube.model.IMessages;
   import com.google.youtube.model.MessageEvent;
   import com.google.youtube.model.WatchMessages;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class AudioTrackButton extends ControlButton
   {
      
      protected var currentTrackValue:String;
      
      protected var tracks:Object = {};
      
      protected var titleContainer:Sprite;
      
      protected var title:TextField;
      
      protected var menu:PopupMenu = new PopupMenu();
      
      protected var selectedBackground:MovieClip;
      
      protected var shortNames:Object = {};
      
      public function AudioTrackButton(param1:IMessages)
      {
         super(param1,"<>");
         this.menu.classOrderPriority = classOrderPriority;
         tooltipMessage = WatchMessages.AUDIO_TRACK_TITLE;
         mouseChildren = true;
         tabChildren = true;
         this.build();
      }
      
      public function hideMenu() : void
      {
         if(contains(this.menu))
         {
            removeChild(this.menu);
            this.selectedBackground.alpha = 0;
            redraw();
         }
      }
      
      override protected function onRemovedFromStage(param1:Event) : void
      {
         super.onRemovedFromStage(param1);
         stageAmbassador.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown);
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         super.setSize(param1,param2);
         if(this.selectedBackground)
         {
            this.selectedBackground.width = param1 + 4;
            this.selectedBackground.height = param2;
         }
      }
      
      public function setTracks(param1:Array) : void
      {
         var _loc2_:MenuItem = null;
         var _loc3_:String = null;
         var _loc4_:AudioTrack = null;
         var _loc5_:String = null;
         var _loc6_:MenuItem = null;
         for each(_loc2_ in this.tracks)
         {
            this.menu.remove(_loc2_);
         }
         this.tracks = {};
         this.shortNames = {};
         for each(_loc4_ in param1)
         {
            _loc5_ = "";
            if(_loc4_.language)
            {
               _loc5_ = messages.getMessage("AUDIO_TRACK_" + _loc4_.language.toUpperCase().replace("-","_"));
               this.shortNames[_loc4_.name] = /(x-)?(.*)/.exec(_loc4_.language)[2];
            }
            else
            {
               this.shortNames[_loc4_.name] = _loc4_.name.slice(0,2);
            }
            _loc5_ ||= _loc4_.name;
            _loc6_ = new MenuItem(_loc5_,MenuItem.Bullet,TextFormatAlign.LEFT);
            _loc6_.addEventListener(MouseEvent.CLICK,this.clickHandler(this,_loc4_.name));
            this.menu.add(_loc6_);
            this.tracks[_loc4_.name] = _loc6_;
            if(_loc4_.isDefault)
            {
               _loc3_ = _loc4_.name;
            }
         }
         this.currentTrack = _loc3_;
      }
      
      protected function onStageMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         if(_loc2_ != this && !contains(_loc2_))
         {
            this.hideMenu();
         }
      }
      
      protected function onLabelsMessageUpdate(param1:MessageEvent) : void
      {
         this.title.text = messages.getMessage(WatchMessages.AUDIO_TRACK_TITLE);
      }
      
      public function get currentTrack() : String
      {
         return this.currentTrackValue;
      }
      
      protected function clickHandler(param1:EventDispatcher, param2:String) : Function
      {
         var dispatcher:EventDispatcher = param1;
         var label:String = param2;
         return function(param1:MouseEvent):void
         {
            if(!param1.target.enabled)
            {
               return;
            }
            dispatcher.dispatchEvent(new AudioTrackChangeEvent(AudioTrackChangeEvent.CHANGE,label));
            param1.stopPropagation();
            hideMenu();
            setState(stateValue.onRollOut());
         };
      }
      
      public function set currentTrack(param1:String) : void
      {
         var _loc2_:MenuItem = null;
         this.currentTrackValue = param1;
         for each(_loc2_ in this.tracks)
         {
            _loc2_.selected = _loc2_ == this.tracks[param1];
         }
         labels["default"] = this.shortNames[param1];
         redraw();
      }
      
      protected function build() : void
      {
         var _loc1_:Shape = null;
         var _loc2_:TextFormat = null;
         _loc1_ = new Shape();
         Drawing.invisibleRect(_loc1_.graphics,0,0,1,4);
         this.title = Theme.newTextField();
         _loc2_ = this.title.defaultTextFormat;
         _loc2_.leftMargin = 20;
         _loc2_.rightMargin = 20;
         this.title.mouseEnabled = false;
         this.title.defaultTextFormat = _loc2_;
         this.titleContainer = new Sprite();
         this.titleContainer.useHandCursor = false;
         this.titleContainer.addChild(this.title);
         this.selectedBackground = new (Theme.getClass("BgSelected"))();
         addChildAt(this.selectedBackground,getChildIndex(background));
         this.selectedBackground.alpha = 0;
         this.selectedBackground.x = -1;
         this.menu.order(this.titleContainer,Sprite,_loc1_);
         this.menu.add(_loc1_);
         this.menu.add(this.titleContainer);
         messages.addEventListener(MessageEvent.UPDATE,this.onLabelsMessageUpdate);
      }
      
      override public function onClick(param1:MouseEvent) : void
      {
         super.onClick(param1);
         if(!enabled)
         {
            return;
         }
         var _loc2_:Boolean = contains(this.menu);
         if(_loc2_)
         {
            this.hideMenu();
         }
         else
         {
            this.showMenu();
         }
      }
      
      public function showLoaded() : void
      {
         hideNotification();
      }
      
      override protected function transformText(param1:String, param2:DisplayObject) : String
      {
         param1 = super.transformText(param1,param2);
         var _loc3_:TextField = TextField(param2);
         var _loc4_:TextFormat = _loc3_.defaultTextFormat;
         _loc4_.rightMargin = 2;
         _loc3_.defaultTextFormat = _loc4_;
         _loc3_.text = param1;
         return param1;
      }
      
      override protected function onAddedToStage(param1:Event) : void
      {
         super.onAddedToStage(param1);
         stageAmbassador.addEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown);
      }
      
      protected function showMenu() : void
      {
         var _loc1_:Rectangle = null;
         if(!contains(this.menu))
         {
            addChild(this.menu);
            this.selectedBackground.alpha = 1;
            this.menu.visible = true;
            _loc1_ = this.menu.container.getBounds(this.menu);
            this.menu.x = (nominalWidth - _loc1_.width) / 2;
            this.menu.y = -_loc1_.bottom;
            redraw();
         }
      }
      
      public function showLoading() : void
      {
         showNotification(new AnimatedElement(new MiniSpinner()));
      }
   }
}

