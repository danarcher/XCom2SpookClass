class SpookDetectionManager
    extends Object
    implements(X2VisualizationMgrObserverInterface)
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var localized string StealthKilledFriendlyName;

var config array<name> SHADOW_EFFECTS;
var config array<name> SHADOW_NOT_REVEALED_BY_CLASSES;
var config bool SHADOW_NOT_REVEALED_BY_DETECTOR;
var config array<name> UNITS_NOT_REVEALED_ABILITIES;
var config array<name> UNITS_NOT_REVEALED_EFFECTS;

var float StatOverrideSpecialDetectionModifier;

enum EConcealBreakReason
{
    eCBR_EnemyTookDamage,
    eCBR_UnitVisibilityChange,
    eCBR_UnitMoveIntoDetectionRange,
    eCBR_EnemyMoveIntoDetectionRange,
    eCBR_BrokenWindow,
};

enum ECoverHandling
{
    eCH_SafeInCover,
    eCH_IgnoreCover,
};

function OnInit()
{
    local Object This;
    This = self;

    `SPOOKLOG("OnInit");
    `XEVENTMGR.RegisterForEvent(This, 'PlayerTurnBegun', OnPlayerTurnBegun, ELD_OnStateSubmitted);
    `XEVENTMGR.RegisterForEvent(This, 'UnitSpawned', OnUnitSpawned, ELD_OnStateSubmitted);
    ReplaceEventListeners();
    `SPOOKLOG("StatOverrideSpecialDetectionModifier is " $ default.StatOverrideSpecialDetectionModifier);
    `XCOMVISUALIZATIONMGR.RegisterObserver(self);
}

function float GetUnitDetectionModifier(XComGameState_Unit Unit)
{
    local array<XComGameState_Effect> Mods;
    local X2Effect_Persistent Effect;
    local array<float> ModValues;
    local int i;
    local float Value;

    Value = Unit.GetBaseStat(eStat_DetectionModifier);

    Unit.GetStatModifiers(eStat_DetectionModifier, Mods, ModValues);
    for (i = 0; i < Mods.Length; ++i)
    {
        Effect = (Mods[i] != none) ? Mods[i].GetX2Effect() : none;
        if (Effect == none || Effect.EffectName != 'SpookStatOverrideEffect')
        {
            Value += ModValues[i];
        }
    }

    return Value;
}

function float GetConcealmentDetectionDistanceMeters(XComGameState_BaseObject Detector, XComGameState_Unit Victim)
{
    local XComGameState_Unit Enemy;
    local XComGameState_InteractiveObject Tower;
    local float DetectionRadius;
    local float SightRadius;

    Enemy = XComGameState_Unit(Detector);
    if (Enemy != none)
    {
        SightRadius = Enemy.GetVisibilityRadius();
        DetectionRadius = FMax(Enemy.GetCurrentStat(eStat_DetectionRadius), 0.0);
        DetectionRadius = DetectionRadius * FMax(1.0 - GetUnitDetectionModifier(Victim), 0.0);
        DetectionRadius = FMin(SightRadius, DetectionRadius);
        return DetectionRadius;
    }

    Tower = XComGameState_InteractiveObject(Detector);
    if (Tower != none)
    {
        DetectionRadius = `UNITSTOMETERS(Tower.DetectionRange);
        return DetectionRadius;
    }

    return 0;
}

