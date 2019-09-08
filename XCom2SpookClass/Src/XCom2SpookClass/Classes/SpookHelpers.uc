class SpookHelpers
    extends Object;

`include(XCom2SpookClass\Src\Spook.uci)

static function XComGameState_Unit FindUnitState(int ObjectID, optional XComGameState NewGameState, optional XComGameStateHistory History)
{
    local XComGameState_Unit Unit;
    if (ObjectID == 0)
    {
        return none;
    }
    if (NewGameState != none)
    {
        Unit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ObjectID));
    }
    if (Unit == none)
    {
        if (History == none)
        {
            History = `XCOMHISTORY;
        }
        Unit = XComGameState_Unit(History.GetGameStateForObjectID(ObjectID));
    }
    return Unit;
}

static function XComGameState_Unit FindOrAddUnitState(int ObjectID, XComGameState NewGameState)
{
    local XComGameState_Unit Unit;
    if (ObjectID == 0)
    {
        return none;
    }
    if (NewGameState != none)
    {
        Unit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ObjectID));
    }
    if (Unit == none)
    {
        Unit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ObjectID));
        NewGameState.AddStateObject(Unit);
    }
    return Unit;
}

static function XComGameState_Ability FindAbilityState(int ObjectID, optional XComGameState NewGameState, optional XComGameStateHistory History)
{
    local XComGameState_Ability Ability;
    if (ObjectID == 0)
    {
        return none;
    }
    if (NewGameState != none)
    {
        Ability = XComGameState_Ability(NewGameState.GetGameStateForObjectID(ObjectID));
    }
    if (Ability == none)
    {
        if (History == none)
        {
            History = `XCOMHISTORY;
        }
        Ability = XComGameState_Ability(History.GetGameStateForObjectID(ObjectID));
    }
    return Ability;
}

static function XComGameState_Item FindItemState(int ObjectID, optional XComGameState NewGameState, optional XComGameStateHistory History)
{
    local XComGameState_Item Item;
    if (ObjectID == 0)
    {
        return none;
    }
    if (NewGameState != none)
    {
        Item = XComGameState_Item(NewGameState.GetGameStateForObjectID(ObjectID));
    }
    if (Item == none)
    {
        if (History == none)
        {
            History = `XCOMHISTORY;
        }
        Item = XComGameState_Item(History.GetGameStateForObjectID(ObjectID));
    }
    return Item;
}
