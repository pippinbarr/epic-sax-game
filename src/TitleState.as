package
{
	
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import org.flixel.*;
	
	public class TitleState extends FlxState
	{
		private var _practiceState:PracticeState;
		private var _studioState:StudioState;
		private var _jamState:JamState;
		private var _eurovisionState:EurovisionState;
		private var _youTubeState:YouTubeState;
		
		private var _titleText:TextField;
		private var _titleFormat:TextFormat = new TextFormat("Commodore",48,0xFFFFFF,null,null,null,null,null,"center");
		private var _practiceMenuText:TextField;
		private var _studioMenuText:TextField;
		private var _jamMenuText:TextField;
		private var _eurovisionMenuText:TextField;
		private var _youTubeMenuText:TextField;
		private var _menuFormat:TextFormat = new TextFormat("Commodore",24,0xFFFFFF,null,null,null,null,null,"center");
		
		private var _practiceStats:TextField;
		private var _studioStats:TextField;
		private var _jamStats:TextField;
		private var _eurovisionStats:TextField;
		private var _youTubeStats:TextField;
		private var _statsFormat:TextFormat = new TextFormat("Commodore",14,0xFFFFFF,null,null,null,null,null,"center");
		
		private var _saxGuyRight:FlxSprite;
		private var _saxGuyLeft:FlxSprite;
		
		public function TitleState()
		{
		}
		
		
		public override function create():void
		{
			super.create();
			
			FlxG.bgColor = 0xFF000000;
			
			SaveState.load();
			//SaveState.flush();
			
			_saxGuyRight = new FlxSprite(50,27);
			_saxGuyRight.loadGraphic(Assets.YOUTUBE_SAX_GUY,true,false,42,33);
			_saxGuyRight.addAnimation("playingleft",[1,2],4,true);
			_saxGuyRight.play("playingleft");
			add(_saxGuyRight);

			_saxGuyLeft = new FlxSprite(-12,27);
			_saxGuyLeft.loadGraphic(Assets.YOUTUBE_SAX_GUY,true,false,42,33);
			_saxGuyLeft.addAnimation("playingright",[4,5],4,true);
			_saxGuyLeft.play("playingright");
			add(_saxGuyLeft);
			
			_titleText = makeTextField(0,5,FlxG.width,FlxG.height,"EPIC SAX GAME",_titleFormat);
			FlxG.stage.addChild(_titleText);
						
			_practiceMenuText = makeTextField(0,15,FlxG.width,300,"",_menuFormat);
			_practiceMenuText.appendText("(P)RACTICE");
			FlxG.stage.addChild(_practiceMenuText);
			_studioMenuText = makeTextField(0,24,FlxG.width,300,"",_menuFormat);
			_studioMenuText.appendText("(S)TUDIO");
			FlxG.stage.addChild(_studioMenuText);
			_jamMenuText = makeTextField(0,33,FlxG.width,300,"",_menuFormat);
			_jamMenuText.appendText("(J)AM SESSION");
			FlxG.stage.addChild(_jamMenuText);
			_eurovisionMenuText = makeTextField(0,42,FlxG.width,300,"",_menuFormat);
			_eurovisionMenuText.appendText("(E)UROVISION");
			FlxG.stage.addChild(_eurovisionMenuText);
			_youTubeMenuText = makeTextField(0,51,FlxG.width,300,"",_menuFormat);
			_youTubeMenuText.appendText("(Y)OUTUBE");
			FlxG.stage.addChild(_youTubeMenuText);
			
			_practiceStats = makeTextField(0,19,FlxG.width,300,"",_statsFormat);
			_studioStats = makeTextField(0,28,FlxG.width,300,"",_statsFormat);
			_jamStats = makeTextField(0,37,FlxG.width,300,"",_statsFormat);
			_eurovisionStats = makeTextField(0,46,FlxG.width,300,"",_statsFormat);
			_youTubeStats = makeTextField(0,55,FlxG.width,300,"",_statsFormat);
			
			if (SaveState.saveObject.completedPractice)
			{
				_practiceStats.appendText("[COMPLETED! ");
				_practiceStats.appendText("BEST RESULT: " + SaveState.saveObject.bestPracticeResult + "%]");
			}
			else
			{
				_practiceStats.appendText("[NOT COMPLETED!]");
			}
			FlxG.stage.addChild(_practiceStats);
			
			if (SaveState.saveObject.completedStudio)
			{
				_studioStats.appendText("[COMPLETED! ");
				_studioStats.appendText("BEST RESULT: " + getLetterGrade(SaveState.saveObject.bestStudioResult) + "]");
			}
			else
			{
				_studioStats.appendText("[NOT COMPLETED!]");
			}
			FlxG.stage.addChild(_studioStats);
			
			if (SaveState.saveObject.completedJam)
			{
				_jamStats.appendText("[COMPLETED! ");
				_jamStats.appendText("MOST NOTES PLAYED: " + SaveState.saveObject.mostNotesPlayedInJam + "]");
			}
			else
			{
				_jamStats.appendText("[NOT COMPLETED!]");
			}
			FlxG.stage.addChild(_jamStats);
			
			if (SaveState.saveObject.completedEurovision)
			{
				_eurovisionStats.appendText("[COMPLETED! ");
				_eurovisionStats.appendText("BEST PLACING: #" + (SaveState.saveObject.bestEurovisionResult + 1) + "]");
			}
			else
			{
				_eurovisionStats.appendText("[NOT COMPLETED!]");
			}
			FlxG.stage.addChild(_eurovisionStats);
			
			if (SaveState.saveObject.completedYouTube)
			{
				_youTubeStats.appendText("[COMPLETED! ");
				_youTubeStats.appendText("MOST LIKES: " + SaveState.saveObject.mostYouTubeLikes + "]");
			}
			else
			{
				_youTubeStats.appendText("[NOT COMPLETED!]");
			}
			FlxG.stage.addChild(_youTubeStats);
			
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
		}
		
		
		public override function update():void
		{
			super.update();
		}
		
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.P:
					FlxG.switchState(new PracticeState);
					break;
				case Keyboard.S:
					FlxG.switchState(new StudioState);
					break;
				case Keyboard.J:
					FlxG.switchState(new JamState);
					break;
				case Keyboard.E:
					FlxG.switchState(new EurovisionState);
					break;
				case Keyboard.Y:
					FlxG.switchState(new YouTubeState);
					break;
			}
		}
		
		
		private function getLetterGrade(rating:uint):String
		{
			if (rating >= 90)
			{
				return "A+";
			}
			else if (rating >= 80)
			{
				return "A";
			}
			else if (rating >= 75)
			{
				return "A-";
			}
			else if (rating >= 70)
			{
				return "B+";
			}
			else if (rating >= 65)
			{
				return "B";
			}
			else if (rating >= 60)
			{
				return "B-";
			}
			else if (rating >= 55)
			{
				return "C+";
			}
			else if (rating >= 50)
			{
				return "C";
			}
			else if (rating >= 45)
			{
				return "C-";
			}
			else
			{
				return "D";
			}
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
			super.destroy();
			
			_saxGuyLeft.destroy();
			_saxGuyRight.destroy();
			
			FlxG.stage.removeChild(_titleText);
			
			FlxG.stage.removeChild(_practiceMenuText);
			FlxG.stage.removeChild(_studioMenuText);
			FlxG.stage.removeChild(_jamMenuText);
			FlxG.stage.removeChild(_eurovisionMenuText);
			FlxG.stage.removeChild(_youTubeMenuText);
			
			FlxG.stage.removeChild(_practiceStats);
			FlxG.stage.removeChild(_studioStats);
			FlxG.stage.removeChild(_jamStats);
			FlxG.stage.removeChild(_eurovisionStats);
			FlxG.stage.removeChild(_youTubeStats);

			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			
			FlxG.stage.focus = null;
		}
	}
}