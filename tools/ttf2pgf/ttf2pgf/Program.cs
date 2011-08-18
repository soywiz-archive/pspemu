using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace ttf2pgf
{
	class Program
	{
		static void Main(string[] args)
		{
			var bitmap = new Bitmap(200, 200);
			var g = Graphics.FromImage(bitmap);
			var Font = new Font("MS Gothic", 16, FontStyle.Regular);
			var size = g.MeasureString("a", Font);
			g.DrawString("a", Font, new SolidBrush(Color.Black), new PointF(0, 0));
			bitmap.Save("temp.png");
			Console.WriteLine(size);

			PGF PGF = new PGF();
			//PGF.load("../../ltn0.pgf");
			PGF.load("../../jpn0.pgf");
			
			//PGF.write("../../ltn0.pgf.bak");
			PGF.GetGlyph('あ').GetBitmap().Save("a.png");

			//test();
			Console.ReadKey();
		}
	}
}
