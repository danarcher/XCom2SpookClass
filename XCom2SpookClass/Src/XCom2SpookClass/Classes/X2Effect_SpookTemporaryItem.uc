// Adapted from code by Amineri (Pavonis Interactive)
class X2Effect_SpookTemporaryItem extends X2Effect_Persistent;

`include(XCom2SpookClass\Src\Spook.uci)

struct ResearchConditional
{
    var name ResearchProjectName;
    var name ItemName;
};

var name ItemName;
var array<name> AlternativeItemNames;
var array<ResearchConditional> ResearchOptionalItems;
var array<name> AdditionalAbilities;
var array<name> ForceCheckAbilities;
var bool bIgnoreItemEquipRestrictions;
var bool bReplaceExistingItemOnly;
var name ExistingItemName;
var bool bOverrideInventorySlot;
var EInventorySlot InventorySlotOverride;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local XComGameState_HeadquartersXCom        XComHQ;
    local ResearchConditional                   Conditional;
    local name                                  UseItemName, AltItemName;
    local XComGameState_Unit                    UnitState;
    local XComGameState_Item                    OldItemState, UpdatedItemState, NewItemState;
    local X2EquipmentTemplate                   EquipmentTemplate;
    local X2WeaponTemplate                      WeaponTemplate;
    local XComGameState_Effect_SpookTemporaryItem EffectComponent;
    local Object                                ListenerObj;
    local EInventorySlot                        InventorySlot;


    UnitState = XComGameState_Unit(kNewTargetState);
    if (UnitState == none)
        return;

    XComHQ = `XCOMHQ;
    UseItemName = ItemName;
    //check if we meet any of the optional research conditions to add a better item
    foreach ResearchOptionalItems(Conditional)
    {
        if(XComHQ.IsTechResearched(Conditional.ResearchProjectName))
        {
            UseItemName = Conditional.ItemName;
            break;
        }
    }

    EquipmentTemplate = X2WeaponTemplate(class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate(UseItemName));
    if(bOverrideInventorySlot)
        InventorySlot = InventorySlotOverride;
    else
        InventorySlot = EquipmentTemplate.InventorySlot;

    if(bReplaceExistingItemOnly)
        OldItemState = GetItem(UnitState, ExistingItemName);
    else
        OldItemState = GetItem(UnitState, UseItemName);

    if(OldItemState == none && !bReplaceExistingItemOnly)
    {
        //check and see if any of the alternative options are available to replace before adding a new item
        foreach AlternativeItemNames(AltItemName)
        {
            OldItemState = GetItem(UnitState, AltItemName);
            if(OldItemState != none)
            {
                UseItemName = AltItemName;
                EquipmentTemplate = X2WeaponTemplate(class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate(UseItemName));
                if(EquipmentTemplate != none)
                    break;
            }
        }
    }

    if (EquipmentTemplate == none)
        return;

    if(OldItemState == none && bReplaceExistingItemOnly)
        return;

    if (OldItemState != none && !bReplaceExistingItemOnly)
    {
        // The unit has this item already, so add ammo/charges if appropriate, otherwise silently ignore
        WeaponTemplate = X2WeaponTemplate(EquipmentTemplate);
        if (WeaponTemplate != none && WeaponTemplate.bMergeAmmo)
        {
            UpdatedItemState = XComGameState_Item(NewGameState.CreateStateObject(OldItemState.Class, OldItemState.ObjectID));
            UpdatedItemState.Ammo += WeaponTemplate.iClipSize;
            NewGameState.AddStateObject(UpdatedItemState);
        }
    }
    else // Unit either doesn't have item, or it has it and it has to be replaced
    {
        // Create a new XCGS_Item instance
        NewItemState = AddNewItemToUnit(EquipmentTemplate, UnitState, InventorySlot, NewGameState);

        if(bReplaceExistingItemOnly)
        {
            //transfer ammo information over
            NewItemState.Ammo = OldItemState.Ammo;
            NewItemState.MergedItemCount = OldItemState.MergedItemCount;

            //mark old item as having no ammo -- this hides grenades and the like
            OldItemState.Ammo = 0;
            OldItemState.MergedItemCount = 0;
            OldItemState.bMergedOut = true;
            NewGameState.AddStateObject(OldItemState);
        }

        //check and see if the effect component has already been created by another temporary item
        EffectComponent = GetEffectComponent(NewEffectState);

        if(EffectComponent == none) // doesn't exist, so create and link it
        {
            EffectComponent = XComGameState_Effect_SpookTemporaryItem(NewGameState.CreateStateObject(class'XComGameState_Effect_SpookTemporaryItem'));
            NewEffectState.AddComponentObject(EffectComponent);
            NewGameState.AddStateObject(NewEffectState);
        }

        EffectComponent.TemporaryItems.AddItem(NewItemState.GetReference());
        NewGameState.AddStateObject(EffectComponent);
    }

    ListenerObj = EffectComponent;
    `XEVENTMGR.RegisterForEvent(ListenerObj, 'TacticalGameEnd', EffectComponent.OnTacticalGameEnd, ELD_OnStateSubmitted);

    super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated function XComGameState_Item AddNewItemToUnit(X2EquipmentTemplate EquipmentTemplate, XComGameState_Unit UnitState, EInventorySlot InventorySlot, XComGameState NewGameState)
{
    local XComGameStateHistory          History;
    local XGUnit                        Visualizer;
    local XComGameState_Item            ItemState, TempItem;
    local X2AbilityTemplateManager      AbilityManager;
    local X2AbilityTemplate             AbilityTemplate;
    local bool                          bCachedIgnoredItemEquipRestrictions;
    local array<name>                   EquipmentAbilities;
    local name                          AbilityName;
    local StateObjectReference          AbilityRef;
    local XComGameState_Ability         AbilityState;

    History = `XCOMHISTORY;
    AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

    Visualizer = XGUnit(UnitState.GetVisualizer());

    // Create a new XCGS_Item instance
    ItemState = EquipmentTemplate.CreateInstanceFromTemplate(NewGameState);
    NewGameState.AddStateObject(ItemState);
    NewGameState.AddStateObject(UnitState);

    bCachedIgnoredItemEquipRestrictions = UnitState.bIgnoreItemEquipRestrictions;
    UnitState.bIgnoreItemEquipRestrictions = bIgnoreItemEquipRestrictions;

    // Add the temporary item to the unit's inventory, adding the new state object to the NewGameState container
    if(!UnitState.AddItemToInventory(ItemState, InventorySlot, NewGameState))
        `REDSCREEN("TempItem : Failed to add Item" @ ItemState.GetMyTemplateName() @ "to inventory.");

    UnitState.bIgnoreItemEquipRestrictions = bCachedIgnoredItemEquipRestrictions;

    // At this point the item has been created and added to the unit's inventory, but any item (or additional) abilities have yet to be added
    EquipmentAbilities = GatherAbilitiesForItem(EquipmentTemplate);

    //first, create any abilities that are missing
    foreach EquipmentAbilities(AbilityName)
    {
        `SPOOKLOG("TempItem: Testing to add" @ AbilityName);
        AbilityRef = UnitState.FindAbility(AbilityName, ItemState.GetReference());
        if(AbilityRef.ObjectID == 0)
        {
            `SPOOKLOG("TempItem:" @ AbilityName @ "/Item combo not found, adding.");
            AddAbilityToUnit(AbilityName, UnitState, ItemState.GetReference(), NewGameState);
        }
        AbilityRef = UnitState.FindAbility(AbilityName, ItemState.GetReference());
        if(AbilityRef.ObjectID > 0)
            `SPOOKLOG("TempItem : Post AddAbilityToUnit -- Ability + Item combo found");
        else
            `SPOOKLOG("TempItem : Post AddAbilityToUnit -- Ability + Item combo NOT found");
    }

    //special handling for LaunchGrenade and maybe some other stuff
    foreach ForceCheckAbilities(AbilityName)
    {
        `SPOOKLOG("TempItem : Checking ability" @ AbilityName @ "on unit:" @ UnitState.GetFullName());
        AbilityRef = UnitState.FindAbility(AbilityName);
        if(AbilityRef.ObjectID > 0)
        {
            AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
            `SPOOKLOG("TempItem :" @ AbilityName @ "found, adding for new ammo type.");
            if(AbilityState.SourceWeapon.ObjectId > 0)
            {
                TempItem = XComGameState_Item(History.GetGameStateForObjectID(AbilityState.SourceWeapon.ObjectID));
                `SPOOKLOG("TempItem : Adding" @ ItemState.GetMyTemplate().GetItemFriendlyName() @ "as ammo to" @ TempItem.GetMyTemplate().GetItemFriendlyName());

                //AddAbilityToUnit(AbilityName, UnitState, ItemState.GetReference(), NewGameState, ItemState.GetReference());   // try and use AddToAbility helper to add item as weapon/ammo for launch grenade
                //AddAbilityToUnit(AbilityName, UnitState, AbilityState.SourceWeapon, NewGameState, ItemState.GetReference());  // try and use AddToAbility helper to add launcher/ammo ability mapping

                AbilityTemplate = AbilityManager.FindAbilityTemplate(AbilityName);
                `TACTICALRULES.InitAbilityForUnit(AbilityTemplate, UnitState, NewGameState, AbilityState.SourceWeapon, ItemState.GetReference());
            }
            else
            {
                `REDSCREEN("TempItem : No source weapon found for AbilityName=" $ AbilityName);
            }
        } else {
            if(UnitState.HasSoldierAbility(AbilityName)) {
                AbilityTemplate = AbilityManager.FindAbilityTemplate(AbilityName);
                `TACTICALRULES.InitAbilityForUnit(AbilityTemplate, UnitState, NewGameState, UnitState.GetSecondaryWeapon().GetReference(), ItemState.GetReference());
            }
        }
        AbilityRef = UnitState.FindAbility(AbilityName, ItemState.GetReference());
        if(AbilityRef.ObjectID > 0)
            `SPOOKLOG("TempItem : Post AddAbilityToUnit -- Ability + Item combo found");
        else
            `SPOOKLOG("TempItem : Post AddAbilityToUnit -- Ability + Item combo NOT found");
    }

    //Create the visualizer for the new item, and attach it if needed
    Visualizer.ApplyLoadoutFromGameState(UnitState, NewGameState);

    return ItemState;
}

static function XComGameState_Effect_SpookTemporaryItem GetEffectComponent(XComGameState_Effect Effect)
{
    if (Effect != none)
        return XComGameState_Effect_SpookTemporaryItem(Effect.FindComponentObject(class'XComGameState_Effect_SpookTemporaryItem'));
    return none;
}

static function XComGameState_Item GetItem(XComGameState_Unit Unit, name TemplateName, optional XComGameState CheckGameState)
{
    local array<XComGameState_Item> Items;
    local XComGameState_Item Item;

    Items = Unit.GetAllInventoryItems(CheckGameState);
    foreach Items(Item)
    {
        if(Item.GetMyTemplateName() == TemplateName && !Item.bMergedOut)
            return Item;
    }
    return none;
}

function array<name> GatherAbilitiesForItem(X2EquipmentTemplate EquipmentTemplate)
{
    local name AbilityName, AdditionalAbilityName;
    local array<name> EquipmentAbilities;
    local X2AbilityTemplateManager AbilityTemplateMan;
    local X2AbilityTemplate AbilityTemplate, AdditionalAbilityTemplate;

    AbilityTemplateMan = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

    EquipmentAbilities = AdditionalAbilities;

    if (EquipmentTemplate != none)
    {
        foreach EquipmentTemplate.Abilities(AbilityName)
        {
            AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate(AbilityName);
            if (AbilityTemplate != none && AbilityName != 'SmallItemWeight' && EquipmentAbilities.Find(AbilityName) == INDEX_NONE) // add ability if not duplicate
            {
                EquipmentAbilities.AddItem(AbilityName);
                foreach AbilityTemplate.AdditionalAbilities(AdditionalAbilityName)  // handle any additional abilities
                {
                    AdditionalAbilityTemplate = AbilityTemplateMan.FindAbilityTemplate(AdditionalAbilityName);
                    if (AdditionalAbilityTemplate != none && EquipmentAbilities.Find(AdditionalAbilityName) == INDEX_NONE)
                    {
                        EquipmentAbilities.AddItem(AdditionalAbilityName);
                    }
                    else if (AdditionalAbilityTemplate == none)
                    {
                        `RedScreen("Equipment template" @ EquipmentTemplate.DataName @ "specifies unknown additional ability:" @ AdditionalAbilityName);
                    }
                }
            }
            else if (AbilityTemplate == none)
            {
                `RedScreen("Equipment template" @ EquipmentTemplate.DataName @ "specifies unknown ability:" @ AbilityName);
            }
        }
    }
    return EquipmentAbilities;
}

function array<X2AbilityTemplate> AddAbilityToUnit(name AbilityName, XComGameState_Unit AbilitySourceUnitState, StateObjectReference ItemRef, XComGameState NewGameState, optional StateObjectReference AmmoRef)
{
    local X2AbilityTemplate RootAbilityTemplate, AbilityTemplate;
    local array<X2AbilityTemplate> AllAbilityTemplates, ReturnAbilityTemplates;
    local X2AbilityTemplateManager AbilityManager;
    local StateObjectReference AbilityRef;
    local XComGameState_Ability AbilityState;
    local Name AdditionalAbilityName;

    AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
    RootAbilityTemplate = AbilityManager.FindAbilityTemplate(AbilityName);

    if( RootAbilityTemplate != none )
    {
        AllAbilityTemplates.AddItem(RootAbilityTemplate);
        foreach RootAbilityTemplate.AdditionalAbilities(AdditionalAbilityName)
        {
            AbilityTemplate = AbilityManager.FindAbilityTemplate(AdditionalAbilityName);
            if( AbilityTemplate != none )
            {
                AllAbilityTemplates.AddItem(AbilityTemplate);
            }
        }
    }

    foreach AllAbilityTemplates(AbilityTemplate)
    {
        AbilityRef = AbilitySourceUnitState.FindAbility(AbilityTemplate.DataName, ItemRef);
        if( AbilityRef.ObjectID == 0 )
        {
            AbilityRef = `TACTICALRULES.InitAbilityForUnit(AbilityTemplate, AbilitySourceUnitState, NewGameState, ItemRef, AmmoRef);
            ReturnAbilityTemplates.AddItem(AbilityTemplate);
        }

        AbilityState = XComGameState_Ability(NewGameState.CreateStateObject(class'XComGameState_Ability', AbilityRef.ObjectID));
        NewGameState.AddStateObject(AbilityState);
    }
    return ReturnAbilityTemplates;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
    local XComGameState_BaseObject EffectComponent;
    local XComGameState_Effect_SpookTemporaryItem TempItemComponent;
    local Object EffectComponentObj;

    super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

    EffectComponent = GetEffectComponent(RemovedEffectState);
    if (EffectComponent == none)
        return;

    TempItemComponent = XComGameState_Effect_SpookTemporaryItem(EffectComponent);
    if (TempItemComponent == none)
        return;

    //manually clean up the temporary items
    TempItemComponent.OnTacticalGameEnd(none, none, none, '');

    EffectComponentObj = EffectComponent;
    `XEVENTMGR.UnRegisterFromAllEvents(EffectComponentObj);

    NewGameState.RemoveStateObject(EffectComponent.ObjectID);
}

defaultProperties
{
    bInfiniteDuration = true;
}
