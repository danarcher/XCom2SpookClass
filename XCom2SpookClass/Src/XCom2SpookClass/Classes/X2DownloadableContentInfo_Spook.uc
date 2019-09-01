class X2DownloadableContentInfo_Spook
    extends X2DownloadableContentInfo
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

static function X2DownloadableContentInfo_Spook GetSpookDLC()
{
    local array<X2DownloadableContentInfo> DLCInfos;
    local X2DownloadableContentInfo DLCInfo;
    local X2DownloadableContentInfo_Spook SpookDLCInfo;

    DLCInfos = `ONLINEEVENTMGR.GetDLCInfos(false);
    foreach DLCInfos(DLCInfo)
    {
        SpookDLCInfo = X2DownloadableContentInfo_Spook(DLCInfo);
        if (SpookDLCInfo != none)
        {
            return SpookDLCInfo;
        }
    }
    return none;
}

static event OnLoadedSavedGame()
{
}

static event InstallNewCampaign(XComGameState StartState)
{
}

static event OnPostTemplatesCreated()
{
    `SPOOKSLOG("OnPostTemplatesCreated");
    UpdateWeaponTemplates();
    UpdateAbilityTemplates();
    UpdateCharacterTemplates();
}

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit Unit, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player Player, optional bool bMultiplayerDisplay)
{
    local AbilitySetupData Item;
    local bool bFound;
    local X2AbilityTemplateManager AbilityManager;
    local X2AbilityTemplate Template;
    `SPOOKSLOG("FinalizeUnitAbilitiesForInit with " $ Unit.GetMyTemplateName());
    foreach SetupData(Item)
    {
        //`SPOOKSLOG("TemplateName=" $ Item.TemplateName $ " Template.DataName=" $ Item.Template.DataName);
        if (Item.TemplateName == 'Spook_Distract_AISetDestination')
        {
            bFound = true;
            //break;
        }
    }
    if (!bFound)
    {
        AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
        Template = AbilityManager.FindAbilityTemplate('Spook_Distract_AISetDestination');
        if (Template != none)
        {
            // Set TemplateName, Template, SourceWeaponRef, SourceAmmoRef.
            Item.TemplateName = Template.DataName;
            Item.Template = Template;
            Item.SourceWeaponRef.ObjectID = 0;
            Item.SourceAmmoRef.ObjectID = 0;
            SetupData.AddItem(Item);
            `SPOOKSLOG("Spook_Distract_AISetDestination added as not found");
        }
        else
        {
            `SPOOKSLOG("Spook_Distract_AISetDestination not found and could not be added!");
        }
    }
    else
    {
        `SPOOKSLOG("Spook_Distract_AISetDestination found");
    }
}

static function UpdateWeaponTemplates()
{
    local X2ItemTemplateManager ItemManager;

    `SPOOKSLOG("Updating weapon templates");
    ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

    FindAndUpdateWeaponTemplate(ItemManager, 'CombatKnife_CV', true);
    FindAndUpdateWeaponTemplate(ItemManager, 'CombatKnife_MG', true);
    // There are no other combat knife variants in use.
}

static function FindAndUpdateWeaponTemplate(X2ItemTemplateManager ItemManager, name ItemName, bool bMelee, optional WeaponDamageValue ExtraDamage)
{
    local X2WeaponTemplate Template;

    Template = X2WeaponTemplate(ItemManager.FindItemTemplate(ItemName));
    if (Template != none)
    {
        if (bMelee)
        {
            `SPOOKSLOG("Adding melee abilities to " $ ItemName);
            Template.Abilities.AddItem('Spook_Cosh');
            Template.Abilities.AddItem('Spook_Sap');
        }
    }
    else
    {
        `SPOOKSLOG(ItemName $ " not found, can't add update it");
    }
}

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

    `SPOOKSLOG("Ability template updates completed");
}

static function DenySpooksAbility(X2AbilityTemplateManager AbilityManager, name AbilityName)
{
    local X2AbilityTemplate Template;
    local X2Condition_UnitProperty NonSpookShooter;
    Template = AbilityManager.FindAbilityTemplate(AbilityName);
    if (Template != none)
    {
        NonSpookShooter = new class'X2Condition_UnitProperty';
        NonSpookShooter.ExcludeSoldierClasses.AddItem('Spook');
        Template.AbilityShooterConditions.AddItem(NonSpookShooter);
        `SPOOKSLOG("Denied spooks " $ AbilityName);
    }
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

static function UpdateCharacterTemplates()
{
    local X2CharacterTemplateManager CharManager;
    local X2DataTemplate Template;
    local X2CharacterTemplate CharTemplate;

    `SPOOKSLOG("Updating character templates");
    CharManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
    foreach CharManager.IterateTemplates(Template, None)
    {
        CharTemplate = X2CharacterTemplate(Template);
        if (CharTemplate == none)
        {
            continue;
        }
        CharTemplate.Abilities.AddItem('Spook_Distract_AISetDestination');
        `SPOOKSLOG("Added Spook_Distract_AISetDestination to " $ CharTemplate.DataName);
    }
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
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Spook Rankup Soldier Cheat");
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

            for(i = 0; i < RankUps; i++)
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

exec function SpookUpdateTiles()
{
    `SPOOKSLOG("SpookUpdateTiles console command");
    `XEVENTMGR.TriggerEvent('SpookUpdateTiles');
}
