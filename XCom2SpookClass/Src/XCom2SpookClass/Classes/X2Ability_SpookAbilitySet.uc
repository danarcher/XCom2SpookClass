class X2Ability_SpookAbilitySet
    extends X2Ability
    dependson (XComGameStateContext_Ability)
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var config float VEIL_RK_DETECTION_RANGE_REDUCTION;
var config float VEIL_SQ_DETECTION_RANGE_REDUCTION;
var config float VEIL_LCPL_DETECTION_RANGE_REDUCTION;
var config float VEIL_CPL_DETECTION_RANGE_REDUCTION;
var config float VEIL_SGT_DETECTION_RANGE_REDUCTION;
var config float VEIL_SSGT_DETECTION_RANGE_REDUCTION;
var config float VEIL_TSGT_DETECTION_RANGE_REDUCTION;
var config float VEIL_GSGT_DETECTION_RANGE_REDUCTION;
var config float VEIL_MSGT_DETECTION_RANGE_REDUCTION;

var config int DISTRACT_CHARGES;
var config int DISTRACT_COOLDOWN_TURNS;
var config float DISTRACT_RANGE_TILES;
var config float DISTRACT_RADIUS_TILES;
var config int DISTRACT_TURNS;
var config float DISTRACT_MOBILITY_ADJUST;
var config bool DISTRACT_EXCLUDE_RED_ALERT;

var config bool SHADE_SOUND_EFFECTS;

var config int VANISH_CHARGES;
var config float VANISH_RADIUS;

var config float EXFIL_RADIUS;
var config float EXODUS_RADIUS;

var config WeaponDamageValue DART_CONVENTIONAL_DAMAGE;
var config WeaponDamageValue DART_LASER_DAMAGE;
var config WeaponDamageValue DART_MAGNETIC_DAMAGE;
var config WeaponDamageValue DART_COIL_DAMAGE;
var config WeaponDamageValue DART_BEAM_DAMAGE;

var config int DART_CHARGES;
var config int DART_BLEED_TURNS;
var config int DART_BLEED_DAMAGE_PER_TICK;
var config int DART_BLEED_DAMAGE_SPREAD_PER_TICK;
var config int DART_BLEED_DAMAGE_PLUSONE_PER_TICK;

var config int SURGEON_DAMAGE;
var config int SURGEON_AIM;

var localized string WiredNotRevealedByClassesFriendlyName;
var localized string WiredNotRevealedByClassesHelpText;

const ExeuntAbilityName = 'Spook_Exeunt';
const WiredAbilityName = 'Spook_Wired';
const MeldAbilityName = 'Spook_Meld';
const MeldTriggerAbilityName = 'Spook_MeldTrigger';

