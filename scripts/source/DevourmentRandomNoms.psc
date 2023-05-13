Scriptname DevourmentRandomNoms extends Quest
import Logging


Actor property PlayerRef auto
DevourmentManager property Manager auto
Faction property RandomNoms auto
Keyword property BeingSwallowed auto
Keyword property ActorTypeNPC auto
Spell property ScriptedEndoSpell auto
Spell property ScriptedVoreSpell auto


float property NomsInterval = 10.0 auto
float property NomsRange = 488.0 auto
float property ScanRange = 2048.0 auto
float property NomsChance = 1.00 auto
int property NomsLimit = 10 auto
int property AutoNoms = 0 auto
	

String PREFIX = "DevourmentRandomNoms"
bool DEBUGGING = false


Event OnInit()
	;Log0(PREFIX, "OnInit")
	RegisterForSingleUpdate(NomsInterval)
EndEvent


Event OnUpdate()
	;Log0(PREFIX, "OnUpdate")

	if NomsChance > 0.0 && !PlayerRef.IsInCombat() && Utility.RandomFloat() < NomsChance && !Manager.paused
		if AutoNoms == 0
			SearchForNoms0()
		elseif AutoNoms == 1
			SearchForNoms1()
		elseif AutoNoms == 2
			SearchForNoms2()
		elseif AutoNoms == 3
			SearchForNoms3()
		endIf
	endIf

	if StorageUtil.FormListCount(self, "DVTPastPreds") > NomsLimit*2
		Actor pastPred = StorageUtil.FormListPluck(self, "DVTPastPreds", 0, None) as Actor
		Actor pastPrey = StorageUtil.FormListPluck(self, "DVTPastPreds", 0, None) as Actor
		if pastPred && pastPrey && Manager.Has(pastPred, pastPrey)
			Manager.RegisterVomit(pastPrey)
		endIf
	endIf

	RegisterForSingleUpdate(Utility.RandomFloat(nomsInterval, 1.5 * nomsInterval))
endEvent


Function SearchForNoms0()
	if !IsViablePrey(playerRef)
		if DEBUGGING
			Log1(PREFIX, "SearchForNoms0", "Player not viable as prey.")
		endIf
		return
	endIf

	Actor[] potentialPreds = MiscUtil.ScanCellNPCsByFaction(RandomNoms, PlayerRef, NomsRange)
	Actor[] viablePreds = PapyrusUtil.ActorArray(potentialPreds.length)
	int numViablePreds = 0

	int i = potentialPreds.length
	while i
		i -= 1
		Actor candidate = potentialPreds[i]

		if IsViablePredator(candidate)
			viablePreds[numViablePreds] = candidate
			numViablePreds += 1
		endIf
	endWhile

	if DEBUGGING
		LogActors(PREFIX, "SearchForNoms0", "viablePreds", viablePreds)
	endIf

	if numViablePreds == 0
		return
	else
		Actor pred = viablePreds[Utility.RandomInt(0, numViablePreds - 1)]
		DoANom(pred, playerRef)
	endIf
EndFunction


Function SearchForNoms1()
	; Find a prey.
	Actor prey = SearchForPrey_Player()
	if !prey
		return
	endIf

	; Find a predator.
	Actor pred = SearchForPred(prey)
	if !pred
		return
	endIf

	DoANom(pred, prey)
EndFunction


Function SearchForNoms2()
	; Find a prey.
	Actor prey = SearchForPrey_NonPlayer()
	if !prey
		return
	endIf

	; Find a predator.
	Actor pred = SearchForPred(prey)
	if !pred
		return
	endIf

	if pred.getLevel() < prey.getLevel() && !pred.IsPlayerTeammate() && IsViablePredator(prey) && IsViablePrey(pred)
		if Debugging
			Log1(PREFIX, "SearchForNom2", "Doing pred-Prey swap")
		endIf
		Actor temp = pred
		pred = prey
		prey = temp
	endIf

	DoANom(pred, prey)
EndFunction


Function SearchForNoms3()
	; Find a prey.
	Actor prey = SearchForPrey_Anyone()
	if !prey
		return
	endIf

	; Find a predator.
	Actor pred = SearchForPred(prey)
	if !pred
		return
	endIf

	if pred.getLevel() < prey.getLevel() && IsViablePredator(prey) && IsViablePrey(pred)
		if Debugging
			Log1(PREFIX, "SearchForNom3", "Doing pred-Prey swap")
		endIf
		Actor temp = pred
		pred = prey
		prey = temp
	endIf

	DoANom(pred, prey)
