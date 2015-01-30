package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	
	[SWF(backgroundColor="#000000")]
	public class n extends Sprite
	{
		private var jw:Array = new Array();
		private var g:Sprite;
		private var s:Sprite = new Sprite();
		private var pr:int = -10;
		private var pc:int = -10;
		private var cl:Array = new Array(0xFF0000, 0xFF00, 0xFF, 0XFFFF00, 0xFF00FF, 0xFFFF, 0xFFFFFF);
		private var cp:Boolean = false;
		private var ts:TextField = new TextField();
		private var th:TextField = new TextField();
		private var sc:uint = 0;
		private var m:uint = 0;
		
		//[SWF(width="800", height="600", background-color="#ffffff", frameRate="12")]
		public function n()
		{
			addChild(ts);
			ts.textColor = 0xFFFFFF;
			ts.x = 500;
			addChild(th);
			th.textColor = 0xFFFFFF;
			th.x = 550;
			for (var i:uint = 0; i < 8; i++)
			{
				jw[i] = new Array();
				for (var j:uint = 0; j < 8; j++)
				{
					do
					{
						jw[i][j] = Math.floor(Math.random() * 7);
					} while (rk(i, j) > 2 || ck(i, j) > 2);
					g = new Sprite();
					g.graphics.beginFill(cl[jw[i][j]]);
					g.graphics.drawCircle(30, 30, 29);
					g.graphics.endFill();
					g.name = i + "_" + j;
					g.x = j * 60;
					g.y = i * 60;
					addChild(g);
				}
			}
			addChild(s);
			s.graphics.lineStyle(2, 0xff0000, 1);
			s.graphics.drawRect(0, 0, 60, 60);
			s.visible = false;
			stage.addEventListener(MouseEvent.CLICK, ci);
			addEventListener(Event.ENTER_FRAME, ef);
		}
		
		private function ef(e:Event):void
		{
			var f:Boolean = false;
			for (var i:int = 6; i >= 0; i--)
			{
				for (var j:uint = 0; j < 8; j++)
				{
					if (jw[i][j] != -1 && jw[i + 1][j] == -1)
					{
						f = true;
						jw[i + 1][j] = jw[i][j];
						jw[i][j] = -1;
						getChildByName(i + "_" + j).y += 60;
						getChildByName(i + "_" + j).name = (i + 1) + "_" + j;
						break;
					}
				}
				if (f)
				{
					break;
				}
			}
			if (!f)
			{
				var h:Boolean = false;
				for (i = 7; i >= 0; i--)
				{
					for (j = 0; j < 8; j++)
					{
						if (jw[i][j] == -1)
						{
							h = true;
							jw[0][j] = Math.floor(Math.random() * 7);
							g = new Sprite();
							g.graphics.beginFill(cl[jw[0][j]]);
							g.graphics.drawCircle(30, 30, 29);
							g.graphics.endFill();
							g.name = "0_" + j;
							g.x = j * 60;
							g.y = 0;
							addChild(g);
							break;
						}
					}
					if (h)
					{
						break;
					}
				}
				if (!h)
				{
					var r:Boolean = false;
					for (i = 7; i >= 0; i--)
					{
						for (j = 0; j < 8; j++)
						{
							if (rk(i, j) > 2 || ck(i, j) > 2)
							{
								r = true;
								var tr:Array = [i + "_" + j];
								var u:uint = jw[i][j];
								var t:int;
								if (rk(i, j) > 2)
								{
									t = j;
									while (chk(u, i, t - 1))
									{
										t--;
										tr.push(i + "_" + t);
									}
									t = j;
									while (chk(u, i, t + 1))
									{
										t++;
										tr.push(i + "_" + t);
									}
								}
								if (ck(i, j) > 2)
								{
									t = i;
									while (chk(u, t - 1, j))
									{
										t--;
										tr.push(t + "_" + j);
									}
									t = i;
									while (chk(u, t + 1, j))
									{
										t++;
										tr.push(t + "_" + j);
									}
								}
								for (i = 0; i < tr.length; i++)
								{
									removeChild(getChildByName(tr[i]));
									var cd:Array = tr[i].split("_");
									jw[cd[0]][cd[1]] = -1;
									sc += m;
									m++;
								}
								break;
							}
						}
						if (r)
						{
							break;
						}
					}
					if (!r)
					{
						cp = true;
						m = 0;
					}
				}
			}
			ts.text = sc.toString();
		}
		
		private function ci(e:MouseEvent):void
		{
			if (cp)
			{
				if (mouseX < 480 && mouseX > 0 && mouseY < 480 && mouseY > 0)
				{
					var sr:uint = Math.floor(mouseY / 60);
					var sc:uint = Math.floor(mouseX / 60);
					if (!(((sr == pr + 1 || sr == pr - 1) && sc == pc) || ((sc == pc + 1 || sc == pc - 1) && sr == pr)))
					{
						pr = sr;
						pc = sc;
						s.x = 60 * pc;
						s.y = 60 * pr;
						s.visible = true;
					}
					else
					{
						swp(pr, pc, sr, sc);
						if (rk(pr, pc) > 2 || ck(pr, pc) > 2 || rk(sr, sc) > 2 || ck(sr, sc) > 2)
						{
							th.text = "";
							cp = false;
							getChildByName(pr + "_" + pc).x = sc * 60;
							getChildByName(pr + "_" + pc).y = sr * 60;
							getChildByName(pr + "_" + pc).name = "t";
							getChildByName(sr + "_" + sc).x = pc * 60;
							getChildByName(sr + "_" + sc).y = pr * 60;
							getChildByName(sr + "_" + sc).name = pr + "_" + pc;
							getChildByName("t").name = sr + "_" + sc;
						}
						else
						{
							swp(pr, pc, sr, sc);
						}
						pr = -10;
						pc = -10;
						s.visible = false;
					}
				}
				else
				{
					for (var i:uint = 0; i < 8; i++)
					{
						for (var j:uint = 0; j < 8; j++)
						{
							if (i < 7)
							{
								swp(i, j, i + 1, j);
								if ((rk(i, j) > 2 || ck(i, j) > 2 || rk(i + 1, j) > 2 || ck(i + 1, j) > 2))
								{
									th.text = i.toString() + "," + j.toString() + "->" + (i + 1).toString() + "," + j.toString();
								}
								swp(i, j, i + 1, j);
							}
							if (j < 7)
							{
								swp(i, j, i, j + 1);
								if ((rk(i, j) > 2 || ck(i, j) > 2 || rk(i, j + 1) > 2 || ck(i, j + 1) > 2))
								{
									th.text = i.toString() + "," + j.toString() + "->" + (i).toString() + "," + (j + 1).toString();
								}
								swp(i, j, i, j + 1);
							}
						}
					}
				}
			}
		}
		
		private function swp(r1:uint, c1:uint, r2:uint, c2:uint):void
		{
			var t:uint = jw[r1][c1];
			jw[r1][c1] = jw[r2][c2];
			jw[r2][c2] = t;
		}
		
		private function rk(r:uint, c:uint):uint
		{
			var u:uint = jw[r][c];
			var stk:uint = 1;
			var t:int = c;
			while (chk(u, r, t - 1))
			{
				t--;
				stk++;
			}
			t = c;
			while (chk(u, r, t + 1))
			{
				t++;
				stk++;
			}
			return (stk);
		}
		
		private function ck(r:uint, c:uint):uint
		{
			var u:uint = jw[r][c];
			var stk:uint = 1;
			var t:int = r;
			while (chk(u, t - 1, c))
			{
				t--;
				stk++;
			}
			t = r;
			while (chk(u, t + 1, c))
			{
				t++;
				stk++;
			}
			return (stk);
		}
		
		private function chk(g:uint, r:int, c:int):Boolean
		{
			if (jw[r] == null)
			{
				return false;
			}
			if (jw[r][c] == null)
			{
				return false;
			}
			return g == jw[r][c];
		}
	}
}