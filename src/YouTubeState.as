package
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.Keyboard;
	
	import org.flixel.*;
	
	public class YouTubeState extends FlxState
	{
		
		private const YOUTUBE_INTRO_TEXT:String = "" +
			"IT'S TIME FOR 'EPIC SAX GUY 10 HOURS' WHERE YOU PLAY THE EPIC SAX REFRAIN FOR 10 HOURS!\n\n" +
			"PRESS [ENTER] TO BEGIN. " +
			"PRESS [ESCAPE] TO RETURN TO THE MENU.";
		private const YOUTUBE_INTRO_TEXT_HEIGHT:uint = 18;
		
		private const YOUTUBE_RESULT_TEXT_HEIGHT:uint = 14;
		
		
		
		private const TEN_HOURS:uint = 36000;
		private const LOADING_BAR_LENGTH:Number = 52;
		
		private var _bgSprite:FlxSprite;
		private var _bgAnimation:FlxSprite;
		private var _guySprite:FlxSprite;
		
		private var _buffer:Sprite;
		private var _loadingBar:Bitmap;
		
		private var _currentBackgroundAnimation:String = "left";
		private var _currentSaxGuyPlayAnimation:String = "playleft";
		private var _currentSaxGuyIdleAnimation:String = "idleleft";
		
		private var _music:LoopMusic;
		private var _input:PlayerInput;
		
		private var _viewsText:TextField;
		private var _viewsFormat:TextFormat = new TextFormat("Commodore",16,0x000000,null,null,null,null,null,"right");
		private var _likesText:TextField;
		private var _dislikesText:TextField;
		private var _likesDislikesFormat:TextFormat = new TextFormat("Commodore",12,0x000000,null,null,null,null,null,"right");
		private var _commentsHeader:TextField;
		private var _commentsHeaderFormat:TextFormat = new TextFormat("Commodore",14,0x555555);
		private var _commentsText:TextField;
		private var _commentsFormat:TextFormat = new TextFormat("Commodore",12,0x000000);
		
		private var _ratingWordFormat:TextFormat = new TextFormat("Commodore",50,0x000000,null,null,null,null,null,"center"); 
		private var _ratingWord:TextField;
		
		private var _views:uint = 0;
		private var _likes:uint = 0;
		private var _dislikes:uint = 0;
		
		private var _playing:Boolean = false;
		private var _complete:Boolean = false;
		
		private var _cumulativeRating:Number = 0.0;
		private var _loops:uint = 0;
		
		private var _timeElapsed:Number = 0;
		
		private var _message:Message;
		private var _result:Message;
		
		private var _timer:FlxTimer;
		
		public function YouTubeState()
		{
			super();
		}
		
		
		public override function create():void
		{
			super.create();
						
			_bgSprite = new FlxSprite(0,0,Assets.YOUTUBE_BG);
			add(_bgSprite);
			
			_bgAnimation = new FlxSprite(2,2);
			_bgAnimation.loadGraphic(Assets.YOUTUBE_BG_ANIM,true,false,52,33);
			_bgAnimation.addAnimation("left",[0,1,2,3,4,5,6,7,8,9,10,11],5,true);
			_bgAnimation.addAnimation("idleleft",[0,0],5,true);
			_bgAnimation.addAnimation("idleright",[12,12],5,true);
			_bgAnimation.addAnimation("right",[12,13,14,15,16,17,18,19,20,21,22,23],5,true);
			_bgAnimation.alpha = 0.8;
			add(_bgAnimation);
						
			_guySprite = new FlxSprite(7,2);
			_guySprite.loadGraphic(Assets.YOUTUBE_SAX_GUY,true,false,42,33);
			_guySprite.addAnimation("playleft",[1,2],4,true);
			_guySprite.addAnimation("playright",[4,5],4,true);
			_guySprite.addAnimation("idleleft",[0,0],10,false);
			_guySprite.addAnimation("idleright",[3,3],10,false);
			add(_guySprite);
						
			_guySprite.play("idleleft");
			_currentSaxGuyIdleAnimation = "idleleft";
			_currentSaxGuyPlayAnimation = "playleft";
			
			_loadingBar = new Bitmap(new BitmapData(1 * Globals.ZOOM,1 * Globals.ZOOM,false,0xFF0000));
			_loadingBar.x = 2 * Globals.ZOOM;
			_loadingBar.y = 35 * Globals.ZOOM;
			_loadingBar.scaleX = 0;
			_buffer = new Sprite();
			FlxG.stage.addChild(_buffer);	
			_buffer.addChild(_loadingBar);
			
			_input = new PlayerInput(0.6);
			_music = new LoopMusic(_input, true, true, false, false, false);
			_music.dispatcher.addEventListener(Event.COMPLETE,onLoopComplete);
			add(_input);
			add(_music);
			
			
			_viewsText = makeTextField(14,40,40,100,"0",_viewsFormat);
			_likesText = makeTextField(14,43,40,100,"0 LIKES",_likesDislikesFormat);
			_dislikesText = makeTextField(14,45,40,100,"0 DISLIKES",_likesDislikesFormat);
			_commentsHeader = makeTextField(2,50,40,100,"COMMENTS",_commentsHeaderFormat);
			_commentsText = makeTextField(2,54,35,100,"Ummmmm..",_commentsFormat);
			_ratingWord = makeTextField(0,FlxG.height/2 - 10,FlxG.width,200,"",_ratingWordFormat);
			_ratingWord.alpha = 0;
			FlxG.stage.addChild(_ratingWord);

			FlxG.stage.addChild(_viewsText);
			FlxG.stage.addChild(_likesText);
			FlxG.stage.addChild(_dislikesText);
			FlxG.stage.addChild(_commentsHeader);
			FlxG.stage.addChild(_commentsText);
			
			_message = new Message(42,YOUTUBE_INTRO_TEXT_HEIGHT);
			_message.setText(YOUTUBE_INTRO_TEXT);
			_message.show();
			
			_result = new Message(42,YOUTUBE_RESULT_TEXT_HEIGHT);
			
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			
			_timer = new FlxTimer();
		}
		
		
		public override function update():void
		{
			super.update();
			
			if (!_playing)
				return;
			
			_timeElapsed += FlxG.elapsed;
			
			if (_bgAnimation.finished)
			{
				if (_currentSaxGuyIdleAnimation == "idleleft")
					_currentSaxGuyIdleAnimation = "idleright";
				else
					_currentSaxGuyIdleAnimation = "idleleft";
				
				if (_currentSaxGuyPlayAnimation == "playleft")
					_currentSaxGuyPlayAnimation = "playright";
				else
					_currentSaxGuyPlayAnimation = "playleft";
				
				if (_currentBackgroundAnimation == "left")
					_currentBackgroundAnimation = "right";
				else
					_currentBackgroundAnimation = "left";
			}
			
			_bgAnimation.play(_currentBackgroundAnimation);
			if (_input.getPlaying())
			{
				trace("PLAYING... " + _currentSaxGuyPlayAnimation);
				_guySprite.play(_currentSaxGuyPlayAnimation);
			}
			else
			{
				_guySprite.play(_currentSaxGuyIdleAnimation);
			}
						
			if (_loadingBar.width < LOADING_BAR_LENGTH * Globals.ZOOM)
				_loadingBar.scaleX = (_timeElapsed / TEN_HOURS) * (LOADING_BAR_LENGTH);
		}
		
		
		private function onLoopComplete(e:Event):void
		{
			var rating:Number = _music.getLastRating();
			_loops++;
			_cumulativeRating = (_cumulativeRating + rating);
			var views:uint = (Math.random() * 50) + (100 * _cumulativeRating/_loops);
			var likes:uint = rating * (views/10);
			var dislikes:uint = (1 - rating) * (views/10);

			this._views += views;
			this._likes += likes;
			this._dislikes += dislikes;
			
			this._viewsText.text = _views.toString();
			this._likesText.text = _likes.toString() + " LIKES";
			this._dislikesText.text = _dislikes.toString() + " DISLIKES";
			
			this._commentsText.text = getRandomComment();
			
			// Update save object
			if (this._likes > SaveState.saveObject.mostYouTubeLikes)
			{
				SaveState.saveObject.mostYouTubeLikes = this._likes;
			}
		}
		
		private function onFinish(t:FlxTimer):void
		{
			
			_complete = true;
			
			this._bgAnimation.play("idleleft");
			this._guySprite.play("idleleft");
			this._music.stop();
			this._playing = false;
			this._input.disable();
			
			
			// And respond in some way based on the cumulative rating!
			if (_cumulativeRating >= 0.5)
			{
				_result.setText("THAT. WAS. EPIC.\n\nPRESS [ESCAPE] TO RETURN TO THE MENU.");
			}
			else if (_cumulativeRating >= 0.1)
			{
				_result.setText("THAT WAS... STRANGELY IMPRESSIVE!\n\nPRESS [ESCAPE] TO RETURN TO THE MENU.");
			}
			else
			{
				_result.setText("WELL, NICE WORK ON LEAVING THE GAME RUNNING!\n\nPRESS [ESCAPE] TO RETURN TO THE MENU.");
			}
			_result.show();
			
			// Update save object
			SaveState.saveObject.completedYouTube = true;
		}
		
		
		private function getRandomComment():String
		{
			if ((_cumulativeRating/_loops) > 0.75)
				return Comments._positive[Math.floor(Math.random() * Comments._positive.length)];
			else if ((_cumulativeRating/_loops) > 0.49)
				return Comments._neutral[Math.floor(Math.random() * Comments._neutral.length)];
			else 
				return Comments._negative[Math.floor(Math.random() * Comments._negative.length)];

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
				_bgAnimation.play("left");
				_music.start();
				_message.hide();
				_timer.start(TEN_HOURS,1,onFinish);
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
			
			_input.destroy();
			_music.destroy();
			
			_bgSprite.destroy();
			_bgAnimation.destroy();
			_guySprite.destroy();
			
			FlxG.stage.removeChild(_buffer);
			
			FlxG.stage.removeChild(_viewsText);
			FlxG.stage.removeChild(_likesText);
			FlxG.stage.removeChild(_dislikesText);
			FlxG.stage.removeChild(_commentsHeader);
			FlxG.stage.removeChild(_commentsText);
			FlxG.stage.removeChild(_ratingWord);
			
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			
			_message.destroy();
			_result.destroy();
			
			_timer.destroy();
			
			FlxG.stage.focus = null;
		}
	}
}