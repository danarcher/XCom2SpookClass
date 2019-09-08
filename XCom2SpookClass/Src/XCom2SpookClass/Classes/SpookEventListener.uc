// Allows several registrations for the same event with different deferrals.
class SpookEventListener
    extends Object
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var delegate<SpookEventListenerCallback> EventHandler;

delegate SpookEventListenerCallback(Object EventData, Object EventSource, XComGameState GameState, Name EventID);

function RegisterForEvent(Name EventID, delegate<SpookEventListenerCallback> Callback, EventListenerDeferral Deferral)
{
    local Object This;

    This = self;
    EventHandler = Callback;
    `XEVENTMGR.RegisterForEvent(This, EventID, RawEventHandler, Deferral);
}

function EventListenerReturn RawEventHandler(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    if (EventHandler != none)
    {
        EventHandler(EventData, EventSource, GameState, EventID);
    }
    return ELR_NoInterrupt;
}
