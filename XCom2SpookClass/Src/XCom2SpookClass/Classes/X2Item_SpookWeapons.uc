class X2Item_SpookWeapons
    extends X2Item
    config(Spook);

var config WeaponDamageValue PISTOL_CONVENTIONAL_BASEDAMAGE;
var config WeaponDamageValue PISTOL_LASER_BASEDAMAGE;
var config WeaponDamageValue PISTOL_MAGNETIC_BASEDAMAGE;
var config WeaponDamageValue PISTOL_COIL_BASEDAMAGE;
var config WeaponDamageValue PISTOL_BEAM_BASEDAMAGE;

var config int PISTOL_CONVENTIONAL_AIM;
var config int PISTOL_CONVENTIONAL_CRITCHANCE;
var config int PISTOL_CONVENTIONAL_ICLIPSIZE;
var config int PISTOL_CONVENTIONAL_ISOUNDRANGE;
var config int PISTOL_CONVENTIONAL_IENVIRONMENTDAMAGE;
var config int PISTOL_CONVENTIONAL_ISUPPLIES;
var config int PISTOL_CONVENTIONAL_TRADINGPOSTVALUE;
var config int PISTOL_CONVENTIONAL_IPOINTS;

var config int PISTOL_LASER_AIM;
var config int PISTOL_LASER_CRITCHANCE;
var config int PISTOL_LASER_ICLIPSIZE;
var config int PISTOL_LASER_ISOUNDRANGE;
var config int PISTOL_LASER_IENVIRONMENTDAMAGE;
var config int PISTOL_LASER_ISUPPLIES;
var config int PISTOL_LASER_TRADINGPOSTVALUE;
var config int PISTOL_LASER_IPOINTS;

var config int PISTOL_MAGNETIC_AIM;
var config int PISTOL_MAGNETIC_CRITCHANCE;
var config int PISTOL_MAGNETIC_ICLIPSIZE;
var config int PISTOL_MAGNETIC_ISOUNDRANGE;
var config int PISTOL_MAGNETIC_IENVIRONMENTDAMAGE;
var config int PISTOL_MAGNETIC_ISUPPLIES;
var config int PISTOL_MAGNETIC_TRADINGPOSTVALUE;
var config int PISTOL_MAGNETIC_IPOINTS;

var config int PISTOL_COIL_AIM;
var config int PISTOL_COIL_CRITCHANCE;
var config int PISTOL_COIL_ICLIPSIZE;
var config int PISTOL_COIL_ISOUNDRANGE;
var config int PISTOL_COIL_IENVIRONMENTDAMAGE;
var config int PISTOL_COIL_ISUPPLIES;
var config int PISTOL_COIL_TRADINGPOSTVALUE;
var config int PISTOL_COIL_IPOINTS;

var config int PISTOL_BEAM_AIM;
var config int PISTOL_BEAM_CRITCHANCE;
var config int PISTOL_BEAM_ICLIPSIZE;
var config int PISTOL_BEAM_ISOUNDRANGE;
var config int PISTOL_BEAM_IENVIRONMENTDAMAGE;
var config int PISTOL_BEAM_ISUPPLIES;
var config int PISTOL_BEAM_TRADINGPOSTVALUE;
var config int PISTOL_BEAM_IPOINTS;

var config array<int> SHORT_RANGE;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    Templates.AddItem(CreatePistolCV());
    Templates.AddItem(CreatePistolLS());
    Templates.AddItem(CreatePistolMG());
    Templates.AddItem(CreatePistolCG());
    Templates.AddItem(CreatePistolBM());
    return Templates;
}

