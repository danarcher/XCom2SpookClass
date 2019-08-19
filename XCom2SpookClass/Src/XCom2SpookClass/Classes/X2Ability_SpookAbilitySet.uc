class X2Ability_SpookAbilitySet
    extends X2Ability
    dependson (XComGameStateContext_Ability)
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var config float SPOOK_VEIL_RK_DETECTION_RANGE_REDUCTION;
var config float SPOOK_VEIL_SQ_DETECTION_RANGE_REDUCTION;
var config float SPOOK_VEIL_LCPL_DETECTION_RANGE_REDUCTION;
var config float SPOOK_VEIL_CPL_DETECTION_RANGE_REDUCTION;
var config float SPOOK_VEIL_SGT_DETECTION_RANGE_REDUCTION;
var config float SPOOK_VEIL_SSGT_DETECTION_RANGE_REDUCTION;
var config float SPOOK_VEIL_TSGT_DETECTION_RANGE_REDUCTION;
var config float SPOOK_VEIL_GSGT_DETECTION_RANGE_REDUCTION;
var config float SPOOK_VEIL_MSGT_DETECTION_RANGE_REDUCTION;

var config int SPOOK_WIRED_SIGHT_RANGE_INCREASE;

var config int SPOOK_VANISH_CHARGES;
var config float SPOOK_VANISH_RADIUS;

var localized string ShadowFriendlyName;
var localized string ShadowHelpText;

var config int SPOOK_OPPORTUNIST_BLEED_TURNS;
var config int SPOOK_OPPORTUNIST_BLEED_DAMAGE_PER_TICK;
var config int SPOOK_OPPORTUNIST_BLEED_DAMAGE_SPREAD_PER_TICK;

var config WeaponDamageValue SPOOK_DART_CONVENTIONAL_DAMAGE;
var config WeaponDamageValue SPOOK_DART_LASER_DAMAGE;
var config WeaponDamageValue SPOOK_DART_MAGNETIC_DAMAGE;
var config WeaponDamageValue SPOOK_DART_BEAM_DAMAGE;

var config int SPOOK_DART_BLEED_TURNS;
var config int SPOOK_DART_BLEED_DAMAGE_PER_TICK;
var config int SPOOK_DART_BLEED_DAMAGE_SPREAD_PER_TICK;

var localized string OpportunistFriendlyName;

const ShadowEffectName = 'SpookShadowEffect';
const ExeuntAbilityName = 'Spook_Exeunt';

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;


    Templates.AddItem(AddCoshAbility());
    Templates.AddItem(AddSapAbility());
    Templates.AddItem(AddDartAbility());

    Templates.AddItem(AddEclipseAbility());
    Templates.AddItem(AddWiredAbility());

    Templates.AddItem(AddVeilAbility());
    // This is a PurePassive since the work is done in UIScreenListener_TacticalHUD_Spook.OnGetEvacPlacementDelay().
    Templates.AddItem(PurePassive(ExeuntAbilityName, "img:///UILibrary_PerkIcons.UIPerk_height", true));
    Templates.AddItem(/*TODO:*/PurePassive('Spook_Operator', "img:///UILibrary_PerkIcons.UIPerk_psychosis", true));
    Templates.AddItem(AddVanishAbility());
    Templates.AddItem(/*TODO:*/PurePassive('Spook_Exfil', "img:///UILibrary_PerkIcons.UIPerk_launch", true));
    Templates.AddItem(/*TODO:*/PurePassive('Spook_Exodus', "img:///UILibrary_PerkIcons.UIPerk_flight", true));

