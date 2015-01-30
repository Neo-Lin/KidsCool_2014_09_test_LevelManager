package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Neo
	 */
	public class Menu extends ALevel 
	{
		
		public function Menu(level:XML = null) 
		{
			super(level);
		}
		
		//場景載入完畢
		override protected function onComplete(e:Event):void 
		{
			super.onComplete(e);
			//使用者資料
			state_mc.user_mc.name_txt.text = _ce.gameData.userName;
			state_mc.integra_mc.integral_txt.text = _ce.gameData.integral;
			state_mc.integra_mc.rank_txt.text = _ce.gameData.rank;
			state_mc.top_mc.topIntegral_txt.text = _ce.gameData.topIntegral;
			state_mc.top_mc.topIntegralName_txt.text = _ce.gameData.topIntegralName;
			
			//關卡的title(依xml的日期決定開啟or未開啟)
			MovieClip(state_mc.getChildByName("level1_mc")).gotoAndStop(2);
			if (_ce.gameData.today > 20140908) {
				MovieClip(state_mc.getChildByName("level2_mc")).gotoAndStop(2);
				if (_ce.gameData.today > 20140915) {
					MovieClip(state_mc.getChildByName("level3_mc")).gotoAndStop(2);
					if (_ce.gameData.today > 20140922) {
						MovieClip(state_mc.getChildByName("level4_mc")).gotoAndStop(2);
					}
				}
			}
				
			var _t:int;
			for (var i:int = 1; i <= 4; i++) {
				//變更所有關卡按鈕的狀態(開啟or未開啟)
				for (var j:int = 1; j <= 3; j++) {
					var _mc:MovieClip = state_mc.getChildByName("l" + i + "_" + j + "_btn") as MovieClip;
					_t++;
					_mc.levelNumber_mc.gotoAndStop(_t);
					
					//大關卡開啟後自動開第一小關 || 目前關卡有分數表示開啟並且過關
					if (state_mc["level" + i + "_mc"].currentFrame == 2 && j == 1 || _ce.gameData["l" + i + "_" + j + "_Score"].length > 0) {
						_mc.gotoAndStop(2);
						_mc.btn_mc.gotoAndStop(1);
						_mc.btn_mc.buttonMode = true;
						//?-?數字
						_mc.btn_mc.levelNumber_mc.gotoAndStop(_t);
						_mc.btn_mc.addEventListener(MouseEvent.MOUSE_OVER, mIn);
						_mc.btn_mc.addEventListener(MouseEvent.MOUSE_OUT, mOut);
						_mc.btn_mc.addEventListener(MouseEvent.CLICK, mClick);
						//判斷過關沒
						if (_ce.gameData["l" + i + "_" + j + "_Score"].length > 0) {
							//過關圖示&小面板
							_mc.passMv_mc.visible = true;
							if (_ce.gameData.newLevel != _t) _mc.passMv_mc.gotoAndStop(_mc.passMv_mc.totalFrames);
							_mc.pass_mc.visible = false;
							_mc.pass_mc.topScore_txt.text = _ce.gameData["l" + i + "_" + j + "_TopScore"]
							_mc.pass_mc.score_txt.text = _ce.gameData["l" + i + "_" + j + "_Score"]
						}
					}
					
					//上一小關過關就開啟這一小關
					if (j > 1) {
						if (_ce.gameData["l" + i + "_" + (j - 1) + "_Score"].length > 0) {
							_mc.gotoAndStop(2);
							_mc.btn_mc.gotoAndStop(1);
							_mc.btn_mc.buttonMode = true;
							//?-?數字
							_mc.btn_mc.levelNumber_mc.gotoAndStop(_t);
							_mc.btn_mc.addEventListener(MouseEvent.MOUSE_OVER, mIn);
							_mc.btn_mc.addEventListener(MouseEvent.MOUSE_OUT, mOut);
							_mc.btn_mc.addEventListener(MouseEvent.CLICK, mClick);
						}
					}
				}
			}
		}
		
		private function mClick(e:MouseEvent):void 
		{
			_ce.gameData.nowGame = e.currentTarget.levelNumber_mc.currentFrame;
			//dispatchEvent(new Event("goGame"));
			lvlJumpTo.dispatch(6);
		}
		private function mOut(e:MouseEvent):void 
		{
			e.currentTarget.gotoAndStop(1);
			e.currentTarget.parent.pass_mc.visible = false;
			_ce.sound.stopSound("l"+e.currentTarget.levelNumber_mc.currentFrame);
		}
		private function mIn(e:MouseEvent):void 
		{
			e.currentTarget.gotoAndStop(2);
			if (e.currentTarget.parent.passMv_mc.visible) e.currentTarget.parent.pass_mc.visible = true;
			_ce.sound.playSound("l"+e.currentTarget.levelNumber_mc.currentFrame);
		}
		
		override protected function thisClick(e:Event):void 
		{	
			super.thisClick(e);
			
			if (e.target.name == "card_btn") { //
				lvlJumpTo.dispatch(0);
			}
		}
	}

}