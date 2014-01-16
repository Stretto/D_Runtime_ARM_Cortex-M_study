module reference;

import trace;
import memory;

struct Reference(T)
{
    private struct Data
    {
	T Payload;
	size_t Count;
    }

    static Reference!T Create()
    {
	Reference!T r;
	
	r._data = cast(Data*)HeapMemory.Instance.Allocate(Data.sizeof);
	r._data.Count = 1;
	r._data.Payload = new T();
	
	return r;
    }

    Data* _data;
    
    private void Decrement()
    {	
	_data.Count--;
	
	if(_data.Count == 0)
	{
	    _data.Payload.destroy();
	    
	    HeapMemory.Instance.Free(_data);
	    _data = null;
	}
    }
    
    private void Increment()
    {	
	_data.Count++;
    }
    
    this(this)
    {
	Increment();
    }
    
    ~this()
    {
	Decrement();
    }
    
    void opAssign(typeof(this) rhs)
    {
        //This works based on the fact that rhs is a value type, was copied (and therefore incremented)
        //right before this call, and will be decrmented when this function loses scope.
        
        //this._data becomes rhs._data and will therefore contain the incremented reference count.
        //rhs._data becomes this's old _data and will be decremented when this function exits.
        
        Data* t = _data;
        _data = rhs._data;
        rhs._data = t;
    }
    
    @property size_t Count()
    {
	return _data.Count;
    }
    
    // This property is needed to support the 'alias Payload this' statement
    @property T Payload()
    {
	return _data.Payload;
    }
    
    alias Payload this;
}