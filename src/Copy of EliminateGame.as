package  
{
	import caurina.transitions.Tweener;
	import citrus.core.State;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class EliminateGame extends State 
	{
		private var _objectsMC:MovieClip;
		private var _hTile:uint = 8;
		private var _wTile:uint = 8;
		private var _tileNameAll:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s"];
		private var _tileName:Array = [];
		private var _allTileArray:Array = new Array();
		private var _touchTile:Array = [];
		private var _addLineNum:int = 0;
		//檢查連線,有連線的Tile會存入
		private var _tArrayAllW:Array = [];
		private var _tArrayAllH:Array = [];
		private var _tweenerCount:int;
		private var _helpTile:Tile;
		private var _score:int;
		private var _scoreDouble:int = 1;	//計算分數加乘用
		//Tile的位置開始值&縮放比例
		private var _tileStartX:int = 54;
		private var _tileStartY:int = 134;
		private var _tileScale:Number = .232;
		//計算人物數量扣到零的人物
		private var _tilePeople:int = 0;
		//倒數計時
		private var _time:Timer = new Timer(1000, 1);
		private var _everyTime:int = 0;
		private var _lastTimeStatic:int = 0;
		private var _lastTime:int = 0;
		private var _barFrame:int = 180;	//時間條物件的影格數量
		//寶物數量
		private var _helpGlasses:int = 0;
		private var _helpTime:int = 0;
		private var _everyHelpTime:int = 0;
		//亂數Tile用
		private var _randomTileFrame:int = 0;
		//紀錄遊戲過關否
		private var _gamePass:Boolean = false;
		
		//各關卡目標人物
		private var _q:Array = [[, 3, 4, 5, 12, 13], 
								[, 3, 4, 5, 9, 10, 11], 
								[, 3, 4, 5, 6, 7, 8, 18], 
								[, 3, 4, 5, 14, 15, 16, 17, 19]];
		//各關卡目標人物數量
		private var _qn:Array = [6, 9, 12, 6, 9, 12, 6, 9, 12, 6, 9, 12];
		private var _qnArray:Array = [];
		
		public function EliminateGame(objectsMC:MovieClip) 
		{
			super();
			_objectsMC = objectsMC;
			
		}
		
		override public function initialize():void {
			super.initialize();
			
			addChild(_objectsMC);
			_time.addEventListener(TimerEvent.TIMER_COMPLETE, setTimer);
			addScore(0, _objectsMC); //分數歸零
			_objectsMC.glasses_btn.addEventListener(MouseEvent.MOUSE_OVER, helpIn);
			_objectsMC.glasses_btn.addEventListener(MouseEvent.MOUSE_OUT, helpOu);
			_objectsMC.glasses_btn.addEventListener(MouseEvent.CLICK, goHelpGlasses);
			_objectsMC.addTime_btn.addEventListener(MouseEvent.MOUSE_OVER, helpIn);
			_objectsMC.addTime_btn.addEventListener(MouseEvent.MOUSE_OUT, helpOu);
			_objectsMC.addTime_btn.addEventListener(MouseEvent.CLICK, goHelpTime);
			_objectsMC.panel_mc._mc.yes_btn.addEventListener(MouseEvent.CLICK, reStart);
			_objectsMC.panel_mc._mc.no_btn.addEventListener(MouseEvent.CLICK, goMenu);
			_objectsMC.panel_mc._mc.ok_btn.addEventListener(MouseEvent.CLICK, goPass);
			_objectsMC.goMenu_btn.addEventListener(MouseEvent.CLICK, goMenu);
			_objectsMC.help_btn.addEventListener(MouseEvent.CLICK, goHelp);
			
			initGameData();
			initGameTile();
			impasse();
		}
		
		private function initGameData():void {
			_time.start();
			_objectsMC.panel_mc.visible = false;
			
			//左邊的第一個目標要依據使用者的性別顯示
			_objectsMC["q1_mc"].gotoAndStop(1);
			if (_ce.gameData.sex == "boy") {
				_objectsMC["q1_mc"].p_mc.gotoAndStop(1);
				_qnArray[1] = _objectsMC["q1_mc"].n_mc;
				_tileName.push(_tileNameAll[0]);
			}else if (_ce.gameData.sex == "girl") {
				_objectsMC["q1_mc"].p_mc.gotoAndStop(2);
				_qnArray[2] = _objectsMC["q1_mc"].n_mc;
				_tileName.push(_tileNameAll[1]);
			}
			_objectsMC["q1_mc"].n_mc.showN(_qn[int(_ce.gameData.nowGame)-1]);
			_objectsMC["q1_mc"].n_mc.addEventListener("zero", goCheckPass);
			//其他目標,依據目前關卡變化不同的圖案&數量
			for (var q:int = 2; q <= 9; q++) {
				if (_ce.gameData.nowGame <= 3 && q <= _q[0].length) {	
					_objectsMC["q" + q + "_mc"].gotoAndStop(1);
					_objectsMC["q" + q + "_mc"].p_mc.gotoAndStop(_q[0][q - 1]);
					_objectsMC["q" + q + "_mc"].n_mc.showN(_qn[int(_ce.gameData.nowGame) - 1]);	//各人物數量,n_mc元件裡有程式碼
					_objectsMC["q" + q + "_mc"].n_mc.addEventListener("zero", goCheckPass);	//偵聽人物數量扣到零了
					_qnArray[_q[0][q - 1]] = _objectsMC["q" + q + "_mc"].n_mc;	//人物數量顯示的n_mc記錄在_qnArray裡跟影格一樣的位置
					_objectsMC["targetNum_mc"].gotoAndStop(q);	//目標數
					_tileName.push(_tileNameAll[_q[0][q - 1] - 1]);
					_lastTimeStatic = _lastTime = 90;
					_everyTime = 2;
					_helpGlasses = _helpTime = 3;
					_everyHelpTime = 10;
				}else if (_ce.gameData.nowGame > 3 && _ce.gameData.nowGame <= 6 && q <= _q[1].length) {
					_objectsMC["q" + q + "_mc"].gotoAndStop(1);
					_objectsMC["q" + q + "_mc"].p_mc.gotoAndStop(_q[1][q-1]);
					_objectsMC["q" + q + "_mc"].n_mc.showN(_qn[int(_ce.gameData.nowGame) - 1]);
					_objectsMC["q" + q + "_mc"].n_mc.addEventListener("zero", goCheckPass);
					_qnArray[_q[1][q - 1]] = _objectsMC["q" + q + "_mc"].n_mc;
					_objectsMC["targetNum_mc"].gotoAndStop(q);
					_tileName.push(_tileNameAll[_q[1][q - 1]-1]);
					_lastTimeStatic = _lastTime = 90;
					_everyTime = 2;
					_helpGlasses = _helpTime = 3;
					_everyHelpTime = 10;
				}else if (_ce.gameData.nowGame > 6 && _ce.gameData.nowGame <= 9 && q <= _q[2].length) {
					_objectsMC["q" + q + "_mc"].gotoAndStop(1);
					_objectsMC["q" + q + "_mc"].p_mc.gotoAndStop(_q[2][q-1]);
					_objectsMC["q" + q + "_mc"].n_mc.showN(_qn[int(_ce.gameData.nowGame)-1]);
					_objectsMC["q" + q + "_mc"].n_mc.addEventListener("zero", goCheckPass);
					_qnArray[_q[2][q - 1]] = _objectsMC["q" + q + "_mc"].n_mc;
					_objectsMC["targetNum_mc"].gotoAndStop(q);
					_tileName.push(_tileNameAll[_q[2][q - 1]-1]);
					_lastTimeStatic = _lastTime = 60;
					_everyTime = 3;
					_helpGlasses = _helpTime = 2;
					_everyHelpTime = 5;
				}else if (_ce.gameData.nowGame > 9 && q <= _q[3].length) {
					_objectsMC["q" + q + "_mc"].gotoAndStop(1);
					_objectsMC["q" + q + "_mc"].p_mc.gotoAndStop(_q[3][q-1]);
					_objectsMC["q" + q + "_mc"].n_mc.showN(_qn[int(_ce.gameData.nowGame) - 1]);	
					_objectsMC["q" + q + "_mc"].n_mc.addEventListener("zero", goCheckPass);
					_qnArray[_q[3][q - 1]] = _objectsMC["q" + q + "_mc"].n_mc;
					_objectsMC["targetNum_mc"].gotoAndStop(q);
					_tileName.push(_tileNameAll[_q[3][q - 1]-1]);
					_lastTimeStatic = _lastTime = 60;
					_everyTime = 3;
					_helpGlasses = _helpTime = 2;
					_everyHelpTime = 5;
				}else {
					_objectsMC["q" + q + "_mc"].visible = false;
				}
				
				_objectsMC.glasses_btn._mc.gotoAndStop(_helpGlasses);
				_objectsMC.glasses_btn.gotoAndStop(1);
				_objectsMC.addTime_btn._mc.gotoAndStop(_helpTime);
				_objectsMC.addTime_btn.gotoAndStop(1);
			}
			
		}
		
		//回選單
		private function goMenu(e:MouseEvent):void 
		{
			_objectsMC.dispatchEvent(new Event("goMenu"));
		}
		//遊戲說明
		private function goHelp(e:MouseEvent):void 
		{
			_objectsMC.dispatchEvent(new Event("goHelp"));
		}
		
		private function reStart(e:MouseEvent):void 
		{
			_tileName = [];
			_touchTile= [];
			_addLineNum= 0;
			_tArrayAllW = [];
			_tArrayAllH= [];
			_tweenerCount = 0;
			_scoreDouble = 1;	
			_tilePeople = 0;
			
			_objectsMC.time_bar.gotoAndStop(1);
			_objectsMC.clock_mc.gotoAndStop(1);
			
			_objectsMC.clock_mc.gotoAndStop(1);
			addScore(0, _objectsMC, "change");
			removeAllTile();
			initGameData();
			initGameTile();
			impasse();
		}
		
		private function removeAllTile():void {
			for (var i:int = 0; i < _hTile; i++) {
				for (var j:int = 0; j < _wTile; j++) {
					_objectsMC.removeChild(_allTileArray[i][j]);
				}
			}
		}
		
		private function initGameTile():void {
			for (var i:int = 0; i < _hTile; i++) {
				_allTileArray[i] = new Array();
				for (var j:int = 0; j < _wTile; j++) {
					var _t:Tile = new Tile();
					_t.scaleX = _t.scaleY = _tileScale;
					_allTileArray[i][j] = _t;
					
						//做出不會連線的初始組合
						do {
							_t.gotoAndStop(_tileName[Math.floor(Math.random() * _tileName.length)]);
							//如果是特殊技能就調整該技能的影格,並且隱藏普通大頭
							if (_t.skill == "bomb" || _t.skill == "lightning") {
								MovieClip(_t.skill_mc.getChildAt(0)).gotoAndStop(_t.currentFrameLabel);
								_t._mc.visible = false;
							}else if (_t.skill == "randomTile") {
								_t._mc.visible = false;
								_t.tileName = _tileName;	//指定array後自動開始跳影格
							}
							if(_t._mc) _t._mc.stop();
						}while (initChk(i, j)) 
					
					
					_objectsMC.addChild(_t);
					//_t.x = _tileStartX + (_t.width + 1.3) * j;
					//_t.y = _tileStartY + (_t.height + 1) * i;
					_t.x = _tileStartX + _t.width * j;
					_t.y = _tileStartY + _t.height * i;
					_t.name = i + "_" + j;
					_t.addEventListener(MouseEvent.MOUSE_DOWN, tileMD);
					_t.addEventListener(MouseEvent.MOUSE_UP, tileMU);
				}
			}
		}
		
		//倒數計時
		private function setTimer(e:TimerEvent):void 
		{
			_objectsMC.time_bar.gotoAndStop(_objectsMC.time_bar.currentFrame + _everyTime);
			_lastTime --;
			if (_lastTime > 0) {
				_time.start();
				if (_lastTime == 10) {
					_objectsMC.clock_mc.gotoAndStop(2); //鬧鐘跳
					chkLine(0);
				}
			}else {
				//trace("時間到!!!!!!!!!!!!!!!!!!!!!!!!");
				showPanel(13);
			}
		}
		
		//檢查是否過關
		private function goCheckPass(e:Event):void 
		{
			e.target.removeEventListener("zero", goCheckPass);
			//記錄亮的人頭影格
			var _f:int = e.target.parent.p_mc.currentFrame;
			//跳到暗的人頭並跳影格
			e.target.parent.gotoAndStop(2);
			e.target.parent.p_mc.gotoAndStop(_f);
			_tilePeople ++;
			if (_tilePeople == _objectsMC["targetNum_mc"].currentFrame) {
				trace("過關!!!!!!!!!!!!!!!!!!!!!!!!"); 
				_time.stop();
				//在addTile會檢查過關了沒,有過關就打開過關面板
				_gamePass = true;
			}
		}
		
		private function goPass(e:MouseEvent):void 
		{
			_objectsMC.dispatchEvent(new Event("gamePass"));
		}
		
		//顯示字卡
		private function showPanel(_frame:int):void {
			Tweener.pauseAllTweens();
			_objectsMC.panel_mc._mc.gotoAndStop(_frame);
			_objectsMC.panel_mc.visible = true;
			_objectsMC.setChildIndex(_objectsMC.panel_mc, _objectsMC.numChildren - 1);
			_objectsMC.panel_mc.gotoAndPlay(1);
			_objectsMC.mouseChildren = true;
		}
		
		//神奇眼鏡
		private function goHelpGlasses(e:MouseEvent):void 
		{
			if (_helpGlasses > 0) {
				_helpGlasses--;
				_helpTile.help_mc.play();
				if (_helpGlasses == 0) {
					_objectsMC.glasses_btn.gotoAndStop(4);
					_objectsMC.glasses_btn._mc.gotoAndStop(10);
				}else {
					_objectsMC.glasses_btn._mc.gotoAndStop(_helpGlasses);
				}
			}
		}
		//加時器
		private function goHelpTime(e:MouseEvent):void 
		{
			if (_helpTime > 0) {
				_helpTime--;
				if (_objectsMC.time_bar.currentFrame - _everyTime * _everyHelpTime < 0) {
					_lastTime = _lastTimeStatic;
					_objectsMC.time_bar.gotoAndStop(0);
				}else {
					_lastTime += _everyHelpTime;
					_objectsMC.time_bar.gotoAndStop(_objectsMC.time_bar.currentFrame - _everyTime * _everyHelpTime);
				}
				_ce.sound.playSound(_everyHelpTime + "s");
				if (_helpTime == 0) {
					_objectsMC.addTime_btn.gotoAndStop(4);
					_objectsMC.addTime_btn._mc.gotoAndStop(10);
				}else {
					_objectsMC.addTime_btn._mc.gotoAndStop(_helpTime);
				}
				chkLine(0);
			}	trace(_lastTime);
		}
		private function helpIn(e:MouseEvent):void 
		{	
			if (e.currentTarget.currentFrame < 4) {
				e.currentTarget.gotoAndStop(2);
				_ce.sound.playSound(e.currentTarget.name);
			}
		}
		private function helpOu(e:MouseEvent):void 
		{
			if (e.currentTarget.currentFrame < 4) {
				e.currentTarget.gotoAndStop(1);
				_ce.sound.stopSound(e.currentTarget.name);
			}
		}
		
		
		private function initChk(i:int, j:int):Boolean 
		{
			if (i > 1) {
				if(_allTileArray[i][j].currentFrameLabel == _allTileArray[i - 1][j].currentFrameLabel) {
					if(_allTileArray[i][j].currentFrameLabel == _allTileArray[i - 2][j].currentFrameLabel) {
						return true;
					}
				}
			}
			if (j > 1) {
				if(_allTileArray[i][j].currentFrameLabel == _allTileArray[i][j - 1].currentFrameLabel) {
					if(_allTileArray[i][j].currentFrameLabel == _allTileArray[i][j - 2].currentFrameLabel) {
						return true;
					}
				}
			}
			return false;
		}
		
		//使用者對調Tile
		private function tileMD(e:MouseEvent):void 
		{	
			//相同圖案的Tile全部消除的特殊技能(同色消除技能)
			if (e.currentTarget.skill == "randomTile") {
				e.currentTarget.stopRandom();
				_objectsMC.mouseChildren = false;
				for (var i:int = _allTileArray.length - 1; i >= 0; i--) {
					for (var j:int = _allTileArray[i].length - 1; j >= 0; j--) {
						if (_allTileArray[i][j].currentFrameLabel == e.currentTarget.skill_mc.randomTile_mc.currentFrameLabel
						&& _allTileArray[i][j].skill != "randomTile") {
							cleanLineTweener(_allTileArray[i][j]);
							addScore(20, _objectsMC);
						}
					}
				}
				//清除被按到的特殊技能Tile
				cleanLineTweener(e.currentTarget as Tile);
				if (_touchTile.length > 0) { //是否已選取了第一個圖案
					var _m:MovieClip = _objectsMC.getChildByName(_touchTile[0] + "_" + _touchTile[1]) as MovieClip;
					_m.select_mc.visible = false;
				}
				_touchTile.length = 0;
				return;
			}else {
				var _tmpAR:Array = e.currentTarget.name.split("_");
			}
			e.currentTarget._mc.gotoAndStop(2);
			if (_touchTile.length > 0) { //是否已選取了第一個圖案
				var _m:MovieClip = _objectsMC.getChildByName(_touchTile[0] + "_" + _touchTile[1]) as MovieClip;
				_m.select_mc.visible = false;
				//上下交換
				if ((_touchTile[0] == int(_tmpAR[0]) + 1 || _touchTile[0] == int(_tmpAR[0]) - 1) &&
				_touchTile[1] == _tmpAR[1]) {	
					//改變陣列中兩個圖案的位置
					_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, _m);
					_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, e.currentTarget);
					//改變畫面上兩個圖案的位置
					Tweener.addTween(e.currentTarget, { y:_m.y, time:.3 } );
					Tweener.addTween(_m, { y:e.currentTarget.y, time:.3, onComplete:function() {
						if (chkLine(2)) {
							//動畫結束後刪除連線的Tile
							cleanLine();
						}
						} } );
					//檢查是否達成連線
					if (chkLine(2)) {
						//修改交換的物件名稱,因為名稱要對應陣列位置,所以換位置就要換名字
						var _mName:String = _m.name;
						_m.name = e.currentTarget.name;
						e.currentTarget.name = _mName;
						//刪除連線的Tile
						//cleanLine();
					}else { //沒有達成連線,恢復原狀
						_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, e.currentTarget);
						_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, _m);
						Tweener.addTween(e.currentTarget, { y:e.currentTarget.y, time:.3, delay:.3 } );
						Tweener.addTween(_m, { y:_m.y, time:.3, delay:.3 } );
					}
				//左右交換
				}else if ((_touchTile[1] == int(_tmpAR[1]) + 1 || _touchTile[1] == int(_tmpAR[1]) - 1) &&
				_touchTile[0] == _tmpAR[0]) {	
					//改變陣列中兩個圖案的位置
					_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, _m);
					_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, e.currentTarget);
					//改變畫面上兩個圖案的位置
					Tweener.addTween(e.currentTarget, { x:_m.x, time:.3 } );
					Tweener.addTween(_m, { x:e.currentTarget.x, time:.3, onComplete:function() {
						if (chkLine(2)) {
							//動畫結束後刪除連線的Tile
							cleanLine();
						}
						} } );
					//檢查是否達成連線
					if (chkLine(2)) {
						//修改交換的物件名稱,因為名稱要對應陣列位置,所以換位置就要換名字
						var _mName:String = _m.name;
						_m.name = e.currentTarget.name
						e.currentTarget.name = _mName;
						//刪除連線的Tile
						//cleanLine();
					}else { //沒有達成連線,恢復原狀
						_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, e.currentTarget);
						_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, _m);
						Tweener.addTween(e.currentTarget, { x:e.currentTarget.x, time:.3, delay:.3 } );
						Tweener.addTween(_m, { x:_m.x, time:.3, delay:.3 } );
					}
				}else {
					//trace("不在旁邊");
				}
				e.currentTarget._mc.gotoAndStop(1);
				_m._mc.gotoAndStop(1);
				_touchTile.length = 0;
			}else {
				_touchTile = _tmpAR;
				e.currentTarget.select_mc.visible = true;
			}
		}
		
		//判斷要加多少分數
		private function countScore(cs:int, _x:Number = 0, _y:Number = 0):void {
			if (cs == 3) {	trace("分數計算:50 * " + _scoreDouble + " = " + 50 * _scoreDouble)
				addScore(50 * _scoreDouble, _objectsMC);
				showAddScoreMc(_x, _y, 50 * _scoreDouble);
			}else if (cs == 4) {	trace("分數計算:100 * " + _scoreDouble + " = " + 100 * _scoreDouble)
				addScore(100 * _scoreDouble, _objectsMC);
				showAddScoreMc(_x, _y, 100 * _scoreDouble);
			}else if (cs == 5) {	trace("分數計算:150 * " + _scoreDouble + " = " + 150 * _scoreDouble)
				addScore(150 * _scoreDouble, _objectsMC);
				showAddScoreMc(_x, _y, 150 * _scoreDouble);
			}
		}
		//加分並顯示
		private function addScore(s:int, _mc:DisplayObject, addOrChange:String = "add"):void {	trace("分數加 "+s+" 分::::");
			if (addOrChange == "add") {
				_score += s;
			}else if (addOrChange == "change") {
				_score = s;
			}
			//_objectsMC.score_txt.text = _score;
			//六位數的分數顯示
			var _a = String(_score).split("");
			var _an:int = _a.length;
			for (var i:int = 1; i <= 6; i++) {
				if (i <= _an) {
					var _n:int = int(_a.pop());
					if (_n == 0) _n = 10;
					_mc["score" + i + "_mc"].gotoAndStop(_n);
				}else {
					_mc["score" + i + "_mc"].gotoAndStop(10);
				}
			}
		}
		
		//刪除連線的Tile
		private function cleanLine():void {
			_objectsMC.mouseChildren = false;
			var bombSkillTile:Array = [];
			var lightningSkillTile:Array = [];
			//刪除橫向
			for (var wi:int = 0; wi < _tArrayAllW.length; wi++) {
				countScore(_tArrayAllW[wi].length, _tArrayAllW[wi][0].x, _tArrayAllW[wi][0].y);
				for each(var f:Tile in _tArrayAllW[wi]) {
					//怕跟直向有重複到所以多一道檢查,把直向陣列有重複的刪除
					/*for (var whi:int = 0; whi < _tArrayAllH.length; whi++) {
						if(_tArrayAllH[whi].indexOf(f)>-1){ trace("刪:", _tArrayAllH[whi].indexOf(f), f.name);
							_tArrayAllH[whi].splice(_tArrayAllH[whi].indexOf(f), 1);
						}
					}*/
					if (f.skill == "bomb") {
						bombSkillTile.push([f.name.charAt(0), f.name.charAt(2)]);
						showAddScoreMc(f.x, f.y, 300);
					}else if (f.skill == "lightning") {
						lightningSkillTile.push([f.name.charAt(0), f.name.charAt(2)]);
						showAddScoreMc(f.x, f.y, 500);
					}
					cleanLineTweener(f);
				}
			}
			//刪除直向
			for (var hi:int = 0; hi < _tArrayAllH.length; hi++) {
				countScore(_tArrayAllH[hi].length, _tArrayAllH[hi][0].x, _tArrayAllH[hi][0].y);
				for each(var f:Tile in _tArrayAllH[hi]) {
					//是否有爆炸技能
					if (f.skill == "bomb") {
						bombSkillTile.push([f.name.charAt(0), f.name.charAt(2)]);
						showAddScoreMc(f.x, f.y, 300);
					}else if (f.skill == "lightning") {
						lightningSkillTile.push([f.name.charAt(0), f.name.charAt(2)]);
						showAddScoreMc(f.x, f.y, 500);
					}
					cleanLineTweener(f);
				}
			}
			//刪除九宮格爆炸
			for (var i:int = 0; i < bombSkillTile.length; i++) {
				bomb(bombSkillTile[i][0], bombSkillTile[i][1]);
				addScore(300, _objectsMC);
			}
			//刪除閃電
			for (var i:int = 0; i < lightningSkillTile.length; i++) {
				lightning(lightningSkillTile[i][0], lightningSkillTile[i][1]);
				addScore(500, _objectsMC);
			}
		}
		
		//顯示加多少分數
		private function showAddScoreMc(_x:Number, _y:Number, _c:int):void 
		{
			var _s:AddScoreNumber = new AddScoreNumber();
			_s.x = _x;
			_s.y = _y;
			_s.showN(_c);
			addChild(_s);
		}
		
		//刪除閃電
		private function lightning(skillTile_h:int, skillTile_w:int):void 
		{
			for (var i:int = 0; i < _hTile; i++) {
				cleanLineTweener(_allTileArray[i][skillTile_w]);
			}
			for (var j:int = 0; j < _wTile; j++) {
				cleanLineTweener(_allTileArray[skillTile_h][j]);
			}
			//閃電效果
			var _b:LightningMv = new LightningMv();
			_b.x = _allTileArray[skillTile_h][skillTile_w].x;
			_b.y = _allTileArray[skillTile_h][skillTile_w].y;
			addChild(_b);
		}
		
		//九宮格爆炸
		private function bomb(skillTile_h:int, skillTile_w:int):void {
			var h1:int;
			var w1:int;
			var h2:int;
			var w2:int;
			//取得九宮格範圍
			if (skillTile_h > 0) {
				h1 = skillTile_h - 1;
			}else {
				h1 = skillTile_h;
			}
			if (skillTile_h < _hTile-1) {
				h2 = skillTile_h + 1;
			}else {
				h2 = skillTile_h;
			}
			if (skillTile_w > 0) {
				w1 = skillTile_w - 1;
			}else {
				w1 = skillTile_w;
			}
			if (skillTile_w < _wTile-1) {
				w2 = skillTile_w + 1;
			}else {
				w2 = skillTile_w;
			}
			//刪除範圍內的Tile
			for (h1; h1 <= h2; h1++) {
				for (var w:int = w1; w <= w2; w++) {	
					cleanLineTweener(_allTileArray[h1][w]);
				}
			}
			//爆破效果
			var _b:BombMv = new BombMv();
			_b.x = _allTileArray[skillTile_h][skillTile_w].x;
			_b.y = _allTileArray[skillTile_h][skillTile_w].y;
			addChild(_b);
		}
		
		private function cleanLineTweener(f:Tile):void {
			//略過達成連線而即將被刪除的Tile,因為tweener的關係刪除會延遲,因此多一個屬性判斷
			if (f.readyKill) {	//trace("略過", f.name);
				return;
			}
			_tweenerCount++;
			f.readyKill = true;
			f._mc.gotoAndStop(3);
			//減少右上角需消除的人物數量
			MovieClip(_qnArray[f.currentFrame]).changeNum(-1);
			Tweener.addTween(f, { alpha:0, time:.5, transition:"easeInBounce", onComplete:function() {
				_tweenerCount--;
				_objectsMC.removeChild(_allTileArray[this.name.charAt(0)][this.name.charAt(2)]);
				_allTileArray[this.name.charAt(0)][this.name.charAt(2)] = null;	
				rankTile();
				} } );
		}
		
		//排列Tile陣列
		private function rankTile():void {	
			var _n:int = 0;
			for (var i:int = _allTileArray.length-1; i >= 0; i--) {
				for (var j:int = _allTileArray[i].length - 1; j >= 0; j--) {
					if (_allTileArray[j][i] == null) {
						_n++;
					}else if (_n > 0 ) {
						_allTileArray[j + _n][i] = _allTileArray[j][i];
						_allTileArray[j][i] = null;
						Tweener.addTween(_allTileArray[j + _n][i], { y:_tileStartY + _allTileArray[j + _n][i].height * (j + _n), time:.5 } );
					}
				}
				_n = 0;
			}
			addTile();
		}
		
		//補滿Tile--編輯所有Tile的名字,對應Tile在_allTileArray裡的位置--檢查是否死棋
		private function addTile():void 
		{		
			//showMeAllTileArray();
			//trace("=============================================");
			for (var i:int = _allTileArray.length - 1; i >= 0; i--) {
				for (var j:int = _allTileArray[i].length - 1; j >= 0; j--) {
					if (!_allTileArray[i][j]) { 
						var _t:Tile = new Tile();
						_t.scaleX = _t.scaleY = .232;
						
							_t.gotoAndStop(_tileName[Math.floor(Math.random() * _tileName.length)]);
							//如果是特殊技能就調整該技能的影格,並且隱藏普通大頭
							if (_t.skill == "bomb" || _t.skill == "lightning") {
								MovieClip(_t.skill_mc.getChildAt(0)).gotoAndStop(_t.currentFrameLabel);
								_t._mc.visible = false;
							}else if (_t.skill == "randomTile") {
								_t._mc.visible = false;
								_t.tileName = _tileName;	//指定array後自動開始跳影格
							}
							if(_t._mc) _t._mc.stop();
						
						_objectsMC.addChild(_t);
						_t.x = _tileStartX + _t.width * int(j);
						_t.y = _tileStartY;
						//_t.x += 400; 
						_t.addEventListener(MouseEvent.MOUSE_DOWN, tileMD);
						_t.addEventListener(MouseEvent.MOUSE_UP, tileMU);
						_allTileArray[i][j] = _t;
					}
					_allTileArray[i][j].name = i + "_" + j;
				}
			}
			if (_tweenerCount == 0) {	trace("=====================檢查是否死棋");
				if (chkLine(2)) {
					_scoreDouble++;  //連鎖反應分數加乘
					cleanLine();
				}else {
					_scoreDouble = 1;  //分數加乘歸零
					//檢查是否死棋
					if (impasse() > 0) {
						_objectsMC.mouseChildren = true;
					}else {	//死棋,刷新所有Tile
						renewTile();
					}
					//如果過關了,等所有Tile靜止下來之後再打開過關面板
					if (_gamePass) {
						showPanel(_ce.gameData.nowGame);
						trace("過關分數:", _score, "  剩餘秒數:", _lastTime, "  總結分數:", _lastTime * 100 + _score);
						//剩餘時間加分
						addScore(_lastTime * 100, _objectsMC);
						//字卡裡的分數數字
						addScore(_score, _objectsMC.panel_mc._mc, "change");
						_ce.gameData.score = _score;
					}
				}
			}
			//showMeAllTileArray();
		}
		
		//亂數更新所有Tile的影格
		private function renewTile():void 
		{
			var _m:MovieClip;
			for (var i:int = 0; i < _hTile; i++) {
				for (var j:int = 0; j < _wTile; j++) {
					_m = _objectsMC.getChildByName(i + "_" + j) as MovieClip
					do{
						_m.gotoAndStop(_tileName[Math.floor(Math.random() * _tileName.length)]);
						if (_m._mc) _m._mc.stop();
					}while (initChk(i, j)) 
				}
			}	
			
			//檢查是否死棋
			if (impasse() > 0) {
				_objectsMC.mouseChildren = true;
			}else {
				renewTile();
			}
		}
		
		//檢查是否死棋
		private function impasse():int {
			var _i:int = 0;	//橫向
			var _j:int = 0;	//直向
			var _k:int = 0;	//十字
			var _n:int = 0;
			var h:int;
			var w:int;
			if (chkLine(1)) {
				//檢查橫向
				for (var wi:int = 0; wi < _tArrayAllW.length; wi++) {
					for each(var f:Tile in _tArrayAllW[wi]) {
						h = int(f.name.charAt(0));
						w = int(f.name.charAt(2));
						if (_n == 0) { 
							_n++;
							if (w - 2 >= 0 && _allTileArray[h][w - 2].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h][w - 2];
							}
							if (w - 1 >= 0 && h - 1 >= 0 && _allTileArray[h - 1][w - 1].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h - 1][w - 1];
							}
							if (w - 1 >= 0 && h + 1 <= _hTile-1 && _allTileArray[h + 1][w - 1].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h + 1][w - 1];
							}
						}else { 
							_n = 0;
							if (w + 2 <= _wTile-1 && _allTileArray[h][w + 2].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h][w + 2];
							}
							if (w + 1 <= _wTile-1 && h - 1 >= 0 && _allTileArray[h - 1][w + 1].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h - 1][w + 1];
							}
							if (w + 1 <= _wTile-1 && h + 1 <= _hTile-1 && _allTileArray[h + 1][w + 1].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h + 1][w + 1];
							}
						}
					}
				}
				//檢查直向
				for (var hi:int = 0; hi < _tArrayAllH.length; hi++) {
					for each(var f:Tile in _tArrayAllH[hi]) {
						h = int(f.name.charAt(0));
						w = int(f.name.charAt(2));
						if (_n == 0) { 
							_n++;
							if (h - 2 >= 0 && _allTileArray[h - 2][w].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h - 2][w];
							}
							if (h - 1 >= 0 && w - 1 >= 0 && _allTileArray[h - 1][w - 1].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h - 1][w - 1];
							}
							if (h - 1 >= 0 && w + 1 <= _wTile-1 && _allTileArray[h - 1][w + 1].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h - 1][w + 1];
							}
						}else { 
							_n = 0;
							if (h + 2 <= _hTile-1 && _allTileArray[h + 2][w].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h + 2][w];
							}
							if (h + 1 <= _hTile-1 && w - 1 >= 0 && _allTileArray[h + 1][w - 1].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h + 1][w - 1];
							}
							if (h + 1 <= _hTile-1 && w + 1 <= _wTile-1 && _allTileArray[h + 1][w + 1].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h + 1][w + 1];
							}
						}
					}
				}
			}
			//檢查十字
			for (var wi:int = 0; wi < _allTileArray.length; wi++) {
				for each(var f:Tile in _allTileArray[wi]) {
					h = int(f.name.charAt(0));
					w = int(f.name.charAt(2));
					//十字無論如何都會檢查,所以只要有"同色消除技能"的Tile,就直接指定為"提示"功能要顯示的Tile
					/*if (_allTileArray[h][w].skill == "randomTile") {
						_helpTile = _allTileArray[h][w];
						return 1;
					}*/
					var _a:String = "";
					var _l:String; //用來判斷少一邊的十字(因為靠牆所以只有三個)
					//紀錄每個Tile上下左右的影格標籤
					if (h - 1 >= 0) {
						_a+=_allTileArray[h - 1][w].currentFrameLabel;
					}else {
						_l = "h1"; //沒有上方的Tile
					}
					if (h + 1 <= _hTile-1) {
						_a+=_allTileArray[h + 1][w].currentFrameLabel;
					}else {
						_l = "h2";
					}
					if (w - 1 >= 0) {
						_a+=_allTileArray[h][w - 1].currentFrameLabel;
					}else {
						_l = "w1"; //沒有左邊的Tile
					}
					if (w + 1 <= _wTile-1) {
						_a += _allTileArray[h][w + 1].currentFrameLabel;
					} else {
						_l = "w2";
					}
					//檢查有沒有兩個以上重複的影格標籤,有就成立
					for (var e:int = 0; e < _tileName.length; e++) {
						var pattern:RegExp = new RegExp(_tileName[e],"g"); 
						if (_a.match(pattern).length > 2) {
							_k++;	
							if (_a.charAt(0) != _tileName[e]) {
								_helpTile = _allTileArray[h + 1][w];
							}else if (_a.charAt(1) != _tileName[e]) {
								_helpTile = _allTileArray[h - 1][w];
							}else if (_a.charAt(2) != _tileName[e]) {
								_helpTile = _allTileArray[h][w + 1];
							}else if(_a.length == 3 && _l == "h1"){ //靠在上方所以沒有上面,所以一定是下面的Tile可以移動
								_helpTile = _allTileArray[h + 1][w];
							}else if(_a.length == 3 && _l == "h2"){
								_helpTile = _allTileArray[h - 1][w];
							}else if(_a.length == 3 && _l == "w1"){ //靠在左方所以沒有左邊,所以一定是右邊的Tile可以移動
								_helpTile = _allTileArray[h][w + 1];
							}else if(_a.length == 3 && _l == "w2"){
								_helpTile = _allTileArray[h][w - 1];
							}else {
								_helpTile = _allTileArray[h][w - 1];
							}
							break;
						}
					}
				}
			}
			trace("檢查死路-橫:", _i, "檢查死路-直:", _j, "檢查死路-十字:", _k);
			return _i + _j + _k;
		}
		
		//檢查是否有連線
		private function chkLine(tileNum:int):Boolean {
			var _t:MovieClip;
			var _tArray:Array = [];
			_tArrayAllW = [];
			_tArrayAllH = [];
			//檢查橫向
			for (var i:uint = 0; i < _allTileArray.length; i++) {
				for (var j:uint = 0; j < _allTileArray[i].length; j++) {
					//若Tile有"同色消除技能"就跳過
					if (_allTileArray[i][j].skill == "randomTile") {
						_t = null;
						if (_tArray.length > tileNum) {
							_tArrayAllW.push(_tArray);
						}
						continue;
					}
					if (_t) {
						//若跟上一個相同
						if (_t.currentFrameLabel == _allTileArray[i][j].currentFrameLabel) {
							_tArray.push(_allTileArray[i][j]);
						}else {
							if (_tArray.length > tileNum) {
								_tArrayAllW.push(_tArray);
							}
							_t = _allTileArray[i][j];
							_tArray = [_t];
						}
					}else {
						_t = _allTileArray[i][j];
						_tArray = [_t];
					}
					//倒數十秒抖抖抖
					if (_lastTime <= 10) {
						_t._mc.gotoAndStop(3);
					}else {
						_t._mc.gotoAndStop(1);
					}
				}
				_t = null;
				if (_tArray.length > tileNum) {
					_tArrayAllW.push(_tArray);
				}
			}
			//trace("_tArrayAllW:",_tArrayAllW);
			//檢查直向
			_tArray = [];
			for (var k:uint = 0; k < _allTileArray.length; k++) {
				for (var m:uint = 0; m < _allTileArray[k].length; m++) {
					//若Tile有"同色消除技能"就跳過
					if(_allTileArray[m][k].skill == "randomTile") {
						_t = null;
						if (_tArray.length > tileNum) {
							_tArrayAllW.push(_tArray);
						}
						continue;
					}
					if (_t) {
						//若跟上一個相同
						if (_t.currentFrameLabel == _allTileArray[m][k].currentFrameLabel) {
							_tArray.push(_allTileArray[m][k]);
						}else {
							if (_tArray.length > tileNum) {
								_tArrayAllH.push(_tArray);
							}
							_t = _allTileArray[m][k];
							_tArray = [_t];
						}
					}else {
						_t = _allTileArray[m][k];
						_tArray = [_t];
					}
					//倒數十秒抖抖抖
					if (_lastTime <= 10) {
						_t._mc.gotoAndStop(3);
					}else {
						_t._mc.gotoAndStop(1);
					}
				}
				_t = null;
				if (_tArray.length > tileNum) {
					_tArrayAllH.push(_tArray);
				}
			}
			//trace("_tArrayAllH:",_tArrayAllH);
			
			if (_tArrayAllW.length > 0 || _tArrayAllH.length > 0) {
				return true;
			}else {
				return false;
			}
		}
		
		//印出_allTileArray
		private function showMeAllTileArray():void {
			var _s:String = "";
			for each(var af:Array in _allTileArray) {
				for each(var f in af) {
					if (f) { 
						_s += f.name += "   ";
					}else {
						_s += f += "                ";
					}
				}
				trace(" ");
				trace(_s);
				_s = "";
			}
		}
		
		private function tileMU(e:MouseEvent):void 
		{
			
		}
		
	}

}