class ActorComponent_SpookSavedMaterials
    extends ActorComponent
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

struct native MeshComponentMaterial
{
    var MeshComponent MeshComp;
    var int ElementIndex;
    var MaterialInterface Mat;
};

var array<MeshComponentMaterial> Items;

static function ActorComponent_SpookSavedMaterials Find(Actor actor)
{
    local ActorComponent_SpookSavedMaterials Comp;
    foreach actor.ComponentList(class'ActorComponent_SpookSavedMaterials', Comp)
    {
        return Comp;
    }
    return none;
}

static function ActorComponent_SpookSavedMaterials FindOrCreate(Actor actor)
{
    local ActorComponent_SpookSavedMaterials Comp;
    Comp = Find(actor);
    if (Comp == none)
    {
        Comp = new class'ActorComponent_SpookSavedMaterials';
        actor.AttachComponent(Comp);
    }
    return Comp;
}

function SaveMaterials(Actor TheActor)
{
    local MeshComponent MeshComp;
    local MeshComponentMaterial Item;
    local int ElementIndex;

    Items.Remove(0, Items.Length);
    foreach TheActor.AllOwnedComponents(class'MeshComponent', MeshComp) // Static and Skeletal
    {
        for (ElementIndex = 0; ElementIndex < MeshComp.GetNumElements(); ++ElementIndex)
        {
            Item.MeshComp = MeshComp;
            Item.ElementIndex = ElementIndex;
            Item.Mat = MeshComp.GetMaterial(ElementIndex);
            Items.AddItem(Item);
            //`SPOOKLOG("Saving component " $ Item.MeshComp $ " element " $ Item.ElementIndex $ " material " $ Item.Mat);
        }
    }
}

static function SetMaterial(Actor TheActor, MaterialInterface NewMat)
{
    local MeshComponent MeshComp;
    local int ElementIndex;

    foreach TheActor.AllOwnedComponents(class'MeshComponent', MeshComp) // Static and Skeletal
    {
        for (ElementIndex = 0; ElementIndex < MeshComp.GetNumElements(); ++ElementIndex)
        {
            MeshComp.SetMaterial(ElementIndex, NewMat);
        }
    }
}

function ResetMaterials()
{
    local MeshComponentMaterial Item;
    foreach Items(Item)
    {
        //`SPOOKLOG("Restoring component " $ Item.MeshComp $ " element " $ Item.ElementIndex $ " material " $ Item.Mat);
        Item.MeshComp.SetMaterial(Item.ElementIndex, Item.Mat);
    }
}
