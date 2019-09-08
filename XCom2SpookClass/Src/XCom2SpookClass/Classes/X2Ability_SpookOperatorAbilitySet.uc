class X2Ability_SpookOperatorAbilitySet
    extends X2Ability
    config(Spook);

static function CreateOperatorTemplates(out array<X2AbilityTemplate> Templates)
{
    Templates.AddItem(AddInteractSmashNGrabAbility());
}

static function SetFreeCost(X2AbilityTemplate Template)
{
    local X2AbilityCost_ActionPoints ActionPoints;

    Template.AbilityCosts.Remove(0, Template.AbilityCosts.Length);

    ActionPoints = new class'X2AbilityCost_ActionPoints';
    ActionPoints.iNumPoints = 0;
    ActionPoints.bFreeCost = true;
    Template.AbilityCosts.AddItem(ActionPoints);
}

static function SetIconColor(X2AbilityTemplate Template, string IconColor)
{
    if (IconColor != "")
    {
        Template.AbilityIconColor = IconColor;
    }
}

static function X2AbilityTemplate AddInteractSmashNGrabAbility()
{
    local X2AbilityTemplate Template;

    Template = class'X2Ability_DefaultAbilitySet'.static.AddInteractAbility('Interact_SmashNGrab');
    SetFreeCost(Template);

    // Since LW doesn't get to modify this template.
    SetIconColor(Template, class'XComConfig_LW_Overhaul'.default.ICON_COLOR_OBJECTIVE);

    return Template;
}
