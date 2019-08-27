class X2Item_SpookDamageTypes
    extends X2Item
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

const BleedDamageTypeName = 'SpookBleedDamageType';
const StealthBleedDamageTypeName = 'SpookStealthBleedDamageType';
const PrecisionProjectileDamageTypeName = 'SpookPrecisionProjectileDamageType';

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> DamageTypes;
    DamageTypes.AddItem(CreateDamageType(BleedDamageTypeName));
    DamageTypes.AddItem(CreateDamageType(StealthBleedDamageTypeName));
    DamageTypes.AddItem(CreateDamageType(PrecisionProjectileDamageTypeName));
    return DamageTypes;
}

static function X2DamageTypeTemplate CreateDamageType(name DataName)
{
    local X2DamageTypeTemplate Template;

    `CREATE_X2TEMPLATE(class'X2DamageTypeTemplate', Template, DataName);

    Template.bCauseFracture = false;
    Template.MaxFireCount = 0;
    Template.bAllowAnimatedDeath = true;

    return Template;
}
