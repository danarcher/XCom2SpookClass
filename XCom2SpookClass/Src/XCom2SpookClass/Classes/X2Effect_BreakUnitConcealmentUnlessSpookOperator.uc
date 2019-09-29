class X2Effect_BreakUnitConcealmentUnlessSpookOperator extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local XComGameState_Unit Unit;
    Unit = XComGameState_Unit(kNewTargetState);
    if (Unit != none && !class'X2Ability_SpookOperatorAbilitySet'.static.IsOperator(Unit))
    {
        `XEVENTMGR.TriggerEvent('EffectBreakUnitConcealment', Unit, Unit, NewGameState);
    }
}
