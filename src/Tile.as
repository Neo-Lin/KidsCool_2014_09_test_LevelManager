package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Tile extends MovieClip 
	{
		public static const BOMB:String = "bomb";
		public static const LIGHTNING:String = "lightning";
		public static const RANDOM_TILE:String = "randomTile";
		
		public var select_mc:MovieClip;
		public var help_mc:MovieClip;
		public var skill_mc:MovieClip;
		public var _mc:MovieClip;	//有三種狀態的大頭
		private var _skill:String;
		private var _readyKill:Boolean;
		
		//亂數Tile用
		private var _randomTileFrame:int = 0;
		private var _randomTileSpeed:int = 0;
		private var _randomTileSpeedStatic:int = 3;
		private var _tileName:Array;
		
		public function Tile() 
		{
			//stop();
			addEventListener(Event.ADDED_TO_STAGE, goDrop);
			addEventListener(Event.REMOVED_FROM_STAGE, kill);
			select_mc.visible = false;
			//skill_mc.visible = false;
			
			var _r:Number = Math.random();
			if (_r < .02) {
				skill_mc.gotoAndStop(BOMB);
				skill = BOMB;
			}else if (_r > .02 && _r < .04) {
				skill_mc.gotoAndStop(LIGHTNING);
				skill = LIGHTNING;
			}else if (_r > .04 && _r < .05) {
				skill_mc.gotoAndStop(RANDOM_TILE);
				skill = RANDOM_TILE;
			}
		}
		
		//randomTile技能的亂數效果
		private function randomTile(e:Event):void 
		{	
			if (_randomTileSpeed <= _randomTileSpeedStatic) {
				_randomTileSpeed++;
			}else {
				_randomTileSpeed = 0;
				e.target.gotoAndStop(_tileName[_randomTileFrame]);
				_randomTileFrame ++;
				if (_randomTileFrame == _tileName.length) {
					_randomTileFrame = 0;
				}
			}
		}
		//供外部停止亂數效果
		public function stopRandom():void {
			skill_mc.randomTile_mc.removeEventListener(Event.ENTER_FRAME, randomTile);
		}
		
		private function goDrop(e:Event):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, goDrop);
			//addEventListener(Event.ENTER_FRAME, drop);
		}
		
		private function drop(e:Event):void 
		{	
			y+=5;
			if (y>500) {
				removeEventListener(Event.ENTER_FRAME, drop);
			}
		}
		
		public function get skill():String 
		{
			return _skill;
		}
		
		public function set skill(value:String):void 
		{
			_skill = value;
		}
		
		public function get readyKill():Boolean 
		{
			return _readyKill;
		}
		
		public function set readyKill(value:Boolean):void 
		{
			_readyKill = value;
		}
		
		public function set tileName(value:Array):void 
		{
			_tileName = value;
			skill_mc.randomTile_mc.addEventListener(Event.ENTER_FRAME, randomTile);
		}
		
		private function kill(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, kill);
			if(skill == RANDOM_TILE) skill_mc.randomTile_mc.removeEventListener(Event.ENTER_FRAME, randomTile);
		}
		
	}

}