function float GetConcealmentDetectionDistanceUnits(XComGameState_BaseObject Detector, XComGameState_Unit Victim)
{
    return `METERSTOUNITS(GetConcealmentDetectionDistanceMeters(Detector, Victim));
}

function bool BreaksConcealment(XComGameState_BaseObject Detector, XComGameState_Unit Victim, EConcealBreakReason Reason)
{
    local XComGameState_Unit Enemy;
    local XComGameState_InteractiveObject Tower;

    Enemy = XComGameState_Unit(Detector);
    if (Enemy != none)
    {
        if (UnitHasShadowEffect(Victim) && default.SHADOW_NOT_REVEALED_BY_CLASSES.Find(Enemy.GetMyTemplateName()) >= 0)
        {
            return false;
        }
        return Victim.IsAlive() && Enemy.IsAlive() && Victim.UnitBreaksConcealment(Enemy);
    }

    Tower = XComGameState_InteractiveObject(Detector);
    if (Tower != none)
    {
        if (UnitHasShadowEffect(Victim) && default.SHADOW_NOT_REVEALED_BY_DETECTOR)
        {
            return false;
        }
        return Tower.Health > 0 && Tower.DetectionRange > 0.0 && !Tower.bHasBeenHacked;
    }

    return false;
}

function EventListenerReturn OnPlayerTurnBegun(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    // Ensure eg. reinforcement units have their movement events overridden by us;
    // This does presume that units don't spawn during a player's turn and then
    // move and see the player using their default logic, so we also check for
    // spawns. Arguably this may be overkill (if we do the latter, the former is
    // less relevant).
    if (`TACTICALRULES.GetLocalClientPlayerObjectID() == XComGameState_Player(EventSource).ObjectID)
    {
        `SPOOKLOG("OnPlayerTurnBegun: Human");
    }
    else
    {
        `SPOOKLOG("OnPlayerTurnBegun: AI");
    }
    ReplaceEventListeners();
    return ELR_NoInterrupt;
}

function EventListenerReturn OnUnitSpawned(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local X2EventManager EventMgr;
    local XComGameState_Unit UnitState;
    EventMgr = `XEVENTMGR;
    UnitState = XComGameState_Unit(EventData);
    if (UnitState != none)
    {
        `SPOOKLOG("OnUnitSpawned: Valid");
        UnregisterUnitEvents(EventMgr, UnitState);
    }
    else
    {
        `SPOOKLOG("OnUnitSpawned: Invalid");
    }
    return ELR_NoInterrupt;
}

function UnregisterUnitEvents(X2EventManager EventMgr, XComGameState_Unit UnitState)
{
    EventMgr.UnRegisterFromEvent(UnitState, 'ObjectMoved');
    EventMgr.UnRegisterFromEvent(UnitState, 'UnitTakeEffectDamage');
}

function ReplaceEventListeners()
{
    local Object This;
    local X2EventManager EventMgr;
    local XComGameStateHistory History;
    local XComGameState_Unit UnitState;
    local XComGameState_Player PlayerState;

    History = `XCOMHISTORY;
    EventMgr = `XEVENTMGR;
    This = self;

    `SPOOKLOG("ReplaceEventListeners");

    foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
    {
        UnregisterUnitEvents(EventMgr, UnitState);
    }

    foreach History.IterateByClassType(class'XComGameState_Player', PlayerState)
    {
        EventMgr.UnRegisterFromEvent(PlayerState, 'ObjectVisibilityChanged');
    }

    EventMgr.RegisterForEvent(This, 'ObjectVisibilityChanged', OnObjectVisibilityChanged, ELD_OnStateSubmitted);

    EventMgr.RegisterForEvent(This, 'ObjectMoved', OnUnitEnteredTile, ELD_OnStateSubmitted);
    //EventMgr.RegisterForEvent(This, 'UnitMoveFinished', OnUnitMoveFinished, ELD_OnStateSubmitted);

    EventMgr.RegisterForEvent(This, 'UnitTakeEffectDamage', OnUnitTakeEffectDamage, ELD_OnStateSubmitted);
    EventMgr.RegisterForEvent(This, 'UnitDied', OnUnitDied, ELD_OnStateSubmitted);
}

function EventListenerReturn OnObjectVisibilityChanged(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState_BaseObject Detector;
    local XComGameState_Unit Victim;
    Detector = XComGameState_BaseObject(EventSource);
    Victim = XComGameState_Unit(EventData);
    TryDetectorSeeingVictim(Detector, Victim, GameState, eCBR_UnitVisibilityChange, eCH_SafeInCover);
    return ELR_NoInterrupt;
}

