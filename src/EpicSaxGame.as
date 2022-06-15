package {

	import org.flixel.*;
	import flash.events.Event;
	
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.system.fscommand;

	[SWF(width = "640", height = "480", backgroundColor = "#FFFFFF")]
//	[Frame(factoryClass="EpicSaxGamePreloader")]

	public class EpicSaxGame extends FlxGame {
		
		public function EpicSaxGame() {
			super(80,60,TitleState,Globals.ZOOM);
			FlxG.framerate = 60;
		//	this.forceDebugger = true;	
			this.useSoundHotKeys = false;
			
			
			/////////////////////////////////
			
			
			FlxG.stage.showDefaultContextMenu = false;
			FlxG.stage.displayState = StageDisplayState.FULL_SCREEN;
			FlxG.stage.scaleMode = StageScaleMode.SHOW_ALL;
			FlxG.stage.fullScreenSourceRect = new Rectangle(0,0,640,480);
			
			FlxG.stage.align = StageAlign.TOP;
			
			fscommand("trapallkeys","true");
		}
		
		public override function create(FlashEvent:Event):void
		{
			super.create(FlashEvent);
			stage.removeEventListener(Event.DEACTIVATE, onFocusLost);
			stage.removeEventListener(Event.ACTIVATE, onFocus);
		}
		
	}
}