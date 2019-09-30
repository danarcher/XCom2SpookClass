class X2Action_SpookEclipse extends X2Action;

var CustomAnimParams Params;
var protected XComGameStateContext_Ability AbilityContext;

function Init(const out VisualizationTrack InTrack)
{
    super.Init(InTrack);
    AbilityContext = XComGameStateContext_Ability(StateChangeContext);
}

simulated state Executing
{
Begin:
    Params.AnimName = 'FF_Melee';
    FinishAnim(UnitPawn.GetAnimTreeController().PlayFullBodyDynamicAnim(Params));

    if (AbilityContext.InputContext.PrimaryTarget.ObjectID > 0)
    {
        VisualizationMgr.SendInterTrackMessage(AbilityContext.InputContext.PrimaryTarget);
    }

    CompleteAction();
}
