class X2DownloadableContentInfo_Spook
    extends X2DownloadableContentInfo
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var X2Ability_SpookOperatorAbilitySet OperatorAbilitySet;

static function X2DownloadableContentInfo_Spook GetDLC()
{
    local array<X2DownloadableContentInfo> DLCInfos;
    local X2DownloadableContentInfo DLCInfo;
    local X2DownloadableContentInfo_Spook This;

    DLCInfos = `ONLINEEVENTMGR.GetDLCInfos(false);
    foreach DLCInfos(DLCInfo)
    {
        This = X2DownloadableContentInfo_Spook(DLCInfo);
        if (This != none)
        {
            return This;
        }
    }
    return none;
}

static event OnPostTemplatesCreated()
{
    local X2DownloadableContentInfo_Spook DLC;
    class'SpookTacticalDetectionManager'.static.OnPostTemplatesCreated();
    class'X2StrategyElement_SpookAcademyUnlocks'.static.OnPostTemplatesCreated();
    DLC = GetDLC();
    DLC.OperatorAbilitySet = new class'X2Ability_SpookOperatorAbilitySet';
    DLC.OperatorAbilitySet.OnPostTemplatesCreated();
}

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit Unit, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
    GetDLC().OperatorAbilitySet.FinalizeUnitAbilitiesForInit(Unit, SetupData, StartState, PlayerState, bMultiplayerDisplay);
}

// This function is only called by LW.
static function bool CanAddItemToInventory(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit Unit, XComGameState CheckGameState)
{
    return GetDLC().OperatorAbilitySet.CanAddItemToInventory(bCanAddItem, Slot, ItemTemplate, Quantity, Unit, CheckGameState);
}

static function OnPostMission()
{
    class'SpookPostMissionTraining'.static.OnPostMission();
}

exec function SpookLevelUpSoldier(string UnitName, optional int Ranks = 1)
{
    class'SpookDebug'.static.LevelUpSoldier(UnitName, Ranks);
}

exec function SpookLogMission()
{
    class'SpookDebug'.static.DumpMission();
}

exec function SpookLogUnits()
{
    class'SpookDebug'.static.DumpUnits();
}

exec function SpookLogInventory()
{
    class'SpookDebug'.static.DumpInventories();
}
