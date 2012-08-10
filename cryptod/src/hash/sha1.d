// Written in the D programming language

/*	Copyright Andrey A Popov 2012
 * 
 *	Permission is hereby granted, free of charge, to any person or organization
 *	obtaining a copy of the software and accompanying documentation covered by
 *	this license (the "Software") to use, reproduce, display, distribute,
 *	execute, and transmit the Software, and to prepare derivative works of the
 *	Software, and to permit third-parties to whom the Software is furnished to
 *	do so, all subject to the following:
 *	
 *	The copyright notices in the Software and this entire statement, including
 *	the above license grant, this restriction and the following disclaimer,
 *	must be included in all copies of the Software, in whole or in part, and
 *	all derivative works of the Software, unless such copies or derivative
 *	works are solely in the form of machine-executable object code generated by
 *	a source language processor.
 *	
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 *	SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 *	FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 *	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *	DEALINGS IN THE SOFTWARE.
 */

module cryptod.hash.sha1;

import std.string, std.format, std.array;

import cryptod.hash.hash;


/**
 * The SHA1 hash according to specification;
 * Takes a byte array and converts it into a 128-bit hash.
 * It does not yet support streaming hashes of extremely long messages.
 */
class SHA1Context : HashContext
{
	private:

	uint k1 = 0x5a827999; //SHA1 Constant
	uint k2 = 0x6ed9eba1; //SHA1 Constant
	uint k3 = 0x8f1bbcdc; //SHA1 Constant
	uint k4 = 0xca62c1d6; //SHA1 Constant
	
	uint[5] H; ///Hash iteration vars.
	ubyte[] buffer;
	ulong buffl;
	
	pure uint K(uint t)
	{
		if 		(t <= 19)
			return k1;
		else if (t <= 39)
			return k2;
		else if (t <= 59)
			return k3;
		else
			return k4;
	}
	
	pure uint ROTL(uint x, uint n)
	{
		return (x << n) | (x >> (32-n));
	}

	pure uint Ch(uint x, uint y, uint z)
	{
		return (x & y) ^ ((~x) & z);
	}
	
	pure int Parity(uint x, uint y, uint z)
	{
		return x ^ y ^ z;
	}
	
	pure uint Maj(uint x, uint y, uint z)
	{
		return (x & y) ^ (x & z) ^ (y & z);
	}
	
	pure uint f(uint x, uint y, uint z, uint t)
	{
		if 		(t <= 19) 
			return Ch(x,y,z);
		else if (t <= 39)
			return Parity(x,y,z);
		else if (t <= 59)
			return Maj(x,y,z);
		else
			return Parity(x,y,z);
	}
	
	pure ubyte[] WordsToBytes(uint[] Z)
	{
		uint numBytes = Z.length * 4;
		
		ubyte[] bytes = new ubyte[numBytes];
		
		for(uint i = 0; i < Z.length; i++)
		{
			for(uint j = 0; j < 4; j++)
			{
				bytes[4*i+j] = (Z[i] >>> (4*(3-j))) & 0xFF;
			}
		}
		return bytes;
	}
	
	/**
	 * Pads the message in order for it to be divisible into chunks of 64 bytes.
	 * Params:
	 * 		m =		The message as a byte array.
	 * Returns:
	 * 		The message appended with a 1 bit, followed by zeros, followed by a 64-bit integer
	 */ 
	pure ubyte[] PadMessage(ubyte[] m, ulong l)
	{
		//ulong l = m.length; ///This is the length of the message in BYTES, not bits as per spec;
		
		ubyte p = 0x80; ///The first pad bit.
		
		ubyte z = 0x00; ///The zero byte.
		
		ubyte[8] lb; ///The 8 byte array making up the length of m in bits.
		
		uint zl = (64 - ((l%64) + 9)) % 64; ///How many zero bytes to use.
		
		ulong ltb = l * 8; ///The length in bits.
		
		//converts l into a 8 byte array stored in lb.
		lb[0] = cast(ubyte)((ltb >> 56) & 0xFF) ;
		lb[1] = cast(ubyte)((ltb >> 48) & 0xFF) ;
		lb[2] = cast(ubyte)((ltb >> 40) & 0XFF) ;
		lb[3] = cast(ubyte)((ltb >> 32) & 0xFF) ;
		lb[4] = cast(ubyte)((ltb >> 24) & 0xFF) ;
		lb[5] = cast(ubyte)((ltb >> 16) & 0xFF) ;
		lb[6] = cast(ubyte)((ltb >> 8 ) & 0XFF) ;
		lb[7] = cast(ubyte)((ltb        & 0XFF));
		
		m ~= p;
		
		for(uint i = 0; i < zl; i++)
			m ~= z;
			
		m ~= lb;
		
		return m;
	}
	
