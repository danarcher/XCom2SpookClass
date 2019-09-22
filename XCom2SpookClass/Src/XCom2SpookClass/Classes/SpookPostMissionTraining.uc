class SpookPostMissionTraining
    extends Object
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var config bool REQUIRE_POST_MISSION_TRAINING;

static function OnPostMission()
{
    local XComGameStateHistory History;
    local XComGameState NewGameState;
    local XComGameState_HeadquartersXCom XComHQ;
    local XComGameState_Unit Unit;
    local XComGameState_HeadquartersProjectSpookTraining Project;
    local int UnitID, Index;

    if (!default.REQUIRE_POST_MISSION_TRAINING)
    {
        return;
    }

    History = `XCOMHISTORY;
    XComHQ = `XCOMHQ;

    for(Index = 0; Index < XComHQ.Squad.Length; Index++)
    {
        UnitID = XComHQ.Squad[Index].ObjectID;
        if (UnitID != 0)
        {
            Unit = `FindUnitState(UnitID, none, History);
            if (Unit.GetSoldierClassTemplateName() == 'Spook' &&
                !Unit.IsDead() && !Unit.bCaptured && !Unit.IsInjured() &&
                Unit.GetStatus() == eStatus_Active)
            {
                if (NewGameState == none)
                {
                    NewGameState = `CreateChangeState("Spook Post Mission Training");
                    XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(XComHQ.Class, XComHQ.ObjectID));
                    NewGameState.AddStateObject(XComHQ);
                }

                Unit = `FindOrAddUnitState(UnitID, NewGameState, History);

                Project = XComGameState_HeadquartersProjectSpookTraining(NewGameState.CreateStateObject(class'XComGameState_HeadquartersProjectSpookTraining'));
                NewGameState.AddStateObject(Project);
                Project.SetProjectFocus(Unit.GetReference(), NewGameState);
                XComHQ.Projects.AddItem(Project.GetReference());
            }
        }
    }

    if (NewGameState != none)
    {
        `GAMERULES.SubmitGameState(NewGameState);
    }
}
