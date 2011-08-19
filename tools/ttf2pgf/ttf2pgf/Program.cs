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
			/*
			var bitmap = new Bitmap(200, 200);
			var g = Graphics.FromImage(bitmap);
			var Font = new Font("MS Gothic", 16, FontStyle.Regular);
			var size = g.MeasureString("a", Font);
			g.DrawString("a", Font, new SolidBrush(Color.Black), new PointF(0, 0));
			bitmap.Save("temp.png");
			Console.WriteLine(size);
			*/

			PGF PGF = new PGF();
			//PGF.load("../../ltn0.pgf");
			PGF.load("../../jpn0.pgf");

			for (int m = 0; m < PGF.charMap.Length; m++)
			{
				//Console.WriteLine("{0} -> {1} :: {2}", m, PGF.charMap[m], (int)'あ');
			}

			//PGF.write("../../ltn0.pgf.bak");
			PGF.GetGlyph('あ').Shadow.GetBitmap().Save("_a.png");
			PGF.GetGlyph('な').Shadow.GetBitmap().Save("_na.png");
			PGF.GetGlyph('た').Shadow.GetBitmap().Save("_ta.png");
			PGF.GetGlyph('私').Shadow.GetBitmap().Save("_watashi.png");
			PGF.GetGlyph('あ').Face.GetBitmap().Save("a.png");
			PGF.GetGlyph('な').Face.GetBitmap().Save("na.png");
			PGF.GetGlyph('た').Face.GetBitmap().Save("ta.png");
			PGF.GetGlyph('私').Face.GetBitmap().Save("watashi.png");
			/*
			int n = 0;
			foreach (var Glyph in PGF.Glyphs)
			{
				Glyph.GetBitmap().Save(String.Format("dump/{0}.png", n));
				n++;
				//break;
			}
			 * */

			//PGF.GetGlyph('a').GetBitmap().Save("a.png");

			//test();
			Console.ReadKey();
		}
	}
}
