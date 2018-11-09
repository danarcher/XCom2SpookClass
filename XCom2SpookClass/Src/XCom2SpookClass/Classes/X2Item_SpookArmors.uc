class X2Item_SpookArmors
    extends X2Item
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Armors;

    Armors.AddItem(CreateSpookArmor());
    return Armors;
}

static function X2DataTemplate CreateSpookArmor()
{
    local X2ArmorTemplate Template;

    `CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'SpookArmorConventional');
    Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Kevlar_Armor";
    Template.ItemCat = 'armor';
    Template.StartingItem = true;
    Template.CanBeBuilt = false;
    Template.bInfiniteItem = true;
    Template.Tier = 0;
    Template.EquipSound = "StrategyUI_Armor_Equip_Conventional";

    Template.bHeavyWeapon = false;
    Template.bAddsUtilitySlot = true;
    Template.ArmorTechCat = 'conventional';
    Template.AkAudioSoldierArmorSwitch = 'Conventional';
    Template.ArmorCat = 'SpookArmor';

    Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, 0, true);

    return Template;
}
