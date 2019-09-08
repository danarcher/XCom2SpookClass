class X2Condition_Spook
    extends X2Condition;

`include(XCom2SpookClass\Src\Spook.uci)

var bool bRequireSelfTarget;
var bool bRequireConscious;
var bool bRequireNotBleedingOut;
var bool bRequireCannotRevealWiredSource;
var bool bRequireCredulousAI;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
    local XComGameState_Unit SourceUnit;
    local XComGameState_Unit TargetUnit;

    SourceUnit = XComGameState_Unit(kSource);
    TargetUnit = XComGameState_Unit(kTarget);

    if (bRequireSelfTarget && kTarget.ObjectID != kSource.ObjectID)
    {
        return 'AA_NotSelfTarget';
    }

    if (bRequireConscious && (TargetUnit == none || TargetUnit.IsUnconscious()))
    {
        return 'AA_NotConscious';
    }

    if (bRequireNotBleedingOut && (TargetUnit == none || TargetUnit.IsBleedingOut()))
    {
        return 'AA_BleedingOut';
    }

    if (bRequireCannotRevealWiredSource)
    {
        if (SourceUnit == none ||
            !SourceUnit.IsUnitAffectedByEffectName(class'X2Ability_SpookAbilitySet'.const.WiredAbilityName) ||
            class'SpookTacticalDetectionManager'.default.WIRED_NOT_REVEALED_BY_CLASSES.Find(kTarget.GetMyTemplateName()) == INDEX_NONE)
        {
            return 'AA_AbilityUnavailable';
        }
    }

    if (bRequireCredulousAI)
    {
        if (TargetUnit == none ||
            !TargetUnit.ControllingPlayerIsAI() ||
            TargetUnit.GetCurrentStat(eStat_AlertLevel) >= 2)
        {
            if (TargetUnit != none)
            {
                `SPOOKLOG("AA_Incredulous for " $ (TargetUnit.ControllingPlayerIsAI() ? "AI" : "non-AI") $ " unit " $ TargetUnit.GetMyTemplateName() $ " alert level " $ TargetUnit.GetCurrentStat(eStat_AlertLevel));
            }
            return 'AA_Incredulous';
        }
    }

    return 'AA_Success';
}
