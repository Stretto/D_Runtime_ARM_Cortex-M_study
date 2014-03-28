//           
// Copyright (c) 2014 Michael V. Franklin
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/***************************************************************************
 Implementation of memory-mapped I/O registers in D.  The idea for this
 came from a paper by Ken Smith titled "C++ Hardware Register Access Redux".
 At the time of this writing, a link to the could be found here:
 http://yogiken.files.wordpress.com/2010/02/c-register-access.pdf
 
 The idea, is that all of this logic will actually be evaluated at compile
 time and each BitField access will only cost a 2~3 instructions of assembly.
 
 Right now, this will probably only work for 32-bit platforms. I'd like to 
 modify this so it is portable to even 16, and 8 bit platforms, but one step 
 at a time.
 
 Using this code should allow one to go directly from datasheet to code as
 shown below.
 Examples:
 --------------------
 // Declare register with it's contained fields like this
 struct MyRegister
 {
     mixin Register!(0x2000_0000, 0x0000_0000);

     alias BitField!(size_t, 31,  0, Mutability.Read)      EntireRegister;
     alias BitField!(ushort, 16,  1, Mutability.Read)      Bits16To1;
     alias Bit     !(             0, Mutability.Write)     Bit0;
     alias BitField!(ubyte,  24, 17, Mutability.ReadWrite) Bits24To17;
 }
 --------------------

 TODO:
 - Find a way to set multiple bit fields in one Load/Modify/Store cycle
 - Find a way to enforce 8-bit, 16-bit, or 32-bit access as specified in the
   datasheet
*/
module mmio;

import trace;

enum Access
{    
    /****************************************************************************
     Register can only be accessed as a 32-bit word
    */
    Word = 4,
    
    /****************************************************************************
     Register can be accessed as individual bytes or 32-bit words
    */
    Byte_Word = 1 | Word,
    
    /****************************************************************************
     Register can be accessed as 16-bit halfwords or 32-bit words
    */
    HalfWord_Word = 2 | Word,
    
    /****************************************************************************
     Register can be accessed as individual bytes, 16-bit halfwords, or 32-Bit
     words
    */
    Byte_HalfWord_Word = 1 | 2 | Word
}

/****************************************************************************
   Mutability (Read/Write policy) as specified in the datasheet
   see pp. 57 of the reference manual
*/
enum Mutability
{
    /****************************************************************************
     Software can read and write to these bits.
    */
    rw,
    
    /****************************************************************************
      Software can only read these bits
    */
    r,
    
    /****************************************************************************
     Software can only write to this bit. Reading the bit returns the reset
     value.
    */
    w,
    
    /****************************************************************************
     Software can read as well as clear this bit by writing 1. Writing '0' has
     no effect on the bit value.
    */
    rc_w1,
    
    /****************************************************************************
     Software can read as well as clear this bit by writing 0. Writing '1' has
     no effect on the bit value.
    */
    rc_w0,
    
    /****************************************************************************
     Software can read this bit. Reading this bit automatically clears it to '0'.
     Writing '0' has no effect on the bit value
    */
    rc_r,
    
    /****************************************************************************
     Software can read as well as set this bit. Writing '0' has no effect on the
     bit value.
    */
    rs,
    
    /****************************************************************************
     Software can read this bit. Writing '0' or '1' triggers an event but has no
     effect on the bit value.
    */
    rt_w
}

