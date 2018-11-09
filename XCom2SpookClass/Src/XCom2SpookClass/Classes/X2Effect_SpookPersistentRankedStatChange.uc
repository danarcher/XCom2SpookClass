class X2Effect_SpookPersistentRankedStatChange
    extends X2Effect_ModifyStats
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

const RankCount = 12; // HACK: Constant rank count. TODO: Is class'X2ExperienceConfig'.static.GetMaxRank() valid? Doesn't seem to be.

struct SpookStatChangesAtRank
{
    var array<StatChange> m_aStatChanges;
};

var array<SpookStatChangesAtRank> m_aRanks;

simulated function AddPersistentStatChange(int RankAndAbove, ECharStatType StatType, float StatAmount, optional EStatModOp InModOp=MODOP_Addition )
{
    local StatChange NewChange;
    local SpookStatChangesAtRank Item;
    local int i;
    local int j;
    local bool bModified;

    NewChange.StatType = StatType;
    NewChange.StatAmount = StatAmount;
    NewChange.ModOp = InModOp;

    while (m_aRanks.Length < RankCount)
    {
        m_aRanks.AddItem(Item);
    }

    for (i = RankAndAbove; i < RankCount; ++i)
    {
        bModified = false;
        for (j = 0; j < m_aRanks[i].m_aStatChanges.Length; ++j)
        {
            if (m_aRanks[i].m_aStatChanges[j].StatType == StatType)
            {
                m_aRanks[i].m_aStatChanges[j] = NewChange;
                bModified = true;
            }
        }

        if (!bModified)
        {
            m_aRanks[i].m_aStatChanges.AddItem(NewChange);
        }
    }
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local XComGameState_Unit Unit;
    local int Rank;

    Unit = XComGameState_Unit(kNewTargetState);
    if (Unit != None && Unit.IsSoldier())
    {
        Rank = Unit.GetSoldierRank();
    }
    else
    {
        Rank = 0;
    }

    NewEffectState.StatChanges = m_aRanks[Rank].m_aStatChanges;
    super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}