//  Templates.AddItem(PurePassive('Spook_BatonRound', "img:///UILibrary_PerkIcons.UIPerk_ambush", true));
//  Templates.AddItem(PurePassive('Spook_Blackjack', "img:///UILibrary_PerkIcons.UIPerk_adventstunlancer_stunlance", true));
//  Templates.AddItem(PurePassive('Spook_Operator', "img:///UILibrary_PerkIcons.UIPerk_psychosis", true));
//  Templates.AddItem(PurePassive('Spook_Shroud', "img:///UILibrary_LW_PerkPack.LW_AbilityCovert", true));
//  Templates.AddItem(PurePassive('Spook_Eidolon', "img:///UILibrary_PerkIcons.UIPerk_stealth", true));
//  Templates.AddItem(PurePassive('Spook_Puncture', "img:///UILibrary_PerkIcons.UIPerk_hunter", true));
//  Templates.AddItem(PurePassive('Spook_Takedown', "img:///UILibrary_PerkIcons.UIPerk_inthezone", true));
//  Templates.AddItem(PurePassive('Spook_Cocoon', "img:///UILibrary_PerkIcons.UIPerk_stasisshield", true));
//  Templates.AddItem(PurePassive('Spook_Pinpoint', "img:///UILibrary_PerkIcons.UIPerk_snapshot", true));
//  Templates.AddItem(PurePassive('Spook_Exfil', "img:///UILibrary_PerkIcons.UIPerk_flight", true));
//  Templates.AddItem(PurePassive('Spook_Thunderflash', "img:///UILibrary_PerkIcons.UIPerk_flashbang", true));
//  Templates.AddItem(PurePassive('Spook_SatchelCharge', "img:///UILibrary_PerkIcons.UIPerk_item_x4", true));
//  Templates.AddItem(PurePassive('Spook_Mini4', "img:///UILibrary_PerkIcons.UIPerk_bombard", true));
//  Templates.AddItem(PurePassive('Spook_Shrapnel', "img:///UILibrary_PerkIcons.UIPerk_bigbooms", true));
//  Templates.AddItem(PurePassive('Spook_Pyrotechnics', "img:///UILibrary_PerkIcons.UIPerk_flamethrower", true));
//  Templates.AddItem(PurePassive('Spook_MadBomber', "img:///UILibrary_PerkIcons.UIPerk_quickthrow", true));

    Templates.AddItem(PurePassive('Spook_Dummy0', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy1', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy2', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy3', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy4', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy5', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy6', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy7', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy8', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy9', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy10', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy11', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy12', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy13', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy14', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy15', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy16', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy17', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy18', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy19', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Dummy20', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));

    // To be removed!
    Templates.AddItem(PurePassive('Spook_BattleHardened', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(PurePassive('Spook_Farsight', "img:///UILibrary_PerkIcons.UIPerk_unknown", true));
    Templates.AddItem(AddOpportunistAbility());
    Templates.AddItem(AddOpportunistAttackAbility());

    return Templates;
}

// Modify an ability so the shooter must be a Spook
// Used for abilities gained from common weapons.
static function AbilityRequiresSpookShooter(X2AbilityTemplate Template)
{
    local X2Condition_UnitProperty SpookShooter;
    SpookShooter = new class'X2Condition_UnitProperty';
    SpookShooter.RequireSoldierClasses.AddItem('Spook');
    Template.AbilityShooterConditions.AddItem(SpookShooter);
}

static function X2AbilityTemplate AddCoshAbility()
{
    local X2AbilityTemplate                 Template;
    local X2AbilityCost_ActionPoints        ActionPointCost;
    local X2AbilityToHitCalc_StandardMelee  StandardMelee;
    local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
    local X2Effect_PersistentStatChange     DisorientedEffect;
    local X2Effect_SpookBonusMove           BonusMoveEffect;
    local array<name>                       SkipExclusions;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Cosh');

    Template.AbilitySourceName = 'eAbilitySource_Standard';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
    Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
    Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;
    Template.CinescriptCameraType = "Ranger_Reaper";
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";
    Template.bHideOnClassUnlock = false;
    Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
    Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";

    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 1;
    ActionPointCost.bConsumeAllPoints = true;
    Template.AbilityCosts.AddItem(ActionPointCost);

    StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
    Template.AbilityToHitCalc = StandardMelee;

    Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
    Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
    Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

    // Target Conditions
    //
    Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
    Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

    // Shooter Conditions
    //
    AbilityRequiresSpookShooter(Template);
    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
    SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
    Template.AddShooterEffectExclusions(SkipExclusions);

    // Damage Effect
    //
    WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
    Template.AddTargetEffect(WeaponDamageEffect);

    // Disoriented Effect
    //
    DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect(,,false);
    DisorientedEffect.iNumTurns = 1;
    Template.AddTargetEffect(DisorientedEffect);

    // Bonus Move Effect
    BonusMoveEffect = new class'X2Effect_SpookBonusMove';
    BonusMoveEffect.EffectName = 'SpookBonusMove';
    BonusMoveEffect.bApplyOnMiss = true;
    BonusMoveEffect.bIsConcealedBonusMove = false;
    BonusMoveEffect.BuildPersistentEffect(`BPE_TickAtEndOfNUnitTurns(1));
    Template.AddShooterEffect(BonusMoveEffect);

    Template.bAllowBonusWeaponEffects = true;
    Template.bSkipMoveStop = true;

    // Voice events
    //
    Template.SourceMissSpeech = 'SwordMiss';

    return Template;
}

static function X2AbilityTemplate AddSapAbility()
{
    local X2AbilityTemplate                 Template;
    local X2AbilityCost_ActionPoints        ActionPointCost;
    local X2AbilityToHitCalc_StandardMelee  StandardMelee;
    local X2Condition_UnitProperty          TargetPropertyCondition;
    //local X2Effect_ApplyWeaponDamage      WeaponDamageEffect;
    local X2Effect_Persistent               UnconsciousEffect;
    local X2Effect_SpookBonusMove           BonusMoveEffect;
    local X2Effect_SpookUngroupAI           UngroupEffect;
    local array<name>                       SkipExclusions;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Sap');

    Template.AbilitySourceName = 'eAbilitySource_Standard';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
    Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
    Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;
    Template.CinescriptCameraType = "Ranger_Reaper";
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_charge";
    Template.bHideOnClassUnlock = false;
    Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
    Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";

    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 1;
    ActionPointCost.bConsumeAllPoints = true;
    Template.AbilityCosts.AddItem(ActionPointCost);

    StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
    Template.AbilityToHitCalc = StandardMelee;

    Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
    Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
    Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

    // Retain Concealment
    //
    Template.ConcealmentRule = eConceal_Always;

    // No Alert Through Sound
    Template.bSilentAbility = true;

    // Inoffensive
    Template.Hostility = eHostility_Neutral;

    // No Robots
    TargetPropertyCondition = new class'X2Condition_UnitProperty';
    TargetPropertyCondition.ExcludeRobotic = true;
    Template.AbilityTargetConditions.AddItem(TargetPropertyCondition);

    // Target Conditions
    //
    Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
    Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

    // Shooter Conditions
    //
    AbilityRequiresSpookShooter(Template);
    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
    SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
    Template.AddShooterEffectExclusions(SkipExclusions);

    // Damage Effect
    //
    //WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
    //Template.AddTargetEffect(WeaponDamageEffect);

    // Unconscious Effect
    //
    UnconsciousEffect = class'X2StatusEffects'.static.CreateUnconsciousStatusEffect();
    Template.AddTargetEffect(UnconsciousEffect);

    // Don't break your patrol by being unconscious, especially if you're in charge.
    UngroupEffect = new class'X2Effect_SpookUngroupAI';
    UngroupEffect.BuildPersistentEffect(`BPE_TickAtEndOfNAnyTurns(1));
    UngroupEffect.bRemoveWhenTargetDies = true;
    Template.AddTargetEffect(UngroupEffect);

    // Bonus Move Effect
    BonusMoveEffect = new class'X2Effect_SpookBonusMove';
    BonusMoveEffect.EffectName = 'SpookBonusMove';
    BonusMoveEffect.bApplyOnMiss = true;
    BonusMoveEffect.bIsConcealedBonusMove = true;
    BonusMoveEffect.BuildPersistentEffect(`BPE_TickAtEndOfNUnitTurns(1));
    Template.AddShooterEffect(BonusMoveEffect);

    // Misc
    //
    Template.bAllowBonusWeaponEffects = false;
    Template.bSkipMoveStop = true;

    // Voice events
    //
    Template.SourceMissSpeech = 'SwordMiss';

    return Template;
}

static function X2Effect_Persistent CreateEclipsedStatusEffect()
{
    local X2Effect_Persistent PersistentEffect;
    PersistentEffect = new class'X2Effect_Persistent';
    PersistentEffect.EffectName = class'X2StatusEffects'.default.UnconsciousName;
    PersistentEffect.DuplicateResponse = 2;
    PersistentEffect.BuildPersistentEffect(1, true, false);
    PersistentEffect.bRemoveWhenTargetDies = true;
    PersistentEffect.bIsImpairing = true;
    PersistentEffect.SetDisplayInfo(2, class'X2StatusEffects'.default.UnconsciousFriendlyName, class'X2StatusEffects'.default.UnconsciousFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_stun", true, "img:///UILibrary_Common.status_unconscious");
    PersistentEffect.EffectAddedFn = class'X2StatusEffects'.static.UnconsciousEffectAdded;
    PersistentEffect.EffectRemovedFn = class'X2StatusEffects'.static.UnconsciousEffectRemoved;
    PersistentEffect.VisualizationFn = EclipsedVisualization;
    PersistentEffect.EffectTickedVisualizationFn = class'X2StatusEffects'.static.UnconsciousVisualizationTicked;
    PersistentEffect.EffectRemovedVisualizationFn = class'X2StatusEffects'.static.UnconsciousVisualizationRemoved;
    PersistentEffect.CleansedVisualizationFn =class'X2StatusEffects'.static.UnconsciousCleansedVisualization;
    PersistentEffect.EffectHierarchyValue = class'X2StatusEffects'.default.UNCONCIOUS_HIERARCHY_VALUE;
    PersistentEffect.DamageTypes.AddItem('Unconscious');
    return PersistentEffect;
}

static function EclipsedVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    if(EffectApplyResult != 'AA_Success')
    {
        return;
    }

    if(XComGameState_Unit(BuildTrack.StateObject_NewState) == none)
    {
        return;
    }

    //AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), default.UnconsciousFriendlyName, 'None', 4, "img:///UILibrary_Common.status_unconscious");
    class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, class'X2StatusEffects'.default.UnconsciousEffectAcquiredString, VisualizeGameState.GetContext());
    class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

static function X2AbilityTemplate AddEclipseAbility()
{
    local X2AbilityTemplate                     Template;
    local X2AbilityCost_ActionPoints            ActionPointCost;
    local X2Condition_UnitProperty              UnitPropertyCondition;
    local X2Condition_SpookEclipse              EclipseCondition;
    local X2AbilityTarget_Single                SingleTarget;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Eclipse');

    Template.AbilitySourceName = 'eAbilitySource_Standard';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_coupdegrace";
    Template.Hostility = eHostility_Neutral;
    Template.bLimitTargetIcons = true;

    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

    Template.bShowActivation = true;
    Template.ShotHUDPriority = 1101;

    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
    Template.AddShooterEffectExclusions();

    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 1; // 1 = require an action point left, 0 = anytime, like Evac.
    ActionPointCost.bFreeCost = true;
    Template.AbilityCosts.AddItem(ActionPointCost);

    SingleTarget = new class'X2AbilityTarget_Single';
    Template.AbilityTargetStyle = SingleTarget;

    UnitPropertyCondition = new class'X2Condition_UnitProperty';
    UnitPropertyCondition.ExcludeFriendlyToSource = false;
    UnitPropertyCondition.FailOnNonUnits = true;
    UnitPropertyCondition.ExcludeDead = true;
    UnitPropertyCondition.ExcludeAlien = true;
    UnitPropertyCondition.ExcludeRobotic = true;
    UnitPropertyCondition.ExcludeHostileToSource = true;
    UnitPropertyCondition.RequireWithinRange = true;
    UnitPropertyCondition.WithinRange = 144; // 1 tile
    Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

    EclipseCondition = new class'X2Condition_SpookEclipse';
    Template.AbilityTargetConditions.AddItem(EclipseCondition);

    Template.AddTargetEffect(CreateEclipsedStatusEffect());

    Template.ActivationSpeech = 'StabilizingAlly';
    Template.bShowActivation = true;

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = class'X2Ability_DefaultAbilitySet'.static.Knockout_BuildVisualization;
    Template.BuildAffectedVisualizationSyncFn = class'X2Ability_DefaultAbilitySet'.static.Knockout_BuildAffectedVisualizationSync;

    return Template;
}

static function X2AbilityTemplate AddVeilAbility()
{
    local X2AbilityTemplate                         Template;
    local X2Effect_SpookPersistentRankedStatChange  VeilEffect;
    local X2Effect_Persistent                       ShadowEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Veil');
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AbilityCovert";
    Template.Hostility = eHostility_Neutral;
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bCrossClassEligible = false;
    Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;

    VeilEffect = new class'X2Effect_SpookPersistentRankedStatChange';
    VeilEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    VeilEffect.SetDisplayInfo(ePerkBuff_Passive,Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
    VeilEffect.AddPersistentStatChange(0, eStat_DetectionModifier, default.SPOOK_VEIL_RK_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(1, eStat_DetectionModifier, default.SPOOK_VEIL_SQ_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(2, eStat_DetectionModifier, default.SPOOK_VEIL_LCPL_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(3, eStat_DetectionModifier, default.SPOOK_VEIL_CPL_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(4, eStat_DetectionModifier, default.SPOOK_VEIL_SGT_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(5, eStat_DetectionModifier, default.SPOOK_VEIL_SSGT_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(6, eStat_DetectionModifier, default.SPOOK_VEIL_TSGT_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(7, eStat_DetectionModifier, default.SPOOK_VEIL_GSGT_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(8, eStat_DetectionModifier, default.SPOOK_VEIL_MSGT_DETECTION_RANGE_REDUCTION);
    Template.AddTargetEffect(VeilEffect);

    ShadowEffect = new class'X2Effect_Persistent';
    ShadowEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    ShadowEffect.SetDisplayInfo(ePerkBuff_Passive, default.ShadowFriendlyName, default.ShadowHelpText, "img:///UILibrary_PerkIcons.UIPerk_stealth",,, Template.AbilitySourceName);
    ShadowEffect.EffectName = ShadowEffectName;
    Template.AddTargetEffect(ShadowEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate AddVanishAbility()
{
    local X2AbilityTemplate                 Template;
    local X2AbilityCost_ActionPoints        ActionPointCost;
    local X2Condition_UnitProperty          ShooterProperty;
    local X2Effect_ApplySmokeGrenadeToWorld WeaponEffect;
    local X2Effect_RangerStealth            StealthEffect;
    local X2Effect_SpookBonusMove           BonusMoveEffect;
    local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
    local X2AbilityCharges                  Charges;
    local X2AbilityCost_Charges             ChargeCost;
    local array<name>                       SkipExclusions;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Vanish');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_wraith";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
    Template.Hostility = eHostility_Neutral;
    Template.bDisplayInUITacticalText = true;
    Template.bCrossClassEligible = false;

    // Cost
    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 0; // 1 = require an action point left, 0 = anytime, like Evac.
    ActionPointCost.bFreeCost = true;
    Template.AbilityCosts.AddItem(ActionPointCost);

    // Activation
    Template.bIsPassive = false;
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
    Template.bSkipFireAction = true;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;

    // Shooter conditions
    ShooterProperty = new class'X2Condition_UnitProperty';
    ShooterProperty.ExcludeConcealed = true;
    Template.AbilityShooterConditions.AddItem(ShooterProperty);                             // Must not be concealed
    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);               // Must be alive
    SkipExclusions.AddItem(class'X2Ability_CarryUnit'.default.CarryUnitEffectName);         // Can be carrying someone
    SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);           // Can be disoriented (by a sectoid)
    SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);        // Can be disoriented (by something else)
    SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);                     // Can be on fire
    Template.AddShooterEffectExclusions(SkipExclusions);

    Charges = new class'X2AbilityCharges';
    Charges.InitialCharges = default.SPOOK_VANISH_CHARGES;
    Template.AbilityCharges = Charges;
    ChargeCost = new class'X2AbilityCost_Charges';
    ChargeCost.NumCharges = 1;
    Template.AbilityCosts.AddItem(ChargeCost);

    RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
    RadiusMultiTarget.bUseWeaponRadius = false;
    RadiusMultiTarget.bUseSourceWeaponLocation = false;
    RadiusMultiTarget.fTargetRadius = default.SPOOK_VANISH_RADIUS * 1.5; // tiles to meters
    Template.AbilityMultiTargetStyle = RadiusMultiTarget;

    WeaponEffect = new class'X2Effect_ApplySmokeGrenadeToWorld';
    Template.AddTargetEffect(WeaponEffect);

    Template.AddMultiTargetEffect(class'X2Item_DefaultGrenades'.static.SmokeGrenadeEffect());

    StealthEffect = new class'X2Effect_RangerStealth';
    StealthEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true);
    StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
    Template.AddTargetEffect(StealthEffect);
    Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

    // Bonus Move Effect
    BonusMoveEffect = new class'X2Effect_SpookBonusMove';
    BonusMoveEffect.EffectName = 'SpookBonusMove';
    BonusMoveEffect.bApplyOnMiss = true;
    BonusMoveEffect.bIsConcealedBonusMove = true;
    BonusMoveEffect.bEvenIfFree = true;
    BonusMoveEffect.BuildPersistentEffect(`BPE_TickAtEndOfNUnitTurns(1));
    Template.AddShooterEffect(BonusMoveEffect);

    Template.ActivationSpeech = 'ActivateConcealment';
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    return Template;
}

static function X2AbilityTemplate AddOpportunistAbility()
{
    local X2AbilityTemplate                 Template;

    Template = PurePassive('Spook_Opportunist', "img:///UILibrary_PerkIcons.UIPerk_bladestorm", false, 'eAbilitySource_Perk');
    Template.AdditionalAbilities.AddItem('Spook_OpportunistAttack');

    return Template;
}

static function X2AbilityTemplate AddOpportunistAttackAbility()
{
    local X2AbilityTemplate                 Template;
    local X2AbilityTrigger_Event            Trigger;
    local X2Effect_Persistent               OpportunistTargetEffect;
    local X2Condition_UnitEffectsWithAbilitySource OpportunistTargetCondition;
    //local X2AbilityTrigger_EventListener    EventListener;
    local X2Condition_UnitProperty          SourceConcealedCondition;
    local X2Condition_UnitProperty          TargetPropertyCondition;
    local X2Condition_Visibility            TargetVisibilityCondition;
    //local array<name>                     SkipExclusions;
    //local X2Effect_Persistent             UnconsciousEffect;
    local X2Effect_SpookUngroupAI           UngroupEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_OpportunistAttack');

    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_bladestorm";
    Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;

    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SimpleSingleMeleeTarget;

    //  trigger on movement
    Trigger = new class'X2AbilityTrigger_Event';
    Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
    Trigger.MethodName = 'InterruptGameState';
    Template.AbilityTriggers.AddItem(Trigger);
    Trigger = new class'X2AbilityTrigger_Event';
    Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
    Trigger.MethodName = 'PostBuildGameState';
    Template.AbilityTriggers.AddItem(Trigger);
    //  trigger on an attack
    Trigger = new class'X2AbilityTrigger_Event';
    Trigger.EventObserverClass = class'X2TacticalGameRuleset_AttackObserver';
    Trigger.MethodName = 'InterruptGameState';
    Template.AbilityTriggers.AddItem(Trigger);

    // Retain Concealment
    Template.ConcealmentRule = eConceal_Always;

    // No Alert Through Sound
    Template.bSilentAbility = true;

    // Inoffensive
    Template.Hostility = eHostility_Neutral;

    // No Robots
    TargetPropertyCondition = new class'X2Condition_UnitProperty';
    TargetPropertyCondition.ExcludeRobotic = true;
    Template.AbilityTargetConditions.AddItem(TargetPropertyCondition);

    Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
    TargetVisibilityCondition = new class'X2Condition_Visibility';
    TargetVisibilityCondition.bRequireGameplayVisible = true;
    TargetVisibilityCondition.bRequireBasicVisibility = true;
    TargetVisibilityCondition.bDisablePeeksOnMovement = true; // Don't use peek tiles for overwatch shots
    Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
    //SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
    //Template.AddShooterEffectExclusions(SkipExclusions);

    // ONLY trigger when the source is concealed
    SourceConcealedCondition = new class'X2Condition_UnitProperty';
    SourceConcealedCondition.IsConcealed = true;
    Template.AbilityShooterConditions.AddItem(SourceConcealedCondition);

    Template.bAllowBonusWeaponEffects = false;
    //Template.AddTargetEffect(new class'X2Effect_ApplyWeaponDamage');

    //// Unconscious Effect
    ////
    //UnconsciousEffect = class'X2StatusEffects'.static.CreateUnconsciousStatusEffect();
    //Template.AddTargetEffect(UnconsciousEffect);

    // Don't break your patrol by dying on them later, especially if you're in charge.
    UngroupEffect = new class'X2Effect_SpookUngroupAI';
    UngroupEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    UngroupEffect.bRemoveWhenTargetDies = true;
    Template.AddTargetEffect(UngroupEffect);

    // Bleed
    Template.AddTargetEffect(class'X2Effect_SpookBleeding'.static.CreateBleedingStatusEffect(class'X2Item_SpookDamageTypes'.const.StealthBleedDamageTypeName, default.SPOOK_OPPORTUNIST_BLEED_TURNS, default.SPOOK_OPPORTUNIST_BLEED_DAMAGE_PER_TICK, default.SPOOK_OPPORTUNIST_BLEED_DAMAGE_SPREAD_PER_TICK));

    // Prevent repeatedly hammering on a unit with Opportunist triggers.
    //(This effect does nothing, but enables many-to-many marking of which Opportunist attacks have already occurred each turn.)
    OpportunistTargetEffect = new class'X2Effect_Persistent';
    OpportunistTargetEffect.BuildPersistentEffect(`BPE_TickAtEndOfNAnyTurns(1));
    OpportunistTargetEffect.EffectName = 'OpportunistTarget';
    OpportunistTargetEffect.bApplyOnMiss = true; //Only one chance, even if you miss (prevents crazy flailing counter-attack chains with a Muton, for example)
    Template.AddTargetEffect(OpportunistTargetEffect);

    OpportunistTargetCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
    OpportunistTargetCondition.AddExcludeEffect('OpportunistTarget', 'AA_DuplicateEffectIgnored');

    // Don't keep darting the same enemies.
    OpportunistTargetCondition.AddExcludeEffect('SpookBleeding', 'AA_DuplicateEffectIgnored');

    // Apply the above two.
    Template.AbilityTargetConditions.AddItem(OpportunistTargetCondition);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = Opportunist_BuildSimpleVisualization;

    return Template;
}

static function Opportunist_BuildSimpleVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
    local XComGameStateHistory          History;
    local XComGameStateContext_Ability  Context;
    local AbilityInputContext           AbilityContext;
    local X2AbilityTemplate             AbilityTemplate;
    local StateObjectReference          ShootingUnitRef;
    local Actor                         ShooterVisualizer;
    local X2VisualizerInterface         ShooterVisualizerInterface;
    local StateObjectReference          TargetUnitRef;
    local Actor                         TargetVisualizer;

    local VisualizationTrack            SourceTrack;
    local X2Action_SpookFaceUnit        FaceUnit;
    local X2Action_PlaySoundAndFlyOver  SoundAndFlyOver;
    local X2Action_PlayAnimation        PlayAnimation;
    local X2Action_Delay                Delay;

    local VisualizationTrack            TargetTrack;

    // Find various things
    History = `XCOMHISTORY;
    Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
    AbilityContext = Context.InputContext;
    AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
    ShootingUnitRef = Context.InputContext.SourceObject;
    ShooterVisualizer = History.GetVisualizer(ShootingUnitRef.ObjectID);
    ShooterVisualizerInterface = X2VisualizerInterface(ShooterVisualizer);
    TargetUnitRef = AbilityContext.PrimaryTarget;
    TargetVisualizer = History.GetVisualizer(AbilityContext.PrimaryTarget.ObjectID);

    // Prepare the source (shooter) track
    SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
    SourceTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
    if (SourceTrack.StateObject_NewState == none)
    {
        SourceTrack.StateObject_NewState = SourceTrack.StateObject_OldState;
    }
    SourceTrack.TrackActor = ShooterVisualizer;
    SourceTrack.AbilityName = AbilityTemplate.DataName;

    // Prepare the target track
    TargetTrack.StateObject_OldState = History.GetGameStateForObjectID(TargetUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
    TargetTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(TargetUnitRef.ObjectID);
    if (TargetTrack.StateObject_NewState == none)
    {
        TargetTrack.StateObject_NewState = TargetTrack.StateObject_OldState;
    }
    TargetTrack.TrackActor = TargetVisualizer;
    TargetTrack.AbilityName = AbilityTemplate.DataName;

    // Now the actual visuals we wish to have on the source.
    FaceUnit = X2Action_SpookFaceUnit(class'X2Action_SpookFaceUnit'.static.AddToVisualizationTrack(SourceTrack, VisualizeGameState.GetContext()));
    FaceUnit.FaceActor = TargetVisualizer;
    SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(SourceTrack, VisualizeGameState.GetContext()));
    SoundAndFlyOver.SetSoundAndFlyOverParameters(SoundCue(DynamicLoadObject("Spook.SpookSilencedPistolMono_Cue", class'SoundCue')), default.OpportunistFriendlyName, '', eColor_Good,,0,false);
    PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTrack(SourceTrack, VisualizeGameState.GetContext()));
    PlayAnimation.Params.AnimName = 'NO_GrappleFire'; // from Soldier_ANIM.Anims.AS_Solider. Or 'HL_SendGremlin'. See AS_xxxx.

    // Now the visuals for the target.
    Delay = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTrack(TargetTrack, VisualizeGameState.GetContext()));
    Delay.Duration = 2.8f;
    Delay.bIgnoreZipMode = true;
    SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(TargetTrack, VisualizeGameState.GetContext()));
    SoundAndFlyOver.SetSoundAndFlyOverParameters(None, class'X2Effect_SpookBleeding'.default.BleedingFriendlyName, '', eColor_Bad,,0,false);

    // Apparently one does this.
    if (ShooterVisualizerInterface != none)
    {
        ShooterVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, SourceTrack);
    }

    // Hopefully that's all we need.
    OutVisualizationTracks.AddItem(SourceTrack);
    OutVisualizationTracks.AddItem(TargetTrack);
}

