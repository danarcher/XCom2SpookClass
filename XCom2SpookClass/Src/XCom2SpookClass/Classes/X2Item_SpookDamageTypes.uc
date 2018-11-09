class X2Item_SpookDamageTypes
    extends X2Item
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> DamageTypes;
    DamageTypes.AddItem(CreateSpookBleedDamageType());
    return DamageTypes;
}

static function X2DamageTypeTemplate CreateSpookBleedDamageType()
{
    local X2DamageTypeTemplate Template;

    `CREATE_X2TEMPLATE(class'X2DamageTypeTemplate', Template, 'SpookBleedDamageType');

    Template.bCauseFracture = false;
    Template.MaxFireCount = 0;
    Template.bAllowAnimatedDeath = true;

    return Template;
}