// These names are used for related abilities, effects, and/or events!
const WiredNotRevealedByClassesName = 'Spook_WiredNotRevealedByClasses';

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(AddWiredAbility());
    Templates.AddItem(AddWiredNotRevealedByClassesAbility());
    Templates.AddItem(AddVeilAbility());
    Templates.AddItem(AddDistractAbility());
    Templates.AddItem(AddDistractThrowGrenadeAbility());
    Templates.AddItem(AddMeldAbility());
    Templates.AddItem(AddMeldTriggerAbility());
    Templates.AddItem(AddVanishAbility());
    Templates.AddItem(AddExfilAbility());
    Templates.AddItem(AddExodusAbility());

    Templates.AddItem(AddDartAbility());
    Templates.AddItem(AddPistolStatBonusAbility());

    Templates.AddItem(AddEclipseAbility());

    Templates.AddItem(AddExeuntAbility());

    Templates.AddItem(AddSurgeonAbility());

    Templates.AddItem(PurePassive('Spook_Dummy0', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy1', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy2', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy3', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy4', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy5', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy6', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy7', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy8', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy9', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy10', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy11', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy12', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy13', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy14', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy15', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy16', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy17', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy18', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy19', "img:///UILibrary_PerkIcons.UIPerk_unknown"));
    Templates.AddItem(PurePassive('Spook_Dummy20', "img:///UILibrary_PerkIcons.UIPerk_unknown"));

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

static function X2AbilityTemplate AddWiredAbility()
{
    local X2AbilityTemplate                 Template;
    local X2Effect_DamageImmunity           ImmunityEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, WiredAbilityName);
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mentalstrength";
    Template.Hostility = eHostility_Neutral;
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;

    ImmunityEffect = new class'X2Effect_DamageImmunity';
    ImmunityEffect.ImmuneTypes.AddItem('Stun');
    ImmunityEffect.ImmuneTypes.AddItem('Unconscious');
    ImmunityEffect.ImmuneTypes.AddItem('Panic');
    ImmunityEffect.ImmuneTypes.AddItem('Mental');
    ImmunityEffect.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.DisorientDamageType);
    ImmunityEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
    ImmunityEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    Template.AddTargetEffect(ImmunityEffect);

    Template.AdditionalAbilities.AddItem(WiredNotRevealedByClassesName);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate AddWiredNotRevealedByClassesAbility()
{
    local X2AbilityTemplate                            Template;
    local X2AbilityTrigger_EventListener               EventTrigger;
    local X2Condition_UnitProperty                     TargetPropertyCondition;
    local X2Condition_Spook                            TargetSpecialCondition;
    local X2Effect_PersistentStatChange                DetectionChangeEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, WiredNotRevealedByClassesName);

    EventTrigger = new class'X2AbilityTrigger_EventListener';
    EventTrigger.ListenerData.EventID = WiredNotRevealedByClassesName;
    EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.SolaceCleanseListener; // Handy.
    EventTrigger.ListenerData.Filter = eFilter_Unit;
    EventTrigger.ListenerData.Deferral = ELD_Immediate;

    Template.AbilitySourceName = 'eAbilitySource_Standard';
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_unknown";
    Template.Hostility = eHostility_Neutral;
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SimpleSingleTarget;
    Template.AbilityTriggers.AddItem(EventTrigger);
    Template.bDisplayInUITooltip = false;
    Template.bDisplayInUITacticalText = false;

    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
    AbilityRequiresSpookShooter(Template);

    TargetPropertyCondition = new class'X2Condition_UnitProperty'; // Defaults are good; living enemy, etc.
    Template.AbilityTargetConditions.AddItem(TargetPropertyCondition);
    TargetSpecialCondition = new class'X2Condition_Spook';
    TargetSpecialCondition.bRequireCannotRevealWiredSource = true;
    Template.AbilityTargetConditions.AddItem(TargetSpecialCondition);

    DetectionChangeEffect = new class'X2Effect_PersistentStatChange';
    DetectionChangeEffect.EffectName = WiredNotRevealedByClassesName;
    DetectionChangeEffect.DuplicateResponse = eDupe_Ignore;
    DetectionChangeEffect.BuildPersistentEffect(`BPE_TickAtEndOfNAnyTurns(1)); // Last until the end of the turn it's cast.
    DetectionChangeEffect.AddPersistentStatChange(eStat_DetectionRadius, -100);
    DetectionChangeEffect.SetDisplayInfo(ePerkBuff_Penalty, default.WiredNotRevealedByClassesFriendlyName, default.WiredNotRevealedByClassesHelpText, "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_confuse");
    Template.AddTargetEffect(DetectionChangeEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate AddVeilAbility()
{
    local X2AbilityTemplate                         Template;
    local X2Effect_SpookPersistentRankedStatChange  VeilEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Veil');
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.IconImage = "img:///Spook.UIPerk_veil";
    Template.Hostility = eHostility_Neutral;
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;

    VeilEffect = new class'X2Effect_SpookPersistentRankedStatChange';
    VeilEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    VeilEffect.SetDisplayInfo(ePerkBuff_Passive,Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
    VeilEffect.AddPersistentStatChange(0, eStat_DetectionModifier, default.VEIL_RK_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(1, eStat_DetectionModifier, default.VEIL_SQ_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(2, eStat_DetectionModifier, default.VEIL_LCPL_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(3, eStat_DetectionModifier, default.VEIL_CPL_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(4, eStat_DetectionModifier, default.VEIL_SGT_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(5, eStat_DetectionModifier, default.VEIL_SSGT_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(6, eStat_DetectionModifier, default.VEIL_TSGT_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(7, eStat_DetectionModifier, default.VEIL_GSGT_DETECTION_RANGE_REDUCTION);
    VeilEffect.AddPersistentStatChange(8, eStat_DetectionModifier, default.VEIL_MSGT_DETECTION_RANGE_REDUCTION);
    Template.AddTargetEffect(VeilEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate AddDistractAbility()
{
    local X2AbilityTemplate             Template;
    local X2Effect_SpookTemporaryItem   ItemEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Distract');

    Template.IconImage = "img:///Spook.UIPerk_distract_grenade";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
    Template.bIsPassive = true;

    ItemEffect = new class'X2Effect_SpookTemporaryItem';
    ItemEffect.bIgnoreItemEquipRestrictions = true;
    ItemEffect.EffectName = 'SpookDistractGrenadeEffect';
    ItemEffect.ItemName = 'SpookDistractGrenade';
    ItemEffect.bIgnoreItemEquipRestrictions = true;
    ItemEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    ItemEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false,, Template.AbilitySourceName);
    ItemEffect.DuplicateResponse = eDupe_Ignore;
    Template.AddTargetEffect(ItemEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate AddDistractThrowGrenadeAbility()
{
    local X2AbilityTemplate             Template;
    local X2AbilityCost_ActionPoints    ActionPointCost;
    local X2AbilityCharges              Charges;
    local X2AbilityCooldown             Cooldown;

    local X2AbilityTarget_Cursor        CursorTarget;
    local X2AbilityMultiTarget_Radius   RadiusMultiTarget;
    local X2Condition_UnitProperty      MultiTargetPropertyCondition;
    local X2Condition_Spook             MultiTargetSpecialCondition;
    local X2Effect_PersistentStatChange DistractEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'SpookThrowDistractGrenade');

    Template.IconImage = "img:///Spook.UIPerk_distract_grenade";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
    Template.Hostility = eHostility_Neutral;
    Template.ConcealmentRule = eConceal_Always;
    Template.bSilentAbility = true;
    Template.bHideWeaponDuringFire = true;
    Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_GRENADE_PRIORITY;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

    CursorTarget = new class'X2AbilityTarget_Cursor';
    CursorTarget.bRestrictToWeaponRange = true;
    Template.AbilityTargetStyle = CursorTarget;

    RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
    RadiusMultiTarget.bUseWeaponRadius = true;
    RadiusMultiTarget.bIgnoreBlockingCover = true;
    Template.AbilityMultiTargetStyle = RadiusMultiTarget;
    Template.TargetingMethod = class'X2TargetingMethod_Grenade';

    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 1;
    ActionPointCost.bFreeCost = false;
    Template.AbilityCosts.AddItem(ActionPointCost);

    if (default.DISTRACT_CHARGES > 0)
    {
        Charges = new class'X2AbilityCharges';
        Charges.InitialCharges = default.DISTRACT_CHARGES;
        Template.AbilityCharges = Charges;
        Template.AbilityCosts.AddItem(new class'X2AbilityCost_Charges');
    }

    if (default.DISTRACT_COOLDOWN_TURNS > 0)
    {
        Cooldown = new class'X2AbilityCooldown';
        Cooldown.iNumTurns = default.DISTRACT_COOLDOWN_TURNS;
        Template.AbilityCooldown = Cooldown;
    }

    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
    Template.AddShooterEffectExclusions();

    MultiTargetPropertyCondition = new class'X2Condition_UnitProperty';
    MultiTargetPropertyCondition.FailOnNonUnits = true; // plus defaults
    Template.AbilityMultiTargetConditions.AddItem(MultiTargetPropertyCondition);

    if (default.DISTRACT_EXCLUDE_RED_ALERT)
    {
        `SPOOKSLOG("Distract excludes red alert and hence is prevented by it");
        MultiTargetSpecialCondition = new class'X2Condition_Spook';
        MultiTargetSpecialCondition.bRequireCredulousAI = true;
        Template.AbilityMultiTargetConditions.AddItem(MultiTargetSpecialCondition);
    }
    else
    {
        `SPOOKSLOG("Distract does NOT exclude red alert");
    }

    DistractEffect = class'XComGameState_SpookDistractEffect'.static.CreateDistractEffect(default.DISTRACT_TURNS, default.DISTRACT_MOBILITY_ADJUST, Template.IconImage);
    Template.AddMultiTargetEffect(DistractEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    return Template;
}

static function X2AbilityTemplate AddMeldAbility()
{
    local X2AbilityTemplate Template;
    // This is a PurePassive so we get a "we can meld" status icon.
    Template = PurePassive(MeldAbilityName, "img:///Spook.UIPerk_meld");
    Template.AdditionalAbilities.AddItem(MeldTriggerAbilityName);
    return Template;
}

static function X2AbilityTemplate AddMeldTriggerAbility()
{
    local X2AbilityTemplate             Template;
    local array<name>                   SkipExclusions;
    local X2Condition_UnitProperty      ConcealedShooterCondition;
    local X2AbilityCost_ActionPoints    ActionPointCost;

    `CREATE_X2ABILITY_TEMPLATE(Template, MeldTriggerAbilityName);
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_unknown";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.bHideOnClassUnlock = true;
    Template.bDisplayInUITooltip = false;
    Template.bDisplayInUITacticalText = false;

    // Cost
    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 0;
    ActionPointCost.bFreeCost = true;
    ActionPointCost.bConsumeAllPoints = false;
    Template.AbilityCosts.AddItem(ActionPointCost);

    // Activation
    Template.bIsPassive = false;
    Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');
    Template.bSkipFireAction = true;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;

    // Shooter conditions
    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);               // Must be alive
    SkipExclusions.AddItem(class'X2Ability_CarryUnit'.default.CarryUnitEffectName);         // Can be carrying someone
    SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);           // Can be disoriented (by a sectoid)
    SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);        // Can be disoriented (by something else)
    SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);                     // Can be on fire
    Template.AddShooterEffectExclusions(SkipExclusions);
    ConcealedShooterCondition = new class'X2Condition_UnitProperty';
    ConcealedShooterCondition.ExcludeFriendlyToSource = false;
    ConcealedShooterCondition.IsConcealed = true;
    Template.AbilityShooterConditions.AddItem(ConcealedShooterCondition);

    Template.AddTargetEffect(class'X2Effect_SpookShade'.static.CreateShadeEffect(true, Template.LocFriendlyName));

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    return Template;
}

