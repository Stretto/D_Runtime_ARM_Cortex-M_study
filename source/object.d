module object;

alias immutable(char)[] string;

class Object
{
}

class TypeInfo
{
    /*const(void)[] init() nothrow pure const @safe
    {
        return null;
    }*/
}

class TypeInfo_Class : TypeInfo
{
    //ubyte[16] x;
    
    byte[] init; // class static initializer
                                 // (init.length gives size in bytes of class)
                                 //
    string name; /// class name
    void*[] vtbl; /// virtual function pointer table
    Interface[] interfaces; /// interfaces this class implements
    TypeInfo_Class base; /// base class
    void* destructor;
    void function(Object) classInvariant;
    enum ClassFlags : uint
    {
        isCOMclass = 0x1,
        noPointers = 0x2,
        hasOffTi = 0x4,
        hasCtor = 0x8,
        hasGetMembers = 0x10,
        hasTypeInfo = 0x20,
        isAbstract = 0x40,
        isCPPclass = 0x80,
    }
    ClassFlags m_flags;
    void* deallocator;
    OffsetTypeInfo[] m_offTi;
    void function(Object) defaultConstructor; // default Constructor

    immutable(void)* m_RTInfo; // data for precise GC
}