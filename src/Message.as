package
{
	
	import flash.text.*;
	
	import org.flixel.*;
	
	
	public class Message extends FlxGroup
	{
		private var _bg:FlxSprite;
		private var _text:TextField;
		private var _textFormat:TextFormat = new TextFormat("Commodore",16,0xFFFFFF,null,null,null,null,null,"left");
		
		public function Message(Y:Number, H:Number)
		{
			super();
			_text = makeTextField(4,Y+2,FlxG.width - 8,H,"",_textFormat);
			_bg = new FlxSprite(2,Y);
			_bg.makeGraphic(FlxG.width-4,H-4,0xAA333333);
			
			FlxG.stage.addChild(_text);
			_text.visible = false;
			FlxG.state.add(_bg);
			_bg.visible = false;
		}
		
		
		public override function update():void
		{
			super.update();
		}
		
		public function setText(text:String):void
		{
			_text.text = text;
		}
		
		public function show():void
		{
			_text.visible = true;
			_bg.visible = true;
		}
		
		public function hide():void
		{
			_text.visible = false;
			_bg.visible = false;
		}
		
		
		public static function makeTextField(x:uint, y:uint, w:uint, h:uint, s:String, tf:TextFormat):TextField {
			
			var textField:TextField = new TextField();
			textField.x = x * Globals.ZOOM;
			textField.y = y * Globals.ZOOM;
			textField.width = w * Globals.ZOOM;
			textField.height = h * Globals.ZOOM;
			textField.defaultTextFormat = tf;
			textField.text = s;
			textField.wordWrap = true;
			textField.embedFonts = true;
			textField.selectable = false;
			
			return textField;
		}
		
		public override function destroy():void
		{			
			if (FlxG.stage.contains(_text)) FlxG.stage.removeChild(_text);
			_bg.destroy();
			
			FlxG.stage.focus = null;
		}
	}
}