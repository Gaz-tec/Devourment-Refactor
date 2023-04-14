ScriptName DevourmentNewDova extends Quest
import DevourmentUtil
import Logging


Actor property FakePlayer auto
Actor property playerRef auto
DevourmentManager Property Manager auto
DialogueFollowerScript property FollowerQuest auto
DLC1RadiantScript property RadiantCrimeScript auto
EffectShader property AbsorbVisual auto
Explosion property AbsorbExplosion auto
Faction[] property ImportantFactions auto
Faction property PlayerMarriedFaction auto
GlobalVariable property prevDovBountyPale auto
GlobalVariable property prevDovBountyFalkreath auto
GlobalVariable property prevDovBountyReach auto
GlobalVariable property prevDovBountyHjaalmarch auto
GlobalVariable property prevDovBountyRift auto
GlobalVariable property prevDovBountyHaafingar auto
GlobalVariable property prevDovBountyWhiterun auto
GlobalVariable property prevDovBountyEastmarch auto
GlobalVariable property prevDovBountyWinterhold auto
Message property NewDovaMessage auto
Message property NewDovaCreature auto
Perk[] Property VorePerks Auto
Perk[] property AllThePerks auto
Quest property BreakupQuest auto
Quest property MarriageFINQuest auto
Quest property MarriageQuest auto
Quest property WeddingQuest auto
ReferenceAlias property fakePlayerRef auto
Sound property AbsorbFinishSound auto
Sound property AbsorbSound auto
String[] property AVList auto


Actor property deadDovaRef = none auto
Actor property newDovaRef = none auto


bool property nameChanged = false auto
int property prevDov = 0 auto
String property newName = "" auto
String property previousName = "" auto
String PREFIX = "DevourmentNewDova"
String PlayableMonsterDataFile = "data\\skse\\plugins\\devourment\\PlayableMonsterModData.json"


;-- Functions ---------------------------------------


Event OnInit()
	SetPlayerName()
EndEvent


Function SetPlayerName()
	if nameChanged
		Log2(PREFIX, "SetPlayerName", nameChanged, newName)
		playerRef.getLeveledActorBase().setName(newName)
		playerRef.SetDisplayName(newName)
	endIf
endFunction


Function ClearPlayerName()
	nameChanged = false
	newName = PlayerRef.getLeveledActorBase().getName()
	Log2(PREFIX, "ClearPlayerName", nameChanged, newName)
endFunction


