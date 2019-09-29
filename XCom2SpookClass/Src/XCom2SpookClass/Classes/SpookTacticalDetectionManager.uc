class SpookTacticalDetectionManager
    extends Object
    implements(X2VisualizationMgrObserverInterface)
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var localized string StealthKilledFriendlyName;

var config array<name> WIRED_NOT_REVEALED_BY_CLASSES;
var config array<name> UNITS_NOT_REVEALED_ABILITIES;
var config array<name> UNITS_NOT_REVEALED_EFFECTS;

var config bool MELD_HIGH_COVER;
var config bool MELD_HACKABLE;
var config array<name> MELD_INTERACTABLE;

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

    `XEVENTMGR.RegisterForEvent(This, 'PlayerTurnBegun', OnPlayerTurnBegun, ELD_OnStateSubmitted);
    `XEVENTMGR.RegisterForEvent(This, 'PlayerTurnEnded', OnPlayerTurnEnded, ELD_OnStateSubmitted);
    `XEVENTMGR.RegisterForEvent(This, 'UnitSpawned', OnUnitSpawned, ELD_OnStateSubmitted);
    ReplaceEventListeners();
    `XCOMVISUALIZATIONMGR.RegisterObserver(self);
}

// X2VisualizationMgrObserverInterface
event OnVisualizationBlockComplete(XComGameState AssociatedGameState);
event OnVisualizationIdle();
event OnActiveUnitChanged(XComGameState_Unit NewActiveUnit)
{
    HandleWiredAbilityOnActiveUnitChanged(NewActiveUnit);
}

static function OnPostTemplatesCreated()
{
    // ChangeForm, BurrowedAttack, UnburrowSawEnemy, ChangeFormSawEnemy
    UpdateRevealAbilityTemplate('ChangeForm');
    UpdateRevealAbilityTemplate('ChangeFormSawEnemy');
    UpdateRevealAbilityTemplate('BurrowedAttack');
    UpdateRevealAbilityTemplate('UnburrowSawEnemy');

    if (class'X2Ability_SpookAbilitySet'.default.DISTRACT_EXCLUDE_RED_ALERT)
    {
        `SPOOKSLOG("Distract excludes red alert and hence is cancelled by it");
        RedAlertCancelsDistract();
    }
    else
    {
        `SPOOKSLOG("Distract does NOT exclude red alert");
    }
}

function EventListenerReturn OnPlayerTurnBegun(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState_Player Player;

    Player = XComGameState_Player(EventSource);
    `SPOOKLOG("OnPlayerTurnBegun: " $ (`IsHumanPlayer(Player) ? "Human" : "AI"));

    // Hook any new enemies from last turn.
    ReplaceEventListeners();
    return ELR_NoInterrupt;
}

