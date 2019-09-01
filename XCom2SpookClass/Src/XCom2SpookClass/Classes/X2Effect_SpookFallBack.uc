// Adapted from LW2 X2Effect_FallBack by Amineri (Pavonis Interactive)
class X2Effect_SpookFallBack
    extends X2Effect
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var name BehaviorTree;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local XComGameState_Unit UnitState;
    local Name FallBackBehaviorTree;
    local int Point;

    UnitState = XComGameState_Unit(kNewTargetState);

    if (UnitState == none)
        return;

    if (UnitState.isStunned())
        return;

    `SPOOKLOG("Fallback applied");
    // Add one standard action point for fallback actions.
    for( Point = 0; Point < 1; ++Point )
    {
        if( Point < UnitState.ActionPoints.Length )
        {
            if( UnitState.ActionPoints[Point] != class'X2CharacterTemplateManager'.default.StandardActionPoint )
            {
                UnitState.ActionPoints[Point] = class'X2CharacterTemplateManager'.default.StandardActionPoint;
            }
        }
        else
        {
            UnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
        }
    }

    // Kick off panic behavior tree.
    FallBackBehaviorTree = BehaviorTree;

    // Delayed behavior tree kick-off.  Points must be added and game state submitted before the behavior tree can
    // update, since it requires the ability cache to be refreshed with the new action points.
    UnitState.AutoRunBehaviorTree(FallBackBehaviorTree, 1, `XCOMHISTORY.GetCurrentHistoryIndex() + 1, true);
}
