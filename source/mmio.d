//           Copyright Michael V. Franklin 2014
// Distributed under the Boost Software License, Version 1.0.
//    (See copy at http://www.boost.org/LICENSE_1_0.txt)

/***************************************************************************
 Class for modeling memory-mapped I/O registers in D.  The idea for this
 came from a paper by Ken Smith titled "C++ Hardware Register Access Redux".
 At the time of this writing, a link to the could be found here:
 http://yogiken.files.wordpress.com/2010/02/c-register-access.pdf
 
 The idea, is that all of this logic will actually be evaluated at compile
 time and each BitField access will only cost a 2~3 instructions of assembly.
 However, I have yet to test this code.
 
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
     mixin Register!(0x20000000, 0);

     static BitField!(size_t, 31,  0, Policy.Read)      EntireRegister;
     static BitField!(ushort, 16,  1, Policy.Read)      Bits16To1;
     static BitField!(bool,    0,  0, Policy.Write)     Bit0;
     static BitField!(ubyte,  24, 17, Policy.ReadWrite) Bits24To17;
 }
 --------------------

 TODO:
 - Find a way to set multiple bit fields in one Load/Modify/Store cycle
 - Find a way to enforce 8-bit, 16-bit, or 32-bit access as specified in the
   datasheet
*/

module test;

/***********************************************************************
 Used to define access to a given bitfield.  Usuall microcontrollers 
 define some registers/bitfields as read-only or write-only, and this
 will enforce such a policy at compile time.  Cool!
*/
enum Policy
{
    Read,
    Write,
    ReadWrite
}

/***********************************************************************
 Gets register's value by address
*/
private auto GetValue(size_t address)
{
    return *(cast(size_t*)address);
}

/***********************************************************************
 Sets register's value by address
*/
private void SetValue(size_t address, size_t value)
{
    *(cast(size_t*)address) = value;
}

/***********************************************************************
 Template for modeling a 32-bit register
*/
mixin template Register(size_t address, size_t resetValue = 0)
{
    private alias typeof(this) ThisRegister;
    
    /***********************************************************************
      Reset this register to its initial reset value
    */
    private static void Reset()
    {
        Value = resetValue;
    }
    
    /***********************************************************************
      Gets all bits in the register as a single value.  It's only exposed
      privately to prevent circumventing the access policy.
    */
    private static @property auto Value()
    {
        return GetValue(address);
    }

    /***********************************************************************
      Sets all bits in the register as a single value.  It's only exposed
      privately to prevent circumventing the access policy.
    */
    private static @property void Value(size_t value)
    {
        SetValue(address, value);
    }

    /***********************************************************************
     Provides access to a limited range of bits in this register
    */
    struct BitField(TReturnType, size_t msb, size_t lsb, Policy policy)
    {
	/***************************************************************
	 Index of this BitField's most significant Bit
	*/
        static @property auto MSBIndex()
        {
            return msb >= lsb ? msb : lsb;
        }

        /***********************************************************************
	 Index of this BitField's least significant Bit
	*/
        static @property auto LSBIndex()
        {
            return lsb <= msb ? lsb : msb;
        }

        /***********************************************************************
	 Total number of bits in this BitField
	*/
        static @property auto NumOfBits()
        {
            return MSBIndex - LSBIndex + 1;
        }

        /***********************************************************************
	 Gets a bit-mask for this bit field for masking just this BitField out
	 of the register.
	*/
        @property auto BitMask()
        {
            return ((1 << NumOfBits()) - 1) << LSBIndex();
        }

	// Only add a "getter" if the policy supports it.
        static if (policy == Policy.Read || policy == Policy.ReadWrite)
        {
	    /***********************************************************************
	     Get this BitField's value
	    */
            @property TReturnType Value()
            {
                return cast(TReturnType)((ThisRegister.Value & BitMask) >> LSBIndex);
            }
        }

	// Only add a "setter" if the policy supports it.
        static if (policy == Policy.Write || policy == Policy.ReadWrite)
        {
	    /***********************************************************************
	     Set this BitField's value
	    */
            @property void Value(TReturnType value)
            {
                ThisRegister.Value = (ThisRegister.Value & ~BitMask) | ((cast(size_t)value) << LSBIndex);
            }
        }
    }

    /***********************************************************************
      Gets this register's reset value as specified in the datasheet
    */
    static @property auto ResetValue()
    {
        return resetValue;
    }
}