function XComGameState_Unit TryDetectorSeeingVictim(XComGameState_BaseObject Detector, XComGameState_Unit Victim, XComGameState GameState, EConcealBreakReason Reason, ECoverHandling CoverHandling)
{
    local XComGameState_Unit Enemy;
    local GameRulesCache_VisibilityInfo Visibility;

    if (Detector == none || Victim == none || GameState == none
        || Detector.ObjectID == Victim.ObjectID
        || Victim.GetMyTemplate().bIsCosmetic)
    {
        return Victim;
    }

    Enemy = XComGameState_Unit(Detector);
    if (Enemy != none)
    {
        if (!Enemy.IsAlive() || !Enemy.TargetIsEnemy(Victim.ObjectID))
        {
            return Victim;
        }

        `TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Enemy.ObjectID, Victim.ObjectID, Visibility, GameState.HistoryIndex);
        if (Visibility.bVisibleGameplay)
        {
            // (Deleted impossible alien noises code. XComGameState_Player.TurnsSinceEnemySeen is privatewrite.)
            UnitASeesUnitB(Enemy, Victim, GameState);
            return Victim;
        }

        if (!Visibility.bVisibleBasic)
        {
            return Victim;
        }
    }

    if (Victim.IsConcealed() && (CoverHandling == eCH_IgnoreCover || Visibility.TargetCover == CT_None))
    {
        Victim = TryBreakConcealment(Detector, Victim, GameState, Reason);
    }

    if (Enemy != none && !Victim.IsConcealed())
    {
        UnitASeesUnitB(Enemy, Victim, GameState);
    }

    return Victim;
}

function XComGameState_Unit TryBreakConcealment(XComGameState_BaseObject Detector, XComGameState_Unit Victim, XComGameState GameState, EConcealBreakReason Reason)
{
    local TTile DetectorTile, VictimTile;
    local vector DetectorPosition, VictimPosition;
    local XComWorldData World;
    local XComGameState_Unit Enemy;

    if (Detector == none || Victim == none || GameState == none
        || Detector.ObjectID == Victim.ObjectID
        || Victim.GetMyTemplate().bIsCosmetic)
    {
        return Victim;
    }

    if (!Victim.IsConcealed())
    {
        return Victim;
    }

    if (BreaksConcealment(Detector, Victim, Reason))
    {
        GetOwnTile(Detector, DetectorTile);
        GetOwnTile(Victim, VictimTile);

        World = `XWORLD;
        DetectorPosition = World.GetPositionFromTileCoordinates(DetectorTile);
        VictimPosition = World.GetPositionFromTileCoordinates(VictimTile);

        if (VSizeSq(DetectorPosition - VictimPosition) <= Square(GetConcealmentDetectionDistanceUnits(Detector, Victim)))
        {
            if (!IsUnitConcealmentUnbreakable(GameState, Victim, Reason))
            {
                Enemy = XComGameState_Unit(Detector);
                if (Enemy != none)
                {
                    Victim.BreakConcealment(Enemy);
                }
                else
                {
                    Victim.BreakConcealment();
                }
                Victim = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Victim.ObjectID));
            }
        }
    }

    return Victim;
}

