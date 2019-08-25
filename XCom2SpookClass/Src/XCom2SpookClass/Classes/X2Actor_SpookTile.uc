class X2Actor_SpookTile
    extends StaticMeshActor
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var StaticMesh ConcealmentBreakTileMesh;
var StaticMeshComponent ConcealmentBreakTileRenderer;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    ConcealmentBreakTileMesh = StaticMesh(`CONTENT.RequestGameArchetype("Spook.Tile.ConcealmentBreakTile")); // UI_3D.Tile.SoundTile, UI_3D.Tile.ConcealmentTile_Enter
    if (ConcealmentBreakTileMesh != none)
    {
        ConcealmentBreakTileRenderer.SetStaticMesh(ConcealmentBreakTileMesh);
    }
    else
    {
        `RedScreen("X2Actor_SpookTile: ConcealmentBreakTileMesh not loaded");
    }
}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=ConcealmentBreakTileRenderer0
        bOwnerNoSee=false
        CastShadow=false
        CollideActors=false
        BlockActors=false
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        BlockRigidBody=false
        HiddenGame=false
        HideDuringCinematicView=true
    End object
    ConcealmentBreakTileRenderer=ConcealmentBreakTileRenderer0
    Components.Add(ConcealmentBreakTileRenderer0)

    bStatic=false
    bWorldGeometry=false
    bMovable=true
}
