class UIScreenListener_TacticalHUD_Spook
    extends UIScreenListener
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var SpookDetectionManager DetectionManager;
//var SpookSoundManager SoundManager;

event OnInit(UIScreen Screen)
{
    local Object This;
    This = self;
    `SPOOKLOG("OnInit");
    `XEVENTMGR.RegisterForEvent(This, 'GetEvacPlacementDelay', OnGetEvacPlacementDelay, ELD_Immediate);

    DetectionManager = new class'SpookDetectionManager';
    DetectionManager.OnInit();
    //SoundManager.OnInit();
}

function EventListenerReturn OnGetEvacPlacementDelay(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local LWTuple EvacDelayTuple;
    local XComGameState_HeadquartersXCom XComHQ;
    local XComGameStateHistory History;
    local XComGameState_Unit UnitState;
    local bool bOnlySpecialSoldiersFound;
    local int SquadIndex;

    EvacDelayTuple = LWTuple(EventData);
    if(EvacDelayTuple == none)
    {
        `SPOOKLOG("OnGetEvacPlacementDelay: No tuple!");
        return ELR_NoInterrupt;
    }

    if(EvacDelayTuple.Id != 'DelayedEvacTurns')
    {
        `SPOOKLOG("OnGetEvacPlacementDelay: Bad ID!");
        return ELR_NoInterrupt;
    }

    if(EvacDelayTuple.Data[0].Kind != LWTVInt)
    {
        `SPOOKLOG("OnGetEvacPlacementDelay: Not an integer!");
        return ELR_NoInterrupt;
    }

    `SPOOKLOG("OnGetEvacPlacementDelay: Checking soldiers");
    XComHQ = `XCOMHQ;
    History = `XCOMHISTORY;

    bOnlySpecialSoldiersFound = true;
    for (SquadIndex = 0; SquadIndex < XComHQ.Squad.Length; SquadIndex++)
    {
        UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Squad[SquadIndex].ObjectID));
        if (UnitState != none && UnitState.GetSoldierClassTemplateName() == 'Spook')
        {
            `SPOOKLOG("OnGetEvacPlacementDelay: Found a Spook, -1");
            EvacDelayTuple.Data[0].i -= 1; // go negative if we fire before LW2, that's fine
        }
        else
        {
            `SPOOKLOG("OnGetEvacPlacementDelay: Found another soldier");
            bOnlySpecialSoldiersFound = false;
        }
    }

    if (bOnlySpecialSoldiersFound)
    {
        `SPOOKLOG("OnGetEvacPlacementDelay: Only found Spooks, -100");
        EvacDelayTuple.Data[0].i -= 100; // go negative if we fire before LW2, that's fine; capped to min 1 anyway
    }

    return ELR_NoInterrupt;
}

defaultProperties
{
    ScreenClass = UITacticalHUD
}
