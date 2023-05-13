Scriptname DevourmentSpellDistribution extends Quest
{
AUTHOR: Gaz
PURPOSE: Simple injector Quest to distribute Devourment spells to shop inventories.
}

Event OnInit()

    Utility.Wait(5.0)   ;Potentially dangerous due to suspended stack but is simpler than waiting for chargen to end.
    AddSpells()

EndEvent

Function AddSpells()

    Book TouchvoreBook = Game.GetFormFromFile(0x000009ED, "Devourment.esp") as Book

    ObjectReference MerchantRiverwoodTraderChest = Game.GetForm(0x00078C0C) as ObjectReference
    MerchantRiverwoodTraderChest.AddItem(TouchvoreBook, 1)

    LeveledItem LItemSpellTomes25AllAlteration  = Game.GetForm(0x000A297D) as LeveledItem
    LItemSpellTomes25AllAlteration.AddForm(TouchvoreBook, 1, 1)

    Book BellyportBook = Game.GetFormFromFile(0x00000DCD, "Devourment.esp") as Book
    Book TelegulpBook = Game.GetFormFromFile(0x00000DCE, "Devourment.esp") as Book

    LeveledItem LItemSpellTomes50AllAlteration  = Game.GetForm(0x000A298C) as LeveledItem
    LItemSpellTomes50AllAlteration.AddForm(BellyportBook, 1, 1)
    LItemSpellTomes50AllAlteration.AddForm(TelegulpBook, 1, 1)
    Debug.Notification("Devourment Spells added to Vendors.")

EndFunction