static function X2AbilityTemplate AddVanishAbility()
{
    local X2AbilityTemplate                 Template;
    local X2AbilityCost_ActionPoints        ActionPointCost;
    local X2Condition_UnitProperty          ShooterProperty;
    local X2Effect_ApplySmokeGrenadeToWorld SmokeEffect;
    local X2Effect_RangerStealth            StealthEffect;
    local X2Effect_SpookBonusMove           BonusMoveEffect;
    local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
    local X2AbilityCharges                  Charges;
    local array<name>                       SkipExclusions;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Vanish');
    Template.IconImage = "img:///Spook.UIPerk_vanish";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
    Template.Hostility = eHostility_Neutral;
    Template.bDisplayInUITacticalText = true;

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

    if (default.VANISH_CHARGES > 0)
    {
        Charges = new class'X2AbilityCharges';
        Charges.InitialCharges = default.VANISH_CHARGES;
        Template.AbilityCharges = Charges;
        Template.AbilityCosts.AddItem(new class'X2AbilityCost_Charges');
    }

    RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
    RadiusMultiTarget.bUseWeaponRadius = false;
    RadiusMultiTarget.bUseSourceWeaponLocation = false;
    RadiusMultiTarget.bIgnoreBlockingCover = true;
    RadiusMultiTarget.fTargetRadius = `TILESTOMETERS(default.VANISH_RADIUS);
    Template.AbilityMultiTargetStyle = RadiusMultiTarget;

    SmokeEffect = new class'X2Effect_ApplySmokeGrenadeToWorld';
    Template.AddTargetEffect(SmokeEffect);
    Template.AddMultiTargetEffect(class'X2Item_DefaultGrenades'.static.SmokeGrenadeEffect());

    StealthEffect = new class'X2Effect_RangerStealth';
    StealthEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true);
    StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
    Template.AddTargetEffect(StealthEffect);
    Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

    Template.AddTargetEffect(class'X2Effect_SpookShade'.static.CreateShadeEffect(false, Template.LocFriendlyName));

    // Bonus Move Effect
    BonusMoveEffect = new class'X2Effect_SpookBonusMove';
    BonusMoveEffect.bApplyOnMiss = true;
    BonusMoveEffect.bEvenIfFree = true;
    BonusMoveEffect.BuildPersistentEffect(`BPE_TickAtEndOfNUnitTurns(1));
    Template.AddShooterEffect(BonusMoveEffect);

    Template.ActivationSpeech = 'ActivateConcealment';
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    return Template;
}

