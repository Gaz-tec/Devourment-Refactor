ScriptName DevourmentDialog extends Quest conditional
{ None of this is in use yet. }
import Logging
import DevourmentUtil
import Devourment_JCDomain


DevourmentManager property Manager auto
String PREFIX = "DevourmentDialog"


Actor property PlayerRef auto
ReferenceAlias property DialogPredAlias auto
ReferenceAlias property DialogPreyAlias auto
Keyword property ActorTypeAnimal auto
DevourmentTalker property TheTalker auto

GlobalVariable property VoreDialog auto
GlobalVariable property Lethal auto conditional
GlobalVariable property Consented auto conditional
GlobalVariable property Locus auto conditional
GlobalVariable property NoEscape auto conditional


bool property Activated = false auto conditional

Function DoDialog_PlayerAndPrey(Actor prey, bool useTalkActivator = false)
{ Starts dialog with the player and their prey. }
	if VoreDialog.GetValue() == 0.0
		return
	endIf
	
	int preyData = Manager.GetPreyData(prey)
	
	if !assertExists(PREFIX, "DoDialog_PlayerAndPrey", "preyData", preyData) \
	|| !assertNotNone(PREFIX, "DoDialog_PlayerAndPrey", "prey", prey) \
	|| !assertNotSame(PREFIX, "DoDialog_PlayerAndPrey", PlayerRef, prey)
		return
	elseif prey.hasKeyword(ActorTypeAnimal) && !prey.hasKeyword(Manager.ActorTypeNPC) && !prey.HasKeyword(Manager.VoreTalker)
		Log2(PREFIX, "DoDialog_PlayerAndPrey", Namer(prey), "No dialog with critters!")
		return
	elseif Activated
		Log2(PREFIX, "DoDialog_PlayerAndPrey", Namer(prey), "Dialog already activated!")
		return
	endIf

	Activated = true
	Manager.RegisterBlocks("DoDialog_PlayerAndPrey", PlayerRef, prey)
	
	ObjectReference talker = prey
	float healthBefore = prey.GetActorValue("Health")
	
	if prey.HasKeyword(Manager.VoreTalker) || useTalkActivator
		TheTalker.PrepareForDialog(prey)
		talker = TheTalker
	else
		Manager.HideNearPred(PlayerRef, prey)
		talker = prey
	endIf
	
	DialogPredAlias.ForceRefTo(PlayerRef)
	DialogPreyAlias.ForceRefTo(prey)
	
	NoEscape.SetValue(Manager.IsNoEscape(preyData) as float)
	Consented.SetValue(Manager.IsConsented(preyData) as float)
	Lethal.SetValue(Manager.IsVore(preyData) as float)
	Locus.SetValue(Manager.GetLocus(preyData) as float)
	sendDialogEvent(PlayerRef, prey, !Lethal)

	int counter = 0
	while !talker.activate(PlayerRef) && counter < 20
		counter += 1
		Log2(PREFIX, "DoDialog_PlayerAndPrey", Namer(prey), "Failed to activate dialog. Waiting for 100ms.")
		Utility.wait(0.100)
	endWhile

	if counter < 20
		Log2(PREFIX, "DoDialog_PlayerAndPrey", Namer(prey), "Dialogue initiated.")
		ConsoleUtil.PrintMessage("Dialog initiated with " + Namer(prey))
		utility.wait(1.0)
		
		counter = 0
		while talker.isInDialogueWithPlayer() && counter < 300
			counter += 1
			ConsoleUtil.PrintMessage("Waiting for dialog to end.")
			Log2(PREFIX, "DoDialog_PlayerAndPrey", Namer(prey), "Waiting for dialog to terminate " + counter)
			utility.wait(2.0)
		endWhile
		
	else
		Log2(PREFIX, "DoDialog_PlayerAndPrey", Namer(prey), "Failed to activate dialog. Time expired.")
	endIf

	if talker == TheTalker
		TheTalker.ClearPrompt()
	else
		Manager.HideInStomach(prey)
	
		float healthAfter = prey.GetActorValue("Health")
		if healthAfter > healthBefore
			Log3(PREFIX, "", "Dealing damage to prey to restore their health.", healthBefore, healthAfter)
			prey.DamageActorValue("Health", healthAfter - healthBefore)
		endIf
	endIf

	Manager.UnregisterBlocks("DoDialog_PlayerAndPrey", PlayerRef, prey)
	DialogPredAlias.clear()
	DialogPreyAlias.clear()
	Activated = false
