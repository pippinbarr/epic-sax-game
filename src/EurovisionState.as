package
{
	
	import flash.events.*;
	import flash.ui.Keyboard;
	
	import org.flixel.*;
	
	public class EurovisionState extends FlxState
	{
		private const EUROVISION_INTRO_TEXT:String = "" +
			"THIS IS IT! EUROVISION 2010! " +
			"TIME TO WOW THE CROWD AND THE JUDGES WITH THE EPIC SAX REFRAIN! " +
			"BE SURE TO PLAY AT THE RIGHT TIMES IF YOU WANT TO IMPRESS! " +
			"(SEARCH YOUTUBE FOR 'EUROVISION MOLDOVA 2010' IF YOU WANT TO SEE HOW!) " +
			"\n\nPRESS [ENTER] TO STEP INTO HISTORY OR [ESCAPE] TO STEP OUT!";
		private const EUROVISION_INTRO_TEXT_HEIGHT:uint = 26;
		
		private const EUROVISION_RESULT_TEXT_HEIGHT:uint = 18;
		
		private const MAX_SPECIAL_EFFECTS_LOOPS:int = 2;
		
		private var _specialEffectsSprite:FlxSprite;
		private var _bgSprite:FlxSprite;
		private var _darknessMask:FlxSprite;
		private var _spotlightMask:FlxSprite;
		private var _saxSpotlightMask:FlxSprite;
		private var _saxGuySprite:FlxSprite;
		private var _violinGuySprite:FlxSprite;
		private var _vocalGalSprite:FlxSprite;
		private var _vocalGuySprite:FlxSprite;
		private var _dancerOneSprite:FlxSprite;
		private var _dancerTwoSprite:FlxSprite;
		
		private var _music:FullMusic;
		private var _input:PlayerInput;
		
		private var _violinTimingIndex:int = 0;
		private var _nextViolinTime:Number = Timings._violinStarts[_violinTimingIndex];
		
		private var _vocalGalTimingIndex:int = 0;
		private var _nextVocalGalTime:Number = Timings._vocalGalStarts[_vocalGalTimingIndex];
		
		private var _vocalGuyTimingIndex:int = 0;
		private var _nextVocalGuyTime:Number = Timings._vocalGuyStarts[_vocalGuyTimingIndex];
		
		private var _jumpTimingIndex:int = 0;
		private var _nextJumpTime:Number = Timings._jumpTimes[_jumpTimingIndex];
		
		private var _currentDanceSequence:Array = Timings._danceSequences[0];
		private var _currentDanceSequenceIndex:int = 0;
		
		private var _currentSpecialEffect:String = "horizontals";
		private var _currentEffectsSequenceCounter:int = MAX_SPECIAL_EFFECTS_LOOPS;
		
		private var _specialEffectsAnimations:Array = new Array(
			"horizontals", "reversehorizontals","verticals","reverseverticals","explosions","reverseexplosions");
		
		private var _specialEffectsColors:Array = new Array(
			0xDDCC0000, 0xDDCC00CC, 0xDD00CCCC, 0xDDCCCC00);
		
		private var _playing:Boolean = false;
		private var _complete:Boolean = false;
		
		private var _message:Message;
		private var _result:Message;
		
		// LENGTH = 24 (INDEXES 0 - 23)
		private var _results:Array = new Array(
			"GERMANY", "TURKEY", "ROMANIA", "DENMARK", "AZERBAIJAN", "BELGIUM", "ARMENIA", "GREECE",
			"GEORGIA", "UKRAINE", "RUSSIA", "FRANCE", "SERBIA", "ISRAEL", "SPAIN", "ALBANIA",
			"BOSNIA AND HERZEGOVINA", "PORTUGAL", "ICELAND", "NORWAY", "CYPRUS", "IRELAND", "BELARUS",
			"THE UNITED KINGDOM");
		
		public function EurovisionState()
		{
			super();
		}
		
		
		public override function create():void
		{
			super.create();
			
			_specialEffectsSprite = new FlxSprite(0,0);
			_specialEffectsSprite.loadGraphic(Assets.SPECIAL_EFFECTS,true,false,80,37);
			_specialEffectsSprite.addAnimation("horizontals",[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18],5,false);
			_specialEffectsSprite.addAnimation("reversehorizontals",[18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0],5,false);
			_specialEffectsSprite.addAnimation("verticals",[19,20,21,22,23,24,25,26,27,28,29,30,31,32,33],5,false);
			_specialEffectsSprite.addAnimation("reverseverticals",[33,32,31,30,29,28,27,26,25,24,23,22,21,20,19],5,false);
			_specialEffectsSprite.addAnimation("explosions",[34,35,36,37,38,39,40],4,false);
			_specialEffectsSprite.addAnimation("reverseexplosions",[40,39,38,37,36,35,34],4,false);

			_specialEffectsSprite.color = 0xDDCCCC00;
			add(_specialEffectsSprite);
			_specialEffectsSprite.visible = false;
			
			_bgSprite = new FlxSprite(0,0,Assets.EUROVISION_BG);
			add(_bgSprite);
			
			_saxGuySprite = new FlxSprite(14,2);
			_saxGuySprite.loadGraphic(Assets.EUROVISION_SAX_GUY,true,false,21,30);
			// 32 frames = 8 seconds
			_saxGuySprite.addAnimation("playing",[3,4,5,6,5,4,5,6,5,4,5,6,5,6,7,8,9,9,10,11,11,12,11,12,11,12,11,12,11,12,11,12],4,true);
			_saxGuySprite.addAnimation("idle",[2,2],10,false);
			_saxGuySprite.addAnimation("tapping",[0,1],3,true);
			_saxGuySprite.addAnimation("jumping",Timings._saxGuyJumpFrames,6,false);

			add(_saxGuySprite);
			
			_saxGuySprite.play("idle");
			
			_violinGuySprite = new FlxSprite(45,2);
			_violinGuySprite.loadGraphic(Assets.EUROVISION_VIOLIN_GUY,true,false,20,30);
			_violinGuySprite.addAnimation("idle",[0,0],2,true);
			_violinGuySprite.addAnimation("tapping",Timings._violinTappingFrames,3,true);
			_violinGuySprite.addAnimation("playing",[4,5,6,7],10,true);
			_violinGuySprite.addAnimation("spinning",[0,1,2,3],4,true);
			_violinGuySprite.addAnimation("jumping",[10,11,12,13,14],6,false);
			add(_violinGuySprite);
			
			_violinGuySprite.play("idle");
			
			_vocalGalSprite = new FlxSprite(33,15);
			_vocalGalSprite.loadGraphic(Assets.EUROVISION_VOCAL_GAL,true,false,21,30);
			_vocalGalSprite.addAnimation("idle",[0,0],2,true);
			_vocalGalSprite.addAnimation("tapping",[0,1,2,3],4,true);
			_vocalGalSprite.addAnimation("frontsinging",[5,4],4,true);
			_vocalGalSprite.addAnimation("sidesinging",[7,6],4,true);
			_vocalGalSprite.addAnimation("jumping",[8,9,10,11,12],6,false);
			add(_vocalGalSprite);
			
			_vocalGalSprite.play("idle");
			
			_vocalGuySprite = new FlxSprite(24,14);
			_vocalGuySprite.loadGraphic(Assets.EUROVISION_VOCAL_GUY,true,false,21,30);
			_vocalGuySprite.addAnimation("idle",[0,0],2,true);
			_vocalGuySprite.addAnimation("tapping",[1,2],4,true);
			_vocalGuySprite.addAnimation("frontsinging",[4,3],4,true);
			_vocalGuySprite.addAnimation("sidesinging",[6,5],4,true);
			_vocalGuySprite.addAnimation("jumping",[7,8,9,10,11],6,false);
			add(_vocalGuySprite);
			
			_vocalGuySprite.play("idle");
			
			_dancerOneSprite = new FlxSprite(0,14);
			_dancerOneSprite.loadGraphic(Assets.EUROVISION_DANCER_ONE,true,false,21,30);
			_dancerOneSprite.addAnimation("idle",[0,0],2,true);
			_dancerOneSprite.addAnimation("tapping",[6,7],4,true);
			_dancerOneSprite.addAnimation("spin",[8,9,10,11,12],4,true);
			_dancerOneSprite.addAnimation("hipwiggle",[13,14,15,16],4,true);
			_dancerOneSprite.addAnimation("leftlunge",[17,20,21,20,21,20,21,20,21,17],4,true);
			_dancerOneSprite.addAnimation("rightlunge",[17,18,19,18,19,18,19,18,19,17],4,true);
			_dancerOneSprite.addAnimation("jumping",[1,2,3,4,5],6,false);
			add(_dancerOneSprite);
			
			_dancerOneSprite.play("idle");
			
			_dancerTwoSprite = new FlxSprite(59,14);
			_dancerTwoSprite.loadGraphic(Assets.EUROVISION_DANCER_TWO,true,false,21,30);
			_dancerTwoSprite.addAnimation("idle",[0,0],2,true);
			_dancerTwoSprite.addAnimation("tapping",[6,7],4,true);
			_dancerTwoSprite.addAnimation("spin",[8,9,10,11,12],4,true);
			_dancerTwoSprite.addAnimation("hipwiggle",[13,14,15,16],4,true);
			_dancerTwoSprite.addAnimation("rightlunge",[17,20,21,20,21,20,21,20,21,17],4,true);
			_dancerTwoSprite.addAnimation("leftlunge",[17,18,19,18,19,18,19,18,19,17],4,true);
			_dancerTwoSprite.addAnimation("jumping",[1,2,3,4,5],6,false);
			add(_dancerTwoSprite);
			
			_dancerTwoSprite.play("idle");
			
			_saxSpotlightMask = new FlxSprite(0,0,Assets.SAX_SPOTLIGHT_MASK);
			_saxSpotlightMask.visible = false;
			add(_saxSpotlightMask);
			
			_spotlightMask = new FlxSprite(0,0,Assets.SPOTLIGHT_MASK);
			_spotlightMask.visible = true;
			add(_spotlightMask);
			
			_darknessMask = new FlxSprite(0,0,Assets.DARKNESS_MASK);
			add(_darknessMask);
			
			_input = new PlayerInput(0.8);
			_input.enable();
			_music = new FullMusic(_input, false, false, false, true);
			add(_input);
			add(_music);
						
			_message = new Message(2,EUROVISION_INTRO_TEXT_HEIGHT);
			_message.setText(EUROVISION_INTRO_TEXT);
			_message.show();
			
			_result = new Message(2, EUROVISION_RESULT_TEXT_HEIGHT);
			
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			
			_music.dispatcher.addEventListener(Event.COMPLETE,onSongFinished);
		}
		
		
		private function onSongFinished(e:Event):void
		{
			_complete = true;
			var rating:Number = _music.getRating();
			
			trace("Rating was " + rating);
			var index:uint = _results.length - Math.ceil(rating * _results.length);
			trace("index was " + index);
			trace("Length of _results is " + _results.length);
			if (index == 0)
			{
				_result.setText("" +
					"THE VOTES ARE IN AND YOU DID IT! YOU WON EUROVISION! " +
					"IT DOESN'T GET ANY MORE EPIC THAN THAT!\n\n" +
					"PRESS [ESCAPE] TO RETURN TO THE MENU.");
			}
			else if (index < _results.length)
			{
				_result.setText("" +
					"THE VOTES ARE IN AND YOU CAME IN AT #" + (index+1) + 
					", JUST AHEAD OF " + _results[index] + 
					" AND JUST BEHIND " + _results[index-1] + 
					"!\n\nPRESS [ESCAPE] TO RETURN TO THE MENU.");
			}
			else
			{
				_result.setText("" +
					"THE VOTES ARE IN AND YOU CAME DEAD LAST, BEHIND EVEN " + _results[index-1] + "! " +
					"THAT HAS TO HURT!" + 
					"\n\nPRESS [ESCAPE] TO RETURN TO THE MENU.");
			}
			
			_result.show();
			
			// Update save object
			SaveState.saveObject.completedEurovision = true;
			if (index < SaveState.saveObject.bestEurovisionResult)
			{
				SaveState.saveObject.bestEurovisionResult = index;
			}
		}
		
		public override function update():void
		{
			super.update();
				
			handleSpecialEffects();

			if (!_music.getFinished())
			{
				handleEpicSaxGuyAnimation();
				handleViolinAnimation();
				handleVocalGalAnimation();
				handleVocalGuyAnimation();
				handleDancersAnimation();
				handleJumpingAnimation();
			}
			else
			{
				this._saxGuySprite.frame = 1;
				this._dancerOneSprite.frame = 7;
				this._dancerTwoSprite.frame = 7;
				this._violinGuySprite.frame = 9;
				this._vocalGalSprite.frame = 13;
				this._vocalGuySprite.frame = 2;
			}
		}
		
		
		private function handleSpecialEffects():void
		{
			if (_specialEffectsSprite.finished && _currentEffectsSequenceCounter == 0)
			{
				trace("New special effects, includign tint....");
				_currentEffectsSequenceCounter = MAX_SPECIAL_EFFECTS_LOOPS;
				_specialEffectsSprite.color = getRandomSpecialEffectsColor();
				playRandomSpecialEffect();
			}
			else if (_specialEffectsSprite.finished)
			{
				_specialEffectsSprite.play(_currentSpecialEffect);
				_currentEffectsSequenceCounter--;
			}
		}
		
		private function handleEpicSaxGuyAnimation():void
		{
			if ((_music.getTime() > Timings._fullSaxLoopStarts[0] && _music.getTime() < Timings._fullSaxLoopStarts[1] + Timings._saxEnds[Timings._saxEnds.length-1]) ||
				(_music.getTime() > Timings._fullSaxLoopStarts[2] && _music.getTime() < Timings._fullSaxLoopStarts[3] + Timings._saxEnds[Timings._saxEnds.length-1]))
			{
				_saxSpotlightMask.visible = true;
			}
			else
			{
				_saxSpotlightMask.visible = false;
			}
			
			if (_input.getPlaying())
			{
				_saxGuySprite.play("playing");
			}
			else
			{
				if (Timings._saxGuyJumpFrames.indexOf(_saxGuySprite.frame) == -1)
				{
					_saxGuySprite.play("idle");
				}
				else if (_saxGuySprite.finished)
				{
					_saxGuySprite.play("idle");
				}
			}
		}
		
		
		private function handleViolinAnimation():void
		{
			if (_nextViolinTime > 0 && _music.getTime() + Timings.MAGIC_NUMBER > _nextViolinTime && _violinTimingIndex != -1)
			{
				_darknessMask.visible = false;
				
				_violinGuySprite.play(Timings._violinAnimations[_violinTimingIndex]);
				
				_nextViolinTime = Timings._violinEnds[_violinTimingIndex];
			}
			else if (_nextViolinTime < 0 && _music.getTime() + Timings.MAGIC_NUMBER > Math.abs(_nextViolinTime) && _violinTimingIndex != -1)
			{
				_violinGuySprite.play("tapping");
				
				if (_violinTimingIndex + 1 < Timings._violinStarts.length)
				{
					_violinTimingIndex++;
					_nextViolinTime = Timings._violinStarts[_violinTimingIndex];
				}
				else
				{
					_violinTimingIndex = -1;
				}
			}
			else
			{
				// End of song?
			}
		}
		
		
		private function handleVocalGalAnimation():void
		{
			if (_nextVocalGalTime > 0 && _music.getTime() + Timings.MAGIC_NUMBER > _nextVocalGalTime && _vocalGalTimingIndex != -1)
			{
				_vocalGalSprite.play(Timings._vocalGalAnimations[_vocalGalTimingIndex]);
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
			else if (_music.getTime() + Timings.MAGIC_NUMBER > Math.abs(Timings._vocalGalEnds[Timings._vocalGalEnds.length - 1]))
			{
				// End of song?
				_vocalGalSprite.play("tapping");
			}
		}
		
		
		private function handleVocalGuyAnimation():void
		{
			if (_nextVocalGuyTime > 0 && _music.getTime() + Timings.MAGIC_NUMBER > _nextVocalGuyTime && _vocalGuyTimingIndex != -1)
			{
				_vocalGuySprite.play(Timings._vocalGuyAnimations[_vocalGuyTimingIndex]);
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
			else if (_music.getTime() + Timings.MAGIC_NUMBER > Math.abs(Timings._vocalGuyEnds[Timings._vocalGuyEnds.length - 1]))
			{
				// End of song?
				_vocalGuySprite.play("tapping");
			}
		}
		
		
		private function handleDancersAnimation():void
		{
			if (_music.getTime() < Timings._dancersStart ||
				_music.getTime() > Timings._dancersEnd)
				return;
			
			if (_currentDanceSequenceIndex == _currentDanceSequence.length)
			{
				_currentDanceSequence = randomDanceSequence();
				_currentDanceSequenceIndex = 0;
			}
			
			var nextMove:String = _currentDanceSequence[_currentDanceSequenceIndex];
			
			if (_dancerOneSprite.finished && _dancerTwoSprite.finished)
			{
				_dancerOneSprite.play(nextMove,true);
				_dancerTwoSprite.play(nextMove,true);
				_currentDanceSequenceIndex++;
			}
		}
		
		
		private function handleJumpingAnimation():void
		{
			if (_music.getTime() + Timings.MAGIC_NUMBER > _nextJumpTime && _jumpTimingIndex != -1)
			{
				_spotlightMask.visible = false;
				
				_specialEffectsSprite.visible = true;
				playRandomSpecialEffect();
				
				FlxG.flash(0xFFFFFFFF,0.75);
				
				if (Timings._violinTappingFrames.indexOf(_violinGuySprite.frame) != -1)
					_violinGuySprite.play("jumping");
				if (!_input.getPlaying())
				{
					_saxGuySprite.play("jumping");
				}
				_dancerOneSprite.play("jumping");
				_dancerTwoSprite.play("jumping");
				
				_jumpTimingIndex++;
				if (_jumpTimingIndex == Timings._jumpTimes.length)
					_jumpTimingIndex = -1;
				else
					_nextJumpTime = Timings._jumpTimes[_jumpTimingIndex];
			}
		}
		
		
		private function playRandomSpecialEffect():void
		{
			var effectIndex:uint = Math.floor(Math.random() * _specialEffectsAnimations.length);
			_currentSpecialEffect = _specialEffectsAnimations[effectIndex];
			_specialEffectsSprite.play(_currentSpecialEffect);
		}
		
		
		private function getRandomSpecialEffectsColor():uint
		{
			var colorIndex:uint = Math.floor(Math.random() * _specialEffectsColors.length);
			return (_specialEffectsColors[colorIndex]);
		}
		
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE)
			{
				FlxG.switchState(new TitleState);
			}
			else if (e.keyCode == Keyboard.ENTER && !_playing && !_complete)
			{
				_message.hide();
				_playing = true;
				_music.start();
			}
			
//			if (e.keyCode == Keyboard.W)
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
		
		
		
		private function randomDanceSequence():Array
		{
			var index:int = Math.floor(Math.random() * Timings._danceSequences.length);	
			return Timings._danceSequences[index];
		}
		
		
		
		
		public override function destroy():void
		{
			super.destroy();
			
			_specialEffectsSprite.destroy();
			_bgSprite.destroy();
			_spotlightMask.destroy();
			_saxGuySprite.destroy();
			_violinGuySprite.destroy();
			_vocalGalSprite.destroy();
			_vocalGuySprite.destroy();
			_dancerOneSprite.destroy();
			_dancerTwoSprite.destroy();
			
			_music.destroy();
			_input.destroy();
			
			_message.destroy();
			_result.destroy();
			
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			
			FlxG.stage.focus = null;
		}
	}
}