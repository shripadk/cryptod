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

module cryptod.blockcipher.blockcipher;

/**
 * All block ciphers have a set of common functionality
 * let B be a block cipher, and let P be some plaintext
 * where P.length == B.blockSize 
 * 
 * Let C = B.Cipher(P) , then P == B.InvCipher(C)
 */
interface BlockCipher
{
	public:
	///
	@property uint blockSize();
	
	///
	ubyte[] Cipher(ubyte[] P);
	///
	ubyte[] InvCipher(ubyte[] C);
}

///This error is returned when you input a P of an infavourable blocksize.
class BadBlockSizeException : Exception
{
	this(string msg)
	{
		super(msg);
	}
}