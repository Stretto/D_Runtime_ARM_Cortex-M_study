module object;

import memory;
import trace;

alias uint               size_t;
alias immutable(char)[]  string;

class Object
{
    new(size_t nBytes)
    {
        void* p;

        p = HeapMemory.Instance.Allocate(nBytes);
        
        if (p == null)
        {
	    //TODO:
            //throw new OutOfMemoryError();
        }
        
        return p;
    }
    
    void destroy()  
    {
	auto ppv = cast(void**)this;
	auto pc = cast(ClassInfo*) *ppv;
	auto classInfo = *pc;
	if (classInfo.destructor)
	{
	    (cast(void function (Object)) classInfo.destructor)(cast(Object) this); // call destructor
        }
	
	HeapMemory.Instance.Free(cast(void*)this);
    }
}

class TypeInfo
{
    const(void)[] init() nothrow pure const @safe 
    { 
	return null; 
    }
}

struct OffsetTypeInfo
{
    size_t   offset;    /// Offset of member from start of object
    TypeInfo ti;        /// TypeInfo for this member
}

struct Interface
{
    TypeInfo_Class   classinfo;  /// .classinfo for this interface (not for containing class)
    void*[]     vtbl;
    size_t      offset;     /// offset to Interface 'this' from Object 'this'
}

class TypeInfo_Class : TypeInfo
{
    byte[]      init;           // class static initializer
                                 // (init.length gives size in bytes of class)
                                 //
    string      name;           /// class name
    void*[]     vtbl;           /// virtual function pointer table
    Interface[] interfaces;     /// interfaces this class implements
    TypeInfo_Class   base;           /// base class
    void*       destructor;
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
    void*       deallocator;
    OffsetTypeInfo[] m_offTi;
    void function(Object) defaultConstructor;   // default Constructor

    immutable(void)* m_RTInfo;        // data for precise GC
}

alias TypeInfo_Class ClassInfo;

class TypeInfo_Struct : TypeInfo
{
    string name;
    void[] m_init;      // initializer; init.ptr == null if 0 initialize
    
    @safe pure nothrow
    {
	size_t   function(in void*)           xtoHash;
	bool     function(in void*, in void*) xopEquals;
	int      function(in void*, in void*) xopCmp;
	char[]   function(in void*)           xtoString;

	enum StructFlags : uint
	{
	    hasPointers = 0x1,
	}
	StructFlags m_flags;
    }
    void function(void*)                    xdtor;
    void function(void*)                    xpostblit;

    uint m_align;
    immutable(void)* m_RTInfo;                // data for precise GC
    
    override const(void)[] init() nothrow pure const @safe { return m_init; }
}

class TypeInfo_Typedef : TypeInfo
{
    TypeInfo base;
    string   name;
    void[]   m_init;
    
    override const(void)[] init() nothrow pure const @safe { return m_init.length ? m_init : base.init(); }
}

class TypeInfo_Enum : TypeInfo_Typedef
{

}

bool _xopEquals(in void*, in void*)
{
    return false;
}



class TypeInfo_k : TypeInfo
{
    
}

