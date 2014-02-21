// object.d

module object;

alias size_t = uint;
alias string = immutable(char)[];

class Object
{ }

class TypeInfo
{ }

class TypeInfo_Class : TypeInfo
{
    ubyte[68] ignore;
}

class TypeInfo_Struct : TypeInfo
{
    ubyte[52] ignore;
}

class TypeInfo_Enum : TypeInfo
{  
    ubyte[20] ignore;
}