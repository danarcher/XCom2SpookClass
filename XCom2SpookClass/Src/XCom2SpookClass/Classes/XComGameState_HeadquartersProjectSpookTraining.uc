// Spook post-mission "training" to enforce downtime.
// Extends rookie training to work around hard-coded base game expectations.
class XComGameState_HeadquartersProjectSpookTraining
    extends XComGameState_HeadquartersProjectTrainRookie
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var config bool REQUIRE_POST_MISSION_TRAINING;

var config int MIN_POST_MISSION_TRAINING_HOURS;
var config int MAX_POST_MISSION_TRAINING_HOURS;

var localized string ProjectDisplayName;
var localized string ProjectTrainingDisplayName;

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
        `SPOOKSLOG("Post mission training is disabled");
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
                `SPOOKSLOG(Unit.GetSoldierClassTemplateName() $ " " $ Unit.GetFullName() $ " requires post-mission training");

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

// Only LW2 calls this.
function string GetDisplayName()
{
    return default.ProjectDisplayName;
}

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

    // The base game uses this to display "<CLASS> TRAINING: n days" in event
    // queue UI (XComHQ.GetSoldierEvents() calls our GetTrainingClassTemplate()
    // and accesses its DisplayName). LW2 instead calls GetDisplayName() which
    // it adds to our base class.
    //
    // Hence without LW2 we will show "SPOOK TRAINING: n days". With LW2 we will
    // show "POST-MISSION TRAINING: n days" via GetDisplayName(). We could
    // provide a fake class template if we wanted identical results.
    NewClassName = Unit.GetSoldierClassTemplateName();

    ProjectPointsRemaining = int(FMax(1, RandRange(default.MIN_POST_MISSION_TRAINING_HOURS, default.MAX_POST_MISSION_TRAINING_HOURS)));
    InitialProjectPoints = ProjectPointsRemaining;

    `SPOOKLOG("Project to train " $ Unit.GetFullName() $ " will take " $ ProjectPointsRemaining $ " hours (" $ (ProjectPointsRemaining / 24.0) $ " days)");

    UpdateWorkPerHour(NewGameState);
    TimeState = XComGameState_GameTime(History.GetSingleGameStateObjectForClass(class'XComGameState_GameTime'));
    StartDateTime = TimeState.CurrentTime;

    if (`STRATEGYRULES != none)
    {
        if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(TimeState.CurrentTime, `STRATEGYRULES.GameTime))
        {
            StartDateTime = `STRATEGYRULES.GameTime;
            `SPOOKLOG("Start date adjusted to strategy game time");
        }
    }

    if (MakingProgress())
    {
        `SPOOKLOG("Project completion time set");
        SetProjectedCompletionDateTime(StartDateTime);
    }
    else
    {
        // Set completion time to unreachable future
        CompletionDateTime.m_iYear = 9999;
        `SPOOKLOG("Project completion time set to unreachable future");
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
    local XComGameState_HeadquartersXCom XComHQ;

    NewGameState = `CreateChangeState("Spook Post Mission Training Completed");

    Unit = `FindOrAddUnitState(ProjectFocus.ObjectID, NewGameState, none);
    Unit.SetStatus(eStatus_Active);

    XComHQ = `XCOMHQ;
    XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(XComHQ.Class, XComHQ.ObjectID));
    NewGameState.AddStateObject(XComHQ);
    XComHQ.Projects.RemoveItem(self.GetReference());
    NewGameState.RemoveStateObject(self.ObjectID);

    `GAMERULES.SubmitGameState(NewGameState);

    `SPOOKLOG("Training project completed for " $ Unit.GetFullName());
}

static function EventListenerReturn OnOverrideGetPersonnelStatusSeparate(Object EventData, Object EventSource, XComGameState NewGameState, Name EventID)
{
    local XComGameState_Unit Unit;
    local XComLWTuple Tuple;
    local XComGameState_HeadquartersProjectSpookTraining Project;
    local int iHours, iDays;

    //`SPOOKSLOG("OnOverrideGetPersonnelStatusSeparate");

    Tuple = XComLWTuple(EventData);
    Unit = XComGameState_Unit(EventSource);

    if (Tuple == none || Unit == none)
    {
        `SPOOKSLOG("OnOverrideGetPersonnelStatusSeparate found bad tuple/unit!");
        return ELR_NoInterrupt;
    }

    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_HeadquartersProjectSpookTraining', Project)
    {
        if (Project.ProjectFocus.ObjectID == Unit.ObjectID && Unit.GetStatus() == eStatus_Training)
        {
            iHours = Project.GetCurrentNumHoursRemaining();
            iDays = iHours / 24;
            //`SPOOKSLOG("Project found for unit " $ Unit.GetFullName() $ ", " $ iHours $ " hours (" $ iDays $ " days) remaining");

            if (iHours % 24 > 0)
            {
                iDays += 1;
            }

            if (Tuple.Data.Length < 4)
            {
                Tuple.Data.Add(4 - Tuple.Data.Length);
            }

            Tuple.Data[0].s = default.ProjectTrainingDisplayName;
            Tuple.Data[0].kind = XComLWTVString;

            Tuple.Data[1].s = class'UIUtilities_Text'.static.GetDaysString(iDays);
            Tuple.Data[1].kind = XComLWTVString;

            Tuple.Data[2].i = iDays;
            Tuple.Data[2].kind = XComLWTVInt;

            Tuple.Data[3].i = eUIState_Warning;
            Tuple.Data[3].kind = XComLWTVInt;
            return ELR_NoInterrupt;
        }
    }

    return ELR_NoInterrupt;
}
