package src
{
	import fl.transitions.Tween;
	import fl.transitions.easing.Strong;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;

	public class Graph extends Sprite
	{

		private var graphContainer:Sprite = new Sprite();
		private var xmlFile:XML;
		private var urlLoader:URLLoader = new URLLoader();
		private var totalBars:int;

		private var tween:Tween;
		private var tf:TextFormat = new TextFormat();
		
		

		public function Graph(nms:Array,vl:Array,mxvl:Array,mnvl:Array):void
		{
			/* Text Format */
			tf.color = 0x666666;
			tf.size = 12;
			tf.font = "Helvetica";
			createGraphContainer();
			trace("nms.length="+nms.length);
			if(nms.length!=0){
				createBars(vl,mxvl,mnvl);
				displayNames(nms);
			}
		}

		private function createGraphContainer():void
		{
			graphContainer.graphics.lineStyle(2, 0x9C9C9E);
			graphContainer.graphics.moveTo(0, 0);
			graphContainer.graphics.lineTo(0, 90);
			graphContainer.graphics.lineTo(280, 90);

			addChild(graphContainer);
		}
		
		private function createBars(vl:Array,mxvl:Array,mnvl:Array):void
		{
			for (var i:int = 0; i < vl.length; i++)
			{
				var bar:Sprite = new Sprite();
				switch(i){
					case 0:bar.graphics.beginFill(0xFF0000);
						break;
					case 1:bar.graphics.beginFill(0x25B7E2);
						break;
					case 2:bar.graphics.beginFill(0xB8CF36);
						break;
				}
				bar.graphics.drawRect(0, 0, 40, int((vl[i]-mnvl[i])/(mxvl[i]-mnvl[i])*89)+1);
				bar.graphics.endFill();

				bar.x = 10+(40* i) + (10*i);
				bar.y = 90- bar.height;

				var val:TextField = new TextField();

				val.defaultTextFormat = tf;
				val.autoSize = TextFieldAutoSize.RIGHT;
				if(vl[i]-Math.floor(vl[i])==0){
					val.text = String(vl[i]);
				}else{
					val.text = String(vl[i].toFixed(2));
				}
				val.x = bar.x+20-val.width/2;
				val.y = 70 - bar.height;

				tween = new Tween(bar,"height",Strong.easeOut,0,bar.height,1,true);
				
				addChild(bar);
				addChild(val);
			}
		}

		private function displayNames(nms:Array):void
		{
			var sum:Number=0;
			for (var i:int = 0; i < nms.length; i++)
			{
				var color:Sprite = new Sprite();
				var names:TextField = new TextField();
				switch(i){
					case 0:color.graphics.beginFill(0xFF0000);
						break;
					case 1:color.graphics.beginFill(0x25B7E2);
						break;
					case 2:color.graphics.beginFill(0xB8CF36);
						break;
				}
				
				names.text = nms[i];
				names.defaultTextFormat = tf;
				names.autoSize = TextFieldAutoSize.LEFT;
				names.wordWrap=true;
				names.x = 170;
				names.y =sum;
				names.width=this.width-names.x;
				sum+=names.height;

				color.graphics.drawRect(0, 0, 10, 10);
				color.graphics.endFill();
				color.x = 160;
				color.y = 3 + names.y;

				addChild(names);
				addChild(color);
			}
		}
	}
}
