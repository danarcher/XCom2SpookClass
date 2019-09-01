class XComGameState_SpookDistractEffect
    extends XComGameState_Effect;

`include(XCom2SpookClass\Src\Spook.uci)

var vector TargetPosition;

function OnCreation(EffectAppliedData InApplyEffectParameters, GameRuleStateChange WatchRule, XComGameState NewGameState)
{
    local XComGameState_Unit UnitInHistory;
    super.OnCreation(InApplyEffectParameters, WatchRule, NewGameState);
    UnitInHistory = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
    `SPOOKLOG("OnCreation for " $ UnitInHistory.GetMyTemplateName());
}