function EventListenerReturn OnUnitEnteredTile(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState_Unit Mover, Bystander;
    local XComGameState_InteractiveObject Tower;
    local XComGameStateHistory History;
    local XComGameStateContext_Ability AbilityContext;
    local XComGameState_AIGroup AIGroup;

    History = `XCOMHISTORY;

    Mover = XComGameState_Unit(EventData);
    Mover = XComGameState_Unit(History.GetGameStateForObjectID(Mover.ObjectID));
    AbilityContext = XComGameStateContext_Ability(GameState.GetContext());

    CleanseBurningIfInWater(Mover);

    if (AbilityContext != None)
    {
        // Breaking windows breaks concealment. Ignore tile since we broke a window to get to it.
        if (AbilityContext.ResultContext.bPathCausesDestruction &&
            Mover.IsConcealed() &&
            !IsUnitConcealmentUnbreakableIgnoringTile(GameState, Mover, eCBR_BrokenWindow))
        {
            Mover.BreakConcealment();
            Mover = XComGameState_Unit(History.GetGameStateForObjectID(Mover.ObjectID));
        }
    }

    if (AbilityContext != none)
    {
        // Check if this unit is a member of a group waiting on this unit's movement to complete,
        // or at least reach the interruption step where the movement should complete.
        AIGroup = Mover.GetGroupMembership();
        if (AIGroup != None &&
            AIGroup.IsWaitingOnUnitForReveal(Mover) &&
            (AbilityContext.InterruptionStatus != eInterruptionStatus_Interrupt ||
             (AIGroup.FinalVisibilityMovementStep > INDEX_NONE &&
              AIGroup.FinalVisibilityMovementStep <= AbilityContext.ResultContext.InterruptionStep)))
        {
            AIGroup.StopWaitingOnUnitForReveal(Mover);
        }
    }

    foreach History.IterateByClassType(class'XComGameState_InteractiveObject', Tower)
    {
        Mover = TryDetectorSeeingVictim(Tower, Mover, GameState, eCBR_UnitMoveIntoDetectionRange, eCH_IgnoreCover);
    }

    foreach History.IterateByClassType(class'XComGameState_Unit', Bystander)
    {
        Mover = TryDetectorSeeingVictim(Bystander, Mover, GameState, eCBR_UnitMoveIntoDetectionRange, eCH_IgnoreCover);
        Bystander = TryDetectorSeeingVictim(Mover, Bystander, GameState, eCBR_EnemyMoveIntoDetectionRange, eCH_SafeInCover);
    }

    return ELR_NoInterrupt;
}

function bool GetOwnTile(XComGameState_BaseObject Obj, out TTile Tile)
{
    local XComGameState_Unit Unit;
    local XComGameState_InteractiveObject Tower;

    Unit = XComGameState_Unit(Obj);
    if (Unit != none)
    {
        Unit.GetKeystoneVisibilityLocation(Tile);
        return true;
    }

    Tower = XComGameState_InteractiveObject(Obj);
    if (Tower != none)
    {
        Tile = Tower.TileLocation;
        return true;
    }

    return false;
}

function bool IsUnitConcealmentUnbreakable(XComGameState GameState, XComGameState_Unit Unit, EConcealBreakReason Reason)
{
    local TTile Tile;
    GetOwnTile(Unit, Tile);
    return IsTileUnbreakablyConcealingForUnit(Unit, Tile, Reason) ||
           IsUnitConcealmentUnbreakableIgnoringTile(GameState, Unit, Reason);
}

function bool IsTileUnbreakablyConcealingForUnit(XComGameState_Unit Unit, out TTile Tile, EConcealBreakReason Reason)
{
    local XComWorldData World;
    local vector Position;
    local XComCoverPoint Cover;
    local array<XComInteractPoint> InteractionPoints;
    local XComInteractiveLevelActor InteractiveActor;
    local XComGameState_InteractiveObject InteractiveObject;
    local int i;

    if (!UnitHasShadowEffect(Unit))
    {
        return false;
    }

    if (Reason == eCBR_UnitMoveIntoDetectionRange)
    {
        // If we move into detection range, our tile won't protect us.
        // (We're doing this because it means we don't have to replace default concealment tile handling!)
        return false;
    }

    World = `XWORLD;
    Position = World.GetPositionFromTileCoordinates(Tile);
    World.GetCoverPointAtFloor(Position, Cover);
    if (`HAS_HIGH_COVER(Cover))
    {
        return true;
    }

    World.GetInteractionPoints(Position, 8.0f, 90.0f, InteractionPoints);
    for (i = 0; i < InteractionPoints.Length; ++i)
    {
        InteractiveActor = InteractionPoints[i].InteractiveActor;
        if (InteractiveActor != none)
        {
            InteractiveObject = InteractiveActor.GetInteractiveState();
            if (InteractiveObject != none)
            {
                if (InteractiveObject.MustBeHacked() ||
                    InteractiveActor.InteractionAbilityTemplateName == 'Interact_OpenChest' ||
                    InteractiveActor.InteractionAbilityTemplateName == 'Interact_TakeVial' ||
                    InteractiveActor.InteractionAbilityTemplateName == 'Interact_StasisTube' ||
                    InteractiveActor.InteractionAbilityTemplateName == 'Interact_PlantBomb')
                {
                    return true;
                }
            }
        }
    }

    return false;
}

function bool IsUnitConcealmentUnbreakableIgnoringTile(XComGameState GameState, XComGameState_Unit Victim, EConcealBreakReason Reason)
{
    local XComGameStateContext_Ability SourceAbilityContext;
    local name EffectName;

    if (Victim == none)
    {
        `SPOOKLOG("IsUnitConcealmentUnbreakableIgnoringTile: no unit ergo false");
        return false;
    }
    if (!Victim.IsConcealed())
    {
        `SPOOKLOG("IsUnitConcealmentUnbreakableIgnoringTile: not concealed ergo false");
    }

    // Certain abilities, whilst being executed, prevent concealment from breaking.
    SourceAbilityContext = XComGameStateContext_Ability(GameState.GetContext());
    if (SourceAbilityContext != none)
    {
        if (default.UNITS_NOT_REVEALED_ABILITIES.Find(SourceAbilityContext.InputContext.AbilityTemplateName) >= 0)
        {
            `SPOOKLOG("IsUnitConcealmentUnbreakableIgnoringTile: " $ Victim.GetFullName() $ " staying concealed as ability " $ SourceAbilityContext.InputContext.AbilityTemplateName $ " is active");
            return true;
        }
    }

    // Certain effects on the "seen" unit prevent concealment from breaking.
    foreach default.UNITS_NOT_REVEALED_EFFECTS(EffectName)
    {
        if (Victim.IsUnitAffectedByEffectName(EffectName))
        {
            `SPOOKLOG("IsUnitConcealmentUnbreakableIgnoringTile: " $ Victim.GetFullName() $ " staying concealed as has effect " $ EffectName);
            return true;
        }
    }

    `SPOOKLOG("IsUnitConcealmentUnbreakableIgnoringTile: " $ Victim.GetFullName() $ " not staying concealed");
    return false;
}

function bool UnitHasShadowEffect(XComGameState_Unit Unit)
{
    local name EffectName;
    foreach default.SHADOW_EFFECTS(EffectName)
    {
        if (Unit.IsUnitAffectedByEffectName(EffectName))
        {
            return true;
        }
    }
    return false;
}

static function X2Effect_Persistent UnitHasEffect(XComGameState_Unit Unit, name EffectName)
{
    local StateObjectReference EffectRef;
    local XComGameState_Effect EffectState;
    local X2Effect_Persistent EffectTemplate;
    local XComGameStateHistory History;

    History = `XCOMHISTORY;

    foreach Unit.AffectedByEffects(EffectRef)
    {
        EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
        EffectTemplate = EffectState.GetX2Effect();

        if (EffectTemplate != none && EffectTemplate.EffectName == EffectName)
        {
            return EffectTemplate;
        }
    }
    return none;
}

function EventListenerReturn OnUnitTakeEffectDamage(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameStateHistory History;
    local XComGameStateContext_Ability AbilityContext;
    local XComGameState_Unit Damagee, Damager;

    History = `XCOMHISTORY;

    `SPOOKLOG("OnUnitTakeEffectDamage");

    AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
    if( AbilityContext != None )
    {
        Damager = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
        `SPOOKLOG("Damager is " @ Damager.ObjectID);
    }
    else
    {
        `SPOOKLOG("No ability context, no damager");
    }
    Damagee = XComGameState_Unit(EventSource);

    if (Damager != None)
    {
        if (IsUnitConcealmentUnbreakableIgnoringTile(GameState, Damager, eCBR_EnemyTookDamage))
        {
            `SPOOKLOG("Damager stays concealed, no reaction");
            `SPOOKLOG("OnUnitTakeEffectDamage ends");
            return ELR_NoInterrupt;
        }
        `SPOOKLOG("Damager does not stay concealed");
    }

    if (Damagee != None)
    {
        if (Damager == None)
        {
            if (UnitHasEffect(Damagee, 'SpookBleeding') != none)
            {
                `SPOOKLOG("No damager, and damagee suffering from SpookBleeding. Sweeping assumption: no reaction");
                `SPOOKLOG("OnUnitTakeEffectDamage ends");
                return ELR_NoInterrupt;
            }
        }

        `SPOOKLOG("Damagee reacting to damage(r)");
        return Damagee.OnUnitTookDamage(EventData, EventSource, GameState, EventID);
    }
    else
    {
        `SPOOKLOG("No damagee");
    }

    `SPOOKLOG("OnUnitTakeEffectDamage ends");
    return ELR_NoInterrupt;
}

function UnitASeesUnitB(XComGameState_Unit UnitA, XComGameState_Unit UnitB, XComGameState GameState)
{
    local XComGameState_AIGroup AIGroup;

    if (UnitB.IsDead() && !UnitA.HasSeenCorpse(UnitB.ObjectID) && IsCorpseStealthKill(UnitB))
    {
        `SPOOKLOG("UnitASeesUnitB filter marking stealth killed corpse " @ UnitB.ObjectID @ " seen by " @ UnitA.ObjectID);
        UnitA.MarkCorpseSeen(UnitB.ObjectID);
    }

    // Don't register an alert if this unit is about to reflex.
    AIGroup = UnitA.GetGroupMembership();
    if (AIGroup == none || AIGroup.EverSightedByEnemy)
    {
        class'XComGameState_Unit'.static.UnitASeesUnitB(UnitA, UnitB, GameState);
    }
}