EndFunction


Actor Function SearchForPred(Actor prey)
	; Make a list of all potential predators in the area.
	Actor[] potentialPreds = MiscUtil.ScanCellNPCs(prey, NomsRange)

	; Filter the list of potential predators to make a new list of viable predators.
	Actor[] viablePreds = PapyrusUtil.ActorArray(potentialPreds.length)
	int numViablePreds = 0

	int i = potentialPreds.length
	while i
		i -= 1
		Actor candidate = potentialPreds[i]

		if candidate != prey && candidate != playerRef && IsViablePredator(candidate)
			viablePreds[numViablePreds] = candidate
			numViablePreds += 1
		endIf
	endWhile

	; Select the predator.
	Actor pred
	if numViablePreds > 0
		pred = viablePreds[Utility.RandomInt(0, numViablePreds - 1)]
	endIf	 
	
	if DEBUGGING
		LogActors(PREFIX, "SearchForPred", "potentialPreds", potentialPreds)
		LogActors(PREFIX, "SearchForPred", "viablePreds", viablePreds)
		Log1(PREFIX, "SearchForPred", "Selected predator: " + Namer(pred))
	endIf

	return pred
EndFunction


Actor Function SearchForPrey_Player()
	; Make a list of all potential prey in the area.
	Actor[] potentialPrey
	ObjectReference[] NearbyObjects

	if Manager.playerPreference == 2
		potentialPrey = new Actor[1]
		potentialPrey[0] = PlayerRef
	elseif Manager.playerPreference == 1
		NearbyObjects = PO3_SKSEFunctions.FindAllReferencesOfFormType(PlayerRef,62,ScanRange)
		int i = NearbyObjects.Length
		int count = 0
		while i
			Actor subject = NearbyObjects[i] as Actor
			if subject.IsPlayerTeammate()
				count += 1
			endIf
			i -= 1
		endWhile
		potentialPrey = PapyrusUtil.ActorArray(count)
		while i < NearbyObjects.Length
			Actor subject = NearbyObjects[i] as Actor
			if subject.IsPlayerTeammate()
				potentialPrey[count] = subject
				count -= 1
			endif
			i += 1
		endwhile
	else
		NearbyObjects = PO3_SKSEFunctions.FindAllReferencesOfFormType(PlayerRef,62,ScanRange)
		int i = NearbyObjects.Length
		int count = 0
		while i 
			Actor subject = NearbyObjects[i] as Actor
			if subject.IsPlayerTeammate()
				count += 1
			endIf
			i -= 1
		endWhile
		potentialPrey = PapyrusUtil.ActorArray(count)
		while i < NearbyObjects.Length
			Actor subject = NearbyObjects[i] as Actor
			if subject.IsPlayerTeammate()
				potentialPrey[count] = subject
				count -= 1
			endif
		endwhile
		potentialPrey = PapyrusUtil.PushActor(potentialPrey, PlayerRef)
	endIf

	; Filter the list of potential prey to make a new list of viable prey.
	Actor[] viablePrey = PapyrusUtil.ActorArray(potentialPrey.length)
	int numViablePrey = 0

	int i = potentialPrey.length
	while i
		i -= 1
		Actor candidate = potentialPrey[i]

		if IsViablePrey(candidate)
			viablePrey[numViablePrey] = candidate
			numViablePrey += 1
		endIf
	endWhile

	; Select the prey.
	Actor prey
	if numViablePrey > 0
		prey = viablePrey[Utility.RandomInt(0, numViablePrey - 1)]
	endIf

	if DEBUGGING
		LogActors(PREFIX, "SearchForPrey_Player", "potentialPrey", potentialPrey)
		LogActors(PREFIX, "SearchForPrey_Player", "viablePrey", viablePrey)
		Log1(PREFIX, "SearchForPrey_Player", "Selected prey: " + Namer(prey))
	endIf

	return prey
EndFunction


