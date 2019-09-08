class X2DownloadableContentInfo_Spook
    extends X2DownloadableContentInfo
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var array<X2AbilityTemplate> OperatorTemplates;

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
    `SPOOKSLOG("OnPostTemplatesCreated");
    UpdateAbilityTemplates();
    //UpdateItemTemplates();

    class'X2Ability_SpookOperatorAbilitySet'.static.CreateOperatorTemplates(GetDLC().OperatorTemplates);
}

//static function UpdateItemTemplates()
//{
//    local X2ItemTemplateManager ItemManager;
//    local X2EquipmentTemplate Equipment;
//
//    ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
//    Equipment = X2EquipmentTemplate(ItemManager.FindItemTemplate('SmashNGrabQuestItem'));
//    if (Equipment != none)
//    {
//        Equipment.InventorySlot = eInvSlot_Backpack;
//        `SPOOKSLOG("Updated " $ Equipment.DataName);
//    }
//}

static function UpdateAbilityTemplates()
{
    local X2AbilityTemplateManager AbilityManager;

    `SPOOKSLOG("Updating ability templates");
    AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

    // ChangeForm, BurrowedAttack, UnburrowSawEnemy, ChangeFormSawEnemy
    FindAndUpdateRevealAbilityTemplate(AbilityManager, 'ChangeForm');
    FindAndUpdateRevealAbilityTemplate(AbilityManager, 'ChangeFormSawEnemy');
    FindAndUpdateRevealAbilityTemplate(AbilityManager, 'BurrowedAttack');
    FindAndUpdateRevealAbilityTemplate(AbilityManager, 'UnburrowSawEnemy');

    if (class'X2Ability_SpookAbilitySet'.default.DISTRACT_EXCLUDE_RED_ALERT)
    {
        `SPOOKSLOG("Distract excludes red alert and hence is cancelled by it");
        RedAlertCancelsDistract(AbilityManager);
    }
    else
    {
        `SPOOKSLOG("Distract does NOT exclude red alert");
    }

    `SPOOKSLOG("Ability template updates completed");
}

static function FindAndUpdateRevealAbilityTemplate(X2AbilityTemplateManager AbilityManager, name AbilityName)
{
    local X2AbilityTemplate Template;
    Template = AbilityManager.FindAbilityTemplate(AbilityName);
    if (Template != none)
    {
        UpdateRevealAbilityTemplate(Template);
    }
}

static function UpdateRevealAbilityTemplate(X2AbilityTemplate Template)
{
    local X2Condition_UnitProperty UnitPropertyCondition;

    // Concealed units cannot be targeted for e.g. concealment removal,
    // nor can concealed movement set of alarms.
    //
    // This change affects two things:
    //
    // i) It prevents X2Effect_BreakUnitConcealment from being applied as a multi-target effect via this template.
    //
    // ii) It prevents CheckForVisibleMovementIn[..]Radius_Self from counting concealed units, since that
    //     function delegates back to the ability's multi-target conditions to check target suitability.
    //
    UnitPropertyCondition = new class'X2Condition_UnitProperty';
    UnitPropertyCondition.ExcludeConcealed = true;
    Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);
    `SPOOKSLOG("Updated " @ Template.DataName @ " to exclude concealed units");
}

static function RedAlertCancelsDistract(X2AbilityTemplateManager AbilityManager)
{
    local X2DataTemplate DataTemplate;
    local X2AbilityTemplate Template;
    local SpookRedAlertVisualizer Visualizer;
    local bool bModified;
    foreach AbilityManager.IterateTemplates(DataTemplate, none)
    {
        Template = X2AbilityTemplate(DataTemplate);
        if (Template == none)
        {
            continue;
        }

        bModified = false;
        if (RedAlertCancelsDistractHere(Template, Template.AbilityShooterEffects))
        {
            Template.AddShooterEffect(CreateDistractRemover(Template, "AbilityShooterEffects"));
            bModified = true;
        }
        if (RedAlertCancelsDistractHere(Template, Template.AbilityTargetEffects))
        {
            Template.AddTargetEffect(CreateDistractRemover(Template, "AbilityTargetEffects"));
            bModified = true;
        }
        if (RedAlertCancelsDistractHere(Template, Template.AbilityMultiTargetEffects))
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

static function bool RedAlertCancelsDistractHere(X2AbilityTemplate Template, out const array<X2Effect> Effects)
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

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
    GetDLC().FinalizeOperatorAbilitiesForInit(UnitState, SetupData, StartState, PlayerState, bMultiplayerDisplay);
}

function FinalizeOperatorAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
    local int SetupIndex, OperatorIndex;
    local AbilitySetupData Entry;
    local X2AbilityTemplate OperatorTemplate;
    local bool bReplaced;

    if (UnitState.GetSoldierClassTemplateName() == 'Spook')
    {
        // name TemplateName, X2AbilityTemplate Template, StateObjectReference SourceWeaponRef, StateObjectReference SourceAmmoRef
        for (SetupIndex = 0; SetupIndex < SetupData.Length; ++SetupIndex)
        {
            Entry = SetupData[SetupIndex];
            bReplaced = false;

            for (OperatorIndex = 0; OperatorIndex < OperatorTemplates.Length; ++OperatorIndex)
            {
                OperatorTemplate = OperatorTemplates[OperatorIndex];
                if (OperatorTemplate.DataName == Entry.TemplateName)
                {
                    `SPOOKLOG("Replacing " $ Entry.TemplateName $ "with Operator equivalent for " $ UnitState.GetFullName());
                    Entry.Template = OperatorTemplate;
                    bReplaced = true;
                }
            }

            if (bReplaced)
            {
                SetupData[SetupIndex] = Entry;
            }
        }

    }
}

