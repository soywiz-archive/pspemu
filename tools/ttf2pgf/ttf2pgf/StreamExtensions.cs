using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Runtime.InteropServices;

namespace ttf2pgf
{
	static public class StreamExtensions
	{
		public static T ReadStruct<T>(this Stream Stream) where T : struct
		{
			var Size = Marshal.SizeOf(typeof(T));
			var Buffer = new byte[Size];
			Stream.Read(Buffer, 0, Size);
			return StructUtils.BytesToStruct<T>(Buffer);
		}

		public static void WriteStruct<T>(this Stream Stream, T Object) where T : struct
		{
			byte[] Bytes = StructUtils.StructToBytes(Object);
			Stream.Write(Bytes, 0, Bytes.Length);
		}

		public static void ReadStructVector<T>(this Stream Stream, ref T[] Vector, int Size) where T : struct
		{
			Vector = new T[Size];
			for (int n = 0; n < Size; n++)
			{
				Vector[n] = ReadStruct<T>(Stream);
			}
		}

		public static void WriteStructVector<T>(this Stream Stream, T[] Vector) where T : struct
		{
			for (int n = 0; n < Vector.Length; n++)
			{
				Stream.WriteStruct(Vector[n]);
			}
		}

		public static byte[] ReadBytes(this Stream Stream, int Count)
		{
			byte[] Bytes = new byte[Count];
			Stream.Read(Bytes, 0, Count);
			return Bytes;
		}

		public static void WriteBytes(this Stream Stream, byte[] Bytes)
		{
			Stream.Write(Bytes, 0, Bytes.Length);
		}
	}
}
