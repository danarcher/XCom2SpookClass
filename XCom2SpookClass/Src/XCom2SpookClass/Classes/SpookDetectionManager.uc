class SpookDetectionManager
    extends Object
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var localized string StealthKilledFriendlyName;

var config array<name> SHADOW_EFFECTS;
var config array<name> SHADOW_NOT_REVEALED_BY_CLASSES;
var config bool SHADOW_NOT_REVEALED_BY_DETECTOR;
var config array<name> UNITS_NOT_REVEALED_ABILITIES;
var config array<name> UNITS_NOT_REVEALED_EFFECTS;

function OnInit()
{
    local Object This;
    This = self;

    `SPOOKLOG("OnInit");
    `XEVENTMGR.RegisterForEvent(This, 'PlayerTurnBegun', OnPlayerTurnBegun, ELD_OnStateSubmitted);
    `XEVENTMGR.RegisterForEvent(This, 'UnitSpawned', OnUnitSpawned, ELD_OnStateSubmitted);
    ReplaceEventListeners();
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

// Via LW2
function EventListenerReturn OnObjectVisibilityChanged(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local X2GameRulesetVisibilityInterface SourceObject;
    local XComGameState_Unit SeenUnit;
    local XComGameState_Unit SourceUnit;
    local GameRulesCache_VisibilityInfo VisibilityInfo;
    local X2GameRulesetVisibilityManager VisibilityMgr;

    VisibilityMgr = `TACTICALRULES.VisibilityMgr;

    SourceObject = X2GameRulesetVisibilityInterface(EventSource);

    SeenUnit = XComGameState_Unit(EventData); // we only care about enemy units
    // LWS Mods: Don't trigger on cosmetic units (see comments in XCGS_Unit about gremlins not wanting to receive movement events).
    // Fixes bugs with Gremlins activating pods when you cancel a hack or when movement causes the gremlin to be visible while the unit
    // isn't.
    if(SeenUnit != none && SourceObject.TargetIsEnemy(SeenUnit.ObjectID) && !SeenUnit.GetMyTemplate().bIsCosmetic)
    {
        SourceUnit = XComGameState_Unit(SourceObject);
        if(SourceUnit != none && GameState != none)
        {
            VisibilityMgr.GetVisibilityInfo(SourceUnit.ObjectID, SeenUnit.ObjectID, VisibilityInfo, GameState.HistoryIndex);
            if(VisibilityInfo.bVisibleGameplay)
            {
                // (Deleted alien noises code, not possible, since XComGameState_Player.TurnsSinceEnemySeen is privatewrite.)

                //Inform the units that they see each other
                UnitASeesUnitB(SourceUnit, SeenUnit, GameState);
            }
            else if (VisibilityInfo.bVisibleBasic && !StayConcealed(GameState, SeenUnit, SourceUnit))
            {
                //If the target is not yet gameplay-visible, it might be because they are concealed.
                //Check if the source should break their concealment due to the new conditions.
                //(Typically happens in XComGameState_Unit when a unit moves, but there are edge cases,
                //like blowing up the last structure between two units, when it needs to happen here.)
                if (SeenUnit.IsConcealed() && SeenUnit.UnitBreaksConcealment(SourceUnit) && VisibilityInfo.TargetCover == CT_None)
                {
                    if (VisibilityInfo.DefaultTargetDist <= Square(SeenUnit.GetConcealmentDetectionDistance(SourceUnit)))
                    {
                        SeenUnit.BreakConcealment(SourceUnit, VisibilityInfo.TargetCover == CT_None);
                    }
                }
            }
        }
    }

    return ELR_NoInterrupt;
}

