class SpookRedAlertVisualizer
    extends Object;

`include(XCom2SpookClass\Src\Spook.uci)

var X2AbilityTemplate AbilityTemplate;
var delegate<BuildVisualizationDelegate> OriginalBuildVisualizationFn;

delegate BuildVisualizationDelegate(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks);

function AttachTo(X2AbilityTemplate Template)
{
    AbilityTemplate = Template;
    `SPOOKLOG("Original BuildVisualizationFn is " $ Template.BuildVisualizationFn);
    OriginalBuildVisualizationFn = Template.BuildVisualizationFn;
    `SPOOKLOG("Copy is " $ OriginalBuildVisualizationFn);
    Template.BuildVisualizationFn = BuildVisualization;
    `SPOOKLOG("New BuildVisualizationFn is " $ Template.BuildVisualizationFn);
}

simulated function BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
    local XComGameStateHistory History;
    local XComGameStateContext_Ability Context;
    local int EffectIndex, TargetIndex;
    local X2Effect Effect;
    local name ApplyResult;
    local VisualizationTrack Track;

    // Just for diagnostics.
    local XComGameState_Ability AbilityState;
    local X2AbilityTemplate AbilityStateTemplate;

    if (OriginalBuildVisualizationFn != none)
    {
        `SPOOKLOG("Calling OriginalBuildVisualizationFn");
        OriginalBuildVisualizationFn(VisualizeGameState, OutVisualizationTracks);
    }

    History = `XCOMHISTORY;
    Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
    if (Context == none)
    {
        `SPOOKLOG("No ability context, giving up");
        return;
    }

    // Diagnostics.
    `SPOOKLOG("Context InterruptionStatus=" $ Context.InterruptionStatus $ " InterruptionHistoryIndex=" $ Context.InterruptionHistoryIndex $ " ResumeHistoryIndex=" $ Context.ResumeHistoryIndex $ " EventChainStartIndex=" $ Context.EventChainStartIndex $ " bFirstEventInChain=" $ Context.bFirstEventInChain $ " bLastEventInChain=" $ Context.bLastEventInChain);
    AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID));
    AbilityStateTemplate = AbilityState.GetMyTemplate();
    if (AbilityStateTemplate != AbilityTemplate)
    {
        `SPOOKLOG("Warning, expected template " $ AbilityTemplate.DataName $ " does not match actual template " $ AbilityStateTemplate.DataName);
    }
    DumpResults("ShooterEffectResults", 0, Context.ResultContext.ShooterEffectResults);
    DumpResults("TargetEffectResults", 0, Context.ResultContext.TargetEffectResults);
    DumpResultsArray("MultiTargetEffectResults", Context.ResultContext.MultiTargetEffectResults);
    // End diagnostics.

    for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
    {
        Effect = AbilityTemplate.AbilityShooterEffects[EffectIndex];
        If (EffectNeedsVisualizer(Effect))
        {
            `SPOOKLOG("Shooter effect " $ Effect $ " needs visualization");
            FindAndRemoveOrCreateTrackFor(Context.InputContext.SourceObject.ObjectID, VisualizeGameState, History, OutVisualizationTracks, Track);
            Effect.AddX2ActionsForVisualization(VisualizeGameState, Track, CheckResult(Context.FindShooterEffectApplyResult(Effect)));
            OutVisualizationTracks.AddItem(Track);
        }
    }

    for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
    {
        Effect = AbilityTemplate.AbilityTargetEffects[EffectIndex];
        if (EffectNeedsVisualizer(Effect))
        {
            `SPOOKLOG("Target effect " $ Effect $ " needs visualization");
            ApplyResult = CheckResult(Context.FindTargetEffectApplyResult(Effect));
            FindAndRemoveOrCreateTrackFor(Context.InputContext.PrimaryTarget.ObjectID, VisualizeGameState, History, OutVisualizationTracks, Track);
            Effect.AddX2ActionsForVisualization(VisualizeGameState, Track, ApplyResult);
            OutVisualizationTracks.AddItem(Track);
            FindAndRemoveOrCreateTrackFor(Context.InputContext.SourceObject.ObjectID, VisualizeGameState, History, OutVisualizationTracks, Track);
            Effect.AddX2ActionsForVisualizationSource(VisualizeGameState, Track, ApplyResult);
            OutVisualizationTracks.AddItem(Track);
        }
    }

    for (TargetIndex = 0; TargetIndex < Context.InputContext.MultiTargets.Length; ++TargetIndex)
    {
        for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityMultiTargetEffects.Length; ++EffectIndex)
        {
            Effect = AbilityTemplate.AbilityMultiTargetEffects[EffectIndex];
            if (EffectNeedsVisualizer(Effect))
            {
                `SPOOKLOG("Multitarget effect " $ Effect $ " needs visualization for target " $ TargetIndex);
                ApplyResult = CheckResult(Context.FindMultiTargetEffectApplyResult(Effect, TargetIndex));
                FindAndRemoveOrCreateTrackFor(Context.InputContext.MultiTargets[TargetIndex].ObjectID, VisualizeGameState, History, OutVisualizationTracks, Track);
                OutVisualizationTracks.AddItem(Track);
                Effect.AddX2ActionsForVisualization(VisualizeGameState, Track, ApplyResult);
                FindAndRemoveOrCreateTrackFor(Context.InputContext.SourceObject.ObjectID, VisualizeGameState, History, OutVisualizationTracks, Track);
                Effect.AddX2ActionsForVisualizationSource(VisualizeGameState, Track, ApplyResult);
                OutVisualizationTracks.AddItem(Track);
            }
        }
    }
}