/***********************************************************************
 Provides information about a bit field given the specified bit indices
*/
mixin template BitFieldDimensions(size_t bitIndex0, size_t bitIndex1)
{
    /***************************************************************
        Index of this BitField's most significant Bit
    */
    static @property auto mostSignificantBitIndex() pure
    {
        return bitIndex0 >= bitIndex1 ? bitIndex0 : bitIndex1;
    }

    /***********************************************************************
        Index of this BitField's least significant Bit
    */
    static @property auto leastSignificantBitIndex() pure
    {
        return bitIndex0 <= bitIndex1 ? bitIndex0 : bitIndex1;
    }

    /***********************************************************************
        Total number of bits in this BitField
    */
    static @property auto numberOfBits() pure
    {
        return mostSignificantBitIndex - leastSignificantBitIndex + 1;
    }

    /***************************************************************
      Determineds if bitIndex is a valid index for this register
      
      Returns: true if the bitIndex is valid, false if not
    */
    private static bool isValidBitIndex(size_t bitIndex) pure
    {
        return bitIndex >= 0 && bitIndex < (size_t.sizeof * 8);
    }

    /***********************************************************************
        Gets a bit-mask for this bit field for masking just this BitField out
        of the register.
    */
    static @property auto bitMask() pure
    {
        return ((1 << numberOfBits) - 1) << leastSignificantBitIndex;
    }
    
    private static size_t maskValue(T)(T value) pure
    {
        return (value << leastSignificantBitIndex) & bitMask;
    }
    
    /***********************************************************************
      Whether or not this bitfield is aligned to an even multiple of bytes
    */
    private static @property bool isByteAligned() pure
    {
        return ((mostSignificantBitIndex + 1) % 8) == 0 
            && (leastSignificantBitIndex % 8) == 0;
    }
    
    /***********************************************************************
      Whether or not this bitfield is aligned to an even multiple 16-Bit
      half-words
    */
    private static @property bool isHalfWordAligned() pure
    {
        return ((mostSignificantBitIndex + 1) % 16) == 0 
            && (leastSignificantBitIndex % 16) == 0;
    }
    
    /***********************************************************************
      Gets the address of this bitfield at its aligned byte's location
    */
    private static @property size_t byteAlignedAddress() pure
    {
        return address + (leastSignificantBitIndex / 8);
    }
    
    /***********************************************************************
      Gets the address of this bitfield at its aligned half-word's location
    */
    private static @property size_t halfWordAlignedAddress() pure
    {
        return address + (leastSignificantBitIndex / 16);
    }
    
    private static @property size_t bitBandAddress() pure
    {
        //TODO: need to find some way to externalize this. 
        // From reference manual pp. 69
        // bit_word_addr = bit_band_base + (byte_offset x 32) + (bit_number × 4)
        
        static if (address >= 0x4000_0000 && address <= 0x400F_FFFF)
        {
            return 0x4200_0000 + ((address - 0x4000_0000) * 32) + (leastSignificantBitIndex * 4);
        }
        else static if (address >= 0x2000_0000 && address <= 0x200F_FFFF)
        {
            return 0x2200_0000 + ((address - 0x2000_0000) * 32) + (leastSignificantBitIndex * 4);
        }
        else
        {
            static assert(false, "Not a valid bit band address");
        }
    }
}