EndFunction



Function DoDialog_PlayerAndApex()
{ Starts dialog with the player and their apex predator. }
	if VoreDialog.GetValue() == 0.0
		return
	endIf
	
	int preyData = Manager.GetPreyData(PlayerRef)
	Actor apex = Manager.FindApex(PlayerRef)
	
	if !assertExists(PREFIX, "DoDialog_PlayerAndApex", "preyData", preyData) \
	|| !assertNotNone(PREFIX, "DoDialog_PlayerAndApex", "apex", apex) \
	|| !assertNotSame(PREFIX, "DoDialog_PlayerAndApex", PlayerRef, apex)
		return
	elseif apex.hasKeyword(ActorTypeAnimal) && !apex.hasKeyword(Manager.ActorTypeNPC)
		Log2(PREFIX, "DoDialog_PlayerAndApex", Namer(apex), "No dialog with critters!")
		return
	elseif Activated
		Log2(PREFIX, "DoDialog_PlayerAndApex", Namer(apex), "Dialog already activated!")
		return
	endIf

	Activated = true
	Manager.RegisterBlocks("DoDialog_PlayerAndApex", PlayerRef, apex)

	Manager.HideNearPred(apex, PlayerRef)

	DialogPredAlias.ForceRefTo(apex)
	DialogPreyAlias.ForceRefTo(PlayerRef)
	
	NoEscape.SetValue(Manager.IsNoEscape(preyData) as float)
	Consented.SetValue(Manager.IsConsented(preyData) as float)
	Lethal.SetValue(Manager.IsVore(preyData) as float)
	Locus.SetValue(Manager.GetLocus(preyData) as float)
	sendDialogEvent(apex, PlayerRef, !Lethal)
	
	int counter = 0
	while !apex.activate(PlayerRef, false) && counter < 20
		counter += 1
		Log2(PREFIX, "DoDialog_PlayerAndApex", Namer(apex), "Failed to activate dialog. Waiting for 100ms.")
		Utility.wait(0.100)
	endWhile

	if counter < 20
		Log2(PREFIX, "DoDialog_PlayerAndApex", Namer(apex), "Dialogue initiated.")
		ConsoleUtil.PrintMessage("Dialog initiated with " + Namer(apex))
		utility.wait(1.0)
		
		while apex.isInDialogueWithPlayer()
			ConsoleUtil.PrintMessage("Waiting for dialog to end.")
			Log2(PREFIX, "DoDialog_PlayerAndApex", Namer(apex), "Waiting for dialog to terminate.")
			utility.wait(1.0)
		endWhile
		
	else
		Log2(PREFIX, "DoDialog_PlayerAndApex", Namer(apex), "Failed to activate dialog. Time expired.")
	endIf

	Manager.HideLocally(apex, PlayerRef)

	Manager.UnregisterBlocks("DoDialog_PlayerAndApex", PlayerRef, apex)
	DialogPredAlias.clear()
	DialogPreyAlias.clear()
	Activated = false
EndFunction


Bool function createDialogEvent()
	Actor prey = DialogPreyAlias.getActorReference()
	Actor pred = DialogPredAlias.getActorReference()
	int preyData = Manager.GetPreyData(prey)
	bool endo = Manager.IsEndo(preyData)
	
	if prey && prey && JValue_isExists(preyData)
		SendDialogEvent(pred, prey, endo)
		return true
	else
		return false
	endIf
endFunction


Function Reset()
	Parent.Reset()
	DialogPredAlias.clear()
	DialogPreyAlias.clear()
	Activated = false
EndFunction


Function SendDialogEvent(Actor pred, Actor prey, bool endo) global
	int handle = ModEvent.create("Devourment_onDialog")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.pushBool(handle, endo)
	ModEvent.Send(handle)
EndFunction


DevourmentDialog Function instance() global
	return Quest.GetQuest("DevourmentDialog") as DevourmentDialog
EndFunction
