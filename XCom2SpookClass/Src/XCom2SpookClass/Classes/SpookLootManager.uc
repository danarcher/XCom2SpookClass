class SpookLootManager
    extends Object
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var SpookEventListener EvacActivatingListener;
var SpookEventListener EvacActivatedListener;

var int BonusLoot;

function OnInit()
{
    `SPOOKLOG("OnInit");
    EvacActivatingListener = new class'SpookEventListener';
    EvacActivatingListener.RegisterForEvent('EvacActivated', OnEvacActivating, ELD_Immediate);

    EvacActivatedListener = new class'SpookEventListener';
    EvacActivatedListener.RegisterForEvent('EvacActivated', OnEvacActivated, ELD_OnStateSubmitted);
}

function OnEvacActivating(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState_Unit Unit;
    local XComGameState_BattleData BattleData;
    local array<XComGameState_Item> Items;

    `SPOOKLOG("OnEvacActivating");
    Unit = XComGameState_Unit(EventSource);
    BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

    `SPOOKLOG("Mission is " $ BattleData.MapData.ActiveMission.MissionName);

    BonusLoot = 0;

    if (BattleData.MapData.ActiveMission.MissionName == 'SmashNGrab_LW')
    {
        `SPOOKLOG("SmashNGrab_LW evac detected, checking inventory");

        Items = GetInventoryItems(Unit, 'SmashNGrabQuestItem');
        if (Items.Length > 1)
        {
            BonusLoot = Items.Length - 1;
            `SPOOKLOG(BonusLoot $ " excess quest items found, preparing to award loot for those");
        }
    }
}

function OnEvacActivated(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState_Unit Unit;
    local XComGameState NewGameState;
    local array<XComGameState_Item> Items;
    local int Index;

    `SPOOKLOG("OnEvacActivated");
    Unit = XComGameState_Unit(EventSource);

    `SPOOKLOG("Found bonus loot count " $ BonusLoot);

    for (Index = 0; Index < BonusLoot; ++Index)
    {
        AwardLoot('SmashNGrab_LW');
    }

    Items = GetInventoryItems(Unit, 'SmashNGrabQuestItem');
    if (Items.Length > 1)
    {
        Items.Remove(0, 1);
        NewGameState = `CreateChangeState("Spook SmashNGrab Loot Manager Quest Item Removal");
        Unit = `FindOrAddUnitState(Unit.ObjectID, NewGameState);
        for (Index = 0; Index < Items.Length; ++Index)
        {
            Unit.RemoveItemFromInventory(Items[Index], NewGameState);
        }
        `TACTICALRULES.SubmitGameState(NewGameState);
    }

    BonusLoot = 0;
}

function array<XComGameState_Item> GetInventoryItems(XComGameState_Unit Unit, name ItemName)
{
    local array<XComGameState_Item> AllItems, Items;
    local XComGameState_Item Item;

    AllItems = Unit.GetAllInventoryItems(Unit.GetParentGameState());
    foreach AllItems(Item)
    {
        if (Item.GetMyTemplateName() == ItemName)
        {
            Items.AddItem(Item);
        }
    }

    return Items;
}

// A la LW SeqAct_AwardLoot.
function AwardLoot(name LootCarrierName)
{
    local X2LootTableManager LootManager;
    local int LootIndex;
    local LootResults Loot;
    local Name LootName;
    local int Idx;
    local XComGameState_Item Item;
    local X2ItemTemplate ItemTemplate;
    local XComGameState NewGameState;
    local XComGameState_BattleData BattleData;
    local XComGameState_HeadquartersXCom XComHQ;
    local XComGameStateHistory History;
    local X2ItemTemplateManager ItemTemplateManager;

    `SPOOKLOG("Awarding bonus loot from " $ LootCarrierName);

    History = `XCOMHISTORY;
    LootManager = class'X2LootTableManager'.static.GetLootTableManager();
    LootIndex = LootManager.FindGlobalLootCarrier(LootCarrierName);
    if (LootIndex >= 0)
    {
        NewGameState = `CreateChangeState("Spook SmashNGrab Loot Manager Bonus Loot");

        BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
        BattleData = XComGameState_BattleData(NewGameState.CreateStateObject(class'XComGameState_BattleData', BattleData.ObjectID));
        NewGameState.AddStateObject(BattleData);
        XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
        XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
        NewGameState.AddStateObject(XComHQ);

        LootManager.RollForGlobalLootCarrier(LootIndex, Loot);
        ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
        foreach Loot.LootToBeCreated(LootName, Idx)
        {
            ItemTemplate = ItemTemplateManager.FindItemTemplate(LootName);
            Item = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
            NewGameState.AddStateObject(Item);
            XComHQ.PutItemInInventory(NewGameState, Item, true);
            BattleData.CarriedOutLootBucket.AddItem(LootName);
        }

        `TACTICALRULES.SubmitGameState(NewGameState);
    }
}
