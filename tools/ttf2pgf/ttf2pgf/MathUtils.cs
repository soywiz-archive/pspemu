using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ttf2pgf
{
	public class MathUtils
	{
		static public int NextHigherAligned(int Value, int Align) {
			if ((Value % Align) != 0)
			{
				Value += Align - (Value % Align);
			}
			return Value;
		}
	}
}
