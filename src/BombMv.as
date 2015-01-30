package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class BombMv extends MovieClip 
	{
		
		public function BombMv() 
		{
			addEventListener(Event.ENTER_FRAME, checkFinish);
		}
		
		private function checkFinish(e:Event):void 
		{
			if (this.currentFrame == this.totalFrames) {
				removeEventListener(Event.ENTER_FRAME, checkFinish);
				goFinish();
			}
		}
		
		private function goFinish():void 
		{
			parent.removeChild(this);
		}
		
	}

}