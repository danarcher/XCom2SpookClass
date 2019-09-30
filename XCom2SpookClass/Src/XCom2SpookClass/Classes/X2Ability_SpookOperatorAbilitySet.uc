class X2Ability_SpookOperatorAbilitySet
    extends X2Ability
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var config bool OVERRIDE_OPERATOR_ABILITY_ICON_COLORS;
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

static function OnPostTemplatesCreated()
{
    local array<X2DataTemplate> DataTemplates;
    local X2CharacterTemplate CharacterTemplate;
    local X2DataTemplate DataTemplate;
    local X2AbilityTemplate ExistingTemplate;
    local int iItem, iName;
    local X2AbilityCost_ActionPoints ActionPoints;
    local X2AbilityCost_SpookOperatorActionPoints OperatorActionPoints;
    local bool bBreaksConcealment;
    local X2Effect_BreakUnitConcealmentUnlessSpookOperator BreakConcealment;
    local X2Effect_SpookOperatorSentinel Sentinel;

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
        switch (ExistingTemplate.DataName)
        {
            case 'Interact':
            case 'Interact_OpenDoor':
            case 'Interact_OpenChest':
            case 'Interact_PlantBomb':
            case 'Interact_TakeVial':
            case 'Interact_StasisTube':
            case 'Interact_SmashNGrab': // Deliberately bypass LW amendments (item count checks).
            case 'Hack':
            case 'Hack_Chest':
            case 'Hack_Workstation':
            case 'Hack_ObjectiveChest':
            case 'FinalizeHack':
            case 'GatherEvidence':
            case 'PlantExplosiveMissionDevice':
            case 'Knockout':
            case 'Spook_Eclipse':
            case 'CarryUnit':
            case 'PutDownUnit':
                for (iItem = 0; iItem < ExistingTemplate.AbilityCosts.Length; ++iItem)
                {
                    ActionPoints = X2AbilityCost_ActionPoints(ExistingTemplate.AbilityCosts[iItem]);
                    if (ActionPoints != none)
                    {
                        `SPOOKSLOG("Overriding action point cost for Operators using " $ ExistingTemplate.DataName);
                        OperatorActionPoints = new class'X2AbilityCost_SpookOperatorActionPoints';

                        OperatorActionPoints.bFreeCost = ActionPoints.bFreeCost;
                        OperatorActionPoints.iNumPoints = ActionPoints.iNumPoints;
                        OperatorActionPoints.bAddWeaponTypicalCost = ActionPoints.bAddWeaponTypicalCost;
                        OperatorActionPoints.bConsumeAllPoints = ActionPoints.bConsumeAllPoints;
                        OperatorActionPoints.bMoveCost = ActionPoints.bMoveCost;

                        for (iName = 0; iName < ActionPoints.AllowedTypes.Length; ++iName)
                        {
                            OperatorActionPoints.AllowedTypes.AddItem(ActionPoints.AllowedTypes[iName]);
                        }
                        for (iName = 0; iName < ActionPoints.DoNotConsumeAllEffects.Length; ++iName)
                        {
                            OperatorActionPoints.DoNotConsumeAllEffects.AddItem(ActionPoints.DoNotConsumeAllEffects[iName]);
                        }
                        for (iName = 0; iName < ActionPoints.DoNotConsumeAllSoldierAbilities.Length; ++iName)
                        {
                            OperatorActionPoints.DoNotConsumeAllSoldierAbilities.AddItem(ActionPoints.DoNotConsumeAllSoldierAbilities[iName]);
                        }

                        ExistingTemplate.AbilityCosts[iItem] = OperatorActionPoints;
                    }
                }

                if (ExistingTemplate.Hostility == eHostility_Offensive || ExistingTemplate.ConcealmentRule == eConceal_Never)
                {
                    bBreaksConcealment = true;
                }

                if (bBreaksConcealment)
                {
                    `SPOOKSLOG("Overriding concealment break for Operators using " $ ExistingTemplate.DataName);
                    ExistingTemplate.Hostility = eHostility_Neutral;
                    ExistingTemplate.ConcealmentRule = eConceal_Always;
                    BreakConcealment = new class'X2Effect_BreakUnitConcealmentUnlessSpookOperator';
                    ExistingTemplate.AddShooterEffect(BreakConcealment);
                }

                // Flag as Operator-sensitive
                `SPOOKSLOG("Flagging potential Operator ability " $ ExistingTemplate.DataName);
                Sentinel = new class'X2Effect_SpookOperatorSentinel';
                switch (ExistingTemplate.DataName)
                {
                    case 'Interact_PlantBomb':
                    case 'Interact_TakeVial':
                    case 'Interact_StasisTube':
                    case 'Interact_SmashNGrab': // Deliberately bypass LW amendments (item count checks).
                    case 'Hack_Workstation':
                    case 'Hack_ObjectiveChest':
                    case 'GatherEvidence':
                    case 'PlantExplosiveMissionDevice':
                        Sentinel.bObjective = true;
                        break;
                }
                ExistingTemplate.AddShooterEffect(Sentinel);

                ExistingTemplate.AbilityIconColor = "Variable"; // LW2 feature
                break;
        }
    }
}

static function bool IsOperator(XComGameState_Unit Unit)
{
    return Unit != none && Unit.FindAbility(OperatorAbilityName).ObjectID != 0;
}

static function bool CanAddItemToInventory(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit Unit, XComGameState CheckGameState)
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

static function EventListenerReturn OnOverrideAbilityIconColor(Object EventData, Object EventSource, XComGameState NewGameState, Name EventID)
{
    local XComLWTuple                    OverrideTuple;
    local XComGameState_Ability          AbilityState;
    local X2AbilityTemplate              AbilityTemplate;
    local XComGameState_Unit             Unit;
    local int                            iEffect;
    local X2Effect_SpookOperatorSentinel Sentinel;

    OverrideTuple = XComLWTuple(EventData);
    if(OverrideTuple == none)
    {
        `SPOOKSLOG("OnOverrideAbilityIconColor event triggered with invalid event data.");
        return ELR_NoInterrupt;
    }

    AbilityState = XComGameState_Ability (EventSource);
    if (AbilityState == none)
    {
        `SPOOKSLOG("No ability state fed to OnOverrideAbilityIconColor");
        return ELR_NoInterrupt;
    }

    if (!default.OVERRIDE_OPERATOR_ABILITY_ICON_COLORS)
    {
        //`SPOOKSLOG("Ability icon color overrides disabled");
        return ELR_NoInterrupt;
    }

    AbilityTemplate = AbilityState.GetMyTemplate();
    Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));

    for (iEffect = 0; iEffect < AbilityTemplate.AbilityShooterEffects.Length; ++iEffect)
    {
        Sentinel = X2Effect_SpookOperatorSentinel(AbilityTemplate.AbilityShooterEffects[iEffect]);
        if (Sentinel != none && IsOperator(Unit))
        {
            //`SPOOKSLOG("Overriding icon color for " $ AbilityTemplate.DataName);
            if (EventID == 'OverrideObjectiveAbilityIconColor')
            {
                OverrideTuple.Data[0].b = true;
                OverrideTuple.Data[1].s = default.ICON_COLOR_OBJECTIVE;
            }
            else
            {
                OverrideTuple.Data[0].s = default.ICON_COLOR_FREE;
            }
            return ELR_NoInterrupt;
        }
    }

    return ELR_NoInterrupt;
}
