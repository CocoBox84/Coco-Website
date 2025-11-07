package com.google.youtube.application
{
   import com.google.utils.RequestVariables;
   import com.google.youtube.model.Environment;
   import com.google.youtube.util.StageAmbassador;
   import flash.events.IEventDispatcher;
   
   public interface IApplication extends IEventDispatcher
   {
      
      function handleError(param1:Error, param2:RequestVariables = null) : void;
      
      function destroy() : void;
      
      function guardedCall(param1:Function, ... rest) : *;
      
      function set environment(param1:Environment) : void;
      
      function onInited() : void;
      
      function get stageAmbassador() : StageAmbassador;
      
      function init() : void;
      
      function get environment() : Environment;
      
      function build() : void;
      
      function initData() : void;
      
      function set stageAmbassador(param1:StageAmbassador) : void;
   }
}

