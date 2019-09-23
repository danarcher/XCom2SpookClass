class UIScreenListener_UIAvengerHUD_Spook
    extends UIScreenListener
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

event OnInit(UIScreen Screen)
{
    local Object This;

    This = self;
    `SPOOKLOG("OnInit");
    `XEVENTMGR.RegisterForEvent(This, 'OverrideGetPersonnelStatusSeparate', OnOverrideGetPersonnelStatusSeparate, ELD_Immediate);
}

event OnRemoved(UIScreen Screen)
{
    local Object This;

    This = self;
    `SPOOKLOG("OnRemoved");
    `XEVENTMGR.UnRegisterFromAllEvents(This);
}

function EventListenerReturn OnOverrideGetPersonnelStatusSeparate(Object EventData, Object EventSource, XComGameState NewGameState, Name EventID)
{
    return class'XComGameState_HeadquartersProjectSpookTraining'.static.OnOverrideGetPersonnelStatusSeparate(EventData, EventSource, NewGameState, EventID);
}

defaultproperties
{
    ScreenClass = UIAvengerHUD
}