function EventListenerReturn OnPlayerTurnEnded(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState_Player Player;
    local XComGameState_Ability Ability;
    local XComGameState_Unit Unit;

    Player = XComGameState_Player(EventSource);
    `SPOOKLOG("OnPlayerTurnEnded: " $ (`IsHumanPlayer(Player) ? "Human" : "AI"));

    // Find each of this player's units which can Meld, by finding each Meld
    // ability and walking back to its owning unit and their controlling player.
    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Ability', Ability)
    {
        if (Ability.GetMyTemplateName() != class'X2Ability_SpookAbilitySet'.const.MeldAbilityName)
        {
            continue;
        }

        Unit = `FindUnitState(Ability.OwnerStateObject.ObjectID);
        if (Unit != none && Unit.ControllingPlayer.ObjectID == Player.ObjectID)
        {
            // If you can Meld, Meld.
            HandleMeldAbilityOnPlayerTurnEnd(Unit, GameState);
        }
    }
    return ELR_NoInterrupt;
}

function EventListenerReturn OnUnitSpawned(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local X2EventManager EventMgr;
    local XComGameState_Unit Unit;

    EventMgr = `XEVENTMGR;
    Unit = XComGameState_Unit(EventData);
    `SPOOKLOG("OnUnitSpawned: " $ (Unit != none ? "Valid" : "Invalid"));

    if (Unit != none)
    {
        UnregisterUnitEvents(EventMgr, Unit);
    }
    return ELR_NoInterrupt;
}

function UnregisterUnitEvents(X2EventManager EventMgr, XComGameState_Unit Unit)
{
    EventMgr.UnRegisterFromEvent(Unit, 'ObjectMoved');
    EventMgr.UnRegisterFromEvent(Unit, 'UnitTakeEffectDamage');
}

function ReplaceEventListeners()
{
    local Object This;
    local X2EventManager EventMgr;
    local XComGameStateHistory History;
    local XComGameState_Unit Unit;
    local XComGameState_Player PlayerState;

    History = `XCOMHISTORY;
    EventMgr = `XEVENTMGR;
    This = self;

    `SPOOKLOG("ReplaceEventListeners");

    foreach History.IterateByClassType(class'XComGameState_Unit', Unit)
    {
        UnregisterUnitEvents(EventMgr, Unit);
    }

    foreach History.IterateByClassType(class'XComGameState_Player', PlayerState)
    {
        EventMgr.UnRegisterFromEvent(PlayerState, 'ObjectVisibilityChanged');
    }

    EventMgr.RegisterForEvent(This, 'ObjectVisibilityChanged', OnObjectVisibilityChanged, ELD_OnStateSubmitted);

    EventMgr.RegisterForEvent(This, 'ObjectMoved', OnUnitEnteredTile, ELD_OnStateSubmitted);
    //EventMgr.RegisterForEvent(This, 'UnitMoveFinished', OnUnitMoveFinished, ELD_OnStateSubmitted);

    EventMgr.RegisterForEvent(This, 'UnitTakeEffectDamage', OnUnitTakeEffectDamage, ELD_OnStateSubmitted);
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

function EventListenerReturn OnUnitEnteredTile(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState_Unit Mover, Bystander;
    local XComGameState_InteractiveObject InteractiveObject;
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

    foreach History.IterateByClassType(class'XComGameState_InteractiveObject', InteractiveObject)
    {
        Mover = TryDetectorSeeingVictim(InteractiveObject, Mover, GameState, eCBR_UnitMoveIntoDetectionRange, eCH_IgnoreCover);
    }

    foreach History.IterateByClassType(class'XComGameState_Unit', Bystander)
    {
        Mover = TryDetectorSeeingVictim(Bystander, Mover, GameState, eCBR_UnitMoveIntoDetectionRange, eCH_IgnoreCover);
        Bystander = TryDetectorSeeingVictim(Mover, Bystander, GameState, eCBR_EnemyMoveIntoDetectionRange, eCH_SafeInCover);
    }

    return ELR_NoInterrupt;
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
            if (Damagee.IsUnitAffectedByEffectName(class'X2Effect_SpookBleeding'.const.BleedEffectName))
            {
                `SPOOKLOG("No damager, and damagee suffering from SpookBleeding. Sweeping assumption: no reaction");
                `SPOOKLOG("OnUnitTakeEffectDamage ends");
                return ELR_NoInterrupt;
            }
        }

        `SPOOKLOG("Damagee reacting to damage");
        return Damagee.OnUnitTookDamage(EventData, EventSource, GameState, EventID);
    }
    else
    {
        `SPOOKLOG("No damagee");
    }

    `SPOOKLOG("OnUnitTakeEffectDamage ends");
    return ELR_NoInterrupt;
}

function XComGameState_Unit TryDetectorSeeingVictim(XComGameState_BaseObject Detector, XComGameState_Unit Victim, XComGameState GameState, EConcealBreakReason Reason, ECoverHandling CoverHandling)
{
    local XComGameState_Unit Enemy;
    local GameRulesCache_VisibilityInfo Visibility;

    if (Detector == none || Victim == none || GameState == none
        || Detector.ObjectID == Victim.ObjectID
        || Victim.GetMyTemplate().bIsCosmetic
        || Victim.bRemovedFromPlay)
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
        `GetOwnTile(Detector, DetectorTile);
        `GetOwnTile(Victim, VictimTile);

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

function bool IsUnitConcealmentUnbreakable(XComGameState GameState, XComGameState_Unit Unit, EConcealBreakReason Reason)
{
    local TTile Tile;
    `GetOwnTile(Unit, Tile);
    return IsTileUnbreakablyConcealingForUnit(Unit, Tile, Reason) ||
           IsUnitConcealmentUnbreakableIgnoringTile(GameState, Unit, Reason);
}

