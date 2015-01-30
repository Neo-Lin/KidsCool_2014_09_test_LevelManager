package  
{
	import caurina.transitions.Tweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class EliminateGame extends Sprite 
	{
		private var _objectsMC:MovieClip;
		private var _hTile:uint = 8;
		private var _wTile:uint = 8;
		//private var _tileW:uint = 
		private var _tileName:Array = ["a", "b", "c", "d", "e", "f", "g"];
		private var _allTileArray:Array = new Array();
		private var _touchTile:Array = [];
		private var _addLineNum:int = 0;
		//檢查連線,有連線的Tile會存入
		private var _tArrayAllW:Array = [];
		private var _tArrayAllH:Array = [];
		
		public function EliminateGame(objectsMC:MovieClip) 
		{
			_objectsMC = objectsMC;
			addChild(_objectsMC);
			
			for (var i:int = 0; i < _hTile; i++) {
				_allTileArray[i] = new Array();
				for (var j:int = 0; j < _wTile; j++) {
					var _t:Tile = new Tile();
					_allTileArray[i][j] = _t;
					//做出不會連線的初始組合
					do{
						_t.gotoAndStop(_tileName[Math.floor(Math.random() * _tileName.length)]);
					}while (initChk(i, j)) 
					
					_objectsMC.addChild(_t);
					_t.x = _t.width * j;
					_t.y = _t.height * i;
					_t.name = i + "_" + j;
					_t.addEventListener(MouseEvent.MOUSE_DOWN, tileMD);
					_t.addEventListener(MouseEvent.MOUSE_UP, tileMU);
				}
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
		
		private function tileMD(e:MouseEvent):void 
		{	//trace(e.currentTarget.name.split("_")[0]);
			var _tmpAR:Array = e.currentTarget.name.split("_");
			if (_touchTile.length > 0) { //是否已選取了第一個圖案
				var _m:MovieClip = _objectsMC.getChildByName(_touchTile[0] + "_" + _touchTile[1]) as MovieClip;
				if ((_touchTile[0] == int(_tmpAR[0]) + 1 || _touchTile[0] == int(_tmpAR[0]) - 1) &&
				_touchTile[1] == _tmpAR[1]) {	trace("在上下旁邊");
					//改變陣列中兩個圖案的位置
					/*trace(_allTileArray[_tmpAR[0]][_tmpAR[1]].name);
					trace(_allTileArray[_touchTile[0]][_touchTile[1]].name);*/
					_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, _m);
					_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, e.currentTarget);
					/*trace(_allTileArray[_tmpAR[0]][_tmpAR[1]].name);
					trace(_allTileArray[_touchTile[0]][_touchTile[1]].name);*/
					//改變畫面上兩個圖案的位置
					Tweener.addTween(e.currentTarget, { y:_m.y, time:.5 } );
					Tweener.addTween(_m, { y:e.currentTarget.y, time:.5 } );
					//檢查是否達成連線
					if (chkLine()) {
						//修改交換的物件名稱,因為名稱要對應陣列位置,所以換位置就要換名字
						var _mName:String = _m.name;
						_m.name = e.currentTarget.name
						e.currentTarget.name = _mName;
						//刪除連線的Tile
						cleanLine();
					}else { //沒有達成連線,恢復原狀
						_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, e.currentTarget);
						_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, _m);
						Tweener.addTween(e.currentTarget, { y:e.currentTarget.y, time:.5, delay:.5 } );
						Tweener.addTween(_m, { y:_m.y, time:.5, delay:.5 } );
					}
				}else if ((_touchTile[1] == int(_tmpAR[1]) + 1 || _touchTile[1] == int(_tmpAR[1]) - 1) &&
				_touchTile[0] == _tmpAR[0]) {	trace("在左右旁邊");
					//改變陣列中兩個圖案的位置
					_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, _m);
					_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, e.currentTarget);
					//改變畫面上兩個圖案的位置
					Tweener.addTween(e.currentTarget, { x:_m.x, time:.5 } );
					Tweener.addTween(_m, { x:e.currentTarget.x, time:.5 } );
					//檢查是否達成連線
					if (chkLine()) {
						//修改交換的物件名稱,因為名稱要對應陣列位置,所以換位置就要換名字
						var _mName:String = _m.name;
						_m.name = e.currentTarget.name
						e.currentTarget.name = _mName;
						//刪除連線的Tile
						cleanLine();
					}else { //沒有達成連線,恢復原狀
						_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, e.currentTarget);
						_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, _m);
						Tweener.addTween(e.currentTarget, { x:e.currentTarget.x, time:.5, delay:.5 } );
						Tweener.addTween(_m, { x:_m.x, time:.5, delay:.5 } );
					}
				}else {
					trace("不在旁邊");
				}
				_touchTile.length = 0;
			}else {
				_touchTile = _tmpAR;
			}
		}
		
		//刪除連線的Tile
		private function cleanLine():void {
			//刪除橫向
			for (var wi:int = 0; wi < _tArrayAllW.length; wi++) {
				for each(var f:Tile in _tArrayAllW[wi]) {
					trace("刪除橫向:",f.name);
					Tweener.addTween(f, { alpha:0, time:.5, transition:"easeInQuart", onComplete:function() {
						_objectsMC.removeChild(this);
						addTile(this.name.charAt(0), this.name.charAt(2));
						} } );
					_allTileArray[f.name.charAt(0)][f.name.charAt(2)] = f = null;
					
					trace("刪除橫向:",_tArrayAllW[wi]);
				}
			}
			//刪除直向
			for (var hi:int = 0; hi < _tArrayAllH.length; hi++) {
				for each(var f:Tile in _tArrayAllH[hi]) {
					trace("刪除直向:",f.name);
					//怕跟橫向有重複到所以多一道檢查
					if (_allTileArray[f.name.charAt(0)][f.name.charAt(2)]) {
						_objectsMC.removeChild(f);
						_allTileArray[f.name.charAt(0)][f.name.charAt(2)] = null;	
					}
					trace("刪除直向:",_tArrayAllH[hi]);
				}
			}
			
			/*for each(var af:Array in _allTileArray) {
				trace(af.length);
			}*/
		}
		
		private function addTile(a:String, b:String):void 
		{	trace(a, b);
			var _m:MovieClip;
			for (var i:int = int(a)-1; i >= 0; i--) {
				_m = _objectsMC.getChildByName(i + "_" + b) as MovieClip;
				trace("addTile:",_m, i, b);
				Tweener.addTween(_m, { y:_m.y + _m.height, time:.5, onComplete:function() {
					trace(this.name, _m.name);
					_m.name = a + "_" + b;
					_allTileArray[a][b] = _t;
					} } );
				trace("addTile:",_m.name);
			}
			var _t:Tile = new Tile();
			_allTileArray[0][b] = _t;
			_t.gotoAndStop(_tileName[Math.floor(Math.random() * _tileName.length)]);
			_objectsMC.addChild(_t);
			_t.x = _t.width * int(b);
			_t.name = "0_" + b;
			_t.addEventListener(MouseEvent.MOUSE_DOWN, tileMD);
			_t.addEventListener(MouseEvent.MOUSE_UP, tileMU);
		}
		
		//檢查是否有連線
		private function chkLine():Boolean {
			var _t:MovieClip;
			var _tArray:Array = [];
			_tArrayAllW = [];
			_tArrayAllH = [];
			//檢查橫向
			for (var i:uint = 0; i < _allTileArray.length; i++) {
				for (var j:uint = 0; j < _allTileArray[i].length; j++) {
					if (_t) {
						//若跟上一個相同
						if (_t.currentFrameLabel == _allTileArray[i][j].currentFrameLabel) {
							_tArray.push(_allTileArray[i][j]);
						}else {
							if (_tArray.length > 2) {
								//_tArray.push("++"+i);
								_tArrayAllW.push(_tArray);
							}
							_t = _allTileArray[i][j];
							_tArray = [_t];
						}
					}else {
						_t = _allTileArray[i][j];
						_tArray = [_t];
					}
				}
				_t = null;
				if (_tArray.length > 2) {
					//_tArray.push("=="+i);
					_tArrayAllW.push(_tArray);
				}
			}
			trace("_tArrayAllW:",_tArrayAllW);
			//檢查直向
			_tArray = [];
			for (var k:uint = 0; k < _allTileArray.length; k++) {
				for (var m:uint = 0; m < _allTileArray[k].length; m++) {
					if (_t) {
						//若跟上一個相同
						if (_t.currentFrameLabel == _allTileArray[m][k].currentFrameLabel) {
							_tArray.push(_allTileArray[m][k]);
						}else {
							if (_tArray.length > 2) {
								//_tArray.push("++"+k);
								_tArrayAllH.push(_tArray);
							}
							_t = _allTileArray[m][k];
							_tArray = [_t];
						}
					}else {
						_t = _allTileArray[m][k];
						_tArray = [_t];
					}
				}
				_t = null;
				if (_tArray.length > 2) {
					//_tArray.push("=="+k);
					_tArrayAllH.push(_tArray);
				}
			}
			trace("_tArrayAllH:",_tArrayAllH);
			
			if (_tArrayAllW.length > 0 || _tArrayAllH.length > 0) {
				return true;
			}else {
				return false;
			}
		}
		
		private function tileMU(e:MouseEvent):void 
		{
			/*var _tmpAR:Array = e.currentTarget.name.split("_");
			if (_touchTile.length > 0) { //是否已選取了第一個圖案
				var _m:MovieClip = _objectsMC.getChildByName(_touchTile[0] + "_" + _touchTile[1]) as MovieClip;
				if ((_touchTile[0] == int(_tmpAR[0]) + 1 || _touchTile[0] == int(_tmpAR[0]) - 1) &&
				_touchTile[1] == _tmpAR[1]) {	trace("在上下旁邊");
					Tweener.addTween(e.currentTarget, { y:_m.y, time:.5 } );
					Tweener.addTween(_m, {y:e.currentTarget.y, time:.5 } );
				}else if ((_touchTile[1] == int(_tmpAR[1]) + 1 || _touchTile[1] == int(_tmpAR[1]) - 1) &&
				_touchTile[0] == _tmpAR[0]) {	trace("在左右旁邊");
					Tweener.addTween(e.currentTarget, { x:_m.x, time:.5 } );
					Tweener.addTween(_m, {x:e.currentTarget.x, time:.5 } );
				}else {
					trace("不在旁邊");
				}
				_touchTile.length = 0;
			}*/
		}
		
	}

}