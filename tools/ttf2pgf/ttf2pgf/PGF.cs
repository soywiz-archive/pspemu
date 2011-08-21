using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.IO;
using System.Drawing;

namespace ttf2pgf
{
	class PGF
	{
		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi, Pack = 1)]
		public struct Point32
		{
			public int X;
			public int Y;

			public override string ToString()
			{
				return String.Format("Point32({0}; {1})", X, Y);
			}
		}

		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi, Pack = 1)]
		public struct PointFixed26_6
		{
			public Fixed26_6 X;
			public Fixed26_6 Y;

			public override string ToString()
			{
				return String.Format("Point32({0}; {1})", X, Y);
			}
		}

		public struct Fixed26_6
		{
			public int EncodedValue;

			public float Value
			{
				get
				{
					return (EncodedValue / (float)Math.Pow(2, 6));
				}
				set
				{
					this.EncodedValue = (int)(Value * (float)Math.Pow(2, 6));
				}
			}

			public override string ToString()
			{
				return String.Format("{0}", Value);
			}
		}

		public struct MapUshort
		{
			public uint Src;
			public uint Dst;

			public override string ToString()
			{
				return String.Format("MapUshort({0}, {1})", Src, Dst);
			}
		}

		public struct MapUint
		{
			public uint Src;
			public uint Dst;

			public override string ToString()
			{
				return String.Format("MapUint({0}, {1})", Src, Dst);
			}
		}

		public struct MapInt
		{
			public int Src;
			public int Dst;

			public override string ToString()
			{
				return String.Format("MapUint({0}, {1})", Src, Dst);
			}
		}

		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi, Pack = 1)]
		public struct Header
		{
			public ushort headerOffset; // = 0
			public ushort headerSize; // 392 =
			[MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
			public byte[] magic; // = "PGF0" 
			public uint revision; // = 2;
			public uint version; // = 6;
			public int TableCharMapLength;
			public int TableCharPointerLength;

			/**
			 * Number of bits per packedCharMap entry.
			 */
			public int TableCharMapBpe;

			/**
			 * Number of bits per packedCharPointerTable entry.
			 */
			public int TableCharPointerBpe;

			public uint __unk1;

			//public PointFixed26_6 Size;
			public Point32 Size;
	
			// Resolution of a single character?
			public Point32 Resolution;

			public byte __unk2;

			[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 64)]
			public string fontName;

			[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 64)]
			public string fontType;

			public byte __unk3;
			public ushort firstGlyph;
			public ushort lastGlyph;

			[MarshalAs(UnmanagedType.ByValArray, SizeConst = 34)]
			public byte[] __unk4;

			public Fixed26_6 maxLeftXAdjust;
			public Fixed26_6 maxBaseYAdjust;
			public Fixed26_6 minCenterXAdjust;
			public Fixed26_6 maxTopYAdjust;
			public PointFixed26_6 maxAdvance;
			public PointFixed26_6 maxSize;
			public ushort maxGlyphWidth;
			public ushort maxGlyphHeight;

			public ushort __unk5;

			public byte TableDimLength;

			public byte TableXAdjustLength;
			public byte TableYAdjustLength;
			public byte TableAdvanceLength;

			[MarshalAs(UnmanagedType.ByValArray, SizeConst = 102)]
			public byte[] __unk6;

			public int TableShadowMapLength;
			public int TableShadowMapBpe;
			public uint __unk7;
			public Point32 shadowScale;
			public ulong      __unk8;

			// Revision 3
		}

		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi, Pack = 1)]
		struct HeaderRevision3 {
			public uint   TableCompCharMapBpe1;
			public ushort TableCompCharMapLength1;
			public ushort __unk1;
			public uint   TableCompCharMapBpe2;
			public ushort TableCompCharMapLength2;
			[MarshalAs(UnmanagedType.ByValArray, SizeConst = 6)]
			public byte[] __unk2;
		}

		public class Glyph
		{
			protected PGF PGF;
			protected int GlyphIndex;
			protected GlyphSymbol _Face;
			protected GlyphSymbol _Shadow;

			public Glyph(PGF PGF, int GlyphIndex)
			{
				this.PGF = PGF;
				this.GlyphIndex = GlyphIndex;
			}

			public GlyphSymbol Face {
				get
				{
					if (_Face == null)
					{
						_Face = new GlyphSymbol(GlyphSymbol.GlyphFlags.FONT_PGF_CHARGLYPH);
						_Face.Read(PGF, GlyphIndex);
					}
					return _Face;
				}
			}

			public GlyphSymbol Shadow
			{
				get
				{
					if (_Shadow == null)
					{
						_Shadow = new GlyphSymbol(GlyphSymbol.GlyphFlags.FONT_PGF_SHADOWGLYPH);
						_Shadow.Read(PGF, GlyphIndex);
					}
					return _Shadow;
				}

			}

		}

		public class GlyphSymbol
		{
			public enum GlyphFlags : int
			{
				FONT_PGF_BMP_H_ROWS = 0x01,
				FONT_PGF_BMP_V_ROWS = 0x02,
				FONT_PGF_BMP_OVERLAY = 0x03,
				FONT_PGF_METRIC_FLAG1 = 0x04,
				FONT_PGF_METRIC_FLAG2 = 0x08,
				FONT_PGF_METRIC_FLAG3 = 0x10,
				FONT_PGF_CHARGLYPH = 0x20,
				FONT_PGF_SHADOWGLYPH = 0x40,
			}

			public char UnicodeChar;
			public int GlyphIndex;
			public uint Width;
			public uint Height;
			public int Left;
			public int Top;
			public uint DataByteOffset;
			public uint AdvanceIndex;
			public GlyphFlags Flags;
			public byte[] Data;
			GlyphFlags GlyphType;

			public GlyphSymbol(GlyphFlags GlyphType = GlyphFlags.FONT_PGF_CHARGLYPH)
			{
				this.GlyphType = GlyphType;
			}

			public override string ToString()
			{
				return String.Format(
					"PGF.Glyph(GlyphIndex={0}, Char='{1}', Width={2}, Height={3}, Left={4}, Top={5}, Flags={6})",
					GlyphIndex, UnicodeChar, Width, Height, Left, Top, Flags
				);
			}

			public GlyphSymbol Read(PGF PGF, int GlyphIndex)
			{
				var br = new BitReader(PGF.charData);
				br.Position = PGF.charPointer[GlyphIndex] * 4 * 8;

				this.GlyphIndex = GlyphIndex;
				this.UnicodeChar = (char)PGF.reverseCharMap[GlyphIndex];

				//int NextOffset = br.Position;

				//br.Position = NextOffset;
				int ShadowOffset = (int)br.Position + (int)br.ReadBits(14) * 8;
				if (GlyphType == GlyphFlags.FONT_PGF_SHADOWGLYPH)
				{
					br.Position = ShadowOffset;
					br.SkipBits(14);
				}

				this.Width = br.ReadBits(7);
				this.Height = br.ReadBits(7);
				this.Left = br.ReadBitsSigned(7);
				this.Top = br.ReadBitsSigned(7);
				this.Flags = (GlyphFlags)br.ReadBits(6);

				if (Flags.HasFlag(GlyphFlags.FONT_PGF_CHARGLYPH))
				{
					br.SkipBits(7);
					var shadowId = br.ReadBits(9);
					br.SkipBits(24);
					if (!Flags.HasFlag(GlyphFlags.FONT_PGF_METRIC_FLAG1)) br.SkipBits(56);
					if (!Flags.HasFlag(GlyphFlags.FONT_PGF_METRIC_FLAG2)) br.SkipBits(56);
					if (!Flags.HasFlag(GlyphFlags.FONT_PGF_METRIC_FLAG3)) br.SkipBits(56);
					this.AdvanceIndex = br.ReadBits(8);
				}

				this.DataByteOffset = (uint)(br.Position / 8);

				uint PixelIndex = 0;
				uint NumberOfPixels = Width * Height;
				bool BitmapHorizontalRows = (Flags & GlyphFlags.FONT_PGF_BMP_OVERLAY) == GlyphFlags.FONT_PGF_BMP_H_ROWS;
				this.Data = new byte[NumberOfPixels];
				int Count;
				uint Value = 0;
				uint x, y;

				//Console.WriteLine(br.BitsLeft);

				while (PixelIndex < NumberOfPixels)
				{
					uint Code = br.ReadBits(4);

					if (Code < 8)
					{
						Value = br.ReadBits(4);
						Count = (int)Code + 1;
					}
					else
					{
						Count = 16 - (int)Code;
					}

					for (int n = 0; (n < Count) && (PixelIndex < NumberOfPixels); n++)
					{
						if (Code >= 8)
						{
							Value = br.ReadBits(4);
						}

						if (BitmapHorizontalRows)
						{
							x = PixelIndex % Width;
							y = PixelIndex / Width;
						}
						else
						{
							x = PixelIndex / Height;
							y = PixelIndex % Height;
						}

						this.Data[x + y * Width] = (byte)((Value << 0) | (Value << 4));
						PixelIndex++;
					}
				}

				/*
				for (int y = 0, n = 0; y < Height; y++)
				{
					for (int x = 0; x < Width; x++, n++)
					{
						Console.Write("{0:X1}", this.Data[n] & 0xF);
						//String.Format
					}
					Console.WriteLine("");
				}

				*/
				//Console.WriteLine(this);

				return this;
			}

			public Bitmap GetBitmap()
			{
				if (Width == 0 || Height == 0) return new Bitmap(1, 1);
				Bitmap Bitmap = new Bitmap((int)Width, (int)Height);
				for (int y = 0, n = 0; y < Height; y++)
				{
					for (int x = 0; x < Width; x++, n++)
					{
						byte c = Data[n];
						//Bitmap.SetPixel(x, y, Color.FromArgb(Data[n], 0xFF, 0xFF, 0xFF));
						Bitmap.SetPixel(x, y, Color.FromArgb(0xFF, c, c, c));
					}
				}
				return Bitmap;
			}
		}

		protected Glyph[] Glyphs;

		protected Glyph _GetGlyph(int Index)
		{
			if (Glyphs[Index] == null) {
				Glyphs[Index] = new Glyph(this, Index);
			}
			return Glyphs[Index];
		}

		public Glyph GetGlyph(char character, char alternativeCharacter = '?')
		{
			if (character >= 0 && character < charMap.Length)
			{
				return _GetGlyph(charMap[character]);
			}
			return _GetGlyph(charMap[alternativeCharacter]);
		}

		Header header;
		HeaderRevision3 headerExtraRevision3;

		PointFixed26_6[] dimensionTable;
		MapInt[] advanceTable;
		MapInt[] xAdjustTable;
		MapInt[] yAdjustTable;
		byte[] packedShadowCharMap;

		MapUshort[] charmapCompressionTable1;
		MapUshort[] charmapCompressionTable2;

		byte[] packedCharMap;
		byte[] packedCharPointerTable;

		public int[] charMap;
		Dictionary<int, int> reverseCharMap;
		int[] charPointer;

		public int[] shadowCharMap;
		Dictionary<int, int> reverseShadowCharMap;


		byte[] charData;

		public PGF()
		{
		}

		public int GetGlyphId(char c)
		{
			if (c < header.firstGlyph) return -1;
			if (c > header.lastGlyph) return -1;
			int glyphPos = (c - header.firstGlyph);
			//Console.WriteLine("Offset: {0}, Size: {1}", glyphPos * header.charMapBpe, header.charMapBpe);
			return (int)BitReader.ReadBitsAt(packedCharMap, glyphPos * header.TableCharMapBpe, header.TableCharMapBpe);
		}

		static protected int BitsToBytesHighAligned(int Bits)
		{
			//return MathUtils.NextHigherAligned(Bits, 8) / 8;
			return ((Bits + 31) & ~31) / 8;
		}

		public void load(string FileName)
		{
			FileStream FileStream = new FileStream(FileName, FileMode.Open, FileAccess.Read);
			this.header = FileStream.ReadStruct<Header>();

			if (this.header.revision >= 3)
			{
				this.headerExtraRevision3 = FileStream.ReadStruct<HeaderRevision3>();
			}

			FileStream.ReadStructVector(ref dimensionTable, header.TableDimLength);
			FileStream.ReadStructVector(ref xAdjustTable, header.TableXAdjustLength);
			FileStream.ReadStructVector(ref yAdjustTable, header.TableYAdjustLength);
			FileStream.ReadStructVector(ref advanceTable, header.TableAdvanceLength);

			packedShadowCharMap = FileStream.ReadBytes(BitsToBytesHighAligned(header.TableShadowMapLength * header.TableShadowMapBpe));

			if (header.revision == 3)
			{
				FileStream.ReadStructVector(ref charmapCompressionTable1, headerExtraRevision3.TableCompCharMapLength1);
				FileStream.ReadStructVector(ref charmapCompressionTable2, headerExtraRevision3.TableCompCharMapLength2);
			}

			packedCharMap = FileStream.ReadBytes(BitsToBytesHighAligned(header.TableCharMapLength * header.TableCharMapBpe));
			packedCharPointerTable = FileStream.ReadBytes(BitsToBytesHighAligned(header.TableCharPointerLength * header.TableCharPointerBpe));

			/*
			int BytesLeft = (int)(FileStream.Length - FileStream.Position);
			charData = new byte[BytesLeft];
			FileStream.Read(charData, 0, BytesLeft);
			*/

			charData = FileStream.ReadBytes((int)(FileStream.Length - FileStream.Position));

			var NumberOfCharacters = header.TableCharPointerLength;

			charMap = new int[header.lastGlyph + 1];
			charPointer = new int[NumberOfCharacters];
			Glyphs = new Glyph[NumberOfCharacters];
			reverseCharMap = new Dictionary<int, int>();


			foreach (var Pair in BitReader.FixedBitReader(packedShadowCharMap, header.TableShadowMapBpe))
			{
				var UnicodeIndex = (int)Pair.Key + header.firstGlyph;
				var GlyphIndex = (int)Pair.Value;
				shadowCharMap[UnicodeIndex] = GlyphIndex;
				reverseShadowCharMap[GlyphIndex] = UnicodeIndex;
			}


			foreach (var Pair in BitReader.FixedBitReader(packedCharMap, header.TableCharMapBpe))
			{
				var UnicodeIndex = (int)Pair.Key + header.firstGlyph;
				var GlyphIndex = (int)Pair.Value;
				charMap[UnicodeIndex] = GlyphIndex;
				reverseCharMap[GlyphIndex] = UnicodeIndex;
			}

			foreach (var Pair in BitReader.FixedBitReader(packedCharPointerTable, header.TableCharPointerBpe))
			{
				charPointer[Pair.Key] = (int)Pair.Value;
			}

			/*
			for (int n = 0; n < NumberOfCharacters; n++)
			{
				Glyphs[n] = new Glyph().Read(this, n);
			}
			*/

			Console.WriteLine(this.header.fontName);

			/*
			Console.WriteLine(this.header.fontName);
			for (int n = 0; n < 300; n++)
			{
				Console.WriteLine(GetGlyphId((char)n));
			}
			*/
		}

		public void write(string FileName)
		{
			FileStream FileStream = new FileStream(FileName, FileMode.OpenOrCreate, FileAccess.Write);
			FileStream.WriteStruct(this.header);

			if (this.header.revision >= 3)
			{
				FileStream.WriteStruct(this.headerExtraRevision3);
			}

			FileStream.WriteStructVector(dimensionTable);
			FileStream.WriteStructVector(xAdjustTable);
			FileStream.WriteStructVector(yAdjustTable);
			FileStream.WriteStructVector(advanceTable);
			FileStream.WriteStructVector(packedShadowCharMap);

			if (header.revision == 3)
			{
				FileStream.WriteStructVector(charmapCompressionTable1);
				FileStream.WriteStructVector(charmapCompressionTable2);
			}

			FileStream.WriteStructVector(packedCharMap);
			FileStream.WriteStructVector(packedCharPointerTable);

			FileStream.WriteBytes(charData);
		}
	}
}
