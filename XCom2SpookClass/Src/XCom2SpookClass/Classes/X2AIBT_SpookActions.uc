class X2AIBT_SpookActions extends X2AIBTDefaultActions;

`include(XCom2SpookClass\Src\Spook.uci)

static event bool FindBTActionDelegate(name strName, optional out delegate<BTActionDelegate> dOutFn, optional out name NameParam, optional out name MoveProfile)
{
    dOutFn = None;

    switch (strName)
    {
        case 'SpookIsDistracted':
            dOutFn = IsDistracted;
            return true;
        case 'SpookSetDestinationToDistraction':
            dOutFn = SetDestinationToDistraction;
            return true;
        break;

        default:
            `SPOOKSLOG("Unresolved behavior tree action name with no delegate definition: " $ strName);
        break;

    }
    return super.FindBTActionDelegate(strName, dOutFn, NameParam, MoveProfile);
}

function bt_status IsDistracted()
{
    local XComGameState_Unit Unit;
    local XComGameState_Effect EffectState;

    Unit = m_kBehavior.m_kUnit.GetVisualizedGameState();
    EffectState = Unit.GetUnitAffectedByEffectState(class'XComGameState_SpookDistractEffect'.const.DistractedEffectName);
    if (EffectState == none)
    {
        return BTS_FAILURE;
    }
    return BTS_SUCCESS;
}

function bt_status SetDestinationToDistraction()
{
    local XComGameState_Unit Unit;
    local XComGameState_Effect EffectState;
    local XComGameState_SpookDistractEffect DistractEffectState;
    local XComWorldData World;
    local TTile DestinationTile;
    local vector DestinationPosition;

    Unit = m_kBehavior.m_kUnit.GetVisualizedGameState();
    EffectState = Unit.GetUnitAffectedByEffectState(class'XComGameState_SpookDistractEffect'.const.DistractedEffectName);
    if (EffectState == none)
    {
        `SPOOKSLOG("Can't set distract AI destination: no distracted effect");
        return BTS_FAILURE;
    }
    DistractEffectState = XComGameState_SpookDistractEffect(EffectState);
    if (DistractEffectState == none)
    {
        `SPOOKSLOG("Can't set distract AI destination: distracted effect is base class");
        return BTS_FAILURE;
    }

    `SPOOKSLOG("AI found distract destination at " $ DistractEffectState.TargetPosition);
    World = `XWORLD;
    World.GetFloorTileForPosition(DistractEffectState.TargetPosition, DestinationTile);
    DestinationPosition = World.GetPositionFromTileCoordinates(DestinationTile);
    if (!m_kBehavior.HasValidDestinationToward(DestinationPosition, DestinationPosition, m_kBehavior.m_bBTCanDash))
    {
        `SPOOKSLOG("Can't set distract AI destination: no valid destination toward target");
        return BTS_FAILURE;
    }

    if (m_kBehavior.CanUseCover())
    {
        m_kBehavior.GetClosestCoverLocation(DestinationPosition, DestinationPosition);
    }

    m_kBehavior.m_vBTDestination = DestinationPosition;
    m_kBehavior.m_bBTDestinationSet = true;
    return BTS_SUCCESS;
}
