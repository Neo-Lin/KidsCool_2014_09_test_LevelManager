package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Neo
	 */
	public class Card extends ALevel 
	{
		private var _pw:Array = [, 
								[, 6145, 3004, 1269], 
								[, 9632, 3321, 4213], 
								[, 8741, 8125, 8457],
								[, 5986, 2654, 3564]];
		private var _p:int = 0;	//計算幾點了
		
		public function Card(level:XML = null) 
		{
			super(level);
		}
		
		//場景載入完畢
		override protected function onComplete(e:Event):void 
		{
			super.onComplete(e);
			
			//隱藏字卡
			state_mc.panel_mc.visible = false;
			for (var i:int = 1; i <= 4; i++) {
				for (var j:int = 1; j <= 3; j++) {
					//隱藏"已找到"動畫
					state_mc.pass_mc.visible = false;
					state_mc["pass" + i + "_" + j + "_mc"].visible = false;
					//計算拿到幾點點數
					_p += int(_ce.gameData["l" + i + "_" + j + "_Points"]);
					//已過關,開啟密碼輸入框
					if (_ce.gameData["l" + i + "_" + j + "_Score"].length > 0) {
						state_mc["l" + i + "_" + j + "_mc"].gotoAndStop(2);
						state_mc["l" + i + "_" + j + "_mc"].enter_mc.gotoAndStop(2);
						//已輸入並取得點數了
						if (_ce.gameData["l" + i + "_" + j + "_Points"] == 1) {
							state_mc["l" + i + "_" + j + "_mc"].gotoAndStop(3);
							state_mc["pass" + i + "_" + j + "_mc"].visible = true;
							state_mc["pass" + i + "_" + j + "_mc"].gotoAndStop(state_mc["pass" + i + "_" + j + "_mc"].totalFrames);
						}
					}
				}
			}
			
			//顯示名字&累計點數
			state_mc.user_mc.name_txt.text = _ce.gameData.userName;
			if (_p < 10) {	//單數字前要加0
				state_mc.user_mc.points_txt.text = "0" + _p;
			}else {
				state_mc.user_mc.points_txt.text = _p;
			}
			if (_p == 12) {
				state_mc.pass_mc.visible = true;
				state_mc.pass_mc.gotoAndStop(3);
				state_mc.pass_mc.gotoAndStop(state_mc.pass_mc.totalFrames);
				_p++;
				state_mc.user_mc.points_txt.text = _p;
			}
		}
		
		override protected function thisClick(e:Event):void 
		{	
			super.thisClick(e);
			
			if (e.target.name == "input_txt") { //輸入密碼
				e.target.text = "";
			}else if (e.target.name == "enter_btn") { //送出密碼
				//trace(e.target.parent.parent.input_txt.text, e.target.parent.parent.name);
				var i:int = int(e.target.parent.parent.name.slice(1, 2));
				var j:int = int(e.target.parent.parent.name.slice(3, 4));
				//檢查密碼正確就送出
				if (e.target.parent.parent.input_txt.text == _pw[i][j]) {
					_ce.sound.playSound("card");
					e.target.parent.parent.gotoAndStop(3);
					state_mc["pass" + i + "_" + j + "_mc"].visible = true;
					state_mc["pass" + i + "_" + j + "_mc"].gotoAndPlay(1);
					_p ++;
					//點數加總
					if (_p < 10) {	//單數字前要加0
						state_mc.user_mc.points_txt.text = "0" + _p;
					}else {
						state_mc.user_mc.points_txt.text = _p;
					}
					//判斷集滿12點了沒
					if (_p == 12) {
						state_mc.panel_mc._mc.gotoAndStop(2);
						state_mc.panel_mc.visible = true;
						state_mc.panel_mc.gotoAndPlay(1);
					}
					_ce.gameData.nowGame = 3 * (i - 1) + j;
					dispatchEvent(new Event("sendPw"));
				}else {	//密碼錯誤
					state_mc.panel_mc._mc.gotoAndStop(3);
					state_mc.panel_mc.visible = true;
					state_mc.panel_mc.gotoAndPlay(1);
				}
			}else if (e.target.name == "ok_btn") {
				state_mc.panel_mc.visible = false;
				state_mc.pass_mc.visible = true;
				state_mc.pass_mc.gotoAndPlay(1);
				_p++;
				state_mc.user_mc.points_txt.text = _p;
			}else if (e.target.name == "er_ok_btn") {
				state_mc.panel_mc.visible = false;
				state_mc.panel_mc._mc.gotoAndStop(1);
			}else if (e.target.name == "back_btn") {
				lvlJumpTo.dispatch(4);
			}
		}
	}

}