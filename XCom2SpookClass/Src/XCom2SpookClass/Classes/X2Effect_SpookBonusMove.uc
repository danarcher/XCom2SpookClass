class X2Effect_SpookBonusMove
    extends X2Effect_Persistent
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var bool bIsConcealedBonusMove;
var bool bEvenIfFree;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
    local UnitValue MovesThisTurn;

    `SPOOKLOG("PostAbilityCostPaid");
    //  if we have no standard actions left, but we had them before, then this obviously cost us something and we can refund an action point
    if (SourceUnit.NumActionPoints() == 0 && (PreCostActionPoints.Length > 0 || bEvenIfFree))
    {
        if (!SourceUnit.GetUnitValue('SpookBonusMovesTaken', MovesThisTurn))
        {
            `SPOOKLOG("Adding action points");
            SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.MoveActionPoint);
            SourceUnit.SetUnitFloatValue('SpookBonusMovesTaken', 1, eCleanup_BeginTurn);
            return true;
        }
    }

    return false;
}
