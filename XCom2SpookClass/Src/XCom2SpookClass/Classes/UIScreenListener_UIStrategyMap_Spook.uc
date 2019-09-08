class UIScreenListener_UIStrategyMap_Spook
    extends UIScreenListener
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

const POIName = 'POI_SpookRecruit';

event OnInit(UIScreen Screen)
{
    local XComGameStateHistory History;
    local XComGameState NewGameState;
    local XComGameState_PointOfInterest POIState;
    local X2StrategyElementTemplateManager StrategyElementManager;
    local X2PointOfInterestTemplate POITemplate;
    local bool bFound, bSpawn;

    History = `XCOMHISTORY;
    NewGameState = `CreateChangeState("Spawn Spook POI");

    foreach History.IterateByClassType(class'XComGameState_PointOfInterest', POIState)
    {
        if(POIState.GetMyTemplateName() == POIName)
        {
            bFound = true;
            if (POIState.NumSpawns == 0)
            {
                `SPOOKLOG(POIName $ " has only spawned" $ POIState.NumSpawns $ " times, will spawn/again");
                POIState = XComGameState_PointOfInterest(NewGameState.CreateStateObject(class'XComGameState_PointOfInterest', POIState.ObjectID));
                NewGameState.AddStateObject(POIState);
                bSpawn = true;
                break;
            }
            else
            {
                `SPOOKLOG(POIName $ " has already spawned " $ POIState.NumSpawns $ " times, that's sufficient");
            }
        }
    }

    if(!bFound)
    {
        `SPOOKLOG(POIName $ " not found in history, creating one");
        StrategyElementManager = `XSTRATEGYELEMENTMANAGER;
        POITemplate = X2PointOfInterestTemplate(StrategyElementManager.FindStrategyElementTemplate(POIName));
        if (POITemplate != none)
        {
            `SPOOKLOG(POIName $ " created, will spawn");
            POIState = POITemplate.CreateInstanceFromTemplate(NewGameState);
            NewGameState.AddStateObject(POIState);
            bSpawn = true;
        }
        else
        {
            `SPOOKLOG("Template for " $ POIName $ " not found either, giving up");
        }
    }

    if (bSpawn)
    {
        `SPOOKLOG("Spawning " $ POIName);
        POIState.Spawn(NewGameState);
        POIState.bNeedsAppearedPopup = true;
        POIState.SetScanHoursRemaining(1, 1);
    }

    if(NewGameState.GetNumGameStateObjects() > 0)
    {
        `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
    }
    else
    {
        History.CleanupPendingGameState(NewGameState);
    }
}

defaultproperties
{
    ScreenClass = UIStrategyMap;
}
