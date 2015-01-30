package  
{
	/**
	 * ...
	 * @author Neo
	 */
	public class OnlyAnimation extends ALevel 
	{
		
		public function OnlyAnimation(level:XML = null) 
		{
			super(level);
		}
		
		override protected function skip():void 
		{
			//參數為要去的關卡數字,0=下一關
			lvlJumpTo.dispatch(0);
		}
		
		override protected function finishMovie():void 
		{
			lvlJumpTo.dispatch(0);
		}
	}

}