function bool IsTileUnbreakablyConcealingForUnit(XComGameState_Unit Unit, out TTile Tile, EConcealBreakReason Reason)
{
    if (Reason == eCBR_UnitMoveIntoDetectionRange)
    {
        // If we move into detection range, our tile won't protect us.
        // (We're doing this because it means we don't have to replace default concealment tile handling!)
        return false;
    }

    if (CanUnitMeldHere(Unit, Tile))
    {
        // If the unit *can* Meld here, they are unbreakably concealed.
        // It is not necessary for them to have Melded (inducing Shade).
        return true;
    }

    return false;
}

function bool BreaksConcealment(XComGameState_BaseObject Detector, XComGameState_Unit Victim, EConcealBreakReason Reason)
{
    local XComGameState_Unit Enemy;
    local XComGameState_InteractiveObject InteractiveObject;

    Enemy = XComGameState_Unit(Detector);
    if (Enemy != none)
    {
        if (Victim.IsUnitAffectedByEffectName(class'X2Ability_SpookAbilitySet'.const.WiredAbilityName) && default.WIRED_NOT_REVEALED_BY_CLASSES.Find(Enemy.GetMyTemplateName()) >= 0)
        {
            return false;
        }
        return Victim.IsAlive() && Enemy.IsAlive() && Victim.UnitBreaksConcealment(Enemy);
    }

    InteractiveObject = XComGameState_InteractiveObject(Detector);
    if (InteractiveObject != none)
    {
        // Likely an ADVENT tower.
        return InteractiveObject.Health > 0 &&
               InteractiveObject.DetectionRange > 0.0 &&
               !InteractiveObject.bHasBeenHacked;
    }

    return false;
}

