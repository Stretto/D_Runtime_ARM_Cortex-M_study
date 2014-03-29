module test;

import mmio;

final abstract class MyRegister
{
    mixin Register!(0x2000_1000, 0x0000_0000, Access.Word);

    alias EntireRegister = BitField!(31, 0, Mutability.rw);
    alias Bits31To17     = BitField!(17, 2, Mutability.rw);
    alias Bits15to8      = BitField!(15, 8, Mutability.rw);
    alias Bits1to0       = BitField!( 1, 0, Mutability.rw); 
    alias Bit1           = Bit!(1, Mutability.rw);
    alias Bit0           = Bit!(0, Mutability.rw);
}