Actor Function SearchForPrey_NonPlayer()
	; Make a list of all potential prey in the area.
	Actor[] potentialPrey = MiscUtil.ScanCellNPCs(PlayerRef, ScanRange)

	; Filter the list of potential prey to make a new list of viable prey.
	Actor[] viablePrey = PapyrusUtil.ActorArray(potentialPrey.length)
	int numViablePrey = 0

	int i = potentialPrey.length
	while i
		i -= 1
		Actor candidate = potentialPrey[i]

		if candidate != playerRef && !candidate.IsPlayerTeammate() && IsViablePrey(candidate)
			viablePrey[numViablePrey] = candidate
			numViablePrey += 1
		endIf
	endWhile

	; Select the prey.
	Actor prey
	if numViablePrey > 0
		prey = viablePrey[Utility.RandomInt(0, numViablePrey - 1)]
	endIf

	if DEBUGGING
		LogActors(PREFIX, "SearchForPrey_NonPlayer", "potentialPrey", potentialPrey)
		LogActors(PREFIX, "SearchForPrey_NonPlayer", "viablePrey", viablePrey)
		Log1(PREFIX, "SearchForPrey_NonPlayer", "Selected prey: " + Namer(prey))
	endIf

	return prey
EndFunction


Actor Function SearchForPrey_Anyone()
	; Make a list of all potential prey in the area.
	Actor[] potentialPrey = MiscUtil.ScanCellNPCs(PlayerRef, ScanRange)

	; Filter the list of potential prey to make a new list of viable prey.
	Actor[] viablePrey = PapyrusUtil.ActorArray(potentialPrey.length)
	int numViablePrey = 0

	int i = potentialPrey.length
	while i
		i -= 1
		Actor candidate = potentialPrey[i]

		if IsViablePrey(candidate)
			viablePrey[numViablePrey] = candidate
			numViablePrey += 1
		endIf
	endWhile

	; Select the prey.
	Actor prey
	if numViablePrey > 0
		prey = viablePrey[Utility.RandomInt(0, numViablePrey - 1)]
	endIf

	if DEBUGGING
		LogActors(PREFIX, "SearchForPrey_Anyone", "potentialPrey", potentialPrey)
		LogActors(PREFIX, "SearchForPrey_Anyone", "viablePrey", viablePrey)
		Log1(PREFIX, "SearchForPrey_Anyone", "Selected prey: " + Namer(prey))
	endIf

	return prey
EndFunction


bool Function IsViablePredator(Actor pred)
	if DEBUGGING
		Log1(PREFIX, "ViablePredator", Namer(pred))
	endIf
	Pred.GetCombatState() ; QueueSD11: The Creation Kit's page for GetCombatState() says its unreliable the FIRST time. Call it on nothing, then call it for real.
	return pred && !pred.isDead() && !pred.isDisabled() && !pred.isChild() && !pred.IsInDialogueWithPlayer() \
	&& pred.GetCombatState() == 0 && !Manager.IsPrey(pred) && Manager.validPredator(pred) && pred.GetSleepState() < 3 \
	&& !Manager.IsBlocked(pred)
EndFunction


bool Function IsViablePrey(Actor prey)
	if DEBUGGING
		Log1(PREFIX, "ViablePrey", Namer(prey))
	endIf

	return prey && !prey.isDead() && !prey.isDisabled() && !prey.isChild() && !prey.IsInDialogueWithPlayer() \
	&& prey.GetCombatState() == 0 && !Manager.IsPrey(prey) && !prey.IsWeaponDrawn() && !Manager.IsBlocked(prey)
EndFunction


Function DoANom(Actor pred, Actor prey)
{ Don't swallow anyone who is already being swallowed or too far away or will make the pred too full. Print out appropriate debugging messages.	}

	Log3(PREFIX, "DoANom", "RandomNom prepared:", Namer(pred), Namer(prey))

	if !Manager.HasRoomForPrey(pred, prey)
		if DEBUGGING
			Log1(PREFIX, "DoANom", "Too full, inducing vomit.")
		endIf
		Manager.RegisterVomitAll(pred)

	elseif PlayerCheck(prey)
		ConsoleUtil.PrintMessage(Namer(pred) + " is trying to nom " + Namer(prey, true) + "!")
		ScriptedEndoSpell.Cast(pred, prey)
		StorageUtil.FormListAdd(self, "DVTPastPreds", pred, true)
		StorageUtil.FormListAdd(self, "DVTPastPreds", prey, true)
	endIf
EndFunction
	

bool Function PlayerCheck(Actor target)
	if target == PlayerRef
		return Manager.playerPreference != 1
	else
		return Manager.playerPreference != 2
	endIf
EndFunction


bool Function LoadedCheck(Actor pred)
	if !pred.Is3DLoaded()
		Log1(PREFIX, "LoadedCheck", "Dispelling")
		UnregisterForUpdate()
		pred = none
		return false
	else
		if DEBUGGING
			Log1(PREFIX, "LoadedCheck", "Passed")
		endIf
		return true
	endIf
EndFunction
