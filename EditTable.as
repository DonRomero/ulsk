package  src{
	import flash.text.*;
	import fl.controls.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	
	public class EditTable extends Sprite {
		private var tf:TextField;
		private var txtFormatTf:TextFormat = new TextFormat();
		private var txtFormatEdit:TextFormat = new TextFormat();
		private var r:Array=new Array();
		private var maxLength:int=0;
		private var btn:Button;
		private var _xml:XML;
		private var _loadXml:URLLoader; 
		private var _xmlRequest:URLRequest;
		private var so:SharedObject = SharedObject.getLocal("ulsk");
		
		public function EditTable(n:int,_r:Array,xml:XML) {
			_xml=xml;
			for(var i:int=0;i<_r.length;i++){
				r[i]=_r[i];
			}
			trace(r[0].nameOfPropertyLen());
			if(n==1&&r[0].nameOfPropertyLen()==0){
				n=0;
			}
			switch(n){
				case 0:createTable(true);
					break;
				case 1:createTable(false,r[0].getPropName(0));
					break;
				case 2:deleteTable();
					break;
			}
		}
		
		private function createTable(createOrEdit:Boolean,selectedItem:String=""){
			var z:Number=0;
			var edit:TextField;
			var comboBox:ComboBox;
			var num:int;

			for(var i:int=0;i<r[0].nameOfPropertyLen();i++){
				if(r[0].getPropName(i)==selectedItem){
					num=i;
					break;
				}
			}
			
			txtFormatTf.color=0x000000;
			txtFormatTf.size=15;
			txtFormatTf.bold=true;
			txtFormatTf.font="Verdana";
			
			txtFormatEdit.color=0xCCCCCC;
			txtFormatEdit.size=10;
			txtFormatEdit.bold=true;
			txtFormatEdit.font="Verdana";
			txtFormatEdit.italic=true;
			
			tf=new TextField();
			tf.x=0;
			tf.y=z;
			tf.defaultTextFormat=txtFormatTf;
			if(createOrEdit){
				tf.text="Создание критерия статистики";
			}else{
				tf.text="Редактирование критерия статистики";
			}
			tf.autoSize="left";
			addChild(tf);
			z+=tf.height;
			
			if(!createOrEdit){
				tf=new TextField();
				tf.x=0;
				tf.y=z;
				tf.defaultTextFormat=txtFormatTf;
				tf.text="Критерий:";
				tf.autoSize="left";
				addChild(tf);
				comboBox=new ComboBox;
				comboBox.x=this.width/60*25;
				comboBox.y=tf.y;
				comboBox.width=this.width-comboBox.x;
				for(i=0;i<r[0].nameOfPropertyLen();i++){
					comboBox.addItem({label:r[0].getPropName(i)+", "+r[0].getPropSi(i)});
				}
				comboBox.selectedIndex=num;
				comboBox.addEventListener(Event.CHANGE,comboChangeListener);
				addChild(comboBox);
				
				z+=comboBox.height+3;
			}
			
			txtFormatTf.size=10.5;
			if(createOrEdit){
				tf=new TextField();
				tf.x=0;
				tf.y=z;
				tf.defaultTextFormat=txtFormatTf;
				tf.text="Название:";
				tf.autoSize="left";
				addChild(tf);
				edit=new TextField();
				edit.x=this.width/60*25;
				edit.y=tf.y;
				edit.width=this.width-tf.width;
				edit.defaultTextFormat=txtFormatEdit;
				edit.type = TextFieldType.INPUT;
				edit.width=this.width-edit.x;
				edit.height=tf.height;
				edit.background=true;
				edit.backgroundColor=0xFFFFFF;
				edit.text="введите значение";
				edit.addEventListener(TextEvent.TEXT_INPUT,editInputListener);
				addChild(edit);
				
				z+=tf.height+3;
			}
			tf=new TextField();
			tf.x=0;
			tf.y=z;
			tf.defaultTextFormat=txtFormatTf;
			tf.text="Ед.измерения:";
			tf.autoSize="left";
			addChild(tf);
			edit=new TextField();
			edit.x=this.width/60*25;
			edit.y=tf.y;
			edit.defaultTextFormat=txtFormatEdit;
			edit.type = TextFieldType.INPUT;
			edit.width=this.width-edit.x;
			edit.height=tf.height;
			edit.background=true;
			edit.backgroundColor=0xFFFFFF;
			if(createOrEdit){
				edit.text="введите значение";
			}else{
				edit.text=r[0].getPropSi(num);
			}
			edit.addEventListener(TextEvent.TEXT_INPUT,editInputListener);
			addChild(edit);
			
			z+=tf.height+3;
			
			tf=new TextField();
			tf.x=0;
			tf.y=z;
			tf.defaultTextFormat=txtFormatTf;
			tf.text="Сектор:";
			tf.autoSize="left";
			addChild(tf);
			comboBox=new ComboBox;
			comboBox.x=this.width/60*25;
			comboBox.y=tf.y;
			comboBox.width=this.width-comboBox.x;
			comboBox.addItem({label:"Социальный"});
			comboBox.addItem({label:"Производственный"});
			comboBox.addItem({label:"Фин.-инвестиционный"});
			comboBox.addItem({label:"Другой"});
			if(!createOrEdit){
				switch(r[0].getPropSector(num)){
					case "Социальный":comboBox.selectedIndex=0;
						break;
					case "Производственный":comboBox.selectedIndex=1;
						break;
					case "Фин.-инвестиционный":comboBox.selectedIndex=2;
						break;
					case "Другой":comboBox.selectedIndex=3;
						break;
				}
			}
			addChild(comboBox);
			
			z+=comboBox.height+3;
			
			for(i=0;i<r.length;i++){
				tf=new TextField();
				tf.x=0;
				tf.y=z;
				tf.defaultTextFormat=txtFormatTf;
				tf.text=r[i].title+":";
				tf.autoSize="left";
				addChild(tf);
				edit=new TextField();
				edit.x=this.width/60*25;
				edit.y=tf.y;
				edit.defaultTextFormat=txtFormatEdit;
				edit.type = TextFieldType.INPUT;
				edit.width=this.width-edit.x;
				edit.height=tf.height;
				edit.background=true;
				edit.backgroundColor=0xFFFFFF;
				if(createOrEdit){
					edit.text="введите значение";
				}else{
					edit.text=r[i].getPropValue(num);
				}
				edit.addEventListener(TextEvent.TEXT_INPUT,editInputListener);
				tf.addEventListener(MouseEvent.MOUSE_OVER,mouseListener);
				tf.addEventListener(MouseEvent.MOUSE_OUT,mouseListener);
				addChild(edit);
				
				z+=tf.height+3;
				
			}
			btn = new Button();
			btn.y=z;
			btn.x=this.width-btn.width;
			btn.setStyle("textFormat",txtFormatTf);
			btn.label="Сохранить";
			btn.addEventListener(MouseEvent.CLICK,btnSaveClickListener);
			addChild(btn);
		}
		
		
		private function deleteTable(){
			var z:Number=0;
			var comboBox:ComboBox;
			
			txtFormatTf.color=0x000000;
			txtFormatTf.size=15;
			txtFormatTf.bold=true;
			txtFormatTf.font="Verdana";
			
			txtFormatEdit.color=0xCCCCCC;
			txtFormatEdit.size=10;
			txtFormatEdit.bold=true;
			txtFormatEdit.font="Verdana";
			txtFormatEdit.italic=true;
			
			tf=new TextField();
			tf.x=0;
			tf.y=z;
			tf.defaultTextFormat=txtFormatTf;
			tf.text="Удаление критерия статистики";
			tf.autoSize="left";
			addChild(tf);
			z+=tf.height;
			
			txtFormatTf.size=10.5;
			
			comboBox=new ComboBox;
			comboBox.x=this.width/60*25;
			comboBox.y=z;
			comboBox.width=this.width-comboBox.x;
			for(var i:int=5;i<_xml.children()[0].elements().length();i++){
				comboBox.addItem({label:_xml.children()[0].elements()[i].@*[0]+", "+_xml.children()[0].elements()[i].@*[2]});
			}
			addChild(comboBox);
			
			z+=comboBox.height+3;
			
			btn = new Button();
			btn.y=z;
			btn.x=this.width-btn.width;
			btn.setStyle("textFormat",txtFormatTf);
			btn.label="Удалить";
			btn.addEventListener(MouseEvent.CLICK,btnDeleteClickListener);
			addChild(btn);
		}
		
		private function errorXml(event:*):void{
			trace(event.type);
		}
		
		private function checkData():Boolean{
			for(var i:int=0;i<_xml.children().length();i++){
				//проверка на число
				if(String(Number(TextField(this.getChildAt(2*i+8)).text))!=TextField(this.getChildAt(2*i+8)).text){
					return false;
				}
			}
			return true;
		}
		
		private function xmlAddItem(i:int,name:String, sector:String, si:String, value:String){
			_xml.children()[i].insertChildAfter(_xml.children()[i].*[_xml.children()[i].*.length()-1],<{"prop"+_xml.children()[i].*.length()} name={name} sector={sector} si={si} >{value}</{"prop"+_xml.children()[i].*.length()}>);
		}
		
		private function comboChangeListener(e:Event){
			var num = numChildren;
			for(var i:int=0;i<num;i++){
				removeChildAt(0);
			}
			createTable(false,ComboBox(e.target).selectedLabel);
		}
		
		private function deleteXml(s:String){
			for(var i:int=0;i<_xml.children().length();i++){
				var _xmlList:XMLList = _xml.children();
				for(var j:int=0; j<_xmlList.length(); ++j){
					if(_xmlList[i].elements()[j].@*[0]+", "+_xmlList[i].elements()[j].@*[2]==s&&s!="undefined"){
						delete(_xmlList[i].elements()[j]);
						break;
					}
				}
			}
			so.data.xml=_xml;
			so.flush();
		}
		
		private function btnDeleteClickListener(e:MouseEvent){
			var s:String=ComboBox(this.getChildAt(1)).selectedLabel;
			if(s==null)return;
			var sel:Array= new Array;
			deleteXml(s);
			var num = numChildren;
			for(var i:int=0;i<num;i++){
				removeChildAt(0);
			}
			sel=so.data.selects;
			trace(sel.toString());
			for(i=0;i<sel.length;i++){
				if(sel[i]==s){
					sel.splice(i,1);
				}
			}
			so.data.selects=sel;
			so.flush();
			deleteTable();
		}
		
		private function saveXml(s:String){
			var name:String;
			if(s=="new"){
				name=TextField(this.getChildAt(2)).text;
			}else{
				name=ComboBox(this.getChildAt(2)).selectedLabel;
			}
			if(checkData()){
				for(var i:int=0;i<_xml.children().length();i++){
					xmlAddItem(i,name,ComboBox(this.getChildAt(6)).selectedLabel,TextField(this.getChildAt(4)).text,TextField(this.getChildAt(2*i+8)).text);
				}
				so.data.xml=_xml;
				so.flush();
			}
		}
		
		private function btnSaveClickListener(e:MouseEvent){
			if(TextField(getChildAt(0)).text=="Создание критерия статистики"){
				saveXml("new");
			}else{
				deleteXml(ComboBox(getChildAt(2)).selectedLabel);
				saveXml("edit");
			}
		}

		private function editInputListener(e:TextEvent){
			var tf:TextField = TextField(e.target);
			var txtFormat:TextFormat = new TextFormat();
			txtFormat.color=0x000000;
			txtFormat.size=10;
			txtFormat.bold=true;
			txtFormat.font="Verdana";
			if(tf.defaultTextFormat.color==0xCCCCCC){
				tf.defaultTextFormat=txtFormat;
				if(tf.text=="введите значение"){
					tf.text="";
				}else{
					tf.text=tf.text;
				}
			}
		}
		
		private function mouseListener(e:MouseEvent){
			var tf:TextField = TextField(e.target);
			switch(e.type){
				case "mouseOver":
					Mouse.cursor=MouseCursor.BUTTON;
					for(var i:int=0;i<r.length;i++){
						if(tf.text==r[i].title+":"){
							r[i].mOver();
							break;
						}
					}
					break;
				case "mouseOut":
					Mouse.cursor=MouseCursor.AUTO;
					for(var i:int=0;i<r.length;i++){
						if(tf.text==r[i].title+":"){
							r[i].mOut();
							break;
						}
					}
					break;
			}
		}
	}
	
}
