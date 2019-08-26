class SpookTileManager
    extends Object
    implements(X2VisualizationMgrObserverInterface)
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var config bool RENDER_TILE_OVERLAYS;
var config bool RENDER_REQUIRES_SHADOW_EFFECT;

var array<X2Actor_SpookTile> AllTiles;
var array<X2Actor_SpookTile> UnusedTiles;
var SpookDetectionManager DetectionManager;

function OnInit(SpookDetectionManager DetectionManagerInstance)
{
    local Object This;
    local X2EventManager EventMgr;

    DetectionManager = DetectionManagerInstance;

    `SPOOKLOG("OnInit");
    This = self;
    EventMgr = `XEVENTMGR;
    EventMgr.RegisterForEvent(This, 'PlayerTurnBegun', OnPlayerTurnBegun, ELD_OnStateSubmitted);
    EventMgr.RegisterForEvent(This, 'PlayerTurnEnded', OnPlayerTurnEnded, ELD_OnStateSubmitted);
    EventMgr.RegisterForEvent(This, 'ObjectVisibilityChanged', OnObjectVisibilityChanged, ELD_OnStateSubmitted);
    EventMgr.RegisterForEvent(This, 'UnitMoveFinished', OnUnitMoveFinished, ELD_OnStateSubmitted);
    EventMgr.RegisterForEvent(This, 'AbilityActivated', OnAbilityActivated, ELD_OnStateSubmitted);
    `XEVENTMGR.RegisterForEvent(This, 'SpookUpdateTiles', OnSpookUpdateTiles, ELD_Immediate);
    `XCOMVISUALIZATIONMGR.RegisterObserver(self);
}

function EventListenerReturn OnPlayerTurnBegun(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    //UpdateTiles();
    return ELR_NoInterrupt;
}

function EventListenerReturn OnPlayerTurnEnded(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    `SPOOKLOG("OnPlayerTurnEnded");
    FreeAllTiles();
    return ELR_NoInterrupt;
}

function EventListenerReturn OnObjectVisibilityChanged(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    `SPOOKLOG("OnObjectVisibilityChanged");
    //UpdateTiles();
    return ELR_NoInterrupt;
}

function EventListenerReturn OnUnitMoveFinished(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    `SPOOKLOG("OnUnitMoveFinished");
    `BATTLE.SetTimer(1.0f, false, nameof(UpdateTiles), self);
    return ELR_NoInterrupt;
}

function EventListenerReturn OnAbilityActivated(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameStateContext_Ability AbilityContext;
    local AbilityInputContext InputContext;
    local XComGameState_Unit Unit;

    `SPOOKLOG("OnAbilityActivated");
    AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
    if (AbilityContext == none)
    {
        `SPOOKLOG("No ability context, stopping");
        return ELR_NoInterrupt;
    }

    if(AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt)
    {
        // Something complicated is still happening.
        `SPOOKLOG("Still interrupting, stopping");
        return ELR_NoInterrupt;
    }

    InputContext = AbilityContext.InputContext;
    Unit = XComGameState_Unit(GameState.GetGameStateForObjectID(InputContext.SourceObject.ObjectID));
    if (Unit == none)
    {
        Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(InputContext.SourceObject.ObjectID));
    }
    if (Unit == none)
    {
        `SPOOKLOG("No unit, stopping");
        return ELR_NoInterrupt;
    }
    if (!Unit.IsConcealed() || !DetectionManager.UnitHasShadowEffect(Unit))
    {
        `SPOOKLOG("Not concealed or no shadow effect, stopping");
        return ELR_NoInterrupt;
    }

    UpdateTiles();
    return ELR_NoInterrupt;
}

function EventListenerReturn OnSpookUpdateTiles(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    `SPOOKLOG("OnSpookUpdateTiles");
    UpdateTiles();
    return ELR_NoInterrupt;
}

event OnVisualizationBlockComplete(XComGameState AssociatedGameState);
event OnVisualizationIdle();

