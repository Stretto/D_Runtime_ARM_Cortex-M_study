module isr;

import trace;

alias void function() ISR;

extern extern(C) void OnReset();
extern extern(C) void OnHardFault();

private void DoNothing()
{ 
    Trace.WriteLine("Nothing");
    while(true)
    { }
}

private void _onReset()
{
    OnReset();
}

private void _onHardFault()
{
    OnHardFault();
}

//Must be stored as second 32-bit word in .text section
extern(C) immutable ISR[16] ISRVectorTable =
[
    &_onReset,
    &DoNothing,
    &_onHardFault,
    &DoNothing,
    &DoNothing,
    &DoNothing,
    &DoNothing,
    &DoNothing,
    &DoNothing,
    &DoNothing,
    &DoNothing,
    &DoNothing,
    &DoNothing,
    &DoNothing,
    &DoNothing,
    &DoNothing
];