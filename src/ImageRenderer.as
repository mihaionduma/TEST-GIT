package 
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Mihai Duma
	 */
	public class ImageRenderer extends MovieClip  
	{
		public var origin:Number;
		public var allAlpha:Number
		
		
		private var _url:String;
		private var thisWidth:Number;
		private var thisHeight:Number;
		private var loadingSprite:Sprite;
		public function ImageRenderer(url:String, w:Number, h:Number,debug:Boolean = false):void
		{
			_url = url;
			thisWidth = w;
			thisHeight = h;
			loadingSprite = new Sprite();
			addChild(loadingSprite);
			var tempLoader:Loader = new Loader();
			tempLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, doComplete);
			tempLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS , progress);
			tempLoader.load(new URLRequest(url));
			if (debug)
			{
				Debugger.addText("[SLIDESHOW IMAGE] starting to load image: "+url+" ...\n");
			}
			trace(w + " : " + h);
		}
		
		private function progress(e:ProgressEvent):void 
		{
			loadingSprite.graphics.clear();
			var raport:Number = e.bytesLoaded / e.bytesTotal ;
			loadingSprite.graphics.beginFill(0x000000, 1);
			loadingSprite.graphics.drawRect(0, thisWidth/2-5, raport * thisWidth, 10);
			loadingSprite.graphics.endFill();
		}
		
		private function doComplete(e:Event):void 
		{
			removeChild(loadingSprite);
			var temp:Bitmap = Bitmap(e.currentTarget.content);
			temp.smoothing = true;
			temp.x = 0;
			temp.y = 0;
			addChild(temp);
			var raport:Number = temp.width / temp.height;
			if (temp.width > temp.height)
			{
				temp.width = thisWidth;
				temp.height = thisHeight * raport;
			}
			else if (temp.height < temp.width)
			{
				temp.width = thisWidth* raport;
				temp.height = thisHeight ;
			}
			else {
				temp.width = thisWidth;
				temp.height = thisHeight;
			}
			// DE AJUSTAT IMAGINEA PE CENTRU!!!
			
			dispatchEvent(new Event("scamaz"));
		}
	}
	
}