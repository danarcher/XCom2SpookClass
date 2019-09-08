class SpookDebug
    extends Object
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

static function LevelUpSoldier(string UnitName, optional int Ranks = 1)
{
    local XComGameState NewGameState;
    local XComGameState_HeadquartersXCom XComHQ;
    local XComGameStateHistory History;
    local XComGameState_Unit Unit;
    local int idx, i, RankUps, NewRank;
    local name SoldierClassName;

    History = `XCOMHISTORY;
    XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
    NewGameState = `CreateChangeState("Spook Rankup Soldier Cheat");
    XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
    NewGameState.AddStateObject(XComHQ);

    for(idx = 0; idx < XComHQ.Crew.Length; idx++)
    {
        Unit = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Crew[idx].ObjectID));

        if(Unit != none && Unit.IsSoldier() && Unit.GetFullName() == UnitName && Unit.GetRank() < (class'X2ExperienceConfig'.static.GetMaxRank() - 1))
        {
            Unit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));
            NewGameState.AddStateObject(Unit);
            NewRank = Unit.GetRank() + Ranks;

            if(NewRank >= class'X2ExperienceConfig'.static.GetMaxRank())
            {
                NewRank = (class'X2ExperienceConfig'.static.GetMaxRank());
            }

            RankUps = NewRank - Unit.GetRank();

            for (i = 0; i < RankUps; i++)
            {
                SoldierClassName = '';
                if(Unit.GetRank() == 0)
                {
                    SoldierClassName = XComHQ.SelectNextSoldierClass();
                }

                Unit.RankUpSoldier(NewGameState, SoldierClassName);

                if(Unit.GetRank() == 1)
                {
                    Unit.ApplySquaddieLoadout(NewGameState, XComHQ);
                    Unit.ApplyBestGearLoadout(NewGameState); // Make sure the squaddie has the best gear available
                }
            }

            Unit.StartingRank = NewRank;
            Unit.SetXPForRank(NewRank);
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

static function DumpMission()
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

