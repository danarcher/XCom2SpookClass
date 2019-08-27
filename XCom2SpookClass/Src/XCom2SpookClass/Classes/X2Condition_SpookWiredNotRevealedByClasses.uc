class X2Condition_SpookWiredNotRevealedByClasses
    extends X2Condition;

var bool Required;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
    local XComGameState_Unit Source;
    Source = XComGameState_Unit(kSource);
    if (Source != none &&
        Source.IsUnitAffectedByEffectName(class'X2Ability_SpookAbilitySet'.const.WiredAbilityName) &&
        class'SpookDetectionManager'.default.WIRED_NOT_REVEALED_BY_CLASSES.Find(kTarget.GetMyTemplateName()) >= 0)
    {
        return 'AA_Success';
    }
    return 'AA_AbilityUnavailable';
}
