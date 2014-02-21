// assert.d

import trace;

extern(C) void _d_assert(string file, uint line)
{
    trace.WriteLine(file, line);
}

extern(C) void _d_assert_msg(string msg, string file, uint line)
{
    trace.WriteLine(file, line, msg);
}
