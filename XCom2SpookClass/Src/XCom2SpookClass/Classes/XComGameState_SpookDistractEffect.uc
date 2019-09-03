class XComGameState_SpookDistractEffect
    extends XComGameState_Effect
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var vector TargetPosition;

const DistractedEffectName = 'SpookDistracted';

var localized string DistractedFriendlyName;
var localized string DistractedHelpText;
var localized string DistractedAcquiredString;
var localized string DistractedTickedString;
var localized string DistractedLostString;
var localized string DistractedCleansedString;

static function X2Effect_PersistentStatChange CreateDistractEffect(int Turns, float MobilityAdjust, string IconImage)
{
    local X2Effect_PersistentStatChange Effect;
    Effect = new class'X2Effect_PersistentStatChange';
    Effect.BuildPersistentEffect(`BPE_TickAtStartOfNUnitTurns(Turns));
    Effect.DuplicateResponse = eDupe_Refresh;
    Effect.EffectName = DistractedEffectName;
    Effect.AddPersistentStatChange(eStat_Mobility, MobilityAdjust);
    Effect.GameStateEffectClass = class'XComGameState_SpookDistractEffect';
    Effect.SetDisplayInfo(ePerkBuff_Penalty, default.DistractedFriendlyName, default.DistractedHelpText, IconImage);
    Effect.VisualizationFn = static.DistractedVisualization;
    Effect.EffectTickedVisualizationFn = static.DistractedVisualizationTicked;
    Effect.EffectRemovedVisualizationFn = static.DistractedVisualizationRemoved;
    Effect.CleansedVisualizationFn = static.DistractedVisualizationRemoved;
    Effect.EffectRemovedSourceVisualizationFn = static.DistractedVisualizationRemoved;
    Effect.DelayVisualizationSec = 1;
    return Effect;
}

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
        `SPOOKSLOG("Distract visualized on failure!");
        return;
    }

    Unit = `FindUnitState(BuildTrack.StateObject_NewState.ObjectID, VisualizeGameState);
    if (Unit == none)
    {
        `SPOOKSLOG("Distract visualized on no/dead unit!");
        return;
    }

    class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(BuildTrack, VisualizeGameState.GetContext());
    class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), default.DistractedFriendlyName, '', eColor_Bad, class'UIUtilities_Image'.const.UnitStatus_Default);
    class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, default.DistractedAcquiredString, VisualizeGameState.GetContext());
    class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
    `SPOOKSLOG("Distract visualized");
}

static function DistractedVisualizationTicked(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    local XComGameState_Unit Unit;

    Unit = `FindUnitState(BuildTrack.StateObject_NewState.ObjectID, VisualizeGameState);
    if (Unit == none || !Unit.IsAlive())
    {
        `SPOOKSLOG("Distract ticked on no/dead unit!");
        return;
    }

    class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), default.DistractedFriendlyName, '', eColor_Bad, class'UIUtilities_Image'.const.UnitStatus_Default);
    `SPOOKSLOG("Distract tick visualized");
}

static function DistractedVisualizationRemoved(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    local XComGameState_Unit Unit;

    Unit = `FindUnitState(BuildTrack.StateObject_NewState.ObjectID, VisualizeGameState);
    if (Unit == none || !Unit.IsAlive())
    {
        `SPOOKSLOG("Distract removed on no/dead unit!");
        return;
    }

    class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, default.DistractedLostString, VisualizeGameState.GetContext());
    class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
    `SPOOKSLOG("Distract removal visualized");
}
