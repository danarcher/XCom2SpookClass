class X2Condition_SpookShadowNotRevealedByClasses
    extends X2Condition;

var bool Required;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
    local name EffectName;
    local bool SourceHasShadow;
    local XComGameState_Unit Source;

    SourceHasShadow = false;

    Source = XComGameState_Unit(kSource);
    if (Source != none)
    {
        foreach class'SpookDetectionManager'.default.SHADOW_EFFECTS(EffectName)
        {
            if (Source.IsUnitAffectedByEffectName(EffectName))
            {
                SourceHasShadow = true;
                break;
            }
        }
    }

    if (SourceHasShadow && class'SpookDetectionManager'.default.SHADOW_NOT_REVEALED_BY_CLASSES.Find(kTarget.GetMyTemplateName()) >= 0)
    {
        return 'AA_Success';
    }

    return 'AA_AbilityUnavailable';
}