event OnActiveUnitChanged(XComGameState_Unit NewActiveUnit)
{
    `SPOOKLOG("OnActiveUnitChanged");
    UpdateTiles();
}

function X2Actor_SpookTile AllocTile()
{
    local X2Actor_SpookTile Tile;
    if (UnusedTiles.Length > 0)
    {
        Tile = UnusedTiles[UnusedTiles.Length - 1];
        UnusedTiles.Remove(UnusedTiles.Length - 1, 1);
        return Tile;
    }
    else
    {
        Tile = `BATTLE.spawn(class'X2Actor_SpookTile');
        AllTiles.AddItem(Tile);
        return Tile;
    }
}

function FreeTile(X2Actor_SpookTile Tile)
{
    Tile.SetHidden(true);
    UnusedTiles.AddItem(Tile);
}

function FreeAllTiles()
{
    local int i;
    UnusedTiles.Remove(0, UnusedTiles.Length);
    for (i = 0; i < AllTiles.Length; ++i)
    {
        FreeTile(AllTiles[i]);
    }
}

function UpdateTiles()
{
    local XComGameState_Unit Unit;
    local XComTacticalController TacticalController;
    local StateObjectReference ActiveUnitRef;

    if (!default.RENDER_TILE_OVERLAYS)
    {
        return;
    }

    TacticalController = XComTacticalController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());
    ActiveUnitRef = TacticalController.GetActiveUnitStateRef();
    Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ActiveUnitRef.ObjectID));
    if (Unit != none && Unit.GetTeam() == eTeam_XCom)
    {
        FreeAllTiles();
        UpdateTilesForUnit(Unit);
    }
}

