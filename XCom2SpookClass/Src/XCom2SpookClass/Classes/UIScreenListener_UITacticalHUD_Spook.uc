class UIScreenListener_UITacticalHUD_Spook
    extends UIScreenListener
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var SpookDetectionManager DetectionManager;
var SpookTileManager TileManager;

event OnInit(UIScreen Screen)
{
    local Object This;

    This = self;
    `SPOOKLOG("OnInit");
    `XEVENTMGR.RegisterForEvent(This, 'GetEvacPlacementDelay', OnGetEvacPlacementDelay, ELD_Immediate);

    DetectionManager = new class'SpookDetectionManager';
    DetectionManager.OnInit();

    TileManager = new class'SpookTileManager';
    TileManager.OnInit(DetectionManager);
}

function EventListenerReturn OnGetEvacPlacementDelay(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local LWTuple EvacDelayTuple;
    local XComGameState_HeadquartersXCom XComHQ;
    local XComGameStateHistory History;
    local XComGameState_Unit Unit;
    local int SquadIndex, Spooks;
    local bool bOnlySpooks;
    local bool bSomeoneHasExeunt;

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

    Spooks = 0;
    bOnlySpooks = true;
    bSomeoneHasExeunt = false;

    for (SquadIndex = 0; SquadIndex < XComHQ.Squad.Length; SquadIndex++)
    {
        Unit = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Squad[SquadIndex].ObjectID));
        if (Unit != none)
        {
            if (Unit.HasSoldierAbility(class'X2Ability_SpookAbilitySet'.const.ExeuntAbilityName))
            {
                bSomeoneHasExeunt = true;
            }
            if (Unit.GetSoldierClassTemplateName() == 'Spook')
            {
                ++Spooks;
            }
            else
            {
                bOnlySpooks = false;
            }
        }
    }

    if (bSomeoneHasExeunt)
    {
        if (bOnlySpooks)
        {
            `SPOOKLOG("OnGetEvacPlacementDelay: Exeunt and only found Spooks, -100");
            EvacDelayTuple.Data[0].i -= 100; // go negative if we fire before LW2, that's fine; capped to min 1 anyway
        }
        else
        {
            `SPOOKLOG("OnGetEvacPlacementDelay: Exeunt and " $ Spooks $ " Spooks, " $ -Spooks);
            EvacDelayTuple.Data[0].i -= Spooks;
        }
    }
    else
    {
        `SPOOKLOG("OnGetEvacPlacementDelay: Nobody has Exeunt");
    }

    return ELR_NoInterrupt;
}

defaultProperties
{
    ScreenClass = UITacticalHUD
}
