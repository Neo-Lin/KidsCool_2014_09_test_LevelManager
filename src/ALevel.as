package  
{
	import citrus.core.State;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import org.osflash.signals.Signal;
	
	/**
	 * ...各個場景都可以繼承這個類別,傳入swf路徑的xml就會自動載入swf,配合_ce.levelManager使用
	 * 
	 * 功能=======================
	 * 載入swf
	 * 偵聽Click事件
	 * 偵聽到達最後影格
	 * 關閉整個遊戲
	 * 
	 * 屬性=======================
	 * progressNum:載入進度(int)
	 * 
	 * 事件(由_ce發送)============
	 * isProgress:載入中
	 * isComplete:載入完成
	 * 
	 * 複寫=======================
	 * onComplete():swf載入完成.
	 * thisClick():Mouse Click.
	 * skip():skip_btn按下.
	 * finishMovie():抵達最後影格.
	 * kill():刪除後要做的事,移除偵聽事件等
	 * 
	 * @author Neo
	 */
	public class ALevel extends State 
	{
		public var lvlEnded:Signal;
		public var lvlJumpTo:Signal;
		public var restartLevel:Signal;
		protected var state_mc:MovieClip;
		protected var myLoader:Loader = new Loader();
		private var _progressNum:int;
		
		public function ALevel(level:XML = null) 
		{
			super();
			
			addEventListener(Event.REMOVED_FROM_STAGE, kill);
			/*如果不用做載入進度,level就可以直接傳入swf(MovieClip)
			 * state_mc = level;
			addChild(state_mc);
			state_mc.play();
			//影格播完自動發出事件
			state_mc.addEventListener(Event.ENTER_FRAME, goEnd);
			state_mc.addEventListener(MouseEvent.CLICK, thisClick);*/
			
			myLoader.contentLoaderInfo.addEventListener(Event.INIT, initHandle);
			myLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandle);
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			myLoader.load(new URLRequest(level));
			
			lvlEnded = new Signal();
			lvlJumpTo = new Signal(uint);
			restartLevel = new Signal();
		}
		
		private function initHandle(e:Event):void 
		{
			e.currentTarget.content.stop();
		}
		private function progressHandle(e:ProgressEvent):void 
		{	
			_ce.dispatchEvent(new Event("isProgress"));
			_progressNum = int(myLoader.contentLoaderInfo.bytesLoaded / myLoader.contentLoaderInfo.bytesTotal * 100);
		}
		/**
		 * 場景載入完畢. 顯示場景. 偵聽ENTER_FRAME & CLICK.
		 * ENTER_FRAME=影格播完(最後一格)會送出"finishMovie"訊號.  CLICK=傳出被按下的物件名字.
		 */
		protected function onComplete(e:Event):void 
		{	
			_ce.dispatchEvent(new Event("isComplete"));
			e.currentTarget.removeEventListener(Event.INIT, initHandle);
			e.currentTarget.removeEventListener(ProgressEvent.PROGRESS, progressHandle);
			e.currentTarget.removeEventListener(Event.COMPLETE, onComplete);
			state_mc = e.currentTarget.content as MovieClip;
			addChild(state_mc);
			state_mc.play();
			
			//影格播完自動發出事件
			state_mc.addEventListener(Event.ENTER_FRAME, goEnd);
			state_mc.addEventListener(MouseEvent.CLICK, thisClick);
		}
		
		override public function initialize():void {
			super.initialize();
		}
		
		protected function thisClick(e:Event):void 
		{	trace("OpLoaderState.thisClick:", e.target.name);
			//傳出被按下的物件名字
			//dispatchEvent(new Event(e.target.name));
			
			if (e.target.name == "close_btn") { //關閉遊戲
				closeWindow();
			}else if (e.target.name == "skip_btn") { //下一關
				skip();
			}
		}
		
		//繼承的類別可改寫,skip_btn按下後要執行的動作
		protected function skip():void { }
		
		private function goEnd(e:Event):void 
		{	//trace("OpLoaderState.goEnd:", this.name);
			//影格播完(最後一格)傳出訊息
			if (state_mc.currentFrame == state_mc.totalFrames) {
				//trace("影格播完(最後一格)傳出訊息");
				state_mc.removeEventListener(Event.ENTER_FRAME, goEnd);
				//dispatchEvent(new Event("finishMovie"));
				finishMovie();
			}
		}
		
		//繼承的類別可改寫,影片片段到最後影格後要做的動作
		protected function finishMovie():void { }
		
		public function get progressNum():int 
		{
			return _progressNum;
		}
		
		protected function kill(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, kill);
			state_mc.removeEventListener(MouseEvent.CLICK, thisClick);
			state_mc.removeEventListener(Event.ENTER_FRAME, goEnd);
			state_mc.stop();
			removeChild(state_mc);
			myLoader.unloadAndStop(true);
		}
		
		//關閉視窗
		private function closeWindow():void {
			navigateToURL(new URLRequest("javascript:window.opener=self; window.close();"), "_self");
		}
		
	}

}