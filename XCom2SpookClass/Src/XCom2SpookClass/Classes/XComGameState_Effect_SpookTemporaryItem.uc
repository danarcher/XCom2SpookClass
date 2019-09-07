// Adapted from code by Amineri (Pavonis Interactive)
class XComGameState_Effect_SpookTemporaryItem extends XComGameState_BaseObject dependson(X2Effect_SpookTemporaryItem);

`include(XCom2SpookClass\Src\Spook.uci)

var array<StateObjectReference> TemporaryItems; // temporary items granted only for the duration of the tactical mission

function EventListenerReturn OnTacticalGameEnd(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    CleanUpTemporaryItems(none);
    return ELR_NoInterrupt;
}

function CleanUpTemporaryItems(XComGameState NewGameState)
{
    local XComGameStateHistory      History;
    local StateObjectReference      ItemRef;
    local XComGameState_Item        ItemState;
    local XComGameState_Unit        UnitState;
    local Object                    ThisObj;
    local bool                      bSubmit;

    History = `XCOMHISTORY;

    if (NewGameState == none)
    {
        NewGameState = `CreateChangeState("Spook Temporary Item Cleanup");
        bSubmit = true;
    }

    foreach TemporaryItems(ItemRef)
    {
        if (ItemRef.ObjectID > 0)
        {
            ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
            if (ItemState != none)
            {
                UnitState = `FindOrAddUnitState(ItemState.OwnerStateObject.ObjectID, NewGameState);
                if (UnitState != none)
                {
                    // Technically this tramples ItemState, but it may be a read-only copy.
                    UnitState.RemoveItemFromInventory(ItemState); // Remove the item from the unit's inventory
                }

                // Remove the temporary item's gamestate object from history
                NewGameState.RemoveStateObject(ItemRef.ObjectID);
            }
        }
    }

    // Remove ourselves from history
    NewGameState.RemoveStateObject(ObjectID);

    // We don't need to receive further events
    ThisObj = self;
    `XEVENTMGR.UnRegisterFromAllEvents(ThisObj);

    if (bSubmit)
    {
        `TACTICALRULES.SubmitGameState(NewGameState);
    }
}
