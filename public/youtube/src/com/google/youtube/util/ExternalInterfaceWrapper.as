package com.google.youtube.util
{
   import flash.external.ExternalInterface;
   import flash.utils.getQualifiedClassName;
   
   public class ExternalInterfaceWrapper
   {
      
      protected static var testedCall:Boolean;
      
      protected static var callFailed:Boolean;
      
      protected static const LEGAL_FUNCTION_NAME:RegExp = /^[a-zA-Z0-9_.$]+$/;
      
      public static var interfaceOverride:Object = ExternalInterface;
      
      public function ExternalInterfaceWrapper()
      {
         super();
      }
      
      public static function addCallback(param1:String, param2:Function) : void
      {
         var name:String = param1;
         var fn:Function = param2;
         var sanitized:Function = function():Object
         {
            return sanitizeArg(fn.apply(null,arguments));
         };
         ExternalInterface.addCallback(checkName(name),sanitized);
      }
      
      public static function get available() : Boolean
      {
         return ExternalInterface.available && !callFailed;
      }
      
      private static function checkName(param1:String) : String
      {
         if(param1.match(LEGAL_FUNCTION_NAME))
         {
            return param1;
         }
         throw new SecurityError("Illegal ExternalInterface call argument \'" + param1 + "\'.");
      }
      
      private static function sanitizeArg(param1:Object) : Object
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(param1 == null)
         {
            return null;
         }
         switch(getQualifiedClassName(param1.constructor))
         {
            case "Array":
            case "Object":
               _loc2_ = param1 is Array ? [] : {};
               for(_loc3_ in param1)
               {
                  _loc2_[checkName(_loc3_)] = sanitizeArg(param1[_loc3_]);
               }
               return _loc2_;
            case "Number":
            case "Boolean":
               return param1;
            case "String":
         }
         return String(param1).replace(/\\/g,"\\\\").replace(/ /g," ");
      }
      
      public static function call(... rest) : *
      {
         var i:Number;
         var result:* = undefined;
         var args:Array = rest;
         args[0] = checkName(args[0]);
         i = 1;
         while(i < args.length)
         {
            args[i] = sanitizeArg(args[i]);
            i++;
         }
         try
         {
            result = interfaceOverride.call.apply(interfaceOverride,args);
            testedCall = true;
            return result;
         }
         catch(error:SecurityError)
         {
            callFailed = true;
            throw error;
         }
      }
      
      public static function get allowScriptAccess() : Boolean
      {
         if(testedCall)
         {
            return available;
         }
         try
         {
            return available && call("isNaN");
         }
         catch(error:SecurityError)
         {
         }
         return false;
      }
   }
}

