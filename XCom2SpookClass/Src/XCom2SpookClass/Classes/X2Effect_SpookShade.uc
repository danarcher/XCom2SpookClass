class X2Effect_SpookShade
    extends X2Effect_Persistent
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

const ShadeEffectName = 'SpookShadeEffect';

// This effect is slightly similar to Chryssalid burrow, but unlike burrow it
// does not, in and of itself, provide gameplay invisibility. Instead it simply
// triggers a visibility update when it expires. We want this since it permits
// enemies to notice a unit which has just lost shade if they're, for instance,
// standing right next to them in open ground.
//
// We don't actually want the Shade effect to provide the gameplay invisiblity,
// since that would separate Shade from concealment. Instead thanks to the
// tactical detection manager, Shade acts as a concealment preserver, preventing
// loss of concealment. Concealment itself provides the gameplay invisibility.
//
// Moreover, it isn't just the Shade effect which preserves concealment.
// Both the Shade effect, and being on a tile where the unit can Meld (which
// can induce the Shade effect, mostly for visual consistency, but still
// preserves concealment after the Shade effect has worn off) preserve
// concealment. This is important since Shade can wear off at the end of a turn,
// and we don't want the unit to lose concealment immediately to any nearby
// enemies, until and unless the unit moves out of its safe tile.
//
// To fully separate Shade from concealment, we'd also need additional logic in
// the tactical detection manager. After the detection manager decides it is
// valid to break concealment, and does so, it would need to retest visibility
// to look for other reasons for gameplay invisibility before presuming that
// unit A sees unit B, perhaps checking the tags returned by the visibility
// test (see burrow), since even our cleaned up and extended port of the base
// game code does no such thing presently (and the base game certainly didn't
// either). The assumption has been (by the base game and by us) that there are
// no reasons for player unit gameplay invisibility other than concealment,
// though burrow-like effects present an opportunity to implement one given
// said changes to concealment-breaking logic.

static function X2Effect_SpookShade CreateShadeEffect(bool bUntilNextTurn, string EffectFriendlyName)
{
    local X2Effect_SpookShade Effect;
    Effect = new class'X2Effect_SpookShade';
    if (bUntilNextTurn)
    {
        // For end of turn Shades in cover etc. thanks to the Meld ability.
        Effect.BuildPersistentEffect(`BPE_TickAtStartOfNUnitTurns(1));
    }
    else
    {
        // For briefer Shades such as that induced by Vanish.
        Effect.BuildPersistentEffect(`BPE_TickAtEndOfNUnitTurns(1));
    }
    Effect.DuplicateResponse = eDupe_Allow; // In case of overlapping effects for different reasons.
    Effect.EffectName = ShadeEffectName; // Per UNITS_NOT_REVEALED_EFFECTS.
    Effect.FriendlyName = EffectFriendlyName;
    return Effect;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
    local XComGameState_Unit Unit;

    super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

    // Effects that change visibility must actively indicate it.
    // When shade wears off, we need to test again to see if our concealment
    // can now be broken.
    Unit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
    Unit.bRequiresVisibilityUpdate = true;
    NewGameState.AddStateObject(Unit);
}

static function int GetShadeCount(int ObjectID, XComGameState GameState)
{
    local XComGameState_Unit Unit;
    local StateObjectReference EffectRef;
    local XComGameState_Effect Effect;
    local int Count;

    Unit = `FindUnitState(ObjectID, GameState);
    foreach Unit.AffectedByEffects(EffectRef)
    {
        Effect = `FindEffectState(EffectRef.ObjectID, GameState);
        if (Effect.GetX2Effect().EffectName == ShadeEffectName)
        {
            Count += 1;
        }
    }
    return Count;
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack Track, name EffectApplyResult)
{
    local XComGameStateContext Context;
    local X2Action_PlaySoundAndFlyover SoundAndFlyOver;
    local X2Action_SpookPlayAkEvent PlayAkEvent;
    local int ShadeCount;

    super.AddX2ActionsForVisualization(VisualizeGameState, Track, EffectApplyResult);

    Context = VisualizeGameState.GetContext();

    ShadeCount = GetShadeCount(Track.StateObject_NewState.ObjectID, VisualizeGameState);
    if (ShadeCount == 1)
    {
        SoundAndFlyOver = X2Action_PlaySoundAndFlyover(`InsertTrackAction(Track, 0, class'X2Action_PlaySoundAndFlyover', Context));
        SoundAndFlyOver.SetSoundAndFlyOverParameters(None, FriendlyName, '', eColor_Good);

        `InsertTrackAction(Track, 1, class'X2Action_SpookSetMaterial', Context);

        if (class'X2Ability_SpookAbilitySet'.default.SHADE_SOUND_EFFECTS)
        {
            PlayAkEvent = X2Action_SpookPlayAkEvent(`InsertTrackAction(Track, 2, class'X2Action_SpookPlayAkEvent', Context));
            PlayAkEvent.EventToPlay = AkEvent'SoundX2CharacterFX.MimicBeaconActivate';
        }
    }
}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationTrack Track, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
    local X2Action_SpookSetMaterial SetMaterial;
    local X2Action_SpookPlayAkEvent PlayAkEvent;
    local int ShadeCount;

    super.AddX2ActionsForVisualization_Removed(VisualizeGameState, Track, EffectApplyResult, RemovedEffect);

    ShadeCount = GetShadeCount(Track.StateObject_NewState.ObjectID, VisualizeGameState);
    if (ShadeCount == 0)
    {
        SetMaterial = X2Action_SpookSetMaterial(`InsertTrackAction(Track, 0, class'X2Action_SpookSetMaterial', VisualizeGameState.GetContext()));
        SetMaterial.bResetMaterial = true;

        if (class'X2Ability_SpookAbilitySet'.default.SHADE_SOUND_EFFECTS)
        {
            PlayAkEvent = X2Action_SpookPlayAkEvent(`InsertTrackAction(Track, 1, class'X2Action_SpookPlayAkEvent', VisualizeGameState.GetContext()));
            PlayAkEvent.EventToPlay = AkEvent'SoundX2CharacterFX.MimicBeaconDeactivate';
        }
    }
}

defaultproperties
{
    EffectName="SpookShadeEffect"
}
