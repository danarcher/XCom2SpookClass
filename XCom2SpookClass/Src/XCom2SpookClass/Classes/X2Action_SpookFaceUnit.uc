class X2Action_SpookFaceUnit
    extends X2Action_Move;

`include(XCom2SpookClass\Src\Spook.uci)

var Actor FaceActor;
var protected XGUnit FaceUnit;
var protected XComUnitPawn FaceUnitPawn;
var protected vector vFacePoint;
var protected vector vFaceDir;

simulated state Executing
{
    simulated function bool DecideFacePoint()
    {
        if (FaceUnitPawn == None)
        {
            return false;
        }
        vFacePoint = FaceUnitPawn.Location;
        return true;
    }

    simulated function bool ShouldTurn()
    {
        local float fDot;

        vFaceDir = vFacePoint - UnitPawn.Location;
        vFaceDir.Z = 0;
        vFaceDir = normal(vFaceDir);

        fDot = vFaceDir dot vector(UnitPawn.Rotation);

        return fDot < 0.9f;
    }

Begin:
    Unit = XGUnit(Track.TrackActor);
    UnitPawn = Unit.GetPawn();

    FaceUnit = XGUnit(FaceActor);
    if (FaceUnit != None)
    {
        FaceUnitPawn = FaceUnit.GetPawn();
    }

    if (DecideFacePoint())
    {
        //Check to see whether we are in the middle of a run that has been interrupted
        if(UnitPawn.GetAnimTreeController().GetAllowNewAnimations())
        {
            UnitPawn.TargetLoc = vFacePoint;
        }

        if(ShouldTurn())
        {
            // Turn
            FinishAnim(UnitPawn.StartTurning(UnitPawn.Location + vFaceDir*vect(1000, 1000, 0)));
        }
        // Snap
        UnitPawn.SetRotation(Rotator(vFaceDir));

        UnitPawn.Acceleration = vect(0, 0, 0);
    }

    CompleteAction();
}