function SwitchPlayer(Actor pred)
	Log2(PREFIX, "SwitchPlayer", Namer(pred), Namer(playerRef))

	if !assertNotNone(PREFIX, "SwitchPlayer", "pred", pred) \
	|| !assertNotSame(PREFIX, "SwitchPlayer", pred, playerRef)
		return
	endIf

	Game.FadeOutGame(true, true, 0.0, 0.5)

	deadDovaRef = newDovaRef ; Store this in case we need it later....
	newDovaRef = pred

	ActorBase predBase = pred.getLeveledActorBase()
	ActorBase playerBase = playerRef.getLeveledActorBase()
	ActorBase fakeBase = fakePlayer.getLeveledActorBase()
	bool creature = pred.hasKeyword(Manager.ActorTypeCreature)

	prevDov += 1
	AbsorbVisual.play(pred, 5.0)
	AbsorbSound.play(pred)
	previousName = playerBase.getName()
	newName = predBase.getName()
	nameChanged = true
	SetPlayerName()

	fakeBase.setName(previousName)
	fakePlayer.setName(previousName)
	fakePlayer.setRace(playerRef.getRace())
	fakePlayer.setScale(playerRef.getScale())
	
	if fakeBase.getSex() != playerBase.getSex()
		ConsoleUtil.ExecuteCommand(Hex32(fakeBase.GetFormID()) + ".sexchange")
	endIf
	
	fakePlayerRef.forceRefTo(fakePlayer)
	
	; Attempt to copy the pred's appearance and race to the pred.
	if creature
		playerRef.SetRace(predBase.getRace())
		playerRef.SetHeadTracking(false)
		playerRef.UnequipAll()
	else
		RaceMenuMimic.mimic(playerRef, pred)
	endIf

	; Adjust the player's weight and scale to match the pred.
	playerRef.SetWeight(pred.GetWeight())
	playerBase.SetWeight(predBase.GetWeight())
	playerRef.SetScale(pred.GetScale())
	playerBase.SetHeight(predBase.GetHeight())
	
	; Make the player visible again.
	Manager.unGhostify(playerRef)

	; Heal the player. Fresh start!
	float damage = PlayerRef.GetBaseActorValue("Health") - PlayerRef.GetActorValue("Health")
	if damage > 0.0
		PlayerRef.RestoreActorValue("Health", damage)
	endIf

	; Transfer the predator's inventory to the player.
	if creature
		pred.removeAllItems(playerRef)
	else
		TransferEquipment(pred, playerRef)
	endIf
	
	StoreBounties()
	TerminateRelationships()

	;ObjectReference loc = pred.placeAtMe(AbsorbExplosion, 1, false, false)
	AbsorbFinishSound.play(pred)
	pred.disable()
	
	Manager.reappearPreyAt(playerRef, pred)

	if !creature
		if NewDovaMessage.show() >= 2
			Utility.wait(0.5)
			game.ShowRaceMenu()
		endIf
	elseif Game.IsPluginInstalled("Playable Monster Mod.esp")
		if !ApplyPlayableMonsterSpell(pred)
			Log1(PREFIX, "SwitchPlayer", "Playable Monster Mod failure: manual creature conversion.")
			Game.ForceThirdPerson()
			Game.ShowFirstPersonGeometry(false)
			Game.DisablePlayerControls(false, true, false, false, false, True, true, false, 0)
			Game.SetPlayerReportCrime(false)
		endIf
	else
		Log1(PREFIX, "SwitchPlayer", "Manual creature conversion.")
		Game.ForceThirdPerson()
		Game.ShowFirstPersonGeometry(false)
		Game.DisablePlayerControls(false, true, false, false, false, True, true, false, 0)
	    Game.SetPlayerReportCrime(false)
	endif

	playerRef.stopCombat()
	playerRef.stopCombatAlarm()

	RegisterForModEvent("Devourment_FinishNewDova", "FinishNewDova")
	int handle = ModEvent.Create("Devourment_FinishNewDova")
	ModEvent.PushForm(handle, pred)
	ModEvent.PushBool(handle, creature)
	ModEvent.send(handle)

	Log1(PREFIX, "SwitchPlayer", "COMPLETED")
endFunction


Event FinishNewDova(Form f1, bool creature)
	Actor pred = f1 as Actor
	if pred
		if !creature
			TransferStats(pred, pred.GetLeveledActorBase(), PlayerRef)
		endIf
		TransferFactions(pred, PlayerRef)
	EndIf

	Game.FadeOutGame(false, true, 0.0, 0.5)
	playerRef.stopCombat()
	playerRef.stopCombatAlarm()
EndEvent


Function TransferStats(Actor source, ActorBase sourceBase, Actor dest)
	Int which = AVList.length
	while which > 0
		which -=  1
		String skill = AVList[which]
		float val = source.getBaseActorValue(skill)
		dest.setActorValue(skill, val)
		dest.forceActorValue(skill, val)
	endWhile

	Int spellCount = source.getSpellCount()
	while spellCount > 0
		spellCount -= 1
		playerRef.addSpell(source.getNthSpell(spellCount), false)
	endWhile

	spellCount = sourceBase.getSpellCount()
	while spellCount > 0
		spellCount -= 1
		playerRef.addSpell(sourceBase.getNthSpell(spellCount), false)
	endWhile

	Int whichPerk = AllThePerks.length
	while whichPerk > 0
		whichPerk -= 1
		Perk p = AllThePerks[whichPerk]
		if dest.hasPerk(p)
			dest.removePerk(p)
		endif
	endWhile

	Game.setPerkPoints(playerRef.getLevel() - 1)

	int vorePerkPoints = 0
	whichPerk = VorePerks.length
	while whichPerk > 0
		whichPerk -= 1
		Perk p = VorePerks[whichPerk]

		if dest.HasPerk(p)
			dest.removePerk(p)
			vorePerkPoints += 1
		endif
	endwhile

	Manager.Devourment_PerkPoints.Mod(vorePerkPoints as float)
	;Log(PREFIX, "SwitchPlayer", "done " + VorePerks.length + " vore perks and " + AllThePerks.length + " regular perks.")

	;Log(PREFIX, "SwitchPlayer", "changed skills")

	;float sourceSkill = PredData.getVoreSkill(source)
	;float destSkill = PredData.getVoreSkill(dest)
	;int voreLevel = StorageUtil.getIntValue(source, "voreLevel", 0)
	;Manager.modVoreSkill(dest, sourceSkill - destSkill)

	;StorageUtil.setFloatValue(dest, "voreSkill", sourceSkill)
	;StorageUtil.setIntValue(dest, "perkPoints", voreLevel)
