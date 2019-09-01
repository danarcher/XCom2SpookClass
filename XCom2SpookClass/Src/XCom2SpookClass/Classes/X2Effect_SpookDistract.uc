class X2Effect_SpookDistract
    extends X2Effect_Persistent;

`include(XCom2SpookClass\Src\Spook.uci)

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local XComGameState_Unit Target;
    local XComGameState_SpookDistractEffect DistractEffectState;
    local UnitValue Value;

    `SPOOKLOG("OnEffectAdded");
    Target = XComGameState_Unit(kNewTargetState);
    Target.SetUnitFloatValue('SpookDistract', 1.0, eCleanup_BeginTactical);

    Value.fValue = 0;
    Target.GetUnitValue('SpookDistract', Value);
    `SPOOKLOG(Target.GetMyTemplateName() $ " SpookDistract value is now " $ Value.fValue);

    DistractEffectState = XComGameState_SpookDistractEffect(NewEffectState);
    DistractEffectState.TargetPosition = ApplyEffectParameters.AbilityResultContext.ProjectileHitLocations[0];
    `SPOOKLOG(Target.GetMyTemplateName() $ " target position is now " $ DistractEffectState.TargetPosition);

    super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
    local XComGameState_Unit Target;
    local UnitValue Value;

    `SPOOKLOG("OnEffectRemoved");
    Target = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
    if (Target == none)
    {
        Target = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
        NewGameState.AddStateObject(Target);
    }
    Target.ClearUnitValue('SpookDistract');

    Value.fValue = 0;
    Target.GetUnitValue('SpookDistract', Value);
    `SPOOKLOG(Target.GetMyTemplateName() $ " SpookDistract value is now " $ Value.fValue);

    super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
}
