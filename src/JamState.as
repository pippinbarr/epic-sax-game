package
{
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.flixel.*;
	
	public class JamState extends FlxState
	{		
		private const JAM_STATE_INTRO_TEXT:String = "" +
			"TIME TO JUST KICK BACK AND JAM WITH THE " +
			"BAND. NO RULES. " +
			"JUST SMOOTH, SMOOTH SAX.\n\n" +
			"PRESS [ENTER] TO START. " +
			"PRESS [ESCAPE] ANY TIME TO EXIT.";
		private const JAM_STATE_INTRO_TEXT_HEIGHT:uint = 18;
		
		private const JAM_STATE_END_TEXT:String = "" +
			"NICE JAM!\n\n" +
			"PRESS [ESCAPE] TO RETURN TO THE MENU.";
		private const JAM_STATE_RESULT_TEXT_HEIGHT:uint = 14;
		
		private var _bgSprite:FlxSprite;
		private var _guySprite:FlxSprite;
		private var _violinGuySprite:FlxSprite;
		private var _vocalGalSprite:FlxSprite;
		private var _vocalGuySprite:FlxSprite;
		
		private var _music:FullMusic;
		private var _input:PlayerInput;
		
		private var _violinTimingIndex:int = 0;
		private var _nextViolinTime:Number = Timings._violinStarts[_violinTimingIndex];
		
		private var _vocalGalTimingIndex:int = 0;
		private var _nextVocalGalTime:Number = Timings._vocalGalStarts[_vocalGalTimingIndex];
		
		private var _vocalGuyTimingIndex:int = 0;
		private var _nextVocalGuyTime:Number = Timings._vocalGuyStarts[_vocalGuyTimingIndex];
		
		private var _message:Message;
		private var _result:Message;
		
		private var _playing:Boolean = false;
		private var _complete:Boolean = false;
		
		public function JamState()
		{
			super();
		}
		
		
		public override function create():void
		{
			super.create();
			
			_bgSprite = new FlxSprite(0,0,Assets.JAM_BG);
			add(_bgSprite);
			
			_guySprite = new FlxSprite(37,30);
			_guySprite.loadGraphic(Assets.JAM_SAX_GUY,true,false,8,24);
			_guySprite.addAnimation("playing",[1,1],10,true);
			_guySprite.addAnimation("idle",[0,0],10,false);
			add(_guySprite);

			_guySprite.play("idle");
			
			_violinGuySprite = new FlxSprite(46,30);
			_violinGuySprite.loadGraphic(Assets.JAM_VIOLIN_GUY,true,false,16,23);
			_violinGuySprite.addAnimation("idle",[0,0],2,true);
			_violinGuySprite.addAnimation("tapping",[0,1],4,true);
			_violinGuySprite.addAnimation("playing",[2,3,4,5],10,true);
			add(_violinGuySprite);
			
			_violinGuySprite.play("idle");
			
			_vocalGalSprite = new FlxSprite(24,31);
			_vocalGalSprite.loadGraphic(Assets.JAM_VOCAL_GAL,true,false,11,23);
			_vocalGalSprite.addAnimation("idle",[0,0],2,true);
			_vocalGalSprite.addAnimation("tapping",[0,1],4,true);
			_vocalGalSprite.addAnimation("singing",[3,2],4,true);
			add(_vocalGalSprite);
			
			_vocalGalSprite.play("idle");
			
			_vocalGuySprite = new FlxSprite(11,30);
			_vocalGuySprite.loadGraphic(Assets.JAM_VOCAL_GUY,true,false,11,23);
			_vocalGuySprite.addAnimation("idle",[0,0],2,true);
			_vocalGuySprite.addAnimation("tapping",[0,1],4,true);
			_vocalGuySprite.addAnimation("singing",[3,2],4,true);
			add(_vocalGuySprite);
			
			_vocalGuySprite.play("idle");
			
			_input = new PlayerInput();
			_input.enable();
			_music = new FullMusic(_input, true, false, false, false);
			
			add(_input);
			add(_music);
			
			_message = new Message(42,JAM_STATE_INTRO_TEXT_HEIGHT);
			_message.setText(JAM_STATE_INTRO_TEXT);
			_message.show();
			
			_result = new Message(42,JAM_STATE_RESULT_TEXT_HEIGHT);
			_result.setText(JAM_STATE_END_TEXT);

			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			_music.dispatcher.addEventListener(Event.COMPLETE,onComplete);
		}
		
		
		private function onComplete(e:Event):void
		{
			_complete = true;
			_result.show();
			
			// Update save object
			SaveState.saveObject.completedJam = true;
			if (_input.getNotesPlayed() > SaveState.saveObject.mostNotesPlayedInJam)
			{
				SaveState.saveObject.mostNotesPlayedInJam = _input.getNotesPlayed();
			}
		}
		
		
		public override function update():void
		{
			super.update();
			
			handleEpicSaxGuyAnimation();
			handleViolinAnimation();
			handleVocalGalAnimation();
			handleVocalGuyAnimation();
		}
		
		
		private function handleEpicSaxGuyAnimation():void
		{
			if (_input.getPlaying())
			{
				_guySprite.play("playing");
			}
			else
			{
				_guySprite.play("idle");
			}
		}
		
		
		private function handleViolinAnimation():void
		{
			if (_nextViolinTime > 0 && _music.getTime() > _nextViolinTime && _violinTimingIndex != -1)
			{
				_violinGuySprite.play("playing");
				_nextViolinTime = Timings._violinEnds[_violinTimingIndex];
				if (_violinTimingIndex + 1 < Timings._violinStarts.length)
				{
					_violinTimingIndex++;
				}
				else
				{
					_violinTimingIndex = -1;
				}
			}
			else if (_nextViolinTime < 0 && _music.getTime() > Math.abs(_nextViolinTime) && _violinTimingIndex != -1)
			{
				trace("Negative next violin...");
				_violinGuySprite.play("tapping");
				_nextViolinTime = Timings._violinStarts[_violinTimingIndex];
			}
			else
			{
				// End of song?
			}
		}
		
		
		private function handleVocalGalAnimation():void
		{
			if (_nextVocalGalTime > 0 && _music.getTime()  + Timings.MAGIC_NUMBER > _nextVocalGalTime && _vocalGalTimingIndex != -1)
			{
				_vocalGalSprite.play("singing");
				_nextVocalGalTime = Timings._vocalGalEnds[_vocalGalTimingIndex];
				if (_vocalGalTimingIndex + 1 < Timings._vocalGalStarts.length)
				{
					_vocalGalTimingIndex++;
				}
				else
				{
					_vocalGalTimingIndex = -1;
				}
			}
			else if (_nextVocalGalTime < 0 && _music.getTime() + Timings.MAGIC_NUMBER > Math.abs(_nextVocalGalTime) && _vocalGalTimingIndex != -1)
			{
				_vocalGalSprite.play("tapping");
				_nextVocalGalTime = Timings._vocalGalStarts[_vocalGalTimingIndex];
			}
			else
			{
				// End of song?
			}
		}
		
		
		private function handleVocalGuyAnimation():void
		{
			if (_nextVocalGuyTime > 0 && _music.getTime() + Timings.MAGIC_NUMBER > _nextVocalGuyTime && _vocalGuyTimingIndex != -1)
			{
				_vocalGuySprite.play("singing");
				_nextVocalGuyTime = Timings._vocalGuyEnds[_vocalGuyTimingIndex];
				if (_vocalGuyTimingIndex + 1 < Timings._vocalGuyStarts.length)
				{
					_vocalGuyTimingIndex++;
				}
				else
				{
					_vocalGuyTimingIndex = -1;
				}
			}
			else if (_nextVocalGuyTime < 0 && _music.getTime() + Timings.MAGIC_NUMBER > Math.abs(_nextVocalGuyTime) && _vocalGuyTimingIndex != -1)
			{
				_vocalGuySprite.play("tapping");
				_nextVocalGuyTime = Timings._vocalGuyStarts[_vocalGuyTimingIndex];
			}
			else
			{
				// End of song?
			}
		}
		
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE)
			{
				FlxG.switchState(new TitleState);
			}
			else if (e.keyCode == Keyboard.ENTER && !_playing && !_complete)
			{
				_playing = true;

				_music.start();
				_message.hide();
			}
		}
		
		
		
		
		public override function destroy():void
		{
			super.destroy();
			
			_music.destroy();
			_input.destroy();
			
			_bgSprite.destroy();
			_guySprite.destroy();
			_violinGuySprite.destroy();
			_vocalGalSprite.destroy();
			_vocalGuySprite.destroy();
			
			_message.destroy();
			_result.destroy();
			
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			
			FlxG.stage.focus = null;
		}
	}
}