static function X2AbilityTemplate AddWiredAbility()
{
    local X2AbilityTemplate                 Template;
    local X2Effect_DamageImmunity           ImmunityEffect;
    local X2Effect_PersistentStatChange     SightEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Wired');
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mentalstrength";
    Template.Hostility = eHostility_Neutral;
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bCrossClassEligible = true;
    Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;

    ImmunityEffect = new class'X2Effect_DamageImmunity';
    ImmunityEffect.ImmuneTypes.AddItem('Stun');
    ImmunityEffect.ImmuneTypes.AddItem('Unconscious');
    ImmunityEffect.ImmuneTypes.AddItem('Panic');
    ImmunityEffect.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.DisorientDamageType);
    ImmunityEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, false, , Template.AbilitySourceName);
    ImmunityEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    Template.AddTargetEffect(ImmunityEffect);

    SightEffect = new class'X2Effect_PersistentStatChange';
    SightEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    SightEffect.AddPersistentStatChange(eStat_SightRadius, default.SPOOK_WIRED_SIGHT_RANGE_INCREASE);
    Template.AddTargetEffect(SightEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate AddDartAbility()
{
    local X2AbilityTemplate                     Template;
    local X2Condition_Visibility                RequireVisibleCondition;
    local X2Condition_UnitProperty              NoRobotsCondition;
    local X2AbilityCost_ActionPoints            ActionPointCost;
    local X2Effect_ApplyWeaponDamage_SpookDart  DamageEffect;
    local X2Effect_SpookUngroupAI               UngroupEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Dart');

    Template.bDontDisplayInAbilitySummary = false;
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_bloodcall";
    Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_PISTOL_SHOT_PRIORITY;
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
    Template.DisplayTargetHitChance = true;
    Template.AbilitySourceName = 'eAbilitySource_Standard';
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
    Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;

    Template.AbilityTargetStyle = default.SimpleSingleTarget;
    Template.AbilityToHitCalc = default.SimpleStandardAim;
    Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;
    Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
    Template.bUsesFiringCamera = true;
    Template.CinescriptCameraType = "StandardGunFiring";

    Template.ConcealmentRule = eConceal_Always;
    Template.bSilentAbility = true;
    Template.Hostility = eHostility_Neutral;
    Template.bAllowFreeFireWeaponUpgrade = true;

    AbilityRequiresSpookShooter(Template);

    // Target must be visible
    RequireVisibleCondition = new class'X2Condition_Visibility';
    RequireVisibleCondition.bRequireGameplayVisible = true;
    RequireVisibleCondition.bAllowSquadsight = true;
    Template.AbilityTargetConditions.AddItem(RequireVisibleCondition);

    // Target must be alive
    Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

    // Shooter must be alive
    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

    // No Robots
    NoRobotsCondition = new class'X2Condition_UnitProperty';
    NoRobotsCondition.ExcludeRobotic = true;
    Template.AbilityTargetConditions.AddItem(NoRobotsCondition);

    // Cost an action
    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 1;
    ActionPointCost.bConsumeAllPoints = false;
    Template.AbilityCosts.AddItem(ActionPointCost);

    // Can cause a holotarget to be applied
    Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
    Template.AssociatedPassives.AddItem('HoloTargeting');
    // (Cannot shred even if the shooter can, so we don't add that effect.)

    // Damage
    DamageEffect = new class'X2Effect_ApplyWeaponDamage_SpookDart';
    DamageEffect.bIgnoreBaseDamage = true;
    DamageEffect.bAllowWeaponUpgrade = false;
    DamageEffect.DamageTag = 'Spook_Dart';
    Template.AddTargetEffect(DamageEffect);
    Template.bAllowBonusWeaponEffects = false;
    Template.bAllowAmmoEffects = false;

    // Bleed
    Template.AddTargetEffect(class'X2Effect_SpookBleeding'.static.CreateBleedingStatusEffect(class'X2Item_SpookDamageTypes'.const.StealthBleedDamageTypeName, default.SPOOK_DART_BLEED_TURNS, default.SPOOK_DART_BLEED_DAMAGE_PER_TICK, default.SPOOK_DART_BLEED_DAMAGE_SPREAD_PER_TICK));

    // Don't break your patrol by dying on them later, especially if you're in charge.
    UngroupEffect = new class'X2Effect_SpookUngroupAI';
    UngroupEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    UngroupEffect.bRemoveWhenTargetDies = true;
    Template.AddTargetEffect(UngroupEffect);

    Template.BuildNewGameStateFn = BuildDartGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
    Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

    return Template;
}

static function XComGameState BuildDartGameState(XComGameStateContext Context)
{
    local XComGameState NewGameState;
    local XComGameStateHistory History;
    local XComGameStateContext_Ability AbilityContext;
    local XComGameState_Unit TargetState;
    local XComGameState_AIUnitData AI;
    local AlertAbilityInfo AlertInfo;

    History = `XCOMHISTORY;

    NewGameState = History.CreateNewGameState(true, Context);

    // First do what typical abilities do.
    TypicalAbility_FillOutGameState(NewGameState);

    // Then if we hit, we want to do some other things.
    AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
    if (AbilityContext.IsResultContextHit())
    {
        // Grab our target unit.
        TargetState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
        if (TargetState == none)
        {
            TargetState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
        }

        // If the target dies, everyone will be worried by the corpse.
        // If they don't, we want to worry them.
        if (TargetState != none && TargetState.IsAlive())
        {
            AlertInfo.AlertTileLocation = TargetState.TileLocation;
            AlertInfo.AlertRadius = 1;
            AlertInfo.AlertUnitSourceID = 0; //TargetState.ObjectID;
            AlertInfo.AnalyzingHistoryIndex = History.GetCurrentHistoryIndex();

            AI = XComGameState_AIUnitData(NewGameState.GetGameStateForObjectID(TargetState.GetAIUnitDataID()));
            if (AI == none)
            {
                AI = XComGameState_AIUnitData(NewGameState.CreateStateObject(class'XComGameState_AIUnitData', TargetState.GetAIUnitDataID()));
                if (AI.AddAlertData(AI.m_iUnitObjectID, eAC_DetectedSound, AlertInfo, NewGameState))
                {
                    NewGameState.AddStateObject(AI);
                }
                else
                {
                    NewGameState.PurgeGameStateForObjectID(AI.ObjectID);
                }
            }
            else
            {
                AI.AddAlertData(AI.m_iUnitObjectID, eAC_DetectedSound, AlertInfo, NewGameState);
            }
        }
    }

    return NewGameState;
}
