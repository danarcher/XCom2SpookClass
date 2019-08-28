class X2StrategyElement_SpookPointsOfInterest
    extends X2StrategyElement
    dependson(X2PointOfInterestTemplate)
    dependson(X2RewardTemplate);

`include(XCom2SpookClass\Src\Spook.uci)

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreateSpookRecruitTemplate());
    Templates.AddItem(CreateSpookRewardTemplate());

    return Templates;
}

static function X2DataTemplate CreateSpookRecruitTemplate()
{
    local X2PointOfInterestTemplate Template;

    `CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_SpookRecruit');

    Template.IsRewardNeededFn = IsSpookRecruitRewardNeeded;

    return Template;
}

function bool IsSpookRecruitRewardNeeded(XComGameState_PointOfInterest POIState)
{
    // We'll spawn this ourselves when we want it, so we don't need it to come
    // up for any other reasons.
    return false;
}

static function X2DataTemplate CreateSpookRewardTemplate()
{
    local X2RewardTemplate Template;

    `CREATE_X2Reward_TEMPLATE(Template, 'Reward_Spook');
    Template.rewardObjectTemplateName = 'Spook';

    Template.GenerateRewardFn = GenerateSoldierReward;
    Template.SetRewardFn = class'X2StrategyElement_DefaultRewards'.static.SetPersonnelReward;
    Template.GiveRewardFn = class'X2StrategyElement_DefaultRewards'.static.GivePersonnelReward;
    Template.GetRewardStringFn = class'X2StrategyElement_DefaultRewards'.static.GetPersonnelRewardString;
    Template.GetRewardImageFn = class'X2StrategyElement_DefaultRewards'.static.GetPersonnelRewardImage;
    Template.GetBlackMarketStringFn = class'X2StrategyElement_DefaultRewards'.static.GetSoldierBlackMarketString;
    Template.GetRewardIconFn = class'X2StrategyElement_DefaultRewards'.static.GetGenericRewardIcon;

    return Template;
}

// Adapted from GeneratePersonnelReward.
// We use X2RewardTemplate.rewardObjectTemplateName to reference a soldier class, not 'Soldier' or 'Scientist' etc.
function GenerateSoldierReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference RegionRef)
{
    local XComGameState_HeadquartersResistance ResistanceHQ;
    local XComGameState_HeadquartersAlien AlienHQ;
    local XComGameStateHistory History;
    local XComGameState_Unit NewUnitState;
    local XComGameState_WorldRegion RegionState;
    local int idx, NewRank;
    local name nmCountry;

    History = `XCOMHISTORY;

    // Grab the region and pick a random country
    nmCountry = '';
    RegionState = XComGameState_WorldRegion(History.GetGameStateForObjectID(RegionRef.ObjectID));

    if(RegionState != none)
    {
        nmCountry = RegionState.GetMyTemplate().GetRandomCountryInRegion();
    }

    //Use the character pool's creation method to retrieve a unit
    NewUnitState = `CHARACTERPOOLMGR.CreateCharacter(NewGameState, `XPROFILESETTINGS.Data.m_eCharPoolUsage, 'Soldier', nmCountry);
    NewUnitState.RandomizeStats();
    NewGameState.AddStateObject(NewUnitState);

    ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
    if(!NewGameState.GetContext().IsStartState())
    {
        ResistanceHQ = XComGameState_HeadquartersResistance(NewGameState.CreateStateObject(class'XComGameState_HeadquartersResistance', ResistanceHQ.ObjectID));
        NewGameState.AddStateObject(ResistanceHQ);
    }

    NewUnitState.ApplyInventoryLoadout(NewGameState);

    // Per X2StrategyElement_DefaultRewards.GetPersonnelRewardRank()
    AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
    NewRank = 1;
    for(idx = 0; idx < class'X2StrategyElement_DefaultRewards'.default.SoldierRewardForceLevelGates.Length; idx++)
    {
        if(AlienHQ.GetForceLevel() >= class'X2StrategyElement_DefaultRewards'.default.SoldierRewardForceLevelGates[idx])
        {
            NewRank++;
        }
    }

    NewUnitState.SetXPForRank(NewRank);
    NewUnitState.StartingRank = NewRank;

    for(idx = 0; idx < NewRank; idx++)
    {
        // Rank up to squaddie
        if(idx == 0)
        {
            NewUnitState.RankUpSoldier(NewGameState, RewardState.GetMyTemplate().rewardObjectTemplateName);
            NewUnitState.ApplySquaddieLoadout(NewGameState);
            //NewUnitState.bNeedsNewClassPopup = false;
        }
        else
        {
            NewUnitState.RankUpSoldier(NewGameState, NewUnitState.GetSoldierClassTemplate().DataName);
        }
    }

    RewardState.RewardObjectReference = NewUnitState.GetReference();
}
