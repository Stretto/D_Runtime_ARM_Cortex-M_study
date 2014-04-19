module exception;

import trace;

/***********************************************************************
  For assert(condition) statements
*/
extern(C) void _d_assert(string file, uint line)
{
    trace.writeLine(file, ":", line);
}

/***********************************************************************
  For assert(condition, message) statements
*/
extern(C) void _d_assert_msg(string msg, string file, uint line)
{
    trace.writeLine(file, ":", line, ":", msg);
}

/***********************************************************************
  Assert with ModuleInfo
*/
// void _d_assertm(ModuleInfo* m, uint line)
// {
//     trace.writeLine(m.name, ":", line);
// }


