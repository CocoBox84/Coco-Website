package com.google.youtube.ui
{
   public class Sparkline extends UIElement
   {
      
      protected var data:Array = [];
      
      public function Sparkline()
      {
         super();
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         Drawing.invisibleRect(background.graphics,0,0,param1,param2);
         super.setSize(param1,param2);
      }
      
      public function get last() : Number
      {
         return this.data[this.data.length - 1];
      }
      
      override protected function redraw() : void
      {
         var i:int;
         var min:Number = NaN;
         var max:Number = NaN;
         var alpha:Number = NaN;
         var start:int = Math.max(this.data.length - nominalWidth,0);
         var end:int = int(this.data.length);
         min = Number(Math.min.apply(null,this.data.slice(start)));
         max = Number(Math.max.apply(null,this.data.slice(start)));
         var ypos:Function = function(param1:Number):Number
         {
            if(max == min)
            {
               return nominalHeight;
            }
            var _loc2_:Number = Math.min((param1 - min) / (max - min),1);
            return nominalHeight - Math.floor(_loc2_ * nominalHeight);
         };
         graphics.clear();
         graphics.moveTo(0,ypos(this.data[start]));
         i = start + 1;
         while(i < end)
         {
            alpha = 0.25;
            if(end - i < 4)
            {
               alpha += 1 - (end - i) / 4;
            }
            if(i - start < 5)
            {
               alpha *= (i - start) / 5;
            }
            graphics.lineStyle(1,16777215,alpha);
            graphics.lineTo(i - start,ypos(this.data[i]));
            i++;
         }
      }
      
      public function push(param1:Number) : void
      {
         this.data.push(param1 || 0);
         if(this.data.length > nominalWidth * 2)
         {
            this.data.splice(0,this.data.length - nominalWidth);
         }
         this.redraw();
      }
   }
}