static function bool IsCorpseStealthKill(XComGameState_Unit Corpse)
{
    return false; // Corpse.KilledByDamageTypes.Find(class'X2Item_SpookDamageTypes'.const.StealthBleedDamageTypeName) >= 0;
}

function EventListenerReturn OnUnitDied(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState_Unit Unit;
    local XComGameState NewGameState;

    `SPOOKLOG("OnUnitDied");

    Unit = XComGameState_Unit(EventSource);
    if (Unit.IsDead() && IsCorpseStealthKill(Unit) && Unit.KilledByDamageTypes.Find('SpookStealthKillMarker') < 0)
    {
        // This creates a cool possibility - limited time fulton, or limited time until the unit's death is detected, during which time you have
        // to go and pick up the body and move them so that they're not spotted....then we could unmark such corpses as seen if not gotten,
        // triggering alerts and badness. And/or we remove the corpse at time expiry too, and remove the loot unless you hide/fulton the corpse.
        // With changes to detection mechanics (new vis, actual unit LOS being a factor so front fire arc vis, etc.) this could be nice.
        // Also TODO: elevaysheeyon should prevent detection if we're going all Dishonored. So higher up = they can't see you. Nobody looks up, after all.
        // There'd still be roof drones to worry about. Maybe roof drones get instasmurdered, the askholes.
        `SPOOKLOG("Detected a stealth kill");
        NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Marking Spook Stealth Kill");
        Unit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));
        Unit.KilledByDamageTypes.AddItem('SpookStealthKillMarker');
        NewGameState.AddStateObject(Unit);
        NewGameState.GetContext().PostBuildVisualizationFn.AddItem(BuildSimpleVisualizationForStealthKill);
        `TACTICALRULES.SubmitGameState(NewGameState);
    }

    `SPOOKLOG("OnUnitDied ends");
    return ELR_NoInterrupt;
}