EndFunction


Function TransferFactions(Actor source, Actor dest)
	int FactionCount = ImportantFactions.length
	while FactionCount > 0
		FactionCount -= 1
		Faction f = ImportantFactions[FactionCount]
		dest.removeFromFaction(f)
	endwhile

	Faction[] factions = source.getFactions(-128,127)
	FactionCount = factions.length
	while FactionCount > 0
		FactionCount -= 1
		Faction f = factions[FactionCount]
		dest.addToFaction(f)
		dest.setFactionRank(f, source.getFactionRank(f))
	endwhile
EndFunction


Function StoreBounties()
	prevDovBountyEastmarch.setValue(RadiantCrimeScript.CrimeFactionEastmarch.getCrimeGold() as float)
	RadiantCrimeScript.CrimeFactionEastmarch.setCrimeGold(0)
	RadiantCrimeScript.CrimeFactionEastmarch.setCrimeGoldViolent(0)

	prevDovBountyFalkreath.setValue(RadiantCrimeScript.CrimeFactionFalkreath.getCrimeGold() as float)
	RadiantCrimeScript.CrimeFactionFalkreath.setCrimeGold(0)
	RadiantCrimeScript.CrimeFactionFalkreath.setCrimeGoldViolent(0)

	prevDovBountyHaafingar.setValue(RadiantCrimeScript.CrimeFactionHaafingar.getCrimeGold() as float)
	RadiantCrimeScript.CrimeFactionHaafingar.setCrimeGold(0)
	RadiantCrimeScript.CrimeFactionHaafingar.setCrimeGoldViolent(0)
	
	prevDovBountyHjaalmarch.setValue(RadiantCrimeScript.CrimeFactionHjaalmarch.getCrimeGold() as float)
	RadiantCrimeScript.CrimeFactionHjaalmarch.setCrimeGold(0)
	RadiantCrimeScript.CrimeFactionHjaalmarch.setCrimeGoldViolent(0)
	
	prevDovBountyPale.setValue(RadiantCrimeScript.CrimeFactionPale.getCrimeGold() as float)
	RadiantCrimeScript.CrimeFactionPale.setCrimeGold(0)
	RadiantCrimeScript.CrimeFactionPale.setCrimeGoldViolent(0)
	
	prevDovBountyReach.setValue(RadiantCrimeScript.CrimeFactionReach.getCrimeGold() as float)
	RadiantCrimeScript.CrimeFactionReach.setCrimeGold(0)
	RadiantCrimeScript.CrimeFactionReach.setCrimeGoldViolent(0)
	
	prevDovBountyRift.setValue(RadiantCrimeScript.CrimeFactionRift.getCrimeGold() as float)
	RadiantCrimeScript.CrimeFactionRift.setCrimeGold(0)
	RadiantCrimeScript.CrimeFactionRift.setCrimeGoldViolent(0)
	
	prevDovBountyWhiterun.setValue(RadiantCrimeScript.CrimeFactionWhiterun.getCrimeGold() as float)
	RadiantCrimeScript.CrimeFactionWhiterun.setCrimeGold(0)
	RadiantCrimeScript.CrimeFactionWhiterun.setCrimeGoldViolent(0)
	
	prevDovBountyWinterHold.setValue(RadiantCrimeScript.CrimeFactionWinterhold.getCrimeGold() as float)
	RadiantCrimeScript.CrimeFactionWinterhold.setCrimeGold(0)
	RadiantCrimeScript.CrimeFactionWinterhold.setCrimeGoldViolent(0)
	
