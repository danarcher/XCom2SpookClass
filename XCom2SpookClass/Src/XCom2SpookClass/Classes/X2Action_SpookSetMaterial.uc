class X2Action_SpookSetMaterial
    extends X2Action
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var bool bResetMaterial;
var bool bSaveMaterials;
var string MaterialToSet;

var protected XComHumanPawn HumanPawn;
var protected Material SpecialMaterial;

function Init(const out VisualizationTrack InTrack)
{
    super.Init(InTrack);
    HumanPawn = XComHumanPawn(UnitPawn);
}

function bool CheckInterrupted()
{
    return false;
}

simulated state Executing
{
    function RequestSpecialMaterial()
    {
        `CONTENT.RequestGameArchetype(MaterialToSet, self, SpecialMaterialLoaded, true);
    }

    function SpecialMaterialLoaded(Object LoadedArchetype)
    {
        SpecialMaterial = Material(LoadedArchetype);
    }

    function ApplySpecialMaterial()
    {
        local ActorComponent_SpookSavedMaterials Saved;

        if (bSaveMaterials)
        {
            Saved = class'ActorComponent_SpookSavedMaterials'.static.FindOrCreate(HumanPawn);
            Saved.SaveMaterials(HumanPawn);
        }

        class'ActorComponent_SpookSavedMaterials'.static.SetMaterial(HumanPawn, SpecialMaterial);
    }

    function ResetMaterials()
    {
        local ActorComponent_SpookSavedMaterials Saved;
        Saved = class'ActorComponent_SpookSavedMaterials'.static.Find(HumanPawn);
        if (Saved != none)
        {
            Saved.ResetMaterials();
        }
    }

Begin:
    if (bResetMaterial)
    {
        ResetMaterials();
    }
    else
    {
        RequestSpecialMaterial();

        while (SpecialMaterial == None)
        {
            Sleep(0.0f);
        }

        ApplySpecialMaterial();
    }

    CompleteAction();
}

defaultproperties
{
    MaterialToSet="Spook.M_Shade"
    bSaveMaterials=true
}