static function BuildSimpleVisualizationForStealthKill(XComGameState GameState, out array<VisualizationTrack> OutVisualizationTracks)
{
    local XComGameStateHistory          History;
    local XComGameState_Unit            Prospect, Unit;
    local Actor                         UnitVisualizer;

    local VisualizationTrack            Track;
    local X2Action_PlaySoundAndFlyOver  SoundAndFlyOver;

    History = `XCOMHISTORY;

    foreach GameState.IterateByClassType(class'XComGameState_Unit', Prospect)
    {
        Unit = Prospect;
    }

    UnitVisualizer = History.GetVisualizer(Unit.ObjectID);
    Track.StateObject_OldState = History.GetGameStateForObjectID(Unit.ObjectID, eReturnType_Reference, GameState.HistoryIndex - 1);
    Track.StateObject_NewState = Unit;
    Track.TrackActor = UnitVisualizer;

    SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(Track, GameState.GetContext()));
    SoundAndFlyOver.SetSoundAndFlyOverParameters(none, default.StealthKilledFriendlyName, '', eColor_Good,, 0, false);

    OutVisualizationTracks.AddItem(Track);
}

function CleanseBurningIfInWater(XComGameState_Unit Unit)
{
    local TTile Tile;
    local XComGameState_Effect EffectState;
    local X2Effect_Persistent PersistentEffect;
    local XComGameStateContext_EffectRemoved Context;
    local XComGameState NewGameState;
    local XComGameStateHistory History;

    GetOwnTile(Unit, Tile);
    if (Unit.IsBurning() && `XWORLD.IsWaterTile(Tile))
    {
        History = `XCOMHISTORY;
        foreach History.IterateByClassType(class'XComGameState_Effect', EffectState)
        {
            if (EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID == Unit.ObjectID)
            {
                PersistentEffect = EffectState.GetX2Effect();
                if (PersistentEffect.EffectName == class'X2StatusEffects'.default.BurningName)
                {
                    Context = class'XComGameStateContext_EffectRemoved'.static.CreateEffectRemovedContext(EffectState);
                    NewGameState = History.CreateNewGameState(true, Context);
                    EffectState.RemoveEffect(NewGameState, NewGameState, true);
                    `TACTICALRULES.SubmitGameState(NewGameState);
                }
            }
        }
    }
}

