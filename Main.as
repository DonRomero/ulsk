package  src{
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.geom.*;
	import fl.controls.CheckBox;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import com.greensock.*;
	import com.greensock.plugins.*;
	
	public class Main extends MovieClip {
		private var _maps:MapsClip; // Это клип с клипами районов
		private var _region:Region; // С помощью этой переменной мы будем получать данные о районе при мышиных событиях
		private var _r:Array=new Array;
		// Переменные для полученных данных XML файла 
		private var _xml:XML;
		private var _loadXml:URLLoader; 
		private var _xmlRequest:URLRequest;
		private var _tooltip:ToolTip;
		private var _pause:int = 0;
		// Переменная координат для появления подсказки
		private var _point:Point;
		// Постоянные переменные
		private var _ttWidth:Number;
		private var _ttHeight:Number;
		//для graph
		private var _graph:Graph;
		private var nameOfProp:Array=new Array();
		private var sumOfProp:Array = new Array();
		private var valueToGraph:Array = new Array();
		private var maxToGraph:Array = new Array();
		private var minToGraph:Array = new Array();
		private var nameToGraph:Array = new Array();
		private var max1:Array = new Array();
		private var min1:Array = new Array();
		private var minIndex:Array = new Array();
		private var maxIndex:Array = new Array();
		private var selects:Array = ["Население, чел.", "Рождаемость, на тыс.чел.", "Среднемес.зар.плата, р."];
		//для menu
		private var _d1:DropDownMenu=new DropDownMenu("menu.xml","Меню");
		private var _d2:DropDownMenu;
		//checkbox
		private var countcb:int;
		private var tf:TextField;
		private var a:Array= new Array();
		//пробел между картой и меню
		private const space:Number=20;
		//Таблица
		private var tb:Table;
		private var sector:Array=new Array();
		//Редактор
		private var edtb:EditTable;
		//clearScene
		private var iscbOnScene,isTableOnScene,is_d2OnScene,isEditTableOnScene:Boolean; 
		//файл для записи данных
		private var so:SharedObject = SharedObject.getLocal("ulsk");
		
		public function Main() {
			// constructor code
			// Проверяем доступность сцены
			(stage) ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event=null):void{
			// Удаляем прослушиватель добавления на сцену
			removeEventListener(Event.ADDED_TO_STAGE, init); 
			// создадим и добавим слип карты на сцену
			_tooltip = new ToolTip;
			_maps = new MapsClip;
			_maps.x =0;// (stage.stageWidth - _maps.width)/2;
			_maps.y = (stage.stageHeight - _maps.height)/2;
			this.addChild(_maps);			
			//добавление герба
			var gerb=new Gerb();
			gerb.x=(stage.stageWidth-_maps.width)/2-gerb.width/2+_maps.width;
			gerb.y=stage.stageHeight/2-gerb.height/2;
			new TweenLite(gerb,1,{alpha:.15});
			this.addChild(gerb);
			//работа с menu
			_d1.x=0;//_maps.width+space;
			_d1.y=0;
			this.addChild(_d1);
			_d1.addEventListener(DropDownMenuEvent.CHANGE,d1Change);
			// Сцена доступна. Загружаем XML файл.
			_loadXml = new URLLoader;
			_xmlRequest = new URLRequest;
			_xmlRequest.url = "mapsulsk.xml";
			// Подписываемся на конец загрузки XML файла и возможные ошибки загрузки.
			_loadXml.addEventListener(Event.COMPLETE, completeXml);
			_loadXml.addEventListener(IOErrorEvent.IO_ERROR, errorXml);
			_loadXml.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorXml);
			// Загружаем XML 
			_loadXml.load(_xmlRequest);
			this.addChild(_tooltip);
			// Подбиралось опытным путём
			_ttWidth = _tooltip.width/2+5;
			_ttHeight = _tooltip.height/2+55;//55
		}
		
		private function completeXml(event:Event):void{
			_xml = XML(event.target.data);
			xmlToRegion();
		}
		
		private function xmlToRegion(){
			if(so.data.xml!=null) _xml=so.data.xml;
			//trace(_xml.toString());
			nameOfProp.splice(0);
			_r.splice(0);
			sector.splice(0);
			// Парсим xml файл и передаём данные в клипы районов
			var _xmlList:XMLList = _xml.children();
			for(var i:int=0;i<_xmlList[0].children().length()-5;i++){
				max1[i]=0;
				min1[i]=_xmlList[0].elements()[i+5];
				minIndex[i]=0;
				maxIndex[i]=0;
			}
			for(i=0; i<_xmlList.length(); ++i){
				// Ищем объект в клипе _maps по имени класса
				for(var r:int = 0; r<_maps.numChildren; ++r){
					if(getQualifiedClassName(_maps.getChildAt(r))==_xmlList[i].@classname){
						_region = _maps.getChildAt(r) as Region;
						_region.imageUrl = _xmlList[i].elements("image");
						_region.type=_xmlList[i].elements("type");
						_region.title =_xmlList[i].elements("title");
						_region.description = _xmlList[i].elements("discription");
						_region.url = _xmlList[i].elements("url");
						for(var j:int=0;j<_xmlList[i].children().length()-5;j++){
							_region.setProp(j,_xmlList[i].elements()[j+5].@*[0],Number(_xmlList[i].elements()[j+5]),_xmlList[i].elements()[j+5].@*[1],_xmlList[i].elements()[j+5].@*[2]);
							if(sector.length<_xmlList[i].children().length()-4){
								sector[j]=_xmlList[i].elements()[j+5].@*[1];
								sector[j]+=" сектор";
							}
							if(max1[j]<Number(_xmlList[i].elements()[j+5])){
								max1[j]=Number(_xmlList[i].elements()[j+5]);
								maxIndex[j]=i;
							}
							if(min1[j]>Number(_xmlList[i].elements()[j+5])){
								min1[j]=Number(_xmlList[i].elements()[j+5]);
								minIndex[j]=i;
							}
							nameOfProp[j]=_xmlList[i].elements()[j+5].@*[0]+", "+_xmlList[i].elements()[j+5].@*[2];
							
						}
						_r[i]=_region;
					}
				}
			}
			//считываем выбранные критерии
			if(so.data.selects!=null){
				selects=so.data.selects;
			}else{
				so.data.selects=selects;
				so.flush();
			}
			//задаём количество доступных для выбора критериев статистики
			countcb=selects.length;
			// Подписываем сцену на события появления и скрытия подсказки
			stage.addEventListener(ShowToolTipEvent.SHOW, showBallon);
			stage.addEventListener("hidetooltip", hideBallon);
		}
		
		private function errorXml(event:*):void{
			trace(event.type);
		}
		
		private function showBallon(event:ShowToolTipEvent):void{
			// event.object – это и есть район, отправивший событие
			// Загружаем данные в ToolTip
			xmlToRegion();
			_tooltip.titleHtml = event.object.type +" " + event.object.title;
			_tooltip.descriptionHtml = event.object.description;
			_tooltip.loadImage(event.object.imageUrl);
			//Очищаем массивы
			valueToGraph.splice(0);
			maxToGraph.splice(0);
			nameToGraph.splice(0);
			for(var i:int=0;i<selects.length;i++){
				trace(getNum(selects[i]));
				if(getNum(selects[i])>=0){
					nameToGraph[i]=event.object.getPropName(getNum(selects[i]));
					valueToGraph[i]=event.object.getPropValue(getNum(selects[i]));				
				}
				for(var j:int=0;j<nameOfProp.length;j++){
					if(nameOfProp[j]==selects[i]){
						maxToGraph[i]=max1[j];
					}
					if(nameOfProp[j]==selects[i]){
						minToGraph[i]=min1[j];
					}
				}
			}
			trace(nameToGraph[0]+" "+nameToGraph[1]+" "+nameToGraph[2]);
			trace("selects="+selects[0]+" "+selects[1]+" "+selects[2]);
			// Узнаём место события
			_point = event.object.pointGlobalCenter;
			// Расчитываем положение ToolTip относительно сцены и полученной координаты события
			var _deltaY:Number = _maps.width-_ttWidth;
			_tooltip.x = (_point.x<_ttWidth) ? _ttWidth : (_point.x>_deltaY) ? _deltaY : _point.x;
			_tooltip.y = (_point.y<_ttHeight*2) ? (_point.y+_ttHeight) : (_point.y-_ttHeight);
			// запустим паузу на появление клипа на одну секунду.
			_pause = setTimeout(toolTipShow, 700);
		}
		
		private function hideBallon(event:Event):void{
			// Удаляем таймер
			clearTimeout(_pause);
			_graph.visible=false;
			// скрываем ToolTip
			_tooltip.visible = false;
		}
		
		private function toolTipShow(){
			// Удаляем таймер
			clearTimeout(_pause);
			_graph = new Graph(nameToGraph,valueToGraph,maxToGraph,minToGraph);
			_graph.x=_tooltip.x-120;
			_graph.y=_tooltip.y;
			_graph.visible = true;
			this.addChild(_graph);
			// показываем ToolTip
			_tooltip.visible = true;
		}
		
		private function showcb(s:String):void{
			clearScene();
			trace(sector.toString());
			tf=new TextField();
			var txtFormat:TextFormat=new TextFormat();
			var z:Number=0;
			txtFormat.bold=true;
			txtFormat.size=15;
			txtFormat.font="Verdana";
			tf.defaultTextFormat=txtFormat;
			tf.x=_maps.x+_maps.width+space;
			tf.y=_d1.h+5;
			tf.text=s;
			tf.autoSize="left";
			addChild(tf);
			z=_d1.h+tf.height+10;
			a = new Array();
			for(var i:int=0;i<nameOfProp.length;i++){
				if(sector[i]==s){
					a[i] = new CheckBox();
					a[i].x=_maps.x+_maps.width+space;
					a[i].y=z;
					a[i].addEventListener(MouseEvent.CLICK,updateGraph);
					a[i].label=nameOfProp[i];
					a[i].width=stage.stageWidth-(_maps.x+_maps.width+space)-10;
					a[i].width=this.width-a[i].x-20;
					addChild(a[i]);
					z+=a[i].height;
				}
			}
			for(i=0;i<nameOfProp.length;i++){
				for(var j:int=0;j<selects.length;j++){
					if(nameOfProp[i]==selects[j]&&sector[i]==s){
						a[i].selected=true;
					}
				}
			}
			iscbOnScene=true;
		}
		
		private function getNum(label:String):int{
			for(var i:int=0;i<nameOfProp.length;i++){
				if(label==nameOfProp[i]){
					return i;
				}
			}
			return -1;
		}
		
		private function delNum(label:String){
			for(var j:int=0;j<selects.length;j++){
				if(selects[j]==label){
					selects.splice(j,1);
					return;
				}
			}
		}
		
		private function updateGraph(e:MouseEvent):void {
            var cb:CheckBox = CheckBox(e.target);
			if(countcb<3){
				if(cb.selected){
					countcb++;
					selects.push(cb.label);
				}else{
					countcb--;
					delNum(cb.label);
				}
			}else{
				if(!cb.selected){
					countcb--;
					delNum(cb.label);
				}else{
					cb.selected=false;
				}
			}
			so.data.selects=selects;
			so.flush();
        }
		
		private function clearScene():void{
			if(iscbOnScene){
				for(var i:int=0;i<a.length;i++){
					if(tf.text==sector[i]){
						this.removeChild(DisplayObject(a[i]));
					}
				}
				this.removeChild(DisplayObject(tf));
			}
			if(isTableOnScene)this.removeChild(DisplayObject(tb));
			if(isEditTableOnScene)this.removeChild(DisplayObject(edtb));
			
			isEditTableOnScene=false;
			iscbOnScene=false;
			isTableOnScene=false;
		}
		
		private function showTable(s:String){
			clearScene();
			tb=new Table(nameOfProp,max1,min1,maxIndex,minIndex,stage.stageWidth-_maps.width-space,_r,sector,s);
			tb.x=_maps.x+_maps.width+space;
			tb.y=5+_d1.h;
			this.addChild(tb);
			isTableOnScene=true;
		}
		
		private function showEditTable(s:String){
			clearScene();
			var n:int;
			switch(s){
				case "Создать":n=0;
					break;
				case "Удалить":n=2;
					break;
				case "Редактировать":n=1;
					break;
			}
			trace(_xml.toString());
			edtb=new EditTable(n,_r,_xml);
			edtb.x=_maps.x+_maps.width+space;
			edtb.y=5+_d1.h;
			edtb.width=stage.stageWidth-_maps.width-space-10;
			this.addChild(edtb);
			isEditTableOnScene=true;
		}
		
		private function d1Change(e:DropDownMenuEvent):void{
			xmlToRegion();
			if(is_d2OnScene){
				this.removeChild(DisplayObject(_d2));
			}
			switch (e.caption){
				case "Критерии статистики":showcb("Социальный сектор");
					_d2=new DropDownMenu("sectormenu.xml",e.caption,1);
					break;
				case "Сводная информация":showTable("Социальный сектор");
					_d2=new DropDownMenu("sectormenu.xml",e.caption,1);
					break;
				case "Редактор":showEditTable("Создать");
					_d2=new DropDownMenu("editmenu.xml",e.caption,1);
					break;
			}
			_d2.addEventListener(DropDownMenuEvent.CHANGE,d2Change);
			_d2.x=stage.stageWidth-_d2.width;
			_d2.y=0;
			this.addChild(_d2);
			is_d2OnScene=true;
		}	
		
		private function d2Change(e:DropDownMenuEvent):void{
			xmlToRegion();
			switch(_d2.caption){
				case "Критерии статистики":showcb(e.caption);
					break;
				case "Сводная информация":showTable(e.caption);
					break;
				case "Редактор":showEditTable(e.caption);
					break;
			}
			this.addChildAt(_d2,numChildren-1);
		}
	}
}
