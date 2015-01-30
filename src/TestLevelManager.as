package  
{
	import citrus.core.CitrusEngine;
	import citrus.core.IState;
	import citrus.utils.AGameData;
	import citrus.utils.LevelManager;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import net.hires.debug.Stats;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class TestLevelManager extends CitrusEngine 
	{
		private const DataName:String = "/ACT201409/Act201409.asp";
		private var Uldr:URLLoader;
		private var Ureq:URLRequest;
		private var Udata:URLVariables;
		private var tmpStr:String;
		private var tmpXML:XML;
		private var openCard:String;
		private var newLevel:int;
		private var gotoLevel:uint = 1;
		
		public function TestLevelManager() 
		{
			//取得flashvars的參數,是否直接進入集點卡
			openCard = root.loaderInfo.parameters.N;
			
			//sound.addSound("Jump", {sound:"sounds/jump.mp3", volume:3, group:CitrusSoundGroup.SFX}); //疊到
			//sound.addSound("Game1", {sound:"sounds/game1.mp3",loops:-1,group:CitrusSoundGroup.BGM}); //第一關背景音樂
			var _t:int;
			for (var i:int = 1; i <= 4; i++) {
				//設定所有關卡按鈕的聲音
				for (var j:int = 1; j <= 3; j++) {
					_t++;
					sound.addSound("l" + _t, {sound:"sounds/" + i + "-" + j + ".mp3"});
				}
			}
			sound.addSound("addTime_btn", {sound:"sounds/helpTime.mp3"});
			sound.addSound("glasses_btn", {sound:"sounds/helpGlasses.mp3"});
			sound.addSound("5s", {sound:"sounds/5s.mp3"});
			sound.addSound("10s", {sound:"sounds/10s.mp3"});
			sound.addSound("tile1", {sound:"sounds/tile1.mp3", volume:.7});
			sound.addSound("tile2", {sound:"sounds/tile2.mp3", volume:.8});
			sound.addSound("tile3", {sound:"sounds/tile3.mp3", volume:.9});
			sound.addSound("tile4", {sound:"sounds/tile4.mp3"});
			sound.addSound("tile5", {sound:"sounds/tile5.mp3"});
			sound.addSound("bomb", {sound:"sounds/bomb.mp3"});
			sound.addSound("lightning", {sound:"sounds/lightning.mp3"});
			sound.addSound("randomTile", {sound:"sounds/randomTile.mp3"});
			sound.addSound("card", {sound:"sounds/card.mp3"});
			sound.addSound("changeTile", {sound:"sounds/changeTile.mp3"});
			sound.addSound("gameLose", {sound:"sounds/gameLose.mp3"});
			sound.addSound("gameLoseT", {sound:"sounds/gameLoseT.mp3"});
			sound.addSound("gamePass", {sound:"sounds/gamePass.mp3"});
			sound.addSound("timePayScore", {sound:"sounds/timePayScore.mp3", volume:.3});
			sound.addSound("timeOut", {sound:"sounds/timeOut.mp3", loops:-1});
			sound.addSound("gameBG", {sound:"sounds/gameBG.mp3", loops:-1, volume:.5});
			sound.addSound("indexBG", { sound:"sounds/indexBG.mp3", loops: -1, volume:.5 } );
			
			console.addCommand("fps", seeFps);
			
			//console.enabled = false;
			tabChildren = false;
			
			//取得外部資料
			loadData();
			
			gameData = new AGameData();
			//關閉指定不同型態的警告,由xml給值之後它會自動轉成文字或數字等型態,第二次要再從xml給值時它會判斷為xml值XMLList,型態就不同會錯誤.
			gameData.typeVerification = false;
			
			var _xml:XML = new XML("<swf><swfurl>swf/index.swf</swfurl><swfurl>swf/index_mv.swf</swfurl><swfurl>swf/menu_help.swf</swfurl><swfurl>swf/menu.swf</swfurl><swfurl>swf/Card.swf</swfurl><swfurl>swf/EliminateGame.swf</swfurl></swf>");
			
			levelManager = new LevelManager(ALevel);
			//levelManager.applicationDomain = ApplicationDomain.currentDomain; // to be able to load your SWF level on iOS
			//levelManager.enableSwfCaching = true;
			levelManager.onLevelChanged.add(_onLevelChanged);
			//levelManager可以直接給swf檔它會自己載入很方便,可是他沒辦法偵聽載入進度,所以只好傳入xml(不能直接傳String),再自己載入
			levelManager.levels = [[OnlyAnimation, _xml.swfurl[0]], [OnlyAnimation, _xml.swfurl[1]], [OnlyAnimation, _xml.swfurl[2]], [Menu, _xml.swfurl[3]], [Card, _xml.swfurl[4]], [EliminateGame, _xml.swfurl[5]]];
			//levelManager.gotoLevel(); //load the first level, you can change the index. You can also call it later.
		}
		
		private function _onLevelChanged(lvl:ALevel):void {
		 
			state = lvl;
		 
			lvl.lvlEnded.addOnce(_nextLevel);
			lvl.lvlJumpTo.addOnce(_jumpLevel);
			lvl.restartLevel.addOnce(_restartLevel);
		}
		
		private function _jumpLevel(_i:uint):void 
		{
			//先紀錄下一個要去的場景,Data更新之後再載入
			gotoLevel = _i;
			loadData();
		}
		private function _nextLevel():void {
			levelManager.nextLevel();
		}
		private function _restartLevel():void {
			state = levelManager.currentLevel as IState;
		}
		
		
		private function seeFps():void 
		{
			addChild(new Stats());
		}
		
		//=================================asp=======================================
		//取得data
		private function loadData():void {
			Uldr = new URLLoader();
			Ureq = new URLRequest(DataName);
			Udata = new URLVariables();
			
			tmpStr = "mode=1&Date=" + new Date().time;
			Udata.decode(tmpStr);
			Ureq.data = Udata;
			//trace("playerType:", Capabilities.playerType);
			Uldr.addEventListener(Event.COMPLETE, DataLoaded);
			if (Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone") {
				Uldr.load(new URLRequest('Act201409.xml'));
			} else {
				Uldr.load(Ureq);
			}
		}
		//Data載入完成
		private function DataLoaded(e:Event):void {
			e.currentTarget.removeEventListener(Event.COMPLETE, DataLoaded);
			//=============取得資料==============;
			tmpXML = new XML(e.currentTarget.data);
			//trace(tmpXML);
			gameData.today = tmpXML["Today"];
			gameData.userName = tmpXML["Name"];
			if (tmpXML["Sex"] == 1) {
				gameData.sex = "boy";
			}else {
				gameData.sex = "girl";
			}
			gameData.topIntegral = tmpXML["TopIntegral"];
			gameData.topIntegralName = tmpXML["TopIntegralName"];
			gameData.integral = tmpXML["Integral"];
			gameData.rank = tmpXML["Rank"];
			gameData.l1_1_Score = tmpXML["Level1"].g[0].@Score.toString();
			gameData.l1_1_TopScore = tmpXML["Level1"].g[0].@topScore.toString();
			gameData.l1_1_Points = tmpXML["Level1"].g[0].@Points.toString();
			gameData.l1_2_Score = tmpXML["Level1"].g[1].@Score.toString();
			gameData.l1_2_TopScore = tmpXML["Level1"].g[1].@topScore.toString();
			gameData.l1_2_Points = tmpXML["Level1"].g[1].@Points.toString();
			gameData.l1_3_Score = tmpXML["Level1"].g[2].@Score.toString();
			gameData.l1_3_TopScore = tmpXML["Level1"].g[2].@topScore.toString();
			gameData.l1_3_Points = tmpXML["Level1"].g[2].@Points.toString();
			gameData.l2_1_Score = tmpXML["Level2"].g[0].@Score.toString();
			gameData.l2_1_TopScore = tmpXML["Level2"].g[0].@topScore.toString();
			gameData.l2_1_Points = tmpXML["Level2"].g[0].@Points.toString();
			gameData.l2_2_Score = tmpXML["Level2"].g[1].@Score.toString();
			gameData.l2_2_TopScore = tmpXML["Level2"].g[1].@topScore.toString();
			gameData.l2_2_Points = tmpXML["Level2"].g[1].@Points.toString();
			gameData.l2_3_Score = tmpXML["Level2"].g[2].@Score.toString();
			gameData.l2_3_TopScore = tmpXML["Level2"].g[2].@topScore.toString();
			gameData.l2_3_Points = tmpXML["Level2"].g[2].@Points.toString();
			gameData.l3_1_Score = tmpXML["Level3"].g[0].@Score.toString();
			gameData.l3_1_TopScore = tmpXML["Level3"].g[0].@topScore.toString();
			gameData.l3_1_Points = tmpXML["Level3"].g[0].@Points.toString();
			gameData.l3_2_Score = tmpXML["Level3"].g[1].@Score.toString();
			gameData.l3_2_TopScore = tmpXML["Level3"].g[1].@topScore.toString();
			gameData.l3_2_Points = tmpXML["Level3"].g[1].@Points.toString();
			gameData.l3_3_Score = tmpXML["Level3"].g[2].@Score.toString();
			gameData.l3_3_TopScore = tmpXML["Level3"].g[2].@topScore.toString();
			gameData.l3_3_Points = tmpXML["Level3"].g[2].@Points.toString();
			gameData.l4_1_Score = tmpXML["Level4"].g[0].@Score.toString();
			gameData.l4_1_TopScore = tmpXML["Level4"].g[0].@topScore.toString();
			gameData.l4_1_Points = tmpXML["Level4"].g[0].@Points.toString();
			gameData.l4_2_Score = tmpXML["Level4"].g[1].@Score.toString();
			gameData.l4_2_TopScore = tmpXML["Level4"].g[1].@topScore.toString();
			gameData.l4_2_Points = tmpXML["Level4"].g[1].@Points.toString();
			gameData.l4_3_Score = tmpXML["Level4"].g[2].@Score.toString();
			gameData.l4_3_TopScore = tmpXML["Level4"].g[2].@topScore.toString();
			gameData.l4_3_Points = tmpXML["Level4"].g[2].@Points.toString();
			gameData.newLevel = newLevel;
			
			//Data更新之後再載入下一個場景
			if (gotoLevel > 0) {
				levelManager.gotoLevel(gotoLevel);
			}else {
				levelManager.nextLevel();
			}
		}
		//傳值
		private function sendAsp(v:String,m:int):void {
			Uldr = new URLLoader();
			Ureq = new URLRequest(DataName);
			Udata = new URLVariables();
			
			tmpStr = "mode=" + m + "&" + v + "&Date=" + new Date().time;
			Udata.decode(tmpStr);
			Ureq.data = Udata;
			//trace("playerType:", Capabilities.playerType);
			Uldr.addEventListener(Event.COMPLETE, DataSend);
			if (Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone") {
				Uldr.load(new URLRequest('Act201409.xml'));
			} else {
				Uldr.load(Ureq);
			}
		}
		//傳值完成更新Data
		private function DataSend(e:Event):void 
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, DataSend);
			loadData();
		}
	}

}