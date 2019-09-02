class XComGameState_SpookDistractEffect
    extends XComGameState_Effect;

`include(XCom2SpookClass\Src\Spook.uci)

var vector TargetPosition;

function OnCreation(EffectAppliedData InApplyEffectParameters, GameRuleStateChange WatchRule, XComGameState NewGameState)
{
    super.OnCreation(InApplyEffectParameters, WatchRule, NewGameState);
    ApplyDistraction(InApplyEffectParameters, NewGameState);
    `SPOOKLOG("Distraction created at " $ TargetPosition);
}

function OnRefresh(EffectAppliedData NewApplyEffectParameters, XComGameState NewGameState)
{
    super.OnRefresh(NewApplyEffectParameters, NewGameState);
    // Apply with new params, not existing params, which are *not* updated by XComGameState_Effect.
    ApplyDistraction(NewApplyEffectParameters, NewGameState);
    `SPOOKLOG("Distraction refreshed at " $ TargetPosition);
}

function ApplyDistraction(EffectAppliedData NewApplyEffectParameters, XComGameState NewGameState)
{
    TargetPosition = NewApplyEffectParameters.AbilityResultContext.ProjectileHitLocations[0];
}

static function DistractedVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    local XComGameState_Unit Unit;

    if( EffectApplyResult != 'AA_Success' && EffectApplyResult != 'AA_EffectRefreshed' )
    {
        return;
    }

    Unit = `FindUnitState(BuildTrack.StateObject_NewState.ObjectID, VisualizeGameState);
    if (Unit == none)
    {
        return;
    }

    class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(BuildTrack, VisualizeGameState.GetContext());
    class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), class'X2Ability_SpookAbilitySet'.default.DistractedFriendlyName, '', eColor_Bad, class'UIUtilities_Image'.const.UnitStatus_Default);
    class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, class'X2Ability_SpookAbilitySet'.default.DistractedAcquiredString, VisualizeGameState.GetContext());
    class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

static function DistractedVisualizationTicked(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    local XComGameState_Unit Unit;

    `SPOOKSLOG("DistractedVisualizationTicked");
    Unit = `FindUnitState(BuildTrack.StateObject_NewState.ObjectID, VisualizeGameState);
    if (Unit == none || !Unit.IsAlive())
    {
        return;
    }

    class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), class'X2Ability_SpookAbilitySet'.default.DistractedFriendlyName, '', eColor_Bad, class'UIUtilities_Image'.const.UnitStatus_Default);
}

static function DistractedVisualizationRemoved(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    local XComGameState_Unit Unit;

    Unit = `FindUnitState(BuildTrack.StateObject_NewState.ObjectID, VisualizeGameState);
    if (Unit == none || !Unit.IsAlive())
    {
        return;
    }

    class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, class'X2Ability_SpookAbilitySet'.default.DistractedLostString, VisualizeGameState.GetContext());
    class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}
