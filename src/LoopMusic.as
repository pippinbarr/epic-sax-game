package
{
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.*;
	
	import org.flixel.*;
	
	public class LoopMusic extends FlxBasic
	{
		
		private const CLIP_LENGTH_LOOP:Number = 7.35;
		private const CLIP_LENGTH_NOLOOP:Number = 8.2;
		private const HALF_COUNT:Number = 0.45;
		private const FULL_COUNT:Number = 0.9;
		
		private const FUZZY_ALLOWANCE:Number = 0.1;
		
		private const NOTE_SCALE:Number = FlxG.height * Globals.ZOOM - 20;
		
		private var _epicSaxLoop:FlxSound;
		private var _click:FlxSound;
		
		private var _notes:Array;
		
		private var _notesAsNumbers:Array = new Array(
			4, 
			4, 4, 4, 3, 4, 4,
			4, 4, 4, 3, 4, 4,
			5, 4, 3, 2,
			0, 0, 1, 2, 0
		);

		private var _noteInputsAsNumbers:Array = new Array(
			'S', 'D', 'F', 'J', 'K', 'L');
		
		private var _playNotesAsNumbers:Boolean = false;

		
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
		
		
		private var _currentNoteIndex:int = 0;
		private var _nextNoteIndex:int = 1;
		private var _previousNoteIndex:int = -1;
		
		private var _allFrames:Number = 0;
		private var _accurateFrames:Number = 0;
		
		private var _timeElapsed:Number = 0.0;
		private var _timer:FlxTimer;
		
		private var _timeLineSprite:Sprite;
		private var _inputSprite:Sprite;
		private var _templateSprite:Sprite;
		
		
		private var _input:PlayerInput;
		
		private var _drawUI:Boolean = false;
		private var _playNotes:Boolean = false;
		private var _playNotesEnabled:Boolean = true;
		
		private var _noteNameFormat:TextFormat = new TextFormat("Commodore",12,0xFFFFFF,null,null,null,null,null,"left");
		private var _noteNamesBG:Sprite;
		private var _noteNames:Array;
		
		private var _ratingTextFormat:TextFormat = new TextFormat("Commodore",100,0xFFFFFF,null,null,null,null,null,"center");
		private var _rating:TextField;
		private var _ratingWordFormat:TextFormat = new TextFormat("Commodore",50,0xFFFFFF,null,null,null,null,null,"center"); 
		private var _ratingWord:TextField;
		private var _ratingTimer:FlxTimer;
		private var _countText:TextField;
		private var _countTextFormat:TextFormat = new TextFormat("Commodore",100,0x00FF00,null,null,null,null,null,"center");
		private var _fadeRating:Boolean = false;
		
		private var _countIn:Boolean;
		private var _countInTimer:FlxTimer;
		private var _count:uint = 0;
		private var _loop:Boolean;
		private var _ratings:Boolean;
		
		private var _playing:Boolean = false;
		
		private var _loopFrame:Boolean = false;
		
		private var _lastRating:Number = 0.0;
		
		private var _clipLength:Number;
		private var _factor:Number = 1;
		
		public var dispatcher:EventDispatcher = new EventDispatcher();
		
		
		public function LoopMusic(playerInput:PlayerInput, countIn:Boolean = true, loop:Boolean = true, drawUI:Boolean = false, playNotes:Boolean = false, ratings:Boolean = true)
		{
			super();
			
			FlxG.volume = 1;
			FlxG.mute = false;
			
			_input = playerInput;
			_countIn = countIn;
			_loop = loop;
			_drawUI = drawUI;
			_playNotes = playNotes;
			_ratings = ratings;
			
			if (_loop)
				_clipLength = CLIP_LENGTH_LOOP * _factor;
			else
				_clipLength = CLIP_LENGTH_NOLOOP;
			
			if (_drawUI)
			{
				setupScoreTemplateNotes();
				setupTimeLine();
				setupInput();
			}
			
			if (_playNotes)
			{
				var embeddedNotes:Array = new Array();
				embeddedNotes.push(Assets.D_SHARP, Assets.F_NORMAL, Assets.F_SHARP, Assets.G_SHARP, Assets.A_SHARP, Assets.C_SHARP);
				_notes = new Array();
				for (var i:int = 0; i < embeddedNotes.length; i++)
				{
					//var sound:FlxSound = new FlxSound();
					var sound:FlxSound = FlxG.loadSound(embeddedNotes[i]);
					//sound.loadEmbedded(embeddedNotes[i]);
					sound.volume = 0.3;
					_notes.push(sound);
				}
			}
			
			_rating = makeTextField(0,FlxG.height/2 - 10,FlxG.width,200,"TESTING",_ratingTextFormat);
			_rating.alpha = 0;
			FlxG.stage.addChild(_rating);
			
			_ratingWord = makeTextField(0,FlxG.height/2 + 10,FlxG.width,200,"",_ratingWordFormat);
			_ratingWord.alpha = 0;
			FlxG.stage.addChild(_ratingWord);
			
			_countText = makeTextField(0,FlxG.height/2 - 10,FlxG.width,200,"",_countTextFormat);
			_countText.alpha = 0;
			FlxG.stage.addChild(_countText);
			
			_ratingTimer = new FlxTimer();
			
			_epicSaxLoop = FlxG.loadSound(Assets.EPIC_SAX_LOOP_NO_SAX);			
			_epicSaxLoop.volume = 0;
			_epicSaxLoop.play();
						
			_timer = new FlxTimer();

		}
		
		private function setupScoreTemplateNotes():void
		{
			
			_templateSprite = new Sprite();
			_templateSprite.x = 40; _templateSprite.y = 384;
			var _currentX:Number = 0;
			var _currentY:Number = 0;
			var _currentWidth:Number = 0;
			
			for (var i:uint = 0; i < _notesAsNumbers.length; i++) {
				_currentX = ((_noteStarts[i] * _factor) / _clipLength) * (FlxG.width * Globals.ZOOM - 40);
				_currentY = ((5 - _notesAsNumbers[i]) * Globals.ZOOM * 2);
				_currentWidth = (((_noteEnds[i] * _factor) - (_noteStarts[i] * _factor) )/_clipLength) * (FlxG.width * Globals.ZOOM - 40);
				_templateSprite.graphics.beginFill(0xFFFFFF);
				_templateSprite.graphics.drawRect(_currentX,_currentY,_currentWidth,Globals.ZOOM);
				_templateSprite.graphics.endFill();				
			}
			FlxG.stage.addChild(_templateSprite);
			
			_noteNamesBG = new Sprite();
			_noteNamesBG.graphics.beginFill(0x666666);
			_noteNamesBG.graphics.drawRect(0,376,40,104);
			FlxG.stage.addChild(_noteNamesBG);
			
			_noteNames = new Array();
			for (i = 0; i < _input.getNumNotes(); i++)
			{
				_noteNames.push(
					makeTextField(2/Globals.ZOOM,
								  380/Globals.ZOOM + (i * 2),
								  100,
								  100,(6 - i).toString() + "/" + this._noteInputsAsNumbers[5 - i],_noteNameFormat));
				FlxG.stage.addChild(_noteNames[i]);
			}
		}
		
		
		private function setupTimeLine():void
		{
			_timeLineSprite = new Sprite();
			_timeLineSprite.x = 40; 
			_timeLineSprite.y = 376;
			_timeLineSprite.graphics.lineStyle(1,0xFFFFFF);
			_timeLineSprite.graphics.moveTo(0,0);
			_timeLineSprite.graphics.lineTo(0,120);
			FlxG.stage.addChild(_timeLineSprite);
		}
		
		
		private function setupInput():void
		{
			_inputSprite = new Sprite();
			_inputSprite.x = 40; _inputSprite.y = 384;
			FlxG.stage.addChild(_inputSprite);
		}
		
		
		
		public function start():void
		{
			_input.enable();
			if (_countIn)
			{
				trace("Calling _countInTimer");
				_countInTimer = new FlxTimer();
				_countInTimer.start(1,1,count);
			}
			else {
				playMusic(null);
			}
		}
		
		
		private function count(t:FlxTimer):void
		{
			
			trace("In count()");
			
			FlxG.play(Assets.CLICK,0.1);

			_count++;
						
			_countText.alpha = 1;
			if (_count > 2)
			{
				_countText.text = (_count - 2).toString();
			}
			else
			{
				_countText.text = _count.toString();
			}
			if (_count == 6)
			{
				_count = 0;
				t.start(HALF_COUNT,1,playMusic);
			}
			else if (_count < 3)
			{
				t.start(FULL_COUNT,1,count);
			}
			else
			{
				t.start(HALF_COUNT,1,count);
			}
			
		}
		
		
		private function playMusic(t:FlxTimer):void
		{
			_rating.alpha = 0;
			_countText.alpha = 0;
			_playing = true;

			FlxG.volume = 1;
			FlxG.mute = false;
			_epicSaxLoop.volume = 0.9;
			_epicSaxLoop.play(true);
			
			_input.record();
			
			_timer.start(_clipLength,1,onFinish);
		}
		
		
		public function enableNotes():void
		{
			if (_playNotes)
			{
				_playNotesEnabled = true;
			}
		}
		
		
		public function disableNotes():void
		{
			if (_playNotes)
			{
				_playNotesEnabled = false;
				for (var i:int = 0; i < _notes.length; i++)
					_notes[i].stop();
			}
		}
		
		
		public function getPlayNotesEnabled():Boolean{
			return (_playNotesEnabled);
		}
		
		
		private function onFinish(t:FlxTimer):void 
		{
			
			if (_loop)
			{		
				if (_ratings)
					displayPracticeRating();
				
				trace("_accurateFrames = " + _accurateFrames);
				trace("_allFrames = " + _allFrames);
				_lastRating = _accurateFrames / _allFrames;
				trace("_lastRating = " + _lastRating);

				trace("Dispatching Event.COMPLETE...");
				dispatcher.dispatchEvent(new Event(Event.COMPLETE));

				_accurateFrames = 0;
				_allFrames = 0;
				
				_timeElapsed = 0.0;
				_currentNoteIndex = 0;
				_nextNoteIndex = 1;
				_previousNoteIndex = -1;
				
				if (_drawUI)
				{
					_inputSprite.graphics.clear();
				}
				
				_input.resetInput();
				
				_fadeRating = false;
				
				if (this._playNotes)
				{
					for (var i:int = 0; i < _notes.length; i++)
						_notes[i].stop();
				}
				
				_epicSaxLoop.play(true);
				_timer.start(_clipLength,1,onFinish);
			}
			else
			{				
				_lastRating = _accurateFrames / _allFrames;

				dispatcher.dispatchEvent(new Event(Event.COMPLETE));

				_accurateFrames = 0;
				_allFrames = 0;
				
				_timeElapsed = 0.0;
				_currentNoteIndex = 0;
				_nextNoteIndex = 1;
				_previousNoteIndex = -1;
				
				_playing = false;
				_input.stopRecord();
			}
		}
		
		
		private function displayPracticeRating():void
		{
			var rating:int = Math.floor((_accurateFrames / _allFrames) * 100)
			_rating.text = rating.toString() + "%";
			_rating.alpha = 1.0;
			_ratingWord.text = getRatingWord(rating);
			_ratingWord.alpha = 1.0;
			
			_ratingTimer.start(1,1,startRatingFade);
		}
		
		
		private function startRatingFade(t:FlxTimer):void
		{
			_fadeRating = true;
		}
		
		private function getRatingWord(rating:int):String
		{
			if (rating >= 95)
				return "EPIC!";
			if (rating >= 90)
				return "OH YEAH!";
			if (rating >= 85)
				return "MY MAN!";
			if (rating >= 80)
				return "DOIN' IT!";
			if (rating >= 75)
				return "PLAY IT!";
			if (rating >= 70)
				return "KEEP GOING!";
			if (rating >= 65)
				return "UH HUH!";
			if (rating >= 60)
				return "WELL, ALRIGHT!";
			if (rating >= 55)
				return "NOT BAD!";
			if (rating > 50)
				return "KIND OF!";
			if (rating >= 0)
				return "ROOM TO IMPROVE!";
			
			return "ERROR.";
		}
		
		
		public function stop():void
		{
			this._epicSaxLoop.stop();
			this._playing = false;
			this._timer.stop();
		}
		
		public override function update():void
		{
			super.update();
			
			if (_playing)
			{
				if (_timeElapsed == 0)
					_loopFrame = true;
				else
					_loopFrame = false;
				
				_timeElapsed += FlxG.elapsed;
				trace("_timeElapsed increased");
				
				if (_fadeRating && _rating.alpha > 0)
				{
					_rating.alpha -= 0.01;
					_ratingWord.alpha -= 0.01;
				}
				
				checkAccuracy();
				
				if (_drawUI)
				{
					moveTimeLine();
					drawPlayerNotes();
				}
				if (_playNotes && _playNotesEnabled) playNotes();
				updateNotesAndMusic();
				officialNotes();	
				
//				for (var i:uint = 0; i < this._notes.length; i++)
//				{
//					if (i != this._currentNoteIndex)
//					{
//						_notes[i].stop();
//					}
//				}
			}
		}
		
		
		private function moveTimeLine():void
		{
			_timeLineSprite.x = 40 + (_timeElapsed / (_clipLength)) * (FlxG.width * Globals.ZOOM - 40);
		}
		
		
		private function playNotes():void
		{
			if (_currentNoteIndex != -1)
			{
				if (_previousNoteIndex != -1)
				{
					trace("_currentNoteIndex is not -1, Stopping _previousNoteIndex of " + _previousNoteIndex);
					_notes[_notesAsNumbers[_previousNoteIndex]].stop();
				}
				trace("Playing _currentNoteIndex of " + _currentNoteIndex);
				_notes[_notesAsNumbers[_currentNoteIndex]].play();
			}
			else
			{
				trace("_currentNoteIndex is -1, Stopping _previousNoteIndex of " + _previousNoteIndex);
				for (var i:int = 0; i < _notes.length; i++)
					_notes[i].stop();
				//_notes[_notesAsNumbers[_previousNoteIndex]].stop();
			}
		}
		
		
		private function updateNotesAndMusic():void
		{
			if (_playNotes)
			{
				for (var i:int = 0; i < _notes.length; i++)
				{
					//_notes[i].update();
				}
			}
			
			//_epicSaxLoop.update();
		}
		
		
		private function officialNotes():void
		{
			if (_currentNoteIndex != -1 && _timeElapsed >= _noteEnds[_currentNoteIndex] * _factor)
			{
				_previousNoteIndex = _currentNoteIndex;
				if (_timeElapsed >= _noteStarts[_nextNoteIndex] * _factor)
				{
					_currentNoteIndex = _nextNoteIndex;
					_nextNoteIndex++;
				}
				else
				{
					_currentNoteIndex = -1;
				}
			}
			else if (_currentNoteIndex == -1 && _timeElapsed >= _noteStarts[_nextNoteIndex] * _factor)
			{
				_previousNoteIndex = _currentNoteIndex;
				_currentNoteIndex = _nextNoteIndex;
				_nextNoteIndex++;
			}
		}
		
		
		private function drawPlayerNotes():void
		{
			for (var i:uint = 0; i < _input.getNumNotes(); i++) 
			{
				if (_input.getNotePressed(i) > 0) 
				{
					trace("Drawing. getNotePressed is  " + _input.getNotePressed(i) + ", timeElapsed is " + _timeElapsed);
					_inputSprite.graphics.beginFill(0xFFFF0000);
					_inputSprite.graphics.drawRect(_input.getNotePressed(i)/_clipLength * (FlxG.width * Globals.ZOOM - 40), 
						(5 - i) * Globals.ZOOM * 2, 
						(_timeElapsed - _input.getNotePressed(i))/_clipLength * (FlxG.width * Globals.ZOOM - 40), 
						Globals.ZOOM);
					_inputSprite.graphics.endFill();
				}
			}
		}
		
		
		private function checkAccuracy():void
		{
			var accurateFrame:Boolean = true;
			
			// Check each of the notes that the player may be playing
			
			for (var i:int = 0; i < _input.getNumNotes(); i++)
			{
				// If the current note has never been played but should be
				if (_input.getNotePressed(i) == 0 &&
					_currentNoteIndex != -1 &&
					_notesAsNumbers[_currentNoteIndex] == i)
				{
					accurateFrame = false;
					break;
				}
				
				// If the current note isn't being played but should be
				// [[ And it wasn't just released within the fuzzy allowance ]]
				if (_input.getNotePressed(i) < 0 &&
					_currentNoteIndex != -1 &&
					_notesAsNumbers[_currentNoteIndex] == i &&
					_timeElapsed - FUZZY_ALLOWANCE > Math.abs(_input.getNotePressed(i)))
				{
					accurateFrame = false;
					break;
				}
				
				// If the current note is being played but no note should be playing
				// [[ And it's not the case that the previous note was this one and ended within the allowance
				// [[ And it's not the case that the next note is this one and starts withint he allowance
				if (_input.getNotePressed(i) > 0 &&
					_currentNoteIndex == -1 &&
					!(_previousNoteIndex > 0 && 
						_notesAsNumbers[_previousNoteIndex] == i && 
						_noteEnds[_previousNoteIndex] * _factor > _input.getNotePressed(i) - FUZZY_ALLOWANCE)
					&&
					!(_nextNoteIndex < _notesAsNumbers.length &&
						_notesAsNumbers[_nextNoteIndex] == i &&
						_noteStarts[_nextNoteIndex] * _factor < _input.getNotePressed(i) + FUZZY_ALLOWANCE))
				{
					accurateFrame = false;
					break;
				}
				
				// If the current note is playing and there should be a note playing, but not this one
				// [[ And it's not the case that the previous note was this one and ended within the allowance
				// [[ And it's not the case that the next note is this one and starts within the allowance
				if (_input.getNotePressed(i) > 0 &&
					_currentNoteIndex != -1 &&
					_notesAsNumbers[_currentNoteIndex] != i &&
					!(_previousNoteIndex > 0 && 
						_notesAsNumbers[_previousNoteIndex] == i && 
						_noteEnds[_previousNoteIndex] * _factor > _input.getNotePressed(i) - FUZZY_ALLOWANCE)
					&&
					!(_nextNoteIndex < _notesAsNumbers.length &&
						_notesAsNumbers[_nextNoteIndex] == i &&
						_noteStarts[_nextNoteIndex] * _factor < _input.getNotePressed(i) + FUZZY_ALLOWANCE))
				{
					accurateFrame = false;
					break;
				}
			}
			
			if (accurateFrame)
			{
				// Still need to check whether this was a case of not playing
				if (_currentNoteIndex == -1 && 
					_input.getNotePressed(0) <= 0 &&
					_input.getNotePressed(1) <= 0 &&
					_input.getNotePressed(2) <= 0 &&
					_input.getNotePressed(3) <= 0 &&
					_input.getNotePressed(4) <= 0 &&
					_input.getNotePressed(5) <= 0)
				{
					// Don't add a frame because you don't get credit
					// for pushing nothing when nothing needs pushing
				}
				else
				{
					trace("ACCURATE FRAME");
					_accurateFrames++;
					_allFrames++;
				}
			}
			else
			{
				_allFrames++;
			}
			

		}
		
		
		public function toggleSpeed():void
		{
			_factor = 3 - _factor;
			_clipLength = CLIP_LENGTH_LOOP * _factor;
			_epicSaxLoop.stop();
			_timer.stop();
			if (_factor == 1 ) _epicSaxLoop.loadEmbedded(Assets.EPIC_SAX_LOOP_NO_SAX);
			else if (_factor == 2) _epicSaxLoop.loadEmbedded(Assets.EPIC_SAX_LOOP_NO_SAX_DOUBLE_LENGTH);
			trace("toggleSpeed()");
			trace("_factor is " + _factor);
			trace("_clipLength is " + _clipLength);
			onFinish(null);
		}
		
		
		public function isLoopFrame():Boolean
		{
			return _loopFrame;
		}
		
		
		public function getTimeElapsed():Number
		{
			return _timeElapsed;
		}
		
		public function getLastRating():Number
		{
			return _lastRating;
		}
		
		
		private function makeTextField(x:Number, y:Number, w:Number, h:Number, s:String, tf:TextFormat):TextField {
			
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
			
			if (FlxG.stage.contains(_rating)) FlxG.stage.removeChild(_rating);
			if (FlxG.stage.contains(_ratingWord)) FlxG.stage.removeChild(_ratingWord);
			_ratingTimer.destroy();
			_timer.destroy();
			
			
			if (_drawUI)
			{
				if (FlxG.stage.contains(_timeLineSprite)) FlxG.stage.removeChild(_timeLineSprite);
				if (FlxG.stage.contains(_inputSprite)) FlxG.stage.removeChild(_inputSprite);
				if (FlxG.stage.contains(_templateSprite)) FlxG.stage.removeChild(_templateSprite);
				if (FlxG.stage.contains(_noteNamesBG)) FlxG.stage.removeChild(_noteNamesBG);
				for (i = 0; i < _input.getNumNotes(); i++)
				{
					if (FlxG.stage.contains(_noteNames[i])) FlxG.stage.removeChild(_noteNames[i]);
				}

			}
			
			if (_playNotes)
			{
				for (var i:int = 0; i < _notes.length; i++)
				{
					_notes[i].destroy();
				}
			}
			
			this._epicSaxLoop.stop();
			this._epicSaxLoop.destroy();
			
			FlxG.stage.focus = null;
		}
	}
}