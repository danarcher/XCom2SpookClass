class X2Effect_SpookDistract
    extends X2Effect_Persistent;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local XComGameState_Unit Target;
    /*
    local vector TargetPosition;
    local TTile TargetTile;
    TargetPosition = EffectAppliedData.AbilityResultContext.ProjectileHitLocations[0];
    if (!World.GetFloorTileForPosition(TargetPosition, TargetTile))
    {
        `SPOOKSLOG("Projectile hit location has no floor tile!");
        return NewGameState;
    }
    */
    Target = XComGameState_Unit(kNewTargetState);
    Target.SetUnitFloatValue('SpookDistract', 1.0, eCleanup_BeginTactical);

    super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
    local XComGameState_Unit Target;

    Target = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
    if (Target == none)
    {
        Target = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
        NewGameState.AddStateObject(Target);
    }
    Target.ClearUnitValue('SpookDistract');

    super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
}
