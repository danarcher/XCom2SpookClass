class X2StrategyElement_SpookAcademyUnlocks
    extends X2StrategyElement
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    `SPOOKSLOG("Creating new GTS perks");
    Templates.AddItem(ExeuntUnlock());
    Templates.AddItem(OperatorUnlock());

    return Templates;
}

static function OnPostTemplatesCreated()
{
    local array<X2DataTemplate> DataTemplates;
    local X2DataTemplate DataTemplate;
    local X2FacilityTemplate Template;

    `XSTRATEGYELEMENTMANAGER.FindDataTemplateAllDifficulties('OfficerTrainingSchool', DataTemplates);
    foreach DataTemplates(DataTemplate)
    {
        Template = X2FacilityTemplate(DataTemplate);
        if (Template != none)
        {
            `SPOOKSLOG("Adding new GTS perks to GTS " $ DataTemplate.TemplateAvailability);
            Template.SoldierUnlockTemplates.AddItem('Spook_ExeuntUnlock');
            Template.SoldierUnlockTemplates.AddItem('Spook_OperatorUnlock');
        }
    }
}

static function X2SoldierAbilityUnlockTemplate ExeuntUnlock()
{
    local X2SoldierAbilityUnlockTemplate Template;
    local ArtifactCost Resources;

    `CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, 'Spook_ExeuntUnlock');

    Template.AllowedClasses.AddItem('Spook');
    Template.AbilityName = class'X2Ability_SpookAbilitySet'.const.ExeuntAbilityName;
    Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_LightningStrike";

    // Requirements
    Template.Requirements.RequiredHighestSoldierRank = 3;
    Template.Requirements.RequiredSoldierClass = 'Spook';
    Template.Requirements.RequiredSoldierRankClassCombo = true;
    Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

    // Cost
    Resources.ItemTemplateName = 'Supplies';
    Resources.Quantity = 15;
    Template.Cost.ResourceCosts.AddItem(Resources);

    return Template;
}

static function X2SoldierAbilityUnlockTemplate OperatorUnlock()
{
    local X2SoldierAbilityUnlockTemplate Template;
    local ArtifactCost Resources;

    `CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, 'Spook_OperatorUnlock');

    Template.AllowedClasses.AddItem('Spook');
    Template.AbilityName = class'X2Ability_SpookOperatorAbilitySet'.const.OperatorAbilityName;
    Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_LightningStrike";

    // Requirements
    Template.Requirements.RequiredHighestSoldierRank = 5;
    Template.Requirements.RequiredSoldierClass = 'Spook';
    Template.Requirements.RequiredSoldierRankClassCombo = true;
    Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

    // Cost
    Resources.ItemTemplateName = 'Supplies';
    Resources.Quantity = 25;
    Template.Cost.ResourceCosts.AddItem(Resources);

    return Template;
}
