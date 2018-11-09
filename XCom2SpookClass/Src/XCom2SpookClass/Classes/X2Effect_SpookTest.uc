class X2Effect_SpookTest
    extends X2Effect_Persistent
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

static function Setup(X2AbilityTemplate Template)
{
    local X2Effect_SpookTest Test;

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(1, false, false, false, eGameRule_TacticalGameStart);
    Test.EffectName = 'Target1TurnTacticalGameStart';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(2, false, false, false, eGameRule_TacticalGameStart);
    Test.EffectName = 'Target2TurnTacticalGameStart';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(2, false, false, true, eGameRule_TacticalGameStart);
    Test.EffectName = 'Target2TurnTacticalGameStartAny';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(2, false, false, true, eGameRule_TacticalGameStart);
    Test.EffectName = 'Target2TurnTacticalGameStartAny_WhenApplied';
    Test.bTickWhenApplied = true;
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
    Test.EffectName = 'Target1TurnBegin';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
    Test.EffectName = 'Target1TurnEnd';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnBegin);
    Test.EffectName = 'TargetInfiniteTurnBegin';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnEnd);
    Test.EffectName = 'TargetInfiniteTurnEnd';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(1, false, false, true, eGameRule_PlayerTurnBegin);
    Test.EffectName = 'Target1TurnBeginAny';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(1, false, false, true, eGameRule_PlayerTurnEnd);
    Test.EffectName = 'Target1TurnEndAny';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(1, true, false, true, eGameRule_PlayerTurnBegin);
    Test.EffectName = 'TargetInfiniteTurnBeginAny';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(1, true, false, true, eGameRule_PlayerTurnEnd);
    Test.EffectName = 'TargetInfiniteTurnEndAny';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(1, false, false, true, eGameRule_PlayerTurnEnd);
    Test.EffectName = 'Target1TurnEndAny_WhenApplied';
    Test.EffectTickedFn = TickTock;
    Test.bTickWhenApplied = true;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnBegin);
    Test.EffectName = 'Target2TurnsBegin';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnEnd);
    Test.EffectName = 'Target2TurnsEnd';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(2, false, false, true, eGameRule_PlayerTurnBegin);
    Test.EffectName = 'Target2TurnsBeginAny';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(2, false, false, true, eGameRule_PlayerTurnEnd);
    Test.EffectName = 'Target2TurnsEndAny';
    Test.EffectTickedFn = TickTock;
    Template.AddTargetEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnBegin);
    Test.EffectName = 'Source2TurnsBegin';
    Test.EffectTickedFn = TickTock;
    Template.AddShooterEffect(Test);

    Test = new class'X2Effect_SpookTest';
    Test.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnEnd);
    Test.EffectName = 'Source2TurnsEnd';
    Test.EffectTickedFn = TickTock;
    Template.AddShooterEffect(Test);
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    `SPOOKLOG(EffectName @ " OnEffectAdded");
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
    `SPOOKLOG(EffectName @ "OnEffectRemoved");
}

simulated function bool TickTock(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
    local X2Effect_SpookTest This;
    This = X2Effect_SpookTest(PersistentEffect);
    This.Tickety();
    return false;
}

simulated function Tickety()
{
    `SPOOKLOG(EffectName @ "OnEffectTicked");
}
