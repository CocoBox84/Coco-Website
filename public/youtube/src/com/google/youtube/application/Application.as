package com.google.youtube.application
{
   import com.google.utils.RequestVariables;
   import com.google.youtube.model.Environment;
   import com.google.youtube.util.StageAmbassador;
   import com.google.youtube.util.getDefinition;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   
   public class Application extends Sprite implements IApplication
   {
      
      protected static const BUILD_POLICY_AUTO:int = 4;
      
      protected static const BUILD_POLICY_MANUAL:int = 5;
      
      protected static const UncaughtErrorEvent:Object = getDefinition("flash.events.UncaughtErrorEvent");
      
      protected var buildPolicy:int = 5;
      
      protected var contextValue:Object = {};
      
      protected var stageAmbassadorValue:StageAmbassador;
      
      protected var environmentValue:Environment;
      
      public function Application(param1:Object = null)
      {
         super();
         this.context = param1 || loaderInfo;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         if(this.context is IEventDispatcher)
         {
            this.context.addEventListener(Event.INIT,this.onInit);
         }
      }
      
      public static function registerErrorHandler(param1:Object, param2:Function) : void
      {
         if(Boolean(UncaughtErrorEvent) && Boolean(param1.hasOwnProperty("uncaughtErrorEvents")))
         {
            Object(param1).uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,param2);
         }
      }
      
      public function destroy() : void
      {
      }
      
      public function build() : void
      {
      }
      
      protected function onInit(param1:Event) : void
      {
         this.init();
      }
      
      public function init() : void
      {
         if(!this.environment)
         {
            this.environment = new Environment(this.context);
         }
         this.guardedCall(this.initData);
      }
      
      public function get environment() : Environment
      {
         return this.environmentValue;
      }
      
      protected function onRemovedFromStage(param1:Event) : void
      {
         if(Boolean(this.stageAmbassador.focus) && (this.stageAmbassador.focus == this || contains(this.stageAmbassador.focus)))
         {
            this.stageAmbassador.focus = null;
         }
      }
      
      public function handleError(param1:Error, param2:RequestVariables = null) : void
      {
         this.environment.handleError(param1,param2);
      }
      
      public function initData() : void
      {
         this.onInited();
      }
      
      public function get stageAmbassador() : StageAmbassador
      {
         return this.stageAmbassadorValue;
      }
      
      protected function onAddedToStage(param1:Event) : void
      {
         if(!this.stageAmbassador)
         {
            this.stageAmbassador = new StageAmbassador(this);
         }
      }
      
      public function guardedCall(param1:Function, ... rest) : *
      {
         var f:Function = param1;
         var args:Array = rest;
         try
         {
            return f.apply(null,args);
         }
         catch(error:Error)
         {
            handleError(error);
         }
      }
      
      public function set context(param1:Object) : void
      {
         if(Boolean(param1) && Boolean(param1.parameters))
         {
            this.contextValue = param1;
         }
      }
      
      public function set environment(param1:Environment) : void
      {
         this.environmentValue = param1;
      }
      
      public function get context() : Object
      {
         return this.contextValue;
      }
      
      public function onInited() : void
      {
         if(this.buildPolicy == BUILD_POLICY_AUTO)
         {
            this.build();
         }
      }
      
      public function set stageAmbassador(param1:StageAmbassador) : void
      {
         this.stageAmbassadorValue = param1;
      }
   }
}

