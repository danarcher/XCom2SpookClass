class SpookHelpers
    extends Object;

`include(XCom2SpookClass\Src\Spook.uci)

static function XComGameState_BaseObject FindObjectState(int ObjectID, optional XComGameState NewGameState, optional XComGameStateHistory History)
{
    local XComGameState_BaseObject Obj;
    if (ObjectID == 0)
    {
        return none;
    }
    if (NewGameState != none)
    {
        Obj = NewGameState.GetGameStateForObjectID(ObjectID);
    }
    if (Obj == none)
    {
        if (History == none)
        {
            History = `XCOMHISTORY;
        }
        Obj = History.GetGameStateForObjectID(ObjectID);
    }
    return Obj;
}

// This is FindOrAdd, not FindOrCreate, since it also adds the object to the game state.
static function XComGameState_BaseObject FindOrAddObjectState(class<XComGameState_BaseObject> StateClass, int ObjectID, XComGameState NewGameState)
{
    local XComGameState_BaseObject Obj;
    if (ObjectID == 0)
    {
        return none;
    }
    if (NewGameState != none)
    {
        Obj = NewGameState.GetGameStateForObjectID(ObjectID);
    }
    if (Obj == none)
    {
        Obj = NewGameState.CreateStateObject(StateClass, ObjectID);
        NewGameState.AddStateObject(Obj);
    }
    return Obj;
}

static function XComGameState_BaseObject FindHistoricObjectState(int ObjectID, optional XComGameState NewGameState, optional XComGameStateHistory History)
{
    local XComGameState_BaseObject Obj;
    local int HistoryIndex;
    if (ObjectID == 0)
    {
        return none;
    }
    if (NewGameState != none)
    {
        Obj = NewGameState.GetGameStateForObjectID(ObjectID);
    }
    if (Obj == none)
    {
        if (History == none)
        {
            History = `XCOMHISTORY;
        }
        Obj = History.GetGameStateForObjectID(ObjectID);
        if (Obj == none)
        {
            for (HistoryIndex = History.GetCurrentHistoryIndex(); HistoryIndex >= 0; --HistoryIndex)
            {
                Obj = History.GetGameStateForObjectID(ObjectID,, HistoryIndex);
                if (Obj != none)
                {
                    break;
                }
            }
        }
    }
    return Obj;
}

static function bool GetOwnTile(XComGameState_BaseObject Obj, out TTile Tile)
{
    local XComGameState_Unit Unit;
    local XComGameState_InteractiveObject InteractiveObject;

    Unit = XComGameState_Unit(Obj);
    if (Unit != none)
    {
        Unit.GetKeystoneVisibilityLocation(Tile);
        return true;
    }

    InteractiveObject = XComGameState_InteractiveObject(Obj);
    if (InteractiveObject != none)
    {
        Tile = InteractiveObject.TileLocation;
        return true;
    }

    return false;
}

static function X2Action InsertTrackAction(out VisualizationTrack Track, int Index, class<X2Action> SpawnClass, XComGameStateContext Context)
{
    local X2Action Action;
    Action = SpawnClass.static.AddToVisualizationTrack(Track, Context);
    Track.TrackActions.RemoveItem(Action);
    Track.TrackActions.InsertItem(Index, Action);
    return Action;
}