static function X2AbilityTemplate AddExfilAbility()
{
    return BuildExfilAbility('Spook_Exfil', "img:///Spook.UIPerk_exfil", default.EXFIL_RADIUS);
}

static function X2AbilityTemplate AddExodusAbility()
{
    return BuildExfilAbility('Spook_Exodus', "img:///Spook.UIPerk_exodus", default.EXODUS_RADIUS);
}

static function X2AbilityTemplate BuildExfilAbility(name AbilityName, string IconImage, float SmokeRadius)
{
    local X2AbilityTemplate                 Template;
    local X2AbilityCost_ActionPoints        ActionPointCost;
    local X2Condition_UnitProperty          MultiTargetPropertyCondition;
    local X2Condition_AbilityProperty       MultiTargetEvacCondition;
    local X2AbilityMultiTarget_Radius       RadiusMultiTarget;
    local array<name>                       SkipExclusions;
    local X2Effect_ApplySmokeGrenadeToWorld SmokeEffect;
    local X2Effect_PersistentStatChange     SightRadiusEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);
    Template.IconImage = IconImage;
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
    Template.Hostility = eHostility_Neutral;
    Template.bDisplayInUITacticalText = true;

    // Cost
    ActionPointCost = new class'X2AbilityCost_ActionPoints';
    ActionPointCost.iNumPoints = 0;
    ActionPointCost.bFreeCost = true;
    Template.AbilityCosts.AddItem(ActionPointCost);

    // Activation
    Template.bIsPassive = false;
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
    Template.bSkipFireAction = true;
    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;

    RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
    RadiusMultiTarget.bUseWeaponRadius = false;
    RadiusMultiTarget.bUseSourceWeaponLocation = false;
    RadiusMultiTarget.bIgnoreBlockingCover = true;
    RadiusMultiTarget.fTargetRadius = `TILESTOMETERS(SmokeRadius);
    Template.AbilityMultiTargetStyle = RadiusMultiTarget;

    // Shooter conditions
    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);               // Must be alive
    SkipExclusions.AddItem(class'X2Ability_CarryUnit'.default.CarryUnitEffectName);         // Can be carrying someone
    SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);           // Can be disoriented (by a sectoid)
    SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);        // Can be disoriented (by something else)
    SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);                     // Can be on fire
    Template.AddShooterEffectExclusions(SkipExclusions);

    // Only evac living, friendly player-controlled units.
    MultiTargetPropertyCondition = new class'X2Condition_UnitProperty';
    MultiTargetPropertyCondition.FailOnNonUnits = true; // plus defaults
    MultiTargetPropertyCondition.ExcludeFriendlyToSource = false;
    MultiTargetPropertyCondition.ExcludeHostileToSource = true;
    MultiTargetPropertyCondition.IsPlayerControlled = true;
    Template.AbilityMultiTargetConditions.AddItem(MultiTargetPropertyCondition);

    // Only evac people who can evac (not necessarily on this mission).
    MultiTargetEvacCondition = new class'X2Condition_AbilityProperty';
    MultiTargetEvacCondition.OwnerHasSoldierAbilities.AddItem('Evac');
    Template.AbilityMultiTargetConditions.AddItem(MultiTargetEvacCondition);

    SmokeEffect = new class'X2Effect_ApplySmokeGrenadeToWorld';
    Template.AddTargetEffect(SmokeEffect);
    Template.AddMultiTargetEffect(class'X2Item_DefaultGrenades'.static.SmokeGrenadeEffect());

    // Compensate for a vanilla bug which leaves evacuated units with vision of the area they left.
    SightRadiusEffect = new class'X2Effect_PersistentStatChange';
    SightRadiusEffect.DuplicateResponse = eDupe_Ignore;
    SightRadiusEffect.BuildPersistentEffect(`BPE_TickNever_LastForever);
    SightRadiusEffect.AddPersistentStatChange(eStat_SightRadius, -100);
    Template.AddTargetEffect(SightRadiusEffect);
    Template.AddMultiTargetEffect(SightRadiusEffect);

    Template.BuildNewGameStateFn = BuildExfilGameState;
    Template.BuildVisualizationFn = BuildExfilVisualization;

    return Template;
}