function float GetConcealmentDetectionDistanceUnits(XComGameState_BaseObject Detector, XComGameState_Unit Victim)
{
    local XComGameState_Unit Enemy;
    local XComGameState_InteractiveObject InteractiveObject;
    local float DetectionRadius;
    local float SightRadius;

    Enemy = XComGameState_Unit(Detector);
    if (Enemy != none)
    {
        SightRadius = Enemy.GetVisibilityRadius();
        DetectionRadius = FMax(Enemy.GetCurrentStat(eStat_DetectionRadius), 0.0);
        DetectionRadius = DetectionRadius * FMax(1.0 - Victim.GetCurrentStat(eStat_DetectionModifier), 0.0);
        DetectionRadius = FMin(SightRadius, DetectionRadius);
        return `METERSTOUNITS(DetectionRadius);
    }

    InteractiveObject = XComGameState_InteractiveObject(Detector);
    if (InteractiveObject != none)
    {
        return InteractiveObject.DetectionRange;
    }

    return 0;
}

function bool CanUnitMeldHere(XComGameState_Unit Unit, out TTile Tile)
{
    local XComWorldData World;
    local vector Position;
    local XComCoverPoint Cover;
    local array<XComInteractPoint> InteractionPoints;
    local XComInteractiveLevelActor InteractiveActor;
    local XComGameState_InteractiveObject InteractiveObject;
    local int i;

    if (Unit.FindAbility(class'X2Ability_SpookAbilitySet'.const.MeldAbilityName).ObjectID == 0)
    {
        return false;
    }

    World = `XWORLD;
    Position = World.GetPositionFromTileCoordinates(Tile);
    World.GetCoverPointAtFloor(Position, Cover);
    if (`HAS_HIGH_COVER(Cover) && default.MELD_HIGH_COVER)
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
                if ((InteractiveObject.MustBeHacked() && default.MELD_HACKABLE) ||
                    default.MELD_INTERACTABLE.Find(InteractiveActor.InteractionAbilityTemplateName) >= 0)
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
        return false;
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

function HandleWiredAbilityOnActiveUnitChanged(XComGameState_Unit NewActiveUnit)
{
    // We don't want WIRED_NOT_REVEALED_BY_CLASSES units to reveal Wired units,
    // but we do want them to reveal everyone else.
    //
    // We handle gameplay in DetectionManager.BreaksConcealment(), but this
    // doesn't affect concealment-breaking visuals (tiles and Gotcha Again).
    // When it's time to move a spook, we don't want these visible.
    //
    // We use a special ability to debuff WIRED_NOT_REVEALED_BY_CLASSES units
    // when the Wired unit becomes active (tab/click). The debuff expires at
    // the end of the turn and we remove it if the user tabs to another unit.
    local XComGameStateHistory History;
    local XComGameState GameState, NewGameState;
    local XComGameState_Effect EffectState;
    local X2Effect_Persistent PersistentEffect;
    local XComGameState_Unit Unit;
    local XComGameStateContext_EffectRemoved Context;
    local name ApplyName;

    `SPOOKLOG("OnActiveUnitChanged");
    History = `XCOMHISTORY;
    ApplyName = class'X2Ability_SpookAbilitySet'.const.WiredNotRevealedByClassesName;

    foreach History.IterateByClassType(class'XComGameState_Effect', EffectState)
    {
        PersistentEffect = EffectState.GetX2Effect();
        if (PersistentEffect.EffectName == ApplyName)
        {
            Unit = `FindUnitState(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID,, History);
            `SPOOKLOG("Removing " $ ApplyName $ " from " $ Unit.GetMyTemplateName() $ " " $ Unit.ObjectID);

            Context = class'XComGameStateContext_EffectRemoved'.static.CreateEffectRemovedContext(EffectState);
            NewGameState = History.CreateNewGameState(true, Context);
            EffectState.RemoveEffect(NewGameState, NewGameState, true);
            `TACTICALRULES.SubmitGameState(NewGameState);
        }
    }

    GameState = History.GetGameStateFromHistory(-1);
    if (NewActiveUnit != none && NewActiveUnit.FindAbility(ApplyName).ObjectID != 0)
    {
        `SPOOKLOG("Triggering event " $ ApplyName $ " for active unit " $ NewActiveUnit.GetMyTemplateName() $ " " $ NewActiveUnit.GetFullName());
        `XEVENTMGR.TriggerEvent(ApplyName, NewActiveUnit, NewActiveUnit, GameState);
    }
}

function HandleMeldAbilityOnPlayerTurnEnd(XComGameState_Unit Unit, XComGameState GameState)
{
    local XComGameState_Ability MeldTrigger;
    local TTile Tile;

    `SPOOKLOG("HandleMeldAbilityOnPlayerTurnEnd");

    // Note: This could easily have caused flicker in/out conflicts given:
    //       i) Unit Vanishes (which triggers Shade until turn end), and moves
    //          into high cover with their free vanish move; then
    //       ii) At that same turn end in high cover, the unit's Meld kicks in,
    //           inducing Shade.
    //
    // However, fortuitously it seems we activate Shade 2 before Shade 1
    // expires, i.e. this very function is called just before the previous
    // effect hits its turn end tick. Since the shade visualizer checks the
    // effect count before deciding what to do, this works out nicely.
    `GetOwnTile(Unit, Tile);
    if (Unit.IsConcealed() && CanUnitMeldHere(Unit, Tile))
    {
        MeldTrigger = `FindAbilityState(Unit.FindAbility(class'X2Ability_SpookAbilitySet'.const.MeldTriggerAbilityName).ObjectID, GameState);
        if (MeldTrigger != none)
        {
            `SPOOKLOG("Triggering " $ MeldTrigger.GetMyTemplateName());
            MeldTrigger.AbilityTriggerAgainstSingleTarget(MeldTrigger.OwnerStateObject, false);
        }
    }
}

