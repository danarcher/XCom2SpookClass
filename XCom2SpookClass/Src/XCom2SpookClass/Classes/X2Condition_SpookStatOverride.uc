class X2Condition_SpookStatOverride
    extends X2Condition;

var bool Required;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
    if (class'X2DownloadableContentInfo_Spook'.static.IsStatOverrideEnabled())
    {
        if (Required)
        {
            return 'AA_Success';
        }
    }
    else if (!Required)
    {
        return 'AA_Success';
    }

    return 'AA_AbilityUnavailable';
}
