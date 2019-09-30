class X2Action_SpookEclipsed
    extends X2Action;

var private bool bMessageReceived;

function HandleTrackMessage()
{
    bMessageReceived = true;
}

function Init(const out VisualizationTrack InTrack)
{
    super.Init(InTrack);
}

simulated state Executing
{
Begin:
    while (!bMessageReceived && !IsTimedOut())
    {
        // Wait until you've been hit.
        Sleep(0.0f);
    }

    // Ragdoll on the spot.
    UnitPawn.DyingImpulse = vect(0, 0, 0.01f);
    UnitPawn.SetFinalRagdoll(false);
    UnitPawn.fPhysicsMotorForce = 0;
    UnitPawn.RagdollBlendTime = class'XComUnitPawn'.default.RagdollBlendTime;
    UnitPawn.RagdollFinishTimer = 2.0f;
    UnitPawn.StartRagDoll(true,,, false);

    // // Okay look, seriously now, don't whoosh across the level.
    UnitPawn.Mesh.SetRBLinearVelocity(vect(0, 0, 0), false);
    UnitPawn.Mesh.SetRBAngularVelocity(vect(0, 0, 0), false);

    // Hmmm. This doesn't work either:
    Sleep(2.0f);
    UnitPawn.GotoState('');
    UnitPawn.Mesh.PutRigidBodyToSleep();

    // We're done here.
    CompleteAction();
}
