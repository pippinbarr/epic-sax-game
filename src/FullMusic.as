package
{
	
	import flash.display.Sprite;
	import flash.text.*;
	import flash.events.*;
	
	import org.flixel.*;
	
	public class FullMusic extends FlxBasic
	{		
		private const CLIP_LENGTH:Number = 174.994286;
		
		
		private const HALF_COUNT:Number = 0.45;
		private const FULL_COUNT:Number = 0.9;
		
		private const FUZZY_ALLOWANCE:Number = 0.05;
		
		private var _epicSaxTrack:FlxSound;
		
		private var _notes:Array;
				
		private var _notesAsNumbers:Array = new Array(
			4, 
			4, 4, 4, 3, 4, 4,
			4, 4, 4, 3, 4, 4,
			5, 4, 3, 2,
			0, 0, 1, 2, 0
		);
		
		private var _currentNoteIndex:int = -2;
		private var _nextNoteIndex:int = 1;
		private var _previousNoteIndex:int = -1;
		
		private var _currentLoopIndex:int = 0;
		
		private var _allFrames:uint = 0;
		private var _accurateFrames:uint = 0;
		
		private var _timeElapsed:Number = 0.0;
		private var _timer:FlxTimer;
		
		private var _input:PlayerInput;
		
		private var _drawUI:Boolean = false;
		private var _playNotes:Boolean = false;
		private var _playNotesEnabled:Boolean = false;
		
		private var _countIn:Boolean;
		private var _countInTimer:FlxTimer;
		private var _count:uint = 0;
		private var _loop:Boolean;
		
		private var _countText:TextField;
		private var _countTextFormat:TextFormat = new TextFormat("Commodore",100,0x00FF00,null,null,null,null,null,"center");
		
		private var _playing:Boolean = false;
		private var _finished:Boolean = false;

		public var dispatcher:EventDispatcher = new EventDispatcher();
		
		public function FullMusic(playerInput:PlayerInput, countIn:Boolean = true, loop:Boolean = true, drawUI:Boolean = false, playNotes:Boolean = false)
		{
			super();
			
			FlxG.bgColor = 0xFF000000;
						
			_input = playerInput;
			_countIn = countIn;
			_loop = loop;
			_drawUI = drawUI;
			_playNotes = playNotes;
			
			if (_playNotes)
			{
				var embeddedNotes:Array = new Array();
				embeddedNotes.push(Assets.D_SHARP, Assets.F_NORMAL, Assets.F_SHARP, Assets.G_SHARP, Assets.A_SHARP, Assets.C_SHARP);
				_notes = new Array();
				for (var i:int = 0; i < embeddedNotes.length; i++)
				{
					var sound:FlxSound = new FlxSound();
					sound.loadEmbedded(embeddedNotes[i]);
					_notes.push(sound);
				}
			}
			
			_countText = makeTextField(0,FlxG.height/2 - 10,FlxG.width,200,"",_countTextFormat);
			_countText.alpha = 0;
			FlxG.stage.addChild(_countText);

			_epicSaxTrack = new FlxSound();
			_epicSaxTrack.loadEmbedded(Assets.EPIC_SAX_TRACK_NO_SAX);	
			
			_epicSaxTrack.volume = 0;
			_epicSaxTrack.play(true);
			
			_timer = new FlxTimer();
		}

				
		public function start():void
		{
			//_input.enable();
			if (_countIn)
			{
				_countInTimer = new FlxTimer();
				_countInTimer.start(1,1,count);
			}
			else {
				playMusic(null);
			}
		}
		
		
		private function count(t:FlxTimer):void
		{
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
			_countText.alpha = 0;
			
			FlxG.volume = 1;
			_epicSaxTrack.volume = 0.7;

			_input.enable();
			_input.record();
			
			_playing = true;

			_epicSaxTrack.play(true);
			
			_timer.start(CLIP_LENGTH,1,onFinish);
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
				_playing = false;
				_finished = true;
				
				dispatcher.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		
		
		
		public override function update():void
		{
			super.update();
			
			if (_playing)
			{
				_timeElapsed += FlxG.elapsed;
				
				checkAccuracy();
				
				if (_playNotes && _playNotesEnabled) playNotes();
				updateNotesAndMusic();
				officialNotes();	
			}
		}
				
		
		private function playNotes():void
		{
			if (_currentNoteIndex == -2)
			{
				return;
			}
			if (_currentNoteIndex != -1)
			{
				if (_previousNoteIndex != -1)
				{
					_notes[_notesAsNumbers[_previousNoteIndex]].stop();
				}
				_notes[_notesAsNumbers[_currentNoteIndex]].play();
			}
			else 
			{
				_notes[_notesAsNumbers[_previousNoteIndex]].stop();
			}
		}
		
		
		private function updateNotesAndMusic():void
		{
			if (_playNotes)
			{
				for (var i:int = 0; i < _notes.length; i++)
				{
					_notes[i].update();
				}
			}
			
			_epicSaxTrack.update();
		}
		
		
		private function officialNotes():void
		{
			if (_currentLoopIndex == -1)
				return;
			
			// If we're at the very beginning then we obviously want to play the first note!
			if (_currentNoteIndex == -2 && _timeElapsed + Timings.MAGIC_NUMBER >= Timings._fullSaxLoopStarts[_currentLoopIndex] + Timings._saxStarts[0])
			{
				_currentNoteIndex = 0;
			}
			// If we're currently playing a note and we've reached its endpoint
			else if (_currentNoteIndex != -1 && _timeElapsed + Timings.MAGIC_NUMBER >= Timings._fullSaxLoopStarts[_currentLoopIndex] + Timings._saxEnds[_currentNoteIndex])
			{
				// Then remember this note
				_previousNoteIndex = _currentNoteIndex;
				
				// If we've just made it all the way to the end
				if (_currentNoteIndex + 1 == _notesAsNumbers.length)
				{
					_currentLoopIndex++;
					_previousNoteIndex = _currentNoteIndex;
					_currentNoteIndex = -2;
					_nextNoteIndex = 0;
					if (_currentLoopIndex == Timings._fullSaxLoopStarts.length)
					{
						_currentLoopIndex = -1;
					}
				}
				
				// If the next note is ready to start already
				if (_timeElapsed + Timings.MAGIC_NUMBER >= Timings._fullSaxLoopStarts[_currentLoopIndex] + Timings._saxStarts[_nextNoteIndex])
				{
					// Then set the next note
					_currentNoteIndex = _nextNoteIndex;
					// And increase the next note
					_nextNoteIndex++;
				}
				// Otherwise the next note isn't up yet
				else
				{
					// So we set "not playing"
					_currentNoteIndex = -1;
				}
			}
			// If there's nothing playing but we've reached the start of the next note
			else if (_currentNoteIndex == -1 && _timeElapsed + Timings.MAGIC_NUMBER >= Timings._fullSaxLoopStarts[_currentLoopIndex] + Timings._saxStarts[_nextNoteIndex])
			{
				// Remember the previous note
				_previousNoteIndex = _currentNoteIndex;
				_currentNoteIndex = _nextNoteIndex;
				_nextNoteIndex++;
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
				
				// If the current note it being played but no note should be playing
				// [[ And it's not the case that the previous note was this one and ended within the allowance
				// [[ And it's not the case that the next note is this one and starts withint he allowance
				if (_input.getNotePressed(i) > 0 &&
					_currentNoteIndex == -1 &&
					!(_previousNoteIndex > 0 && 
						_notesAsNumbers[_previousNoteIndex] == i && 
						Timings._fullSaxLoopStarts[_currentLoopIndex] + Timings._saxEnds[_previousNoteIndex] > _input.getNotePressed(i) - FUZZY_ALLOWANCE)
					&&
					!(_nextNoteIndex < _notesAsNumbers.length &&
						_notesAsNumbers[_nextNoteIndex] == i &&
						Timings._fullSaxLoopStarts[_currentLoopIndex] + Timings._saxStarts[_nextNoteIndex] < _input.getNotePressed(i) + FUZZY_ALLOWANCE))
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
						Timings._fullSaxLoopStarts[_currentLoopIndex] + Timings._saxEnds[_previousNoteIndex] > _input.getNotePressed(i) - FUZZY_ALLOWANCE)
					&&
					!(_nextNoteIndex < _notesAsNumbers.length &&
						_notesAsNumbers[_nextNoteIndex] == i &&
						Timings._fullSaxLoopStarts[_currentLoopIndex] + Timings._saxStarts[_nextNoteIndex] < _input.getNotePressed(i) + FUZZY_ALLOWANCE))
				{
					accurateFrame = false;
					break;
				}
			}
			
			if (accurateFrame)
			{
				// Still need to check whether this was a case of not playing
				if ((_currentNoteIndex == -1 || _currentNoteIndex == -2) && 
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
				trace("Inaccurate frame.");
				_allFrames++;
			}
		}
		
		
		private function makeTextField(x:uint, y:uint, w:uint, h:uint, s:String, tf:TextFormat):TextField {
			
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
		
		
		public function getTime():Number
		{
			return _timeElapsed;
		}
		
		
		public function getFinished():Boolean
		{
			return _finished;
		}
		
		public function getRating():Number
		{
			return (_accurateFrames / _allFrames);
		}
		
		
		public override function destroy():void
		{
			super.destroy();
			
			_timer.destroy();
			_epicSaxTrack.stop();
			_epicSaxTrack.destroy();
			
			if (_playNotes)
			{
				for (var i:int = 0; i < _notes.length; i++)
				{
					_notes[i].destroy();
				}
			}
			
			if (FlxG.stage.contains(_countText)) FlxG.stage.removeChild(_countText);
			
			FlxG.stage.focus = null;
		}
	}
}