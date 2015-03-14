package src {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.geom.*;
	import com.greensock.*;
	import com.greensock.plugins.*;
	
	public class Region extends MovieClip {
		private var _url:String = "";
		private var _imageUrl:String = "";
		private var _description:String = "";
		private var _title:String = "";
		private var _type:String = "";
		
		private var nameOfProperty:Array = new Array();
		private var valueOfProperty:Array = new Array();
		private var sectorOfProperty:Array = new Array();
		private var siOfProperty:Array = new Array();
		
		private var _clip:MovieClip;
		private var _center:MovieClip;
		
		public function Region() {
			// constructor code
			_clip = this["clip"];
			_center = this["center"];
			// Проверяем доступность сцены
			(stage) ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event=null):void{
			// Активируем плагины фильтров для TweenMax
			TweenPlugin.activate([DropShadowFilterPlugin, GlowFilterPlugin, ColorMatrixFilterPlugin]);
			// Добавляем прослушивателей поведения мыши
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseListener);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseListener);
			this.addEventListener(MouseEvent.CLICK, mouseListener);
			this.mouseChildren = false;
			this.useHandCursor = true;
			this.buttonMode = true;
		}
		
		public function nameOfPropertyLen():int{
			return nameOfProperty.length;
		}
		
		public function setProp(i:int, name:String, value:Number,sector:String,si:String){
			nameOfProperty[i]=name;
			valueOfProperty[i]=value;
			sectorOfProperty[i]=sector;
			siOfProperty[i]=si;
		}
		
		public function getPropSi(i:int):String{
			return siOfProperty[i];
		}
		
		public function getPropName(i:int):String{
			return nameOfProperty[i];
		}
		
		public function getPropValue(i:int):Number{
			return valueOfProperty[i];
		}
		
		public function getPropSector(i:int):String{
			return sectorOfProperty[i];
		}
		
		// Расширяем на свойство url
		public function get url():String{
			return _url;
		}
		
		public function set url(value:String):void{
			_url = value;
		}
		
		// Расширяем на свойство imageUrl
		public function get imageUrl():String{
			return _imageUrl;
		}
		
		public function set imageUrl(value:String):void{
			_imageUrl = value;
		}
		
		// Расширяем на свойство description
		public function get description():String{
			return _description;
		}
		
		public function set description(value:String):void{
			_description = value;
		}
		
		// Расширяем на свойство type
		public function get type():String{
			return _type;
		}
		
		public function set type(value:String):void{
			_type = value;
		}
		
		// Расширяем на свойство title
		public function get title():String{
			return _title;
		}
		
		public function set title(value:String):void{
			_title = value;
		}
		
		// Расширяем на свойство «только для чтения» pointGlobalCenter -  координаты относительно сцены у клипа _center.  
		public function get pointGlobalCenter():Point{
			return localToGlobal(new Point(_center.x, _center.y));
		}
		public function mOver(){
			// Меняем индекс нашего клипа в родительском клипе на самый верхний индекс. Т. е. Выносим его поверх всех клипов в родительском ролике
			this.parent.setChildIndex(this, this.parent.numChildren-1);
			// Применим к клипу clip цвет и анимируем смену цвета
			TweenMax.to(_clip, 0.5, {colorTransform:{tint:0x00ffff, tintAmount:0.8}});
			// Применим к клипу эффект тени и анимируем появление тени. Этим самым создастя впячетление приподнятия клипа (района)
			TweenMax.to(this, 0.5, {dropShadowFilter:{color:0x000000, alpha:1, blurX:7, blurY:7, strength:1, distance:5}, glowFilter:{color:0xffffff, alpha:1, blurX:4, blurY:4, strength:0.5}});
			// Диспатчим сцену о том, что нужно показать всплывающую подсказку. В событием передадим объект (наш клип), который отправил событие, чтобы получить все данные связанные с этим клипом (url, title, imageUrl, description, pointGlobalCenter)
			stage.dispatchEvent(new ShowToolTipEvent(ShowToolTipEvent.SHOW, this));
		}
		public function mOut(){
			// Возвращаем цвет клипу и убираем тень
			TweenMax.to(_clip, 0.5, {colorTransform:{tint:0x66ff00, tintAmount:0}});
			TweenMax.to(this, 0.5, {dropShadowFilter:{color:0x000000, alpha:0, blurX:0, blurY:0, strength:0, distance:0}, glowFilter:{color:0x000000, alpha:0, blurX:0, blurY:0, strength:0}});
			// Диспатчим сцену о скрытии тултипа (подсказки)
			stage.dispatchEvent(new Event("hidetooltip"));
		}
		private function mouseListener(event:MouseEvent):void{
			switch(event.type){
				case "mouseOver": {
					mOver();
					break;
				}
				case "mouseOut":{
					mOut();
					break;
				}
				case "click":{
					// Если кликнули – переходим на страницу с подробной информацией о районе.
					try {
						navigateToURL(new URLRequest(_url), "_blank");
					}catch (e:Error) {
						trace("ошибка");
					}
					break;
				}
			}
		}
	}
} 
