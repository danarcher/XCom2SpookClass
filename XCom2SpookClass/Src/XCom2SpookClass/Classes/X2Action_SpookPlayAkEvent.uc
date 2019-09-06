class X2Action_SpookPlayAkEvent
    extends X2Action
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var AkEvent EventToPlay;

function bool CheckInterrupted()
{
    return false;
}

simulated state Executing
{
Begin:
    UnitPawn.PlayAkEvent(EventToPlay);

    CompleteAction();
}
