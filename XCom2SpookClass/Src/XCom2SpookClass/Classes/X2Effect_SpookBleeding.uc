class X2Effect_SpookBleeding
    extends X2Effect_Persistent
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var localized string BleedingFriendlyName;
var localized string BleedingHelpText;
var localized string BleedingEffectAcquired;
var localized string BleedingEffectTicked;
var localized string BleedingEffectLost;


static function X2Effect_SpookBleeding CreateBleedingStatusEffect(name DamageTypeName, int BleedingTurns, int DamagePerTick, int DamageSpreadPerTick, int PlusOnePerTick)
{
    local X2Effect_SpookBleeding Effect;

    Effect = new class'X2Effect_SpookBleeding';
    Effect.EffectName = 'SpookBleeding';
    Effect.BuildPersistentEffect(`BPE_TickAtStartOfNUnitTurns(BleedingTurns));
    Effect.SetDisplayInfo(ePerkBuff_Penalty, default.BleedingFriendlyName, default.BleedingHelpText, "img:///UILibrary_PerkIcons.UIPerk_bloodcall");
    Effect.SetBleedDamage(DamagePerTick, DamageSpreadPerTick, PlusOnePerTick, DamageTypeName);
    Effect.VisualizationFn = BleedingVisualization;
    Effect.EffectTickedVisualizationFn = BleedingVisualizationTicked;
    Effect.EffectRemovedVisualizationFn = BleedingVisualizationRemoved;
    Effect.bRemoveWhenTargetDies = true;
    Effect.DamageTypes.AddItem(DamageTypeName);
    Effect.DuplicateResponse = eDupe_Refresh;
    Effect.bCanTickEveryAction = true;

    return Effect;
}

simulated function SetBleedDamage(int Damage, int Spread, int PlusOne, name DamageType)
{
    local X2Effect_ApplyWeaponDamage BleedDamage;

    BleedDamage = GetBleedDamage();
    BleedDamage.EffectDamageValue.Damage = Damage;
    BleedDamage.EffectDamageValue.Spread = Spread;
    BleedDamage.EffectDamageValue.PlusOne = PlusOne;
    BleedDamage.EffectDamageValue.DamageType = DamageType;
    BleedDamage.bIgnoreBaseDamage = true;
    BleedDamage.bBypassShields = true;
    BleedDamage.bIgnoreArmor = true;
}

simulated function X2Effect_ApplyWeaponDamage GetBleedDamage()
{
    return X2Effect_ApplyWeaponDamage(ApplyOnTick[0]);
}

DefaultProperties
{
    DuplicateResponse=eDupe_Refresh
    bCanTickEveryAction=true

    Begin Object Class=X2Effect_ApplyWeaponDamage Name=BleedDamage
        bAllowFreeKill=false
        bIgnoreArmor=true
    End Object

    ApplyOnTick.Add(BleedDamage)
}

static function BleedingVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    if (EffectApplyResult != 'AA_Success')
        return;
    if (!BuildTrack.StateObject_NewState.IsA('XComGameState_Unit'))
        return;

    class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), default.BleedingFriendlyName, 'Poison', eColor_Bad, "img:///UILibrary_Common.status_default");
    class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, default.BleedingEffectAcquired, VisualizeGameState.GetContext());
    class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

static function BleedingVisualizationTicked(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    local XComGameState_Unit UnitState;

    UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);

    // dead units should not be reported
    if(UnitState == None || UnitState.IsDead() )
    {
        return;
    }

    class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, default.BleedingEffectTicked, VisualizeGameState.GetContext());
    class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

static function BleedingVisualizationRemoved(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    local XComGameState_Unit UnitState;

    UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);

    // dead units should not be reported
    if(UnitState == None || UnitState.IsDead() )
    {
        return;
    }

    class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, default.BleedingEffectLost, VisualizeGameState.GetContext());
    class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}
