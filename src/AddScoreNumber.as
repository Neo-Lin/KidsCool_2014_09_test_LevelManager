package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class AddScoreNumber extends MovieClip 
	{
		private var _peopleNum:Number;
		public var score1_mc:MovieClip;
		public var score2_mc:MovieClip;
		public var score3_mc:MovieClip;
		public var score4_mc:MovieClip;
		
		public function AddScoreNumber() 
		{
			this.scaleX = this.scaleY = 3;
		}
		
		public function showN(_i:int):void
		{
			_peopleNum = _i;
			var _a = String(_i).split("");
			var _an:int = _a.length;
			trace(_an);
			gotoAndStop(_an);
			
			for (var i:int = 1; i <= _an; i++)
			{
				if (i <= _an)
				{
					var _n:int = int(_a.pop());
					if (_n == 0)
					{
						_n = 10;
					}
					MovieClip(getChildByName("score" + i + "_mc")).gotoAndStop(_n);
				}
				else
				{
					MovieClip(getChildByName("score" + i + "_mc")).gotoAndStop(10);
				}
			}
			addEventListener(Event.ENTER_FRAME, goMove);
		}
		
		private function goMove(e:Event):void{
			if (this.alpha == 0) {
				removeEventListener(Event.ENTER_FRAME, goMove);
				removeChild(this);
				return;
			}
			this.y --;
			this.alpha -= .02;
		}
		
		public function changeNum(_n:Number):void{
			if(_peopleNum + _n <= 0){
				_peopleNum = 0;
				dispatchEvent(new Event("zero"));
			}else{
				_peopleNum += _n;
			}
			showN(_peopleNum);
		}
		
	}
	
}