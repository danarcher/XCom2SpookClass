class X2AbilityCost_FreeToOperator
    extends X2AbilityCost
    config(Spook);

var X2AbilityCost BaseCost;

`include(XCom2SpookClass\Src\Spook.uci)

simulated function name CanAfford(XComGameState_Ability kAbility, XComGameState_Unit ActivatingUnit)
{
    if (class'X2Ability_SpookOperatorAbilitySet'.static.IsOperator(ActivatingUnit))
    {
        return 'AA_Success';
    }
    return BaseCost.CanAfford(kAbility, ActivatingUnit);
}

simulated function ApplyCost(XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
    if (class'X2Ability_SpookOperatorAbilitySet'.static.IsOperator(XComGameState_Unit(AffectState)))
    {
        return;
    }
    BaseCost.ApplyCost(AbilityContext, kAbility, AffectState, AffectWeapon, NewGameState);
}
