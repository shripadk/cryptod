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

/**
 * Authors: Andrey A. Popov, andrey.anat.popov@gmail.com
 */

module cryptod.prng.ctrblockcipher;

import cryptod.blockcipher.blockcipher;

import cryptod.prng.prng;

/*
NOTE: I first need to force every blockcipher to have a fixed block size before this is usable.
*/


class CTRBlockCipher : PRNG
{
	BlockCipher bc;
	ulong counter;
	this(BlockCipher bc, ulong seed)
	{
		this.bc = bc;
		counter = seed;
	}
	
	uint getNextInt()
	{
		ubyte[] input = new ubyte[bc.blockSize];
		
		
		
		for(uint i = 0; i < bc.blockSize && i < 64; i++)
		{
			input[i] = (counter >> i) & 0xff;
		}
		
		ubyte[] output = bc.Cipher(input);
		
		
		uint a = 0;
		
		for(uint i = 0; i < 4 && i < bc.blockSize; i++)
		{
			a <<= 8;
			a += output[i];
		}
		
		counter++;
		return a;
	}
}

unittest
{
	import cryptod.blockcipher.aes;
	import std.stdio;
	import std.datetime;
	
	ulong t = Clock.currTime().stdTime();
	
	ubyte[] key = [(t&0xff),(t>>1)&0xff,(t>>2)&0xff,(t>>3)&0xff,(t>>4)&0xff,(t>>5)&0xff,(t>>6)&0xff,(t>>7)&0xff
	,(t>81)&0xff,(t>>9)&0xff,(t>>10)&0xff,(t>>11)&0xff,(t>>12)&0xff,(t>>13)&0xff,(t>>14)&0xff,(t>>15)&0xff];
	
	AES a = new AES(key);
	CTRBlockCipher ctbc = new CTRBlockCipher(a,1);
	
	import cryptod.tests.prngtest;
	FrequencyTest ft = new FrequencyTest(ctbc);
	
	assert(ft.run());
	
	RunsTest rt = new RunsTest(ctbc);
	
	assert(rt.run());
	
	writeln("Counter Mode BlockCipher unittest passed.");
}