/***********************************************************************
 Provides mutability enforcement for a bitfield.
*/
mixin template BitFieldMutation(Mutability mutability, ValueType_)
{
    alias ValueType = ValueType_;

    // Sanity check: ensure bit indices are of within the size of the register
    static assert(isValidBitIndex(bitIndex0) && isValidBitIndex(bitIndex1), "Invalid bit index");

    // Ensure correct mutability for the size of the bitfield.  Some policies
    // are only relevant to single bits
    static assert
    (
        // a single bit
        numberOfBits == 1 
        
        // Only policies r, w, and rw are valid for bitfieds greater than
        // a single bit.  If numberOfBits is greater than 1 and not r, w,
        // or rw, it's an error.
        || mutability == Mutability.r   
        || mutability == Mutability.w 
        || mutability == Mutability.rw

        , "Mutability is only applicable to a single bit"
    );
    
    /***********************************************************************
        Whether or not the mutability policy allows for reading the bit/
        bitfield's value
    */
    private static @property canRead()
    {
        return mutability == Mutability.r     || mutability == Mutability.rw   
            || mutability == Mutability.rt_w  || mutability == Mutability.rs 
            || mutability == Mutability.rc_r  || mutability == Mutability.rc_w0
            || mutability == Mutability.rc_w1;
    }
    
    /***********************************************************************
        Whether or not the mutability policy allows for writing the bit/
        bitfield's value
    */
    private static @property canWrite()
    {
        return mutability == Mutability.w     || mutability == Mutability.rw 
            || mutability == Mutability.rc_w0 || mutability == Mutability.rc_w1
            || mutability == Mutability.rs;
    }
    
    /***********************************************************************
        Whether or not the mutability policy allows for only setting or
        clearing a bit
    */
    private static @property canOnlySetOrClear()
    {
        return mutability == Mutability.rc_w0 || mutability == Mutability.rc_w1 
            || mutability == Mutability.rs;
    }

    // if mutabililty policy allows for reading the bit/bitfield's value
    static if (canRead)
    {
        /***********************************************************************
            Get this BitField's value
        */
        static @property ValueType value()
        {
            static if (numberOfBits == 1)
            {
                return *(cast(shared ValueType*)bitBandAddress);
            }
            else static if (isHalfWordAligned 
                && (access == Access.Byte_HalfWord_Word || access == Access.HalfWord_Word))
            {
                return *(cast(shared ValueType*)halfWordAlignedAddress);
            }
            else static if (isByteAligned 
                && (access == Access.Byte_HalfWord_Word || access == Access.Byte_Word))
            {
                return *(cast(shared ValueType*)byteAlignedAddress);
            }
            else
            {
                return cast(ValueType)((*(cast(shared size_t*)address) & bitMask) >> leastSignificantBitIndex);
            }
        }
    }

    // If mutability allows setting the bit/bitfield in some way
    static if (canWrite)
    {
        // Can modify the bit/bitfield's value, but only with a set or clear
        static if (canOnlySetOrClear)
        {
            static if (mutability == Mutability.rc_w0)
            {
                /***********************************************************************
                    Clears bit by writing a '0'
                */
                static void clear()
                {
                    value = false;
                }
            }
            else static if (mutability == Mutability.rc_w1)
            {
                /***********************************************************************
                    Clears bit by writing a '1'
                */
                static void clear()
                {
                    value = true;
                }
            }
            else static if (mutability == Mutability.rs)
            {
                /***********************************************************************
                    Sets bit by writing a '1'
                */
                static void set()
                {
                    value = true;
                }
            }
        
            // 'value' is private in favor of clear/set methods
            private:
        }
        
        /***********************************************************************
            Set this BitField's value
        */
        static @property void value(ValueType value_)
        { 
            //TODO: This logic is a duplication of logic below.  Try to consolidate.
            
            // If only a single bit, use bit banding
            static if (numberOfBits == 1)
            {
                *(cast(shared ValueType*)bitBandAddress) = value_;
            }
            // if can access data with perfect halfword alignment
            else static if (isHalfWordAligned 
                && (access == Access.Byte_HalfWord_Word || access == Access.HalfWord_Word))
            {
                *(cast(shared ValueType*)halfWordAlignedAddress) = value_;
            }
            // if can access data with perfect byte alignment
            else static if (isByteAligned 
                && (access == Access.Byte_HalfWord_Word || access == Access.Byte_Word))
            {
                *(cast(shared ValueType*)byteAlignedAddress) = value_;
            }
            // catch-all.  No optimizations possible, so just do read-modify-write
            else
            {
                *(cast(shared size_t*)address) = (*(cast(shared size_t*)address) & ~bitMask) | ((cast(size_t)value_) << leastSignificantBitIndex);
            }
        }
    }
}

/***********************************************************************
 Provides access to a limited range of bits in a register.  This
 version automatically determines the return type based on the size
 of the bitfield.
*/
mixin template BitFieldImplementation(size_t bitIndex0, size_t bitIndex1, Mutability mutability)
{    
    mixin BitFieldDimensions!(bitIndex0, bitIndex1);
    
    //TODO: do a test to determine if limiting return type to something less
    // than the natural word size results in slower code.  Perhaps it's better
    // to simply make everything default to uint/size_t
    
    // determine the return type based on the number of bits
    static if (numberOfBits <= 1)
    {
        alias ValueType = bool;
    }
    else static if (numberOfBits <= 8)
    {
        alias ValueType = ubyte;
    }
    else static if (numberOfBits <= 16)
    {
        alias ValueType = ushort;
    }
    else static if (numberOfBits <= 32)
    {
        alias ValueType = uint;
    }
    
    mixin BitFieldMutation!(mutability, ValueType);
}

