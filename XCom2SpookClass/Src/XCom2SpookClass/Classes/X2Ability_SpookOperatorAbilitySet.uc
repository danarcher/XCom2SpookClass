class X2Ability_SpookOperatorAbilitySet
    extends X2Ability
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var array<X2AbilityTemplate> SpecialTemplates;

var config string ICON_COLOR_OBJECTIVE;
var config string ICON_COLOR_FREE;

const OperatorAbilityName = 'Spook_Operator';

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    Templates.AddItem(AddOperatorAbility());
    return Templates;
}

static function X2AbilityTemplate AddOperatorAbility()
{
    local X2AbilityTemplate Template;
    // Implemented by X2Ability_SpookOperatorAbilitySet().
    Template = PurePassive(OperatorAbilityName, "img:///Spook.UIPerk_operator");
    return Template;
}

function OnPostTemplatesCreated()
{
    local array<X2DataTemplate> DataTemplates;
    local X2CharacterTemplate CharacterTemplate;
    local X2DataTemplate DataTemplate;
    local X2AbilityTemplate ExistingTemplate, NewTemplate;

    // Rebels can be carried.
    `XCHARACTERMANAGER.FindDataTemplateAllDifficulties('Rebel', DataTemplates);
    foreach DataTemplates(DataTemplate)
    {
        CharacterTemplate = X2CharacterTemplate(DataTemplate);
        if (CharacterTemplate != none)
        {
            CharacterTemplate.bCanBeCarried = true;
            `SPOOKSLOG("Rebels " $ CharacterTemplate.TemplateAvailability $ " can be carried");
        }
    }

    // Operator abilities.
    foreach `XABILITYMANAGER.IterateTemplates(DataTemplate, none)
    {
        ExistingTemplate = X2AbilityTemplate(DataTemplate);
        NewTemplate = none;
        switch (ExistingTemplate.DataName)
        {
            case 'Interact':
            case 'Interact_OpenDoor':
            case 'Interact_OpenChest':
                NewTemplate = class'X2Ability_DefaultAbilitySet'.static.AddInteractAbility(ExistingTemplate.DataName);
                break;
            case 'Interact_PlantBomb':
                NewTemplate = class'X2Ability_DefaultAbilitySet'.static.AddPlantBombAbility();
                break;
            case 'Interact_TakeVial':
            case 'Interact_StasisTube':
            case 'Interact_SmashNGrab': // Deliberately bypass LW amendments (item count checks).
                NewTemplate = class'X2Ability_DefaultAbilitySet'.static.AddObjectiveInteractAbility(ExistingTemplate.DataName);
                break;
            case 'Hack':
            case 'Hack_Chest':
                NewTemplate = class'X2Ability_DefaultAbilitySet'.static.AddHackAbility(ExistingTemplate.DataName);
                break;
            case 'Hack_Workstation':
            case 'Hack_ObjectiveChest':
                NewTemplate = class'X2Ability_DefaultAbilitySet'.static.AddObjectiveHackAbility(ExistingTemplate.DataName);
                break;
            case 'FinalizeHack':
                NewTemplate = class'X2Ability_DefaultAbilitySet'.static.FinalizeHack();
                break;
            case 'GatherEvidence':
                NewTemplate = class'X2Ability_DefaultAbilitySet'.static.AddGatherEvidenceAbility();
                break;
            case 'PlantExplosiveMissionDevice':
                NewTemplate = class'X2Ability_DefaultAbilitySet'.static.AddPlantExplosiveMissionDeviceAbility();
                break;
            case 'Knockout':
                NewTemplate = X2AbilityTemplate(class'X2Ability_DefaultAbilitySet'.static.AddKnockoutAbility());
                break;
            case 'Spook_Eclipse':
                NewTemplate = class'X2Ability_SpookAbilitySet'.static.AddEclipseAbility();
                break;
            case 'CarryUnit':
                NewTemplate = class'X2Ability_CarryUnit'.static.CarryUnit();
                break;
            case 'PutDownUnit':
                NewTemplate = X2AbilityTemplate(class'X2Ability_CarryUnit'.static.PutDownUnit());
                break;
        }

        if (NewTemplate == none)
        {
            continue;
        }

        // The ability is free to operators (no action points nor charges).
        NewTemplate.AbilityCosts.Remove(0, NewTemplate.AbilityCosts.Length);

        // LW won't fix the color for us since it can't see this template.
        NewTemplate.AbilityIconColor = (NewTemplate.ShotHUDPriority == class'UIUtilities_Tactical'.const.OBJECTIVE_INTERACT_PRIORITY) ? default.ICON_COLOR_OBJECTIVE : default.ICON_COLOR_FREE;

        // Just in case, this isn't offensive from an operator.
        NewTemplate.Hostility = eHostility_Neutral;

        // Kismet notwithstanding, retain operator concealment.
        NewTemplate.ConcealmentRule = eConceal_Always;

        SpecialTemplates.AddItem(NewTemplate);
    }
}

static function bool IsOperator(XComGameState_Unit Unit)
{
    return Unit != none && Unit.FindAbility(OperatorAbilityName).ObjectID != 0;
}

function FinalizeUnitAbilitiesForInit(XComGameState_Unit Unit, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
    local int SetupIndex, TemplateIndex;
    local AbilitySetupData Entry;
    local X2AbilityTemplate OperatorTemplate;
    local bool bModified;

    if (!IsOperator(Unit))
    {
        return;
    }

    // Replace Operators' abilities with special versions where necessary.
    for (SetupIndex = 0; SetupIndex < SetupData.Length; ++SetupIndex)
    {
        Entry = SetupData[SetupIndex];
        bModified = false;

        for (TemplateIndex = 0; TemplateIndex < SpecialTemplates.Length; ++TemplateIndex)
        {
            OperatorTemplate = SpecialTemplates[TemplateIndex];
            if (OperatorTemplate.DataName == Entry.TemplateName)
            {
                `SPOOKLOG("Replacing " $ Entry.TemplateName $ "with Operator equivalent for " $ Unit.GetFullName());
                Entry.Template = OperatorTemplate;
                bModified = true;
            }
        }

        if (bModified)
        {
            SetupData[SetupIndex] = Entry;
        }
    }
}

function bool CanAddItemToInventory(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit Unit, XComGameState CheckGameState)
{
    // Allow Spooks with Operator to ignore the eSlot_Mission limit of 1 item.
    // We could modify the item template to eSlot_Backpack, but then we'd have to disallow other units instead.
    if (ItemTemplate.DataName == 'SmashNGrabQuestItem' && Unit.GetSoldierClassTemplateName() == 'Spook')
    {
        `SPOOKSLOG(Unit.GetSoldierClassTemplateName() $ " can always carry " $ ItemTemplate.DataName);
        bCanAddItem = 1;
        return true;
    }
    return false;
}