// X2VisualizationMgrObserverInterface
event OnVisualizationBlockComplete(XComGameState AssociatedGameState);

// X2VisualizationMgrObserverInterface
event OnVisualizationIdle();

// X2VisualizationMgrObserverInterface
event OnActiveUnitChanged(XComGameState_Unit NewActiveUnit)
{
    // We don't want SHADOW_NOT_REVEALED_BY_CLASSES units to reveal spooks
    // (strictly units with SHADOW_EFFECTS, but that's only spooks) on them.
    // We do want SHADOW_NOT_REVEALED_BY_CLASSES units to reveal everyone else
    // as usual.
    //
    // We officially handle this in DetectionManager.BreaksConcealment().
    // But this doesn't affect concealment-breaking *visuals* (tiles, and
    // raised-on-a-stick stepping-on-this-tile-is-bad indicators such as those
    // built in and further provided by e.g. the "Gotcha Again" mod). When
    // it's time to move a spook, we want zero red tiles around these units,
    // and no on-a-stick indicators if we walk right up to them.
    //
    // So, we use special abilities to debuff SHADOW_NOT_REVEALED_BY_CLASSES
    // units during the spook unit's turn; specifically we toggle on the debuff
    // when the spook becomes active, and toggle it off again if the user tabs
    // to another unit. This is highly unusual since, like console cheats, we're
    // changing the game state (applying effects to units) outside of normal
    // unit actions, and all of this is written into game state history.
    //
    // Only spooks possess these special abilities, only triggered by us not
    // the player (who isn't even aware they exist), and they go hand in hand
    // with the shadow effect which is applied by the Veil ability, though
    // they're not triggered by Veil either, but by us in response to active
    // unit changes as the player tabs between units.
    //
    // This should stop all visual indicators as we want, which it does.
    // It should also mean our GetConcealmentDetectionDistanceMeters() sees
    // zero for eStat_DetectionRadius during our turn when moving a spook, which
    // didn't appear to be the case in brief testing, however, we don't care,
    // since we deliberately handle the mechanic in
    // DetectionManager.BreaksConcealment() anyway (and were doing so before we
    // started fretting about visuals) and hence avoid relying on this radius
    // being zero during the shadow spook's turn, other than to suppress
    // concealment-breaking visuals, which is working fine.
    //
    // We can't and don't want to rely on the enemy detection radius being zero
    // during the enemy turn, "can't" because a) it may be bugged, see above and
    // "don't want to" because b) we don't want this zero radius applying to all
    // units. So...
    //
    // We've also set these debuffs to expire at the end of the turn (via
    // BuildPersistentEffect parameters), so that eStat_DetectionRadius returns
    // to normal, in case the game gets over its apparent radius bug by the
    // following turn. We want it normal anyway, so that *other* (ie. non-spook)
    // units *can* be detected by SHADOW_NOT_REVEALED_BY_CLASSES units (we don't
    // want their detection radius zero other than when we're moving a spook),
    // but we *also* don't want spooks detected by SHADOW_NOT_REVEALED_BY_CLASSES
    // units, so it's handy our DetectionManager.BreaksConcealment() code is
    // handling that anyway.
    //
    // All in all, if we didn't care about visuals, we could remove these
    // special abilities completely and rely on
    // DetectionManager.BreaksConcealment() to handle this 100% reliably.
    //
    // Yes, it's confounding. This game behaves strangely when modded.
    //
    // Addendum: I may have found the bug of which I accused the game. If the
    // game isn't capping eStat_DetectionRadius at a minimum of zero, then
    // actually it's worth noting what we did is add a massive negative
    // modifier. This will very, very likely make it massively negative.
    // Since we *square it* and then test whether the square of the unit's
    // distance is less than this, and the squaring removes the sign, we
    // may have tripped ourselves up! I've hence put a fix into the function
    // GetConcealmentDetectionDistanceMeters() to clamp the value at zero if
    // below zero, via FMax(n, 0). Cough.
    local XComGameState GameState;
    local name ApplyName, CancelName;

    ApplyName = class'X2Ability_SpookAbilitySet'.const.ShadowNotRevealedByClassesName;
    CancelName = class'X2Ability_SpookAbilitySet'.const.ShadowNotRevealedByClassesCancelName;

    GameState = `XCOMHISTORY.GetGameStateFromHistory(-1);
    `SPOOKLOG("OnActiveUnitChanged");
    `SPOOKLOG("Triggering event " $ CancelName);
    `XEVENTMGR.TriggerEvent(CancelName, none, none, GameState);
    if (NewActiveUnit != none && NewActiveUnit.FindAbility(ApplyName).ObjectID != 0)
    {
        `SPOOKLOG("Triggering event " $ ApplyName $ " for active unit " $ NewActiveUnit.GetMyTemplateName() $ " " $ NewActiveUnit.GetFullName());
        `XEVENTMGR.TriggerEvent(ApplyName, NewActiveUnit, NewActiveUnit, GameState);
    }
}

defaultproperties
{
    StatOverrideSpecialDetectionModifier=666.0
}
