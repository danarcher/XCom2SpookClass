class X2Condition_UnitIsShooter_Spook
    extends X2Condition;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
    if (kTarget.ObjectID == kSource.ObjectID)
    {
        return 'AA_Success';
    }
    return 'AA_UnitIsNotShooter';
}
