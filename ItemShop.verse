using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Device Configuration:
# 1.  Set the 'Cashier' Conditional Button Device's Key Item to use the currency type you want (Gold, etc).
# 2.  Set the HUD Message Device to 'Message Recipient:  Triggering Player'.
# 3.  Set the Button Device to the desired Interact Time.
# 4.  Add the Item being purchased to the Item List of the Item Granter.

shop_device := class(creative_device):

    @editable
    Cashier: conditional_button_device = conditional_button_device{}

    @editable
    HUDMessage: hud_message_device = hud_message_device{}

    @editable
    ShopItems: []shop_item = array{}
    
    MakeMessage<localizes>(Text: string): message = "{Text}"

    OnBegin<override>()<suspends>:void=
        ShopSetup()

    ShopSetup(): void =
        for (Item : ShopItems):
            Item.Init(Self)

    ShowHUDMessage(Agent: agent, Text: string): void =
        HUDMessage.SetText(MakeMessage(Text))
        HUDMessage.Show(Agent)

shop_item := class<concrete>():

    var VerseDevice: shop_device = shop_device{}

    @editable
    ItemName: string = "Item"
    @editable
    ItemName: string = "Item"
    @editable
    ItemCost: type{X: int where X >= 0} = 10

    @editable
    Button: button_device = button_device{}

    @editable
    ItemGranter: item_granter_device = item_granter_device{} 

    MakeMessage<localizes>(Text: string): message = "{Text}"

    Init(MainDevice: shop_device): void =
        set VerseDevice = MainDevice
        Button.InteractedWithEvent.Subscribe(PurchaseAttempt)
        if (ItemCost > 0):
            Button.SetInteractionText(MakeMessage("Purchase {ItemName}"))

        else:
            Button.SetInteractionText(MakeMessage("Pick Up {ItemName}"))

    PurchaseAttempt(Agent: agent): void =
        if (ItemCost > 0):
            PlayerGold := VerseDevice.Cashier.GetItemCount(Agent, 0)
            if (PlayerGold >= ItemCost):
                VerseDevice.Cashier.SetItemCountRequired(0, ItemCost)
                VerseDevice.Cashier.Activate(Agent)
                ItemGranter.GrantItem(Agent)
                VerseDevice.ShowHUDMessage(Agent, "Purchased {ItemName}.")

            else:
                VerseDevice.ShowHUDMessage(Agent, "Not enough resources.")

        else:
            ItemGranter.GrantItem(Agent)
            VerseDevice.ShowHUDMessage(Agent, "Obtained {ItemName}.")