// This function is only called by LW, but in this case that's fine.
static function bool CanAddItemToInventory(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, XComGameState CheckGameState)
{
    if (ItemTemplate.DataName == 'SmashNGrabQuestItem' && UnitState.GetSoldierClassTemplateName() == 'Spook')
    {
        `SPOOKSLOG(UnitState.GetSoldierClassTemplateName() $ " can always carry " $ ItemTemplate.DataName);
        bCanAddItem = 1;
        return true;
    }
    return false;
}

exec function SpookLevelUpSoldier(string UnitName, optional int Ranks = 1)
{
    local XComGameState NewGameState;
    local XComGameState_HeadquartersXCom XComHQ;
    local XComGameStateHistory History;
    local XComGameState_Unit UnitState;
    local int idx, i, RankUps, NewRank;
    local name SoldierClassName;

    History = `XCOMHISTORY;
    XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
    NewGameState = `CreateChangeState("Spook Rankup Soldier Cheat");
    XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
    NewGameState.AddStateObject(XComHQ);

    for(idx = 0; idx < XComHQ.Crew.Length; idx++)
    {
        UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Crew[idx].ObjectID));

        if(UnitState != none && UnitState.IsSoldier() && UnitState.GetFullName() == UnitName && UnitState.GetRank() < (class'X2ExperienceConfig'.static.GetMaxRank() - 1))
        {
            UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
            NewGameState.AddStateObject(UnitState);
            NewRank = UnitState.GetRank() + Ranks;

            if(NewRank >= class'X2ExperienceConfig'.static.GetMaxRank())
            {
                NewRank = (class'X2ExperienceConfig'.static.GetMaxRank());
            }

            RankUps = NewRank - UnitState.GetRank();

            for (i = 0; i < RankUps; i++)
            {
                SoldierClassName = '';
                if(UnitState.GetRank() == 0)
                {
                    SoldierClassName = XComHQ.SelectNextSoldierClass();
                }

                UnitState.RankUpSoldier(NewGameState, SoldierClassName);

                if(UnitState.GetRank() == 1)
                {
                    UnitState.ApplySquaddieLoadout(NewGameState, XComHQ);
                    UnitState.ApplyBestGearLoadout(NewGameState); // Make sure the squaddie has the best gear available
                }
            }

            UnitState.StartingRank = NewRank;
            UnitState.SetXPForRank(NewRank);
        }
    }

    if( NewGameState.GetNumGameStateObjects() > 0 )
    {
        `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
    }
    else
    {
        History.CleanupPendingGameState(NewGameState);
    }
}