	/**
	 * Hashes the byte array m.
	 */
	void AddToHash(ubyte[] m)
	{	
		//writeln(m);
		
		uint[16][] M;
		
		ulong N = m.length/64;
		
		for (uint i = 0; i < N; i++)
		{
			uint[16] block;
			
			for(uint j = 0; j < 16; j++)
			{
				ubyte[4] b = m[64*i + 4*j .. 64*i + 4*j + 4];
				
				uint x = 0;
				
				for (ubyte k = 0; k < 4; k++)
				{
					x = x << 8;
					x += b[k];
				}
				
				block[j] = x; 
			}
			
			M ~= block;
		}
		
		for (uint i = 0; i < N; i++)
		{
			//STEP 1
			uint[80] W;
			
			for (uint t = 0; t < 80; t++)
			{
				if (t <= 15)
					W[t] = M[i][t];
				else
					W[t] = ROTL(W[t-3] ^ W[t-8] ^ W[t-14] ^ W[t-16], 1);
			}
			//writeln(W);
			//STEP 2
			uint a = H[0];
			uint b = H[1];
			uint c = H[2];
			uint d = H[3];
			uint e = H[4];
			uint T;
			
			//STEP 3
			for (uint t = 0; t < 80; t++)
			{
				T = ROTL(a,5) + f(b,c,d,t) + e + K(t) + W[t];
				e = d;
				d = c;
				c = ROTL(b,30);
				b = a;
				a = T;
			}
			
			//STEP 4
			H[0] = a + H[0];
			H[1] = b + H[1];
			H[2] = c + H[2];
			H[3] = d + H[3];
			H[4] = e + H[4];
		}
	}
	
	public:
	
	this()
	{
		H = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0];
		buffl = 0;
	}
	
	void AddToContext(ubyte[] m)
	{
		buffl += m.length;
		buffer ~= m;
		uint r = buffer.length % 64; //remainder
		
		if (buffer.length >= 64)
			AddToHash(buffer[0 .. buffer.length-r]);
		
		if (buffer.length >= 64)
			buffer = buffer[buffer.length-r .. buffer.length];
	}
	
	void AddToContext(string m)
	{
		immutable char * c = toStringz(m);
		ubyte[] b;
		
		for (uint i = 0; c[i] != '\0'; i++)
			b ~= cast(ubyte)(c[i]);
			
		//writeln(b);
		
		AddToContext(b);
	}
	
	void End()
	{
		//writeln("H:", text(buffer));
		buffer = PadMessage(buffer, buffl);
		
		AddToHash(buffer);
	
		//return [H[0], H[1], H[2], H[3], H[4]];
	}
	
	string AsString()
	{
		auto writer = appender!string();
		formattedWrite(writer, "%08x%08x%08x%08x%08x",H[0], H[1], H[2], H[3], H[4]);
		//writefln("%x%x%x%x%x",zz[0],zz[1],zz[2],zz[3],zz[4]);
		
		return writer.data;
	}
	
	ubyte[] AsBytes()
	{
		return WordsToBytes(H);
	}
	
	ubyte[16] As128bitKey()
	{
		ubyte[16] k;
		for (uint i = 0; i < 4; i++)
		{
			for(uint j = 0; j < 4; j++)
			{
				k[4*i + j] = cast(ubyte)((H[i] >> (3-j)*8) & 0xFF) ;
			}
		}
		return k;
	}
	
	unittest
	{
		SHA1Context sha1test1 = new SHA1Context();
		ubyte[] input = [0x61, 0x62, 0x63];
		sha1test1.AddToContext(input);
		sha1test1.End();
		assert(sha1test1.AsString() == "a9993e364706816aba3e25717850c26c9cd0d89d");
		
		SHA1Context sha1test2 = new SHA1Context();
		sha1test2.AddToContext("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq");
		sha1test2.End();
		assert(sha1test2.AsString() == "84983e441c3bd26ebaae4aa1f95129e5e54670f1");
		
		SHA1Context sha1test3 = new SHA1Context();
		
		string millionA;
		for(uint i = 0; i < 1000000; i++)
			sha1test3.AddToContext("a");
		
		sha1test3.End();
		assert(sha1test3.AsString() == "34aa973cd4c4daa4f61eeb2bdbad27316534016f");
	}
	
}