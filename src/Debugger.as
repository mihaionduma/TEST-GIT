package {
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	
	public class Debugger {
		
		private static var file:File;
		private static var writeStream:FileStream;
		private static var initialized:Boolean;
		
		public function Debugger():void {
			trace("this class should not be instantiated");
		}
		
		public static function beginDebugger():void
		{
			if (!initialized)
			{
				var myDate:Date = new Date();
				var ziuaString:String = "";
				ziuaString += myDate.getDay().toString() + myDate.getHours().toString() + myDate.getMinutes().toString() + "__Slideshow_Logs";
				trace(ziuaString + " data");
				initialized = true;
				file = File.applicationStorageDirectory.resolvePath("debugger/"+ziuaString+".txt");
				writeStream = new FileStream();
				writeStream.open(file, FileMode.WRITE);
				ziuaString = myDate.getDay().toString()+":" + myDate.getHours().toString() +":"+ myDate.getMinutes().toString();
				writeStream.writeUTFBytes(ziuaString + " [DEBUG] initializing debug \r\n");
			}
			else {
				trace("already begun");
			}
		}
	
		public static function addText(str:String):void
		{
				var myDate:Date = new Date();
				var ziuaString:String = "";
				ziuaString = myDate.getDay().toString()+":" + myDate.getHours().toString() +":"+ myDate.getMinutes().toString();
				writeStream.writeUTFBytes(ziuaString +" "+str+" \r\n");
		}
	}
}