function UnitASeesUnitB(XComGameState_Unit UnitA, XComGameState_Unit UnitB, XComGameState GameState)
{
    local XComGameState_AIGroup AIGroup;

    // Don't register an alert if this unit is about to reflex.
    AIGroup = UnitA.GetGroupMembership();
    if (AIGroup == none || AIGroup.EverSightedByEnemy)
    {
        class'XComGameState_Unit'.static.UnitASeesUnitB(UnitA, UnitB, GameState);
    }
}

function CleanseBurningIfInWater(XComGameState_Unit Unit)
{
    local TTile Tile;
    local XComGameState_Effect EffectState;
    local X2Effect_Persistent PersistentEffect;
    local XComGameStateContext_EffectRemoved Context;
    local XComGameState NewGameState;
    local XComGameStateHistory History;

    `GetOwnTile(Unit, Tile);
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

static function UpdateRevealAbilityTemplate(name AbilityName)
{
    local X2AbilityTemplate Template;
    local X2Condition_UnitProperty UnitPropertyCondition;

    Template = `XABILITYMANAGER.FindAbilityTemplate(AbilityName);
    if (Template == none)
    {
        return;
    }

    // Concealed units cannot be targeted for e.g. concealment removal, nor can
    // concealed movement set off alarms.
    //
    //  i) Prevent X2Effect_BreakUnitConcealment from being applied as a
    //     multi-target effect via this template.
    //
    // ii) Prevents CheckForVisibleMovementIn[..]Radius_Self from counting
    //     concealed units, since that function delegates back to the ability's
    //     multi-target conditions to check target suitability.
    //
    UnitPropertyCondition = new class'X2Condition_UnitProperty';
    UnitPropertyCondition.ExcludeConcealed = true;
    Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);
    `SPOOKSLOG("Updated " $ Template.DataName $ " to exclude concealed units");
}

static function RedAlertCancelsDistract()
{
    local X2DataTemplate DataTemplate;
    local X2AbilityTemplate Template;
    local SpookRedAlertVisualizer Visualizer;
    local bool bModified;

    foreach `XABILITYMANAGER.IterateTemplates(DataTemplate, none)
    {
        Template = X2AbilityTemplate(DataTemplate);
        if (Template == none)
        {
            continue;
        }

        bModified = false;
        if (ContainsRedAlertEffect(Template.AbilityShooterEffects))
        {
            Template.AddShooterEffect(CreateDistractRemover(Template, "AbilityShooterEffects"));
            bModified = true;
        }
        if (ContainsRedAlertEffect(Template.AbilityTargetEffects))
        {
            Template.AddTargetEffect(CreateDistractRemover(Template, "AbilityTargetEffects"));
            bModified = true;
        }
        if (ContainsRedAlertEffect(Template.AbilityMultiTargetEffects))
        {
            Template.AddMultiTargetEffect(CreateDistractRemover(Template, "AbilityMultiTargetEffects"));
            bModified = true;
        }
        if (bModified)
        {
            Visualizer = new class'SpookRedAlertVisualizer';
            Visualizer.AttachTo(Template);
        }
    }
}

static function bool ContainsRedAlertEffect(out const array<X2Effect> Effects)
{
    local X2Effect Effect;
    local X2Effect_RedAlert RedAlert;

    foreach Effects(Effect)
    {
        RedAlert = X2Effect_RedAlert(Effect);
        if (RedAlert != none)
        {
            return true;
        }
    }
    return false;
}

static function X2Effect CreateDistractRemover(X2AbilityTemplate Template, string ListName)
{
    local X2Effect_SpookRemoveEffects Effect;
    Effect = new class'X2Effect_SpookRemoveEffects';
    Effect.EffectNamesToRemove.AddItem(class'XComGameState_SpookDistractEffect'.const.DistractedEffectName);
    `SPOOKSLOG("Modifying ability " $ Template.DataName $ " to cancel Distract when it adds Red Alert via " $ ListName);
    return Effect;
}
