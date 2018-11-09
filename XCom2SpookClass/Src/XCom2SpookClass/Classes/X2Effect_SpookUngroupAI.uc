// Stop AI bugging out when a patrol member (especially if it's the pod leader) is incapacitated.
// Ungroup the offending member - they're now on their own, and the patrol elect a new leader if necessary.
class X2Effect_SpookUngroupAI
    extends X2Effect_Persistent
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
    super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

    UngroupUnit(NewGameState, ApplyEffectParameters.TargetStateObjectRef);
}

simulated function UngroupUnit(XComGameState NewGameState, StateObjectReference UnitRef)
{
    local XGAIPlayer AIPlayer;
    local XComGameState_AIPlayerData PlayerData;

    local int iUnitID;
    local int iGroupID;
    local XGAIGroup CurrentGroup;

    `SPOOKLOG("UngroupUnit start");

    AIPlayer = XGAIPlayer(XGBattle_SP(`BATTLE).GetAIPlayer());

    PlayerData = XComGameState_AIPlayerData(NewGameState.GetGameStateForObjectID(AIPlayer.GetAIDataID()));
    if (PlayerData == none)
    {
        PlayerData = XComGameState_AIPlayerData(NewGameState.CreateStateObject(class'XComGameState_AIPlayerData', AIPlayer.GetAIDataID()));
        NewGameState.AddStateObject(PlayerData);
    }
    if (IsSoloUnit(PlayerData, UnitRef, NewGameState))
    {
        `SPOOKLOG("Unit is solo, but carrying on regardless");
    }

    iUnitID = UnitRef.ObjectID;
    iGroupID = PlayerData.GetGroupObjectIDFromUnit(UnitRef);
    SafelyRemoveFromCurrentGroup(PlayerData, UnitRef, NewGameState, true); // Add to displaced unit list (why not)

    if (iGroupID > 0)
    {
        `SPOOKLOG("Found Group ID " @ iGroupID);
        foreach `XWORLDINFO.AllActors(class'XGAIGroup', CurrentGroup)
        {
            if (CurrentGroup.m_arrUnitIDs.Find(iUnitID) != -1)
            {
                `SPOOKLOG("Found unit's XGAIGroup, removing unit and refreshing members");
                CurrentGroup.m_arrUnitIDs.RemoveItem(iUnitID);
                CurrentGroup.RefreshMembers();
            }
        }
    }

    `SPOOKLOG("UngroupUnit end");
}

function bool IsSoloUnit(XComGameState_AIPlayerData PlayerData, StateObjectReference UnitRef, XComGameState NewGameState)
{
    local XComGameState_AIGroup GroupState;
    local int iGroupID;

    iGroupID = PlayerData.GetGroupObjectIDFromUnit(UnitRef);
    `SPOOKLOG("IsSoloUnit: Unit group ID is " @ iGroupID);
    if( iGroupID > 0 )
    {
        GroupState = XComGameState_AIGroup(NewGameState.GetGameStateForObjectID(iGroupID));
        if (GroupState == none)
        {
            GroupState = XComGameState_AIGroup(`XCOMHISTORY.GetGameStateForObjectID(iGroupID));
        }

        if (GroupState != none)
        {
            `SPOOKLOG("IsSoloUnit: Unit is in group " @ iGroupID @ " of " @ GroupState.m_arrMembers.Length @ " units");
        }
        else
        {
            `SPOOKLOG("IsSoloUnit: Unit has group ID but is ungrouped");
        }

        if (GroupState != none && GroupState.m_arrMembers.Length > 1)
        {
            return false;
        }
    }

    return true;
}

// A fix to XComGameState_AIPlayerData.RemoveFromCurrentGroup.
// Check for an existing AIGroup state in NewGameState before adding one.
function bool SafelyRemoveFromCurrentGroup(XComGameState_AIPlayerData PlayerData, StateObjectReference UnitRef, XComGameState NewGameState, bool bAddToDisplaced=false)
{
    local XComGameState_AIGroup GroupState;
    local int iGroupID;

    iGroupID = PlayerData.GetGroupObjectIDFromUnit(UnitRef);
    if( iGroupID > 0 )
    {
        GroupState = XComGameState_AIGroup(NewGameState.GetGameStateForObjectID(iGroupID));
        if (GroupState == none)
        {
            GroupState = XComGameState_AIGroup(NewGameState.CreateStateObject(class'XComGameState_AIGroup', iGroupID));
            NewGameState.AddStateObject(GroupState);
        }
        GroupState.m_arrMembers.RemoveItem(UnitRef);
        if( bAddToDisplaced && GroupState.m_arrDisplaced.Find('ObjectID', UnitRef.ObjectID) == INDEX_NONE )
        {
            GroupState.m_arrDisplaced.AddItem(UnitRef);
        }
        PlayerData.UpdateGroupData(NewGameState);
        PlayerData.RemoveFromGroupLookup(UnitRef);
        return true;
    }
    return false;
}
