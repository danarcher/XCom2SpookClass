// As per X2Effect_RemoveEffects but with added logging.
class X2Effect_SpookRemoveEffects extends X2Effect;

`include(XCom2SpookClass\Src\Spook.uci)

var array<name> EffectNamesToRemove;
var bool bCleanse;
var bool bCheckSource;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local XComGameState_Effect EffectState;
    local X2Effect_Persistent PersistentEffect;
    local int Count;

    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Effect', EffectState)
    {
        if ((bCheckSource && (EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID == ApplyEffectParameters.TargetStateObjectRef.ObjectID)) ||
            (!bCheckSource && (EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID == ApplyEffectParameters.TargetStateObjectRef.ObjectID)))
        {
            PersistentEffect = EffectState.GetX2Effect();
            if (ShouldRemoveEffect(EffectState, PersistentEffect))
            {
                EffectState.RemoveEffect(NewGameState, NewGameState, bCleanse);
                ++Count;
            }
        }
    }

    `SPOOKLOG(Count $ " effects removed");
}

simulated function bool ShouldRemoveEffect(XComGameState_Effect EffectState, X2Effect_Persistent PersistentEffect)
{
    return EffectNamesToRemove.Find(PersistentEffect.EffectName) != INDEX_NONE;
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    local XComGameState_Effect EffectState;
    local X2Effect_Persistent Effect;
    local int Count;

    if (EffectApplyResult != 'AA_Success')
    {
        `SPOOKLOG("Not visualizing " $ EffectApplyResult);
        return;
    }

    // We are assuming that any removed effects were removed by *this* RemoveEffects. If this turns out to not be a good assumption, something will have to change.
    foreach VisualizeGameState.IterateByClassType(class'XComGameState_Effect', EffectState)
    {
        if (EffectState.bRemoved)
        {
            if (EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID == BuildTrack.StateObject_NewState.ObjectID)
            {
                Effect = EffectState.GetX2Effect();
                if (Effect.CleansedVisualizationFn != none && bCleanse)
                {
                    Effect.CleansedVisualizationFn(VisualizeGameState, BuildTrack, EffectApplyResult);
                    ++Count;
                }
                else
                {
                    Effect.AddX2ActionsForVisualization_Removed(VisualizeGameState, BuildTrack, EffectApplyResult, EffectState);
                    ++Count;
                }
            }
            else if (EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID == BuildTrack.StateObject_NewState.ObjectID)
            {
                Effect = EffectState.GetX2Effect();
                Effect.AddX2ActionsForVisualization_RemovedSource(VisualizeGameState, BuildTrack, EffectApplyResult, EffectState);
                ++Count;
            }
        }
    }

    `SPOOKLOG(Count $ " removals visualized");
}

defaultproperties
{
    bCleanse = true
}
