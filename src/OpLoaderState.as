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
	
	/**
	 * ...載入遊戲動畫及說明等
	 * 各個場景都可以繼承這個類別,傳入url就會自動載入
	 * 複寫onComplete及thisClick就可控制場景
	 * @author Neo
	 */
	public class OpLoaderState extends State 
	{
		protected var myLoader:Loader = new Loader();
		protected var state_mc:MovieClip;
		private var _progressNum:int;
		
		public function OpLoaderState(_url:String) 
		{
			super();
			addEventListener(Event.REMOVED_FROM_STAGE, kill);
			myLoader.contentLoaderInfo.addEventListener(Event.INIT, initHandle);
			myLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandle);
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			myLoader.load(new URLRequest(_url));
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
		
		override public function initialize():void {
			super.initialize();
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
		
		protected function thisClick(e:Event):void 
		{	trace("OpLoaderState.thisClick:", e.target.name);
			//傳出被按下的物件名字
			dispatchEvent(new Event(e.target.name));
			
			if (e.target.name == "close_btn") { //關閉遊戲
				closeWindow();
			}
		}
		
		protected function goEnd(e:Event):void 
		{	//trace("OpLoaderState.goEnd:", this.name);
			//影格播完(最後一格)傳出訊息
			if (state_mc.currentFrame == state_mc.totalFrames) {
				//trace("自動事件");
				state_mc.removeEventListener(Event.ENTER_FRAME, goEnd);
				dispatchEvent(new Event("finishMovie"));
			}
		}
		
		//關閉視窗
		private function closeWindow():void {
			navigateToURL(new URLRequest("javascript:window.opener=self; window.close();"), "_self");
		}
		
		protected function kill(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, kill);
			state_mc.removeEventListener(MouseEvent.CLICK, thisClick);
			state_mc.removeEventListener(Event.ENTER_FRAME, goEnd);
			myLoader.unloadAndStop(true);
		}
		
		public function get progressNum():int 
		{
			return _progressNum;
		}
		
	}

}