`define DumpUnitBool(nom, x) if (`x) { Text = Text $ " " $ `nom; }
`define DumpUnitValue(nom, x) `SPOOKSLOG("  " $ `nom $ ": '" $ `x $ "'")
`define DumpUnitStringIfNotEmpty(nom, x) if (`x != "") `DumpUnitValue(`nom, `x)
`define DumpUnitNameIfNotNone(nom, x) if (`x != '') `DumpUnitValue(`nom, `x)

static function DumpUnits()
{
    local XComGameState_Unit Unit;
    local X2CharacterTemplate Template;
    local string Text;
    `SPOOKSLOG("All units");
    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', Unit)
    {
        Template = Unit.GetMyTemplate();
        `SPOOKSLOG(Unit.GetMyTemplateName() $ " " $ Unit.GetSoldierClassTemplateName() $ " " $ Unit.GetFullName());
        `DumpUnitNameIfNotNone("CharacterGroupName", Template.CharacterGroupName);
        Text = "  Flags: ";
        // `DumpUnitBool("bCanUse_eTraversal_Normal", Template.bCanUse_eTraversal_Normal);
        // `DumpUnitBool("bCanUse_eTraversal_ClimbOver", Template.bCanUse_eTraversal_ClimbOver);
        // `DumpUnitBool("bCanUse_eTraversal_ClimbOnto", Template.bCanUse_eTraversal_ClimbOnto);
        // `DumpUnitBool("bCanUse_eTraversal_ClimbLadder", Template.bCanUse_eTraversal_ClimbLadder);
        // `DumpUnitBool("bCanUse_eTraversal_DropDown", Template.bCanUse_eTraversal_DropDown);
        // `DumpUnitBool("bCanUse_eTraversal_Grapple", Template.bCanUse_eTraversal_Grapple);
        // `DumpUnitBool("bCanUse_eTraversal_Landing", Template.bCanUse_eTraversal_Landing);
        // `DumpUnitBool("bCanUse_eTraversal_BreakWindow", Template.bCanUse_eTraversal_BreakWindow);
        // `DumpUnitBool("bCanUse_eTraversal_KickDoor", Template.bCanUse_eTraversal_KickDoor);
        // `DumpUnitBool("bCanUse_eTraversal_JumpUp", Template.bCanUse_eTraversal_JumpUp);
        // `DumpUnitBool("bCanUse_eTraversal_WallClimb", Template.bCanUse_eTraversal_WallClimb);
        // `DumpUnitBool("bCanUse_eTraversal_Phasing", Template.bCanUse_eTraversal_Phasing);
        // `DumpUnitBool("bCanUse_eTraversal_BreakWall", Template.bCanUse_eTraversal_BreakWall);
        // `DumpUnitBool("bCanUse_eTraversal_Launch", Template.bCanUse_eTraversal_Launch);
        // `DumpUnitBool("bCanUse_eTraversal_Flying", Template.bCanUse_eTraversal_Flying);
        // `DumpUnitBool("bCanUse_eTraversal_Land", Template.bCanUse_eTraversal_Land);
        // `DumpUnitBool("bIsTooBigForArmory", Template.bIsTooBigForArmory);
        `DumpUnitBool("bCanBeCriticallyWounded", Template.bCanBeCriticallyWounded);
        `DumpUnitBool("bCanBeCarried", Template.bCanBeCarried);
        `DumpUnitBool("bCanBeRevived", Template.bCanBeRevived);
        `DumpUnitBool("bCanBeTerrorist", Template.bCanBeTerrorist);
        `DumpUnitBool("bDiesWhenCaptured", Template.bDiesWhenCaptured);
        `DumpUnitBool("bAppearanceDefinesPawn", Template.bAppearanceDefinesPawn);
        // `DumpUnitBool("bIsAfraidOfFire", Template.bIsAfraidOfFire);
        `DumpUnitBool("bIsAlien", Template.bIsAlien);
        `DumpUnitBool("bIsAdvent", Template.bIsAdvent);
        `DumpUnitBool("bIsCivilian", Template.bIsCivilian);
        // `DumpUnitBool("bDisplayUIUnitFlag", Template.bDisplayUIUnitFlag);
        // `DumpUnitBool("bNeverSelectable", Template.bNeverSelectable);
        `DumpUnitBool("bIsHostileCivilian", Template.bIsHostileCivilian);
        `DumpUnitBool("bIsPsionic", Template.bIsPsionic);
        `DumpUnitBool("bIsRobotic", Template.bIsRobotic);
        `DumpUnitBool("bIsSoldier", Template.bIsSoldier);
        `DumpUnitBool("bIsCosmetic", Template.bIsCosmetic);
        `DumpUnitBool("bIsTurret", Template.bIsTurret);
        `DumpUnitBool("bCanTakeCover", Template.bCanTakeCover);
        `DumpUnitBool("bIsExalt", Template.bIsExalt);
        `DumpUnitBool("bIsEliteExalt", Template.bIsEliteExalt);
        // `DumpUnitBool("bSkipDefaultAbilities", Template.bSkipDefaultAbilities);
        // `DumpUnitBool("bDoesNotScamper", Template.bDoesNotScamper);
        // `DumpUnitBool("bDoesAlwaysFly", Template.bDoesAlwaysFly);
        // `DumpUnitBool("bAllowSpawnInFire", Template.bAllowSpawnInFire);
        // `DumpUnitBool("bAllowSpawnInPoison", Template.bAllowSpawnInPoison);
        // `DumpUnitBool("bAllowSpawnFromATT", Template.bAllowSpawnFromATT);
        // `DumpUnitBool("bFacesAwayFromPod", Template.bFacesAwayFromPod);
        // `DumpUnitBool("bLockdownPodIdleUntilReveal", Template.bLockdownPodIdleUntilReveal);
        `DumpUnitBool("bWeakAgainstTechLikeRobot", Template.bWeakAgainstTechLikeRobot);
        `DumpUnitBool("bIsMeleeOnly", Template.bIsMeleeOnly);
        // `DumpUnitBool("bUsePoolSoldiers", Template.bUsePoolSoldiers);
        // `DumpUnitBool("bUsePoolVIPs", Template.bUsePoolVIPs);
        // `DumpUnitBool("bUsePoolDarkVIPs", Template.bUsePoolDarkVIPs);
        `DumpUnitBool("bIsScientist", Template.bIsScientist);
        `DumpUnitBool("bIsEngineer", Template.bIsEngineer);
        // `DumpUnitBool("bStaffingAllowed", Template.bStaffingAllowed);
        // `DumpUnitBool("bAppearInBase", Template.bAppearInBase);
        // `DumpUnitBool("bWearArmorInBase", Template.bWearArmorInBase);
        // `DumpUnitBool("bBlocksPathingWhenDead", Template.bBlocksPathingWhenDead);
        `DumpUnitBool("bCanTickEffectsEveryAction", Template.bCanTickEffectsEveryAction);
        // `DumpUnitBool("bManualCooldownTick", Template.bManualCooldownTick);
        // `DumpUnitBool("bHideInShadowChamber", Template.bHideInShadowChamber);
        `DumpUnitBool("bDontClearRemovedFromPlay", Template.bDontClearRemovedFromPlay);
        `DumpUnitBool("bSetGenderAlways", Template.bSetGenderAlways);
        `DumpUnitBool("bForceAppearance", Template.bForceAppearance);
        `DumpUnitBool("bHasFullDefaultAppearance", Template.bHasFullDefaultAppearance);
        `DumpUnitBool("bIgnoreEndTacticalHealthMod", Template.bIgnoreEndTacticalHealthMod);
        `DumpUnitBool("bIgnoreEndTacticalRestoreArmor", Template.bIgnoreEndTacticalRestoreArmor);
        // `DumpUnitBool("CanFlankUnits", Template.CanFlankUnits);
        // `DumpUnitBool("bAllowRushCam", Template.bAllowRushCam);
        `DumpUnitBool("bDisablePodRevealMovementChecks", Template.bDisablePodRevealMovementChecks);
        `SPOOKSLOG(Text);

        // `DumpUnitValue("MaxFlightPitchDegrees", Template.MaxFlightPitchDegrees);
        // `DumpUnitValue("SoloMoveSpeedModifier", Template.SoloMoveSpeedModifier);
        // `DumpUnitValue("AIMinSpreadDist", Template.AIMinSpreadDist);
        // `DumpUnitValue("AISpreadMultiplier", Template.AISpreadMultiplier);
        `DumpUnitStringIfNotEmpty("strCharacterName", Template.strCharacterName);
        // `DumpUnitValue("strCharacterHealingPaused", Template.strCharacterHealingPaused);
        `DumpUnitStringIfNotEmpty("strForcedFirstName", Template.strForcedFirstName);
        `DumpUnitStringIfNotEmpty("strForcedLastName", Template.strForcedLastName);
        `DumpUnitStringIfNotEmpty("strForcedNickName", Template.strForcedNickName);
        // `DumpUnitValue("strCustomizeDesc", Template.strCustomizeDesc);
        // `DumpUnitValue("strAcquiredText", Template.strAcquiredText);
        // `DumpUnitValue("strTargetingMatineePrefix", Template.strTargetingMatineePrefix);
        // `DumpUnitValue("strIntroMatineeSlotPrefix", Template.strIntroMatineeSlotPrefix);
        // `DumpUnitValue("strLoadingMatineeSlotPrefix", Template.strLoadingMatineeSlotPrefix);
        // `DumpUnitValue("strHackIconImage", Template.strHackIconImage);
        // `DumpUnitValue("strTargetIconImage", Template.strTargetIconImage);
        // `DumpUnitValue("RevealMatineePrefix", Template.RevealMatineePrefix);
        `DumpUnitValue("strBehaviorTree", Template.strBehaviorTree);
        `DumpUnitValue("strPanicBT", Template.strPanicBT);
        `DumpUnitValue("strScamperBT", Template.strScamperBT);
        // `DumpUnitValue("SpeakerPortrait", Template.SpeakerPortrait);
        // `DumpUnitValue("HQIdleAnim", Template.HQIdleAnim);
        // `DumpUnitValue("HQOffscreenAnim", Template.HQOffscreenAnim);
        // `DumpUnitValue("HQOnscreenAnimPrefix", Template.HQOnscreenAnimPrefix);
        // `DumpUnitValue("HQOnscreenOffset", Template.HQOnscreenOffset);
        // `DumpUnitValue("ForceAppearance", Template.ForceAppearance);
        // `DumpUnitValue("DefaultAppearance", Template.DefaultAppearance);
        `DumpUnitNameIfNotNone("DefaultSoldierClass", Template.DefaultSoldierClass);
        `DumpUnitNameIfNotNone("PhotoboothPersonality", Template.PhotoboothPersonality);
        // `DumpUnitValue("DeathEvent", Template.DeathEvent);
        // `DumpUnitValue("ReactionFireDeathAnim", Template.ReactionFireDeathAnim);

        // array<name> AppearInStaffSlots;
        // array<string> strPawnArchetypes;
        // array<string> strCharacterBackgroundMale;
        // array<string> strCharacterBackgroundFemale;
        // array<string> strMatineePackages;
        // array<int> SkillLevelThresholds;
        // array<XComNarrativeMoment> SightedNarrativeMoments;
        // array<name> SightedEvents;
        // array<name> ImmuneTypes;
    }
}

