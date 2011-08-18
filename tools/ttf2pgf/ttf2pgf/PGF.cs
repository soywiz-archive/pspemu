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
			public int x;
			public int y;
		}

		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi, Pack = 1)]
		public struct PointFixed26_6
		{
			public Fixed26_6 x;
			public Fixed26_6 y;
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
		}

		public struct MapUshort
		{
			public uint src;
			public uint dst;
		}

		public struct MapUint
		{
			public uint src;
			public uint dst;
		}

		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi, Pack = 1)]
		public struct Header
		{
			public ushort headerOffset; // = 0
			public ushort headerSize;
			[MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
			public byte[] magic; // = "PGF0" 
			public uint revision; // = 2;
			public uint version; // = 6;
			public uint charMapLength;
			public uint charPointerLength;

			/**
			 * Number of bits per charMap.
			 */
			public int charMapBpe;
			public int charPointerBpe;
			public uint __unk1;
			public uint hSize;                 // Size of all characters?
			public uint vSize;
			public uint hResolution;           // Resolution of a single character?
			public uint vResolution;
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
			public uint maxLeftXAdjust;
			public uint maxBaseYAdjust;
			public uint minCenterXAdjust;
			public uint maxTopYAdjust;
			public PointFixed26_6 maxAdvance;
			public PointFixed26_6 maxSize;
			public ushort maxGlyphWidth;
			public ushort maxGlyphHeight;
			public ushort __unk5;
			public byte dimTableLength;
			public byte xAdjustTableLength;
			public byte yAdjustTableLength;
			public byte advanceTableLength;
			[MarshalAs(UnmanagedType.ByValArray, SizeConst = 102)]
			public byte[] __unk6;
			public uint shadowMapLength;
			public uint shadowMapBpe;
			public uint __unk7;
			public Point32 shadowScale;
			public ulong      __unk8;

			// Revision 3
		}

		[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi, Pack = 1)]
		struct HeaderRevision3 {
			public uint   compCharMapBpe1;
			public ushort compCharMapLength1;
			public ushort __unk1;
			public uint   compCharMapBpe2;
			public ushort compCharMapLength2;
			[MarshalAs(UnmanagedType.ByValArray, SizeConst = 6)]
			public byte[] __unk2;
		}

		public class Glyph
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

			public override string ToString()
			{
				return String.Format(
					"PGF.Glyph(GlyphIndex={0}, Char='{1}', Width={2}, Height={3}, Left={4}, Top={5}, Flags={6})",
					GlyphIndex, UnicodeChar, Width, Height, Left, Top, Flags
				);
			}

			public Glyph Read(PGF PGF, int GlyphIndex)
			{
				var br = new BitReader(PGF.charData);
				br.Position = PGF.charPointer[GlyphIndex] * 4 * 8;

				this.GlyphIndex = GlyphIndex;
				this.UnicodeChar = (char)PGF.reverseCharMap[GlyphIndex];

				var OffsetShadowMap = br.ReadBits(14);
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

				//Console.WriteLine(br.BitsLeft);

				while (PixelIndex < NumberOfPixels)
				{
					int Count;
					uint Value = 0;
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

						uint x, y;
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
						//Bitmap.SetPixel(x, y, Color.FromArgb(Data[n], 0xFF, 0xFF, 0xFF));
						Bitmap.SetPixel(x, y, Color.FromArgb(0xFF, Data[n], Data[n], Data[n]));
					}
				}
				return Bitmap;
			}
		}

		public Glyph[] Glyphs;

		public Glyph GetGlyph(char character, char alternativeCharacter = '?')
		{
			if (character >= 0 && character < charMap.Length)
			{
				return Glyphs[charMap[character]];
			}
			return Glyphs[charMap[alternativeCharacter]];
		}

		Header header;
		HeaderRevision3 headerExtraRevision3;

		PointFixed26_6[] dimensionTable;
		MapUint[] advanceTable;
		MapUint[] xAdjustTable;
		MapUint[] yAdjustTable;
		byte[] shadowCharMap;

		MapUshort[] charmapCompressionTable1;
		MapUshort[] charmapCompressionTable2;

		byte[] packedCharMap;
		byte[] packedCharPointerTable;

		public int[] charMap;
		int[] charPointer;

		Dictionary<int, int> reverseCharMap;

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
			return (int)BitReader.ReadBitsAt(packedCharMap, glyphPos * header.charMapBpe, header.charMapBpe);
		}

		public void load(string FileName)
		{
			FileStream FileStream = new FileStream(FileName, FileMode.Open, FileAccess.Read);
			this.header = FileStream.ReadStruct<Header>();

			if (this.header.revision >= 3)
			{
				this.headerExtraRevision3 = FileStream.ReadStruct<HeaderRevision3>();
			}

			FileStream.ReadStructVector(ref dimensionTable, header.dimTableLength);
			FileStream.ReadStructVector(ref xAdjustTable, header.xAdjustTableLength);
			FileStream.ReadStructVector(ref yAdjustTable, header.yAdjustTableLength);
			FileStream.ReadStructVector(ref advanceTable, header.advanceTableLength);
			FileStream.ReadStructVector(ref shadowCharMap, (int)((header.shadowMapLength * header.shadowMapBpe + 31) & ~31) / 8);
			if (header.revision == 3)
			{
				FileStream.ReadStructVector(ref charmapCompressionTable1, headerExtraRevision3.compCharMapLength1);
				FileStream.ReadStructVector(ref charmapCompressionTable2, headerExtraRevision3.compCharMapLength2);
			}

			FileStream.ReadStructVector(ref packedCharMap, (int)(((header.charMapLength * header.charMapBpe + 31) & ~31) / 8));
			FileStream.ReadStructVector(ref packedCharPointerTable, (int)(((header.charPointerLength * header.charPointerBpe + 31) & ~31) / 8));

			/*
			int BytesLeft = (int)(FileStream.Length - FileStream.Position);
			charData = new byte[BytesLeft];
			FileStream.Read(charData, 0, BytesLeft);
			*/
			charData = FileStream.ReadBytes((int)(FileStream.Length - FileStream.Position));

			var NumberOfCharacters = header.charPointerLength;

			charMap = new int[header.lastGlyph + 1];
			charPointer = new int[NumberOfCharacters];
			Glyphs = new Glyph[NumberOfCharacters];
			reverseCharMap = new Dictionary<int, int>();

			{
				BitReader br = new BitReader(packedCharMap);
				int BitsToRead = header.charMapBpe;
				for (int UnicodeIndex = header.firstGlyph; UnicodeIndex <= header.lastGlyph; UnicodeIndex++)
				{
					int GlyphIndex = (int)br.ReadBits(BitsToRead);
					charMap[UnicodeIndex] = GlyphIndex;
					reverseCharMap[GlyphIndex] = UnicodeIndex;
				}
			}

			{
				BitReader br = new BitReader(packedCharPointerTable);
				int BitsToRead = header.charPointerBpe;
				for (int n = 0; n < header.charPointerLength; n++)
				{
					charPointer[n] = (int)br.ReadBits(BitsToRead);
				}
			}

			for (int n = 0; n < NumberOfCharacters; n++)
			{
				Glyphs[n] = new Glyph().Read(this, n);
			}

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
			FileStream.WriteStructVector(shadowCharMap);

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
