class X2DownloadableContentInfo_Spook
    extends X2DownloadableContentInfo
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

// We'd like to replace the game's default tile overlays for "stepping
// on this tile breaks concealment". The game doesn't allow us to do
// this, since it's handled in native code.
//
// So we have a different approach:
//
// We're replacing all gameplay code to do with concealment breaking
// (at least all the code we can, that isn't hidden in per-map designer
// Kismet scripts) in SpookDetectionManager.
//
// That code already has the logic to do with our special reasons to
// not detect soldiers in concealment who might otherwise be detected.
//
// If "stat override" is configured, we additionally:
// - Add a special detection modifier to every soldier, with a large
//   magic number. That number is large enough to reduce enemies'
//   detection radii to zero, which disables the default concealment
//   breaking til overlays.
// - Look for that special stat override in our detection logic, and
//   if it's there, pretend it isn't, and hence detection ranges are
//   based on all other modifiers than this one.
// - SpookTileManager then renders custom tile overlays instead. It's
//   also possible to persuade SpookTileManager to render its tiles
//   even if stat override is off, to check the accuracy of our
//   overlay placement versus the game's defaults: both the standard
//   concealment breaking tile overlays, and ours, then will appear on
//   the same tiles.
//
// Applying this requires some unpleasant legwork, especially since
// we'd like to be able to toggle this on and off for diagnostic
// purposes.
//
// Spooks have two abilities (never seen or used by the player) called
// Spook_StatOverride and Spook_StatOverrideCancel. The former will
// apply the special modifier to spooks detection radii *if* stat
// override is configured. The latter will remove any special modifier
// from spooks' detection radii *if* stat override is not configured.
//
// These abilities activate once at the start of tactical play, and also
// activate via custom console command, SpookCycleStatOverrideMode.
// (More specifically they react to an event triggered by that console
// command, once the console command has also committed a blank state
// change to history, which is needed to flush the game's per-unit
// ability cache, which otherwise prevents the abilities from
// activiting properly, because the result of the special X2Condition
// we use to check "stat override" is cached by the game, but we just
// changed it, so we need to flush the cache.)
var config bool STAT_OVERRIDE_BY_DEFAULT;
var name StatOverrideMode;

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

static function bool IsStatOverrideEnabled()
{
    local X2DownloadableContentInfo_Spook SpookDLC;
    SpookDLC = GetSpookDLC();

    if (SpookDLC.StatOverrideMode == 'AA_Default')
    {
        return default.STAT_OVERRIDE_BY_DEFAULT;
    }
    if (SpookDLC.StatOverrideMode == 'AA_Off')
    {
        return false;
    }
    return true;
}

static function CycleStatOverrideMode()
{
    local X2DownloadableContentInfo_Spook SpookDLC;
    SpookDLC = GetSpookDLC();

    if (SpookDLC.StatOverrideMode == 'AA_Default')
    {
        SpookDLC.StatOverrideMode = 'AA_Off';
    }
    else if (SpookDLC.StatOverrideMode == 'AA_Off')
    {
        SpookDLC.StatOverrideMode = 'AA_On';
    }
    else if (SpookDLC.StatOverrideMode == 'AA_On')
    {
        SpookDLC.StatOverrideMode = 'AA_Default';
    }
    `SPOOKSLOG("StatOverrideMode is now '" $ SpookDLC.StatOverrideMode $ "'");
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
    `SPOOKSLOG("StatOverrideMode is '" $ GetSpookDLC().StatOverrideMode $ "'");
    UpdateWeaponTemplates();
    UpdateAbilityTemplates();
}

