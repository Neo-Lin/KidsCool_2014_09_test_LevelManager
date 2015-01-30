package 
{
	import citrus.core.CitrusEngine;
	import citrus.sounds.CitrusSoundGroup;
	import citrus.utils.AGameData;
	import flash.display.Loader;
	import flash.display.MovieClip;
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
	public class Main extends CitrusEngine 
	{
		private const DataName:String = "/ACT201409/Act201409.asp";
		private var Uldr:URLLoader;
		private var Ureq:URLRequest;
		private var Udata:URLVariables;
		private var tmpStr:String;
		private var tmpXML:XML;
		private var openCard:String;
		private var sendMode:int;
		private var loaderMC:MovieClip
		private var newLevel:int;
		
		private var myState:OpLoaderState;
		
		public function Main():void 
		{
			//取得flashvars的參數,是否直接進入集點卡
			openCard = root.loaderInfo.parameters.N;
			
			//sound.addSound("Jump", {sound:"sounds/jump.mp3", volume:3, group:CitrusSoundGroup.SFX}); //疊到
			//sound.addSound("Game1", {sound:"sounds/game1.mp3",loops:-1,group:CitrusSoundGroup.BGM}); //第一關背景音樂
			var _t:int;
			for (var i:int = 1; i <= 4; i++) {
				//變更所有關卡按鈕的狀態(開啟or未開啟)
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
			sound.addSound("indexBG", {sound:"sounds/indexBG.mp3", loops:-1, volume:.5});
			
			
			
			console.addCommand("fps", seeFps);
			
			//console.enabled = false;
			tabChildren = false;
			
			//取得外部資料
			loadData(0);
		}
		
		override protected function handlePlayingChange(value:Boolean):void {
			playing = true;
		}
		
		private function startInit():void {
			if (openCard == "card") {	//直接進入集點卡
				myState = new Card("swf/Card.swf");
				state = myState;
				myState.addEventListener("back_btn", goMenu);
			}else {
				loading();
				addEventListener("isProgress", showProgress);
				addEventListener("isComplete", showComplete);
			}
			
			
			/*myState = new Menu("swf/menu.swf");
			state = myState;
			myState.addEventListener("help_btn", goMenuHelp);
			myState.addEventListener("card_btn", goCard);
			myState.addEventListener("goGame", goGameHelp);*/
		}
		
		//loading畫面
		private function loading():void {
			var loader:Loader = new Loader();
			loader.load(new URLRequest("loading.swf"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, showLoading, false, 0, true);
		}
		private function showLoading(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, showLoading);
			loaderMC = e.target.loader.content;
			addChild(loaderMC);
			//loading畫面載入完畢,開始載入第一個State(index)
			myState = new OpLoaderState("swf/index.swf");
			myState.addEventListener("skip_btn", goIndexMv);
			state = myState;
			sound.playSound("indexBG");
		}
		//State載入完畢
		private function showComplete(e:Event):void 
		{
			loaderMC.visible = false;
		}
		//State載入中
		private function showProgress(e:Event):void 
		{
			loaderMC.visible = true;
			loaderMC.loading_bar.gotoAndStop(myState.progressNum);
			loaderMC.loading_txt.text = myState.progressNum;
		}
		
		//開場動畫
		private function goIndexMv(e:Event):void 
		{
			myState.removeEventListener("skip_btn", goIndexMv);
			myState = new OpLoaderState("swf/index_mv.swf");
			state = myState;
			myState.addEventListener("skip_btn", goMenuHelp);
			myState.addEventListener("finishMovie", goMenuHelp);
		}
		
		//活動說明
		private function goMenuHelp(e:Event):void 
		{
			myState.removeEventListener("skip_btn", goMenuHelp);
			myState.removeEventListener("finishMovie", goMenuHelp);
			myState.removeEventListener("help_btn", goMenuHelp);
			myState.removeEventListener("card_btn", goCard);
			myState.removeEventListener("goGame", goGameHelp);
			myState = new OpLoaderState("swf/menu_help.swf");
			state = myState;
			myState.addEventListener("skip_btn", goMenu);
			myState.addEventListener("finishMovie", goMenu);
		}
		
		//選單
		private function goMenu(e:Event):void 
		{	
			sound.stopSound("gameBG");
			if(!sound.soundIsPlaying("indexBG")) sound.playSound("indexBG");
			myState.removeEventListener("skip_btn", goMenu);
			myState.removeEventListener("finishMovie", goMenu);
			myState.removeEventListener("back_btn", goMenu);
			
			myState.removeEventListener("goMenu", goMenu);
			myState.removeEventListener("goHelp", goGameHelp);
			myState.removeEventListener("gamePass", goGamePass);
			
			myState = new Menu("swf/menu.swf");
			state = myState;
			myState.addEventListener("help_btn", goMenuHelp);
			myState.addEventListener("card_btn", goCard);
			if (gameData.l1_1_Score.length > 0) {
				myState.addEventListener("goGame", goGame);
			}else {
				myState.addEventListener("goGame", goGameHelp);
			}
		}
		
		private function goCard(e:Event):void 
		{
			loadData();
			myState.removeEventListener("help_btn", goMenuHelp);
			myState.removeEventListener("card_btn", goCard);
			myState.removeEventListener("goGame", goGameHelp);
			myState = new Card("swf/Card.swf");
			state = myState;
			myState.addEventListener("back_btn", goMenu);
			myState.addEventListener("sendPw", goSendPw);
		}
		private function goSendPw(e:Event):void 
		{	
			sendAsp("L=" + gameData.nowGame, 3);
		}
		
		//遊戲說明
		private function goGameHelp(e:Event):void 
		{
			sound.stopSound("indexBG");
			if(!sound.soundIsPlaying("gameBG")) sound.playSound("gameBG");
			myState.removeEventListener("help_btn", goMenuHelp);
			myState.removeEventListener("card_btn", goCard);
			myState.removeEventListener("goGame", goGameHelp);
			myState.removeEventListener("goGame", goGame);
			
			myState.removeEventListener("goMenu", goMenu);
			myState.removeEventListener("goHelp", goGameHelp);
			myState.removeEventListener("gamePass", goGamePass);
			myState = new OpLoaderState("swf/game_help.swf");
			state = myState;
			myState.addEventListener("skip_btn", goGame);
			myState.addEventListener("finishMovie", goGame);
		}
		
		//載入遊戲
		private function goGame(e:Event):void 
		{
			sound.stopSound("indexBG");
			if(!sound.soundIsPlaying("gameBG")) sound.playSound("gameBG");
			myState.removeEventListener("skip_btn", goGame);
			myState.removeEventListener("finishMovie", goGame);
			/*var loader:Loader = new Loader();
			loader.load(new URLRequest("swf/EliminateGame.swf"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, startGame, false, 0, true);*/
			myState = new EliminateGame("swf/EliminateGame.swf");
			state = myState;
			myState.addEventListener("goMenu", goMenu);
			myState.addEventListener("goHelp", goGameHelp);
			myState.addEventListener("gamePass", goGamePass);
		}
		
		//遊戲
		/*private function startGame(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, startGame);
			var gameMC:MovieClip = e.target.loader.content;
			state = new EliminateGame(gameMC);
			
			e.target.loader.unloadAndStop(true);
			
			gameMC.addEventListener("goMenu", goMenu);
			gameMC.addEventListener("goHelp", goGameHelp);
			gameMC.addEventListener("gamePass", goGamePass);
		}*/
		
		private function goGamePass(e:Event):void 
		{	
			myState.removeEventListener("goMenu", goMenu);
			myState.removeEventListener("goHelp", goGameHelp);
			myState.removeEventListener("gamePass", goGamePass);
			sendAsp("L=" + gameData.nowGame + "&S=" + gameData.score, 2);
			
		}
		
		private function seeFps():void 
		{
			addChild(new Stats());
		}
		
		//=================================asp=======================================
		//取得data,m=0:第一次進遊戲,m=1:無任何動作,m=2傳值完成之後
		private function loadData(m:int = 1):void {
			Uldr = new URLLoader();
			Ureq = new URLRequest(DataName);
			Udata = new URLVariables();
			
			sendMode = m;
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
			if (gameData) newLevel = gameData.newLevel;
			gameData = new AGameData();
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
			
			if (sendMode == 3) { //集點卡更新不需跳頁
				return;
			}else if (sendMode == 2) { //傳直給後端後
				goMenu(null);
			}else if (sendMode == 0){	//剛進入遊戲
				startInit();
			}
		}
		//傳值
		private function sendAsp(v:String,m:int):void {
			Uldr = new URLLoader();
			Ureq = new URLRequest(DataName);
			Udata = new URLVariables();
			
			sendMode = m;
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
			loadData(sendMode);
		}
	}
	
}