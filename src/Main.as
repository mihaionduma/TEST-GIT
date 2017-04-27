package 
{
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.display.Screen; 
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	/**
	 * ...
	 * @author Mihai Duma
	 */
	public class Main extends Sprite 
	{
		private var frameRates:int = 30;
		private var debugMode:int = 0;
		private var displayMode:int = 0;
		private var thisX:Number = 0;
		private var thisY:Number = 0;
		private var thisWidth:Number = 0;
		private var thisHeight:Number = 0;
		private var typeOfTransition:String;
		private var allowedTransitionTypes:Array = ["slideLeft", "slideRight", "fadeIn", "none"];
		private var transitionDuration:Number = 3;
		private var imageShowDuration:Number = 3;
		private var animationContor:Number = 0;
		private var debugging:Boolean;
		private var initTimer:Timer;
		
		private var fileOpened:File;
		private var newFileStream:FileStream;
		
		private var settingsObj:String;
		
		public function Main():void 
		{
			stage.align = StageAlign.TOP_LEFT; 
            stage.scaleMode = StageScaleMode.NO_SCALE; 
			readIniFile();
		}
		
		private function readIniFile():void 
		{
			fileOpened = File.applicationDirectory.resolvePath("settings/settings.ini");
			newFileStream = new FileStream();
			newFileStream.openAsync(fileOpened, FileMode.READ);
			newFileStream.addEventListener(Event.COMPLETE, showContent);
		}
		
		private function showContent(e:Event):void 
		{
		
			var splitReg:RegExp = new RegExp(/\n/g);// regexpul corect ar fi /frameRate.*?\n/g sau /frameRate.+?\n/g
			var mydata:Array = settingsObj.split(splitReg);
			newFileStream.close();
			for (var q:int = 0; q < mydata.length; q++)
			{
				var tempArr:Array = mydata[q].split("=");
				if (tempArr.length > 1)
				{
					var rex:RegExp = /[\s\r\n]+/gim;
					var tempString:String = tempArr[1].toString().replace(rex, '');
				}
				switch(tempArr[0])
				{
					case "frameRate":
						frameRates = int(tempString);
						if (frameRates == 0)
						{
							frameRates = 22;
						}
					break;
					case "debugMode":
						debugMode = Number(tempString);
						if (debugMode > 1)
						{
							debugMode = 0;
						}
					break;
					case "Display":
						displayMode = int(tempString);
						if (displayMode > 1)
						{
							displayMode = 0;
						}
					break;
					case "X":
						thisX = Number(tempString);
						if (isNaN(thisX))
						{
							thisX = 0;
						}
					break;
					case "Y":
						thisY = Number(tempString);
						if (isNaN(thisY))
						{
							thisY = 0;
						}
					break;
					case "Width":
						thisWidth = Number(tempString);
						if (isNaN(thisWidth))
						{
							thisWidth = 500;
						}
					break;
					case "Height":
						thisHeight = Number (tempString);
						if (isNaN(thisHeight))
						{
							thisWidth = 440;
						}
					break;
					case "transitionType":
						typeOfTransition = String(tempString);
					break;
					case "transitionDuration":
						transitionDuration = Number(tempString);
						if (isNaN(transitionDuration))
						{
							transitionDuration = 3;
						}
					break;
					case "imageShowDuration":
						imageShowDuration = Number(tempString);
						if (isNaN(imageShowDuration))
						{
							imageShowDuration = 3;
						}
					break;
				}
			}
			if (debugMode == 1)
			{
				debugging = true;
				Debugger.beginDebugger();
			}
			setupScene();
			setupMonitor();
			loadImagesAndXML();
		}
		
		private function setupMonitor():void 
		{
		    if (Screen.screens.length > 1) 
		    { 
				if (displayMode == 1)
				{
					var currentScreen:Screen = getCurrentScreen(); 
					var left:Array = Screen.screens; 
					left.sort(sortHorizontal);
					if (debugging)
					{
						Debugger.addText(" [SCREEN]"+left[0].bounds.left.toString() + " : " + left[1].bounds.left.toString() + " ;")
						Debugger.addText(" [SCREEN]"+stage.nativeWindow.bounds.left.toString() + " ecranul si bounds");
						Debugger.addText(" [SCREEN]"+currentScreen.bounds.left + " bounds de current screen");
					}
					if (currentScreen.bounds.left == left[0].bounds.left)
					{
						if (left[0].bounds.left == 0)
						{
							stage.nativeWindow.x += left[1].bounds.left
						}
						else {
							stage.nativeWindow.x -= left[0].bounds.left
						}
					} 
					else if (currentScreen.bounds.left == left[1].bounds.left)
					{
						if (left[1].bounds.left == 0)
						{
							stage.nativeWindow.x += left[0].bounds.left
						}
						else {
							stage.nativeWindow.x -= left[1].bounds.left
						}
					}
				}
		    }
			
			this.stage.frameRate = frameRates;
			if (debugging)
			{
				Debugger.addText("[Seting up which monitor and framerate] framerate = "+this.stage.frameRate+";...\n");
			}
		}
		
		  private function getCurrentScreen():Screen{ 
            var current:Screen; 
            var screens:Array = Screen.getScreensForRectangle(stage.nativeWindow.bounds); 
            (screens.length > 0) ? current = screens[0] : current = Screen.mainScreen; 
			if (debugging) {
				Debugger.addText(current.bounds.toString() + " bounds de ecran!");
			}
            return current; 
        } 
        
         private function sortHorizontal(a:Screen,b:Screen):int{ 
            if (a.bounds.left > b.bounds.left){ 
                return 1; 
            } else if (a.bounds.left < b.bounds.left){ 
                return -1; 
            } else {return 0;} 
        }
		
		private function setupScene():void
		{
			stage.nativeWindow.x =thisX;
			stage.nativeWindow.y = thisY;
			stage.nativeWindow.width = thisWidth;
			stage.nativeWindow.height = thisHeight;
			if (debugging)
			{
				Debugger.addText("[Seting x y width height] x = "+thisX+";y = "+thisY+"...\n");
			}
		}
		
		private var xmlOpened:File;
		private var newxXmlStream:FileStream;
		private var configXml:XML;
		private var reinit:Boolean;
		private function loadImagesAndXML():void 
		{
			xmlOpened = File.applicationDirectory.resolvePath("images/config.xml");
			newxXmlStream = new FileStream();
			newxXmlStream.openAsync(xmlOpened, FileMode.READ);
			newxXmlStream.addEventListener(Event.COMPLETE , completeXmlLoad);
		}
		
		private var nrOfElements:Number;
		private function completeXmlLoad(e:Event):void 
		{
			configXml = XML(newxXmlStream.readUTFBytes(newxXmlStream.bytesAvailable));
			newxXmlStream.close();
			if (debugging)
			{
				Debugger.addText("[Seting x y width height] Loading XML, parsing XML...\n");
			}
			nrOfElements = configXml.image.length();
			for ( var i:int = 0; i < configXml.image.length(); i++)
			{
				var temp:ImageRenderer = new ImageRenderer("images/"+configXml.image[i].@path.toXMLString(),thisWidth,thisHeight,debugging);
				temp.name = "img" + i;
				addChild(temp);
				temp.addEventListener("scamaz", startListeningToXml);
				temp.alpha = 0;
				temp.y = 0;
				temp.x = 0;
			}
		}
		
		private var contor:Number = 0;
		private var xmlTimer:Timer;
		private var actualXml:XML;
		private var prevXml:XML;
		private var timp:int = 1000;
		private function startListeningToXml(e:Event):void
		{
			contor++;
			if (debugging)
			{
				Debugger.addText("[SLIDESHOW]"+contor+" images loaded out of "+nrOfElements+"...\n");
			}
			//trace(contor+" : "+Number(configXml.image.length()-1))
			if (contor > Number(configXml.image.length()-1))
			{
				prevXml = configXml;
				xmlTimer = new Timer(timp);
				if (debugging)
				{
					Debugger.addText("[SLIDESHOW] All images loaded...\n");
				}
				xmlTimer.addEventListener(TimerEvent.TIMER , listenToXml);
				xmlTimer.start();
				beginAnimation();
			}
		}
		
		private var testXml:File;
		//private var testStream:FileStream;
		private function listenToXml(e:Event):void
		{
			testXml = File.applicationDirectory.resolvePath("images/config.xml");
			var testStream:FileStream = new FileStream();
			testStream.openAsync(testXml, FileMode.READ);
			testStream.addEventListener(Event.COMPLETE, doCompleteListener);
			testStream.addEventListener(IOErrorEvent.IO_ERROR , doError);
		}
		
		private function doError(e:IOErrorEvent):void 
		{
			trace("nasol");
		}
		
		private function doCompleteListener(e:Event):void 
		{
			actualXml = XML(FileStream(e.currentTarget).readUTFBytes(FileStream(e.currentTarget).bytesAvailable));
			if (prevXml != actualXml)
			{
				prevXml = actualXml;
				if (debugging)
				{
					Debugger.addText("[SLIDESHOW] New xml...\n");
				}
				destroy();
			}
			FileStream(e.currentTarget).close();
			actualXml = null;
		}
		
		////////////////////////////////////////////ANIMATION
		private var animationX:Number;
		private var animationAlpha:Number;
		private function checkForOkTransitions():String {
			var tempTrans:String;
			for (var q:int = 0; q < allowedTransitionTypes.length; q++)
			{
				if (typeOfTransition == allowedTransitionTypes[q])
				{
					tempTrans = typeOfTransition;
					break;
				} else {
					tempTrans = "none";
				}
			}
			return tempTrans;
		}
		
		private function beginAnimation():void
		{
			animationX = 0;
			animationAlpha = 0;
			if (debugging)
			{
				Debugger.addText("[SLIDESHOW] begin animation...\n");
			}
			var chosenTransition:String = checkForOkTransitions();
			for (var q:int = 0; q < nrOfElements; q++)
			{
				var temp:ImageRenderer = this.getChildByName("img" + q) as ImageRenderer;
				switch(chosenTransition) {
					case "slideRight":
						temp.x = thisWidth;
						temp.allAlpha = temp.alpha = 1;
						animationX = -thisWidth;
						temp.origin = thisWidth;
						
						if (q == 0)
						{
							TweenMax.to(temp,transitionDuration,{x:0,onComplete:startAnimating})
						}
					break;
					case "slideLeft":
						temp.x = -thisWidth;
						temp.allAlpha = temp.alpha = 1;
						animationX = thisWidth;
						temp.origin = -thisWidth
						if (q == 0)
						{
							TweenMax.to(temp,transitionDuration,{x:0,onComplete:startAnimating})
						}
					break;
					case "fadeIn":
						temp.x= 0;
						temp.allAlpha = temp.alpha = 0;
						temp.origin = animationX = 0;
						if (q == 0)
						{
								TweenMax.to(temp,transitionDuration,{alpha:1,onComplete:startAnimating})
						}
					break;
					case "none":
						temp.x= 0;
						temp.allAlpha = temp.alpha = 0;
						temp.origin = animationX = 0;
						if (q == 0)
						{
							temp.alpha = 1;
							startAnimating();
							//beginTimer
						}
					break;
				}
			}
			
		}
		
		private function startAnimating():void
		{
			initTimer = new Timer(imageShowDuration * 1000);
			initTimer.addEventListener(TimerEvent.TIMER , startNextTransition);
			initTimer.start();
		}
		
		private function startNextTransition(e:Event = null):void
		{
			initTimer.stop();
			var itemToLeave:ImageRenderer = this.getChildByName("img" + animationContor) as ImageRenderer;
			if (typeOfTransition != "none")
				TweenMax.to(itemToLeave, transitionDuration , { x:animationX, alpha:itemToLeave.allAlpha, onComplete:function():void { itemToLeave.x = itemToLeave.origin }} )
			else 
				itemToLeave.alpha = 0;
			animationContor++;
			if (animationContor > nrOfElements-1) {
				animationContor = 0;
			}
			
				var itemToCome:ImageRenderer = this.getChildByName("img" + animationContor) as ImageRenderer;
		
			if (typeOfTransition != "none")
				TweenMax.to(itemToCome, transitionDuration , { x:0, alpha:1, onComplete:function():void { initTimer.start() }} )
			else {
				itemToCome.alpha = 1;
				initTimer.start();
			}
		}
		////////////////////////////////// DESTROY SI REINIt
		private function destroy():void
		{
			initTimer.stop();
			xmlTimer.stop();
			contor = 0;
			animationContor = 0;
			TweenMax.killAll();
			removeAllSceneElements();
			if (debugging)
			{
				Debugger.addText("[SLIDESHOW] rebuilding...\n");
			}
			loadImagesAndXML();
		}
		
		private function removeAllSceneElements():void
		{
			for (var q:int = 0; q < nrOfElements; q++)
			{
				var temp:ImageRenderer = this.getChildByName("img" + q) as ImageRenderer;
				removeChild(temp);
			}
		}
	}
}