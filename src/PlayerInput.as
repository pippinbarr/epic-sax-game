package
{
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.flixel.*;
	
	public class PlayerInput extends FlxBasic
	{	
		private var _notes:Array;
		private var _notesPressed:Array = new Array(0,0,0,0,0,0);
		
		private var _playing:Boolean = false;
		private var _timeSinceLastNote:Number = 10;
		private var MAX_IDLE:Number = 1.0;
		
		private var _timeElapsed:Number = 0;
		private var _enabled:Boolean = false;
		private var _recording:Boolean = false;
		
		private var _notesPlayed:uint = 0;
		
		private var _notesAsNumbers:Boolean = false;
		private var _letterNoteInputs:Array = new Array(
			Keyboard.S,Keyboard.D,Keyboard.F,Keyboard.J,Keyboard.K,Keyboard.L);
		private var _letterNoteIndexes:Array = new Array(
			0,1,2,3,4,5);
		
		public function PlayerInput(MaxIdle:Number = 0.1)
		{
			MAX_IDLE = MaxIdle;
			
			var embeddedNotes:Array = new Array();
			embeddedNotes.push(Assets.D_SHARP, Assets.F_NORMAL, Assets.F_SHARP, Assets.G_SHARP, Assets.A_SHARP, Assets.C_SHARP);
			
			_notes = new Array();
			for (var i:int = 0; i < embeddedNotes.length; i++)
			{
				var sound:FlxSound = new FlxSound();
				sound.loadEmbedded(embeddedNotes[i]);
				sound.volume = 0.3;
				_notes.push(sound);
			}
			
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,onInputKeyUp);
		}
		
		
		public function enable():void
		{
			_enabled = true;
		}
		
		public function record():void
		{
			_recording = true;
		}
		
		public function stopRecord():void
		{
			_recording = false;
		}
		
		public function disable():void
		{
			_enabled = false;
			
			for (var i:int = 0; i < _notes.length; i++)
				_notes[i].stop();
			
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,onInputKeyUp);
		}
		
		public override function update():void
		{
			super.update();
			
			if (_enabled)
			{	
				if (_recording)
					_timeElapsed += FlxG.elapsed;

				var oneNotePlaying:Boolean = false;
				for (var i:int = 0; i < _notes.length; i++)
				{
					_notes[i].update();
					if (_notesPressed[i] > 0)
					{
						oneNotePlaying = true;
					}
				}
				
				
				if (oneNotePlaying)
				{
					_playing = true;
					_timeSinceLastNote = 0;
				}
				else
				{
					_timeSinceLastNote += FlxG.elapsed;
					if (_timeSinceLastNote > MAX_IDLE)
					{
						_playing = false;
					}
					else
					{
						_playing = true;
					}
				}
			}
			
		}
		
		
		public function getNotePressed(i:int):Number
		{
			return (_notesPressed[i]);
		}
		
		
		public function getNumNotes():int
		{
			return (_notes.length);
		}	
		
		
		public function getPlaying():Boolean
		{
			return (_playing);
		}
		
		
		public function resetInput():void
		{
			_timeElapsed = 0;	
			for (var i:int = 0; i < _notesPressed.length; i++)
			{
				if (_notesPressed[i] > 0)
				{
					trace("resetInput() setting _notesPressed to 0.00001");
					_notesPressed[i] = 0.00001;
				}
				else
				{
					_notesPressed[i] = 0;
				}
			}
		}
		
		
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if ((e.keyCode < 49 || e.keyCode > 54) && (this._letterNoteInputs.indexOf(e.keyCode) == -1))
				return;
			
			var noteIndex:int;

			switch (e.keyCode)
			{
				case (Keyboard.NUMBER_1):
				case (Keyboard.S):
				noteIndex = 0;
				break;
				
				case (Keyboard.NUMBER_2):
				case (Keyboard.D):
				noteIndex = 1;
				break;
				
				case (Keyboard.NUMBER_3):
				case (Keyboard.F):
				noteIndex = 2;
				break
				
				case (Keyboard.NUMBER_4):
				case (Keyboard.J):
				noteIndex = 3;
				break;
				
				case (Keyboard.NUMBER_5):
				case (Keyboard.K):
				noteIndex = 4;
				break;
				
				case (Keyboard.NUMBER_6):
				case (Keyboard.L):
				noteIndex = 5;
				break;
			}
			
			if (_notesPressed[noteIndex] <= 0)
			{
				if (noteIndex == 0 || noteIndex == 2 || noteIndex == 4)
					_notes[noteIndex].play(true,0.5);
				else
					_notes[noteIndex].play(true);
				if (_timeElapsed != 0)
				{
					_notesPressed[noteIndex] = _timeElapsed;
				}
				else
				{
					_notesPressed[noteIndex] = 0.00001;
				}
			}
		}
		
		private function onInputKeyUp(e:KeyboardEvent):void 
		{
			if ((e.keyCode < 49 || e.keyCode > 54) && (this._letterNoteInputs.indexOf(e.keyCode) == -1))
				return;
			
			var noteIndex:int;
			
			switch (e.keyCode)
			{
				case (Keyboard.NUMBER_1):
				case (Keyboard.S):
					noteIndex = 0;
					break;
				
				case (Keyboard.NUMBER_2):
				case (Keyboard.D):
					noteIndex = 1;
					break;
				
				case (Keyboard.NUMBER_3):
				case (Keyboard.F):
					noteIndex = 2;
					break
				
				case (Keyboard.NUMBER_4):
				case (Keyboard.J):
					noteIndex = 3;
					break;
				
				case (Keyboard.NUMBER_5):
				case (Keyboard.K):
					noteIndex = 4;
					break;
				
				case (Keyboard.NUMBER_6):
				case (Keyboard.L):
					noteIndex = 5;
					break;
			}
			
			_notes[noteIndex].stop();
			_notesPressed[noteIndex] = -_timeElapsed;
			
			if (_enabled)
				this._notesPlayed++;
		}
		
		public function getNotesPlayed():uint
		{
			return this._notesPlayed;
		}
		
		public override function destroy():void
		{
			super.destroy();
			
			for (var i:int = 0; i < _notes.length; i++)
				_notes[i].destroy();
			
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,onInputKeyUp);

				
			FlxG.stage.focus = null;
		}
	}
}