static function DumpInventories()
{
    local XComGameState_Unit Unit;
    local StateObjectReference ItemRef;

    `SPOOKSLOG("Inventory for all soldiers");
    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', Unit)
    {
        if (Unit.IsSoldier())
        {
            `SPOOKSLOG(Unit.GetMyTemplateName() $ " " $ Unit.GetSoldierClassTemplateName() $ " " $ Unit.GetFullName());
            foreach Unit.InventoryItems(ItemRef)
            {
                DumpItem(ItemRef,, 1);
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

    if (ItemRef.ObjectID == 0)
    {
        Text = Text $ "(none)";
        `SPOOKSLOG(Text);
    }
    else
    {
        Item = `FindItemState(ItemRef.ObjectID);
        if (Item == none)
        {
            Item = `FindHistoricItemState(ItemRef.ObjectID);
            if (Item == none)
            {
                Text = Text $ "(missing item " $ ItemRef.ObjectID $ " not found in history!)";
            }
            else
            {
                Text = Text $ "(missing item " $ ItemRef.ObjectID $ " from history frame " $ Item.GetParentGameState().HistoryIndex $ " vs current frame " $ `XCOMHISTORY.GetCurrentHistoryIndex() $ ") ";
            }
        }
        if (Item != none)
        {
            Text = Text $ Item.GetMyTemplateName();
            if (Item.ItemLocation != eSlot_None)
            {
                Text = Text $ " (" $ Item.ItemLocation $ ")";
            }
            Text = Text $ " " $ Item.InventorySlot;
            if (Item.Quantity != 1)
            {
                Text = Text $ " x" $ Item.Quantity;
            }
            if (Item.Ammo != 0)
            {
                Text = Text $ " " $ Item.Ammo $ " ammo";
            }
            if (Item.MergedItemCount != 0)
            {
                Text = Text $ " (merged " $ Item.MergedItemCount $ ")";
            }
            if (Item.bMergedOut)
            {
                Text = Text $ " (merged out)";
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
    }
}