function UpdateTilesForUnit(XComGameState_Unit Unit)
{
    local XComWorldData World;
    local bool UnitHasShadowEffect;
    local float UnitDetectionModifier;
    local array<XComGameState_BaseObject> ConcealmentBreakers;
    local XComGameState_BaseObject Breaker;
    local TTile BreakerTile;
    local float BreakerDetectionRadius, SearchRadius;
    local vector SearchTilePosition;
    local array<vector> CandidateTilePositions;
    local vector CandidateTilePosition;
    local TTile CandidateTile;
    local X2Actor_SpookTile Tile;
    local array<XComGameState_Effect> Mods;
    local array<float> ModValues;
    local int iMod;

    if (Unit == none || !Unit.IsConcealed())
    {
        return;
    }

    `SPOOKLOG("Updating tiles for unit " $ Unit.GetFullName());
    UnitHasShadowEffect = DetectionManager.UnitHasShadowEffect(Unit);
    if (default.RENDER_REQUIRES_SHADOW_EFFECT && !UnitHasShadowEffect)
    {
        `SPOOKLOG("Unit does not have required shadow effect");
        return;
    }

    if (DetectionManager.IsUnitConcealmentUnbreakableIgnoringTile(`XCOMHistory.GetGameStateFromHistory(-1), Unit))
    {
        `SPOOKLOG("Unit concalment is unbreakable");
        return;
    }

    `SPOOKLOG("Unit " $ Unit.GetFullName() $ " detection modifier:" $
        " cur=" $ Unit.GetCurrentStat(eStat_DetectionModifier) $
        " base=" $ Unit.GetBaseStat(eStat_DetectionModifier) $
        " max=" $ Unit.GetMaxStat(eStat_DetectionModifier));
    Unit.GetStatModifiers(eStat_DetectionModifier, Mods, ModValues);
    `SPOOKLOG(Mods.Length $ " mods");
    for (iMod = 0; iMod < Mods.Length; ++iMod)
    {
        `SPOOKLOG("  Detection mod #" $ iMod $ "=" $ ModValues[iMod]);
    }

    UnitDetectionModifier = DetectionManager.GetUnitDetectionModifier(Unit);
    `SPOOKLOG("Using detection modifier " $ UnitDetectionModifier);

    World = `XWORLD;

    GetVisibleConcealmentBreakers(Unit, ConcealmentBreakers);
    `SPOOKLOG("Team can see " $ ConcealmentBreakers.Length $ " concealment breakers");

    foreach ConcealmentBreakers(Breaker)
    {
        BreakerDetectionRadius = DetectionManager.GetConcealmentDetectionDistanceMeters(Breaker, Unit);
        `SPOOKLOG("Breaker " $ GetLogName(Breaker) $ " detects within " $ BreakerDetectionRadius);

        DetectionManager.GetOwnTile(Breaker, BreakerTile);
        SearchTilePosition = World.GetPositionFromTileCoordinates(BreakerTile);
        SearchTilePosition.Z -= 1000;

        CandidateTilePositions.Remove(0, CandidateTilePositions.Length);
        SearchRadius = BreakerDetectionRadius + 1.5; // plus one tile
        World.GetFloorTilePositions(SearchTilePosition, `METERSTOUNITS(SearchRadius), 2000, CandidateTilePositions, true);
        `SPOOKLOG("Breaker " $ GetLogName(Breaker) $ " yielded " $ CandidateTilePositions.Length $ " tile positions");

        foreach CandidateTilePositions(CandidateTilePosition)
        {
            CandidateTile = World.GetTileCoordinatesFromPosition(CandidateTilePosition);
            if (BreakerTile == CandidateTile || CanObjectSeeTile(Breaker, CandidateTile, BreakerDetectionRadius, World))
            {
                if (!DetectionManager.IsTileUnbreakablyConcealingForUnit(Unit, CandidateTile))
                {
                    Tile = AllocTile();
                    CandidateTilePosition.Z = World.GetFloorZForPosition(CandidateTilePosition) + 4;
                    Tile.SetLocation(CandidateTilePosition);
                    Tile.SetHidden(false);
                }
            }
        }
    }
}

static function name GetLogName(XComGameState_BaseObject Obj)
{
   local XComGameState_Unit Unit;
   Unit = XComGameState_Unit(Obj);
   if (Unit != none)
   {
        return Unit.GetMyTemplateName();
   }
   return 'Tower';
}

function GetVisibleConcealmentBreakers(XComGameState_Unit Unit, out array<XComGameState_BaseObject> ConcealmentBreakers)
{
    local XComGameStateHistory History;
    local ETeam UnitTeam;
    local XComGameState_Unit Candidate;
    local XGUnit CandidateVisualizer;
    local XComUnitPawn CandidatePawn;
    local XComGameState_InteractiveObject Tower;
    local XComInteractiveLevelActor TowerVisualizer;

    History = `XCOMHISTORY;
    UnitTeam = Unit.GetTeam();
    foreach History.IterateByClassType(class'XComGameState_Unit', Candidate)
    {
        if (Candidate.ObjectID == Unit.ObjectID)
        {
            continue;
        }

        if (DetectionManager.BreaksConcealment(Candidate, Unit))
        {
            // Test pawn visibility to sync with debug commands such as X2DebugVisualizers.
            // Otherwise we could rely on visibility helpers.
            CandidateVisualizer = XGUnit(Candidate.GetVisualizer());
            if (CandidateVisualizer != none)
            {
                CandidatePawn = CandidateVisualizer.GetPawn();
                if (CandidatePawn != none && CandidatePawn.IsVisibleToTeam(UnitTeam))
                {
                    ConcealmentBreakers.AddItem(Candidate);
                }
            }
        }
    }
    foreach History.IterateByClassType(class'XComGameState_InteractiveObject', Tower)
    {
        if (DetectionManager.BreaksConcealment(Tower, Unit))
        {
            TowerVisualizer = XComInteractiveLevelActor(Tower.GetVisualizer()); // or FindOrCreateVis
            if (TowerVisualizer != none && !(TowerVisualizer.bHidden))
            {
                ConcealmentBreakers.AddItem(Tower);
            }
        }
    }
}

// Adapted from X2TacticalVisibilityHelpers.CanUnitSeeLocation().
function bool CanObjectSeeTile(XComGameState_BaseObject Obj, const out TTile TestTile, float DetectionRadius, XComWorldData World)
{
    local TTile ObjTile;
    local GameRulesCache_VisibilityInfo Visibility;
    local float Detect;

    if (!DetectionManager.GetOwnTile(Obj, ObjTile))
    {
        return false;
    }
    if (!World.CanSeeTileToTile(ObjTile, TestTile, Visibility))
    {
        return false;
    }
    Detect = `METERSTOUNITS(DetectionRadius);
    Detect = Detect * Detect;
    if (Detect >= Visibility.DefaultTargetDist)
    {
        return true;
    }
    return false;
}