static function UpdateWeaponTemplates()
{
    local X2ItemTemplateManager ItemManager;

    `SPOOKSLOG("Updating weapon templates");
    ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

    FindAndUpdateWeaponTemplate(ItemManager, 'AssaultRifle_CV', false, class'X2Ability_SpookAbilitySet'.default.DART_CONVENTIONAL_DAMAGE);
    FindAndUpdateWeaponTemplate(ItemManager, 'AssaultRifle_LS', false, class'X2Ability_SpookAbilitySet'.default.DART_LASER_DAMAGE);
    FindAndUpdateWeaponTemplate(ItemManager, 'AssaultRifle_MG', false, class'X2Ability_SpookAbilitySet'.default.DART_MAGNETIC_DAMAGE);
    FindAndUpdateWeaponTemplate(ItemManager, 'AssaultRifle_BM', false, class'X2Ability_SpookAbilitySet'.default.DART_BEAM_DAMAGE);

    FindAndUpdateWeaponTemplate(ItemManager, 'SMG_CV', false, class'X2Ability_SpookAbilitySet'.default.DART_CONVENTIONAL_DAMAGE);
    FindAndUpdateWeaponTemplate(ItemManager, 'SMG_LS', false, class'X2Ability_SpookAbilitySet'.default.DART_LASER_DAMAGE);
    FindAndUpdateWeaponTemplate(ItemManager, 'SMG_MG', false, class'X2Ability_SpookAbilitySet'.default.DART_MAGNETIC_DAMAGE);
    FindAndUpdateWeaponTemplate(ItemManager, 'SMG_BM', false, class'X2Ability_SpookAbilitySet'.default.DART_BEAM_DAMAGE);

    FindAndUpdateWeaponTemplate(ItemManager, 'Shotgun_CV', false, class'X2Ability_SpookAbilitySet'.default.DART_CONVENTIONAL_DAMAGE);
    FindAndUpdateWeaponTemplate(ItemManager, 'Shotgun_LS', false, class'X2Ability_SpookAbilitySet'.default.DART_LASER_DAMAGE);
    FindAndUpdateWeaponTemplate(ItemManager, 'Shotgun_MG', false, class'X2Ability_SpookAbilitySet'.default.DART_MAGNETIC_DAMAGE);
    FindAndUpdateWeaponTemplate(ItemManager, 'Shotgun_BM', false, class'X2Ability_SpookAbilitySet'.default.DART_BEAM_DAMAGE);

    FindAndUpdateWeaponTemplate(ItemManager, 'Sword_CV', true);
    FindAndUpdateWeaponTemplate(ItemManager, 'Sword_LS', true);
    FindAndUpdateWeaponTemplate(ItemManager, 'Sword_MG', true);
    FindAndUpdateWeaponTemplate(ItemManager, 'Sword_BM', true);
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
        else
        {
            `SPOOKSLOG("Adding ranged abilities to " $ ItemName);
            Template.Abilities.AddItem('Spook_Dart');
            Template.Abilities.AddItem('Spook_CarryUnit');
            Template.Abilities.AddItem('Spook_PutDownUnit');
            Template.Abilities.AddItem('Spook_StatOverride');
            Template.Abilities.AddItem('Spook_StatOverrideCancel');
            Template.Abilities.AddItem(class'X2Ability_SpookAbilitySet'.const.ShadowNotRevealedByClassesName);
            Template.Abilities.AddItem(class'X2Ability_SpookAbilitySet'.const.ShadowNotRevealedByClassesCancelName);
        }
        if (ExtraDamage.Tag != '')
        {
            `SPOOKSLOG("Adding extra damage to " $ ItemName $ ", (" $ ExtraDamage.Damage $ " +/- " $ ExtraDamage.Spread $ " (+" $ ExtraDamage.PlusOne $ ") C" $ ExtraDamage.Crit $ " P" $ ExtraDamage.Pierce $ " S" $ ExtraDamage.Shred $ " Tag=" $ ExtraDamage.Tag $ " Type=" $ ExtraDamage.DamageType);
            Template.ExtraDamage.AddItem(ExtraDamage);
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

    DenySpooksAbility(AbilityManager, 'CarryUnit');
    DenySpooksAbility(AbilityManager, 'PutDownUnit');

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

exec function SpookCycleStatOverrideMode()
{
    local XComGameState_Unit Unit;
    local XComGameState NewGameState;

    `SPOOKSLOG("SpookCycleStatOverrideMode console command");
    CycleStatOverrideMode();

    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Flushing unity ability cache");
    `TACTICALRULES.SubmitGameState(NewGameState);

    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', Unit)
    {
        `SPOOKSLOG("Triggering event on " $ Unit.GetMyTemplateName() $ " " $ Unit.GetFullName());
        `XEVENTMGR.TriggerEvent('SpookApplyStatOverride', Unit, Unit);
    }
    `SPOOKSLOG("Triggering tile update");
    `XEVENTMGR.TriggerEvent('SpookUpdateTiles');
}

exec function SpookUpdateTiles()
{
    `SPOOKSLOG("SpookUpdateTiles console command");
    `XEVENTMGR.TriggerEvent('SpookUpdateTiles');
}

defaultproperties
{
    StatOverrideMode="AA_Default"
}