EndFunction


Function TransferEquipment(Actor source, Actor dest)
	Form[] equipped = PO3_SKSEFunctions.AddAllEquippedItemsToArray(source)

	Int mask = 1
	while mask != 0
		Form wornForm = dest.getWornForm(mask)
		if wornForm
			dest.unequipItem(wornForm, false, true)
		endif
		mask *= 2
	endWhile

	mask = 1
	while mask != 0
		Form wornForm = source.getWornForm(mask)
		if wornForm
			source.removeItem(wornForm, 1, true, dest)
			dest.equipItem(wornForm, false, true)
		endIf
		mask *= 2
	endWhile

	form leftItem = source.getEquippedObject(0)
	form rightItem = source.getEquippedObject(1)
	form voiceItem = source.getEquippedObject(2)

	source.removeAllItems(dest, false, false)

	if voiceItem
		dest.equipItemEx(voiceItem, 2, false, true)
	endIf
	if rightItem
		dest.equipItemEx(rightItem, 1, false, true)
	endIf
	if leftItem
		dest.equipItemEx(leftItem, 0, false, true)
	endIf
EndFunction


Function TerminateRelationships()
	Alias follower = FollowerQuest.GetAlias(0)
	if follower && (follower as ReferenceAlias).GetReference()
		FollowerQuest.dismissFollower(0, 0)
	endif

	Alias breakupPartner = BreakupQuest.GetAlias(0)
	if breakupPartner && (breakupPartner as ReferenceAlias).GetReference()
		BreakupQuest.start()
		BreakupQuest.setStage(0)
		BreakupQuest.completeQuest()
	endif

	Alias finPartner = MarriageFINQuest.GetAlias(0)
	If finPartner && (finPartner as ReferenceAlias).GetReference()
		MarriageFINQuest.stop()
	EndIf

	Alias weddingPartner = WeddingQuest.GetAlias(0)
	If weddingPartner && (weddingPartner as ReferenceAlias).GetReference()
		WeddingQuest.stop()
	EndIf

	Alias loveInterest = MarriageQuest.GetAlias(0)
	if loveInterest && (loveInterest as ReferenceAlias).GetReference()
		playerRef.removeFromFaction(PlayerMarriedFaction)
		MarriageQuest.start()
		MarriageQuest.setStage(10)
		MarriageQuest.setStage(15)
	Endif
EndFunction


bool Function ApplyPlayableMonsterSpell(Actor pred)
	int monsterData = JValue.readFromFile(PlayableMonsterDataFile)
	if !JValue.IsExists(monsterData)
		Log1(PREFIX, "ApplyPlayableMonsterSpell", "Couldn't load " + PlayableMonsterDataFile)
		return false
	endIf
	
	String raceEDID = MiscUtil.GetActorRaceEditorID(pred)
	if !JMap.HasKey(monsterData, raceEDID)
		Log1(PREFIX, "ApplyPlayableMonsterSpell", "No matching race entry: " + raceEDID)
		return false
	endIf
	
	Spell polymorphSpell = JMap.GetForm(monsterData, raceEDID) as Spell
	if polymorphSpell == none
		Log1(PREFIX, "ApplyPlayableMonsterSpell", "Polymorph spell missing.")
		return false
	endIf
	
	Log2(PREFIX, "ApplyPlayableMonsterSpell", "Applying Polymorph spell", polymorphSpell)
	polymorphSpell.cast(playerRef)
	return true
EndFunction


;=================================================
; Convenience function.


Function Upgrade(int oldVersion, int newVersion)
	Log2(PREFIX, "Upgrade", oldVersion, newVersion)
EndFunction


DevourmentNewDova Function instance() global
	return Quest.GetQuest("DevourmentNewDova") as DevourmentNewDova
EndFunction