simulated function DumpResultsArray(string ResultsName, out array<EffectResults> ResultsArray)
{
    local int Index;
    local EffectResults Results;
    for (Index = 0; Index < ResultsArray.Length; ++Index)
    {
        Results = ResultsArray[Index];
        DumpResults(ResultsName, Index, Results);
    }
}

simulated function DumpResults(string ResultsName, int Number, out EffectResults Results)
{
    local int Index;
    `SPOOKLOG("Dumping " $ ResultsName $ " (" $ Number $ ")");
    //var array<X2Effect> Effects;
    //var array<X2EffectTemplateRef> TemplateRefs;
    //var array<name> ApplyResults;
    for (Index = 0; Index < Results.Effects.Length; ++Index)
    {
        `SPOOKLOG("Effect=" $ Results.Effects[Index] $ " Template=" $ Results.TemplateRefs[Index].SourceTemplateName $ " Result=" $ Results.ApplyResults[Index]);
    }
    `SPOOKLOG("Dump ends");
}

simulated function name CheckResult(name Result)
{
    // For some reason Context.FindXXXEffectApplyResult (Shooter, Target,
    // MultiTarget) fail, in fact because (as diagnostic dumps indicate) the
    // underlying result arrays are empty. The cause has not been established,
    // though I am mildly and perhaps erroneously suspicious of
    // X2Ability_AlertMechanics.NewAlertState_BuildVisualization() perhaps
    // doing something non-obviously dubious with contexts and game states.
    // However, it turns out that the visualiser(s) added by
    // X2ffect_(Spook)RemoveEffect (those for the removal of the affects in
    // question) do adequate checking in any case - so there are no
    // "I didn't remove this effect, it wasn't there" errors or similar -
    // so we can just force AA_UnknownError into AA_Success and carry on
    // regardless, whistling, if disconcerted.
    if (Result == 'AA_UnknownError')
    {
        `SPOOKLOG("Effect result is " $ Result $ ", converting to AA_Success");
        Result = 'AA_Success';
    }
    return Result;
}

simulated function bool EffectNeedsVisualizer(X2Effect Effect)
{
    return Effect.IsA('X2Effect_RemoveEffects') || Effect.IsA('X2Effect_SpookRemoveEffects');
}

simulated function FindAndRemoveOrCreateTrackFor(int ObjectID, XComGameState VisualizeGameState, XComGameStateHistory History, out array<VisualizationTrack> Tracks, out VisualizationTrack Track)
{
    local VisualizationTrack EmptyTrack;
    local int TrackIndex;
    for (TrackIndex = 0; TrackIndex < Tracks.Length; ++TrackIndex)
    {
        Track = Tracks[TrackIndex];
        if (Track.StateObject_NewState.ObjectID == ObjectID)
        {
            Tracks.Remove(TrackIndex, 1);
            `SPOOKLOG("Existing track found for " $ ObjectID $ ", removing and using that");
            return;
        }
    }

    `SPOOKLOG("No existing track found for " $ ObjectID $ ", creating new track");
    Track = EmptyTrack;
    Track.StateObject_OldState = History.GetGameStateForObjectID(ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
    Track.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ObjectID);
    if (Track.StateObject_NewState == none)
    {
        Track.StateObject_NewState = Track.StateObject_OldState;
    }
    Track.TrackActor = History.GetVisualizer(ObjectID);
    Track.AbilityName = AbilityTemplate.DataName;
}
