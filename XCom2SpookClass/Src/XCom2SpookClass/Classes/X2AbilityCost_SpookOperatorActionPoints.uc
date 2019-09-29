class X2AbilityCost_SpookOperatorActionPoints extends X2AbilityCost_ActionPoints;

simulated function bool ConsumeAllPoints(XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwner)
{
    if (class'X2Ability_SpookOperatorAbilitySet'.static.IsOperator(AbilityOwner))
    {
        return false;
    }
    return super.ConsumeAllPoints(AbilityState, AbilityOwner);
}

simulated function int GetPointCost(XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwner)
{
    if (class'X2Ability_SpookOperatorAbilitySet'.static.IsOperator(AbilityOwner))
    {
        return 0;
    }
    return super.GetPointCost(AbilityState, AbilityOwner);
}
