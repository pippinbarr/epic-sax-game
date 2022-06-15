package
{
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.flixel.*;
	
	public class PracticeState extends FlxState
	{
		
		private const PRACTICE_INTRO_TEXT:String = "" +
			"TIME TO LEARN THE EPIC SAX REFRAIN!\n\n" +
			"PLAY YOUR SAX WITH THE [1-6] OR [S,D,F,J,K,L] KEYS AND TRY TO MATCH THE REFRAIN SHOWN AT THE BOTTOM.\n\n" +
			"YOU CAN TOGGLE COMPUTER-PLAYED NOTES WITH [E] " +
			"AND TOGGLE HALF-SPEED PLAYING WITH [H].\n\n" +
			"PRESS [ENTER] TO START PRACTISING! " +
			"HIT [ESCAPE] ANY TIME TO RETURN TO THE MENU. ";
		private const PRACTICE_INTRO_TEXT_HEIGHT:uint = 30;
		
		private const PRACTICE_HELP_TEXT:String = "" +
			"[1-6] OR [S,D,F,J,K,L] = PLAY SAX\n" +
			"[E] = TOGGLE COMPUTER-PLAYED NOTES\n" +
			"[H] = TOGGLE HALF-SPEED\n" +
			"[ESCAPE] = MAIN MENU";
		private const PRACTICE_HELP_TEXT_HEIGHT:uint = 16;
				
		private var _bgSprite:FlxSprite;
		private var _guySprite:FlxSprite;
		
		private var _music:LoopMusic;
		private var _input:PlayerInput;
		
		private var _message:Message;
		private var _instructions:Message;
		
		private var _playing:Boolean = false;
		
		public function PracticeState()
		{
			super();
		}
		
		
		public override function create():void
		{
			super.create();
			
			_bgSprite = new FlxSprite(0,0,Assets.PRACTICE_BG);
			add(_bgSprite);
			
			_guySprite = new FlxSprite(35,19);
			_guySprite.loadGraphic(Assets.PRACTICE_SAX_GUY,true,false,7,20);
			_guySprite.addAnimation("playing",[1,2,3,4],2,true);
			_guySprite.addAnimation("idle",[0,0],10,false);
			add(_guySprite);
			
			_guySprite.play("idle");
			
			_input = new PlayerInput();
			_input.enable();
			_music = new LoopMusic(_input, false, true, true, true);
			add(_input);
			add(_music);
			
			_message = new Message(2,PRACTICE_INTRO_TEXT_HEIGHT);
			_message.setText(PRACTICE_INTRO_TEXT);
			_message.show();
			
			_instructions = new Message(2,PRACTICE_HELP_TEXT_HEIGHT);
			_instructions.setText(PRACTICE_HELP_TEXT);
			
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			_music.dispatcher.addEventListener(Event.COMPLETE,onLoop);
		}
		
		
		private function onLoop(e:Event):void
		{
			SaveState.saveObject.completedPractice = true;
			var rating:uint = Math.floor(_music.getLastRating() * 100);
			trace("RATING WAS " + rating);
			trace("BEST PRACTICE RATING WAS " + SaveState.saveObject.bestPracticeResult);
			if (rating > SaveState.saveObject.bestPracticeResult)
			{
				trace("SAVED PRACTICE RESULT");
				SaveState.saveObject.bestPracticeResult = rating;
			}
		}
		
		public override function update():void
		{
			super.update();
			
			FlxG.bgColor = 0xFF000000;
			
			if (_input.getPlaying())
			{
				_guySprite.play("playing");
			}
			else
			{
				_guySprite.play("idle");
			}
		}
		
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE)
			{
				FlxG.switchState(new TitleState);
			}
			else if (e.keyCode == Keyboard.ENTER && !_playing)
			{
				_playing = true;
				_message.hide();
				_instructions.show();
				_music.start();
			}
			else if (e.keyCode == Keyboard.E && _playing)
			{
				if (_music.getPlayNotesEnabled())
				{
					_music.disableNotes();
				}
				else
				{
					_music.enableNotes();
				}
			}
			else if (e.keyCode == Keyboard.H && _playing)
			{
				_music.toggleSpeed();
			}
		}
		
		
		public override function destroy():void
		{
			super.destroy();
			
			_message.destroy();
			
			_instructions.hide();
			_instructions.destroy();
			
			_guySprite.destroy();
			_bgSprite.destroy();
			
			_music.destroy();
			_input.destroy();
			
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			
			FlxG.stage.focus = null;
		}
	}
}