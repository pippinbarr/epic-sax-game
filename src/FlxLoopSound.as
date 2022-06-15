package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.flixel.*;
	
	/**
	 * This is the universal flixel sound object, used for streaming, music, and sound effects.
	 * 
	 * EMBEDDED SEAMLESS LOOPING MODIFICATION BY MAX "GETI" CAHILL.
	 */
	public class FlxLoopSound extends FlxObject
	{
		/**
		 * Whether or not this sound should be automatically destroyed when you switch states.
		 */
		public var survive:Boolean;
		/**
		 * Whether the sound is currently playing or not.
		 */
		public var playing:Boolean;
		/**
		 * The ID3 song name.  Defaults to null.  Currently only works for streamed sounds.
		 */
		public var name:String;
		/**
		 * The ID3 artist name.  Defaults to null.  Currently only works for streamed sounds.
		 */
		public var artist:String;
		
		/*
		* A bunch of looping variables follow.
		*/
		protected const MAGIC_DELAY:Number = 2766.0; 	//THE MAGIC NUMBER
		protected const bufferSize:int = 4096;			//this gives stable playback
		protected var samplesTotal:int = 0;				//this _must_ be known about the song to be looped
		protected var samplesPosition:int = 0;			//helper for reading the sound
		
		protected var _streaming:Boolean;				//whether we're streaming the audio or not
		
		/*
		* The default FlxSound variables
		*/
		
		protected var _init:Boolean;
		public var _sound:Sound;
		protected var _in:Sound;
		public var _channel:SoundChannel;
		protected var _transform:SoundTransform;
		protected var _position:Number;
		protected var _volume:Number;
		protected var _volumeAdjust:Number;
		protected var _looped:Boolean;
		protected var _core:FlxObject;
		protected var _radius:Number;
		protected var _pan:Boolean;
		protected var _fadeOutTimer:Number;
		protected var _fadeOutTotal:Number;
		protected var _pauseOnFadeOut:Boolean;
		protected var _fadeInTimer:Number;
		protected var _fadeInTotal:Number;
		protected var _point2:FlxPoint;
		
		public var _dispatcher:EventDispatcher;
		
		/**
		 * Stores the average wave amplitude of both stereo channels
		 */
		public var amplitude:Number;
		/**
		 * Just the amplitude of the left stereo channel
		 */
		public var amplitudeLeft:Number;
		/**
		 * Just the amplitude of the left stereo channel
		 */
		public var amplitudeRight:Number;
		/**
		 * Whether to call destroy() when the sound has finished.
		 */
		
		
		/**
		 * The FlxSound constructor gets all the variables initialized, but NOT ready to play a sound yet.
		 */
		public function FlxLoopSound()
		{
			super();
			_point2 = new FlxPoint();
			_transform = new SoundTransform();
			init();
			//fixed = true; //no movement usually
			
			this._dispatcher = new EventDispatcher();
		}
		
		/**
		 * An internal function for clearing all the variables used by sounds.
		 */
		protected function init():void
		{
			_transform.pan = 0;
			_sound = null;
			_in = null;
			_position = 0;
			_volume = 1.0;
			_volumeAdjust = 1.0;
			_looped = false;
			_core = null;
			_radius = 0;
			_pan = false;
			_fadeOutTimer = 0;
			_fadeOutTotal = 0;
			_pauseOnFadeOut = false;
			_fadeInTimer = 0;
			_fadeInTotal = 0;
			active = false;
			visible = false;
			solid = false;
			playing = false;
			name = null;
			artist = null;
			
			
			amplitude = 0;
			amplitudeLeft = 0;
			amplitudeRight = 0;
			
		}
		
		/**
		 * One of two main setup functions for sounds, this function loads a sound from an embedded MP3.
		 * 
		 * @param	EmbeddedSound	An embedded Class object representing an MP3 file.
		 * @param	Looped			Whether or not this sound should loop endlessly.
		 * @param	totalSamples	If looped is true, the number of samples is needed.
		 * 
		 * @return	This <code>FlxSound</code> instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadEmbedded(EmbeddedSound:Class, Looped:Boolean=false, totalSamples:int = 0):FlxLoopSound
		{
			trace("loadEmbedded()");
			stop();
			init();
			if (Looped)
			{
				_in = new EmbeddedSound;
				_sound = new Sound();
				_sound.addEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
				samplesTotal = totalSamples - MAGIC_DELAY; //prevents any delay at the end of the track as well.
			}
			else _sound = new EmbeddedSound;
			//NOTE: can't pull ID3 info from embedded sound currently
			_streaming = false;
			_looped = Looped;
			updateTransform();
			active = true;
			return this;
		}
		
		/**
		 * One of two main setup functions for sounds, this function loads a sound from a URL.
		 * 
		 * @param	EmbeddedSound	A string representing the URL of the MP3 file you want to play.
		 * @param	Looped			Whether or not this sound should loop endlessly.
		 * 
		 * @return	This <code>FlxSound</code> instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadStream(SoundURL:String, Looped:Boolean=false):FlxLoopSound
		{
			stop();
			init();
			_sound = new Sound();
			_sound.addEventListener(Event.ID3, gotID3);
			_sound.load(new URLRequest(SoundURL));
			_streaming = true;
			_looped = Looped;
			updateTransform();
			active = true;
			return this;
		}
		
		/**
		 * Call this function if you want this sound's volume to change
		 * based on distance from a particular FlxCore object.
		 * 
		 * @param	X		The X position of the sound.
		 * @param	Y		The Y position of the sound.
		 * @param	Core	The object you want to track.
		 * @param	Radius	The maximum distance this sound can travel.
		 * 
		 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
		 */
		public function proximity(X:Number,Y:Number,Core:FlxObject,Radius:Number,Pan:Boolean=true):FlxLoopSound
		{
			x = X;
			y = Y;
			_core = Core;
			_radius = Radius;
			_pan = Pan;
			return this;
		}
		
		/**
		 * Call this function to play the sound.
		 */
		public function play(ForceRestart:Boolean = false):void
		{
			trace("play()");
			
			if(_position < 0)
				return;
			if(ForceRestart)
			{
				//				var oldAutoDestroy:Boolean = autoDestroy;
				//				autoDestroy = false;
				stop();
				//autoDestroy = oldAutoDestroy;
			}
			if(_looped)
			{
				trace("play() if (_looped)");
				if (!_streaming)
				{
					trace("play() if (_looped) if (!_streaming)");
					if(_channel == null) {
						trace("play() if (_looped) if (!_streaming) if (_channel != null)");
						//trace("PLAYING LOOPED SOUND");
						_channel = _sound.play(0,1,_transform);
						//trace("ADDING SOUND COMPLETE EVENT LISTENER");
						_channel.addEventListener(Event.SOUND_COMPLETE,looped);
					}
					if(_channel == null)
						active = false;
				}
				else
				{
					if(_position == 0)
					{
						if(_channel == null)
							_channel = _sound.play(0,9999,_transform);
						if(_channel == null)
							active = false;
					}
					else
					{
						_channel = _sound.play(_position,0,_transform);
						if(_channel == null)
							active = false;
						else
							_channel.addEventListener(Event.SOUND_COMPLETE, looped);
					}
				}
			}
			else
			{
				if(_position == 0)
				{
					if(_channel == null)
					{
						_channel = _sound.play(0,0,_transform);
						if(_channel == null)
							active = false;
						else
							_channel.addEventListener(Event.SOUND_COMPLETE, stopped);
					}
				}
				else
				{
					_channel = _sound.play(_position,0,_transform);
					if(_channel == null)
						active = false;
				}
			}
			playing = (_channel != null);
			_position = 0;
		}
		
		/**
		 * Call this function to pause this sound.
		 */
		public function pause():void
		{
			if(_channel == null)
			{
				_position = -1;
				return;
			}
			_position = _channel.position;
			_channel.stop();
			if(_looped)
			{
				while(_position >= _sound.length)
					_position -= _sound.length;
			}
			_channel = null;
			playing = false;
		}
		
		/**
		 * Call this function to stop this sound.
		 */
		public function stop():void
		{
			_position = 0;
			if(_channel != null)
			{
				_channel.stop();
				stopped();
			}
		}
		
		/**
		 * Call this function to make this sound fade out over a certain time interval.
		 * 
		 * @param	Seconds			The amount of time the fade out operation should take.
		 * @param	PauseInstead	Tells the sound to pause on fadeout, instead of stopping.
		 */
		public function fadeOut(Seconds:Number,PauseInstead:Boolean=false):void
		{
			_pauseOnFadeOut = PauseInstead;
			_fadeInTimer = 0;
			_fadeOutTimer = Seconds;
			_fadeOutTotal = _fadeOutTimer;
		}
		
		/**
		 * Call this function to make a sound fade in over a certain
		 * time interval (calls <code>play()</code> automatically).
		 * 
		 * @param	Seconds		The amount of time the fade-in operation should take.
		 */
		public function fadeIn(Seconds:Number):void
		{
			_fadeOutTimer = 0;
			_fadeInTimer = Seconds;
			_fadeInTotal = _fadeInTimer;
			play();
		}
		
		/**
		 * Set <code>volume</code> to a value between 0 and 1 to change how this sound is.
		 */
		public function get volume():Number
		{
			return _volume;
		}
		
		/**
		 * @private
		 */
		public function set volume(Volume:Number):void
		{
			_volume = Volume;
			if(_volume < 0)
				_volume = 0;
			else if(_volume > 1)
				_volume = 1;
			updateTransform();
		}
		
		/**
		 * Internal function that performs the actual logical updates to the sound object.
		 * Doesn't do much except optional proximity and fade calculations.
		 */
		protected function updateSound():void
		{
			
			if(_position != 0)
				return;
			
			var radial:Number = 1.0;
			var fade:Number = 1.0;
			
			//Distance-based volume control
			if(_core != null)
			{
				var _point:FlxPoint = new FlxPoint();
				var _point2:FlxPoint = new FlxPoint();
				_core.getScreenXY(_point);
				getScreenXY(_point2);
				var dx:Number = _point.x - _point2.x;
				var dy:Number = _point.y - _point2.y;
				radial = (_radius - Math.sqrt(dx*dx + dy*dy))/_radius;
				if(radial < 0) radial = 0;
				if(radial > 1) radial = 1;
				
				if(_pan)
				{
					var d:Number = -dx/_radius;
					if(d < -1) d = -1;
					else if(d > 1) d = 1;
					_transform.pan = d;
				}
			}
			
			//Cross-fading volume control
			if(_fadeOutTimer > 0)
			{
				_fadeOutTimer -= FlxG.elapsed;
				if(_fadeOutTimer <= 0)
				{
					if(_pauseOnFadeOut)
						pause();
					else
						stop();
				}
				fade = _fadeOutTimer/_fadeOutTotal;
				if(fade < 0) fade = 0;
			}
			else if(_fadeInTimer > 0)
			{
				_fadeInTimer -= FlxG.elapsed;
				fade = _fadeInTimer/_fadeInTotal;
				if(fade < 0) fade = 0;
				fade = 1 - fade;
			}
			
			_volumeAdjust = radial*fade;
			updateTransform();
		}
		
		/**
		 * The basic game loop update function.  Just calls <code>updateSound()</code>.
		 */
		override public function update():void
		{
			super.update();
			updateSound();
			if((_transform.volume > 0) && (_channel != null))
			{
				amplitudeLeft = _channel.leftPeak/_transform.volume;
				amplitudeRight = _channel.rightPeak/_transform.volume;
				amplitude = (amplitudeLeft+amplitudeRight)*0.5;
			}
		}
		
		/**
		 * The basic class destructor, stops the music and removes any leftover events.
		 */
		override public function destroy():void
		{
			if(active)
				stop();
		}
		
		/**
		 * An internal function used to help organize and change the volume of the sound.
		 */
		internal function updateTransform():void
		{
			_transform.volume = (FlxG.mute?0:1)*FlxG.volume*_volume*_volumeAdjust;
			if(_channel != null)
				_channel.soundTransform = _transform;
		}
		
		/**
		 * An internal helper function used to help Flash resume playing a looped sound.
		 * 
		 * @param	event		An <code>Event</code> object.
		 */
		protected function looped(event:Event=null):void
		{
			trace("looped()");
			if (_channel == null)
				return;
			_channel.removeEventListener(Event.SOUND_COMPLETE,looped);
			_channel = null;
			play();
		}
		
		/**
		 * An internal helper function used to help Flash clean up and re-use finished sounds.
		 * 
		 * @param	event		An <code>Event</code> object.
		 */
		protected function stopped(event:Event=null):void
		{
			trace("stopped()");
			if(!_looped)
				_channel.removeEventListener(Event.SOUND_COMPLETE,stopped);
			else
				_channel.removeEventListener(Event.SOUND_COMPLETE,looped);
			_channel = null;
			active = false;
			playing = false;
			amplitude = 0;
		}
		
		/**
		 * Internal event handler for ID3 info (i.e. fetching the song name).
		 * 
		 * @param	event	An <code>Event</code> object.
		 */
		protected function gotID3(event:Event=null):void
		{
			trace("gotID3()");
			FlxG.log("got ID3 info!");
			if(_sound.id3.songName.length > 0)
				name = _sound.id3.songName;
			if(_sound.id3.artist.length > 0)
				artist = _sound.id3.artist;
			_sound.removeEventListener(Event.ID3, gotID3);
		}
		
		//this is just forwarding the event and bufferSize to the extraction function.
		protected function sampleData( event:SampleDataEvent ):void
		{
			extract( event.data, bufferSize );
		}
		
		/**
		 * This methods extracts audio data from the mp3 and wraps it automatically with respect to encoder delay
		 *
		 * @param target The ByteArray where to write the audio data
		 * @param length The amount of samples to be read
		 */
		protected function extract( target: ByteArray, length:int ):void
		{
			if ( samplesPosition <= MAGIC_DELAY + 5000 && samplesPosition > 3000)
				this._dispatcher.dispatchEvent(new Event(Event.SOUND_COMPLETE));
			
			if (samplesTotal == 0) return;
						
			while( 0 < length )
			{
				if( samplesPosition + length > samplesTotal )
				{
					var read: int = samplesTotal - samplesPosition;
					
					_in.extract( target, read, samplesPosition + MAGIC_DELAY );
					
					samplesPosition += read;
					
					length -= read;
				}
				else
				{
					_in.extract( target, length, samplesPosition + MAGIC_DELAY );
					
					samplesPosition += length;
					
					length = 0;
				}
				
				if( samplesPosition == samplesTotal ) // WE ARE AT THE END OF THE LOOP > WRAP
				{
					samplesPosition = 0;
				}
			}
		}
		
		
		public function getChannel():SoundChannel {
			return _channel;
		}
		
	}
}
