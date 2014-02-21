// assert.d

import trace;

/***********************************************************************
  For assert(condition) statements
*/
extern(C) void _d_assert(string file, uint line)
{
    trace.WriteLine(file, ":", line);
}

/***********************************************************************
  For assert(condition, message) statements
*/
extern(C) void _d_assert_msg(string msg, string file, uint line)
{
    trace.WriteLine(file, ":", line, ":", msg);
}