static function XComGameState BuildExfilGameState(XComGameStateContext Context)
{
    local XComGameStateHistory History;
    local XComGameState NewGameState;
    local XComGameStateContext_Ability AbilityContext;
    local XComGameState_Ability AbilityState;
    local StateObjectReference UnitRef;
    local XComGameState_Unit Unit;
    local array<int> EvacObjectIDs;
    local int EvacObjectID;

    History = `XCOMHISTORY;
    AbilityContext = XComGameStateContext_Ability(Context);
    AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));

    EvacObjectIDs.AddItem(AbilityContext.InputContext.SourceObject.ObjectID);
    foreach AbilityContext.InputContext.MultiTargets(UnitRef)
    {
        if (EvacObjectIDs.Find(UnitRef.ObjectID) == INDEX_NONE)
        {
            EvacObjectIDs.AddItem(UnitRef.ObjectID);
        }
    }

    // We can only safely evacuate one unit per game-state without issues.
    // So, we evacuate each unit in its own game state.
    foreach EvacObjectIDs(EvacObjectID)
    {
        NewGameState = `CreateChangeState("Spook Per-Unit Evac");
        Unit = `FindOrAddUnitState(EvacObjectID, NewGameState);
        `XEVENTMGR.TriggerEvent('EvacActivated', AbilityState, Unit, NewGameState);
        Unit.EvacuateUnit(NewGameState);
        Unit.SetIndividualConcealment(false, NewGameState);
        `TACTICALRULES.SubmitGameState(NewGameState);
    }

    // Then the ability runs in another new game state.
    NewGameState = History.CreateNewGameState(true, Context);
    TypicalAbility_FillOutGameState(NewGameState);

    return NewGameState;
}

static function EvacuateUnitAddingToGameState(XComGameState_Unit Unit, XComGameState NewGameState, XComGameState_Ability AbilityState)
{
    Unit.EvacuateUnit(NewGameState);                    // Adds to NewGameState, along with any carried unit.
    Unit.SetIndividualConcealment(false, NewGameState); // Concealment bug workaround.
    //Unit.SetCurrentStat(eStat_SightRadius, 0);        // Sight bug workaround (introduces problems later).
}

function BuildExfilVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
    local XComGameStateHistory History;
    local XComGameStateContext_Ability Context;
    local XComGameState_Ability AbilityState;
    local X2AbilityTemplate AbilityStateTemplate;
    local VisualizationTrack Track, OtherTrack;
    local X2Action_PlaySoundAndFlyover SoundAndFlyOver;
    local X2Action_PlayAnimation PlayAnimation;
    local X2Action_SpookPlayAkEvent PlayAkEvent;
    local X2Action_Delay Delay;
    local X2Action_SendInterTrackMessage Message;
    local X2Action_WaitForAbilityEffect Wait;
    local int TrackIndex, ActionIndex, TargetIndex;
    local XComGameState_Unit OtherUnit;

    //  Start off with the defaults.
    TypicalAbility_BuildVisualization(VisualizeGameState, OutVisualizationTracks);

    History = `XCOMHISTORY;
    Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
    AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID));
    AbilityStateTemplate = AbilityState.GetMyTemplate();

    // Find and remove the shooter's visualization track; we'll add it (back) later once modified.
    class'SpookRedAlertVisualizer'.static.FindAndRemoveOrCreateTrackFor(Context.InputContext.SourceObject.ObjectID, AbilityStateTemplate, VisualizeGameState, History, OutVisualizationTracks, Track);

    // Ensure we have tracks for everyone else, adding them (back).
    for (TargetIndex = 0; TargetIndex < Context.InputContext.MultiTargets.Length; ++TargetIndex)
    {
        class'SpookRedAlertVisualizer'.static.FindAndRemoveOrCreateTrackFor(Context.InputContext.MultiTargets[TargetIndex].ObjectID, AbilityStateTemplate, VisualizeGameState, History, OutVisualizationTracks, OtherTrack);
        OutVisualizationTracks.AddItem(OtherTrack);
    }

    // Announce the exit.
    SoundAndFlyOver = X2Action_PlaySoundAndFlyover(`InsertTrackAction(Track, ActionIndex++, class'X2Action_PlaySoundAndFlyover', Context));
    SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", 'EVAC', eColor_Good);

    // First, the master track plays the halt animation.
    PlayAnimation = X2Action_PlayAnimation(`InsertTrackAction(Track, ActionIndex++, class'X2Action_PlayAnimation', Context));
    PlayAnimation.Params.AnimName = 'HL_SignalHaltA';

    // Sync all tracks with where the master is now, including smoke tracks, since they can start now.
    for (TrackIndex = 0; TrackIndex < OutVisualizationTracks.Length; ++TrackIndex)
    {
        OtherTrack = OutVisualizationTracks[TrackIndex];

        if (OtherTrack.StateObject_NewState.ObjectID == Track.StateObject_NewState.ObjectID)
        {
            // The master track does not message itself.
            continue;
        }

        // Master track sends message to this other track.
        Message = X2Action_SendInterTrackMessage(`InsertTrackAction(Track, ActionIndex++, class'X2Action_SendInterTrackMessage', Context));
        Message.SendTrackMessageToRef.ObjectID = OtherTrack.StateObject_NewState.ObjectID;

        // Other track waits for message from master track, then start.
        Wait = X2Action_WaitForAbilityEffect(`InsertTrackAction(OtherTrack, 0, class'X2Action_WaitForAbilityEffect', Context));
        Wait.bWaitingForActionMessage = true;

        // If the other track is a unit, it cloaks as the first action after the master track message.
        OtherUnit = `FindUnitState(OtherTrack.StateObject_NewState.ObjectID, VisualizeGameState);
        if (OtherUnit != none)
        {
            // Wait for smoke
            Delay = X2Action_Delay(`InsertTrackAction(OtherTrack, 1, class'X2Action_Delay', Context));
            Delay.Duration = 1.5;
            Delay.bIgnoreZipMode = true;

            // Cloak.
            `InsertTrackAction(OtherTrack, 2, class'X2Action_SpookSetMaterial', Context);

            // Wait for cloak.
            Delay = X2Action_Delay(`InsertTrackAction(OtherTrack, 3, class'X2Action_Delay', Context));
            Delay.Duration = 1.5;
            Delay.bIgnoreZipMode = true;
        }

        // Replace the modified track.
        OutVisualizationTracks[TrackIndex] = OtherTrack;
    }

    // Master track waits for smoke.
    Delay = X2Action_Delay(`InsertTrackAction(Track, ActionIndex++, class'X2Action_Delay', Context));
    Delay.Duration = 1.5;
    Delay.bIgnoreZipMode = true;

    // Master track cloaks.
    `InsertTrackAction(Track, ActionIndex++, class'X2Action_SpookSetMaterial', Context);
    if (default.SHADE_SOUND_EFFECTS)
    {
        PlayAkEvent = X2Action_SpookPlayAkEvent(`InsertTrackAction(Track, ActionIndex++, class'X2Action_SpookPlayAkEvent', Context));
        PlayAkEvent.EventToPlay = AkEvent'SoundX2CharacterFX.MimicBeaconActivate';
    }

    // Master track waits for cloak.
    Delay = X2Action_Delay(`InsertTrackAction(Track, ActionIndex++, class'X2Action_Delay', Context));
    Delay.Duration = 1.5;
    Delay.bIgnoreZipMode = true;

    // Re/add the (new, or removed) master track now we've made all local changes.
    OutVisualizationTracks.AddItem(Track);

    // Everyone vanishes.
    for (TrackIndex = 0; TrackIndex < OutVisualizationTracks.Length; ++TrackIndex)
    {
        OtherTrack = OutVisualizationTracks[TrackIndex];

        OtherUnit = `FindUnitState(OtherTrack.StateObject_NewState.ObjectID, VisualizeGameState);
        if (OtherUnit == none)
        {
            // Only units.
            continue;
        }

        // Hide the pawn explicitly.
        class'X2Action_RemoveUnit'.static.AddToVisualizationTrack(OtherTrack, Context);

        // Then the master track pauses for effect.
        if (OtherTrack.StateObject_NewState.ObjectID == Track.StateObject_NewState.ObjectID)
        {
            // OtherTrack *is* the master track here; the Track local variable is out of date.
            Delay = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTrack(OtherTrack, Context));
            Delay.Duration = 2.0;
            Delay.bIgnoreZipMode = true;
        }

        // Replace the modified track.
        OutVisualizationTracks[TrackIndex] = OtherTrack;
    }
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
    local X2Condition_UnitProperty              TargetPropertyCondition;
    local X2Condition_Spook                     TargetSpecialCondition;
    local X2AbilityTarget_Single                SingleTarget;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Eclipse');

    Template.AbilitySourceName = 'eAbilitySource_Standard';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
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
    Template.AbilityCosts.AddItem(ActionPointCost);

    SingleTarget = new class'X2AbilityTarget_Single';
    Template.AbilityTargetStyle = SingleTarget;

    TargetPropertyCondition = new class'X2Condition_UnitProperty';
    TargetPropertyCondition.ExcludeFriendlyToSource = false;
    TargetPropertyCondition.FailOnNonUnits = true;
    TargetPropertyCondition.ExcludeDead = true;
    TargetPropertyCondition.ExcludeAlien = true;
    TargetPropertyCondition.ExcludeRobotic = true;
    TargetPropertyCondition.ExcludeHostileToSource = true;
    TargetPropertyCondition.RequireWithinRange = true;
    TargetPropertyCondition.WithinRange = 144; // 1 tile
    Template.AbilityTargetConditions.AddItem(TargetPropertyCondition);

    TargetSpecialCondition = new class'X2Condition_Spook';
    TargetSpecialCondition.bRequireConscious = true;
    TargetSpecialCondition.bRequireNotBleedingOut = true;
    Template.AbilityTargetConditions.AddItem(TargetSpecialCondition);

    Template.AddTargetEffect(CreateEclipsedStatusEffect());

    Template.ActivationSpeech = 'StabilizingAlly';
    Template.bShowActivation = true;

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = class'X2Ability_DefaultAbilitySet'.static.Knockout_BuildVisualization;
    Template.BuildAffectedVisualizationSyncFn = class'X2Ability_DefaultAbilitySet'.static.Knockout_BuildAffectedVisualizationSync;

    return Template;
}

static function X2AbilityTemplate AddPistolStatBonusAbility()
{
    local X2AbilityTemplate                 Template;
    local X2Effect_PersistentStatChange     PersistentStatChangeEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Pistol_StatBonus');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_unknown";

    Template.AbilitySourceName = 'eAbilitySource_Item';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
    Template.bDisplayInUITacticalText = false;

    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

    // Bonus to Mobility and DetectionRange stat effects
    PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
    PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
    PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, "", "", Template.IconImage, false,, Template.AbilitySourceName);
    PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, class'X2Item_SpookWeapons'.default.PISTOL_MOBILITY_BONUS);
    PersistentStatChangeEffect.AddPersistentStatChange(eStat_DetectionModifier, class'X2Item_SpookWeapons'.default.PISTOL_DETECTION_MODIFIER);
    Template.AddTargetEffect(PersistentStatChangeEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}

static function X2AbilityTemplate AddDartAbility()
{
    local X2AbilityTemplate             Template;
    local X2Condition_Visibility        RequireVisibleCondition;
    local X2Condition_UnitProperty      NoRobotsCondition;
    local X2AbilityCost_ActionPoints    ActionPointCost;
    local X2AbilityCharges              Charges;
    local X2Effect_ApplyWeaponDamage    DamageEffect;
    local X2Effect_SpookUngroupAI       UngroupEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Dart');

    Template.bDontDisplayInAbilitySummary = false;
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_bloodcall";
    Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_PISTOL_SHOT_PRIORITY;
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
    Template.DisplayTargetHitChance = true;
    Template.AbilitySourceName = 'eAbilitySource_Standard';
    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
    Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;

    Template.AbilityTargetStyle = new class'X2AbilityTarget_Single'; // No destructibles.
    Template.AbilityToHitCalc = default.SimpleStandardAim;
    Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;
    Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
    Template.bLimitTargetIcons = true; // Just the ones we can dart.
    Template.bUsesFiringCamera = true;
    Template.CinescriptCameraType = "StandardGunFiring";

    Template.ConcealmentRule = eConceal_Always;
    Template.bSilentAbility = true;
    Template.Hostility = eHostility_Neutral;
    Template.bAllowFreeFireWeaponUpgrade = true;

    AbilityRequiresSpookShooter(Template);
    Template.AddShooterEffectExclusions();

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

    if (default.DART_CHARGES > 0)
    {
        Charges = new class'X2AbilityCharges';
        Charges.InitialCharges = default.DART_CHARGES;
        Template.AbilityCharges = Charges;
        Template.AbilityCosts.AddItem(new class'X2AbilityCost_Charges');
    }

    // Can cause a holotarget to be applied
    Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
    Template.AssociatedPassives.AddItem('HoloTargeting');
    // (Cannot shred even if the shooter can, so we don't add that effect.)

    // Damage
    DamageEffect = new class'X2Effect_ApplyWeaponDamage';
    DamageEffect.bIgnoreBaseDamage = true;
    DamageEffect.bAllowWeaponUpgrade = false;
    DamageEffect.DamageTag = 'Spook_Dart';
    Template.AddTargetEffect(DamageEffect);
    Template.bAllowBonusWeaponEffects = false;
    Template.bAllowAmmoEffects = false;

    // Bleed
    Template.AddTargetEffect(class'X2Effect_SpookBleeding'.static.CreateBleedingStatusEffect(class'X2Item_SpookDamageTypes'.const.StealthBleedDamageTypeName, default.DART_BLEED_TURNS, default.DART_BLEED_DAMAGE_PER_TICK, default.DART_BLEED_DAMAGE_SPREAD_PER_TICK, default.DART_BLEED_DAMAGE_PLUSONE_PER_TICK));

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
        // If they don't, we want to worry them. We don't want red alert
        // behaviour, which other code suppresses
        // (DetectionManager.OnUnitTakeEffectDamage), but we do want them
        // alerted, as if by a bad sound.
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

static function X2AbilityTemplate AddExeuntAbility()
{
    local X2AbilityTemplate Template;
    Template = PurePassive(ExeuntAbilityName, "img:///Spook.UIPerk_exeunt");
    // Implemented by UIScreenListener_TacticalHUD_Spook.OnGetEvacPlacementDelay().
    return Template;
}

static function X2AbilityTemplate AddSurgeonAbility()
{
    local X2AbilityTemplate                     Template;
    local X2Effect_BonusWeaponDamage            DamageEffect;
    local X2Effect_ToHitModifier                HitModEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'Spook_Surgeon');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_momentum";

    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;

    Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

    DamageEffect = new class'X2Effect_BonusWeaponDamage';
    DamageEffect.BonusDmg = default.SURGEON_DAMAGE;
    DamageEffect.BuildPersistentEffect(1, true, false, false);
    DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,, Template.AbilitySourceName);
    Template.AddTargetEffect(DamageEffect);

    HitModEffect = new class'X2Effect_ToHitModifier';
    HitModEffect.AddEffectHitModifier(eHit_Success, default.SURGEON_AIM, Template.LocFriendlyName, , true, false, true, true);
    HitModEffect.BuildPersistentEffect(1, true, false, false);
    HitModEffect.EffectName = 'SurgeonAim';
    Template.AddTargetEffect(HitModEffect);

    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

    return Template;
}
