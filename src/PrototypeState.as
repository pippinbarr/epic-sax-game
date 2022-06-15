package 
{
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.KeyboardEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.ui.Keyboard;
	
	import org.flixel.*;
	
	public class PrototypeState extends FlxState 
	{
		
		[Embed(source="assets/sounds/A#.mp3")]
		private const A_SHARP:Class;
		
		[Embed(source="assets/sounds/C#.mp3")]
		private const C_SHARP:Class;
		
		[Embed(source="assets/sounds/D#.mp3")]
		private const D_SHARP:Class;
		
		[Embed(source="assets/sounds/F.mp3")]
		private const F_NORMAL:Class;
		
		[Embed(source="assets/sounds/F#.mp3")]
		private const F_SHARP:Class;
		
		[Embed(source="assets/sounds/G#.mp3")]
		private const G_SHARP:Class;
		
		
		[Embed(source="assets/sounds/EpicSaxNoSaxGapless.mp3")]
		private const EPIC_SAX_LOOP_NO_SAX:Class;
		
		private const PLAY_NOTES:Boolean = true;
		
		private var _aSharp:FlxSound;
		private var _cSharp:FlxSound;
		private var _dSharp:FlxSound;
		private var _dSharp2:FlxSound;
		private var _fNormal:FlxSound;
		private var _fSharp:FlxSound;
		private var _gSharp:FlxSound;
		
		private var _epicSaxLoop:FlxLoopSound;
		private var _epicSaxSound:Sound;
		private var _epicSaxChannel:SoundChannel;
		
		private var _currentNoteIndex:int = 0;
		private var _nextNoteIndex:int = 1;
		private var _previousNoteIndex:int = -1;
		private var _currentNote:FlxSound;
		private var _currentInputNote:FlxSound;
		
		private const FUZZY_ALLOWANCE:Number = 0.05;
		private var _allFrames:uint = 0;
		private var _accurateFrames:uint = 0;
		
		private var _notes:Array = new Array(
			"A#", 
			"A#", "A#", "A#", "G#", "A#", "A#",
			"A#", "A#", "A#", "G#", "A#", "A#",
			"C#", "A#", "G#", "F#",
			"D#", "D#", "F", "F#", "D#"
		);
		
		private var _notesAsNumbers:Array = new Array(
			1, 
			1, 1, 1, 2, 1, 1,
			1, 1, 1, 2, 1, 1,
			0, 1, 2, 3,
			5, 5, 4, 3, 5
		);
		
		private var _noteStarts:Array = new Array(
			0.011895, 
			0.935201, 1.162912, 1.279600, 1.394872, 1.511276, 1.858224, 
			2.780963, 3.010373, 3.125362, 3.241483, 3.359304, 3.703986, 
			4.394483, 4.853303, 5.312407, 5.773210, 
			6.240528, 6.470788, 6.697366, 6.928759, 7.164966
		);
		private var _noteEnds:Array = new Array(
			0.288887, 
			1.098337, 1.256942, 1.386092, 1.501080, 1.789401, 2.078571, 
			2.942683, 3.103554, 3.231570, 3.347125, 3.554335, 3.924899, 
			4.842824, 5.016723, 5.765847, 5.923035, 
			6.400265, 6.687736, 6.919979, 7.149389, 7.323288
		);
		
		private var _notesPressed:Array = new Array(
			0,0,0,0,0,0
		);
		
		private var _noteTimer:Number = 0.0;
		
		private var _justLooped:Boolean = false;
		private var _notePlaying:Boolean = false;
		
		private var _timer:FlxTimer;
		
		//private const CLIP_LENGTH:Number = 7.38;//7.471020408163265;
		private const CLIP_LENGTH:Number = 7.39;
		
		private var _template:Sprite;
		private var _input:Sprite;
		private var _timeLine:Sprite;
		
		
		public function PrototypeState() 
		{
			super();
		}
		
		public override function create():void 
		{				
			
			super.create();

			FlxG.volume = 0.5;
			FlxG.mute = false;
			
			_aSharp = new FlxSound();
			_aSharp.loadEmbedded(this.A_SHARP);
			
			_cSharp = new FlxSound();
			_cSharp.loadEmbedded(this.C_SHARP);
			
			_dSharp = new FlxSound();
			_dSharp.loadEmbedded(this.D_SHARP);
			
			_fNormal = new FlxSound();
			_fNormal.loadEmbedded(this.F_NORMAL);
			
			_fSharp = new FlxSound();
			_fSharp.loadEmbedded(this.F_SHARP);
			
			_gSharp = new FlxSound();
			_gSharp.loadEmbedded(this.G_SHARP);			
			
			drawTemplateNotes();
			
			_timeLine = new Sprite();
			_timeLine.x = 0; _timeLine.y = 0;
			_timeLine.graphics.lineStyle(1,0xFFFFFF);
			_timeLine.graphics.lineTo(0,FlxG.height);
			
			FlxG.stage.addChild(_timeLine);
			
			_input = new Sprite();
			_input.x = 0; _input.y = 60;
			
			FlxG.stage.addChild(_input);
			
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			
			_epicSaxLoop = new FlxLoopSound();
			_epicSaxLoop.loadEmbedded(this.EPIC_SAX_LOOP_NO_SAX,true,325800);
			_epicSaxLoop.play();
			_epicSaxLoop._dispatcher.addEventListener(Event.SOUND_COMPLETE,onComplete);

			
//			_epicSaxSound = new EPIC_SAX_LOOP_NO_SAX();
//			_epicSaxChannel = _epicSaxSound.play(0.3);
//			_epicSaxChannel.addEventListener(Event.SOUND_COMPLETE,onComplete);
			
			//_timer = new FlxTimer();
			//_timer.start(CLIP_LENGTH,1,onFinish);
		}
		
		
		private function onComplete(e:Event):void
		{
			//_epicSaxChannel = _epicSaxSound.play(0.3);
			//_epicSaxChannel.addEventListener(Event.SOUND_COMPLETE,onComplete);
			trace("Loop.");
			onFinish(null);
		}
		
		
		private function drawTemplateNotes():void
		{
			// SET UP THE SPRITE FOR DRAWING THE CORRECT INPUT
			
			trace("width=" + FlxG.width + ", height=" + FlxG.height);
			
			_template = new Sprite();
			_template.x = 0; _template.y = 0;
			//_template.width = 800; _template.height = 600;
			var _currentX:Number = 0;
			var _currentY:Number = 0;
			var _currentWidth:Number = 0;
			
			for (var i:uint = 0; i < _notes.length; i++) {
				_currentX = (_noteStarts[i] / CLIP_LENGTH) * FlxG.width;
				_currentY = (_notesAsNumbers[i] * 10);
				_currentWidth = ((_noteEnds[i] - _noteStarts[i])/CLIP_LENGTH) * FlxG.width;
				trace(_currentX + "," + _currentY + "," + _currentWidth);
				_template.graphics.beginFill(0xFFFFFF);
				_template.graphics.drawRect(_currentX,_currentY,_currentWidth,10);
				_template.graphics.endFill();				
			}
			
			FlxG.stage.addChild(_template);
		}
		
		
		private function onFinish(t:FlxTimer):void 
		{
			// Score the round
			trace("ACCURACY: " + _accurateFrames + "/" + _allFrames);
			trace("PERCENTAGE: " + (_accurateFrames/_allFrames)*100);
			
			// Reset values
			_accurateFrames = 0;
			_allFrames = 0;
			
			_noteTimer = 0.0;
			_currentNoteIndex = 0;
			_nextNoteIndex = 1;
			_previousNoteIndex = -1;
			
			for (var i:uint = 0; i < _notesPressed.length; i++) 
			{
				_notesPressed[i] = 0;
			}
			
			//_epicSaxLoop.play(true);
			
			//5_timer.start(CLIP_LENGTH,1,onFinish);

		}
		
		
		public override function update():void 
		{
			super.update();
									
			_noteTimer += FlxG.elapsed;
			_timeLine.x = (_noteTimer / CLIP_LENGTH) * FlxG.width;
			
			updateNotesAndMusic();
			
			officialNotes();	
			
			drawNotes();
			
			checkAccuracy();
			

			
			//trace("Playing notes: " + _notesPressed[0] + "," + _notesPressed[1] + "," + _notesPressed[2] + "," + _notesPressed[3] + "," + _notesPressed[4] + "," + _notesPressed[5]);
		}
		
		
		private function updateNotesAndMusic():void
		{
			_aSharp.update();			
			_cSharp.update();
			_dSharp.update();
			_fNormal.update();
			_fSharp.update();
			_gSharp.update();
			
			_epicSaxLoop.update();
		}
		
		
		private function officialNotes():void
		{
			if (_currentNoteIndex != -1 && _noteTimer >= _noteEnds[_currentNoteIndex])
			{
				_previousNoteIndex = _currentNoteIndex;
				if (_noteTimer >= _noteStarts[_nextNoteIndex])
				{
					_currentNoteIndex = _nextNoteIndex;
					_nextNoteIndex++;
					//trace("New current note: " + _currentNoteIndex);
				}
				else
				{
					_currentNoteIndex = -1;
				}
			}
			else if (_currentNoteIndex == -1 && _noteTimer >= _noteStarts[_nextNoteIndex])
			{
				_previousNoteIndex = _currentNoteIndex;
				_currentNoteIndex = _nextNoteIndex;
				_nextNoteIndex++;
				//trace("New current note: " + _currentNoteIndex);
			}
			
			if (_currentNoteIndex == -1)
			{
				return;
			}
			
			if (_noteTimer >= _noteStarts[_currentNoteIndex] && 
				_noteTimer <= _noteEnds[_currentNoteIndex]) 
			{
				if (_notes[_currentNoteIndex] == "A#") 
				{
					_currentNote = _aSharp;
				}
				else if (_notes[_currentNoteIndex] == "C#") 
				{
					_currentNote = _cSharp;
				}
				else if (_notes[_currentNoteIndex] == "D#") 
				{
					_currentNote = _dSharp;			
				}
				else if (_notes[_currentNoteIndex] == "F") 
				{
					_currentNote = _fNormal;
				}
				else if (_notes[_currentNoteIndex] == "F#") 
				{
					_currentNote = _fSharp;
				}
				else if (_notes[_currentNoteIndex] == "G#") 
				{
					_currentNote = _gSharp;
				}
				
				if (PLAY_NOTES)
					_currentNote.play(true);
				
			}
			else if (PLAY_NOTES)
				_currentNote.stop();
		}
		
		
		private function drawNotes():void
		{
			for (var i:uint = 0; i < _notesPressed.length; i++) 
			{
				if (_notesPressed[i] > 0) 
				{
					_input.graphics.beginFill(0xFFFF0000);
					_input.graphics.drawRect(_notesPressed[i]/CLIP_LENGTH * FlxG.width, i*10, ((_noteTimer - _notesPressed[i])/CLIP_LENGTH) * FlxG.width, 10);
					_input.graphics.endFill();
				}
			}
		}
		
		
		private function checkAccuracy():void
		{
			var accurateFrame:Boolean = true;
						
			// Check each of the notes that the player may be playing
			
			for (var i:int = 0; i < _notesPressed.length; i++)
			{
				// If the current note has never been played but should be
				if (_notesPressed[i] == 0 &&
					_currentNoteIndex != -1 &&
					_notesAsNumbers[_currentNoteIndex] == i)
				{
					accurateFrame = false;
					break;
				}
				
				// If the current note isn't being played but should be
				// [[ And it wasn't just released within the fuzzy allowance ]]
				if (_notesPressed[i] < 0 &&
					_currentNoteIndex != -1 &&
					_notesAsNumbers[_currentNoteIndex] == i &&
					_noteTimer - FUZZY_ALLOWANCE > Math.abs(_notesPressed[i]))
				{
					accurateFrame = false;
					break;
				}
				
				// If the current note it being played but no note should be playing
				// [[ And it's not the case that the previous note was this one and ended within the allowance
				// [[ And it's not the case that the next note is this one and starts withint he allowance
				if (_notesPressed[i] > 0 &&
					_currentNoteIndex == -1)
				{
					var check:Boolean = false;
					var previous:int = _previousNoteIndex;
					while(previous >= 0 && _noteEnds[previous] > _noteTimer - FUZZY_ALLOWANCE)
					{
						if (_notesAsNumbers[previous] == i)
						{
							check = true;
							break;
						}
						previous--;
					}
					
					var next:int = _nextNoteIndex;
					while(next < _noteStarts.length && _noteStarts[next] < _noteTimer + FUZZY_ALLOWANCE)
					{
						if (_notesAsNumbers[next] == i)
						{
							check = true;
							break;
						}
						next++;
					}
					
					if (!check)
					{
						accurateFrame = false;
					}
				}
				
				// If the current note is playing and there should be a note playing, but not this one
				// [[ And it's not the case that the previous note was this one and ended within the allowance
				// [[ And it's not the case that the next note is this one and starts within the allowance
				if (_notesPressed[i] > 0 &&
					_currentNoteIndex != -1 &&
					_notesAsNumbers[_currentNoteIndex] != i)
				{
					check = false;
					previous = _previousNoteIndex;
					while(previous >= 0 && _noteEnds[previous] > _noteTimer - FUZZY_ALLOWANCE)
					{
						if (_notesAsNumbers[previous] == i)
						{
							check = true;
							break;
						}
						previous--;
					}
					
					next = _nextNoteIndex;
					while(next < _noteStarts.length && _noteStarts[next] < _noteTimer + FUZZY_ALLOWANCE)
					{
						if (_notesAsNumbers[next] == i)
						{
							check = true;
							break;
						}
						next++;
					}
					
					if (!check)
					{
						accurateFrame = false;
					}
				}
			}
			
			if (accurateFrame)
			{
				_accurateFrames++;
			}
			
			_allFrames++;
		}
		
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			
			var noteNumber:uint;
			
			if (e.keyCode == Keyboard.NUMBER_5 && _notesPressed[1] <= 0) 
			{
				this._aSharp.play(true);
				noteNumber = 1;
				_notesPressed[noteNumber] = _noteTimer;
			}
			else if (e.keyCode == Keyboard.NUMBER_6 && _notesPressed[0] <= 0) 
			{
				this._cSharp.play(true);
				noteNumber = 0;
				_notesPressed[noteNumber] = _noteTimer;
				
			}
			else if (e.keyCode == Keyboard.NUMBER_1 && _notesPressed[5] <= 0) 
			{
				this._dSharp.play(true);
				noteNumber = 5;
				_notesPressed[noteNumber] = _noteTimer;
				
			}
			else if (e.keyCode == Keyboard.NUMBER_2 && _notesPressed[4] <= 0) 
			{
				this._fNormal.play(true);
				noteNumber = 4;
				_notesPressed[noteNumber] = _noteTimer;
				
			}
			else if (e.keyCode == Keyboard.NUMBER_3  && _notesPressed[3] <= 0) 
			{
				this._fSharp.play(true);
				noteNumber = 3;
				_notesPressed[noteNumber] = _noteTimer;
				
			}
			else if (e.keyCode == Keyboard.NUMBER_4 && _notesPressed[2] <= 0) 
			{
				this._gSharp.play(true);
				noteNumber = 2;
				_notesPressed[noteNumber] = _noteTimer;
				
			}
			
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.NUMBER_5) 
			{
				this._aSharp.stop();
				_notesPressed[1] = -_noteTimer;
			}
			else if (e.keyCode == Keyboard.NUMBER_6) 
			{
				this._cSharp.stop();
				_notesPressed[0] = -_noteTimer;
			}
			else if (e.keyCode == Keyboard.NUMBER_1) 
			{
				this._dSharp.stop();
				_notesPressed[5] = -_noteTimer;
			}
			else if (e.keyCode == Keyboard.NUMBER_2) 
			{
				this._fNormal.stop();
				_notesPressed[4] = -_noteTimer;
			}
			else if (e.keyCode == Keyboard.NUMBER_3) 
			{
				this._fSharp.stop();
				_notesPressed[3] = -_noteTimer;
			}
			else if (e.keyCode == Keyboard.NUMBER_4) 
			{
				this._gSharp.stop();
				_notesPressed[2] = -_noteTimer;
			}
		}
		
		public override function destroy():void 
		{	
			_aSharp.destroy();
			super.destroy();	
		}
		
	}
}