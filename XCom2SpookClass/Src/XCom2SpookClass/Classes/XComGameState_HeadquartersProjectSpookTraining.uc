class XComGameState_HeadquartersProjectSpookTraining
    extends XComGameState_HeadquartersProject
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var config int MIN_POST_MISSION_TRAINING_HOURS;
var config int MAX_POST_MISSION_TRAINING_HOURS;

function SetProjectFocus(StateObjectReference FocusRef, optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
    local XComGameStateHistory History;
    local XComGameState_GameTime TimeState;
    local XComGameState_Unit Unit;

    History = `XCOMHISTORY;
    ProjectFocus = FocusRef; // Unit
    AuxilaryReference = AuxRef; // Facility (Unused)

    Unit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ProjectFocus.ObjectID));
    Unit.SetStatus(eStatus_Training);

    ProjectPointsRemaining = int(FMax(1, RandRange(default.MIN_POST_MISSION_TRAINING_HOURS, default.MAX_POST_MISSION_TRAINING_HOURS)));
    InitialProjectPoints = ProjectPointsRemaining;

    UpdateWorkPerHour(NewGameState);
    TimeState = XComGameState_GameTime(History.GetSingleGameStateObjectForClass(class'XComGameState_GameTime'));
    StartDateTime = TimeState.CurrentTime;

    if (`STRATEGYRULES != none)
    {
        if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(TimeState.CurrentTime, `STRATEGYRULES.GameTime))
        {
            StartDateTime = `STRATEGYRULES.GameTime;
        }
    }

    if (MakingProgress())
    {
        SetProjectedCompletionDateTime(StartDateTime);
    }
    else
    {
        // Set completion time to unreachable future
        CompletionDateTime.m_iYear = 9999;
    }
}

function int CalculateWorkPerHour(optional XComGameState StartState = none, optional bool bAssumeActive = false)
{
    return 1;
}

function OnProjectCompleted()
{
    local XComGameState NewGameState;
    local XComGameState_Unit Unit;

    NewGameState = `CreateChangeState("Spook Post Mission Training Completed");
    Unit = `FindOrAddUnitState(ProjectFocus.ObjectID, NewGameState, none);
    Unit.SetStatus(eStatus_Active);
    `GAMERULES.SubmitGameState(NewGameState);
}
