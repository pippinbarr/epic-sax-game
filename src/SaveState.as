package
{
	
	import org.flixel.*;
	
	public class SaveState
	{
		
		private static var _save:FlxSave;
		private static var _loaded:Boolean = false;
		
		private static var tempSaveObject:Object = new Object();
		
		
		public function SaveState()
		{
		}
		
		public static function load():void 
		{	
			_save = new FlxSave();
			_loaded = _save.bind("EpicSaxGameData");
			
			trace("Loaded: " + _loaded);
			trace("_save.data.saveObject is " + _save.data.saveObject);
			trace("saveObject is " + saveObject);
			
			if (_loaded && _save.data.saveObject == null)
			{
				trace("Why do we not see this?");
				_save.data.saveObject = new SaveObject();
			}
			
			trace("And yet we do see this...");
			
		}
		
		public static function flush():void {
			if (_loaded) _save.flush();
		}
		
		public static function erase():void {
			if (_loaded) _save.erase();
		}
		
		public static function set saveObject(value:Object):void {
			if (_loaded)
			{
				_save.data.saveObject = value;
			}
			else
			{
				tempSaveObject = value;
			}
		}
		
		public static function get saveObject():Object {
			if (_loaded)
			{
				return _save.data.saveObject;
			}
			else
			{
				return tempSaveObject;
			}
		}
	}
}