exec function SpookDebugMe()
{
    local XComGameState_BattleData BattleData;
    local StoredMapData MapData;
    local MissionDefinition MissionDef;
    local MissionObjectiveDefinition ObjDef;
    local ObjectiveLootTable OLT;

    BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
    MapData = BattleData.MapData;
    MissionDef = MapData.ActiveMission;
    `SPOOKSLOG("ActiveMissionSchedule: " $ MapData.ActiveMissionSchedule);
    `SPOOKSLOG("ActiveQuestItemTemplate: " $ MapData.ActiveQuestItemTemplate);
    `SPOOKSLOG("MissionName: " $ MissionDef.MissionName);
    `SPOOKSLOG("sType: " $ MissionDef.sType);
    `SPOOKSLOG("MissionFamily: " $ MissionDef.MissionFamily);
    foreach MissionDef.MissionObjectives(ObjDef)
    {
        `SPOOKSLOG("  Objective ObjectiveName: " $ ObjDef.ObjectiveName);
        foreach ObjDef.SuccessLootTables(OLT)
        {
            `SPOOKSLOG("    SuccessLootTable LootTableName:" $ OLT.LootTableName);
            `SPOOKSLOG("    SuccessLootTable ForceLevel:" $ OLT.ForceLevel);
            `SPOOKSLOG("    ---");
        }
        `SPOOKSLOG("  Objective bIsTacticalObjective: " $ ObjDef.bIsTacticalObjective);
        `SPOOKSLOG("  Objective bIsStrategyObjective: " $ ObjDef.bIsStrategyObjective);
        `SPOOKSLOG("  Objective bIsTriadObjective: " $ ObjDef.bIsTriadObjective);
        `SPOOKSLOG("  Objective bCompleted: " $ ObjDef.bCompleted);
        `SPOOKSLOG("  ---");
    }
    `SPOOKSLOG("---");
}

exec function SpookInventory()
{
    local XComGameState_Unit Unit;
    local StateObjectReference ItemRef;

    `SPOOKSLOG("SpookInventory");
    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', Unit)
    {
        if (Unit.IsSoldier())
        {
            `SPOOKSLOG(Unit.GetMyTemplateName() $ " " $ Unit.GetSoldierClassTemplateName() $ " " $ Unit.GetFullName());
            foreach Unit.InventoryItems(ItemRef)
            {
                DumpItem(ItemRef, , 1);
            }
        }
    }
}

static function DumpItem(StateObjectReference ItemRef, string Prefix = "", int Indent = 0)
{
    local XComGameState_Item Item;
    local StateObjectReference ChildItemRef;
    local string Text;
    local int Index;

    Text = "";
    for (Index = 0; Index < Indent; ++Index)
    {
        Text = Text $ "  ";
    }
    if (Prefix != "")
    {
        Text = Text $ Prefix $ " ";
    }

    Item = `FindItemState(ItemRef.ObjectID);
    if (Item != none)
    {
        Text = Text $ "Template=" $ Item.GetMyTemplateName() $ " Loc=" $ Item.ItemLocation $ " Slot=" $ Item.InventorySlot $ " Quantity=" $ Item.Quantity $ " MergedItemCount=" $ Item.MergedItemCount $ " MergedOut=" $ Item.bMergedOut;
        if (Item.Ammo != 0)
        {
            Text = Text $ " Ammo=" $ Item.Ammo;
        }
        `SPOOKSLOG(Text);
        if (Item.LoadedAmmo.ObjectID != 0)
        {
            DumpItem(Item.LoadedAmmo);
        }
        foreach Item.ContainedItems(ChildItemRef)
        {
            DumpItem(ChildItemRef, "Child", Indent + 1);
        }
    }
    else if (ItemRef.ObjectID == 0)
    {
        Text = Text $ "(none)";
        `SPOOKSLOG(Text);
    }
    else
    {
        Text = Text $ "(missing!)";
        `SPOOKSLOG(Text);
    }
}
