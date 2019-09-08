class UIScreenListener_UIChooseClass_Spook
    extends UIScreenListener
    config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

event OnInit(UIScreen Screen)
{
    local UIChooseClass ChooseClass;
    local X2SoldierClassTemplateManager SoldierClassTemplateManager;
    local X2SoldierClassTemplate SpookClass, ExistingClass;
    local Commodity Commodity;
    local UIInventory_ListItem ListItem;
    local int i;

    SoldierClassTemplateManager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
    SpookClass = SoldierClassTemplateManager.FindSoldierClassTemplate('Spook');

    ChooseClass = UIChooseClass(Screen);

    for (i = 0; i < ChooseClass.m_arrClasses.Length; ++i)
    {
        ExistingClass = ChooseClass.m_arrClasses[i];
        if (ExistingClass.DataName == SpookClass.DataName)
        {
            // We're already listed.
            `SPOOKLOG("Spooks can already be trained");
            return;
        }
    }

    ChooseClass.m_arrClasses.AddItem(SpookClass);

    Commodity.Title = SpookClass.DisplayName;
    Commodity.Image = SpookClass.IconImage;
    Commodity.Desc = SpookClass.ClassSummary;
    Commodity.OrderHours = `XCOMHQ.GetTrainRookieDays() * 24;
    ChooseClass.arrItems.AddItem(Commodity);

    ListItem = ChooseClass.Spawn(class'UIInventory_ClassListItem', ChooseClass.List.itemContainer);
    ListItem.InitInventoryListCommodity(Commodity,, ChooseClass.GetButtonString(i), ChooseClass.m_eStyle,, 126);
    `SPOOKLOG("Added Spook as a trainable class");
}

defaultProperties
{
    ScreenClass = UIChooseClass
}