// unit moves - alert for him for other units he sees from the new location
// unit moves - alert for other units towards this unit
function EventListenerReturn OnUnitEnteredTile(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState_Unit OtherUnitState, ThisUnitState;
    local XComGameStateHistory History;
    local X2GameRulesetVisibilityManager VisibilityMgr;
    local GameRulesCache_VisibilityInfo VisibilityInfoFromThisUnit, VisibilityInfoFromOtherUnit;
    local float ConcealmentDetectionDistance;
    local XComGameState_AIGroup AIGroupState;
    local XComGameStateContext_Ability SourceAbilityContext;
    local XComGameState_InteractiveObject InteractiveObjectState;
    local XComWorldData WorldData;
    local Vector CurrentPosition, TestPosition;
    local TTile CurrentTileLocation;
    local XComGameState_Effect EffectState;
    local X2Effect_Persistent PersistentEffect;
    local XComGameState NewGameState;
    local XComGameStateContext_EffectRemoved EffectRemovedContext;

    WorldData = `XWORLD;
    History = `XCOMHISTORY;

    ThisUnitState = XComGameState_Unit(EventData);

    // don't activate from Gremlins etc
    if (ThisUnitState.GetMyTemplate().bIsCosmetic) { return ELR_NoInterrupt; }

    ThisUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ThisUnitState.ObjectID));

    // cleanse burning on entering water
    ThisUnitState.GetKeystoneVisibilityLocation(CurrentTileLocation);
    if( ThisUnitState.IsBurning() && WorldData.IsWaterTile(CurrentTileLocation) )
    {
        foreach History.IterateByClassType(class'XComGameState_Effect', EffectState)
        {
            if( EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID == ThisUnitState.ObjectID )
            {
                PersistentEffect = EffectState.GetX2Effect();
                if( PersistentEffect.EffectName == class'X2StatusEffects'.default.BurningName )
                {
                    EffectRemovedContext = class'XComGameStateContext_EffectRemoved'.static.CreateEffectRemovedContext(EffectState);
                    NewGameState = History.CreateNewGameState(true, EffectRemovedContext);
                    EffectState.RemoveEffect(NewGameState, NewGameState, true); //Cleansed

                    `TACTICALRULES.SubmitGameState(NewGameState);
                }
            }
        }
    }

    SourceAbilityContext = XComGameStateContext_Ability(GameState.GetContext());

    if( SourceAbilityContext != None )
    {
        // concealment for this unit is broken when stepping into a new tile if the act of stepping into the new tile caused environmental damage (ex. "broken glass")
        // if this occurred, then the GameState will contain either an environmental damage state or an InteractiveObject state
        if( ThisUnitState.IsConcealed() && SourceAbilityContext.ResultContext.bPathCausesDestruction && !StayConcealed(GameState, ThisUnitState, none))
        {
            ThisUnitState.BreakConcealment();
        }

        ThisUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ThisUnitState.ObjectID));

        // check if this unit is a member of a group waiting on this unit's movement to complete
        // (or at least reach the interruption step where the movement should complete)
        AIGroupState = ThisUnitState.GetGroupMembership();
        if( AIGroupState != None &&
            AIGroupState.IsWaitingOnUnitForReveal(ThisUnitState) &&
            (SourceAbilityContext.InterruptionStatus != eInterruptionStatus_Interrupt ||
            (AIGroupState.FinalVisibilityMovementStep > INDEX_NONE &&
            AIGroupState.FinalVisibilityMovementStep <= SourceAbilityContext.ResultContext.InterruptionStep)) )
        {
            AIGroupState.StopWaitingOnUnitForReveal(ThisUnitState);
        }
    }

    // concealment may be broken by moving within range of an interactive object 'detector'
    if(ThisUnitState.IsConcealed())
    {
        ThisUnitState.GetKeystoneVisibilityLocation(CurrentTileLocation);
        CurrentPosition = WorldData.GetPositionFromTileCoordinates(CurrentTileLocation);

        foreach History.IterateByClassType(class'XComGameState_InteractiveObject', InteractiveObjectState)
        {
            if( InteractiveObjectState.DetectionRange > 0.0 && !InteractiveObjectState.bHasBeenHacked && !StayConcealed(GameState, ThisUnitState, InteractiveObjectState))
            {
                TestPosition = WorldData.GetPositionFromTileCoordinates(InteractiveObjectState.TileLocation);

                if( VSizeSq(TestPosition - CurrentPosition) <= Square(InteractiveObjectState.DetectionRange) )
                {
                    ThisUnitState.BreakConcealment();
                    ThisUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ThisUnitState.ObjectID));
                    break;
                }
            }
        }
    }

    // concealment may also be broken if this unit moves into detection range of an enemy unit
    VisibilityMgr = `TACTICALRULES.VisibilityMgr;
    foreach History.IterateByClassType(class'XComGameState_Unit', OtherUnitState)
    {
        // don't process visibility against self
        if( OtherUnitState.ObjectID == ThisUnitState.ObjectID )
        {
            continue;
        }

        VisibilityMgr.GetVisibilityInfo(ThisUnitState.ObjectID, OtherUnitState.ObjectID, VisibilityInfoFromThisUnit);

        if( VisibilityInfoFromThisUnit.bVisibleBasic )
        {
            // check if the other unit is concealed, and this unit's move has revealed him
            if( OtherUnitState.IsConcealed() &&
                OtherUnitState.UnitBreaksConcealment(ThisUnitState) &&
                VisibilityInfoFromThisUnit.TargetCover == CT_None &&
                !StayConcealed(GameState, OtherUnitState, ThisUnitState))
            {
                ConcealmentDetectionDistance = OtherUnitState.GetConcealmentDetectionDistance(ThisUnitState);
                if( VisibilityInfoFromThisUnit.DefaultTargetDist <= Square(ConcealmentDetectionDistance))
                {
                    OtherUnitState.BreakConcealment(ThisUnitState, true);

                    // have to refresh the unit state after broken concealment
                    OtherUnitState = XComGameState_Unit(History.GetGameStateForObjectID(OtherUnitState.ObjectID));
                }
            }

            // generate alert data for this unit about other units
            UnitASeesUnitB(ThisUnitState, OtherUnitState, GameState);
        }

        // only need to process visibility updates from the other unit if it is still alive
        if( OtherUnitState.IsAlive() )
        {
            VisibilityMgr.GetVisibilityInfo(OtherUnitState.ObjectID, ThisUnitState.ObjectID, VisibilityInfoFromOtherUnit);

            if( VisibilityInfoFromOtherUnit.bVisibleBasic )
            {
                // check if this unit is concealed and that concealment is broken by entering into an enemy's detection tile
                if( ThisUnitState.IsConcealed() && ThisUnitState.UnitBreaksConcealment(OtherUnitState) && !StayConcealed(GameState, ThisUnitState, OtherUnitState))
                {
                    ConcealmentDetectionDistance = ThisUnitState.GetConcealmentDetectionDistance(OtherUnitState);
                    if( VisibilityInfoFromOtherUnit.DefaultTargetDist <= Square(ConcealmentDetectionDistance))
                    {
                        ThisUnitState.BreakConcealment(OtherUnitState);

                        // have to refresh the unit state after broken concealment
                        ThisUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ThisUnitState.ObjectID));
                    }
                }

                // generate alert data for other units that see this unit
                if( VisibilityInfoFromOtherUnit.bVisibleBasic && !ThisUnitState.IsConcealed() )
                {
                    //  don't register an alert if this unit is about to reflex
                    AIGroupState = OtherUnitState.GetGroupMembership();
                    if (AIGroupState == none || AIGroupState.EverSightedByEnemy)
                    {
                        UnitASeesUnitB(OtherUnitState, ThisUnitState, GameState);
                    }
                }
            }
        }
    }

    return ELR_NoInterrupt;
}

function bool StayConcealed(XComGameState GameState, XComGameState_Unit SeenUnit, XComGameState_BaseObject Watcher)
{
    local XComGameState_Unit WatcherUnit;
    local XComGameState_InteractiveObject WatcherDetector;
    local XComGameStateContext_Ability SourceAbilityContext;
    local name EffectName;
    local TTile SeenUnitTileLocation;
    local Vector SeenUnitPosition;
    local XComCoverPoint SeenUnitCover;
    local bool HasHighCover;
    local bool HasInteractable;

    // Certain abilities, whilst being executed, prevent concealment from breaking.
    SourceAbilityContext = XComGameStateContext_Ability(GameState.GetContext());
    if (SourceAbilityContext != none)
    {
        if (UNITS_NOT_REVEALED_ABILITIES.Find(SourceAbilityContext.InputContext.AbilityTemplateName) >= 0)
        {
            return true;
        }
    }

    if (SeenUnit == none)
    {
        return false;
    }

    // Certain effects on the "seen" unit prevent concealment from breaking.
    foreach UNITS_NOT_REVEALED_EFFECTS(EffectName)
    {
        if (UnitHasEffect(SeenUnit, EffectName) != none)
        {
            return true;
        }
    }

    WatcherUnit = XComGameState_Unit(Watcher);
    WatcherDetector = XComGameState_InteractiveObject(Watcher);

    SeenUnit.GetKeystoneVisibilityLocation(SeenUnitTileLocation);
    SeenUnitPosition = `XWORLD.GetPositionFromTileCoordinates(SeenUnitTileLocation);
    `XWORLD.GetCoverPointAtFloor(SeenUnitPosition, SeenUnitCover);
    HasHighCover = `HAS_HIGH_COVER(SeenUnitCover);

    HasInteractable = class'X2Condition_UnitInteractions'.static.GetUnitInteractionPoints(SeenUnit, eInteractionType_Normal).Length > 0 ||
                      class'X2Condition_UnitInteractions'.static.GetUnitInteractionPoints(SeenUnit, eInteractionType_Hack).Length > 0;

    foreach SHADOW_EFFECTS(EffectName)
    {
        if (UnitHasEffect(SeenUnit, EffectName) != none)
        {
            if (WatcherUnit != none && SHADOW_NOT_REVEALED_BY_CLASSES.Find(WatcherUnit.GetMyTemplateName()) >= 0)
            {
                return true;
            }
            if (WatcherDetector != none && SHADOW_NOT_REVEALED_BY_DETECTOR)
            {
                return true;
            }
            if (HasHighCover || HasInteractable)
            {
                return true;
            }
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
        if (StayConcealed(GameState, Damager, Damagee))
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
    if (UnitB.IsDead() && !UnitA.HasSeenCorpse(UnitB.ObjectID) && IsCorpseStealthKill(UnitB))
    {
        `SPOOKLOG("UnitASeesUnitB filter marking stealth killed corpse " @ UnitB.ObjectID @ " seen by " @ UnitA.ObjectID);
        UnitA.MarkCorpseSeen(UnitB.ObjectID);
    }
    class'XComGameState_Unit'.static.UnitASeesUnitB(UnitA, UnitB, GameState);
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
