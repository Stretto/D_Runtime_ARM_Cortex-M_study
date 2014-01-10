//           Copyright Michael V. Franklin 2014
// Distributed under the Boost Software License, Version 1.0.
//    (See copy at http://www.boost.org/LICENSE_1_0.txt)

module memory;

import trace;

extern(C) pure void* memcpy(void* dest, in void* src, size_t n)
{    
    ubyte* src8 = cast(ubyte*)src;
    ubyte* dest8 = cast(ubyte*)dest;

    while(n > 0)
    {
	*dest8 = *src8;
	dest8++;
	src8++;
	n--;
    }
    
    return dest;
}

extern(C) pure void* memset(void* dest, in ubyte value, size_t n)
{
    ubyte* dest8 = cast(ubyte*)dest;
    
    while(n > 0)
    {
	*dest8 = value;
	dest8++;
	n--;
    }
    
    return dest;
}

extern(C) int memcmp (in void * ptr1, in void * ptr2, size_t num )
{
    Trace.WriteLine("memcmp");
    return 0;
}

private size_t Normalize(size_t nBytes)
{
    return ((nBytes + (size_t.sizeof - 1)) & ~0b11u);
}

struct BlockData(T)
{
    private uint _data;
    
    @property T* Next()
    {
	return cast(T*)(_data & ~0b11u);
    }
    
    @property void Next(T* value)
    {
	_data = (cast(uint)(value) & ~0b11u) | (_data & 0b11u);
    }
    
    @property bool IsFree()
    {
	return (_data & 1u) == 0;
    }
    
    @property bool IsAllocated()
    {
	return !IsFree;
    }
    
    void Free()
    {
	_data &= ~1u;
    }
    
    void Allocate()
    {
	_data |= 1u;
    }
}

private struct Block
{
    BlockData!Block _data;
    
    private void CombineWithNext()
    {
	//Swallow adjacent free blocks
	while(Next.IsFree)
	{
	    _data.Next = Next.Next;
	}
    }
    
    private @property uint MemoryAddress()
    {
	return cast(uint)Memory;
    }
        
    @property bool IsFree()
    {
	return _data.IsFree;
    }
    
    @property bool IsAllocated()
    {
	return _data.IsAllocated;
    }
    
    @property Block* Next()
    {
	return _data.Next;
    }
    
    @property uint Address()
    {
	return cast(uint)(&this);
    }
    
    @property bool IsLast()
    {
	return Next == null;
    }
    
    void Resize(in size_t nBytes)
    {
	// backup current _next pointer
	Block* next = Next;
	
	// move next pointer
	_data.Next = cast(Block*)(MemoryAddress + Normalize(nBytes));
	_data.Next._data.Free(); //ensure it's marked as free
	
	// link to backup
	_data.Next._data.Next = next;
    }
    
    void Init(in size_t nBytes)
    {
	Resize(nBytes);
	
	//Last block points to nothing, and is marked as allocated
	Next._data.Next = null;
	Next._data.Allocate();
    }
    
    @property size_t nBytes()
    {
	if (IsLast)
	{
	    return 0;
	}
	
	return Next.Address - MemoryAddress;
    }
    
    // Get a pointer to the beginning of the usable memory 
    @property void* Memory()
    {
	return cast(void*)(Address + Block.sizeof);
    }
    
    void Free()
    {
	// Mark this block free
	_data.Free();
	
	// Try to combine with adjacent blocks to remove fragmentation
	CombineWithNext();
    }
    
    bool Allocate(in size_t nBytes)
    {
	bool succeeded = false;
	
	if (IsFree)
	{
	    // Ensure that this block has been expanded to its maximum size
	    CombineWithNext();
	    
	    //If this block is large enough
	    if(this.nBytes >= nBytes)
	    {
		_data.Allocate();
		
		//Compress this block if it is more than enough
		if (this.nBytes > nBytes)
		{
		    Resize(nBytes);
		}
		
		succeeded = true;
	    }
	}
	
	return succeeded;
    }
}

struct HeapMemory
{
    private align Block* firstFree;
    private align Block base;
    
    static @property HeapMemory* Instance()
    {
	static __gshared HeapMemory* instance;

	if(!instance)
	{
	    instance = cast(HeapMemory*)0x20000000;
	    instance.Init(128000);
	}

	return instance;
    }
    
    private Block* GetBlock(in void* memory)
    {
	byte* block = cast(byte*)memory;
	block -= Block.sizeof;
	
	return cast(Block*)block;
    }
    
    private void UpdateFirstFreeBlock(Block* block)
    {
	if (firstFree.IsAllocated || block.Address < firstFree.Address)
	{
	    //find the next free block
	    while(!block.IsLast && !block.IsFree)
	    {
		block = block.Next;
	    }
	    
	    //while we're here, try to expand block
	    if (block.IsFree)
	    {
		block.CombineWithNext();
	    }
	    
	    //Mark as the first free block
	    firstFree = block;
	}
    }
    
    void Init(in size_t nBytes)
    {
	base.Init(nBytes);
	firstFree = &base;
    }
    
    void* Allocate(in size_t nBytes)
    {
	void* memory = null;
    
	//Start at the first free block
	Block* block = firstFree;
	
	//Iterate through the list until we reach the last block
	while(!block.IsLast)
	{	    
	    // if allocation succeeded
	    if (block.Allocate(nBytes))
	    {		
		// Get the memory addres of this block so we
		// can return it to the caller
		memory = block.Memory;
		
		// This block has been allocated, so if it was the 
		// first free block, we have to update the first free block
		// to the next free block
		UpdateFirstFreeBlock(block);
		
		break;
	    }
	}
	
	return memory;
    }
    
    void Free(in void* memory)
    {
	//Get a pointer to the block that owns this memory
	Block* block = GetBlock(memory);
	
	// Free the block
	block.Free();
	
	//Update the first free block to save scanning time
	UpdateFirstFreeBlock(block);
    }
    
    void Print()
    {
	Block* block = &base;
	while(!block.IsLast)
	{
	    Trace.Write(block.Address);
	    Trace.Write(": ");
	    Trace.Write(block.nBytes);
	    Trace.Write(": ");
	    if(block.IsAllocated)
	    {
		Trace.Write("1");
	    }
	    else
	    {
		Trace.Write("0");
	    }
	    
	    Trace.WriteLine("");
	    
	    block = block.Next;
	}
    }
}