static function X2WeaponTemplate CreatePistolBase(name TemplateName, int Tier)
{
    local X2WeaponTemplate Template;

    `CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, TemplateName);
    Template.WeaponPanelImage = "_Pistol";
    Template.ItemCat = 'weapon';
    Template.WeaponCat = 'spookpistol';
    Template.InventorySlot = eInvSlot_PrimaryWeapon;
    Template.Tier = Tier;
    Template.InfiniteAmmo = true;
    Template.bHideClipSizeStat = true;
    Template.NumUpgradeSlots = 3;
    Template.StartingItem = Tier == 0;
    Template.CanBeBuilt = false;
    Template.bInfiniteItem = Template.StartingItem;
    Template.RangeAccuracy = default.SHORT_RANGE;
    Template.iPhysicsImpulse = 5;
    Template.fKnockbackDamageAmount = 5.0f;
    Template.fKnockbackDamageRadius = 0.0f;
    Template.DamageTypeTemplateName = class'X2Item_SpookDamageTypes'.const.PrecisionProjectileDamageTypeName;

    //Template.OverwatchActionPoint = class'X2CharacterTemplateManager'.default.PistolOverwatchReserveActionPoint;

    Template.Abilities.AddItem('StandardShot_NoEnd');
    Template.Abilities.AddItem('Overwatch');
    Template.Abilities.AddItem('OverwatchShot');
    Template.Abilities.AddItem('Reload');
    Template.Abilities.AddItem('HotLoadAmmo');
    Template.Abilities.AddItem('Spook_Dart'); // Requires ExtraDamage from DART_[tech]_DAMAGE at each weapon tech.

    Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
    //Template.SetAnimationNameForAbility('FanFire', 'FF_FireMultiShotConvA');

    return Template;
}

//static function MakeBuildable(X2WeaponTemplate Template, name RequiredTech, int SupplyCost, int AlloyCost, int CrystalCost)
//{
//    local ArtifactCost Supplies, Alloys, Crystals;
//
//    Template.StartingItem = false;
//    Template.CanBeBuilt = true;
//    Template.bInfiniteItem = false;
//
//    Template.Requirements.RequiredTechs.AddItem(RequiredTech); // LaserWeapons, MagnetizedWeapons, PlasmaRifle
//
//    if (SupplyCost > 0)
//    {
//        Supplies.ItemTemplateName = 'Supplies';
//        Supplies.Quantity = SupplyCost;
//        Template.Cost.ResourceCosts.AddItem(Supplies);
//    }
//    if (AlloyCost > 0)
//    {
//        Alloys.ItemTemplateName = 'AlienAlloy';
//        Alloys.Quantity = AlloyCost;
//        Template.Cost.ResourceCosts.AddItem(Alloys);
//    }
//    if (CrystalCost > 0)
//    {
//        Crystals.ItemTemplateName = 'EleriumDust';
//        Crystals.Quantity = CrystalCost;
//        Template.Cost.ResourceCosts.AddItem(Crystals);
//    }
//}

static function X2DataTemplate CreatePistolCV()
{
    local X2WeaponTemplate Template;

    Template = CreatePistolBase('SpookPistol_CV', 0);

    Template.WeaponTech = 'conventional';
    Template.strImage = "img:///UILibrary_Common.ConvSecondaryWeapons.ConvPistol";
    Template.EquipSound = "Secondary_Weapon_Equip_Conventional";

    Template.BaseDamage = default.PISTOL_CONVENTIONAL_BASEDAMAGE;
    Template.Aim = default.PISTOL_CONVENTIONAL_AIM;
    Template.CritChance = default.PISTOL_CONVENTIONAL_CRITCHANCE;
    Template.iClipSize = default.PISTOL_CONVENTIONAL_ICLIPSIZE;
    Template.iSoundRange = default.PISTOL_CONVENTIONAL_ISOUNDRANGE;
    Template.iEnvironmentDamage = default.PISTOL_CONVENTIONAL_IENVIRONMENTDAMAGE;
    Template.ExtraDamage.AddItem(class'X2Ability_SpookAbilitySet'.default.DART_CONVENTIONAL_DAMAGE);

    // This all the resources; sounds, animations, models, physics, the works.
    Template.GameArchetype = "Spook.WP_SpookPistol_CV";


    return Template;
}

static function X2DataTemplate CreatePistolLS()
{
    local X2WeaponTemplate Template;

    Template = CreatePistolBase('SpookPistol_LS', 2);

    Template.WeaponTech = 'pulse';
    Template.strImage = "img:///UILibrary_LW_LaserPack.Inv_Laser_Pistol";
    Template.EquipSound = "Secondary_Weapon_Equip_Magnetic";

    Template.BaseDamage = default.PISTOL_LASER_BASEDAMAGE;
    Template.Aim = default.PISTOL_LASER_AIM;
    Template.CritChance = default.PISTOL_LASER_CRITCHANCE;
    Template.iClipSize = default.PISTOL_LASER_ICLIPSIZE;
    Template.iSoundRange = default.PISTOL_LASER_ISOUNDRANGE;
    Template.iEnvironmentDamage = default.PISTOL_LASER_IENVIRONMENTDAMAGE;
    Template.ExtraDamage.AddItem(class'X2Ability_SpookAbilitySet'.default.DART_LASER_DAMAGE);

    Template.GameArchetype = "LWPistol_LS.Archetype.WP_Pistol_LS";


    return Template;
}

static function X2DataTemplate CreatePistolMG()
{
    local X2WeaponTemplate Template;

    Template = CreatePistolBase('SpookPistol_MG', 3);

    Template.WeaponTech = 'magnetic';
    Template.strImage = "img:///UILibrary_Common.MagSecondaryWeapons.MagPistol";
    Template.EquipSound = "Secondary_Weapon_Equip_Magnetic";

    Template.BaseDamage = default.PISTOL_MAGNETIC_BASEDAMAGE;
    Template.Aim = default.PISTOL_MAGNETIC_AIM;
    Template.CritChance = default.PISTOL_MAGNETIC_CRITCHANCE;
    Template.iClipSize = default.PISTOL_MAGNETIC_ICLIPSIZE;
    Template.iSoundRange = default.PISTOL_MAGNETIC_ISOUNDRANGE;
    Template.iEnvironmentDamage = default.PISTOL_MAGNETIC_IENVIRONMENTDAMAGE;
    Template.ExtraDamage.AddItem(class'X2Ability_SpookAbilitySet'.default.DART_MAGNETIC_DAMAGE);

    Template.GameArchetype = "WP_Pistol_MG.WP_Pistol_MG";


    return Template;
}

static function X2DataTemplate CreatePistolCG()
{
    local X2WeaponTemplate Template;

    Template = CreatePistolBase('SpookPistol_CG', 4);

    Template.WeaponTech = 'coilgun_lw';
    Template.strImage = "img:///UILibrary_LW_Overhaul.InventoryArt.Inv_Coil_Pistol";
    Template.EquipSound = "Secondary_Weapon_Equip_Magnetic";

    Template.BaseDamage = default.PISTOL_COIL_BASEDAMAGE;
    Template.Aim = default.PISTOL_COIL_AIM;
    Template.CritChance = default.PISTOL_COIL_CRITCHANCE;
    Template.iClipSize = default.PISTOL_COIL_ICLIPSIZE;
    Template.iSoundRange = default.PISTOL_COIL_ISOUNDRANGE;
    Template.iEnvironmentDamage = default.PISTOL_COIL_IENVIRONMENTDAMAGE;
    Template.ExtraDamage.AddItem(class'X2Ability_SpookAbilitySet'.default.DART_COIL_DAMAGE);

    Template.GameArchetype = "LWPistol_CG.Archetypes.WP_Pistol_CG";


    return Template;
}

static function X2DataTemplate CreatePistolBM()
{
    local X2WeaponTemplate Template;

    Template = CreatePistolBase('SpookPistol_BM', 5);

    Template.WeaponTech = 'beam';
    Template.strImage = "img:///UILibrary_Common.BeamSecondaryWeapons.BeamPistol";
    Template.EquipSound = "Secondary_Weapon_Equip_Beam";

    Template.BaseDamage = default.PISTOL_BEAM_BASEDAMAGE;
    Template.Aim = default.PISTOL_BEAM_AIM;
    Template.CritChance = default.PISTOL_BEAM_CRITCHANCE;
    Template.iClipSize = default.PISTOL_BEAM_ICLIPSIZE;
    Template.iSoundRange = default.PISTOL_BEAM_ISOUNDRANGE;
    Template.iEnvironmentDamage = default.PISTOL_BEAM_IENVIRONMENTDAMAGE;
    Template.ExtraDamage.AddItem(class'X2Ability_SpookAbilitySet'.default.DART_BEAM_DAMAGE);

    Template.GameArchetype = "WP_Pistol_BM.WP_Pistol_BM";

    return Template;
}
