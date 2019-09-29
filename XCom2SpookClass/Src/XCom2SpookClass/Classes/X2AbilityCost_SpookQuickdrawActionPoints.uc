class X2AbilityCost_SpookQuickdrawActionPoints extends X2AbilityCost_ActionPoints;

simulated function bool ConsumeAllPoints(XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwner)
{
    if (AbilityOwner.HasSoldierAbility('Quickdraw'))
    {
        return false;
    }
    return super.ConsumeAllPoints(AbilityState, AbilityOwner);
}
