package
{
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.flixel.*;
	
	public class StudioState extends FlxState
	{		
		private const STUDIO_INTRO_TEXT:String = "" +
			"\"IT'S TIME TO LAY DOWN A RECORDING OF YOUR SAXOPHONE PART.\n\n" +
			"WHEN YOU'RE READY TO RECORD, PRESS [ENTER] AND I'LL COUNT YOU IN. " +
			"PRESS [ESCAPE] ANY TIME TO GO BACK TO THE MENU.\"";
		private const STUDIO_INTRO_TEXT_HEIGHT:uint = 20;
		
		private const STUDIO_RESULT_TEXT_HEIGHT:uint = 14;
		
		private const ENGINEER_NOD_TOLERANCE:Number = 0.5;
		private var _timeSinceLastPlaying:Number = 100;
		
		private var _bgSprite:FlxSprite;
		private var _guySprite:FlxSprite;
		private var _engineerSprite:FlxSprite;
		
		private var _music:LoopMusic;
		private var _input:PlayerInput;
		
		private var _message:Message;
		private var _result:Message;
		
		private var _playing:Boolean = false;
		
		public function StudioState()
		{
			super();
		}
		
		
		public override function create():void
		{
			super.create();
			
			_bgSprite = new FlxSprite(0,0,Assets.STUDIO_BG);
			add(_bgSprite);
			
			_guySprite = new FlxSprite(33,36);
			_guySprite.loadGraphic(Assets.STUDIO_SAX_GUY,true,false,8,24);
			_guySprite.addAnimation("playing",[1,1],2,true);
			_guySprite.addAnimation("idle",[0,0],10,false);
			add(_guySprite);
			
			_guySprite.play("idle");
			
			_engineerSprite = new FlxSprite(29,19);
			_engineerSprite.loadGraphic(Assets.STUDIO_ENGINEER_GUY,true,false,30,10);
			_engineerSprite.addAnimation("idle",[0,0],2,false);
			_engineerSprite.addAnimation("nodding",[0,1],2,true);
			add(_engineerSprite);
			
			_engineerSprite.play("idle");
			
			_input = new PlayerInput();
			_input.enable();
			_music = new LoopMusic(_input, true, false, false, false);
			add(_input);
			add(_music);
			
			
			// Set up a message
			_message = new Message(42,STUDIO_INTRO_TEXT_HEIGHT);
			_message.setText(STUDIO_INTRO_TEXT);
			_message.show();
			
			_result = new Message(42,STUDIO_RESULT_TEXT_HEIGHT);
			
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
		}
		
		
		public override function update():void
		{
			super.update();
			
			if (_input.getPlaying())
			{
				_guySprite.play("playing");
				_timeSinceLastPlaying = 0;
			}
			else
			{
				_guySprite.play("idle");
				_timeSinceLastPlaying += FlxG.elapsed;
			}
			
			if ((_input.getPlaying() || _timeSinceLastPlaying < ENGINEER_NOD_TOLERANCE))
			{
				_engineerSprite.play("nodding");
			}
			else if (_engineerSprite.finished)
			{
				_engineerSprite.play("idle");
			}
		}
		
		
		private function onLoopComplete(e:Event):void
		{
			trace("Loop completed...");
			var rating:uint = Math.floor(_music.getLastRating() * 100);
			
			// Update the save object
			SaveState.saveObject.completedStudio = true;
			if (rating > SaveState.saveObject.bestStudioResult)
			{
				SaveState.saveObject.bestStudioResult = rating;
			}
			
			if (rating >= 90)
			{
				_result.setText("THAT'S AN 'A+'! PRESS [ENTER] TO RE-RECORD YOUR TRACK, OR HIT [ESCAPE] TO GO TO THE MAIN MENU.");
			}
			else if (rating >= 80)
			{
				_result.setText("THAT'S AN 'A'-LEVEL RECORDING! PRESS [ENTER] TO RE-RECORD YOUR TRACK, OR HIT [ESCAPE] TO GO TO THE MAIN MENU.");
			}
			else if (rating >= 75)
			{
				_result.setText("I'D GIVE THAT AN 'A-'! PRESS [ENTER] TO RE-RECORD YOUR TRACK, OR HIT [ESCAPE] TO GO TO THE MAIN MENU.");
			}
			else if (rating >= 70)
			{
				_result.setText("NOT BAD... ABOUT A 'B+'... PRESS [ENTER] TO RE-RECORD YOUR TRACK, OR HIT [ESCAPE] TO GO TO THE MAIN MENU.");
			}
			else if (rating >= 65)
			{
				_result.setText("I'D GIVE THAT A 'B'. PRESS [ENTER] TO RE-RECORD YOUR TRACK, OR HIT [ESCAPE] TO GO TO THE MAIN MENU.");
			}
			else if (rating >= 60)
			{
				_result.setText("THAT'S A 'B-'. PRESS [ENTER] TO RE-RECORD YOUR TRACK, OR HIT [ESCAPE] TO GO TO THE MAIN MENU.");
			}
			else if (rating >= 55)
			{
				_result.setText("I'D GIVE THAT A 'C+'. PRESS [ENTER] TO RE-RECORD YOUR TRACK, OR HIT [ESCAPE] TO GO TO THE MAIN MENU.");
			}
			else if (rating >= 50)
			{
				_result.setText("THAT'S ABOUT A 'C'. PRESS [ENTER] TO RE-RECORD YOUR TRACK, OR HIT [ESCAPE] TO GO TO THE MAIN MENU.");
			}
			else if (rating >= 45)
			{
				_result.setText("HMMM... 'C-' FOR THAT EFFORT. PRESS [ENTER] TO RE-RECORD YOUR TRACK, OR HIT [ESCAPE] TO GO TO THE MAIN MENU.");
			}
			else
			{
				_result.setText("NEEDS WORK, JUST A 'D' FOR ME. PRESS [ENTER] TO RE-RECORD YOUR TRACK, OR HIT [ESCAPE] TO GO TO THE MAIN MENU.");
			}

			
			_result.show();
			_engineerSprite.play("idle",true);
			_playing = false;
		}
		
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE)
			{
				FlxG.switchState(new TitleState);
			}
			if (e.keyCode == Keyboard.ENTER && !_playing)
			{
				_playing = true;
				
				_message.hide();
				_result.hide();
				
				_music.start();
				_music.dispatcher.addEventListener(Event.COMPLETE,onLoopComplete);
			}
//			else if (e.keyCode == Keyboard.W)
//			{
//				if (_music.getPlayNotesEnabled())
//				{
//					_music.disableNotes();
//				}
//				else
//				{
//					_music.enableNotes();
//				}
//			}
		}
		
		
		public override function destroy():void
		{
			super.destroy();
			
			_music.destroy();
			_input.destroy();
			
			_bgSprite.destroy();
			_guySprite.destroy();
			_engineerSprite.destroy();
			
			_message.destroy();
			_result.destroy();
			
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			
			FlxG.stage.focus = null;
		}
	}
}