/***********************************************************************
 Provides access to a limited range of bits in a register. User 
 must specify the return type.
*/
mixin template BitFieldImplementation(size_t bitIndex0, size_t bitIndex1, Mutability mutability, ValueType)
{    
    mixin BitFieldDimensions!(bitIndex0, bitIndex1);
    mixin BitFieldImplementation!(mutability, ValueType);
}

/***********************************************************************
 Template for modeling a register
*/
mixin template Register(size_t peripheralAddress, size_t addressOffset, Access access_ = Access.Byte_HalfWord_Word, size_t resetValue_ = 0)
{    
    /***********************************************************************
      Gets this register's address as specified in the datasheet
    */
    static @property auto address() pure
    {
        return peripheralAddress + addressOffset;
    }
    
    /***********************************************************************
      Gets the data width(byte, half-word, word) access policy for this
      register.
    */
    static @property auto access() pure
    {
        return access_;
    }
    
    /***********************************************************************
      Gets this register's reset value as specified in the datasheet
    */
    static @property auto resetValue() pure
    {
        return resetValue_;
    }

    /***********************************************************************
      Reset this register to its initial reset value
    */
    private static void reset()
    {
        value = resetValue;
    }
    
    /***********************************************************************
      Gets all bits in the register as a single value.  It's only exposed
      privately to prevent circumventing the access mutability.
    */
    private static @property auto value()
    {        
        return *(cast(shared size_t*)address);
    }

    /***********************************************************************
      Sets all bits in the register as a single value.  It's only exposed
      privately to prevent circumventing the access mutability.
    */
    private static @property void value(size_t value)
    {        
        *(cast(shared size_t*)address) = value;
    }
    
    private static size_t combineValues(T...)()
    {    
        static if (T.length > 0)
        {
            //TODO: ensure T[0] is a child of this register
            //static assert(false, __traits(parent, T[0]).stringof);
        
            static assert(__traits(compiles, T[0].value = T[1]), "Invalid assignment");
        
            // merge all specified bitFields and assign to this register's value
            return T[0].maskValue(T[1]) | combineValues!(T[2..$])();
        }
        else
        {
            // no more values left to combine
            return 0;
        }
    }
    
    private static size_t combineMasks(T...)()
    {
        static if (T.length > 0)
        {        
            // merge all specified bitFields and assign to this register's value
            return T[0].bitMask | combineMasks!(T[2..$])();
        }
        else
        {
            // no more values left to combine
            return 0;
        }
    }
     
    static void setValue(T...)()
    {            
        // number of arguments must be even
        static assert(!(T.length & 1), "Wrong number of arguments");
        
        value = (value & ~combineMasks!(T)()) | combineValues!(T)();
    }

    /***********************************************************************
      A range of bits in the this register.  Return type is automatically
      determined.
    */
    final abstract class BitField(size_t bitIndex0, size_t bitIndex1, Mutability mutability)
    {
	mixin BitFieldImplementation!(bitIndex0, bitIndex1, mutability);
    }
    
    /***********************************************************************
      A range of bits in the this register.  User must specify the return
      type.
    */
    final abstract class BitField(size_t bitIndex0, size_t bitIndex1, Mutability mutability, ValueType)
    {
        mixin BitFieldImplementation!(bitIndex0, bitIndex1, mutability, ValueType);
    }
    
    /***********************************************************************
      A special case of BitField (a single bit).   Return type is automatically
      determined.
    */
    final abstract class Bit(size_t bitIndex, Mutability mutability)
    {
	mixin BitFieldImplementation!(bitIndex, bitIndex, mutability);
    }
    
    /***********************************************************************
      A special case of BitField (a single bit). User must specify the return
      type.
    */
    final abstract class Bit(size_t bitIndex, Mutability mutability, ValueType)
    {
        mixin BitFieldImplementation!(bitIndex, bitIndex, mutability, ValueType);
    }
}

