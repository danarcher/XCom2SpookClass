class X2Condition_SpookEclipse extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
    local XComGameState_Unit TargetUnit;

    TargetUnit = XComGameState_Unit(kTarget);
    if (TargetUnit == none)
        return 'AA_NotAUnit';

    if (TargetUnit.IsUnconscious() || TargetUnit.IsBleedingOut())
        return 'AA_NotConscious';

    return 'AA_Success';
}
