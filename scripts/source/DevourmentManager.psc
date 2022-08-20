ScriptName DevourmentManager extends Quest conditional
{This is the central location for managing Devourment. Everything comes through here.

LOCUS_STOMACH	= 0
LOCUS_ANAL	 	= 1
LOCUS_UNBIRTH	= 2
LOCUS_BREASTL 	= 3
LOCUS_BREASTR 	= 4
LOCUS_COCK 		= 5

}
; NEEDS TESTING
; Hotkey vore, hotkey item vore, grabbed item vore, shout key item vore, loose item vore.
;
;
; * TalkingActivator / VoreTalker
; * Guard bounty dialogue
;
; CONFIRMED BUGS
; * Anything involving death alternative...
; * No male grunt sounds during defecation
; * Blackbox covering screen thing (not reproducible, but too many reports to ignore)
; * Other mods changing PerceptionCondition
; * Devourment MCM Title does not show up. No idea why.
;
; REPORTED BUGS
; * Some people reporting that scaling suddenly stops working
; * Random teleportation when swallow shortcuts are set.
; * Multiple reformations blocking each other
; * Investigate Dead Digestion time being way the fuck long.
; * Eating may cause an immediate prey state evaluation on the predator causing extra sfx.
; * The various cum/scat/vomit piles don't always swap correctly.
; * Sometimes creatures will continue to be aggro on the player after voring them.
;
; PLANNED FEATURES
; * Check Devious Devices keywords
; * Option to stop Vore Magic perks gating Vore spells outright.
; * Silent Swallow makes Disposal noises silent to the user ??
; * Add something to make Dragons that vore the player stay put.
; * SCL-inspired PlayerThoughts function?
; * Dialogue to intiiate Vore with friendly animals ?
; * Now that the onload dependancy check is gone, make child checks less frustrating.
; * True Directional Movement camera patch. Maybe reach out?
; * Reach out to MMG or whoever made Horny Creatures / whatever nsfw creature mod people like for conversion permission.
; * Write a series of Vore tests using Chesko's Lilac.
; * Better way to manipulate RaceWeights, preferably from MCM.
; * Finish? The ResetPrey debug function.
; * Re-add all the old depreciated toggles we sacrificed, their strings are at the bottom of the translation file.
; * Finish moving EVERYTHING over to the strings file, we still use some MCM text that is hard-coded.

import DevourmentUtil
import Logging


;-- Properties --------------------------------------


bool property PERFORMANCE = false auto


Actor property FakePlayer auto
Actor property PlayerRef Auto
ActorBase[] property RemainsBones auto
ActorValueInfo property AVProxy_Size auto
Armor property GutArmor auto
CommonMeterInterfaceHandler property PlayerFullnessMeter auto
CommonMeterInterfaceHandler property PlayerStruggleMeter auto
CommonMeterInterfaceHandler[] property PreyHealthMeters Auto
CommonMeterInterfaceHandler[] property PreyStruggleMeters Auto
Container property BolusContainer auto
Container[] property RemainsFeces auto
DevourmentMCM property Menu auto
DevourmentRemap property Remapper auto
DevourmentPlayerAlias property PlayerAlias auto
DevourmentReformationQuest property ReformationQuest auto
DevourmentSkullHandler property SkullHandler auto
Explosion property BoneExplosion auto
Faction property PlayerFaction auto
FormList property FullnessTypes_All auto
Actor[] property PredatorWhitelist auto
{ Predators inside this can always Vore, no matter other settings. Contains Player by default. }
;/
PERSISTENCE NOTES: "When a script property is pointed at a reference in the editor, the target reference will be flagged as "permanently persistent". 
In other words, nothing you do during runtime will unload the object. This means that, if possible, you should not use properties to point at references directly. 
If you can, pull references in from events or other locations to avoid permanently keeping them around." 
https://www.creationkit.com/index.php?title=Persistence_(Papyrus)#Properties 

I was concerned making an Actor[] property in Skyrim I fill in-game would make Actors persistent. I'm keeping this note to remind myself this is fine.
/;

GlobalVariable property Devourment_PerkPoints auto
GlobalVariable property Devourment_PredProgress auto
GlobalVariable property Devourment_PredSkill auto
GlobalVariable property Devourment_PreyProgress auto
GlobalVariable property Devourment_PreySkill auto
GlobalVariable property Devourment_ShowPredGain auto
GlobalVariable property Devourment_ShowPredPerks auto
GlobalVariable property Devourment_ShowPreyGain auto
GlobalVariable property Devourment_ShowPreyPerks auto
GlobalVariable property PreyWeightEdit auto
GlobalVariable[] property HealthMeterColours auto
Idle Property IdleStop Auto
Idle property IdleVore auto
Int[] property CreaturePredatorToggles auto
Int[] property HumanoidMalePredatorToggles auto
Int[] property HumanoidFemalePredatorToggles auto
Keyword property ActorTypeAnimal auto
Keyword property ActorTypeCreature auto
Keyword property ActorTypeDaedra auto
Keyword property ActorTypeDragon auto
Keyword property ActorTypeDwarven auto
Keyword property ActorTypeNPC auto
Keyword property ActorTypeUndead auto
Keyword property BeingSwallowed auto
Keyword property DevourmentPred auto
Keyword property DevourmentSuperPred auto
Keyword property DevourmentSuperPrey auto
Keyword property DevourmentBoss auto
Keyword property KeywordFullness auto
Keyword property KeywordParalysis auto
Keyword property KeywordSurrender auto
Keyword property RapidDigestion auto
Keyword property Secretion auto
Keyword property Vampire auto
Keyword property VoreTalker auto
Keyword property Vorish auto
Keyword[] property RaceDigestionKeywords auto
Message property MenuPreyWeight auto
Message property MenuWhitelist auto
Message property Message_NowDigesting auto
Message property Message_Vomited auto
Message property UnclogMessage auto
Message[] property Messages_Defecated auto
Message[] property MessageIndigestible auto
Message[] property Messages_Swallow auto
Message[] property Messages_Retrovore auto
MiscObject property Ipecac auto
MusicType property DeathMusic auto
ObjectReference property HerStomach auto
Outfit property DigestionOutfit auto
PlayerVampireQuestScript property PlayerVampireQuest auto
Race property Dragon auto
Race[] property CreaturePredatorRaces auto
Race[] property HumanoidPredatorRaces auto
ReferenceAlias property PredNameAlias auto
ReferenceAlias property PreyNameAlias auto
ReferenceAlias property WhitelistNameAlias auto
SoulGem[] property Soulgems auto
Sound property BoneSound_Female auto
Sound property BoneSound_Male auto
Sound property BurpSound auto
Sound property Gurgle auto
Sound property VSkillLevelSound auto
Sound property VomitSound auto
Sound[] property DeathScreams auto
Sound[] property ScatSounds auto
Spell property DevourmentSlow auto
Spell property FakePotion auto
Spell property NotThere auto
Spell property NotThere_Friendly auto
Spell property NotThere_Trapped auto
Spell property RaiseDead Auto
Spell property ScriptedEndo auto
Spell property ScriptedVore auto
Spell property CordycepsFrenzy auto
Spell[] property SoundsOfDigestion auto
Spell[] property StatusSpells auto
Static Property AnimationMarker Auto
String[] property Skills auto
int[] property EdibleTypes auto


;-- Autoproperty settings ---------------------------------------
bool property AnalEscape = false auto
bool property CombatAcceleration = false auto
bool property SoftDeath = false auto
bool property creaturePreds = false auto
bool property crouchScat = true auto
bool property drawnAnimations = true auto
bool property endoAnyone = false auto
bool property femalePreds = false auto
bool property killEssential = false auto
bool property killNPCs = true auto
bool property killPlayer = true auto
bool property malePreds = false auto
bool property notifications = true auto
bool property screamSounds = true auto
bool property shitItems = false auto
bool property SwallowHeal = true auto
bool property StomachStrip = true auto
bool property UseHelpMessages = false auto
bool property bossesSuperPrey = true auto
bool property entitlement = false auto
bool property EndoStruggling = true auto
bool property VisualStruggles = true auto
bool property ComplexStruggles = false auto
bool property SkillGain = true auto
bool property AttributeGain = true auto
bool property DragonVoreAnimation = true auto
bool property MammothVoreAnimation = true auto

float property AcidDamageModifier = 1.0 auto
float property BurpsRate = 16.0 auto
float property GurglesRate = 8.0 auto
float property NPCBonus = 1.0 Auto
float property WeightGain = 0.0 auto
float property ItemBurping = 0.20 auto
float property cameraShake = 0.0 auto
float property preyExperienceRate = 2.0 auto
float property predExperienceRate = 1.0 auto
float property NomsChance = 0.05 auto
float property prefilledChance = 0.0 auto
float property struggleDamage = 1.0 auto
float property CombatChanceScale = 1.0 auto
float property Cooldown_Creature = 4.0 auto
float property Cooldown_NPC = 6.0 auto
int property AutoNoms = 0 auto
int property multiPrey = 2 Auto
int property scatTypeBolus = 1 auto
int property scatTypeCreature = 1 auto
int property scatTypeNPC = 2 auto
int property playerPreference = 0 auto
int property companionPredPreference = 0 auto
int property VomitStyle = 2 auto
int property whoStruggles = 2 auto


float property DigestionTime = 240.0 auto
{Controls the base amount of time it takes to digest dead prey.}


float property liveMultiplier = 1.0 auto
{Multiplies the time a pred can keep live prey trapped inside them, and divides the acid damage per second.}


float property struggleDifficulty = 10.0 auto
{Controls the difficulty of a prey struggling free from a pred.}


bool property VoreTimeout = false auto
{Controls whether prey can escape automatically during vore, or must struggle free.}


bool property EndoTimeout = true auto
{Controls whether prey can escape automatically during endo, or must struggle free.}


float property minimumSwallowChance = 5.0 auto
{Controls the minimum chance of swallowing.}


;====================================================================================================================================
; JContainers stuff.
;====================================================================================================================================


int DB = 0
int predators = 0
int blocks = 0
Form[] blockForms
String[] blockCodes

String property RaceWeights = "..\\devourment\\raceWeights.json" autoreadonly
String property RaceRemaps = "..\\devourment\\raceRemaps.json" autoreadonly


;-- Constants ---------------------------------------

int property STRUGGLE_DISABLED = 0 autoreadonly
int property STRUGGLE_PLAYER   = 1 autoreadonly
int property STRUGGLE_EVERYONE = 2 autoreadonly

int property MULTI_DISABLED	 = 0 autoreadonly
int property MULTI_COUNT	 = 1 autoreadonly
int property MULTI_SIZE1	 = 2 autoreadonly
int property MULTI_SIZE2	 = 3 autoreadonly
int property MULTI_UNLIMITED = 4 autoreadonly


; Animation flags
bool property FNISDetected
	bool Function get()
		if _FNISDetected == false
			_FNISDetected = FNIS.IsGenerated()
		endIF
		return _FNISDetected
	endFunction
endproperty 
bool _FNISDetected = false

bool FrostFallInstalled = false


;====================================================================================================================================
; Variables
;====================================================================================================================================


float lastRealTimeProcessed = 0.0
float lastGameTimeProcessed = 0.0


bool DEBUGGING = false
String PREFIX = "DevourmentManager"
float UpdateInterval = 0.50
bool firstRun = true
bool property paused = false auto


Actor[] PreyMeterAssignments

; Vomit queue mutex stuff.

ObjectReference[] vomitLocks_Prey
Actor[] vomitLocks_Pred
Spell[] property VomitSpells auto
Int lockTries = 0


Function Upgrade(int oldVersion, int newVersion)
	Log2(PREFIX, "Upgrade", oldVersion, newVersion)
	
	if oldVersion > 0 && oldVersion != newVersion
		ResetBellies()
	endIf
EndFunction


Event OnInit()
	createDatabase()
	
	if firstRun && JContainers.fileExistsAtPath(Menu.SettingsFileName)
		LoadSettings(Menu.SettingsFileName)
	endIf

	firstRun = false

	blockForms = Utility.CreateFormArray(256)
	blockCodes = Utility.CreateStringArray(256)

	vomitLocks_Prey = new ObjectReference[5]
	vomitLocks_Pred = new Actor[5]
	lastRealTimeProcessed = Utility.GetCurrentRealTime() ; seconds, real-time
	lastGameTimeProcessed = Utility.GetCurrentGameTime() ; seconds, game-time
	LoadGameChecks()

	GetPredSkill(playerRef)
	GetPreySkill(playerRef)

	PreyMeterAssignments = new Actor[10]

	int meterIndex = PreyHealthMeters.length
	while meterIndex
		meterIndex -= 1
		while !PreyHealthMeters[meterIndex].Meter.ready
			utility.wait(0.5)
		endWhile
		PreyHealthMeters[meterIndex].RemoveMeter()

		while !PreyStruggleMeters[meterIndex].Meter.ready
			utility.wait(0.5)
		endWhile
		PreyStruggleMeters[meterIndex].RemoveMeter()
	endWhile

	while !PlayerFullnessMeter.Meter.ready
		utility.wait(0.5)
	endWhile
	PlayerFullnessMeter.RemoveMeter()
	
	while !PlayerStruggleMeter.Meter.ready
		utility.wait(0.5)
	endWhile
	PlayerStruggleMeter.RemoveMeter()
EndEvent


Function LoadGameChecks()
{
Perform all of the checks and registrations necessary on load.
This is not actually connected to the event system, because this is a quest
script. Instead it's called from DevourmentPlayerAlias.
}
	; Don't even try this until the database has been created.
	if firstRun
		return
	endIf

	;/
	Note from Gaz. At one point we enforced these checks as a way to prevent underage mods. 
	I have seen how these mods work and don't care to engage in an arms race against them to the detriment of the less profane parts of the userbase.

	if !(Game.GetFormFromFile(0x1a66b, "Skyrim.esm") as Actor).IsChild() \
	|| !(Game.GetFormFromFile(0x1348b, "Skyrim.esm") as Actor).IsChild() \
	|| Game.GetModByName("NonEssentialChildren.esp") != 255 \
	|| Game.GetModByName("RCOTS-RACES.esm") != 255 \
	|| Game.GetModByName("Children Fight Back.esp") != 255 \
	|| Game.GetModByName("Killable Children.esp") != 255 \
	|| Game.GetModByName("ImCh.esm") != 255 \
	|| Game.GetModByName("Simple Killable Children.esp") != 255 \
	|| (Game.GetFormFromFile(0x956, "Devourment.esp") as Formlist).GetSize() != 50
		MessageDisabled.Show()
		ResetDevourment()
		Self.GoToState("Waiting")
		Self.Stop()
	endIf
	/;
	
	; Make sure that the devourment database exists.
	; If it doesn't, then recreate it and display an error message.
	if !assertExists(PREFIX, "LoadGameChecks", "DB", DB)
		Debug.MessageBox("The Devourment database was corrupted or deleted.\nRecreating it now.")
		createDatabase()
	endIf

	FrostFallInstalled = Game.IsPluginInstalled("Frostfall.esp")
	Log1(PREFIX, "LoadGameChecks", "Frostfall: " + FrostFallInstalled)
	Log1(PREFIX, "LoadGameChecks", "FNIS patch: " + FNISDetected)

	RegisterForModEvent("dhlp-Suspend", "onDHLP_Suspend")
	RegisterForModEvent("dhlp-Resume", "onDHLP_Resume")

	RegisterForModEvent("Devourment_RegisterDigestion", "RegisterDigestion")
	RegisterForModEvent("Devourment_ForceSwallow", "ForceSwallow")
	RegisterForModEvent("Devourment_ForceEscape", "ForceEscape")
	RegisterForModEvent("Devourment_DisableEscape", "DisableEscape")
	RegisterForModEvent("Devourment_VoreConsent", "VoreConsent")
	RegisterForModEvent("Devourment_SwitchLethal", "SwitchLethal")
	RegisterForModEvent("Devourment_Poop", "Poop")
	RegisterForModEvent("Devourment_Vomit", "Vomit")

	RegisterForModEvent("Devourment_VoreSkills", "VoreSkills")
	RegisterForModEvent("Devourment_PredXP", "GivePredXP")
	RegisterForModEvent("Devourment_PreyXP", "GivePreyXP")
	RegisterForModEvent("Devourment_ProduceVomit", "ProduceVomit")
	RegisterForModEvent("Devourment_DeadDigested", "DeadDigested")
	RegisterForModEvent("Devourment_ValidDigestion", "CheckValidDigestion")
	RegisterForModEvent("Devourment_RaiseDead", "RaiseDead")
	RegisterForModEvent("Devourment_AddSkull", "AddSkull")
	RegisterForModEvent("Devourment_Burp", "PlayBurp")
	RegisterForModEvent("Devourment_UpdateSounds", "UpdateSounds")
	RegisterForModEvent("Devourment_Entitlement", "Entitlement")
	RegisterForModEvent("Devourment_WeightGain", "WeightGain")
	RegisterForModEvent("Devourment_OutfitRestore", "OutfitRestore")
	
	RegisterForSingleUpdate(UpdateInterval)
EndFunction


Function CreateDatabase()
{ Initialize the JContainers tables. }
	DB = JValue.releaseAndretain(predators, JMap.object(), PREFIX)
	JDB.setObj("dvt", DB)
	predators = JFormMap.object()
	blocks = JFormMap.Object()
	JMap.setObj(DB, "predators", predators)
	JMap.setObj(DB, "blocks", blocks)
	JMap.setForm(DB, "playerRef", playerRef)
	JMap.setForm(DB, "fakePlayer", fakePlayer)
	
	if DEBUGGING
		Log3(PREFIX, "CreateDatabase", "Database created.", DB, predators)
	endIf
EndFunction


Function CommitMorphsToDB()
	JMap.setObj(DB, "Locus_Scales", JArray.objectWithFloats(Menu.Morphs.Locus_Scales))
	JMap.setObj(DB, "Locus_Maxes", JArray.objectWithFloats(Menu.Morphs.Locus_Maxes))
	JMap.setObj(DB, "Locus_Sliders", JArray.objectWithStrings(Menu.Morphs.Locus_Sliders))
EndFunction


Event onDHLP_Suspend(string eventName, string strArg, float numArg, Form sender)
	if sender != self
		paused = true
	endIf
EndEvent


Event onDHLP_Resume(string eventName, string strArg, float numArg, Form sender)
	paused = false
EndEvent


auto State Waiting
endState


State Running

	Event OnBeginState()
		Log1(PREFIX, "Running:OnBeginState", "Prey added. Starting main loop.")
		lastGameTimeProcessed = Utility.GetCurrentGameTime() ; days
		lastRealTimeProcessed = Utility.getCurrentRealTime() ; seconds
		RegisterForSingleUpdate(UpdateInterval)
	EndEvent 
	
	Event OnEndState()
		Log1(PREFIX, "Running:OnEndState", "No prey remain. Terminating main loop.")
		UnregisterForUpdate()
	EndEvent
	
	Event OnUpdate()
		; You may ask, why not use gameTime for everything? Because gameTime is:
		; * affected by TimeScale
		; * inaccurate at midnight or when fast-travelling
		; * loses precision the longer the game goes on
		float currentGameTime = Utility.GetCurrentGameTime()
		float currentRealTime = Utility.getCurrentRealTime()
		float dtGame = currentGameTime - lastGameTimeProcessed
		float dtReal = currentRealTime - lastRealTimeProcessed

		; If elapsed time is negative, then the game was probably
		; just now loaded.
		;
		; If there is more than two seconds of elapsed time, then either:
		; * papyrus is overloaded
		; * the player was in a menu
		; * the game was just loaded
		; * the player was sleeping or waiting.
		;
		; dtReal < 0.05 : don't bother with an update unless at least 100 milliseconds have passed.
		; dtGame > 1.0 : if an entire DAY of game time passed, then player is being weird and we wont even acknowledge them.
		;
		; dtReal > 2.0 && dtGame < 0.00694 : if 10s real-time has passed but less than 10m game-time, the player
		; was probably in a menu or saved/loaded the game. If they were sleeping or resting, dtGame would be at least 0.00694 (10 minutes).
		;
		if paused || dtReal < 0.1 || dtGame > 1.0 || (dtReal > 10.0 && dtGame < 0.00694)
			; Don't do shit.
			
		else
			; Process digestions (takes a while).
			if dtGame >= 0.00694 ; more than ten minutes
				processUpdate(dtGame * 86400.0)
			else
				processUpdate(dtReal)
			endIf
		endIf

		lastGameTimeProcessed = currentGameTime ; days
		lastRealTimeProcessed = currentRealTime ; seconds
		self.RegisterForSingleUpdate(UpdateInterval)
	EndEvent
EndState


Function ProcessUpdate(float dt)
{ Processes updates for the entire Devourment system. }

	if DEBUGGING
		LogForms(PREFIX, "ProcessUpdate", "predators", JArray.asFormArray(JFormMap.allKeys(predators)))
	endIf

	; Loop through the list of predators. 
	; Skip any that are currently blocked.
	;
	Actor purge = none
	Actor pred = JFormMap.nextKey(predators) as Actor
	while pred
		if !IsBlocked(pred)
			; The return flag from processPredator() tells us whether the predator still needs
			; processing. If they don't, they're set to be purged.
			; For simplicity, only one predator is purged per update.
			if !processPredator(pred, dt)
				purge = pred
			endif

		elseif DEBUGGING
			Log2(PREFIX, "ProcessUpdate", "Pred is blocked.", Namer(pred))
		endIf
		pred = JFormMap.nextKey(predators, pred) as Actor
	endWhile
	
	if purge
		Log2(PREFIX, "ProcessUpdate", Namer(purge), "Pred has no prey. Unregistering.")
		RemovePredator(purge)
	endIf

	; If there are no predators active, stop the main loop.
	if !JValue.count(predators)
		gotostate("")
	endIf
	
endFunction


bool Function ProcessPredator(Actor pred, float dt)
{ 
Processes updates for a predator and all of their stomach contents. 
Return value is a flag indicating whether the predator is still active.
}
	; Check if the predator has died. If they have, their stomach contents need to be handled.
	; If they are inside of another predator, everything gets moved to that predator.
	; Otherwise, everything gets vomitted out.
	bool isDead = pred.isDead()
	if isDead && !IsPrey(pred)
		Log1(PREFIX, "ProcessPredator", Namer(pred) + " is dead. Calling RegisterVomitAll().")
		RegisterVomitAll(pred, forced = true)
	endIf

	; Get the predData object, which identifies the pred and contains the stomach list.
	; This is needed by Tick function.
	int predData = JFormMap.getObj(predators, pred)

	float potency1 = 1.0 ; The rate multiplier for acid damage.
	float potency2 = 1.0 ; The rate multiplier for digestion.

	if CombatAcceleration && pred.IsInCombat() && pred.IsWeaponDrawn()
		potency2 += 9.0
	endIf

	; Check if the pred is using an acid or digestion spell to speed things up.
	; These spells store their magnitude in the unused IgnoreCrippledLimbs actorvariable.
	if pred.hasMagicEffectWithKeyword(Secretion)
		potency1 += pred.GetActorValue("IgnoreCrippledLimbs")
	endIf
	if pred.hasMagicEffectWithKeyword(RapidDigestion)
		potency2 += pred.GetActorValue("IgnoreCrippledLimbs")
	endIf

	String tickCommand = "return dvt.Tick(args, " + dt + ", " + potency1 + ", " + potency2 + ")"
	int timeout = JLua.EvalLuaInt(tickCommand, predData, 0, false)
	
	; The Tick function already did some of the processing. This next loop does the rest.
	bool vomitted = false
	int stomach = GetStomach(pred)
	
	if DEBUGGING
		Log2(PREFIX, "ProcessPredator", Namer(pred), LuaS("stomach", stomach))
	endIf
	
	; Loop through the stomach contents and process each one.
	; The vomitted flag will track whether the pred has vomitted y

	ObjectReference content = JFormMap.nextKey(stomach) as ObjectReference
	while content
		if DEBUGGING
			Log1(PREFIX, "ProcessPredator", Namer(content))
		endIf
		int preyData = JFormMap.getObj(stomach, content)
		vomitted = ProcessContent(pred, content, preyData, vomitted, dt)
		content = JFormMap.nextKey(stomach, content) as ObjectReference
	endWhile

	BurdenUpdate(pred)

	; Keep track of whether a predator has any player followers in their stomach. 
	; If they don't then clear the SwallowedFollower spell marker. 
	; If they do, then make sure that they do have the spell marker.
	if pred != playerRef
		if pred.HasSpell(StatusSpells[2]) 
			if JLua.evalLuaInt("return dvt.countFollowers(args.pred)", JLua.setForm("pred", pred)) == 0
				pred.removeSpell(StatusSpells[2])
			endIf
		else
			if JLua.evalLuaInt("return dvt.countFollowers(args.pred)", JLua.setForm("pred", pred)) > 0
				pred.addSpell(StatusSpells[2])
			endIf
		endIf

		if pred.Is3DLoaded() && !pred.HasMagicEffectWithKeyword(KeywordFullness)
			pred.RemoveSpell(DevourmentSlow)
			pred.AddSpell(DevourmentSlow)
			UpdateSounds_async(pred)
		endIf
	endIf

	if timeout < 5
		if BurpsRate > 0.0 && Utility.RandomFloat(BurpsRate) < dt
			PlayBurp_async(pred)
		endIf
	endif

	; Return the timeout counter, so that the calling function can decide whether to purge this pred.
	return timeout < 20
EndFunction


bool Function ProcessContent(Actor pred, ObjectReference content, int preyData, bool vomitted, float dt)
{ Processes updates for a single stomach content. }
	int stateCode = JLua.evalLuaInt("return dvt.GetStateCode(args)", preyData)

	if DEBUGGING
		Log5(PREFIX, "ProcessContent", Namer(pred), Namer(content), vomitted, dt, statecode)
	endIf
	
	if stateCode == 5 ;IsVomit(preyData)
		if !vomitted
			ProduceVomit_async(pred, content, preyData)
			return true
		endIf

	elseif stateCode == 4 ;IsDigested(preyData)
		DeadDigested_async(pred, content, preyData)

	elseif stateCode == 3 ;IsReforming(preyData)
		DeadReforming(pred, content as Actor, preyData, dt)
		
	elseif stateCode == 2 ;IsDigesting(preyData)
		DeadDigestion(pred, content, preyData, dt)

	elseif stateCode == 1 ;IsEndo(preyData)
		if !IsBlocked(content as Actor)
			EndoDigestion(pred, content as Actor, preyData, dt)
		elseif DEBUGGING
			Log3(PREFIX, "ProcessContent", "Prey is blocked.", Namer(content), LuaS("", preyData))
		endIf
		
	elseif stateCode == 0 ;IsVore(preyData)
		if !IsBlocked(content as Actor)
			VoreDigestion(pred, content as Actor, preyData, dt)
		elseif DEBUGGING
			Log3(PREFIX, "ProcessContent", "Prey is blocked.", Namer(content), LuaS("", preyData))
		endIf
	endIf
	
	return vomitted
EndFunction


Event RegisterDigestion(Form f1, Form f2, bool endo, int locus)
{ Registers the swallowing of f2 by f1. }
	if !(f1 && f2 && f1 != f2 && f1 as Actor && f2 as ObjectReference)
		assertNotNone(PREFIX, "RegisterDigestion", "f1", f1)
		assertNotNone(PREFIX, "RegisterDigestion", "f2", f2)
		assertNotSame(PREFIX, "RegisterDigestion", f1, f2)
		assertAs(PREFIX, "RegisterDigestion", f1, f1 as Actor)
		assertAs(PREFIX, "RegisterDigestion", f2, f2 as ObjectReference)
		return
	endIf

	if DEBUGGING
		Log3(PREFIX, "RegisterDigestion", Namer(f1), Namer(f2), endo)
	endIf
	
	; Stuff that goes in the butt still ends up in the stomach.
	if locus == 1
		locus = 0
	; When dual breast mode is off, send all breast vore to the "left".
	elseif locus == 4 && !Menu.Morphs.UseDualBreastMode
		locus = 3
	endIf
	
	Actor pred = f1 as Actor

	if IsPrey(f2 as ObjectReference)
		assertFalse(PREFIX, "RegisterDigestion", "IsPrey(f2 as ObjectReference)", IsPrey(f2 as ObjectReference))
		Debug.MessageBox(Namer(f2) + " is already registered in the stomach of " + Namer(GetPredFor(f2 as ObjectReference)) + ".\nSomething is terribly wrong.")
		return
	elseif pred.isChild()
		assertFalse(PREFIX, "RegisterDigestion", "pred.isChild()", pred.isChild())
		return
	elseif !assertTrue(PREFIX, "RegisterDigestion", "VerifyPred(pred)", VerifyPred(pred))
		return
	endIf
	
	if f2 as Actor
		Actor prey = f2 as Actor
		if prey.isChild()
			return
		endIf
		
		bool deadPrey = prey.isDead()
		prey.StopCombat()

		int preyData = CreatePreyData(pred, prey, endo, deadPrey, locus)

		if DEBUGGING
			LogJ(PREFIX, "RegisterDigestion", preyData, pred, prey)
		endIf
		
		AddToStomach(pred, prey, preyData)
		DisappearPreyBy(pred, prey, endo, deadPrey)
		AddPreyEffects(pred, prey, endo, preyData)

		; Player specific stuff.
		if prey == playerRef
			if deadPrey
				PlayerAlias.gotoDead(preyData)
			elseif endo
				PlayerAlias.gotoEndo(preyData)
			else
				PlayerAlias.gotoVore(preyData)
			endIf

			pred.stopCombat()
			pred.setAlert(false)
			pred.evaluatePackage()
		endIf

		if pred.haskeyword(ActorTypeNPC)
			pred.SetExpressionOverride(10, 100)
		endIf

		; If stomach stripping is enabled, strip the prey.
		if StomachStrip && prey.haskeyword(ActorTypeNPC)
			if prey == PlayerRef ; This helps to ensure your gear doesn't get stuck in an NPC's inventory.
				PlayerRef.UnequipItemSlot(32)
				PlayerRef.UnequipItemSlot(39)
				;PlayerRef.UnequipItemSlot(0x00000004) ; 32, body
				;PlayerRef.UnequipItemSlot(0x00000200) ; 39, shield
			else
				DigestEquipment(pred, prey, locus, 0)
			endIf
		endIf

		if deadPrey
			PlayBurp_async(pred)

			bool isNPC = prey.HasKeyword(ActorTypeNPC)
			if (isNPC && ScatTypeNPC == 0 && ScatTypeBolus > 0) || (!isNPC && ScatTypeCreature == 0 && ScatTypeBolus > 0)
				DigestEquipment(pred, prey, GetLocus(preyData), 2)
			elseif shitItems
				DigestEquipment(pred, prey, locus, 1)
			endIf

			if pred == playerRef || pred.GetActorBase().IsUnique()
				WeightGain_async(pred, prey, true)
				incrementVictimType(pred, "corpses")
			endIf

			AddSkull_Async(pred, prey)
			if entitlement
				Entitlement_async(pred, prey)
			endif
		endIf

		IncrementSwallowedCount(prey, endo)
		CheckValidDigestion_async(pred, prey, preyData)
		sendSwallowEvent(pred, prey, endo, locus)

		if DEBUGGING || pred == PlayerRef || prey == PlayerRef || AreFriends(pred, PlayerRef) || AreFriends(prey, PlayerRef)
			if IsDigesting(preyData)
				Notification2(Messages_Swallow[2], pred, prey)
			elseif endo
				Notification2(Messages_Swallow[0], pred, prey)
			else
				Notification2(Messages_Swallow[1], pred, prey)
			endIf
		endIf

		UncacheVoreWeight(pred)
		UncacheVoreWeight(prey)

		GivePredXP_async(pred, Math.sqrt(prey.GetLevel()))
		GivePreyXP_async(prey, Math.sqrt(pred.GetLevel()))

		if prey == PlayerRef && AreFriends(pred, PlayerRef)
			ReformationQuest.AddReformationHost(pred)
		endIf

	elseif f2 as DevourmentBolus
		DevourmentBolus bolus = f2 as DevourmentBolus
		int bolusData = CreateBolusData(pred, bolus, locus)
		
		if DEBUGGING
			LogJ(PREFIX, "RegisterDigestion", bolusData, pred, bolus)
		endIf
		
		AddToStomach(pred, bolus, bolusData)
		disappearBolusBy(pred, bolus)
		
	else
		ObjectReference item = f2 as ObjectReference
		int itemData = CreateItemData(pred, item, locus)

		if DEBUGGING
			LogJ(PREFIX, "RegisterDigestion", itemData, pred, item)
		endIf
		
		AddToStomach(pred, item, itemData)
		disappearBolusBy(pred, item)

	endIf

	UpdateSounds_async(pred)

	if GetState() != "Running"
		gotostate("Running")
	endIf
EndEvent


bool Function RegisterFakeDigestion(Actor pred, float size)
{ Registers the swallowing of a fake prey by the pred. If size is positive, it will be treated as a standard size. If it is negative, it will be treated as proportional to the size of the pred. }
	if !pred
		assertNotNone(PREFIX, "RegisterFakeDigestion", "pred", pred)
		return false
	endIf

	if pred.isChild()
		assertFalse(PREFIX, "RegisterFakeDigestion", "pred.isChild()", pred.isChild())
		return false
	elseif !assertTrue(PREFIX, "RegisterFakeDigestion", "VerifyPred(pred)", VerifyPred(pred))
		return false
	endIf

	if DEBUGGING
		Log1(PREFIX, "RegisterFakeDigestion", Namer(pred))
	endIf
	
	float relativeSize
	if size < 0.0
		relativeSize = -size
	else
		relativeSize = size / GetVoreWeight(pred)
	endIf

	int transport = JLua.setFlt("time", GetDigestionTime(pred, none), JLua.setFlt("size", relativeSize, JLua.setForm("pred", pred)))
	JLua.evalLuaInt("dvt.AddFakeToStomach(args.pred, args.time, args.size, 0.5)", transport)
	UpdateSounds_async(pred)
	
	if GetState() != "Running"
		gotostate("Running")
	endIf
	
	return true
EndFunction


Function RegisterReformation(Actor pred, Actor prey, int locus)
{ Registers the swallowing of a fake prey. }
	if !(pred && prey && pred != prey)
		assertNotNone(PREFIX, "RegisterReformation", "pred", pred)
		assertNotNone(PREFIX, "RegisterReformation", "prey", prey)
		assertNotSame(PREFIX, "RegisterReformation", pred, prey)
		return
	endIf

	if pred.isChild()
		assertFalse(PREFIX, "RegisterReformation", "pred.isChild()", pred.isChild())
		return
	elseif !assertTrue(PREFIX, "RegisterReformation", "VerifyPred(pred)", VerifyPred(pred))
		return
	endIf

	int preyData = CreatePreyData(pred, prey, true, true, locus)
	SetReforming(preyData)
	
	if DEBUGGING
		Log4(PREFIX, "RegisterReformation", Namer(pred), Namer(prey), locus, LuaS("preyData", preyData))
	endIf
	
	AddToStomach(pred, prey, preyData)
	AddPreyEffects(pred, prey, true, preyData)
	UpdateSounds_async(pred)
	
	if prey == playerRef
		DisappearPreyBy(pred, prey, true, false)
		PlayerAlias.gotoReforming(preyData)
	endIf

	if GetState() != "Running"
		gotostate("Running")
	endIf

	SendReformationEvent(pred, prey)
EndFunction


Function SwitchLethalAll(Actor pred, bool toggle)
	{ Toggles all of a pred's prey from lethal to non-lethal and vice versa. }

	if !assertNotNone(PREFIX, "SwitchLethalAll", "pred", pred)
		return
	endIf

	if DEBUGGING
		Log1(PREFIX, "SwitchLethalAll", Namer(pred))
	endIf

	int stomach = GetStomach(pred)
	if !JValue.IsExists(stomach)
		return
	endIf

	bool blocked = RegisterBlock("SwitchLethalAll", pred)

	ObjectReference content = JFormMap.nextKey(stomach) as ObjectReference
	while content
		int preyData = JFormMap.getObj(stomach, content)
		Actor prey = content as Actor
		if prey && IsAlive(preyData)
			if IsVore(preyData) && !toggle
				SetEndo(preyData, prey != playerRef && pred != playerRef)
				AddPreyEffects(pred, prey, true, preyData)
				
				if prey == playerRef
					PlayerAlias.gotoEndo(preyData)
				endIf
		
				sendSwallowEvent(pred, prey, true, GetLocus(preyData))
		
			elseif IsEndo(preyData) && toggle
				SetVore(preyData)
				AddPreyEffects(pred, prey, false, preyData)
				
				if prey == playerRef
					PlayerAlias.gotoVore(preyData)
				endIf
		
				sendSwallowEvent(pred, prey, false, GetLocus(preyData))
			endIf			
		endIf

		content = JFormMap.nextKey(stomach, content) as ObjectReference
	endWhile
	
	UpdateSounds_async(pred)
	
	if blocked 
		UnregisterBlock("SwitchLethalAll", pred)
	endIf
EndFunction


Event SwitchLethal(Form f1, bool toggle)
{ Toggles a prey from lethal to non-lethal and vice versa. }
	if !assertNotNone(PREFIX, "SwitchLethal", "f1", f1) \
	|| !assertAs(PREFIX, "SwitchLethal", f1, f1 as Actor)
		return
	endIf

	if DEBUGGING
		Log1(PREFIX, "SwitchLethal", Namer(f1))
	endIf
	
	Actor prey = f1 as Actor
	int preyData = GetPreyData(prey)
	Actor pred = GetPred(preyData)
	Actor apex = FindApex(prey)
	
	if !assertExists(PREFIX, "SwitchLethal", "preyData", preyData) \
	|| !assertNotNone(PREFIX, "SwitchLethal", "prey", prey) \
	|| !assertNotNone(PREFIX, "SwitchLethal", "pred", pred) \
	|| !assertNotNone(PREFIX, "SwitchLethal", "apex", apex)
		return
	endIf

	bool blocked = RegisterBlocks("SwitchLethal", pred, prey)
	bool isVore = IsVore(preyData)
	
	if isVore && !toggle
		SetEndo(preyData, prey != playerRef && pred != playerRef)
		AddPreyEffects(pred, prey, true, preyData)
		
		if prey == playerRef
			PlayerAlias.gotoEndo(preyData)
		endIf

		sendSwallowEvent(pred, prey, true, GetLocus(preyData))

	elseif !isVore && toggle
		SetVore(preyData)
		AddPreyEffects(pred, prey, false, preyData)
		
		if prey == playerRef
			PlayerAlias.gotoVore(preyData)
		endIf

		if apex.haskeyword(ActorTypeNPC)
			apex.SetExpressionOverride(10, 100)
		endIf

		sendSwallowEvent(pred, prey, false, GetLocus(preyData))
	endIf

	UpdateSounds_async(pred)
	
	if blocked 
		UnregisterBlocks("SwitchLethal", pred, prey)
	endIf
endEvent


Function EndoDigestion(Actor pred, Actor prey, int preyData, float dt)
{ Processes live endo digestion for a pred/prey pair. }
	if DEBUGGING
		assertExists(PREFIX, "EndoDigestion", "preyData", preyData)
		assertNotNone(PREFIX, "EndoDigestion", "pred", pred)
		assertNotNone(PREFIX, "EndoDigestion", "prey", prey)
		assertTrue(PREFIX, "EndoDigestion", "IsPred(pred)", IsPred(pred))
		assertTrue(PREFIX, "EndoDigestion", "IsAlive(preyData)", IsAlive(preyData))
		assertTrue(PREFIX, "EndoDigestion", "Has(pred, prey)", Has(pred, prey))
	endIf
	
	bool deadPrey = prey.isDead()
	playGurgle(pred, dt)
	
	if deadPrey
		; Was the prey accidentally killed? Vomit them out.
		Log3(PREFIX, "EndoDigestion", Namer(pred), Namer(prey), "Prey is endo but died anyway, calling RegisterVomit.")
		RegisterVomit(prey)
		return
	endIf

	if prey.HasPerk(Menu.Delicious)
		pred.restoreActorValue("Health", dt * 4.0)
	endIf

	; Warm the player.
	if prey == PlayerRef && FrostFallInstalled
		FrostUtil.ModPlayerExposure(-10.0, -1.0)
	endIf

	; Used for struggle animations.
	JMap.setFlt(preyData, "health", prey.GetActorValuePercentage("Health"))
	
	float timerMax = JMap.getFlt(preyData, "timerMax")
	if timerMax > 0.0
		float timer = JMap.getFlt(preyData, "timer")
		if timer <= 0.0 && EndoTimeout && CanEscapeEndo(preyData)
			if DEBUGGING
				Log4(PREFIX, "EndoDigestion", preyData, Namer(pred), Namer(prey), "HoldingTime expired, calling RegisterVomit.")
			endIf
			ForceEscape(prey)
		endIf
	endIf
EndFunction


Function VoreDigestion(Actor pred, Actor prey, int preyData, float dt)
{ Processes live vore digestion for a pred/prey pair. }
	if DEBUGGING
		assertExists(PREFIX, "VoreDigestion", "preyData", preyData)
		assertNotNone(PREFIX, "VoreDigestion", "pred", pred)
		assertNotNone(PREFIX, "VoreDigestion", "prey", prey)
		assertTrue(PREFIX, "VoreDigestion", "IsPred(pred)", IsPred(pred))
		assertTrue(PREFIX, "VoreDigestion", "IsAlive(preyData)", IsAlive(preyData))
		assertTrue(PREFIX, "VoreDigestion", "Has(pred, prey)", Has(pred, prey))
	endIf
	
	bool deadPrey = prey.isDead()
	bool eligibleForDigestion = EligibleForDigestion(pred, prey)

	playGurgle(pred, dt)
	
	if deadPrey
		KillPrey(pred, prey, preyData, dt, eligibleForDigestion)
		return
	endIf
	
	float damage = JValue.solveFlt(preyData, ".flux.damage")
	float times = JValue.solveFlt(preyData, ".flux.times")
	float timer = JMap.getFlt(preyData, "timer")

	if times > 100.0 / struggleDifficulty
		times = 100.0 / struggleDifficulty
	endIf
	
	float health = prey.GetActorValue("Health")
	bool healthIsCritical = health <= damage + 2.0

	; If health is high enough that there is a comfortable margin, deal the damage.
	;  |--------X---------------------| damage
	;  |--------.---<=----X-----------| health
	;
	; If health is less than damage, decrease damage and set the healthIsCritical flag. 
	;  |----.---<=---X----------------| damage
	;  |----X-------------------------| health
	;
	; If health is very close to damage, just set the healthIsCritical flag.
	;  |---------------X--------------| damage
	;  |--------------X---------------| health
	;
	if health < damage
		healthIsCritical
		damage = health
	elseif health <= damage + 2.0
		healthIsCritical
	else
		prey.DamageActorValue("Health", damage)
	endIf
		
	if prey != playerRef
		if CanStruggle(prey, preyData)
			if times > 0
				NPCStruggle(pred, prey, preyData, times, true)
			endIf
		endIf
	endIf

	float healthPercentage = prey.GetActorValuePercentage("Health")
	if healthPercentage < 0.0
		healthPercentage = 0.0
	endIf

	sendLiveDigestionEvent(pred, prey, damage, healthPercentage)

	; Used for struggle animations.
	JMap.setFlt(preyData, "health", healthPercentage)

	if pred == playerRef
		updateHealthMeter(prey, 100.0 * healthPercentage)
	endIf

	if DEBUGGING
		String msg = "Health reduced by " + damage + ", " + prey.GetActorValue("Health") + " health remaining (" + healthPercentage + "%), " + timer + " s until escape."
		Log2(PREFIX, "VoreDigestion", Namer(prey), msg)
		ConsoleUtil.PrintMessage(Namer(prey) + ": " + msg)
	endIf
	
	if damage > 0.0
		GivePredXP_async(pred, damage / 5.0)
		GivePreyXP_async(prey, damage / 5.0)

		if pred.hasPerk(Menu.NourishmentBody)
			pred.restoreActorValue("Health", damage * 2.0)
			pred.restoreActorValue("Stamina", damage * 2.0)

			if pred.hasPerk(Menu.NourishmentMana)
				pred.restoreActorValue("Magicka", damage * 2.0)
			endIf
		else
			pred.restoreActorValue("Health", damage)
			pred.restoreActorValue("Stamina", damage)
		endIf
	endIf
	
	; If the prey is dead (or a reasonable approximation thereof), it's time to either
	; move them to dead digestion or vomit them out.
	if deadPrey || healthIsCritical
		KillPrey(pred, prey, preyData, dt, eligibleForDigestion)
		
	; If they're not dead and are capable of escape and have waited out the timer, let them escape.
	elseif timer <= 0.0 && VoreTimeout && CanEscapeVore(preyData)
		if DEBUGGING
			Log4(PREFIX, "VoreDigestion", preyData, Namer(pred), Namer(prey), "HoldingTime expired, calling RegisterVomit.")
		endIf
		CheckAndSetPartingGift(pred, prey)
		ForceEscape(prey)
		
	; Warm the player.
	elseif prey == playerRef && FrostFallInstalled
		FrostUtil.ModPlayerExposure(-10.0, -1.0)
	endIf
endFunction


bool Function EligibleForDigestion(Actor pred, Actor prey)
	if pred == playerRef
		return true
	elseif prey == playerRef
		return KillPlayer
	elseif prey.isEssential() || PO3_SKSEFunctions.IsVIP(prey)
		return KillEssential
	else
		return killNPCs
	endIf
EndFunction


Function KillPrey(Actor pred, Actor prey, int preyData, float dt, bool eligibleForDeath)
	if DEBUGGING
		Log5(PREFIX, "KillPrey", Namer(pred), Namer(prey), dt, eligibleForDeath, LuaS("preyData", preyData))
	endIf

	if !eligibleForDeath
		if Notifications && pred == playerRef
			Notification2(MessageIndigestible[4], pred, prey)
			ConsoleUtil.PrintMessage(Namer(prey, true) + " is indigestible.")
		endIf
		RegisterVomit(prey)
		return

	; Fatally digest.
	else
		FinishLiveDigestion(pred, prey, preyData)
		AdjustTimer(preyData, -dt/2.0)
		return
	endIf
endFunction


Function CheckAndSetPartingGift(Actor pred, Actor prey)
	if prey.HasPerk(Menu.PartingGift)
		if !pred.hasPerk(Menu.ConstrictingGrip) || GetVoreLevel(prey) > GetVoreLevel(pred)
			StorageUtil.SetIntValue(prey, "DevourmentPartingGift", 1)
		endIf
	endIf
EndFunction


bool Function GivePartingGift(Actor prey)
	return 0 < StorageUtil.PluckIntValue(prey, "DevourmentPartingGift")
EndFunction


function FinishLiveDigestion(Actor pred, Actor prey, int preyData)
{ Changes a living prey to a digesting prey. }
	if DEBUGGING
		assertExists(PREFIX, "FinishLiveDigestion", "preyData", preyData)
		assertNotNone(PREFIX, "FinishLiveDigestion", "pred", pred)
		assertNotNone(PREFIX, "FinishLiveDigestion", "prey", prey)
		assertTrue(PREFIX, "FinishLiveDigestion", "IsPred(pred)", IsPred(pred))
		assertTrue(PREFIX, "FinishLiveDigestion", "IsAlive(preyData)", IsAlive(preyData))
		assertTrue(PREFIX, "FinishLiveDigestion", "Has(pred, prey)", Has(pred, prey))
		Log1(PREFIX, "FinishLiveDigestion", Namer(prey))
	endIf
	
	Actor apex = FindApex(prey)
	SetDigesting(preyData, GetDigestionTime(pred, prey))

	if prey.HasPerk(Menu.Cordyceps) && pred.HasSpell(CordycepsFrenzy)
		pred.RemoveSpell(CordycepsFrenzy)
	endIf

	if apex.Is3DLoaded()
		GetDeathSound(prey).play(apex)
	endIf
	
	if prey == playerRef
		PlayerAlias.gotoDead(preyData)
		DeathMusic.add()
	endIf

	SetMeters_Dead(prey)
	updateHealthMeter(prey, 100.0)

	if prey.hasSpell(NotThere_Friendly)
		prey.removeSpell(NotThere_Friendly)
	endIf

	Notification2(Message_NowDigesting, pred, prey)
	playBurp_async(pred)
	UpdateSounds_async(pred)

	; Do the skull stuff!
	AddSkull_Async(pred, prey)

	; Equipment stripping.
	bool isNPC = prey.HasKeyword(ActorTypeNPC)
	if (isNPC && ScatTypeNPC == 0 && ScatTypeBolus > 0) || (!isNPC && ScatTypeCreature == 0 && ScatTypeBolus > 0)
		DigestEquipment(pred, prey, GetLocus(preyData), 2)
	elseif shitItems
		DigestEquipment(pred, prey, GetLocus(preyData), 1)
	endIf
	
	if pred.hasPerk(Menu.SoulFood)
		SkullHandler.AddSoul(pred, prey)
	endIf

	TransferStomach(prey, pred)

	ActorBase predBase = pred.getLeveledActorBase()
	ActorBase preybase = prey.GetLeveledActorBase()

	if prey != playerRef && prey != fakePlayer && !prey.isDead() 
		bool wasProtected = preyBase.isProtected()
		bool wasEssential = preyBase.isEssential()
		bool consented = IsConsented(preyData)
		
		preyBase.SetInvulnerable(false)
		
		if wasProtected
			preyBase.setProtected(false)
		endIf
		if wasEssential
			preyBase.setEssential(false)
		endIf

		if consented
			prey.Kill()
		else
			prey.Kill(pred)
		endIf
		
		if wasProtected
			preyBase.setProtected(true)
		endIf
		if wasEssential
			preyBase.setEssential(true)
		endIf
	endIf

	if pred == playerRef
		if prey.GetLeveledActorBase().getRace() == Dragon
			pred.modActorValue("dragonsouls", 1.0)
		endIf
	endIf

	if pred == playerRef || pred.GetActorBase().IsUnique()
		incrementVictims(pred)
		voreStats(pred, prey)
		WeightGain_async(pred, prey, true)
		VoreSkills_async(pred, prey)
	endIf

	if entitlement
		Entitlement_async(pred, prey)
	endif

	if pred == playerRef && pred.hasKeyword(Vampire) && prey.hasKeyword(ActorTypeNPC)
		PlayerVampireQuest.VampireFeed()
		Log2(PREFIX, "FinishLiveDigestion", Namer(pred), "Vampire drank blood by voring.")
	endIf

	SendDeathEvent(pred, prey)
endFunction


Function WeightGain_async(Actor pred, Actor prey, bool gain)
{ Used to call WeightGain asynchronously using a ModEvent. }
	if WeightGain > 0.0
		int handle = ModEvent.create("Devourment_WeightGain")
		ModEvent.pushForm(handle, pred)
		ModEvent.pushForm(handle, prey)
		ModEvent.pushBool(handle, gain)
		ModEvent.Send(handle)
	endIf
EndFunction
		
		
Event WeightGain(Form f1, Form f2, bool gain)
	Actor pred = f1 as Actor
	ActorBase predBase = pred.getLeveledActorBase()
	
	if WeightGain > 0.0
		float oldweight = predBase.getWeight()
		if oldweight < 100.0
			float newWeight
			if gain
				newWeight = oldweight + WeightGain
				if newWeight > 100.0
					newWeight = 100.0
				endIf
			else
				newWeight = oldweight - WeightGain
				if newWeight < 0.0
					newWeight = 0.0
				endIf
			endIf
	
			predBase.setWeight(newWeight)
				
			if !pred.IsOnMount()
				pred.updateWeight(oldweight / 100 - newWeight / 100.0)
				pred.QueueNiNodeUpdate()
			endIf
		endIf
	endIf	
EndEvent


Function Entitlement_async(Actor pred, Actor prey)
{ Used to call Entitlement asynchronously using a ModEvent. }
	int handle = ModEvent.create("Devourment_Entitlement")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.Send(handle)
EndFunction


Event Entitlement(Form f1, Form f2)
	Actor pred = f1 as Actor
	Actor prey = f2 as Actor

	if !AssertNotNone(PREFIX, "Entitlement", "pred", pred) \
	|| !AssertNotNone(PREFIX, "Entitlement", "prey", prey) \
	|| pred == playerRef || prey == playerRef
		return
	endIf
	
	bool predUnique = pred.GetLeveledActorBase().IsUnique()
	bool preyUnique = prey.GetLeveledActorBase().IsUnique()

	int oldLevel = StorageUtil.GetIntValue(pred, "DevourmentTitleRank")
	int newLevel = prey.GetLevel()
	if oldLevel > newLevel
		return
	endIf

	String preyName = Namer(prey, true)
	String newName

	if preyUnique
		newName = Namer(pred, true) + " [Devourer of " + preyName + "]"
	elseif StringUtil.Find(preyName, " ") < 0
		newName = Namer(pred, true) + " [" + preyName + "sBane]"
	else
		return
	endIf

	pred.SetDisplayName(newName)
	StorageUtil.SetStringValue(pred, "DevourmentTitle", newName)
	StorageUtil.SetIntValue(pred, "DevourmentTitleRank", newLevel)
EndEvent 


Function DeadReforming(Actor pred, Actor prey, int preyData, float dt)
{ Updates the digestion timer and scale the predator's belly accordingly. }
	if DEBUGGING
		assertExists(PREFIX, "DeadReforming", "preyData", preyData)
		assertNotNone(PREFIX, "DeadReforming", "pred", pred)
		assertNotNone(PREFIX, "DeadReforming", "prey", prey)
		assertTrue(PREFIX, "DeadReforming", "IsPred(pred)", IsPred(pred))
		assertTrue(PREFIX, "DeadReforming", "IsDigesting(content)", IsReforming(preyData))
		assertTrue(PREFIX, "DeadReforming", "Has(pred, content)", Has(pred, prey))
	endIf

	;BurdenUpdate(pred)
	playGurgle(pred, dt)

	if pred == playerRef
		updateHealthMeter(prey, GetDigestionPercent(preyData))
	endIf

	if DEBUGGING
		Log2(PREFIX, "DeadReforming", GetTimer(preyData), GetDigestionTime(pred, prey))
	endIF

	if GetDigestionRemaining(preyData) >= 1.0
		ReformPrey(pred, prey, preyData)
	else
		SendDeadReformingEvent(pred, prey, GetDigestionPercent(preyData))
	endIf

EndFunction


Function DeadDigestion(Actor pred, ObjectReference content, int preyData, float dt)
{ Updates the digestion timer and scale the predator's belly accordingly. }
	if DEBUGGING
		assertExists(PREFIX, "DeadDigestion", "preyData", preyData)
		assertNotNone(PREFIX, "DeadDigestion", "pred", pred)
		assertNotNone(PREFIX, "DeadDigestion", "content", content)
		assertTrue(PREFIX, "DeadDigestion", "IsPred(pred)", IsPred(pred))
		assertTrue(PREFIX, "DeadDigestion", "IsDigesting(content)", IsDigesting(preyData))
		assertTrue(PREFIX, "DeadDigestion", "Has(pred, content)", Has(pred, content))
		LogJ(PREFIX, "DeadDigestion", preyData, pred, content)
	endIf
	
	Actor prey = content as Actor
	
	playGurgle(pred, dt)
	;BurdenUpdate(pred)

	if prey
		if pred == playerRef
			updateHealthMeter(prey, GetDigestionPercent(preyData))
		endIf
	endIf

	if GetTimer(preyData) <= 0.0 
		int locus = GetLocus(preyData)
		
		if prey && locus == 2 && Menu.AutoRebirth
			SetReforming(preyData)
			
		else
			SetDigested(preyData)
		
			if pred == playerRef
				if content as DevourmentBolus
					if (content as DevourmentBolus).IsEmpty()
						;
					elseif scatTypeBolus > 0
						PlayerAlias.GotoEliminate()
					endIf
				elseif content.HasKeyword(ActorTypeNPC)
					if scatTypeNPC > 0
						PlayerAlias.GotoEliminate()
					endIf
				elseif scatTypeCreature > 0
					PlayerAlias.GotoEliminate()
				endIf
			endIf
		endIf
		
	elseif prey
		if pred.hasPerk(Menu.NourishmentBody)
			pred.restoreActorValue("Health", 4.0 * dt)
			pred.restoreActorValue("Stamina", 4.0 * dt)
		else
			pred.restoreActorValue("Health", 2.0 * dt)
			pred.restoreActorValue("Stamina", 2.0 * dt)
		endIf

		if pred.hasPerk(Menu.NourishmentMana)
			pred.restoreActorValue("Magicka", 2.0 * dt)
		endIf

		SendDeadDigestionEvent(pred, prey, GetDigestionPercent(preyData))
	endIf	
EndFunction


Function DeadDigested_async(Actor pred, ObjectReference content, int preyData)
{ Used to call DeadDigested asynchronously using a ModEvent. }
	int handle = ModEvent.create("Devourment_DeadDigested")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, content)
	ModEvent.pushInt(handle, preyData)
	ModEvent.Send(handle)
EndFunction


Event DeadDigested(Form f1, Form f2, int preyData)
{ Checks to see if defecation can happen. }
	Actor pred = f1 as Actor
	ObjectReference content = f2 as ObjectReference
	
	if DEBUGGING
		assertExists(PREFIX, "DeadDigested", "preyData", preyData)
		assertNotNone(PREFIX, "DeadDigested", "pred", pred)
		assertNotNone(PREFIX, "DeadDigested", "content", content)
		assertTrue(PREFIX, "DeadDigested", "IsPred(pred)", IsPred(pred))
		assertTrue(PREFIX, "DeadDigested", "IsDigested(content)", IsDigested(preyData))
		assertTrue(PREFIX, "DeadDigested", "Has(pred, content)", Has(pred, content))
	endIf

	if content as Actor
		Actor prey = content as Actor
		bool isNPC = prey.HasKeyword(ActorTypeNPC)

		if (isNPC && scatTypeNPC == 0) || (!isNPC && scatTypeCreature == 0)
			AbsorbRemains(pred, prey, preyData)
			SendDeadDigestionEvent(pred, prey, 0.0)
		elseif (isNPC && (scatTypeNPC == 1 || scatTypeNPC == 2)) || (!isNPC && scatTypeCreature == 1) 
			if !pred.IsInCombat() && (notInPlayerHome(pred) || pred.isDead())
				ExpelRemains(pred, prey, preyData)
				SendDeadDigestionEvent(pred, prey, 0.0)
			endIf
		elseif (isNPC && scatTypeNPC == 3) || (!isNPC && scatTypeNPC == 2)
			if pred != PlayerRef && (notInPlayerHome(pred) || pred.isDead())
				RegisterVomit(prey)
				SendDeadDigestionEvent(pred, prey, 0.0)
			endIf
		endIf

	elseif content as DevourmentBolus
		DevourmentBolus bolus = content as DevourmentBolus
		
		if bolus.IsEmpty()
			RemoveFromStomach(pred, bolus, preyData)
			bolus.Delete()
			if pred == playerRef
				PlayerAlias.CheckClearEliminate()
			endIf
		elseif scatTypeBolus == 0
			AbsorbRemains(pred, bolus, preyData)
		elseif scatTypeBolus == 1 && !pred.IsInCombat()
			ExpelRemains(pred, bolus, preyData)
		elseif scatTypeBolus == 2 && pred != PlayerRef
			RegisterVomit(bolus)
		endIf
	
	else
		if scatTypeBolus == 2
			RegisterVomit(content)
		elseif !pred.IsInCombat() && pred != PlayerRef
			ExpelRemains(pred, content, preyData)
		endIf
	endIf
EndEvent


Function ProduceVomit_async(Actor pred, ObjectReference content, int preyData)
{ Used to call ProduceVomit asynchronously using a ModEvent. }
	int handle = ModEvent.create("Devourment_ProduceVomit")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, content)
	ModEvent.pushInt(handle, preyData)
	ModEvent.Send(handle)
EndFunction


Event ProduceVomit(Form f1, Form f2, int preyData)
{ Creates a vomit event for an Actor. It will attempt a vomit for six seconds. If that fails, it will bypass the vomit Spell. }
	Actor pred = f1 as Actor
	ObjectReference content = f2 as ObjectReference
	Actor apex = FindApex(content)
	
	if DEBUGGING
		assertExists(PREFIX, "ProduceVomit", "preyData", preyData)
		assertNotNone(PREFIX, "ProduceVomit", "apex", apex)
		assertNotNone(PREFIX, "ProduceVomit", "pred", pred)
		assertNotNone(PREFIX, "ProduceVomit", "content", content)
		assertTrue(PREFIX, "ProduceVomit", "IsPred(pred)", IsPred(pred))
		assertTrue(PREFIX, "ProduceVomit", "IsVomit(content)", IsVomit(preyData))
		assertTrue(PREFIX, "ProduceVomit", "Has(pred, content)", Has(pred, content))
		LogJ(PREFIX, "ProduceVomit", preyData, apex, pred, content)
	endIf
	
	if content == playerRef
		PlayerAlias.StopPlayerStruggle()
	endIf

	if !apex.is3DLoaded()
		Log3(PREFIX, "ProduceVomit", Namer(apex), Namer(content), "apex not loaded; forcing a manual vomit.")
		ManualVomit(pred, content, preyData, forced=false)
		return

	elseif VOMIT_EXPIRED()
		Log3(PREFIX, "ProduceVomit", Namer(apex), Namer(content), "Vomit timeout expired; forcing a manual vomit.")
		ManualVomit(pred, content, preyData, forced=true)
		HelpAgnosticMessage(UnclogMessage, "DVT_UNCLOG", 4.0, 60.0)
		VOMIT_UNLOCK(pred, content)
		return

	elseif !VOMIT_LOCK(apex, content)
		return
	endIf

	Spell vomitSpell = VOMIT_SPELL(content)
	bool weaponDrawn = apex.isWeaponDrawn()
	bool doAnimations = (apex == playerRef || apex.hasKeyword(ActorTypeNPC)) && (drawnAnimations || !weaponDrawn)
	bool inCombat = apex.IsInCombat()
	int locus = GetLocus(preyData)
	
	if doAnimations
		if locus == 2 && FNISDetected && !inCombat ; unbirth
			Debug.SendAnimationEvent(apex, "LayDownBirth");
			Utility.Wait(3.6)
			;Debug.SendAnimationEvent(apex, "Birth_S1");
		elseif locus == 3
			debug.sendAnimationEvent(apex, "ShoutStart")
		elseif locus == 4 
			debug.sendAnimationEvent(apex, "ShoutStart")
		else
			debug.sendAnimationEvent(apex, "ShoutStart")
		endIf
	endIf
	
	vomitSpell.Cast(apex, none)
	VomitSound.playAndWait(apex)

	apex.CreateDetectionEvent(apex, 100)
	if apex.haskeyword(ActorTypeNPC)
		apex.SetExpressionOverride(10, 0)
	endIf

	if content as Actor
		Actor prey = content as Actor
		If !prey.isDead()
			sendEscapeEvent(pred, prey, IsEndo(preyData))
		endIf
		Notification2(Message_Vomited, apex, prey)
	endIf

	if doAnimations
		if locus == 2 && FNISDetected && !inCombat ; unbirth
			Debug.SendAnimationEvent(apex, "GetupBirth");
			Utility.Wait(3.5)
			apex.PlayIdle(IdleStop)
		elseif locus == 3  ; schlong
			debug.sendAnimationEvent(apex, "ShoutStop")
		elseif locus == 4  ; schlong
			debug.sendAnimationEvent(apex, "ShoutStop")
		else
			debug.sendAnimationEvent(apex, "ShoutStop")
		endIf
	endIf
EndEvent


Function ManualVomit(Actor pred, ObjectReference content, int preyData, bool forced)
{
ManualVomit is used when there is a problem with the VOMIT_LOCK mutex. It skips using the vomit 
spell and activator, so some of the visual effects will be missing and the prey may be strangely 
placed. It will still put in an effort to look decent though.
}
	if DEBUGGING
		assertExists(PREFIX, "ProduceVomit2", "preyData", preyData)
		assertNotNone(PREFIX, "ProduceVomit2", "apex", FindApex(content))
		assertNotNone(PREFIX, "ProduceVomit2", "pred", pred)
		assertNotNone(PREFIX, "ProduceVomit2", "content", content)
		assertTrue(PREFIX, "ProduceVomit2", "IsPred(pred)", IsPred(pred))
		assertTrue(PREFIX, "ProduceVomit2", "IsVomit(content)", IsVomit(preyData))
		assertTrue(PREFIX, "ProduceVomit2", "Has(pred, content)", Has(pred, content))
		LogJ(PREFIX, "ProduceVomit2", preyData, apex, pred, content)
	endIf

	bool blocked = RegisterBlock("ManualVomit", pred)
	if !forced && !blocked
		return
	endIf
	
	if content == playerRef
		PlayerAlias.StopPlayerStruggle()
	endIf

	Actor apex = FindApex(content)
	bool local = apex == playerRef || content == playerRef || apex.is3DLoaded()
	bool weaponDrawn = apex.isWeaponDrawn()
	bool doAnimations = (apex == playerRef || apex.hasKeyword(ActorTypeNPC)) && (drawnAnimations || !weaponDrawn)
	
	RemoveFromStomach(pred, content, preyData)

	if local
		if doAnimations
			debug.sendAnimationEvent(apex, "shoutStart")
		endIf

		VomitSound.playAndWait(apex)
		apex.CreateDetectionEvent(apex, 100)

		if apex.haskeyword(ActorTypeNPC)
			apex.SetExpressionOverride(10, 0)
		endIf
	endIf

	if content as Actor
		Actor prey = content as Actor

		if local
			if prey.hasPerk(Menu.StickTheLanding)
				ReappearPreyAt(prey, apex, lateral=60.0, vertical=45.0)
			else
				ReappearPreyAt(prey, apex, lateral=60.0, vertical=45.0)
				if WaitUntilPresent(prey, apex)
					apex.pushActorAway(prey, 10.0)
				endIf
			endIf
			
			if GivePartingGift(prey)
				pred.DamageActorValue("Health", 300.0)
			endIf
		else
			ReappearPreyAt(prey, apex, lateral=80.0, vertical=42.0)
		endif
		
		Notification2(Message_Vomited, apex, prey)

		If !prey.isDead()
			sendEscapeEvent(pred, prey, IsEndo(preyData))
		endIf

		if content == playerRef
			pred.AddSpell(StatusSpells[0], false)
		elseif pred == playerRef
			prey.AddSpell(StatusSpells[1], false)
		endIf

		UpdateSounds_async(prey)

	elseif content as DevourmentBolus
		ReappearBolusAt(content as DevourmentBolus, apex, front = true, lateral=50.0, vertical=72.0)
	
	else
		ReappearItemAt(content, apex, front = true, lateral=50.0)
	endIf

	if local && doAnimations
		debug.sendAnimationEvent(apex, "shoutStop")
	endIf
	
	UpdateSounds_async(apex)
	
	if blocked
		UnregisterBlock("ManualVomit", pred)
	endIf
EndFunction


function AbsorbRemains(Actor pred, ObjectReference content, int preyData)
{ Remove digested stomach contents from pred tummy. }
	if DEBUGGING
		assertExists(PREFIX, "AbsorbRemains", "preyData", preyData) 
		assertNotNone(PREFIX, "AbsorbRemains", "apex", FindApex(content))
		assertNotNone(PREFIX, "AbsorbRemains", "pred", pred)
		assertNotNone(PREFIX, "AbsorbRemains", "content", content)
		assertTrue(PREFIX, "AbsorbRemains", "IsPred(pred)", IsPred(pred))
		assertTrue(PREFIX, "AbsorbRemains", "IsDigested(preyData)", IsDigested(preyData))
		assertTrue(PREFIX, "AbsorbRemains", "Has(pred, content)", Has(pred, content))
	endIf

	; If the content is the player, don't do anything yet; the KillPlayer function will do that work.
	if content == playerRef
		return
	elseif !RegisterBlock("AbsorbRemains", pred)
		return
	endIf

	Actor apex = FindApex(content)
	bool local = apex == playerRef || content == playerRef || apex.is3DLoaded()
	bool apexIsDead = apex.isDead()
	bool apexIsNPC = apex.hasKeyword(ActorTypeNPC)

	if DEBUGGING
		Log3(PREFIX, "AbsorbRemains", Namer(apex), Namer(pred), Namer(content))
	endIf

	if content as Actor
		ConsoleUtil.SetSelectedReference(content as Actor)	;Fix brought to my attention by this mod: https://www.nexusmods.com/skyrimspecialedition/mods/62413?tab=description
		ConsoleUtil.ExecuteCommand("unequipall")
		content.removeAllItems(apex, false, true)
		UnassignPreyMeters(content as Actor)
		content.disable()

	elseif content as DevourmentBolus
		DevourmentBolus bolus = content as DevourmentBolus
		bolus.disableDropping()
		bolus.removeAllItems(apex, false, true)
	
	else
		content.removeAllItems(apex, false, true)
	endIf

	RemoveFromStomach(pred, content, preyData)
	UpdateSounds_async(apex)

	if apexIsNPC
		apex.SetExpressionOverride(10, 0)
	endIf

	sendExcretionEvent(apex, content)

	if pred == playerRef
		PlayerAlias.CheckClearEliminate()
	endIf

	UnregisterBlock("AbsorbRemains", pred)
endFunction


function ExpelRemains(Actor pred, ObjectReference content, int preyData)
{ Remove digested stomach contents from pred tummy. Only for NPCs! }
	if DEBUGGING
		assertExists(PREFIX, "ExpelRemains", "preyData", preyData) 
		assertNotNone(PREFIX, "ExpelRemains", "apex", FindApex(content))
		assertNotNone(PREFIX, "ExpelRemains", "pred", pred)
		assertNotNone(PREFIX, "ExpelRemains", "content", content)
		assertTrue(PREFIX, "ExpelRemains", "IsPred(pred)", IsPred(pred))
		assertTrue(PREFIX, "ExpelRemains", "IsDigested(preyData)", IsDigested(preyData))
		assertTrue(PREFIX, "ExpelRemains", "Has(pred, content)", Has(pred, content))
	endIf

	Actor apex = FindApex(content)

	; If the content is the player and BYK is set, don't do anything yet; wait until KillPlayer has been
	; called -- which will either kill the player or make the player the pred.
	if apex == playerRef && !(crouchScat && apex.isSneaking() && !apex.IsWeaponDrawn())
		return
	elseif apex != pred || !RegisterBlock("ExpelRemains", pred)
		return
	endIf
	
	bool local = apex == playerRef || content == playerRef || apex.is3DLoaded()
	bool apexIsDead = apex.isDead()
	bool apexIsNPC = apex.hasKeyword(ActorTypeNPC)
	bool apexSneaking = apex.isSneaking()
	bool apexPlayerControlled = apex == playerRef || apex.getPlayerControls()
	bool complexAnimation = (pred != playerRef || Game.GetCameraState() > 0)
	bool doNPCAnimations = complexAnimation && !apexPlayerControlled && !apexIsDead && apexIsNPC && apex.getCombatState() == 0

	if DEBUGGING
		Log3(PREFIX, "ExpelRemains", Namer(apex), Namer(pred), Namer(content))
	endIf

	if doNPCAnimations && complexAnimation
		Utility.Wait(1.0)
		Defecate(apex, pred, content, preyData, local)
		Utility.Wait(0.5)
		apex.playIdle(IdleStop)
	else
		Defecate(apex, pred, content, preyData, local)
	endIf

	if content as Actor
		UnassignPreyMeters(content as Actor)
	endIf
	
	UpdateSounds_async(apex)

	if apexIsNPC
		apex.SetExpressionOverride(10, 0)
	endIf

	sendExcretionEvent(apex, content)

	if pred == playerRef
		PlayerAlias.CheckClearEliminate()
	endIf
	
	UnregisterBlock("ExpelRemains", pred)
endFunction


bool Function DefecateOne(ObjectReference content, bool force = false, bool escape = false)
{ Causes a pred to defecate one or all of their prey. }
	int preyData = GetPreyData(content)
	Actor pred = GetPred(preyData)
	Actor apex = FindApex(content)

	if DEBUGGING
		assertNotNone(PREFIX, "defecateOne", "apex", apex)
		assertNotNone(PREFIX, "defecateOne", "pred", pred)
		assertNotNone(PREFIX, "defecateOne", "content", content)
		assertTrue(PREFIX, "defecateOne", "Has(pred, content)", Has(pred, content))
		LogJ(PREFIX, "defecateOne", preyData, apex, pred, content)
	endIf

	if !(IsDigested(preyData) || IsAlive(preyData) || content as DevourmentBolus || force)
		return false
	endIf

	bool blocked = RegisterBlock("DefecateOne", pred)
	if !blocked
		return false
	endIf
	
	bool apexIsNPC = apex.hasKeyword(ActorTypeNPC)
	bool local = apex == playerRef || content == playerRef || apex.is3DLoaded()
	bool weaponDrawn = apex.isWeaponDrawn()
	bool complexAnimation = (pred != playerRef || Game.GetCameraState() > 0)
	bool doAnimations = complexAnimation && !apex.isDead() && apexIsNPC && apex.getCombatState() == 0

	; Do the crouch and poop animation.
	if local && doAnimations
		if weaponDrawn && drawnAnimations
			apex.sheatheWeapon()
			Utility.wait(0.5)
			Debug.SendAnimationEvent(apex, "IdleWarmHandsCrouched")
			Utility.Wait(1.5)
		elseif !weaponDrawn
			Debug.SendAnimationEvent(apex, "IdleWarmHandsCrouched")
			Utility.Wait(1.5)
		endIf
	endIf

	if content as Actor
		if IsAlive(preyData)
			DefecateUndigestedActor(apex, pred, content as Actor, preyData, local)
		else
			DefecateDigestedActor(apex, pred, content as Actor, preyData, local)
		endIf
	else
		DefecateBolus(apex, pred, content, preyData, local)
	endIf

	if apexIsNPC
		apex.SetExpressionOverride(10, 0)
	endIf
	
	UpdateSounds_async(apex)

	if local && doAnimations
		if escape
			content.pushActorAway(apex, 5.0)
		else
			apex.playIdle(IdleStop)
			if weaponDrawn && drawnAnimations
				apex.drawWeapon()
			endIf
		endIf
	endIf
	
	if pred == playerRef
		PlayerAlias.CheckClearEliminate()
	endIf
	
	if blocked
		UnregisterBlock("DefecateOne", pred)
	endIf
	
	return true
endFunction


Function DefecateAny(Actor pred, bool all = false)
{ Causes a pred to defecate all living, digested prey. }
	Actor apex = FindApex(pred)
	
	if DEBUGGING
		assertNotNone(PREFIX, "defecateAny", "apex", apex)
		assertNotNone(PREFIX, "defecateAny", "pred", pred)
		Log2(PREFIX, "defecateAny", Namer(apex), Namer(pred))
	endIf

	if !RegisterBlock("DefecateAny", pred)
		return
	endIf
	
	bool local = apex == playerRef || apex.is3DLoaded()
	bool apexNPC = apex.hasKeyword(ActorTypeNPC)
	bool weaponDrawn = apex.isWeaponDrawn()
	bool complexAnimation = (pred != playerRef || Game.GetCameraState() > 0)
	bool doAnimations = complexAnimation && !apex.isDead() && apexNPC && apex.getCombatState() == 0

	; Do the crouch and poop animation.
	if local && doAnimations
		if weaponDrawn && drawnAnimations
			apex.sheatheWeapon()
			Utility.wait(0.5)
			Debug.SendAnimationEvent(apex, "IdleWarmHandsCrouched")
			Utility.Wait(1.5)
		elseif !weaponDrawn
			Debug.SendAnimationEvent(apex, "IdleWarmHandsCrouched")
			Utility.Wait(1.5)
		endIf
	endIf

	Form[] stomach = GetStomachArray(pred)
	if DEBUGGING
		LogForms(PREFIX, "DefecateAny", Namer(pred) + "'s stomach", stomach)
	endIf

	int i = 0
	while i < stomach.length
		ObjectReference content = stomach[i] as ObjectReference
		int preyData = GetPreyData(content)

		if DEBUGGING
			Log2(PREFIX, "DefecateAny", Namer(apex), Namer(content))
		endIf

		bool expelled = defecate(apex, pred, content, preyData, local)

		if expelled && apexNPC
			apex.SetExpressionOverride(10, 0)
		endIf

		i += 1
	endWhile

	UpdateSounds_async(apex)

	if local && doAnimations
		apex.playIdle(IdleStop)
		if weaponDrawn && drawnAnimations
			apex.drawWeapon()
		endIf
	endIf
	
	if pred == playerRef
		PlayerAlias.CheckClearEliminate()
	endIf

	UnregisterBlock("DefecateAny", pred)
endFunction


bool Function defecate(Actor apex, Actor pred, ObjectReference content, int preyData, bool local)
	if DEBUGGING
		assertExists(PREFIX, "defecate", "preyData", preyData)
		assertNotNone(PREFIX, "defecate", "apex", apex)
		assertNotNone(PREFIX, "defecate", "pred", pred)
		assertNotNone(PREFIX, "defecate", "content", content)
		assertTrue(PREFIX, "defecate", "Has(pred, content)", Has(pred, content))
		LogJ(PREFIX, "defecate", preyData, apex, pred, content)
		Log1(PREFIX, "defecate", "local="+local)
	endIf

	if content as Actor
		if IsAlive(preyData)
			;Log2(PREFIX, "defecate", Namer(apex), Namer(content))
			defecateUndigestedActor(apex, pred, content as Actor, preyData, local)
			return true
		elseif IsDigested(preyData)
			;Log2(PREFIX, "defecate", Namer(apex), Namer(content))
			defecateDigestedActor(apex, pred, content as Actor, preyData, local)
			return true
		else
			return false
		endIf
	else
		;Log2(PREFIX, "defecateAny", Namer(apex), Namer(content))
		defecateBolus(apex, pred, content, preyData, local)
		return true
	endIf
endFunction


Function defecateBolus(Actor apex, Actor pred, ObjectReference content, int preyData, bool local)
{
Removes a single dead content from the pred and places a scat pile or bones behind them.
@param apex The apex predator. Their position will be used to place the content.
@param pred The actual predator. Their stomach contents will be updated.
@param content The content to defecate. They must not be an Actor.
@param preyData The preyData for pred/prey.
@param local A flag indicating that this is taking place near the player so sound effects, visuals, and animations should be played.
}
	RemoveFromStomach(pred, content, preyData)

	if local
		if apex.hasKeyword(ActorTypeNPC)
			if IsMale(apex)
				ScatSounds[0].play(apex)
			else
				ScatSounds[1].play(apex)
			endIf
		else
			ScatSounds[2].play(apex)
		endIf
	endIf

	if content as DevourmentBolus
		ReappearBolusAt(content as DevourmentBolus, apex, front = false, lateral = -70.0, vertical = 10.0)
	else
		ReappearItemAt(content, apex, front = false, lateral = -70.0)
	endIf

	if !(Apex.hasPerk(Menu.SilentDefecate) && apex.IsSneaking())
		apex.CreateDetectionEvent(apex, 100)
	endIf
EndFunction

	
Function defecateDigestedActor(Actor apex, Actor pred, Actor prey, int preyData, bool local)
{
Removes a single dead content from the pred and places a scat pile or bones behind them.
@param apex The apex predator. Their position will be used to place the content.
@param pred The actual predator. Their stomach contents will be updated.
@param content The content to defecate. They must be a dead Actor or a bolus.
@param preyData The preyData for pred/prey.
@param local A flag indicating that this is taking place near the player so sound effects, visuals, and animations should be played.
}
	RemoveFromStomach(pred, prey, preyData)
	UnassignPreyMeters(prey)

	if scatTypeNPC == 2 && prey.hasKeyword(ActorTypeNPC)
		if local 
			if IsFemale(apex)
				BoneSound_Female.play(apex)
			else
				BoneSound_Male.play(apex)
			endIf
		endIf
	
		; Place the skeleton. If this is happening nearby, start the skeleton disabled so that we can move it around BEFORE it appears.
		ActorBase bones = GetBonesType(prey)
		Actor pile = apex.placeAtMe(bones, 1, true, local) as Actor

		if local
			float angleZ = apex.GetAngleZ()
			pile.setPosition(apex.GetPositionX() - 60.0*Math.sin(angleZ), apex.GetPositionY() - 60.0*Math.cos(angleZ), apex.GetPositionZ())
			pile.setAlpha(0.0)
			pile.kill()
			pile.Enable()
			pile.setAlpha(0.0)
			apex.placeAtMe(BoneExplosion)
			pile.setScale(prey.GetScale())
			pile.SetDisplayName("Bones (" + Namer(prey, true) + ")")
			Utility.Wait(0.5)
			pile.setAlpha(1.0, true)
		endIf
		
		if prey != playerRef
			ConsoleUtil.SetSelectedReference(prey)
			ConsoleUtil.ExecuteCommand("unequipall")
			prey.removeAllItems(pile, false, true)
		else
			; Move the player (who is still both invisible and dead) to the pile.
			playerRef.RemoveSpell(NotThere_Trapped)
			playerRef.moveTo(pile)
			playerRef.setPosition(pile.X, pile.Y, pile.Z)
			Game.DisablePlayerControls()
			PlayerAlias.SetCameraTarget(PlayerRef)
		endIf

		if local
			RaiseDead_async(apex, pile)
		else
			pile.SetActorOwner(None)
			pile.SetFactionOwner(None)
		endIf
	else
		if local
			if apex.hasKeyword(ActorTypeNPC)
				if IsMale(apex)
					ScatSounds[0].play(apex)
				else
					ScatSounds[1].play(apex)
				endIf
			else
				ScatSounds[2].play(apex)
			endIf
		endIf

		Container feces = GetFecesType(prey)
		ObjectReference pile = apex.placeAtMe(feces, 1, true, false)
		
		pile.setScale(Math.sqrt(GetVoreWeight(prey) / 100.0))
		pile.setAngle(0.0, 0.0, Utility.RandomFloat(0.0,360.0))
		
		if prey != playerRef
			prey.removeAllItems(pile, false, true)
		else
			; Move the player (who is still both invisible and dead) to the pile.
			playerRef.RemoveSpell(NotThere_Trapped)
			playerRef.moveTo(pile)
			playerRef.setPosition(pile.X, pile.Y, pile.Z)
			Game.DisablePlayerControls()
			PlayerAlias.SetCameraTarget(PlayerRef)
		endIf

		pile.SetDisplayName(Namer(prey, true) + "'s remains")
		pile.SetActorOwner(None)
		pile.SetFactionOwner(None)
		
		Notification2(Messages_Defecated[1], apex, prey)
	endIf

	if !(Apex.hasPerk(Menu.SilentDefecate) && apex.IsSneaking())
		apex.CreateDetectionEvent(apex, 100)
	endIf
EndFunction


Function defecateUndigestedActor(Actor apex, Actor pred, Actor prey, int preyData, bool local)
{
Removes a single live prey or bolus from the pred and places them behind them.
@param content The prey data.
@param local A flag indicating that this is taking place near the player so sound effects, visuals, and animations should be played.
}
	if prey == playerRef
		PlayerAlias.StopPlayerStruggle()
	endIf

	RemoveFromStomach(pred, prey, preyData)
	ReappearPreyAt(prey, apex, lateral = -70.0, vertical = 20.0)

	; This is a good spot to do stuff that might take a while, because we will have to wait
	; for the content to finish reappearing anyway!

	if local
		; Pick the correct defecation sound.
		; Play the scat sound and reappear the prey near the apex.
		if apex.hasKeyword(ActorTypeNPC)
			if IsMale(apex)
				ScatSounds[0].play(apex)
			else
				ScatSounds[1].play(apex)
			endIf
		else
			ScatSounds[2].play(apex)
		endIf

		; Wait for the prey to be fully loaded. Moves happen asynchronously and they can take up to half a second!
		if WaitUntilPresent(prey, apex)
			apex.PushActorAway(prey, 10.0)
		endIf
	endIf

	Notification2(Messages_Defecated[0], apex, prey)
	UpdateSounds_async(prey)
	sendEscapeEvent(pred, prey, IsEndo(preyData))
	sendExcretionEvent(apex, prey)

	if prey == playerRef
		pred.AddSpell(StatusSpells[0], false)
	elseif pred == playerRef
		prey.AddSpell(StatusSpells[1], false)
	endIf

	if !(Apex.hasPerk(Menu.SilentDefecate) && apex.IsSneaking())
		apex.CreateDetectionEvent(apex, 100)
	endIf
endFunction
	
	
Container Function GetFecesType(Actor prey)
	String preyRace = Remapper.RemapRaceName(prey)

	if preyRace == "Dunmer" || preyRace == "Altmer" || preyRace == "Bosmer"
		return RemainsFeces[1]
	elseIf preyRace == "Argonian"
		return RemainsFeces[2]
	elseif preyRace == "Khajiit"
		return RemainsFeces[3]
	elseIf preyRace == "Orsimer"
		return RemainsFeces[4]
	elseIf preyRace == "Dragon"
		return RemainsFeces[5]
	elseIf preyRace == "Horse"
		return RemainsFeces[6]
	elseIf prey.hasKeyword(ActorTypeNPC)
		return RemainsFeces[0]
	else
		return RemainsFeces[7]
	endIf
EndFunction


ActorBase Function GetBonesType(Actor prey )
	String preyRace = Remapper.RemapRaceName(prey)

	if preyRace == "Dunmer" || preyRace == "Altmer" || preyRace == "Bosmer"
		return RemainsBones[1]
	elseIf preyRace == "Argonian"
		return RemainsBones[2]
	elseif preyRace == "Khajiit"
		return RemainsBones[3]
	elseIf preyRace == "Orsimer"
		return RemainsBones[4]
	elseIf preyRace == "Dragon"
		return RemainsBones[5]
	else
		return RemainsBones[0]
	endIf
EndFunction


Sound Function GetDeathSound(Actor prey)
	;String preyRace = Remapper.RemapRaceName(prey)

	if prey.HasKeyword(ActorTypeNPC)
		if IsFemale(prey)
			if ScreamSounds
				return DeathScreams[0]
			else
				return DeathScreams[5]
			endIf
		else
			if ScreamSounds
				return DeathScreams[1]
			else
				return DeathScreams[6]
			endIf
		endIf
	elseif prey.HasKeyword(ActorTypeAnimal)
		return DeathScreams[2]
	elseif prey.HasKeyword(ActorTypeCreature)
		return DeathScreams[3]
	elseif prey.HasKeyword(ActorTypeUndead) || prey.HasKeyword(ActorTypeDaedra)
		return DeathScreams[4]
	else
		return DeathScreams[3]
	endIf
EndFunction


Function ReformPrey(Actor pred, Actor prey, int preyData)
	if prey != playerRef
		prey.MoveTo(HerStomach)
		prey.Enable()
		prey.Reset(FakePlayer)
		OutfitRemove(prey)
		prey.RemoveAllItems()
	endIf
	
	prey.IgnoreFriendlyHits(true)
	prey.SetGhost(false)

	;if pred == playerRef && prey == playerRef && NewDova.deadDovaRef != None
	;	prey = NewDova.deadDovaRef
	;endIf
	
	; Make the prey friendly towards the pred.
	if prey == playerRef
		Game.EnablePlayerControls()
		PlayerAlias.GotoEndo(preyData)
		pred.AddSpell(StatusSpells[4])
	elseif prey.GetRelationshipRank(Pred) < 2
		prey.SetRelationshipRank(Pred, 2)
	endIf

	if pred == playerRef
		prey.AddSpell(StatusSpells[3])
		prey.AddToFaction(PlayerFaction)
		prey.RemoveFromFaction(prey.GetCrimeFaction())
	endIf

	WeightGain_Async(pred, prey, false)
	DeactivatePrey(prey)
	SetEndo(preyData, prey != playerRef && pred != playerRef)
	SetMeters_Reformed(prey)
	
	if GetLocus(preyData) == 2
		StorageUtil.SetIntValue(prey, "DevourmentReborn", 1)
	endIf
EndFunction


Function KillPlayer(Actor pred)
	if !assertNotNone(PREFIX, "KillPlayer", "pred", pred)
		return
	endIf

	UnassignAllPreyMeters()

	if PlayerRef.HasPerk(Menu.Phylactery) ;BYK == 0 &&
		Log1(PREFIX, "KillPlayer", "Phylactery.")
		if IsPrey(pred)
			DefecateOne(playerRef, force = true)
		endIf
		pred.AddSpell(StatusSpells[5])
		ReplacePrey(pred, playerRef, fakePlayer)
		ReformationQuest.StartReformation()
	
	elseif Menu.AutoRebirth && GetLocusFor(PlayerRef) == 2 && !IsPrey(pred) ;BYK == 0 &&
		RegisterReformation(pred, PlayerRef, 2)
			
	elseif pred.hasKeyword(ActorTypeNPC) ;BYK == 0 &&
		Log1(PREFIX, "KillPlayer", "No reincarnation.")
		KillPlayer_ForReal()
		
	;elseif BYK < 2 && pred.hasKeyword(ActorTypeCreature)
	;	Log1(PREFIX, "KillPlayer", "BYK is < 2 -- no reincarnation as a creature.")
	;	KillPlayer_ForReal()
		
	elseif IsPrey(pred) 
		Log1(PREFIX, "KillPlayer", "Pred is not the apex -- no reincarnation.")
		KillPlayer_ForReal()
		
	elseif !VerifyPred(playerRef) 
		assertFail(PREFIX, "KillPlayer", "!VerifyPred(playerRef)")
		KillPlayer_ForReal()
		
	;else
		;/
		RegisterBlocks("KillPlayer", playerRef, pred)
		
		; BYK IS set, so we have to completely disable the predator and then turn
		; the player INTO them.
		StopVoreSounds(pred)

		; Transfer the player's prey (if any) to the pred.
		if IsPred(playerRef)
			TransferStomach(playerRef, pred)
		endIf
		
		; Replace the player in the predator's stomach with fakePlayer.
		ReplacePrey(pred, playerRef, fakePlayer)
		
		; Transfer the predator's other prey to the player.
		TransferStomach(pred, playerRef)
		UpdateSounds_async(playerRef)

		; With the stomach transferred, it should be safe to unblock now.
		UnregisterBlocks("KillPlayer", playerRef, pred)

		; Transfer inventory.
		PlayerRef.RemoveAllItems(FakePlayer)

		; Copy appearance, inventory, etc.
		NewDova.switchPlayer(pred)
		
		RemovePredator(pred)
		UpdateSounds_async(playerRef)
		SendNewCharacterEvent(pred, playerRef)
		RestoreAllPreyMeters()
		/;
	endIf
EndFunction


Function KillPlayer_ForReal()
	Actor pred = GetPredFor(PlayerRef)
	Actor apex = FindApex(playerRef)
	
	if DEBUGGING
		Log3(PREFIX, "KillPlayer_ForReal", "Killing player.", Namer(apex), Namer(pred))
	endIf
	
	if Game.IsPluginInstalled("daymoyl.esm")
		ConsoleUtil.PrintMessage("Invoking DeathAlternative")
		apex.SendModEvent("da_ApplyBlackscreen")
		Utility.wait(2.0)
		
		if pred 
			FakePlayer.SetName(PlayerRef.GetName())
			ReplacePrey(pred, playerRef, FakePlayer)
		endIf
		
		apex.SendModEvent("da_ForceBlackout")
		playerRef.removeSpell(NotThere_Trapped)
		playerRef.removeSpell(NotThere_Friendly)
		Unghostify(playerRef)
		UnassignPreyMeters(playerRef)
		
		playerRef.enableNoWait(false)
		playerRef.stopCombat()
		reactivatePrey(playerRef)
		playerRef.PlayIdle(IdleStop)

	elseif SoftDeath && Game.IsPluginInstalled("SMEssentialPlayer.esp")
		ReplacePrey(pred, playerRef, fakePlayer)

		if apex
			ReappearPreyAt(PlayerRef, apex, lateral = -70.0, vertical = 20.0)
		elseif pred
			ReappearPreyAt(PlayerRef, pred, lateral = -70.0, vertical = 20.0)
		endIf
		
		playerRef.DamageActorValue("Health", 10000.0)

	else
		if apex
			playerRef.moveTo(apex)
		elseif pred
			playerRef.moveTo(pred)
		endIf
		
		playerRef.SetAlpha(0.0)
		playerRef.RemoveSpell(NotThere_Trapped)
		
		if IsPrey(playerRef)
			if scatTypeNPC != 0
				DefecateOne(playerRef, force = true)
			endIf
		endIf
		
		if SoftDeath
			playerRef.Kill(pred)
		else
			playerRef.GetLeveledActorBase().setProtected(false)
			playerRef.KillEssential(pred)
		endIf
	endIf
	
EndFunction


Function AddPreyEffects(Actor pred, Actor prey, bool endo, int preyData)
{ Adds the spells that control prey, and assigns health/struggle meters. }

	if prey.isDead()
		if prey.hasSpell(NotThere_Friendly)
			prey.removeSpell(NotThere_Friendly)
		endIf
		if pred == playerRef || prey == playerRef
			assignPreyMeters(prey, GetDigestionPercent(preyData), false, false)
		endIf
		
	elseif endo
		UnassignPreyMeters(prey)
		if !prey.hasSpell(NotThere_Friendly)
			prey.addSpell(NotThere_Friendly, false)
		endIf
		
	else
		if prey.hasSpell(NotThere_Friendly)
			prey.removeSpell(NotThere_Friendly)
		endIf

		if prey.HasPerk(Menu.Cordyceps) && !isConsented(preyData)
			pred.AddSpell(CordycepsFrenzy)
		endIf

		if pred == playerRef || prey == playerRef
			if IsAlive(preyData) 
				assignPreyMeters(prey, 100.0 * prey.GetActorValuePercentage("Health"), true, CanStruggle(prey, preyData))
			else
				assignPreyMeters(prey, GetDigestionPercent(preyData), false, false)
			endIf
		endIf
	endIf
EndFunction


int Function TransferWornForm(Actor owner, ObjectReference bolus, int slot)
{ Unequips an item (by inventory slot) from the target and adds it a bolus. }
	if DEBUGGING
		Log5(PREFIX, "TransferWornForm", Namer(owner), Namer(bolus), slot, Namer(owner.getWornForm(slot)), IsStrippable(owner.getWornForm(slot)))
	endIf

	Form wornForm = owner.getWornForm(slot)
	if wornForm && IsStrippable(wornForm)
		if DEBUGGING
			Log1(PREFIX, "TransferWornForm", "Stripping " + Namer(wornForm))
		endIf		
		owner.removeItem(wornForm, 1, true, bolus)
		return 1
	else
		return 0
	endIf
EndFunction


bool Function DigestItem(Actor pred, Form item, int count, Actor owner, bool unrestricted = true, int locus = -1)
{ 
Creates a bolus for the specified item, with an optional owner, and registers it as swallowed. 
If locus is negative, it will be determined from the owner's preyData (if any).
The unrestricted skips the "IsStrippable" check.
}
	if !(pred && item) 
		assertNotNone(PREFIX, "DigestItem", "pred", pred)
		assertNotNone(PREFIX, "DigestItem", "item", item)
		return false
	endIf

	if !(unrestricted || IsStrippable(item))
		Log2(PREFIX, "DigestItem", Namer(item), "Unstrippable")
		return false
	endIf
	
	if DEBUGGING
		Log5(PREFIX, "DigestItem", Namer(pred), Namer(item), count, Namer(owner), locus)
	endIf

	if count <= 0
		Log1(PREFIX, "DigestItem", "Non-positive item count.")
		return false
	endIf
	
	; If the item is a DevourmentSkull, try to revive it.
	if item as DevourmentSkullObject
		DevourmentSkullObject skull = item as DevourmentSkullObject

		if !skull.IsInitialized() || !skull.IsEnabled()
			Log1(PREFIX, "DigestItem", "Uninitialized DevourmentSkull; skipping reformation.")

		elseif SkullHandler.SwallowSkull(pred, item as DevourmentSkullObject, locus)
			Log1(PREFIX, "DigestItem", "DevourmentSkull passed to the SkullHandler.")
			return true

		else
			Log1(PREFIX, "DigestItem", "SkullHandler failed for some reason.")
			if DEBUGGING
				Debug.MessageBox("Skull reformation failed. Check the Papyrus Log.")
			endIf
			return false
		endIf
	endIf
	
	; If the item is edible, eat it.
	Form itemBase
	ObjectReference itemRef = item as ObjectReference
	if itemRef
		itemBase = itemRef.GetBaseObject()
	else
		itemBase = item
	endIf

	if itemBase as Ingredient || itemBase as Potion
		Log1(PREFIX, "DigestItem", "Found ingredient/potion.")
		return ConsumeItem(pred, itemBase, itemRef, count)
	endIf

	; If there is a very recent bolus, stick this item into it rather than creating a new one.
	DevourmentBolus recentBolus = JLua.evalLuaForm("return dvt.GetRecentBolus(args.pred)", JLua.setForm("pred", pred)) as DevourmentBolus
	if recentBolus
		Log1(PREFIX, "DigestItem", "Found recent bolus")
		recentBolus.AddItem(item, count)
		recentBolus.SetName("Bolus")
		UpdateBolusData(pred, recentBolus)
		return true
	endIf

	if locus < 0
		if pred == PlayerRef
			locus = PlayerAlias.DefaultLocus
		else
			locus = 0
		endIf

		if owner
			int preyData = GetPreyData(owner)
			if JValue.IsExists(preyData)
				locus = GetLocus(preyData)
			endIf
		endIf
	endIf
	
	; Create a container to hold the items.
	; BolusContainer has a script that causes anything removed from
	; it to be dropped. This trick came from the Destructible Containers mod!
	DevourmentBolus bolus = FakePlayer.placeAtMe(BolusContainer) as DevourmentBolus
	
	String name
	if count > 1
		name = Namer(item, true) + " (" + count + ")"
	else
		name = Namer(item, true)
	endIf
	
	if owner
		bolus.Initialize(name, owner, pred)
		owner.removeItem(item, count, true, bolus)
	else
		bolus.Initialize(name, pred, pred)
		bolus.addItem(item, count, true)
	endIf
	
	; Give the bolus scripts a chance to catch up.
	Utility.WaitMenuMode(0.5)

	return RegisterDigestion(pred, bolus, false, locus)
endFunction


bool Function ConsumeItem(Actor consumer, Form itemBase, ObjectReference itemRef, int count)
	if !(itemBase as Ingredient || itemBase as Potion)
		Log2(PREFIX, "ConsumeItem", "Not consumable", Namer(itemBase))
		return false
	endIf

	if DEBUGGING
		Log4(PREFIX, "ConsumeItem", Namer(consumer), Namer(itemBase), Namer(itemRef), count)
	endIf
	
	int handle = ModEvent.Create("Devourment_onConsumeItem")
	ModEvent.PushForm(handle, consumer)
	ModEvent.PushForm(handle, itemBase)
	ModEvent.PushInt(handle, count)
	ModEvent.Send(handle)

	Potion itemPotion = itemBase as Potion
	if itemPotion && itemPotion.IsPoison()
		Log1(PREFIX, "DigestItem", "Fake Poisoning")
		ApplyFakePotion(itemPotion, consumer, 0.5 * count)

		if itemRef
			itemRef.Delete()
		endIf
	
	elseif itemRef
		consumer.AddItem(itemRef, count, true)
		while count
			count -= 1
			consumer.EquipItem(itemBase)
		endWhile
		itemRef.Delete()

	else
		consumer.AddItem(itemBase, count, true)
		while count
			count -= 1
			consumer.EquipItem(itemBase)
		endWhile
	endIf
	
	return true
EndFunction


Function OutfitRestore(Actor subject)
	if subject && StorageUtil.HasFormValue(subject, "DevourmentOriginalOutfit")
		Outfit original = StorageUtil.GetFormValue(subject, "DevourmentOriginalOutfit") as Outfit
		if original
			subject.SetOutfit(original)
		endIf
	endIf

	if subject != playerRef
		subject.disable()
		subject.enable()
	endIf
EndFunction


Function OutfitRemove(Actor subject)
	if subject && subject != PlayerRef 
		subject.SetOutfit(DigestionOutfit)

		ActorBase subjectBase = subject.GetLeveledActorBase()
		if subjectBase.IsUnique()
			Outfit original = subjectBase.GetOutfit()
			if original
				StorageUtil.SetFormValue(subject, "DevourmentOriginalOutfit", original)
			endIf
		endIf
	endIf
EndFunction


Function DigestEquipment(Actor pred, Actor prey, int locus, int level)
{
Transfers some of the NPC's armor/clothes to the pred for digestion.
Level = 0: body, shield
Level = 1: body, shield, helmet, gloves, bracers, boots
Level = 2: entire inventory
The reason for this is that the owner's clothes will respawn on vomit unless at least one piece is left behind.
}
	if !(pred && prey) || DEBUGGING
		!assertNotNone(PREFIX, "DigestEquipment", "prey", prey)
		!assertNotNone(PREFIX, "DigestEquipment", "pred", pred)
		Log4(PREFIX, "DigestEquipment", Namer(pred), Namer(prey), locus, level)
	endIf
	
	; Create a container to hold the items.
	; BolusContainer has a script that causes anything removed from
	; it to be dropped. This trick came from the Destructible Containers mod!
	DevourmentBolus bolus = FakePlayer.placeAtMe(BolusContainer) as DevourmentBolus
	bolus.owner = prey
	String preyName = Namer(prey, true)
	bolus.SetName(preyName + "'s equipment")

	if preyName == ""
		Debug.MessageBox("PREY MISSING NAME")
	endIf

	int count = 0
	
	if level == 0
		count += TransferWornForm(bolus.owner, bolus, 0x00000004) ; 32, body
		count += TransferWornForm(bolus.owner, bolus, 0x00000200) ; 39, shield
	elseif level == 1
		count += TransferWornForm(bolus.owner, bolus, 0x00000004) ; 32, body
		count += TransferWornForm(bolus.owner, bolus, 0x00000200) ; 39, shield
		count += TransferWornForm(bolus.owner, bolus, 0x00000001) ; 30, helmet
		count += TransferWornForm(bolus.owner, bolus, 0x00000008) ; 33, hands
		count += TransferWornForm(bolus.owner, bolus, 0x00000010) ; 34, forearms
		count += TransferWornForm(bolus.owner, bolus, 0x00000080) ; 37, feet
		OutfitRemove(prey)
	elseif level == 2
		count += prey.GetNumItems()
		prey.RemoveAllItems(bolus, false, true)
	endIf

	if DEBUGGING
		Log1(PREFIX, "DigestEquipment", Namer(pred) + ": " + bolus.GetNumItems() + " pieces of equipment removed from " + Namer(prey) + ".")
	endIf
	
	RegisterDigestion(pred, bolus, false, locus)
EndFunction


bool Function IsStrippable(Form item)
	{ Checks if an item should be removed during digestion or not. }

	if item == None
		if DEBUGGING
			Log1(PREFIX, "IsStrippable", "NONE")
		endIf
		return false
	elseif !item.isPlayable() 
		if DEBUGGING
			Log2(PREFIX, "IStrippable", "!isPlayable()", Namer(item))
		endIf
		return false
	elseif item.HasKeywordString("SexlabNoStrip")
		if DEBUGGING
			Log2(PREFIX, "IStrippable", "SexlabNoStrip", Namer(item))
		endIf
		return false
	elseif item.HasKeywordString("zad_BlockGeneric")
		if DEBUGGING
			Log2(PREFIX, "IStrippable", "zad_BlockGeneric", Namer(item))
		endIf
		return false
	elseif item.HasKeywordString("zad_QuestItem")
		if DEBUGGING
			Log2(PREFIX, "IStrippable", "zad_QuestItem", Namer(item))
		endIf
		return false
	elseif item as ObjectReference
		ObjectReference ref = item as ObjectReference
		if ref.GetBaseObject().GetName() == "" 
			if DEBUGGING
				Log2(PREFIX, "IStrippable", "Unnamed", Namer(item))
			endIf
			return false
		elseif PO3_SKSEFunctions.IsQuestItem(ref) 
			if DEBUGGING
				Log2(PREFIX, "IStrippable", "PO3.QuestItem", Namer(item))
			endIf
			return false
		elseif PO3_SKSEFunctions.IsVIP(ref)
			if DEBUGGING
				Log2(PREFIX, "IStrippable", "PO3.VIP", Namer(item))
			endIf
			return false
		endIf
	endIf

	return true
endFunction


Function CompelVore()
{ Forces the Actor closest to the player (or closest to their pred) to vore someone. }
	if !SafeProcess()
		return
	endIf

	;if !DEBUGGING
	;	return
	;endif
	
	Actor center = FindApex(playerRef)
	if !center
		center = playerRef
	endIf

	Log2(PREFIX, "CompelVore", "Selected center", Namer(center))

	Actor[] nearby = MiscUtil.ScanCellNPCs(center, 1000.0)
	if nearby.length < 2
		Debug.Notification("Not enough actors within 1000 units, extending range.")
		nearby = MiscUtil.ScanCellNPCs(center, 4000.0)
	endIf

	if nearby.length < 2
		Debug.Notification("Compel requires at least two actors within 4000 units.")
		return
	endIf
	
	UIListMenu candidateMenu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
	candidateMenu.ResetMenu()

	int index = 0

	Actor[] candidates = createActorArray(nearby.length)
	int candidateIndex = 0

	while index < nearby.length
		Actor candidate = nearby[index] 
		if candidate && !candidate.IsChild()
			candidateMenu.AddEntryItem(Namer(candidate))
			candidates[candidateIndex] = candidate
			candidateIndex += 1
		endIf
		index += 1
	endWhile

	candidateMenu.OpenMenu()
	int candidatePred = candidateMenu.GetResultInt()
	if candidatePred < 0 || candidatePred >= candidates.length || !candidates[candidatePred]
		return
	endIf
	
	candidateMenu.OpenMenu()
	int candidatePrey = candidateMenu.GetResultInt()
	if candidatePrey < 0 || candidatePrey >= candidates.length || !candidates[candidatePrey]
		return
	endIf

	Actor pred = candidates[candidatePred]
	Actor prey = candidates[candidatePrey]
	
	if pred == prey
		Debug.MessageBox("Self-vore?? Sorry, no.")
		return
	endIf

	if IsPrey(pred)
		Debug.MessageBox(Namer(pred) + " was already ingested.\nThey shouldn't even BE in the list....")
		return
	endIf
	if IsPrey(prey)
		Debug.MessageBox(Namer(prey) + " was already ingested.\nThey shouldn't even BE in the list....")
		return
	endIf

	candidateMenu.ResetMenu()
	candidateMenu.AddEntryItem("Vore")
	candidateMenu.AddEntryItem("Endo")

	candidateMenu.OpenMenu()
	int result3 = candidateMenu.GetResultInt()
	
	if result3 == 0
		ForceSwallow(pred, prey, false)
	elseif result3 == 1
		ForceSwallow(pred, prey, true)
	endIf
EndFunction


Function NPCStruggle(Actor pred, Actor prey, int preyData, float times, bool successful)
{ Resolves struggle attempts. }
	if DEBUGGING
		!assertNotNone(PREFIX, "NPCStruggle", "pred", pred)
		!assertNotNone(PREFIX, "NPCStruggle", "prey", prey)
		Log5(PREFIX, "NPCStruggle", Namer(pred), Namer(prey), LuaS("preyData", preyData), times, successful)
	endIf

	bool constricted = pred.hasPerk(Menu.ConstrictingGrip)

	; Chance in the struggle bar.
	float increment = times * struggleDifficulty
	float damage = times * JMap.GetFlt(preyData, "struggleDamage")
	
	if constricted
		increment *= 0.2
	else
		GivePredXP_async(pred, damage / 5.0)
	endIf
	
	float struggle

	if successful
		struggle = AdjustStruggle(preyData, increment)
		GivePreyXP_async(prey, damage / 5.0)
	else
		struggle = AdjustStruggle(preyData, -increment)
	endIf

	; Struggle damage dealt to pred.
	playGurgle(pred, 20.0)

	if DEBUGGING
		Log6(PREFIX, "NPCStruggle", Namer(pred), Namer(prey), "times="+times, "increment="+increment, "struggle="+struggle, "damage="+damage)
	endIf

	if cameraShake > 0.0 
		if prey == playerRef 
			Game.ShakeCamera(pred, cameraShake)
		elseif pred == playerRef
			Game.ShakeController(cameraShake, 0.5 * cameraShake, 0.20)
		endIf
	endIf

	; Vomit the prey if they've filled the strugglebar.
	if struggle >= 100.0
		CheckAndSetPartingGift(pred, prey)
		UpdateStruggleMeter(prey, 100.0)
		ForceEscape(prey)
	else
		UpdateStruggleMeter(prey, struggle)
	endIf

	if !successful
		return
	endIf
	
	; Apply damage and show notifications.
	if constricted
		if DEBUGGING
			ConsoleUtil.PrintMessage(Namer(prey, true) + " struggled " + struggle as int + " percent free.")
		endIf
	else
		pred.DamageActorValue("Health", damage)
		if DEBUGGING
			ConsoleUtil.PrintMessage(Namer(prey) + " struggled " + struggle as int + " percent free, causing " + damage + " damage.")
		endIf
	endIf
EndFunction


Function RaiseDead_async(Actor pred, Actor bones)
{ Used to call RaiseDead asynchronously using a ModEvent. }
	int handle = ModEvent.create("Devourment_RaiseDead")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, bones)
	ModEvent.Send(handle)
EndFunction


Function RaiseDead(Form f1, Form f2)
	Actor pred = f1 as Actor
	Actor bones = f2 as Actor
	if Menu.EnableHungryBones && pred.hasPerk(Menu.RaiseDead)
		Utility.Wait(2.0)
		Log1(PREFIX, "RaiseDead", "Casting HungryBones")
		RaiseDead.cast(pred, bones)
	endIf
EndFunction


Event DisableEscape(Form f1)
{ EVENT HANDLER }
	if !assertNotNone(PREFIX, "DisableEscape", "f1", f1) \
	|| !assertAs(PREFIX, "DisableEscape", f1, f1 as Actor)
		return
	endIf

	int preyData = GetPreyData(f1 as ObjectReference)
	if JValue.isExists(preyData)
		SetNoEscape(preyData)
	else
		; If the prey is still in the process of being swallowed, store the flag for later.
		StorageUtil.SetIntValue(f1, "voreNoEscape", 1)
	endIf
EndEvent


Event VoreConsent(Form f1)
{ EVENT HANDLER }
	if !assertNotNone(PREFIX, "VoreConsent", "f1", f1) \
	|| !assertAs(PREFIX, "VoreConsent", f1, f1 as Actor)
		return
	endIf

	int preyData = GetPreyData(f1 as ObjectReference)
	if JValue.isExists(preyData)
		SetConsented(preyData)
	else
		; If the prey is still in the process of being swallowed, store the flag for later.
		StorageUtil.SetIntValue(f1, "voreConsent", 1)
	endIf
EndEvent


Event ForceEscape(Form f1)
{ EVENT HANDLER }
	ObjectReference prey = f1 as ObjectReference

	if !prey
		assertNotNone(PREFIX, "ForceEscape", "f1", f1)
		assertAs(PREFIX, "ForceEscape", f1, f1 as ObjectReference)
		return
	endIf

	
	int preyData = GetPreyData(prey)
	
	if AnalEscape
		DefecateOne(prey, escape=true)
	else
		RegisterVomit(prey)
	endIf
EndEvent


Event ForceSwallow(Form pred, Form prey, bool endo)
{ EVENT HANDLER }
	if !(pred && prey && pred as Actor && prey as Actor)
		assertNotNone(PREFIX, "ForceSwallow", "pred", pred)
		assertNotNone(PREFIX, "ForceSwallow", "prey", prey)
		assertAs(PREFIX, "ForceSwallow", pred, pred as Actor)
		assertAs(PREFIX, "ForceSwallow", prey, prey as Actor)
		return
	endIf

	if endo
		ScriptedEndo.Cast(pred as Actor, prey as Actor)
	else
		ScriptedVore.Cast(pred as Actor, prey as Actor)
	endIf
EndEvent


Event poop(Form f)
{ EVENT HANDLER }
	if !assertNotNone(PREFIX, "poop", "f", f) \
	|| !assertAs(PREFIX, "poop", f, f as Actor)
		return
	endIf

	DefecateAny(f as Actor)
EndEvent


Event vomit(Form f)
{ EVENT HANDLER }
	if !assertNotNone(PREFIX, "vomit", "f", f) \
	|| !assertAs(PREFIX, "vomit", f, f as Actor)
		return
	endIf

	RegisterVomitAll(f as Actor)
EndEvent


Function voreStats(Actor pred, Actor prey)
{ Record lethal digestion stats. }
	if DEBUGGING
		assertNotNone(PREFIX, "voreStats", "pred", pred)
		assertNotNone(PREFIX, "voreStats", "prey", prey)
		Log2(PREFIX, "voreStats", Namer(pred), Namer(prey))
	endIf
	
	if prey.HasKeyword(ActorTypeNPC)
		if IsMale(prey)
			incrementVictimType(pred, "men")
		elseif IsFemale(prey)
			incrementVictimType(pred, "women")
		endIf
	endIf
	
	if prey.hasKeyword(Vampire)
		incrementVictimType(pred, "vampires")
	endIf
	
	String raceName = Remapper.RemapRaceName(prey)
	
	if Menu.StatRaces.Find(raceName) >= 0
		incrementVictimType(pred, raceName)
		if pred == playerRef
			ConsoleUtil.PrintMessage("Increased your  " + raceName + " digestion count.")
		endIf
	else
		incrementVictimType(pred, "Other")
	endIf
EndFunction


Function AddSkull_Async(Actor pred, Actor prey)
{ Used to call AddSkull asynchronously using a ModEvent. }
	int handle = ModEvent.create("Devourment_AddSkull")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.Send(handle)
EndFunction


Event AddSkull(Form f1, Form f2)
	SkullHandler.AddSkull(f1 as Actor, f2 as Actor)
EndEvent


Function VoreSkills_async(Actor pred, Actor prey)
{ Used to call VoreSkills asynchronously using a ModEvent. }
	int handle = ModEvent.create("Devourment_VoreSkills")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.Send(handle)
EndFunction


Event VoreSkills(Form f1, Form f2)
{ 
If the prey had skills that exceeded the preds', the pred gets a bonus to the highest one.
If the prey had attributes that exceeded the preds', the pred gets a bonus to each.

This function gets called using the Devourment_VoreSkills event, because its very slow and needs to 
run in parallel to the main loop.
}
	Actor pred = f1 as Actor
	Actor prey = f2 as Actor
	
	if DEBUGGING
		assertNotNone(PREFIX, "voreSkills", "pred", pred)
		assertNotNone(PREFIX, "voreSkills", "prey", prey)
		Log2(PREFIX, "VoreSkills", Namer(pred), Namer(prey))
	endIf

	String predName = Namer(pred, true)
	String preyName = Namer(prey, true)
	
	String highest = ""
	Float highestVal = 0.0

	If SkillGain
		int index = Skills.length
		While index
			index -= 1
			String skillName = Skills[index]
			float skillVal = prey.getBaseActorValue(skillName)
			if skillVal > highestVal && skillVal > pred.getBaseActorValue(skillName)
				highest = skillName
				highestVal = skillVal
			endIf
		EndWhile

		if highestVal != 0.0
			if pred == playerRef
				Game.IncrementSkill(highest)
			else
				pred.setActorValue(highest, pred.getBaseActorValue(highest) + 1.0)
			endIf
		endIf
	EndIf

	If AttributeGain
		bool hp = false
		bool sp = false
		bool mp = false

		float gain
		if pred.hasPerk(Menu.ConsumeEssence)
			gain = 2.0
		else
			gain = 1.0
		endIf

		if prey.getBaseActorValue("Health") > pred.getBaseActorValue("Health")
			hp = true
			pred.modActorValue("Health", gain)
		endIf

		if prey.getBaseActorValue("Stamina") > pred.getBaseActorValue("Stamina")
			sp = true
			pred.modActorValue("Stamina", gain)
		endIf

		if prey.getBaseActorValue("Magicka") > pred.getBaseActorValue("Magicka") / 2.0
			mp = true
			pred.modActorValue("Magicka", gain)
		endIf

		if hp && sp && mp
			Notify(predName + " gained " + gain as int + " points of health, stamina, and magicka from " + preyName)
		elseif hp && sp
			Notify(predName + " gained " + gain as int + " points of health and stamina from " + preyName)
		elseif hp && mp
			Notify(predName + " gained " + gain as int + " points of health and magicka from " + preyName)
		elseif sp && mp
			Notify(predName + " gained " + gain as int + " points of stamina and magicka from " + preyName)
		elseif hp
			Notify(predName + " gained " + gain as int + " points of health from " + preyName)
		elseif sp
			Notify(predName + " gained " + gain as int + " points of stamina from " + preyName)
		elseif mp
			Notify(predName + " gained " + gain as int + " points of magicka from " + preyName)
		endIf
	EndIf
EndEvent


float function getDigestionTime(Actor pred, ObjectReference content)
	Actor prey = content as Actor
	float ratio = 1.0

	if prey
		ratio = GetVoreWeightRatio(pred, prey)
		if ratio < 0.3 
			ratio = 0.3
		endIf					
	endIf

	float skillFactor = (100.0 + GetPredSkill(pred)) / 100.0
	return DigestionTime / (skillFactor * ratio)
EndFunction


float function getHoldingTime(Actor pred)
{
Calculate the maximum time a pred can keep live prey trapped in their stomach.
The calculation incorporates:
+ Pred vore skill (quadratic)
+ Iron stomach perks
+ An automatic bonus for NPCs of 2.0
+ liveMultiplier
}
	float X = GetPredSkill(pred)
	float holdingTime = 5.0 + 0.55 * X
	holdingTime *= liveMultiplier
	holdingTime *= GetPerkMultiplier(pred, Menu.IronStomach_arr, 1.0, 0.5)
	
	if DEBUGGING
		Log5(PREFIX, "getHoldingTime", Namer(pred), holdingTime, X, 5.0 + 0.55 * X, GetPerkMultiplier(pred, Menu.IronStomach_arr, 1.0, 0.5))
	endIf
	
	return holdingTime
endFunction


float function getAcidResistance(Actor prey)
	{ Calculate the prey's acid resistance. The calculation incorporates:
	+ Resilience perks }

	float X = GetPreySkill(prey)
	float acidResistance = 0.0025 * X
	if prey != playerRef
		acidResistance *= NPCBonus
	endIf
	
	acidResistance += GetPerkMultiplier(prey, Menu.Resilience_arr, 0.0, 0.1)


	if DEBUGGING
		Log2(PREFIX, "getAcidResistance", Namer(prey), acidResistance)
	endIf

	return acidResistance
EndFunction
	
	
Float function getAcidDamage(Actor pred, Actor prey)
{
Calculate the digestion damage per second for a pred/prey combination.

The calculation incorporates:
+ Pred vore skill (quadratic)
+ Strong acid perks
+ The acidDamageModifier setting.
+ An automatic bonus for NPCs of 50%.
- Prey acid resistance
- The inverse of liveMultiplier

It does NOT incorporate magic effects that provide bonus damage, because these
need to be applied in real-time.
}
	float X = GetPredSkill(pred)
	float damage = 2.0 + 0.18 * X

	damage *= AcidDamageModifier
	damage *= GetPerkMultiplier(pred, Menu.StrongAcid_arr, 1.0, 0.5)
	damage *= (1.0 - getAcidResistance(prey))
	damage /= liveMultiplier

	if pred != playerRef
		damage *= NPCBonus
	endIf

	if DEBUGGING
		Log2(PREFIX, "getAcidDamage", Namer(pred), damage)
	endIf
	
	return damage
endFunction


float function getStruggleDamage(Actor pred, Actor prey)
{
Calculate the pred's struggling damage. The calculation incorporates:
+ Prey vore skill
+ Struggling perks
+ An automatic bonus for NPCs of 50%.
- The multiplier to live digestion time.
- The struggle difficulty setting.
}
	float X = GetPreySkill(prey)
	float damage = 2.5 + 0.225 * X

	damage *= StruggleDamage
	damage /= liveMultiplier
	damage *= GetPerkMultiplier(prey, Menu.Struggle_arr, 1.0, 0.2)
	damage *= GetPerkMultiplier(pred, Menu.IronStomach_arr, 1.0, -0.25)

	if prey != playerRef
		damage *= 2.0
	endIf

	if DEBUGGING
		Log3(PREFIX, "getStruggleDamage", Namer(pred), Namer(prey), damage)
	endIf
	
	return damage
EndFunction


float function getSwallowResistance(Actor prey)
{
Calculate the prey's swallow resistance. The calculation incorporates:
+ Prey vore skill
+ Slippery perks
+ Magic effects that provide swallow resistance.
}
	if DEBUGGING
		Log3(PREFIX, "getSwallowResistance", Namer(prey), "skill="+GetPreySkill(prey), "size="+GetCumulativeSize(prey))
	endIf

	float swallowResistance = GetPreySkill(prey)
	swallowResistance *= GetPerkMultiplier(prey, Menu.Slippery_arr, 1.0, 0.1)
	swallowResistance *= GetCumulativeSize(prey)
	return swallowResistance
EndFunction


float function getSwallowSkill(Actor pred)
{
Calculate the pred's swallow skill. The calculation incorporates:
* Pred vore skill
* Swallow perks
* NPC swallow bonus
}
	if DEBUGGING
		Log3(PREFIX, Namer(pred), "getSwallowSkill", "skill="+GetPredSkill(pred), "size="+GetCumulativeSize(pred))
	endIf

	float swallowSkill = GetPredSkill(pred)
	swallowSkill *= GetPerkMultiplier(pred, Menu.Voracious_arr, 1.0, 0.2)
	swallowSkill *= GetCumulativeSize(pred)

	if pred != playerRef
		swallowSkill *= NPCBonus
	endIf

	return swallowSkill
EndFunction


float Function GetEndoSwallowChance(Actor pred, Actor prey)
{
Calculate the swallow chance for a pred/prey endo combination. The calculation incorporates:
+ Relationship Rank
+ Speechcraft

If no prey is specified, the fakePlayer will be used.
Success is automatic for followers or lovers.
}

	float speechCraft = pred.GetActorValue("Speechcraft")
	float relationship = pred.GetRelationshipRank(prey)
	
	if DEBUGGING
		ConsoleUtil.PrintMessage("Speechcraft: " + speechCraft + ", Relationship Rank: " + relationship)
	endIf
	
	float predSize = GetVoreWeight(pred)
	float preySize = GetVoreWeight(prey)

	if relationship >= 4.0 || endoAnyone
		return 1.0
	elseif pred == playerRef && prey.IsPlayerTeammate()
		return 1.0
	elseif prey.HasKeyword(KeywordSurrender)
		return 1.0
	else
		float chance = relationship * 10.0 + speechCraft / 100.0
		if endoAnyone
			chance *= 2.0
		endIf

		if chance < 0.0
			return 0.0
		else
			return chance
		endIf
	endIf
EndFunction


float Function GetVoreSwallowChance(Actor pred, Actor prey, bool stealthy)
{
Calculate the swallow chance for a pred/prey vore combination. The calculation incorporates:
+ Pred swallow skill
+ Pred size
+ An automatic bonus of 2.5 for NPC preds
+ Bonuses sneak attacks
- Prey swallow resistance
- Prey size
- Prey health
- Prey stamina
- LiveDigestionMult
+ Magic effects that fortify swallow for the pred.
+ Magic effects that damage slipperiness for the prey.
- Magic effects that fortify slipperiness for the prey.

If no prey is specified, the fakePlayer will be used.
Success is automatic for prey that is dead, bleeding out, surrendered, or asleep (if the pred has silent swallow).
}
	if DEBUGGING
		assertNotNone(PREFIX, "GetVoreSwallowChance", "pred", pred)
		assertNotNone(PREFIX, "GetVoreSwallowChance", "prey", prey)
	endIf

	float predSize = GetVoreWeight(pred)
	float preySize = GetVoreWeight(prey)

	; These cases allow automatic success or failure.
	if prey.isDead() || prey.isBleedingOut() || prey.HasMagicEffectWithKeyword(KeywordSurrender)
		return 1.0
	elseif pred.hasPerk(Menu.SilentSwallow) && prey.getSleepState() > 2
		return 1.0
	endIf

	float predSkill = GetSwallowSkill(pred)
	float preySkill = GetSwallowResistance(prey)
	
	float preyHealth = prey.GetActorValuePercentage("Health")
	float preyStamina = prey.GetActorValuePercentage("Stamina")
	
	float healthFactor = -CombatChanceScale * (preyHealth + preyStamina/2.0)
	float skillFactor = (predSkill - preySkill) / (predSkill + preySkill)
	float sizeFactor = (predSize - preySize) / (predSize + preySize)
	float swallowChance = math.pow(2.71828, healthFactor + skillFactor + sizeFactor)
	
	if stealthy
		swallowChance *= 1.5
	endIf

	if prey.GetSleepState() > 2 || prey.IsUnconscious() || prey.HasMagicEffectWithKeyword(KeywordParalysis)
		swallowChance *= 2.0
	endIf

	if DEBUGGING
		ConsoleUtil.PrintMessage("ln(swallowChance) = -"+CombatChanceScale+"(" + preyHealth + " + " + preyStamina + "/2) + (" + predSkill + " - " + preySkill + ")/(" + predSkill + " + " + preySkill + ") + (" + predSize + " - " + preySize + ")/(" + predSize + " + " + preySize + ")")
		ConsoleUtil.PrintMessage("swallowChance = e^(" + healthFactor + " + " + skillFactor + " + " + sizeFactor + ")")
		ConsoleUtil.PrintMessage("swallowChance = " + swallowChance)
		Log6(PREFIX, "GetVoreSwallowChance", Namer(pred), Namer(prey), swallowChance, healthFactor, skillFactor, sizeFactor)
	endIf

	if DEBUGGING && pred == playerRef
		return 1.0
	elseif swallowChance < MinimumSwallowChance/100.0
		return MinimumSwallowChance/100.0
	elseif swallowChance > 1.0
		return 1.0
	else
		return swallowChance
	endIf
EndFunction


function DisappearBolusBy(Actor apex, ObjectReference content)
	{
	This is called from RegisterDigestion, and is responsible for making the item
	disappear because of a pred. Order of operations is critical to making this look good!
	}
	if DEBUGGING
		Log2(PREFIX, "DisappearBolusBy", Namer(content), Namer(apex))
	endIf
	content.moveTo(FakePlayer)
endFunction
	
	
function DisappearPreyBy(Actor apex, Actor prey, bool endo, bool isDead)
{
This is called from RegisterDigestion, and is responsible for making the prey
disappear because of a pred. Order of operations is critical to making this look good!

For the player: they become invisible, and maintain a position 1400 units
away from the pred.

For NPCs: they are moved to the HerStomach cell, and only come out for dialog.
}
	if DEBUGGING
		Log2(PREFIX, "disappearPreyBy", Namer(prey), Namer(apex))
	endIf
	
	StopVoreSounds(prey)
	
	if prey == playerRef
		PlayerAlias.setCameraTarget(apex)
		HideLocally(apex, prey)
		DeactivatePrey(prey)
		SendModEvent("dhlp-Suspend")
		
	elseif isDead
		if prey.GetEnableParent() != none
			Log2(PREFIX, "DisappearPreyBy", Namer(prey), "Relocating dead prey with an EnableParent")
			HideInStomach(prey)
		else
			Log2(PREFIX, "DisappearPreyBy", Namer(prey), "Disabling dead prey.")
			prey.Disable()
		endIf
		
	else
		PlayerAlias.CameraAndControlCheck(apex, prey, endo)
		hideInStomach(prey)
		deactivatePrey(prey)
	endIf

endFunction


function deactivatePrey(Actor prey)
	if DEBUGGING
		Log1(PREFIX, "deactivatePrey", Namer(prey))
	endIf

	prey.SheatheWeapon()
	
	if prey == playerRef
		Game.DisablePlayerControls( \
			abMovement = false, \
			abFighting = false, \
			abCamSwitch = false, \
			abLooking = false, \
			abSneaking = true, \
			abMenu = true, \
			abActivate = true, \
			abJournalTabs = true, \
			aiDisablePOVType = 0)

		PlayerRef.SetPlayerControls(false)
		Game.SetPlayerAIDriven(true)
		
		if playerRef.IsSneaking()
			playerRef.StartSneaking()
		endIf
	else
		if prey.getPlayerControls()
			prey.setPlayerControls(false)
			prey.enableAI(true)
		endIf
		prey.setRestrained(true)
	endIf

	if SwallowHeal
		prey.ResetHealthAndLimbs()
	endIf
EndFunction


function reactivatePrey(Actor prey)
	if DEBUGGING
		Log1(PREFIX, "reactivatePrey", Namer(prey))
	endIf

	if prey == playerRef
		Game.enablePlayerControls()
		playerRef.setRestrained(false)
		playerRef.setPlayerControls(true)
		Game.SetPlayerAIDriven(false)
		playerRef.EnableAI(true)
	else
		prey.setRestrained(false)
	endIf

	ClearBlock(prey)
	prey.SheatheWeapon()

	if SwallowHeal
		prey.ResetHealthAndLimbs()
	endIf
EndFunction


Function ReappearItemAt(ObjectReference item, ObjectReference loc, bool front, float lateral = 0.0)
	if DEBUGGING
		Log3(PREFIX, "ReappearItemAt", Namer(item), Namer(loc), lateral)
	endIf

	float angleZ = loc.GetAngleZ()
	float px = loc.getPositionX()
	float py = loc.getPositionY()
	float pz = loc.getPositionZ()
	
	if lateral != 0.0
		px += Math.sin(angleZ) * lateral
		py += Math.cos(angleZ) * lateral
	endIf
	
	item.moveTo(loc)
	item.SetPosition(px, py, pz)
	item.setAngle(0.0, 0.0, angleZ)
EndFunction


Function ReappearBolusAt(DevourmentBolus bolus, ObjectReference loc, bool front, float lateral = 0.0, float vertical = 0.0)
	if DEBUGGING
		Log4(PREFIX, "ReappearBolusAt", Namer(bolus), Namer(loc), lateral, vertical)
	endIf
	
	float angleZ = loc.GetAngleZ()
	float px = loc.getPositionX()
	float py = loc.getPositionY()
	float pz = loc.getPositionZ() + vertical
	
	ObjectReference dropper
	if front
		dropper = bolus.enableDropping(loc, angleZ, 30.0)
	else
		dropper = bolus.enableDropping(loc, angleZ - 180.0, 30.0)
	endIf
	
	if lateral != 0.0
		px += Math.sin(angleZ) * lateral
		py += Math.cos(angleZ) * lateral
	endIf
	
	dropper.setPosition(px, py, pz)
	dropper.setAngle(0.0, 0.0, angleZ)
	bolus.removeAllItems(dropper, true, true)
endFunction


Function ReappearPreyAt(Actor prey, ObjectReference loc, float lateral = 0.0, float vertical = 0.0)
	if DEBUGGING
		Log4(PREFIX, "ReappearPreyAt", Namer(prey), Namer(loc), lateral, vertical)
	endIf
	
	if prey == playerRef
		SendModEvent("dhlp-Resume")
	endIf

	if prey.hasSpell(NotThere_Trapped)
		prey.removeSpell(NotThere_Trapped)
	endIf

	if prey.GetParentCell() != loc.GetParentCell()
		prey.moveTo(loc)
	endIf

	if StorageUtil.HasIntValue(prey, "DevourmentReborn")
		StorageUtil.UnsetIntValue(prey, "DevourmentReborn")
	endIf
	
	if prey.hasSpell(NotThere_Friendly)
		prey.removeSpell(NotThere_Friendly)
	endIf

	Unghostify(prey)
	UnassignPreyMeters(prey)

	float px = loc.getPositionX()
	float py = loc.getPositionY()
	float pz = loc.getPositionZ() + vertical
	
	if lateral != 0.0
		float angleZ = loc.GetAngleZ()
		px += Math.sin(angleZ) * lateral
		py += Math.cos(angleZ) * lateral
	endIf

	prey.setPosition(px, py, pz)
	
	if prey == playerRef
		PlayerAlias.gotoDefault()
	else
		prey.enableNoWait(false)
		prey.stopCombat()
	endIf

	; This HAS to be done after the state change.
	reactivatePrey(prey)
	prey.PlayIdle(IdleStop)
endFunction


bool Function waitUntilPresent(ObjectReference subject, ObjectReference anchor) global
{
Utility function to wait for a SetLocation or MoveTo to complete.
It will wait up to 2 seconds for the following conditions to be true:
* the anchor is fully loaded, using ObjectReference.is3DLoaded().
* the subject and anchor are in the same cell
* the subject is fully loaded, using ObjectReference.is3DLoaded()
It returns true if subject is near the anchor and the timer didn't expire.
}
	int counter = 0

	if !anchor.is3DLoaded()
		Debug.Trace("DevourmentManager.waitUntilPresent: !anchor.is3DLoaded(). " + anchor)
		return false
	endIf
	
	Cell anchorCell = anchor.getParentCell()

	while counter < 20 && subject.getParentCell() != anchorCell
		counter += 1
		Log2("DevourmentManager", "WaitUntilPresent", "subject in " + Namer(subject.getParentCell()), "anchor in " + Namer(anchorCell))
		;Debug.Trace("DevourmentManager.WaitUntilPresent: subject.getParentCell() != anchorCell; waiting 100ms. " + anchorCell)
		utility.wait(0.1)
	endWhile

	while counter < 20 && !subject.is3DLoaded()
		counter += 1
		Debug.Trace("DevourmentManager.waitUntilPresent:  !subject.is3DLoaded(); waiting 100ms. " + subject)
		utility.wait(0.1)
	endWhile

	return counter < 20
endFunction


function hideLocally(Actor pred, Actor prey)
	if DEBUGGING
		Log2(PREFIX, "hideLocally", Namer(pred), Namer(prey))
	endIf

	;if pred.getParentCell() != prey.getParentCell()
	;	prey.moveTo(pred, -500.0, -500.0, -500.0)
	;else
	;	float PX = pred.getPositionX() - 500.0
	;	float PY = pred.getPositionY() - 500.0
	;	float PZ = pred.getPositionZ() - 500.0
	;	prey.setPosition(PX, PY, PZ)
	;endIf

	Ghostify(prey)

	if !prey.hasSpell(NotThere_Trapped)
		prey.addSpell(NotThere_Trapped, false)
	endIf
endFunction


function hideNearPred(Actor pred, Actor prey)
	if DEBUGGING
		Log2(PREFIX, "hideNearPred", Namer(pred), Namer(prey))
	endIf

	prey.moveTo(pred)
	Ghostify(prey)
	
	if prey.hasSpell(NotThere_Trapped)
		prey.removeSpell(NotThere_Trapped)
	endIf
endFunction


function hideInStomach(Actor prey)
	if DEBUGGING
		Log1(PREFIX, "hideInStomach", Namer(prey))
	endIf

	if prey.hasSpell(NotThere_Trapped)
		prey.removeSpell(NotThere_Trapped)
	endIf

	prey.moveTo(HerStomach)

	if prey.hasSpell(NotThere)
		prey.removeSpell(NotThere)
	endIf
endFunction


Function ghostify(Actor prey)
	prey.setAlpha(0.0, false)
	prey.addSpell(NotThere, false)
	prey.setGhost(true)
	prey.clearExtraArrows()
	prey.stopCombatAlarm()
	prey.stopCombat()
	prey.setAlpha(0.0, false)
endFunction


Function unGhostify(Actor prey)
	prey.removeSpell(NotThere)
	prey.setGhost(false)
	prey.setAlpha(100.0, false)
EndFunction


Function PlayBurp_async(Actor pred, bool oral = true)
{ Used to call PlayBurp asynchronously using SendModEvent. }
	int handle = ModEvent.create("Devourment_Burp")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushBool(handle, oral)
	ModEvent.Send(handle)
EndFunction


Event PlayBurp(Form f, bool oral)
{ Do a burp and a facial expression. If oral is set to false, it will be a fart instead. }
	if DEBUGGING
		Log2(PREFIX, "PlayBurp", Namer(f), oral)
	endIf

	int expression
	Sound TheSound
	
	if oral
		expression = 16
		TheSound = BurpSound
	else
		expression = 10
		theSound = ScatSounds[2]
	endIf

	Actor pred = f as Actor
	if pred == playerRef
		pred.SetExpressionOverride(expression, 100)
		theSound.play(pred)
		BurpItem(pred)
		Utility.Wait(2.0)
		pred.ClearExpressionOverride()

	elseif pred && pred.is3DLoaded()
		if pred.haskeyword(ActorTypeNPC)
			pred.SetExpressionOverride(expression, 100)
			theSound.play(pred)
			Utility.Wait(2.0)
			pred.ClearExpressionOverride()
		else
			theSound.play(pred)
		endIf
	endIf
EndEvent


Function playGurgle(Actor pred, float dt)
{ Do a stomach gurgle. }
	if Utility.randomFloat(GurglesRate) < dt
		if pred == playerRef || pred.is3DLoaded()
			Gurgle.play(pred)
		endIf
	endIf
EndFunction


bool Function BurpItem(Actor pred)
	if DEBUGGING
		Log1(PREFIX, "BurpItem", Namer(pred))
	endIf
	
	if ItemBurping == 0.0 || Utility.RandomFloat() > ItemBurping
		return false
	endIf
	
	Form[] stomach = GetStomachArray(pred)
	if EmptyStomach(stomach)
		return false
	endIf
	
	int stomachIndex = Utility.RandomInt(0, stomach.length - 1)
	ObjectReference content = stomach[stomachIndex] as ObjectReference
	int preydata = GetPreyData(content)

	if content == none || IsEndo(preydata)
		return false
	endIf
	
	Form[] items = content.GetContainerForms()
	int itemIndex = Utility.RandomInt(0, items.length - 1)
	Form item = items[itemIndex] as Form
	
	if item == none
		return false
	elseif item.GetWeight() > 5.0 || !IsStrippable(item)
		return false
	endIf

	content.RemoveItem(item, 1, true, pred)
	pred.DropObject(item, 1)
	
	if content as DevourmentBolus
		UpdateBolusData(pred, content as DevourmentBolus)
	endIf
	
	UpdateSounds_async(pred)
	return true
EndFunction


function getNextVomit(DevourmentVomitActivator vomit)
{
This is a helper function for the DevourmentVomitActivator script to let it obtain the
appropriate pred/prey pair (since we can only process one vomit at a time).
}
	if !(vomit && VomitLocks_Prey[vomit.slot] && VomitLocks_Pred[vomit.slot])
		assertNotNone(PREFIX, "getNextVomit", "vomit", vomit)
		assertNotNone(PREFIX, "getNextVomit", "VomitLocks_Prey[vomit.slot]", VomitLocks_Prey[vomit.slot])
		assertNotNone(PREFIX, "getNextVomit", "VomitLocks_Pred[vomit.slot]", VomitLocks_Pred[vomit.slot])
		return
	endIf

	ObjectReference content = VomitLocks_Prey[vomit.slot]
	Actor pred = VomitLocks_Pred[vomit.slot]
	Actor apex = FindApex(content)
	Actor prey = content as Actor
	DevourmentBolus bolus = content as DevourmentBolus

	int preyData = GetPreyData(content)

	if !(apex && pred && content && JValue.isExists(preyData))
		assertExists(PREFIX, "getNextVomit", "preyData", preyData)
		assertNotNone(PREFIX, "getNextVomit", "content", content)
		assertNotNone(PREFIX, "getNextVomit", "apex", apex)
		assertNotNone(PREFIX, "getNextVomit", "pred", pred)
		return
	endIf

	if DEBUGGING
		assertTrue(PREFIX, "getNextVomit", "has(pred, prey)", pred == GetPred(preyData))
		assertTrue(PREFIX, "getNextVomit", "has(pred, prey)", has(pred, content))
		LogJ(PREFIX, "getNextVomit", preyData, apex, pred, content)
	endIf
	
	if prey
		if IsDigested(preyData)
			vomit.vomitDead(apex, prey, GetLocus(preyData))
		else
			vomit.vomitLive(apex, prey, isEndo(preyData), GetLocus(preyData))
		endIf
		if pred == playerRef
			prey.AddSpell(StatusSpells[1], false)
		endIf
	elseif bolus
		vomit.vomitBolus(apex, bolus)
	else
		vomit.vomitItem(apex, content)
	endIf

	RemoveFromStomach(pred, content, preyData)
	apex.CreateDetectionEvent(apex, 100)
	
	if pred == playerRef
		PlayerAlias.CheckClearEliminate()
	endIf

	if content == playerRef 
		pred.AddSpell(StatusSpells[0], false)
		if FrostFallInstalled
			FrostUtil.ModPlayerWetness(100.0)
		endIf
	endIf
	
	VOMIT_UNLOCK(pred, content)
	UpdateSounds_async(apex)
endFunction


Function UpdateSounds_async(Actor pred)
{ Used to call UpdateSounds asynchronously using SendModEvent. }
	int handle = ModEvent.create("Devourment_UpdateSounds")
	ModEvent.pushForm(handle, pred)
	ModEvent.Send(handle)
EndFunction


Event UpdateSounds(Form f1)
{ Chooses appropriate sets of sound effects for the pred, and either starts or stops them as appropriate.}
	Actor pred = f1 as Actor
	
	if !pred || (pred != playerRef && !pred.Is3DLoaded())
		assertNotNone(PREFIX, "UpdateSounds_async", "pred", pred)
		assertFalse(PREFIX, "UpdateSounds_async", "pred != playerRef && !pred.is3DLoaded()", pred != playerRef && !pred.is3DLoaded())
		return
	endIf
	
	int fullness = GetFullnessDescriptor(pred)
	if DEBUGGING
		Log1(PREFIX, "UpdateSounds_async", LuaS("fullness", fullness))
	endIf

	BurdenUpdate(pred)
	
	if JMap.hasKey(fullness, "male")
		if !pred.hasSpell(SoundsOfDigestion[0])
			pred.addSpell(SoundsOfDigestion[0], false)
		endif
	else
		if pred.hasSpell(SoundsOfDigestion[0])
			pred.removeSpell(SoundsOfDigestion[0])
		endif
	endIf
	
	if JMap.hasKey(fullness, "female") 
		if !pred.hasSpell(SoundsOfDigestion[1])
			pred.addSpell(SoundsOfDigestion[1], false)
		endif
	else
		if pred.hasSpell(SoundsOfDigestion[1])
			pred.removeSpell(SoundsOfDigestion[1])
		endif
	endIf
	
	if JMap.hasKey(fullness, "other")
		if !pred.hasSpell(SoundsOfDigestion[2])
			pred.addSpell(SoundsOfDigestion[2], false)
		endif
	else
		if pred.hasSpell(SoundsOfDigestion[2])
			pred.removeSpell(SoundsOfDigestion[2])
		endif
	endIf
EndEvent


Function StopVoreSounds(Actor target)
	if DEBUGGING
		Log1(PREFIX, "StopVoreSounds", Namer(target))
	endIf
	
	int index = SoundsOfDigestion.length
	while index
		index -= 1
		if target.hasSpell(SoundsOfDigestion[index])
			target.removeSpell(SoundsOfDigestion[index])
		endif
	endWhile
EndFunction


Function PrefillCheck() 
	if PreFilledChance <= 0.0
		return
	endIf

	Actor[] candidates = MiscUtil.ScanCellNPCs(PlayerRef)
	if DEBUGGING
		Log1(PREFIX, "PrefillCheck", ActorArrayToString(candidates))
	endIF

	int i = candidates.length
	while i
		i -= 1
		Actor candidate = candidates[i]

		float chance = PreFilledChance
		if candidate.HasKeyword(DevourmentSuperPred)
			chance *= 3.0
		endIf

		if Utility.RandomFloat() < chance; && !PlayerRef.HasLOS(candidate)
			if candidate != PlayerRef && validPredator(candidate) && candidate.Is3DLoaded() && candidate.HasKeyword(ActorTypeNPC)
				RegisterFakeDigestion(candidate, -1.0)
				if DEBUGGING
					Log2(PREFIX, "PrefillCheck", Namer(candidate), "Prefilling")
				endIF
			endIf
		endIf
	endWhile
EndFunction


;==================================================================================
; Troubleshooting Functions
;==================================================================================


Function AdjustPreyData()
	Log0(PREFIX, "AdjustPreyData")
	Actor pred = JFormMap.nextKey(predators) as Actor
	while pred
		int stomach = GetStomach(pred)
		ObjectReference content = JFormMap.nextKey(stomach) as ObjectReference
		while content
			int preyData = JFormMap.getObj(stomach, content)
			float remaining = GetDigestionRemaining(preyData)

			if IsVore(preyData) && content as Actor
				JMap.SetFlt(preyData, "dps", getAcidDamage(pred, content as Actor))
				JMap.SetFlt(preyData, "struggleDamage", getStruggleDamage(pred, content as Actor))
				JMap.SetFlt(preyData, "timerMax", getHoldingTime(pred))
				SetDigestionRemaining(preyData, remaining)

			elseif IsDigesting(preyData)
				JMap.SetFlt(preyData, "timerMax", GetDigestionTime(pred, content))
				SetDigestionRemaining(preyData, remaining)
			endIf

			content = JFormMap.nextKey(stomach, content) as ObjectReference
		endWhile
		pred = JFormMap.nextKey(predators, pred) as Actor
	endWhile
EndFunction


Function ResetBellies()
{Reapplies bellies to all predators. }
	Log0(PREFIX, "ResetBellies")
	Form[] ActorArray = JArray.asFormArray(JFormMap.allKeys(predators))
	LogForms(PREFIX, "ResetBellies", "Predators to Reset", ActorArray)
	int index = 0
	while index < ActorArray.length
		ResetBelly(ActorArray[index] as Actor)
		index += 1
	endWhile
EndFunction


Function ResetBelly(Actor pred)
	{Reapplies belly of predator. }
	Log0(PREFIX, "ResetBelly")
	pred.removeItem(FullnessTypes_All, 99, true)
	pred.RemoveSpell(DevourmentSlow)
	pred.AddSpell(DevourmentSlow, false)
	UpdateSounds_async(pred)
EndFunction
	

Function ResetDevourment()
{ Attempts to "fix" devourment if something has gone wrong. It clears everything except registrations. }
	Log0(PREFIX, "ResetDevourment")
	
	self.unregisterForUpdate()
	Utility.wait(1.5)

	StorageUtil.ClearIntValuePrefix("vore")
	PlayerAlias.gotoDefault()
	DevourmentDialog.instance().Reset()
	
	Actor[] preds = GetPredatorArray()
	int index = preds.length
	while index
		index -= 1
		ResetPred(preds[index])
	endWhile
	
	blockForms = Utility.CreateFormArray(256)
	blockCodes = Utility.CreateStringArray(256)
	JFormMap.Clear(blocks)

	UnassignAllPreyMeters()

	self.registerForSingleUpdate(1.5)
endfunction


Function ResetPred(Actor pred)
	Log1(PREFIX, "ResetPred", Namer(pred))
	
	if pred != playerRef
		pred.enableAI(true)
	endIf
	
	Form[] stomach = GetStomachArray(pred)
	if !EmptyStomach(stomach)
		int index = stomach.length
		while index
			index -= 1
			ResetPrey(stomach[index] as ObjectReference)
			RemoveFromStomach(pred, stomach[index] as ObjectReference)
		endWhile
	endIf

	RemovePredator(pred)
	ResetActor(pred, playerRef)
EndFunction


Function ResetPreyMCM(string a_input)	;MCM Helper hack.
	int targetID = PO3_SKSEFunctions.StringToInt(a_input)
	ObjectReference target = Game.GetForm(targetID) as ObjectReference
	if target
		resetPrey(target)
	endIf
EndFunction


Function ResetPrey(ObjectReference prey)
	Log1(PREFIX, "ResetPrey", Namer(prey))
	ObjectReference place = FindApex(prey)
	if !place
		place = playerRef
	endIf
	
	if prey as DevourmentBolus
		ReappearBolusAt(prey as DevourmentBolus, place, true, lateral = 40.0, vertical = 40.0)
	elseif prey as Actor
		ResetActor(prey as Actor, place)
	else
		ReappearItemAt(prey, place, true, lateral = 40.0)
	endIf
EndFunction


Function ResetActor(Actor target, ObjectReference place)
	Log2(PREFIX, "ResetActor", Namer(target), Namer(place))
	ReappearPreyAt(target, place)
	UnassignPreyMeters(target)
	Unghostify(target)
	target.enable()
	target.removeItem(FullnessTypes_All, 99, true)
	target.removeSpell(DevourmentSlow)
	target.removeSpell(NotThere_Trapped)
	target.removeSpell(NotThere_Friendly)
	target.removeSpell(NotThere)
	target.removeSpell(CordycepsFrenzy)
	target.setAlpha(100.0, false)
	NiOverride.RemoveNodeTransformScale(target, false, IsFemale(target), "NPC Head [Head]", PREFIX)
	NiOverride.UpdateNodeTransform(target, false, IsFemale(target), "NPC Head [Head]")
	target.resethealthandlimbs()
	target.enableAI(true)
	StopVoreSounds(target)
EndFunction


Function WhitelistPredator()
	ObjectReference targeted = Game.GetCurrentCrossHairRef()
	If targeted as Actor
		WhitelistNameAlias.ForceRefTo(targeted)
		Int Choice = MenuWhitelist.Show()
		If Choice == 0
			PredatorWhitelist = PapyrusUtil.PushActor(PredatorWhitelist, targeted as Actor)
		EndIf
		WhitelistNameAlias.Clear()
	EndIf
EndFunction


Function HotkeyDialogue()
	PlayerAlias.HotkeyDialogue()
EndFunction


Function HotkeyVore(int i)
	PlayerAlias.HotkeyVore(i)
EndFunction


Function ForgetEquippedSpells()
	Spell s0 = playerRef.GetEquippedSpell(0)
	Spell s1 = playerRef.GetEquippedSpell(1)
	Spell s2 = playerRef.GetEquippedSpell(2)
	int count = 0
	
	if s0
		playerRef.RemoveSpell(s0)
		count += 1
	endIf
	
	if s1
		playerRef.RemoveSpell(s1)
		count += 1
	endIf
	
	if s2
		playerRef.RemoveSpell(s2)
		count += 1
	endIf
	
	ConsoleUtil.PrintMessage("Unlearned " + count + " spells/powers.")
endFunction


Function ExportDatabase(String filename)
{ Exports the JContainers devourment database to a json file. }
	Log1(PREFIX, "ExportDatabase", filename)
	JValue.writeToFile(DB, fileName)
	StorageUtil.debug_SaveFile()
	Log1(PREFIX, "ExportDatabase", LuaS("DB", DB))
endFunction


Function LooseItemVore(Actor pred, ObjectReference targetted)
	Form baseForm = targetted.GetBaseObject()

	; Eat armor, weapons, etc.
	if edibleTypes.find(baseForm.GetType()) >= 0
		PlayVoreAnimation_Item(pred, targetted, 0, false)
		DigestItem(pred, targetted, 1, none, false, 0)

	; Katamari Damancy mode
	elseif Menu.UnrestrictedItemVore
		PlayVoreAnimation_Item(pred, targetted, 0, false)
		RegisterDigestion(pred, targetted, false, 0)

	; Eat shit.
	elseif (baseForm as ActorBase && RemainsBones.Find(baseForm as ActorBase) >= 0) \
	|| (baseForm as Container && RemainsFeces.Find(baseForm as Container) >= 0)
		targetted.RemoveAllItems(pred)
		if pred != playerRef || Game.GetCameraState() > 0
			Debug.SendAnimationEvent(pred, "IdleCannibalFeedCrouching")
		endIf

		targetted.Disable(true)
		targetted.Delete()
	endIf
endFunction


Function PlayVoreAnimation_Item(Actor pred, ObjectReference content, int locus, bool grabbed)
	{ Attempts to play an appropriate vore animation.  }

	bool complexAnimation = (pred != playerRef || Game.GetCameraState() > 0)

	if pred.hasKeywordString("ActorTypeNPC")
		if complexAnimation
			if grabbed
				Debug.SendAnimationEvent(pred, "IdleSalute")
			elseif content.GetPositionZ() < pred.GetPositionZ() + 20.0
				Debug.SendAnimationEvent(pred, "IdlePickup_Ground")
			else
				Debug.SendAnimationEvent(pred, "IdleSalute")
			endIf
		endIf
	endIf
EndFunction


bool Function relativelySafe(Actor target)
{ Indicates that the target is not taking regular damage from any Devourment source. }
	return JLua.evalLuaInt("return dvt.RelativelySafe(args.t)", JLua.setForm("t", target))
endFunction


bool Function canStruggle(Actor prey, int preyData)
{ Indicates that the target is eligible for struggling. }
	if (prey == playerRef && whoStruggles >= STRUGGLE_PLAYER) || (whoStruggles >= STRUGGLE_EVERYONE) 
		return !IsConsented(preyData) && !IsSurrendered(preyData)
	else
		return false
	endIf
endFunction


bool Function IsValidDigestion(Actor pred, Actor prey)
	;int keywordIndex = LibFire.ActorFindAnyKeyword(prey, RaceDigestionKeywords)

	if prey.hasKeyword(ActorTypeUndead) ; keywordIndex == 0
		return pred.hasPerk(Menu.DigestionUndead)
	elseif prey.hasKeyword(ActorTypeDaedra) ; keywordIndex == 1
		return pred.hasPerk(Menu.DigestionDaedric)
	elseif prey.hasKeyword(ActorTypeDwarven) ; keywordIndex == 2
		return pred.hasPerk(Menu.DigestionDwemer)
	else
		return true
	endIf
EndFunction


Function CheckValidDigestion_async(Actor pred, Actor prey, int preyData)
{ Used to call CheckValidDigestion asynchronously using a ModEvent. }
	int handle = ModEvent.Create("Devourment_ValidDigestion")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.pushInt(handle, preyData)
	ModEvent.send(handle)
EndFunction


Function CheckValidDigestion(Form f1, Form f2, int preyData)
{
Determines if a prey is eligible to be digested.
* Actors with the ActorTypeUndead keyword can be digested with the DigestUndead perk.
* Actors with the ActorTypeDwarven keyword can be digested with the DigestDwemer perk.
* Actors with the ActorTypeDremora keyword can be digested with the DigestDremora perk.
}
	Actor pred = f1 as Actor
	Actor prey = f2 as Actor

	;int keywordIndex = LibFire.ActorFindAnyKeyword(prey, RaceDigestionKeywords)

	if prey.hasKeyword(ActorTypeUndead) ; keywordIndex == 0
		if !pred.hasPerk(Menu.DigestionUndead)
			HandleInvalidDigestion(MessageIndigestible[0], pred, prey)
		endIf
	elseif prey.hasKeyword(ActorTypeDaedra) ; keywordIndex == 1
		if !pred.hasPerk(Menu.DigestionDaedric)
			HandleInvalidDigestion(MessageIndigestible[1], pred, prey)
		endIf
	elseif prey.hasKeyword(ActorTypeDwarven) ; keywordIndex == 2
		if !pred.hasPerk(Menu.DigestionDwemer)
			HandleInvalidDigestion(MessageIndigestible[2], pred, prey)
		endIf
	elseif prey.getitemcount(Ipecac) > 0
		prey.removeItem(Ipecac, 1, false, none)
		HandleInvalidDigestion(MessageIndigestible[3], pred, prey)
	endIf
endFunction


Function HandleInvalidDigestion(Message msg, Actor pred, Actor prey)
	if pred == playerRef
		HelpAgnosticMessage(msg, "DVT_INDIGESTIBLE", 4.0, 0.1)
	endIf
	RegisterVomit(prey)
EndFunction


float Function GetFullnessWith(Actor pred, ObjectReference target)
	if target as Actor
		return GetFullness(pred, GetVoreWeight(target as Actor) / GetVoreWeight(pred))
	else
		return GetFullness(pred, target.GetWeight() / GetVoreWeight(pred))
	endIf
EndFunction


float Function GetFullness(Actor pred, float offset = 0.0)
	float burden = JLua.evalLuaFlt("return dvt.GetBurdenLinear(args.pred)", JLua.setForm("pred", pred))
	return (burden + offset) / GetCapacity(pred)
EndFunction


bool Function HasRoomForItem(Actor pred, ObjectReference item)
{ Determines if the pred has room for a particular prey. }
	if pred == none || item == none
		assertNotNone(PREFIX, "HasRoomForItem", "pred", pred)
		assertNotNone(PREFIX, "HasRoomForItem", "item", item)
		return false
	elseif multiPrey == MULTI_DISABLED
		return !HasAnyPrey(pred)
	elseif multiPrey == MULTI_COUNT
		return GetPreyCount(pred) as float < GetCapacity(pred)
	elseif multiPrey == MULTI_SIZE1
		return GetFullnessWith(pred, item)
	elseif multiPrey == MULTI_SIZE2
		return true
	else
		return true
	endIf
EndFunction


bool Function HasRoomForPrey(Actor pred, Actor prey)
{ Determines if the pred has room for a particular prey. }

	if pred == none || prey == none
		assertNotNone(PREFIX, "HasRoomForPrey", "pred", pred)
		assertNotNone(PREFIX, "HasRoomForPrey", "prey", prey)
		return false
	endIf
	
	if multiPrey == MULTI_DISABLED
		if DEBUGGING
			if HasAnyPrey(pred)
				ConsoleUtil.PrintMessage(Namer(pred) + " doesn't have room for " + Namer(prey))
			else
				ConsoleUtil.PrintMessage(Namer(pred) + " has room for " + Namer(prey))
			endIf
		endIf
		return !HasAnyPrey(pred)
		
	elseif multiPrey == MULTI_COUNT
		if DEBUGGING
			ConsoleUtil.PrintMessage(Namer(pred) + " has " + GetPreyCount(pred) + " / " + GetCapacity(pred) as int + " prey.")
		endIf
		return GetPreyCount(pred) < GetCapacity(pred) as int
		
	elseif multiPrey == MULTI_SIZE1
		if DEBUGGING
			int oldFullness = (100.0 * GetFullness(pred)) as int
			int newFullness = (100.0 * GetFullnessWith(pred, prey)) as int
			ConsoleUtil.PrintMessage(Namer(pred) + " is " + oldFullness + "%% full; " + Namer(prey) + " would increase that to " + newFullness + "%%.")
		endIf
		return GetFullnessWith(pred, prey) <= 1.0
		
	elseif multiPrey == MULTI_SIZE2
		if DEBUGGING
			int oldFullness = (100.0 * GetFullness(pred)) as int
			int newFullness = (100.0 * GetFullnessWith(pred, prey)) as int
			ConsoleUtil.PrintMessage(Namer(pred) + " is " + oldFullness + "%% full; " + Namer(prey) + " would increase that to " + newFullness + "%%.")
		endIf
		return true
		
	else
		if DEBUGGING
			ConsoleUtil.PrintMessage(Namer(pred) + " is never full.")
		endIf
		return true
	endIf
EndFunction


bool Function IsFull(Actor pred)
{ Determines if the pred is full. }

	if pred == none
		assertNotNone(PREFIX, "isFull", "pred", pred)
		return true
		
	elseif multiPrey == MULTI_DISABLED
		if DEBUGGING
			if HasAnyPrey(pred)
				ConsoleUtil.PrintMessage(Namer(pred) + " is full.")
			else
				ConsoleUtil.PrintMessage(Namer(pred) + " isn't full.")
			endIf
		endIf
		return !HasAnyPrey(pred)
		
	elseif multiPrey == MULTI_COUNT
		if DEBUGGING
			float percent = (100.0 * GetPreyCount(pred) / (GetCapacity(pred) as int)) as int
			ConsoleUtil.PrintMessage(Namer(pred) + " is " + percent + "%% full.")
		endIf
		return GetPreyCount(pred) >= GetCapacity(pred) as int
		
	elseif multiPrey == MULTI_SIZE1 || multiPrey == MULTI_SIZE2
		if DEBUGGING
			int fullness = (100.0 * GetFullness(pred)) as int
			ConsoleUtil.PrintMessage(Namer(pred) + " is " + fullness + "%% full (capacity=" + GetCapacity(pred) + ", burden=" + GetFullness(pred) + ").")
		endIf
		return GetFullness(pred) >= 1.0
	
	else
		if DEBUGGING
			ConsoleUtil.PrintMessage(Namer(pred) + " is never full.")
		endIf
		return false
	endIf
EndFunction


bool Function validPredator(Actor target)
	If target == None || target.isChild()
		return false
	ElseIf PredatorWhitelist.find(target) >= 0
		return true
    ElseIf target.hasKeyword(ActorTypeCreature) && creaturePreds
		Race baseRace = Remapper.RemapRace(target.GetLeveledActorBase().getRace())
		int index = CreaturePredatorRaces.Find(baseRace)
		return index >= 0 && CreaturePredatorToggles[index]
	elseIf target.HasKeyword(ActorTypeNPC) && (MalePreds || FemalePreds)
		int sex = target.getLeveledActorBase().getSex()	;We only care for Sex where humanoids are concerned.
		Race baseRace = Remapper.RemapRace(target.GetLeveledActorBase().getRace())
		int index = HumanoidPredatorRaces.Find(baseRace)
		return (sex == 0 && HumanoidMalePredatorToggles[index] && MalePreds) || (sex != 0 && HumanoidFemalePredatorToggles[index] && FemalePreds)
	else
		Return False
	endIf
EndFunction


bool Function areFriends(Actor pred, Actor prey)
	if pred == playerRef
		return prey.getRelationshipRank(pred) > 0 \
		|| prey.IsPlayerTeammate() \
		|| prey.IsPlayersLastRiddenHorse()
	elseif prey == playerRef
		return pred.getRelationshipRank(prey) > 0 \
		|| prey.IsPlayerTeammate() \
		|| pred.IsPlayersLastRiddenHorse()
	else
		return prey.getRelationshipRank(pred) > 0
	endIf
EndFunction


bool Function notInPlayerHome(Actor pred)
	return !pred.isPlayerTeammate() || !pred.IsInFaction(pred.getParentCell().getFactionOwner())
endFunction


;=================================================
; Associates prey with health bars.


Function assignPreyMeters(Actor prey, float percent, bool isAlive, bool canStruggle)
	if DEBUGGING
		assertNotNone(PREFIX, "assignPreyMeters", "prey", prey)
		Log3(PREFIX, "assignPreyMeters", Namer(prey), percent, isAlive)
	endIf
	
	if prey == playerRef
		if isAlive && canStruggle && whoStruggles >= STRUGGLE_PLAYER
			PlayerStruggleMeter.AttributeValue.setValue(0.0)
			PlayerStruggleMeter.UpdateMeter(true)
		endIf
	else
		int index = PreyMeterAssignments.find(prey)
		if index < 0
			index = PreyMeterAssignments.find(None)
		endIf
		
		if index >= 0
			PreyMeterAssignments[index] = prey
			CommonMeterInterfaceHandler health = PreyHealthMeters[index]
			health.Meter.ForcePercent(percent)
			health.AttributeValue.setValue(percent)
			
			if isAlive
				SetMeters_Alive(prey)
				if canStruggle && whoStruggles >= STRUGGLE_EVERYONE
					CommonMeterInterfaceHandler struggle = PreyStruggleMeters[index]
					struggle.AttributeValue.setValue(0.0)
					struggle.UpdateMeter(true)
				endIf
			else
				SetMeters_Dead(prey)
			endIf
		endIf
	endIf
EndFunction


Function SetMeters_Alive(Actor prey)
	if DEBUGGING
		assertNotNone(PREFIX, "SetMeters_Alive", "prey", prey)
		Log1(PREFIX, "SetMeters_Alive", Namer(prey))
	endIf
	
	if prey != playerRef
		int index = PreyMeterAssignments.find(prey)
		Log1(PREFIX, "SetMeters_Alive", index)
		
		if index >= 0
			CommonMeterInterfaceHandler health = PreyHealthMeters[index]
			health.MainPrimaryColor = HealthMeterColours[6]
			health.MainSecondaryColor = HealthMeterColours[5]
			health.AuxPrimaryColor = HealthMeterColours[4]
			health.AuxSecondaryColor = HealthMeterColours[8]
			health.UpdateMeter(true)
		endIf
	endIf
endFunction


Function SetMeters_Dead(Actor prey)
	if DEBUGGING
		assertNotNone(PREFIX, "SetMeters_Dead", "prey", prey)
		Log1(PREFIX, "SetMeters_Dead", Namer(prey))
	endIf
	
	if prey == playerRef
		PlayerStruggleMeter.RemoveMeter()
		PlayerStruggleMeter.AttributeValue.setValue(0.0)
	else
		int index = PreyMeterAssignments.find(prey)
		Log1(PREFIX, "SetMeters_Dead", index)

		if index >= 0
			CommonMeterInterfaceHandler struggle = PreyStruggleMeters[index]
			CommonMeterInterfaceHandler health = PreyHealthMeters[index]
			
			struggle.RemoveMeter()
			struggle.AttributeValue.setValue(0.0)
			
			health.MainPrimaryColor = HealthMeterColours[0]
			health.MainSecondaryColor = HealthMeterColours[2]
			health.AuxPrimaryColor = HealthMeterColours[4]
			health.AuxSecondaryColor = HealthMeterColours[8]
			health.UpdateMeter(true)
		endIf
	endIf
endFunction


Function SetMeters_Reformed(Actor prey)
	if DEBUGGING
		assertNotNone(PREFIX, "SetMeters_Reformed", "prey", prey)
		Log1(PREFIX, "SetMeters_Reformed", Namer(prey))
	endIf
	
	if prey != playerRef
		int index = PreyMeterAssignments.find(prey)
		Log1(PREFIX, "SetMeters_Reformed", index)

		if index >= 0
			CommonMeterInterfaceHandler health = PreyHealthMeters[index]
			health.MainPrimaryColor = HealthMeterColours[3]
			health.MainSecondaryColor = HealthMeterColours[3]
			health.AuxPrimaryColor = HealthMeterColours[7]
			health.AuxSecondaryColor = HealthMeterColours[7]
			health.UpdateMeter(true)
		endIf
	endIf
endFunction


Function updateHealthMeter(Actor prey, float percent)
	if prey != playerRef
		int index = PreyMeterAssignments.find(prey)

		if index >= 0
			CommonMeterInterfaceHandler healthBar = PreyHealthMeters[index]
			healthBar.AttributeValue.setValue(percent)
			healthBar.UpdateMeter(true)
		endIf
	endIf
EndFunction


Function updateStruggleMeter(Actor prey, float struggle)
	if prey == playerRef
		PlayerStruggleMeter.AttributeValue.setValue(struggle)
		PlayerStruggleMeter.UpdateMeter(true)

	else
		int index = PreyMeterAssignments.find(prey)
		Log1(PREFIX, "updateStruggleMeter", index)

		if index >= 0
			CommonMeterInterfaceHandler struggleBar = PreyStruggleMeters[index]
			struggleBar.AttributeValue.setValue(struggle)
			struggleBar.UpdateMeter(true)
		endIf
	endIf
EndFunction


Function UnassignPreyMeters(Actor prey)
	if DEBUGGING
		assertNotNone(PREFIX, "UnassignPreyMeters", "prey", prey)
		Log1(PREFIX, "UnassignPreyMeters", Namer(prey))
	endIf
	
	if prey == playerRef
		PlayerStruggleMeter.RemoveMeter()
		PlayerStruggleMeter.AttributeValue.setValue(0.0)

	else
		int index = PreyMeterAssignments.find(prey)
		Log1(PREFIX, "UnassignPreyMeters", index)

		if index >= 0
			PreyMeterAssignments[index] = None
			PreyHealthMeters[index].RemoveMeter()
			PreyHealthMeters[index].AttributeValue.setValue(100.0)
			PreyStruggleMeters[index].RemoveMeter()
			PreyStruggleMeters[index].AttributeValue.setValue(0.0)
		endIf
	endIf
EndFunction


Function UnassignAllPreyMeters()
	if DEBUGGING
		LogActors(PREFIX, "UnassignPreyMeters", "PreyMeterAssignments", PreyMeterAssignments)
	endIf
		
	PlayerStruggleMeter.RemoveMeter()
	PlayerStruggleMeter.AttributeValue.setValue(0.0)
	
	int index = PreyMeterAssignments.length
	while index
		index -= 1
		PreyMeterAssignments[index] = None
		PreyHealthMeters[index].RemoveMeter()
		PreyHealthMeters[index].AttributeValue.setValue(100.0)
		PreyStruggleMeters[index].RemoveMeter()
		PreyStruggleMeters[index].AttributeValue.setValue(0.0)
	endWhile
EndFunction


Function RestoreAllPreyMeters()
	Form[] stomach = GetStomachArray(playerRef)
	if !EmptyStomach(stomach)
		int i = stomach.length
		while i
			i -= 1
			if stomach[i] as Actor
				Actor prey = stomach[i] as Actor
				int preyData = GetPreyData(prey)
				if IsAlive(preyData) 
					assignPreyMeters(prey, 100.0 * prey.GetActorValuePercentage("Health"), true, CanStruggle(prey, preyData))
				else
					assignPreyMeters(prey, GetDigestionPercent(preyData), false, false)
				endIf
			endIf
		endWhile
	endIf
EndFunction


;=================================================
; A mutex system for the vomit queue.


bool Function VOMIT_LOCK(Actor pred, ObjectReference prey)
	if DEBUGGING
		assertNotNone(PREFIX, "VOMIT_LOCK", "pred", pred)
		assertNotNone(PREFIX, "VOMIT_LOCK", "prey", prey)
		Log2(PREFIX, "VOMIT_LOCK", Namer(pred), Namer(prey))
	endIf

	int slot = VomitLocks_Prey.find(none)

	if slot < 0
		lockTries += 1
		Log1(PREFIX, "VOMIT_LOCK", "NO SLOT AVAILABLE: TRIES=" + lockTries)
		return false
	elseif VomitLocks_Prey.find(prey) >= 0
		lockTries += 1
		Log1(PREFIX, "VOMIT_LOCK", "PREY ALREADY LOCKED: TRIES=" + lockTries)
		return false
	elseif VomitLocks_Pred.find(pred) >= 0
		lockTries += 1
		Log1(PREFIX, "VOMIT_LOCK", "PRED ALREADY LOCKED: TRIES=" + lockTries)
		return false
	elseif RegisterBlock("VOMIT_LOCK", pred)
		VomitLocks_Prey[slot] = prey
		VomitLocks_Pred[slot] = pred
		Log1(PREFIX, "VOMIT_LOCK", "LOCKED WITH SLOT " + slot)
		return true
	endIf
EndFunction


bool Function VOMIT_EXPIRED()
	return lockTries > 60
EndFunction


Spell Function VOMIT_SPELL(ObjectReference prey)
	if DEBUGGING
		assertNotNone(PREFIX, "VOMIT_SPELL", "prey", prey)
		Log1(PREFIX, "VOMIT_SPELL", Namer(prey))
	endIf

	int slot = VomitLocks_Prey.find(prey)
	if slot >= 0
		return VomitSpells[slot]
	else
		return none
	endIf
EndFunction


Function VOMIT_UNLOCK(Actor pred, ObjectReference prey)
	if DEBUGGING
		assertNotNone(PREFIX, "VOMIT_UNLOCK", "prey", prey)
		Log2(PREFIX, "VOMIT_UNLOCK", Namer(pred), Namer(prey))
	endIf

	int slot = VomitLocks_Prey.find(prey)
	if slot >= 0
		VomitLocks_Prey[slot] = none
		VomitLocks_Pred[slot] = none
		UnRegisterBlock("VOMIT_LOCK", pred)
		lockTries = 0
	endIf
EndFunction


Function VOMIT_CLEAR()
	int slot = VomitLocks_Prey.length
	while slot
		slot -= 1

		ObjectReference content = VomitLocks_Prey[slot]
		if content
			Actor pred = GetPredFor(content)
			if pred
				int preyData = GetPreyData(content)
				if JValue.isExists(preyData)
					ManualVomit(pred, content, preyData, forced=true)
				endIf
				UnRegisterBlock("VOMIT_LOCK", pred)
			endIf
			UnRegisterBlock("VOMIT_LOCK", content as Actor)
		endIf

		VomitLocks_Prey[slot] = None
		VomitLocks_Pred[slot] = None
	endWhile
EndFunction


;=================================================
; Blocking system.
int blockMutex = 0


Bool function IsBlocked(Actor person)
	{ BLOCKING SYSTEM: Determines if an Actor is blocked. }
	return BlockForms.find(person) >= 0
endFunction


Bool function AreBlocked(Actor person1, Actor person2)
	{ BLOCKING SYSTEM: Determines if either of two Actors is blocked. }
	return BlockForms.find(person1) >= 0 || BlockForms.find(person2) >= 0
endFunction


String function GetBlock(Actor person)
	{ BLOCKING SYSTEM: Returns the code of the function holding the block on an actor. }
	int index = BlockForms.find(person)
	if index >= 0
		return BlockCodes[index]
	else
		return ""
	endIf
EndFunction


bool function RegisterBlock(String code, Actor person)
	{ BLOCKING SYSTEM: Adds an Actor to the blocked list. }

	if isBlocked(person)
		assertFail(PREFIX, "RegisterBlock", "Already blocked: " + GetBlock(person) + " is blocking " + code)
		return false
	else
		int index = BlockForms.find(none)
		BlockForms[index] = person
		BlockCodes[index] = code

		JFormMap.SetStr(blocks, person, code)

		if DEBUGGING
			Log3(PREFIX, "RegisterBlock", "Blocked", code, Namer(person))
		endIf
		return true
	endIf
endFunction


bool function RegisterBlocks(String code, Actor person1, Actor person2)
	{ BLOCKING SYSTEM: adds a pair of Actors to the blocked list. }

	if areBlocked(person1, person2)
		assertFail(PREFIX, "RegisterBlocks", "Already blocked: " + GetBlock(person1) + "/" + GetBlock(person2) + " are blocking " + code)
		return false
	else
		int index1 = BlockForms.find(none)
		BlockForms[index1] = person1
		BlockCodes[index1] = code
		
		int index2 = BlockForms.find(none)
		BlockForms[index2] = person2
		BlockCodes[index2] = code

		JFormMap.SetStr(blocks, person1, code)
		JFormMap.SetStr(blocks, person2, code)

		if DEBUGGING
			Log4(PREFIX, "RegisterBlock", "Blocked", code, Namer(person1), Namer(person2))
		endIf
		return true
	endIf
endFunction


function UnregisterBlock(String code, Actor person)
	{ BLOCKING SYSTEM: Removes an Actor from the blocked list. }
	int index = BlockForms.find(person)
	if index >= 0
		String prior = BlockCodes[index]
		BlockForms[index] = none
		BlockCodes[index] = ""

		JFormMap.RemoveKey(blocks, person)

		if DEBUGGING
			assertStringsEqual(PREFIX, "UnregisterBlock", code, prior)
			Log3(PREFIX, "UnregisterBlock", "Unblocked", code, Namer(person))
		endIf
	else
		assertFail(PREFIX, "UnregisterBlock", Namer(person) + " wasn't blocked; " + code)
	endIf
endFunction


function UnregisterBlocks(String code, Actor person1, Actor person2)
{ BLOCKING SYSTEM: Removes a pair of Actors from the blocked list. }
	int index1 = BlockForms.find(person1)
	int index2 = BlockForms.find(person2)

	if index1 >= 0
		String prior = BlockCodes[index1]
		BlockForms[index1] = none
		BlockCodes[index1] = ""

		JFormMap.RemoveKey(blocks, person1)
		JFormMap.RemoveKey(blocks, person2)

		if DEBUGGING
			assertStringsEqual(PREFIX, "UnregisterBlocks", code, prior)
			Log3(PREFIX, "UnregisterBlocks", "Unblocked", code, Namer(person1))
		endIf
	else
		assertFail(PREFIX, "UnregisterBlocks", Namer(person1) + " wasn't blocked; " + code)
	endIf

	if index2 >= 0
		String prior = BlockCodes[index2]
		BlockForms[index2] = none
		BlockCodes[index2] = ""

		if DEBUGGING
			assertStringsEqual(PREFIX, "UnregisterBlocks", code, prior)
			Log3(PREFIX, "UnregisterBlocks", "Unblocked", code, Namer(person2))
		endIf
	else
		assertFail(PREFIX, "UnregisterBlocks", Namer(person2) + " wasn't blocked; " + code)
	endIf
endFunction


Function ClearBlock(Actor person)
{ BLOCKING SYSTEM: if the actor is blocked, they are unblocked and an error message is displayed. }
	if IsBlocked(person)
		String code = GetBlock(person)
		UnregisterBlock(code, person)
		Debug.MessageBox("Error: " + Namer(person) + " was still blocked by '" + code + "'.\nThis shouldn't happen and I'm sad that it did.")
	endIf
endFunction


;=================================================
; For displaying messages.


Function notify(String msg)
	if Notifications
		ConsoleUtil.PrintMessage(msg)
		Debug.Notification(msg)
	endIf
EndFunction


Function Notification2(Message msg, Actor pred, Actor prey)
	if Notifications
		PredNameAlias.ForceRefTo(pred)
		PreyNameAlias.ForceRefTo(prey)
		msg.Show()
		PredNameAlias.Clear()
		PreyNameAlias.Clear()
	endIf
EndFunction


Function HelpAgnosticMessage(Message msg, String code, float duration, float resetTime)
	if useHelpMessages
		Message.resetHelpMessage(code)
		msg.showAsHelpMessage(code, duration, resetTime, 1)
		Message.resetHelpMessage(code)
	else
		msg.show()
	endIf
EndFunction


;==================================================================================================
; JContainers interface.
;==================================================================================================


;==================================================================================================
; Predator functions.
;==================================================================================================


bool Function isPred(Actor target)
	return JFormMap.hasKey(predators, target)
EndFunction


bool Function VerifyPred(Actor pred)
{ Finds the predData for a given Actor. If it does not exist, it will be created. }
	int predData = JFormMap.getObj(predators, pred)

	if !JValue.isExists(predData)
		predData = JMap.object()
		JFormMap.setObj(predators, pred, predData)
		JMap.setObj(predData, "stomach", JFormMap.object())

		if pred.hasKeyword(ActorTypeNPC)
			JMap.setStr(predData, "npc", "npc")
		elseif pred.hasKeyword(ActorTypeCreature)
			JMap.setStr(predData, "creature", "creature")
		endIf
		
		int sex = pred.getLeveledActorBase().getSex()
		JMap.setInt(predData, "sex", sex)
		StorageUtil.SetIntValue(pred, "sex", sex)
	endIf

	; Give the pred the slowdown effect if they don't yet have it.
	if !pred.hasSpell(DevourmentSlow)
		pred.addSpell(DevourmentSlow, false)
	endIf

	if pred == PlayerRef
		PlayerFullnessMeter.ForceMeterDisplay(false)
	endIf

	if DEBUGGING
		Log1(PREFIX, "VerifyPred", LuaS("predData", predData))
		return assertExists(PREFIX, "VerifyPred", "predData", predData)
	else
		return true
	endIf
EndFunction


Function RemovePredator(Actor pred)
	if DEBUGGING
		Log1(PREFIX, "RemovePredator", Namer(pred))
	endIf
	JFormMap.removeKey(predators, pred)
	pred.RemoveSpell(DevourmentSlow)
	pred.RemoveItem(FullnessTypes_All, 99, true)
	StopVoreSounds(pred)

	if pred == PlayerRef
		PlayerFullnessMeter.RemoveMeter()
	endIf
EndFunction


int Function GetStomach(Actor pred)
	return JLua.evalLuaObj("return dvt.GetStomach(args.pred)", JLua.setForm("pred", pred))
EndFunction


Function AddToStomach(Actor pred, ObjectReference content, int preyData)
{ Adds an objectreference to the pred's stomach. }
if DEBUGGING
		assertNotNone(PREFIX, "AddToStomach", "pred", pred)
		assertNotNone(PREFIX, "AddToStomach", "content", content)
		assertExists(PREFIX, "AddToStomach", "preyData", preyData)
		LogJ(PREFIX, "AddToStomach", preyData, pred, content)
	endIf
	
	JLua.evalLuaInt("dvt.AddToStomach(args)", preyData, 0, false)
EndFunction


Function RemoveFromStomach(Actor pred, ObjectReference content, int preyData = 0)
{ Removes an objectreference from the pred's stomach. If preyData data is not specified, it will be determined automatically. }
	if DEBUGGING
		assertNotNone(PREFIX, "RemoveFromStomach", "pred", pred)
		assertNotNone(PREFIX, "RemoveFromStomach", "content", content)
		LogJ(PREFIX, "RemoveFromStomach", preyData, pred, content)
	endIf
	
	if preyData == 0
		preyData = GetPreyData(content)
	endIf

	assertExists(PREFIX, "RemoveFromStomach", "preyData", preyData)
	JLua.evalLuaInt("dvt.RemoveFromStomach(args)", preyData, 0, false)

	if content as Actor
		Actor prey = content as Actor
		UnassignPreyMeters(prey)

		if prey.HasPerk(Menu.Cordyceps) && pred.HasSpell(CordycepsFrenzy)
			pred.RemoveSpell(CordycepsFrenzy)
		endIf
	endIf
EndFunction


Function TransferStomach(Actor oldPred, Actor newPred) 
	if DEBUGGING
		assertNotNone(PREFIX, "TransferStomach", "oldPred", oldPred)
		assertNotNone(PREFIX, "TransferStomach", "newPred", newPred)
		Log2(PREFIX, "TransferStomach", Namer(oldPred), Namer(newPred))
	endIf
	
	int transport = JLua.setForm("oldPred", oldPred, JLua.setForm("newPred", newPred))
	int playerTransferred = JLua.evalLuaInt("return dvt.TransferStomach(args.oldPred, args.newPred)", transport)
	
	if oldPred == playerRef
		UnassignAllPreyMeters()
	elseif newPred == playerRef
		RestoreAllPreyMeters()
	endIf

	if playerTransferred 
		int preyData = GetPreyData(PlayerRef)

		if AreFriends(PlayerRef, newPred)
			if IsVore(preyData)
				SetEndo(preyData, false)
				PlayerAlias.GotoEndo(preyData)
			endIf
		else
			if IsEndo(preyData)
				SetVore(preyData)
				PlayerAlias.GotoVore(preyData)
			endIf
		endIf
	endIf

	if newPred == playerRef
		UnassignAllPreyMeters()
		RestoreAllPreyMeters()
	endIf
EndFunction


Function ReplacePrey(Actor pred, Actor oldPrey, Actor newPrey)
	if DEBUGGING
		assertNotNone(PREFIX, "ReplacePrey", "pred", pred)
		assertNotNone(PREFIX, "ReplacePrey", "oldPrey", oldPrey)
		assertNotNone(PREFIX, "ReplacePrey", "newPrey", newPrey)
		Log3(PREFIX, "ReplacePrey", Namer(pred), Namer(oldPrey), Namer(newPrey))
	endIf
	
	JLua.evalLuaInt("return dvt.ReplacePrey(args.pred, args.oldPrey, args.newPrey)", JLua.setForm("pred", pred, JLua.setForm("oldPrey", oldPrey, JLua.setForm("newPrey", newPrey))))

	if pred == playerRef
		UnassignPreyMeters(oldPrey)
		RestoreAllPreyMeters()
	endIf
EndFunction


Actor Function FindATalker()
	Form[] stomach = GetStomachArray(playerRef)
	if EmptyStomach(stomach)
		return none
	endIf

	Actor[] talkers = CreateActorArray(stomach.length)
	
	UIListMenu talkerList = UIExtensions.GetMenu("UIListMenu") as UIListMenu
	talkerList.ResetMenu()
	
	int listIndex = 0
	int stomachIndex = stomach.length
	
	while stomachIndex
		stomachIndex -= 1
		Actor prey = stomach[stomachIndex] as Actor
		if IsATalker(prey)
			talkerList.AddEntryItem(Namer(prey))
			talkers[listIndex] = prey
			listIndex += 1
		endIf
	endWhile
	
	if listIndex == 0
		return None
	elseif listIndex == 1
		return talkers[0]
	endIf
	
	talkerList.OpenMenu()
	int resultIndex = talkerList.GetResultInt()
	if resultIndex < 0
		return None
	else
		return talkers[resultIndex]
	endIf
		
	;return JLua.evalLuaForm("return dvt.FindATalker()", 0) as Actor
EndFunction


bool Function IsATalker(Actor target)
	if !AssertNotNone(PREFIX, "IsATalker", "target", target)
		return false

	elseif !(target.HasKeyword(ActorTypeNPC) || target.HasKeyword(VoreTalker))
		if DEBUGGING
			Log2(PREFIX, "IsATalker", Namer(target), "No relevant keywords.")
		endIf
		return false

	elseif Has(playerRef, target)
		int preyData = GetPreyData(target)
		if DEBUGGING
			LogJ(PREFIX, "IsATalker", preyData)
		endIf
		return IsAlive(preyData) && !IsPrey(playerRef)

	elseif Has(target, playerRef)
		int preyData = GetPreyData(playerRef)
		if DEBUGGING
			LogJ(PREFIX, "IsATalker", preyData)
		endIf
		return IsAlive(preyData) && !IsPrey(target)

	else
		AssertFail(PREFIX, "IsATalker", Namer(target) + " is neither pred nor prey of the player. This should NEVER happen.")
		return false
	endIf
EndFunction


Function BurdenUpdate(Actor subject)
	float burden = JLua.evalLuaFlt("return dvt.GetBurdenLinear(args.pred)", JLua.setForm("pred", subject))
	float capacity = GetCapacity(playerRef)

	; Controls the slowdown effect and stomach scaling.
	subject.setActorValue("variable10", 2.0 * burden / capacity)

	; For the player, adjust the fullness bar.
	if subject == playerRef
		if multiPrey == 1
			PlayerFullnessMeter.AttributeMax.SetValue(capacity)
			PlayerFullnessMeter.AttributeValue.SetValue(GetPreyCount(playerRef))
			PlayerFullnessMeter.UpdateMeter(true)
		elseif multiPrey == 2
			PlayerFullnessMeter.AttributeMax.SetValue(capacity)
			PlayerFullnessMeter.AttributeValue.SetValue(burden)
			PlayerFullnessMeter.UpdateMeter(true)
		elseif multiPrey == 3
			PlayerFullnessMeter.AttributeMax.SetValue(capacity)
			PlayerFullnessMeter.AttributeValue.SetValue(GetFullness(subject))
			PlayerFullnessMeter.Meter_Inversion_Value = 1.0
			PlayerFullnessMeter.UpdateMeter(true)
		endIf
	endIf
EndFunction


float Function GetBurden(Actor pred)
	float burden = JLua.evalLuaFlt("return dvt.GetBurden(args.pred)", JLua.setForm("pred", pred))
	if DEBUGGING
		Log2(PREFIX, "GetBurden", Namer(pred), burden)
	endIf
	return burden
EndFunction


bool Function has(Form pred, Form prey)
{ Checks if prey as in the stomach of pred. }
	if DEBUGGING
		assertNotNone(PREFIX, "has", "pred", pred)
		assertNotNone(PREFIX, "has", "prey", prey)
	endIf
	return JLua.evalLuaInt("return dvt.has(args.pred, args.prey)", JLua.setForm("pred", pred, JLua.setForm("prey", prey)))
EndFunction


bool Function hasLivePrey(Actor pred)
{ Returns true if the predator has any live Actors in their stomach. }
	if DEBUGGING
		assertNotNone(PREFIX, "hasLivePrey", "pred", pred)
	endIf
	return 0 < JLua.evalLuaInt("return dvt.countLivePrey(args.pred)", JLua.setForm("pred", pred))
EndFunction


bool Function hasAnyPrey(Actor pred)
{ Returns true if the predator has any Actors in their stomach. }
	if DEBUGGING
		assertNotNone(PREFIX, "hasAnyPrey", "pred", pred)
	endIf
	return 0 < JLua.evalLuaInt("return dvt.countPrey(args.pred)", JLua.setForm("pred", pred))
EndFunction


bool Function hasUndigested(Actor pred)
{ Returns true if the predator has anything alive or digesting in their stomach. }
	if DEBUGGING
		assertNotNone(PREFIX, "hasUndigested", "pred", pred)
	endIf
	return 0 < JLua.evalLuaInt("return dvt.countUndigested(args.pred)", JLua.setForm("pred", pred))
EndFunction


bool Function hasDigested(Actor pred)
{ Returns true if the predator has digested in their stomach. }
	if DEBUGGING
		assertNotNone(PREFIX, "hasDigested", "pred", pred)
	endIf
	return 0 < JLua.evalLuaInt("return dvt.countDigested(args.pred)", JLua.setForm("pred", pred))
EndFunction


bool Function hasExcretable(Actor pred)
{ Returns true if the predator has excretable prey in their stomach. }
	if DEBUGGING
		assertNotNone(PREFIX, "hasExcretable", "pred", pred)
	endIf
	return 0 < JLua.evalLuaInt("return dvt.countExcretable(args.pred)", JLua.setForm("pred", pred))
EndFunction


int Function getPreyCount(Actor pred)
{ Returns the number of Actors in the predator's stomach. }
	if DEBUGGING
		assertNotNone(PREFIX, "getPreyCount", "pred", pred)
	endIf
	return JLua.evalLuaInt("return dvt.countPrey(args.pred)", JLua.setForm("pred", pred))
EndFunction


int Function getStomachCount(Actor pred)
{ Returns the number of things in the predator's stomach. }
	if DEBUGGING
		assertNotNone(PREFIX, "getStomachCount", "pred", pred)
	endIf
	return JLua.evalLuaInt("return dvt.countAll(args.pred)", JLua.setForm("pred", pred))
EndFunction


int Function GetFullnessDescriptor(Actor pred)
{ Returns a table describing what kind of prey the pred has.. }
	if DEBUGGING
		assertNotNone(PREFIX, "GetFullness", "pred", pred)
	endIf	
	return JLua.evalLuaObj("return dvt.GetFullness(args.pred)", JLua.setForm("pred", pred))
endFunction


Function RegisterVomit(ObjectReference content)
	if DEBUGGING
		assertNotNone(PREFIX, "RegisterVomit", "content", content)
		Log1(PREFIX, "RegisterVomit", Namer(content))
	endIf
	
	int preyData = GetPreyData(content)
	if JValue.isExists(preyData)
		JLua.evalLuaInt("return dvt.registerVomit(args)", preyData, 0, false)
		ProduceVomit_async(GetPred(preyData), content, preyData)
	endIf
EndFunction


Function RegisterVomitAll(Actor pred, bool forced = false)
	if DEBUGGING
		assertNotNone(PREFIX, "RegisterVomitAll", "pred", pred)
		Log1(PREFIX, "RegisterVomitAll", Namer(pred))
	endIf	

	if forced 
		JLua.evalLuaInt("return dvt.registerVomitAll(args.pred, true)", JLua.setForm("pred", pred))
	else
		JLua.evalLuaInt("return dvt.registerVomitAll(args.pred)", JLua.setForm("pred", pred))
	endIf
EndFunction


float Function GetPerkMultiplier(Actor subject, Perk[] perks, float base, float mult)
	;int perkIndex = LibFire.ActorFindAnyPerk(subject, perks)
	int perkIndex = -1
	int perksLength = perks.Length
	int iIndex = 0
    while iIndex < perksLength && perkIndex == -1
		if subject.HasPerk(perks[iIndex])
			perkIndex = iIndex
		endIf
		iIndex += 1
	endWhile
	int perkLevel = 1 + perkIndex
	float result = base + mult * (perkLevel as float)

	if DEBUGGING
		if perkIndex >= 0 && perkIndex <= perks.length
			Log6(PREFIX, "GetPerkMultiplier", Namer(subject), perkIndex, perkLevel, result, perks[perkIndex], PerkArrayToString(perks))
		else
			Log6(PREFIX, "GetPerkMultiplier", Namer(subject), perkIndex, perkLevel, result, none, PerkArrayToString(perks))
		endIf
	endIf

	return result
EndFunction


Bool Function ApplyFakePotion(Potion realPotion, Actor target, float scaling)
	if DEBUGGING
		Log3(PREFIX, "ApplyFakePotion", Namer(realPotion), Namer(target), scaling)
	endIf

	int numEffects = FakePotion.GetNumEffects()
	while numEffects
		numEffects -= 1
		PO3_SKSEFunctions.RemoveEffectItemFromSpell(FakePotion, FakePotion, numEffects)
	endWhile

	numEffects = realPotion.GetNumEffects()
	while numEffects
		numEffects -= 1

		MagicEffect effect = realPotion.GetNthEffectMagicEffect(numEffects)
		float mag = scaling * realPotion.GetNthEffectMagnitude(numEffects)
		int area = (scaling * realPotion.GetNthEffectArea(numEffects)) as int
		int dur = (scaling * realPotion.GetNthEffectDuration(numEffects)) as int
		String[] conditions = PO3_SKSEFunctions.GetConditionList(realPotion, numEffects)
		PO3_SKSEFunctions.AddMagicEffectToSpell(FakePotion, effect, mag, area, dur, 0.0, conditions)
	endWhile

	FakePotion.Cast(target, target)

	return true
EndFunction


;==================================================================================================
; Prey functions.
;==================================================================================================


int Function GetPreyData(ObjectReference prey)
{ Finds the preyData for a pred/prey pair. }
	if DEBUGGING
		assertNotNone(PREFIX, "GetPreyData", "prey", prey)
	endIf
	return JLua.evalLuaObj("return dvt.GetPreyData(args.prey)", JLua.setForm("prey", prey))
EndFunction


bool Function IsPrey(ObjectReference target)
	return JValue.isExists(GetPreyData(target))
EndFunction


ObjectReference Function GetContent(int preyData)
{ Finds the bolus or prey for a preyData. }
	return JLua.evalLuaForm("return args.bolus or args.prey", preyData, none, false) as ObjectReference
EndFunction


Actor Function GetPredFor(ObjectReference prey)
{ Finds the predator for a prey. }
	return GetPred(GetPreyData(prey))
EndFunction


Actor Function GetPred(int preyData)
{ Finds the predator for a preyData. }
	return JMap.getForm(preyData, "pred") as Actor
EndFunction


Actor Function FindApex(ObjectReference prey)
{
Finds the apex predator for a foodchain containing the specified prey.
If the specified prey has no preds and they are an Actor, the prey will be returned.
}
	return JLua.evalLuaForm("return dvt.getApex(args.prey)", JLua.setForm("prey", prey), prey) as Actor
EndFunction


float Function GetStruggle(int preyData)
{ Returns prey's struggle level. }
	return JMap.getFlt(preyData, "struggle")
EndFunction


float Function AdjustStruggle(int preyData, float delta)
{ Adjusts the prey's struggle level. }
	float struggle = delta + JMap.getFlt(preyData, "struggle")
	JMap.setFlt(preyData, "struggle", struggle)
	return struggle
EndFunction


Function OverrideTimer(int preyData, float timer, float timerMax)
{ Completely overrides the current timer. This is useful for adding a timer to endo. }
	JMap.setFlt(preyData, "timer", timer)
	JMap.setFlt(preyData, "timerMax", timerMax)
EndFunction


float Function GetTimer(int preyData)
{ Returns prey's timer. }
	return JMap.getFlt(preyData, "timer")
EndFunction


float Function AdjustTimer(int preyData, float delta)
{ Adjusts the prey's timer. }
	float timer = delta + JMap.getFlt(preyData, "timer")
	JMap.setFlt(preyData, "timer", timer)
	return timer
EndFunction


float Function GetDPS(int preyData)
{ Returns prey's acid damage per second. }
	return JMap.getFlt(preyData, "dps")
EndFunction


float Function GetDigestionProgress(int preyData)
{ Returns the percentage progress of digestion. Equivalent to 100 - GetDigestionPercent(prey).}
	return 100.0 - GetDigestionPercent(preyData)
EndFunction


float Function GetDigestionPercent(int preyData)
{ Returns the percentage remaining of the prey until digestion is complete. }
	return 100.0 * GetDigestionRemaining(preyData)
EndFunction


float Function GetDigestionRemaining(int preyData)
{ Returns the fraction remaining of the prey until digestion is complete. }
	return JLua.evalLuaFlt("return dvt.GetRemainingTime(args)", preyData, 0.0, false)
EndFunction


float Function SetDigestionRemaining(int preyData, float percent)
{ Returns the fraction remaining of the prey until digestion is complete. }
	return JLua.evalLuaFlt("return dvt.SetRemainingTime(args, " + percent + ")", preyData, 0.0, false)
EndFunction


Function SetVore(int preyData)
	JLua.evalLuaInt("dvt.SetVore(args)", preyData, 0, false)
EndFunction


Function SetEndo(int preyData, bool timeout)
	JLua.evalLuaInt("dvt.SetEndo(args)", preyData, 0, false)
	if timeout
		JMap.setFlt(preyData, "timer", 60.0)
		JMap.setFlt(preyData, "timerMax", 60.0)
	endIf
	if EndoStruggling
		JMap.setInt(preyData, "ForceStruggling", 1)
	endIf
EndFunction


Function SetReforming(int preyData)
	JLua.evalLuaInt("dvt.SetReforming(args)", preyData)
EndFunction


Function SetDigesting(int preyData, float timerMax)
	JLua.evalLuaInt("dvt.SetDigesting(args)", preyData, 0, false)
	JMap.setFlt(preyData, "timer", timerMax)
	JMap.setFlt(preyData, "timerMax", timerMax)
EndFunction


Function SetDigested(int preyData)
	JLua.evalLuaInt("dvt.SetDigested(args)", preyData, 0, false)
EndFunction


bool Function isEndo(int preyData)
	return JMap.hasKey(preyData, "endo")
EndFunction


bool Function isVore(int preyData)
	return JMap.hasKey(preyData, "vore")
EndFunction


bool Function isAlive(int preyData)
	return JMap.hasKey(preyData, "alive")
EndFunction


bool Function isUndigested(int preyData)
	return JLua.evalLuaInt("return dvt.isPrey(args) and (args.alive or args.bolus)", preyData, 0, false)
EndFunction


bool Function IsReforming(int preyData)
	return JMap.HasKey(preyData, "reforming")
EndFunction


bool Function isDigesting(int preyData)
	return JMap.hasKey(preyData, "digesting")
EndFunction


bool Function isDigested(int preyData)
	return JMap.hasKey(preyData, "digested")
EndFunction


int Function GetLocus(int preyData)
	return JMap.getInt(preyData, "locus")
EndFunction


int Function GetLocusFor(ObjectReference content)
	return GetLocus(GetPreyData(content))
EndFunction


bool Function isVomit(int preyData)
	return JMap.hasKey(preyData, "vomit")
EndFunction


bool Function isCorpse(int preyData)
	return JMap.HasKey(preyData, "corpse")
EndFunction


bool Function isNoEscape(int preyData)
	return JMap.hasKey(preyData, "noEscape")
EndFunction


Function setNoEscape(int preyData, bool toggle = true)
	if toggle
		JMap.SetInt(preyData, "noEscape", 1)

		if GetContent(preyData) == playerRef
			PlayerAlias.StopPlayerStruggle()
		endIf

	else
		JMap.RemoveKey(preyData, "noEscape")

		if GetContent(preyData) == playerRef
			PlayerAlias.StartPlayerStruggle()
		endIf
	endIf
EndFunction


bool Function isSurrendered(int preyData)
	return JMap.hasKey(preyData, "surrendered")
EndFunction


Function setSurrendered(int preyData, bool toggle = true)
	if toggle
		JMap.SetInt(preyData, "surrendered", 1)

		if GetContent(preyData) == playerRef
			PlayerAlias.StopPlayerStruggle()
		endIf
	else
		JMap.RemoveKey(preyData, "surrendered")

		if GetContent(preyData) == playerRef
			PlayerAlias.StartPlayerStruggle()
		endIf
	endIf
EndFunction


bool Function isConsented(int preyData)
	return JMap.hasKey(preyData, "consented")
EndFunction


Function setConsented(int preyData, bool toggle = true)
	if toggle
		JMap.SetInt(preyData, "consented", 1)

		if GetContent(preyData) == playerRef
			PlayerAlias.StopPlayerStruggle()
		endIf
	else
		JMap.RemoveKey(preyData, "consented")

		if GetContent(preyData) == playerRef
			PlayerAlias.StartPlayerStruggle()
		endIf
	endIf
EndFunction


bool Function canEscapeVore(int preyData)
	return JLua.evalLuaInt("return dvt.CanEscape(args)", preyData, 0, false) as bool
EndFunction


bool Function canEscapeEndo(int preyData)
	return JLua.evalLuaInt("return dvt.CanEscape(args)", preyData, 0, false) as bool
EndFunction


bool Function IsFemale(Actor target)
	int sex = StorageUtil.GetIntValue(target, "sex", -1)
	if sex < 0
		return target.getLeveledActorBase().getSex() != 0
	else
		return sex != 0
	endIf
EndFunction


bool Function IsMale(Actor target)
	int sex = StorageUtil.GetIntValue(target, "sex", -1)
	if sex < 0
		return target.getLeveledActorBase().getSex() == 0
	else
		return sex == 0
	endIf
EndFunction


int Function CreatePreyData(Actor pred, Actor prey, bool endo, bool dead, int locus)
	if DEBUGGING
		assertNotNone(PREFIX, "CreatePreyData", "pred", pred)
		assertNotNone(PREFIX, "CreatePreyData", "prey", prey)
	endIf

	; Blocking functions -- do this first so that preyData doesn't timeout if the function decides to be interactive.
	float preyWeight = GetVoreWeight(prey)
	float predWeight = GetVoreWeight(pred)
	
	int preyData = JMap.object()
	JMap.setForm(preyData, "pred", pred)
	JMap.setForm(preyData, "prey", prey)
	JMap.setInt(preyData, "locus", locus)
	JMap.setFlt(preyData, "weight", preyWeight / predWeight)

	int sex = prey.getLeveledActorBase().getSex()
	JMap.setInt(preyData, "sex", sex)
	StorageUtil.SetIntValue(prey, "sex", sex)

	JMap.SetFlt(preyData, "dps", getAcidDamage(pred, prey))
	JMap.SetFlt(preyData, "struggleDamage", getStruggleDamage(pred, prey))
	JMap.SetObj(preyData, "flux", JMap.object())

	if prey.hasKeyword(ActorTypeNPC)
		JLua.evalLuaInt("dvt.SetNPC(args)", preyData, 0, false)
	endIf
	
	if AreFriends(playerRef, prey)
		JMap.SetInt(preyData, "isfollower", 1)
		if !pred.HasSpell(StatusSpells[2])
			pred.AddSpell(StatusSpells[2], false)
		endIf
	endIf

	if dead
		SetDigesting(preyData, GetDigestionTime(pred, prey))
		JLua.evalLuaInt("dvt.SetCorpse(args)", preyData, 0, false)
	else
		if prey.hasMagicEffectWithKeyword(KeywordSurrender)
			SetSurrendered(preyData)
		endIf

		if StorageUtil.PluckIntValue(prey, "voreConsent")
			SetConsented(preyData)
		endIf
		
		if StorageUtil.PluckIntValue(prey, "voreNoEscape")
			SetNoEscape(preyData)
		endIf
		
		JMap.SetFlt(preyData, "timerMax", getHoldingTime(pred))
		
		if endo
			SetEndo(preyData, prey != playerRef && pred != playerRef)
		else
			SetVore(preyData)
		endIf
	endIf

	if DEBUGGING
		assertExists(PREFIX, "CreatePreyData", "preyData", preyData)
	endIf	
	return preyData
EndFunction


int Function CreateItemData(Actor pred, ObjectReference item, int locus)
	if DEBUGGING
		assertNotNone(PREFIX, "CreateItemData", "pred", pred)
		assertNotNone(PREFIX, "CreateItemData", "item", item)
	endIf

	; Blocking function -- do this first so that itemData doesn't timeout if the function decides to be interactive.
	float predWeight = GetVoreWeight(pred)
	float itemWeight = item.GetMass() + item.GetWeight() + item.GetHeight() * item.GetWidth() * item.GetLength() / 2000.0
	if item.GetWeight() == 0.0
		item.SetWeight(itemWeight)
	endIf

	int itemData = JMap.object()
	JMap.setForm(itemData, "pred", pred)
	JMap.setForm(itemData, "bolus", item)
	JMap.setInt(itemData, "locus", locus)
	JMap.setFlt(itemData, "weight", itemWeight / predWeight)
	
	if locus == 1
		SetDigested(itemData)
	else
		SetDigesting(itemData, GetDigestionTime(pred, item))
	endIf

	if DEBUGGING
		assertExists(PREFIX, "CreateItemData", "itemData", itemData)
	endIf
	return itemData
EndFunction


int Function CreateBolusData(Actor pred, DevourmentBolus bolus, int locus)
	if DEBUGGING
		assertNotNone(PREFIX, "CreateBolusData", "pred", pred)
		assertNotNone(PREFIX, "CreateBolusData", "bolus", bolus)
	endIf

	; Blocking functions -- do this first so that bolusData doesn't timeout if the function decides to be interactive.
	float predWeight = GetVoreWeight(pred)
	float bolusWeight = bolus.getWeight()

	int bolusData = JMap.object()
	JMap.setForm(bolusData, "pred", pred)
	JMap.setForm(bolusData, "bolus", bolus)
	JMap.setInt(bolusData, "locus", locus)
	JMap.setFlt(bolusData, "weight", bolusWeight / predWeight)

	if bolus.owner != none
		JMap.setForm(bolusData, "owner", bolus.owner)
	endIf

	if locus == 1
		SetDigested(bolusData)
	else
		SetDigesting(bolusData, GetDigestionTime(pred, bolus))
	endIf

	if DEBUGGING
		assertExists(PREFIX, "CreateBolusData", "bolusData", bolusData)
	endIf
	return bolusData
EndFunction


Function UpdateBolusData(Actor pred, DevourmentBolus bolus)
	if DEBUGGING
		assertNotNone(PREFIX, "UpdateBolusData", "pred", pred)
		assertNotNone(PREFIX, "UpdateBolusData", "bolus", bolus)
	endIf

	int bolusData = GetPreyData(bolus)
	if !AssertExists(PREFIX, "UpdateBolusData", "bolusData", bolusData)
		return
	endIf
	
	float predWeight = GetVoreWeight(pred)
	float bolusWeight = bolus.getWeight()
	JMap.setFlt(bolusData, "weight", bolusWeight / predWeight)
endFunction



;==================================================================================================
; Big slow methods, only for the MCM.
;==================================================================================================


Actor[] Function getPredatorArray()
	Form[] arr = JArray.asFormArray(JFormMap.allKeys(predators))
	Actor[] ActorArray = createActorArray(arr.length)
	
	int index = 0
	while index < ActorArray.length
		ActorArray[index] = arr[index] as Actor
		index += 1
	endWhile
	
	return ActorArray
EndFunction


Form[] Function GetStomachArray(Actor pred)
	int stomachObject = JFormMap.allKeys(GetStomach(pred))
	if JValue.IsExists(stomachObject)
		return JArray.asFormArray(stomachObject)
	else
		return Utility.CreateFormArray(0)
	endIf
EndFunction


bool Function EmptyStomach(Form[] stomach) 
	if !stomach
		return true
	elseif stomach.length == 0
		return true
	elseif stomach.length == 1 && stomach[0] == None
		return true
	else
		return false
	endIf
EndFunction


;==================================================================================================
; StorageUtil interface.
;==================================================================================================


;=========================================
; These functions manage vore skill and experience.


float Function GetPredSkill(Actor target)
{ Determines the pred's pred skill and returns it. }
	float skill
	if target == PlayerRef
		skill = Devourment_PredSkill.GetValue()
		if skill <= 0.0
			skill = StorageUtil.GetFloatValue(target, "vorePredSkill", -1.0)
			Devourment_PredSkill.SetValue(skill)
		endIf
	else
		skill = StorageUtil.GetFloatValue(target, "vorePredSkill", -1.0)
	endIf

	if DEBUGGING
		Log2(PREFIX, "GetPredSkill", Namer(target), skill)
	endIf

	if skill <= 0.0
		skill = GetDefaultPredSkill(target)
	endIf

	return skill
EndFunction


float Function GetPreySkill(Actor target)
{ Calculates the pred's prey skill and returns it. }
	float skill
	if target == PlayerRef
		skill = Devourment_PreySkill.GetValue()
		if skill <= 0.0
			skill = StorageUtil.GetFloatValue(target, "vorePreySkill", -1.0)
			Devourment_PreySkill.SetValue(skill)
		endIf
	else
		skill = StorageUtil.GetFloatValue(target, "vorePreySkill", -1.0)
	endIf

	if DEBUGGING
		Log2(PREFIX, "GetPreySkill", Namer(target), skill)
	endIf

	if skill <= 0.0
		skill = GetDefaultPreySkill(target)
	endIf

	return skill
EndFunction


float Function GetCapacity(Actor target)
{ Gets the stomach capacity of the target, which is their pred skill divided by ten. }
;/
	if MicroMode
		float capacity = StorageUtil.GetFloatValue(target, "voreCapacity", -1.0)
		if capacity > 0.0
			return capacity
		else
			if target.HasKeyword(DevourmentSuperPred)
				return 0.5 + target.getLevel() / 8.0
			else
				return 0.1 + target.getLevel() / 12.0
			endif
		endIf
	else
		/;
		return 1.0 + GetPredSkill(target) / 12.0
	;endIf
endFunction
	
	
float Function GetDefaultPredSkill(Actor target)
	if target == playerRef
		int level = playerRef.getLevel()
		float skill
		if level > 41
			skill = 50.0
		else
			skill = level + 9.0
		endIf
		StorageUtil.SetFloatValue(target, "vorePredSkill", skill)
		StorageUtil.SetFloatValue(target, "vorePredXP", (skill - 1.0) * (skill - 1.0))
		Devourment_PredSkill.setValue(skill)
		return skill
	elseif target.HasKeyword(DevourmentSuperPred)
		return 25.0 + 2.0 * target.getLevel()
	else
		return 6.0 + 1.7 * target.getLevel()
	endIf
EndFunction


float Function GetDefaultPreySkill(Actor target)
	if target == playerRef
		int level = playerRef.getLevel()
		float skill
		if level > 41
			skill = 50.0
		else
			skill = level + 9.0
		endIf
		StorageUtil.SetFloatValue(target, "vorePreySkill", skill)
		StorageUtil.SetFloatValue(target, "vorePreyXP", (skill - 1.0) * (skill - 1.0))
		Devourment_PreySkill.setValue(skill)
		return skill
	elseif target.HasKeyword(DevourmentSuperPrey) || (target.HasKeyword(DevourmentBoss) && bossesSuperPrey)
		return 25.0 + 2.0 * target.getLevel()
	else
		return 6.0 + 1.7 * target.getLevel()
	endIf
EndFunction


int Function GetPerkPoints(Actor target)
	if target == playerRef
		return Devourment_PerkPoints.GetValue() as int
	else
		return StorageUtil.GetIntValue(target, "vorePerkPoints", 0)
	endIf
EndFunction


int Function DecrementPerkPoints(Actor target)
{ Decreases the target's number of perk points. Doesn't NOT check if this will make their total negative. }
	if target == playerRef
		return Devourment_PerkPoints.Mod(-1.0) as int
	else
		int perkPoints = StorageUtil.GetIntValue(target, "vorePerkPoints", 0)
		perkPoints -= 1
		StorageUtil.SetIntValue(target, "vorePerkPoints", perkPoints)
		return perkPoints
	endIf
EndFunction


int Function GetVoreLevel(Actor pred)
	return StorageUtil.GetIntValue(pred, "voreLevel", 0)
EndFunction


float Function GetPredXP(Actor target)
	return StorageUtil.GetFloatValue(target, "vorePredXP", 0.0)
EndFunction


float Function GetPreyXP(Actor target)
	return StorageUtil.GetFloatValue(target, "vorePreyXP", 0.0)
EndFunction


Function GivePredXP_async(Actor pred, float xp)
{ Used to call GivePredXP asynchronously using a ModEvent. }
	int handle = ModEvent.Create("Devourment_PredXP")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushFloat(handle, xp)
	ModEvent.Send(handle)
EndFunction


Function GivePreyXP_async(Actor prey, float xp)
{ Used to call GivePreyXP asynchronously using a ModEvent. }
	int handle = ModEvent.Create("Devourment_PreyXP")
	ModEvent.pushForm(handle, prey)
	ModEvent.pushFloat(handle, xp)
	ModEvent.Send(handle)
EndFunction


Event GivePredXP(Form target, float xp)
	Actor pred = target as Actor
	bool skillUp = false
	float skill = GetPredSkill(pred)
	float experience = StorageUtil.AdjustFloatValue(pred, "vorePredXP", xp * PredExperienceRate)

	; Bleedover a trickle of pred xp to prey.
	StorageUtil.AdjustFloatValue(pred, "vorePreyXP", xp * PreyExperienceRate / 20.0)

	if DEBUGGING
		ConsoleUtil.PrintMessage(Namer(pred) + " gained " + xp + " points of pred xp.")
		Log5(PREFIX, "GivePredXP", Namer(pred), "xp="+xp, "totalXP="+experience, "rate="+PredExperienceRate, "skill="+skill)
	endIf

	while experience >= skill*skill
		skill = IncreasePredSkill(pred)
		skillUp = true
	endWhile
	
	; This is for Custom Skills Framework. 
	if pred == playerRef
		Devourment_PredSkill.SetValue(skill)
		Devourment_PredProgress.SetValue((skill*skill - experience) / (2.0*skill + 1.0))
		if skillUp
			Devourment_ShowPredGain.SetValue(skill)
		endIf
	endIf

	int perkProgress = StorageUtil.GetIntValue(pred, "vorePerkProgress")
	while perkProgress >= 5
		perkProgress -= 5
		perkProgress = StorageUtil.SetIntValue(pred, "vorePerkProgress", perkProgress)
		IncreaseVoreLevel(pred)
	endWhile
EndEvent


Event GivePreyXP(Form target, float xp)
	Actor prey = target as Actor
	bool skillUp = false
	float skill = GetPreySkill(prey)
	float experience = StorageUtil.AdjustFloatValue(prey, "vorePreyXP", xp * PreyExperienceRate)

	; Bleedover a trickle of pred xp to prey.
	StorageUtil.AdjustFloatValue(prey, "vorePredXP", xp * PredExperienceRate / 20.0)

	if DEBUGGING
		ConsoleUtil.PrintMessage(Namer(prey) + " gained " + xp + " points of prey xp.")
		Log5(PREFIX, "GivePreyXP", Namer(prey), "xp="+xp, "totalXP="+experience, "rate="+PreyExperienceRate, "skill="+skill)
	endIf

	while experience >= skill*skill
		skill = IncreasePreySkill(prey)
		skillUp = true
	endWhile
	
	; This is for Custom Skills Framework. 
	if prey == playerRef
		Devourment_PreySkill.SetValue(skill)
		Devourment_PreyProgress.SetValue((skill*skill - experience) / (2.0*skill + 1.0))
		if skillUp
			Devourment_ShowPreyGain.SetValue(skill)
		endIf
	endIf

	int perkProgress = StorageUtil.GetIntValue(prey, "vorePerkProgress")
	while perkProgress >= 5
		perkProgress -= 5
		perkProgress = StorageUtil.SetIntValue(prey, "vorePerkProgress", perkProgress)
		IncreaseVoreLevel(prey)
	endWhile
EndEvent


Event GiveCapacityXP(Form target, float xp)
	Actor pred = target as Actor
	bool skillUp = false
	float skill = GetCapacity(pred)
	float xpmod = AcidDamageModifier / liveMultiplier
	float experience = StorageUtil.AdjustFloatValue(pred, "voreCapacityXP", xp * xpmod)

	if DEBUGGING
		ConsoleUtil.PrintMessage(Namer(pred) + " gained " + xp + " points of capacity xp.")
		Log5(PREFIX, "GiveCapacityXP", Namer(pred), "xp="+xp, "totalXP="+experience, "rate="+xpmod, "skill="+skill)
	endIf

	while experience >= skill*skill
		skill = IncreaseCapacity(pred)
		skillUp = true
	endWhile
EndEvent


float Function IncreasePredSkill(Actor target)
{ Adjusts the target's pred skill and returns it. }
	float skill = StorageUtil.AdjustFloatValue(target, "vorePredSkill", 1.0)
	StorageUtil.AdjustIntValue(target, "vorePerkProgress", 1)
	if target == playerRef
		Devourment_PredSkill.SetValue(skill)
	endIf
	return skill
EndFunction


float Function IncreasePreySkill(Actor target)
{ Adjusts the target's prey skill and returns it. }
	float skill = StorageUtil.AdjustFloatValue(target, "vorePreySkill", 1.0)
	StorageUtil.AdjustIntValue(target, "vorePerkProgress", 1)
	if target == playerRef
		Devourment_PreySkill.SetValue(skill)
	endIf
	return skill
EndFunction


float Function IncreaseCapacity(Actor target)
{ Adjusts the target's pred skill and returns it. }
	float skill = StorageUtil.AdjustFloatValue(target, "voreCapacity", 0.05)
	return skill
EndFunction
	
	
Function IncreaseVoreLevel(Actor target, int delta = 1)
{ Adjusts the target's vore level and returns their available perk points. }

	StorageUtil.AdjustIntValue(target, "voreLevel", delta)

	if target == playerRef
		Devourment_PerkPoints.mod(delta as float)
		VSkillLevelSound.play(target)
	else
		StorageUtil.AdjustIntValue(target, "vorePerkPoints", delta)
	endIf
EndFunction


int Function GetNumVictims(Actor pred)
{ Returns the total number of victims that have died in the pred's stomach. }
	return StorageUtil.GetIntValue(pred, "voreVictims")
EndFunction


Function IncrementVictims(Actor pred)
{ Increases the total number of victims for the pred. }
	StorageUtil.AdjustIntValue(pred, "voreVictims", 1)
EndFunction


int Function GetTimesSwallowed(Actor pred, bool endo)
{ Returns the number of times that the prey has been swallowed, for endo or vore.}
	if endo
		return StorageUtil.GetIntValue(pred, "voreEndoed", 0)
	else
		return StorageUtil.GetIntValue(pred, "voreVored", 0)
	endIf
EndFunction


Function IncrementSwallowedCount(Actor prey, bool endo)
{ Increases the total number of times the prey has been swallowed, for endo or vore. }
	if endo
		StorageUtil.AdjustIntValue(prey, "voreEndoed", 1)
	else
		StorageUtil.AdjustIntValue(prey, "voreVored", 1)
	endIf
EndFunction


int Function GetVictimType(Actor pred, String type)
{ Returns the number of victims of a particular type that have died in the pred's stomach. }
	return StorageUtil.GetIntValue(pred, "digested"+type)
EndFunction


Function IncrementVictimType(Actor pred, String type)
{ Increases the number of victims of a particular type for the pred. }
	StorageUtil.AdjustIntValue(pred, "digested"+type, 1)
EndFunction


float Function GetVoreWeightRatio(Actor pred, Actor prey)
	float predSize = GetVoreWeight(pred)
	float preySize = GetVoreWeight(prey)
	float ratio = (predSize - preySize) / (predSize + preySize)

	if DEBUGGING
		Log5(PREFIX, "GetVoreWeightRatio", Namer(pred), Namer(prey), predSize, preySize, ratio)
	endIf
	
	return ratio
endFunction


Function UncacheVoreWeight(Actor subject)
	StorageUtil.UnsetFloatValue(subject, "dvtCachedWeight")
EndFunction


Function CacheVoreWeight(Actor subject)
	StorageUtil.UnsetFloatValue(subject, "dvtCachedWeight")
	StorageUtil.SetFloatValue(subject, "dvtCachedWeight", GetVoreWeight(subject))
EndFunction


float Function GetCumulativeSize(Actor subject)
	float scale = subject.GetScale()
	if scale < 0.1
		scale = 0.01
	elseif scale > 10.0
		scale = 10.0
	endIf

	if DEBUGGING
		Log2(PREFIX, "GetCumulativeSize", Namer(subject), scale)
	endIf
	
	return scale
EndFunction


float Function GetVoreWeight(Actor subject)
	{ Determine how heavy an Actor is. This affects how much fullness they will cause as prey, as well as making 
	them more difficult to swallow. For predators, weight will give them an advantage in swallowing. }

	;Debug.Trace(PREFIX + " " + NamerDebug(subject))

	if subject == none
		assertNotNone(PREFIX, "GetVoreWeight", "subject", subject)
		return -1.0
	endIf

	; If the weight has already been determined and stored, use that value.
	float cachedWeight = StorageUtil.GetFloatValue(subject, "dvtCachedWeight", -1.0)
	if cachedWeight > 0.0
		if DEBUGGING
			Log2(PREFIX, "GetVoreWeight", Namer(subject), "Cache hit: " + cachedWeight)
		endIf
		return cachedWeight
	endIf
	
	; We go by Race, and PapyrusUtil conveniently makes Race editorIDs available.
	String raceEDID = MiscUtil.GetActorRaceEditorID(subject)
	
	if JSonUtil.HasFloatValue(RaceWeights, raceEDID)
		; RaceWeight points to a JSON file mapping the editorIDs of races to weights.
		; The default weight for a humanoid sized Actor is 100.
		float raceWeight = JSonUtil.GetFloatValue(RaceWeights, raceEDID, 100.0)

		if DEBUGGING
			Log3(PREFIX, "GetVoreWeight", Namer(subject), raceWeight, GetCumulativeSize(subject))
		endIf
		return raceWeight * GetCumulativeSize(subject)

	else
		; The race wasn't found in the JSON file, this will display a message box to allow the user to select a weight.
		; Then store the weight in the JSON file for next time.
		float raceWeight = GetPreyWeightMenu(subject)
		JSonUtil.SetFloatValue(RaceWeights, raceEDID, raceWeight)
		JSonUtil.save(RaceWeights)
		
		if DEBUGGING
			Log3(PREFIX, "GetVoreWeight", Namer(subject), raceWeight, GetCumulativeSize(subject))
		endIf
		return raceWeight * GetCumulativeSize(subject)
	endIf	
EndFunction


float Function GetPreyWeightMenu(Actor subject)
	PreyNameAlias.ForceRefTo(subject)
	PreyWeightEdit.SetValue(100.0)
	UpdateCurrentInstanceGlobal(PreyWeightEdit)
	int selection = MenuPreyWeight.show()
	
	while selection < 5
		if selection == 0
			PreyWeightEdit.mod(-100.0)
		elseif selection == 1
			PreyWeightEdit.mod(-10.0)
		elseif selection == 2
			PreyWeightEdit.mod(10.0)
		elseif selection == 3
			PreyWeightEdit.mod(100.0)
		elseif selection == 4
			PreyWeightEdit.mod(500.0)
		endIf
		
		if PreyWeightEdit.GetValue() < 10.0
			PreyWeightEdit.SetValue(10.0)
		endIf
		
		UpdateCurrentInstanceGlobal(PreyWeightEdit)
		selection = MenuPreyWeight.show()
	endWhile
	
	PreyNameAlias.clear()
	return PreyWeightEdit.GetValue()
EndFunction


;=================================================
; Shortcut functions for sending devourment events.
;


Function SendSwallowAttemptEvent(Actor pred, Actor prey, bool endo, bool stealth, bool success, int locus) global
	int handle = ModEvent.create("Devourment_onSwallowAttempt")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.pushBool(handle, endo)
	ModEvent.pushBool(handle, stealth)
	ModEvent.pushBool(handle, success)
	ModEvent.pushInt(handle, locus)
	ModEvent.Send(handle)
EndFunction


Function SendSwallowEvent(Actor pred, Actor prey, bool endo, int locus) global
	int handle = ModEvent.create("Devourment_onSwallow")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.pushBool(handle, endo)
	ModEvent.pushInt(handle, locus)
	ModEvent.Send(handle)
EndFunction


Function SendEscapeEvent(Actor pred, Actor prey, bool endo) global
	int handle = ModEvent.create("Devourment_onEscape")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.pushBool(handle, endo)
	ModEvent.Send(handle)
EndFunction


Function SendLiveDigestionEvent(Actor pred, Actor prey, float damage, float percent) global
	int handle = ModEvent.create("Devourment_onLiveDigestion")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.pushFloat(handle, damage)
	ModEvent.pushFloat(handle, percent)
	ModEvent.Send(handle)
EndFunction


Function SendDeathEvent(Actor pred, Actor prey) global
	int handle = ModEvent.create("Devourment_onPreyDeath")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.Send(handle)
EndFunction


Function SendDeadDigestionEvent(Actor pred, Actor prey, float remaining) global
	int handle = ModEvent.create("Devourment_onDeadDigestion")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.pushFloat(handle, remaining)
	ModEvent.Send(handle)
EndFunction


Function SendReformationEvent(Actor pred, Actor prey) global
	int handle = ModEvent.create("Devourment_onReformation")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.Send(handle)
EndFunction


Function SendDeadReformingEvent(Actor pred, Actor prey, float remaining) global
	int handle = ModEvent.create("Devourment_onDeadReforming")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.pushFloat(handle, remaining)
	ModEvent.Send(handle)
EndFunction


Function SendExcretionEvent(Actor pred, ObjectReference prey) global
	int handle = ModEvent.create("Devourment_onExcretion")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.Send(handle)
EndFunction


Function SendNewCharacterEvent(Actor pred, Actor prey) global
	int handle = ModEvent.create("Devourment_onNewCharacter")
	ModEvent.pushForm(handle, pred)
	ModEvent.pushForm(handle, prey)
	ModEvent.Send(handle)
EndFunction


;=================================================
; Save/Load settings.
;


bool Function saveSettings(String settingsFileName)
	Log1(PREFIX, "saveSettings", settingsFileName)

	int data = JMap.object()

	JMap.setInt(data, "CombatAcceleration", 	CombatAcceleration as int)
	JMap.setInt(data, "scatTypeNPC", 			scatTypeNPC)
	JMap.setInt(data, "scatTypeCreature", 		scatTypeCreature)
	JMap.setInt(data, "scatTypeBolus", 			scatTypeBolus)
	JMap.setInt(data, "screamSounds", 			screamSounds as int)
	JMap.setInt(data, "killPlayer", 			killPlayer as int)
	JMap.setInt(data, "killNPCs", 				killNPCs as int)
	JMap.setInt(data, "killEssential", 			killEssential as int)
	JMap.setInt(data, "playerPreference", 		playerPreference as int)
	JMap.setInt(data, "entitlement", 			entitlement as int)
	JMap.setInt(data, "bossesSuperPrey", 		bossesSuperPrey as int)
	JMap.setInt(data, "whoStruggles", 			whoStruggles)
	JMap.setInt(data, "multiPrey", 				multiPrey)
	JMap.setInt(data, "EndoStruggling", 		EndoStruggling as int)
	JMap.setInt(data, "VisualStruggles", 		VisualStruggles as int)
	JMap.setInt(data, "ComplexStruggles", 		ComplexStruggles as int)
	JMap.setInt(data, "SkillGain", 				SkillGain as int)
	JMap.setInt(data, "AttributeGain", 			AttributeGain as int)
	JMap.setInt(data, "DragonVoreAnimation", 	DragonVoreAnimation as int)
	JMap.setInt(data, "MammothVoreAnimation", 	MammothVoreAnimation as int)
	
	JMap.setFlt(data, "StruggleDifficulty", 	StruggleDifficulty)
	JMap.setFlt(data, "StruggleDamage", 		StruggleDamage)
	JMap.setFlt(data, "LiveMultiplier", 		LiveMultiplier)
	JMap.setFlt(data, "DigestionTime", 			DigestionTime)
	JMap.setFlt(data, "MinimumSwallowChance", 	MinimumSwallowChance)
	JMap.setFlt(data, "NPCBonus", 				NPCBonus)
	JMap.setFlt(data, "CombatChanceScale", 		CombatChanceScale)
	JMap.setFlt(data, "AcidDamageModifier", 	AcidDamageModifier)
	JMap.setFlt(data, "BurpsRate", 				BurpsRate)
	JMap.setFlt(data, "GurglesRate", 			GurglesRate)
	JMap.setFlt(data, "CameraShake", 			CameraShake)
	JMap.setFlt(data, "Cooldown_Creature", 		Cooldown_Creature)
	JMap.setFlt(data, "Cooldown_NPC", 			Cooldown_NPC)

	JMap.setInt(data, "AutoNoms", 				AutoNoms)
	JMap.setInt(data, "ShitItems", 				ShitItems as int)
	JMap.setInt(data, "VoreTimeout", 			VoreTimeout as int)
	JMap.setInt(data, "EndoTimeout", 			EndoTimeout as int)
	JMap.setInt(data, "StomachStrip", 			StomachStrip as int)
	JMap.setInt(data, "DrawnAnimations", 		DrawnAnimations as int)
	JMap.setInt(data, "CrouchScat", 			CrouchScat as int)
	JMap.setFlt(data, "WeightGain",				WeightGain)
	JMap.setFlt(data, "ItemBurping",			ItemBurping)
	
	JMap.setInt(data, "endoAnyone", 			endoAnyone as int)
	JMap.setInt(data, "VomitStyle", 			VomitStyle)
	JMap.setInt(data, "UseHelpMessages", 		UseHelpMessages as int)
	JMap.setInt(data, "Notifications", 			Notifications as int)
	JMap.setInt(data, "AltPerkMenus",			Menu.AltPerkMenus as int)

	JMap.setInt(data, "CreaturePreds", 		CreaturePreds as int)
	JMap.setInt(data, "FemalePreds", 		FemalePreds as int)
	JMap.setInt(data, "MalePreds", 			MalePreds as int)

	JMap.SetObj(data, "CreaturePredatorToggles",	JArray.objectWithInts(CreaturePredatorToggles))
	JMap.SetObj(data, "HumanoidMalePredatorToggles",	JArray.objectWithInts(HumanoidMalePredatorToggles))
	JMap.SetObj(data, "HumanoidFemalePredatorToggles",	JArray.objectWithInts(HumanoidFemalePredatorToggles))
	JMap.setInt(data, "PlayerAlias.DefaultLocus", PlayerAlias.DefaultLocus)
	
	SkullHandler.SaveSettings(data)
	Menu.Morphs.SaveSettings(data)

	JValue.writeToFile(data, SettingsFileName)
	return JContainers.fileExistsAtPath(SettingsFileName)
EndFunction


bool Function loadSettings(String settingsFileName)
	Log1(PREFIX, "loadSettings", settingsFileName)

	int data = JValue.readFromFile(SettingsFileName)
	if !JValue.isExists(data)
		return false
	endIf

	CombatAcceleration = 	JMap.getInt(data, "CombatAcceleration", 		CombatAcceleration as int) as bool
	scatTypeNPC = 			JMap.getInt(data, "scatTypeNPC", 				scatTypeNPC)
	scatTypeCreature = 		JMap.getInt(data, "scatTypeCreature", 			scatTypeCreature)
	scatTypeBolus = 		JMap.getInt(data, "scatTypeBolus", 				scatTypeBolus)
	killPlayer = 			JMap.getInt(data, "killPlayer", 				killPlayer as int) as bool
	killNPCs = 				JMap.getInt(data, "killNPCs", 					killNPCs as int) as bool
	killEssential = 		JMap.getInt(data, "killEssential", 				killEssential as int) as bool
	playerPreference = 		JMap.getInt(data, "playerPreference", 			playerPreference as int)
	screamSounds = 			JMap.getInt(data, "screamSounds", 				screamSounds as int) as bool
	bossesSuperPrey = 		JMap.getInt(data, "bossesSuperPrey", 			bossesSuperPrey as int) as bool
	entitlement = 			JMap.getInt(data, "entitlement", 				entitlement as int) as bool
	whoStruggles =			JMap.getInt(data, "whoStruggles", 				whoStruggles)
	multiPrey = 			JMap.getInt(data, "multiPrey", 					multiPrey)
	EndoStruggling = 		JMap.getInt(data, "EndoStruggling", 			EndoStruggling as int) as bool
	VisualStruggles = 		JMap.getInt(data, "VisualStruggles", 			VisualStruggles as int) as bool
	ComplexStruggles = 		JMap.getInt(data, "ComplexStruggles", 			ComplexStruggles as int) as bool
	SkillGain = 			JMap.getInt(data, "SkillGain", 					SkillGain as int) as bool
	AttributeGain = 		JMap.getInt(data, "AttributeGain", 				AttributeGain as int) as bool
	DragonVoreAnimation = 	JMap.getInt(data, "DragonVoreAnimation", 		DragonVoreAnimation as int) as bool
	MammothVoreAnimation = 	JMap.getInt(data, "MammothVoreAnimation", 		MammothVoreAnimation as int) as bool

	PredExperienceRate = 	JMap.getFlt(data, "PredExperienceRate", 	PredExperienceRate)
	PreyExperienceRate = 	JMap.getFlt(data, "PreyExperienceRate", 	PreyExperienceRate)
	StruggleDifficulty = 	JMap.getFlt(data, "StruggleDifficulty", 	StruggleDifficulty)
	StruggleDamage = 		JMap.getFlt(data, "StruggleDamage", 		StruggleDamage)
	liveMultiplier = 		JMap.getFlt(data, "liveMultiplier", 		liveMultiplier)
	DigestionTime = 		JMap.getFlt(data, "DigestionTime", 			DigestionTime)
	MinimumSwallowChance = 	JMap.getFlt(data, "MinimumSwallowChance", 	MinimumSwallowChance)
	NPCBonus = 				JMap.getFlt(data, "NPCBonus", 				NPCBonus)
	CombatChanceScale = 	JMap.getFlt(data, "CombatChanceScale", 		CombatChanceScale)
	AcidDamageModifier = 	JMap.getFlt(data, "AcidDamageModifier", 	AcidDamageModifier)
	BurpsRate = 			JMap.getFlt(data, "BurpsRate", 				BurpsRate)
	GurglesRate = 			JMap.getFlt(data, "GurglesRate", 			GurglesRate)
	cameraShake = 			JMap.getFlt(data, "cameraShake", 			cameraShake)
	Cooldown_Creature = 	JMap.getFlt(data, "Cooldown_Creature", 		Cooldown_Creature)
	Cooldown_NPC = 			JMap.getFlt(data, "Cooldown_NPC", 			Cooldown_NPC)

	AutoNoms = 				JMap.getInt(data, "AutoNoms", 				AutoNoms)
	ShitItems = 			JMap.getInt(data, "ShitItems", 				ShitItems as int) as bool
	VoreTimeout = 			JMap.getInt(data, "VoreTimeout", 			VoreTimeout as int) as bool
	EndoTimeout = 			JMap.getInt(data, "EndoTimeout", 			EndoTimeout as int) as bool
	StomachStrip = 			JMap.getInt(data, "StomachStrip", 			StomachStrip as int) as bool
	drawnAnimations = 		JMap.getInt(data, "drawnAnimations", 		drawnAnimations as int) as bool
	crouchScat = 			JMap.getInt(data, "crouchScat", 			crouchScat as int) as bool
	WeightGain = 			JMap.getFlt(data, "WeightGain", 			WeightGain)
	ItemBurping = 			JMap.getFlt(data, "ItemBurping", 			ItemBurping)

	endoAnyone = 			JMap.getInt(data, "endoAnyone", 			endoAnyone as int) as bool
	VomitStyle = 			JMap.getInt(data, "VomitStyle", 			VomitStyle)
	useHelpMessages = 		JMap.getInt(data, "useHelpMessages", 		useHelpMessages as int) as bool
	notifications = 		JMap.getInt(data, "notifications", 			notifications as int) as bool
	SwallowHeal = 			JMap.getInt(data, "SwallowHeal", 			SwallowHeal as int) as bool
	creaturePreds = 		JMap.getInt(data, "creaturePreds", 			creaturePreds as int) as bool
	femalePreds = 			JMap.getInt(data, "femalePreds", 			femalePreds as int) as bool
	malePreds = 			JMap.getInt(data, "malePreds", 				malePreds as int) as bool
	
	CreaturePredatorToggles =	JArray.asIntArray(JMap.getObj(data, "CreaturePredatorToggles", JArray.ObjectWithInts(CreaturePredatorToggles)))
	HumanoidMalePredatorToggles =	JArray.asIntArray(JMap.getObj(data, "HumanoidMalePredatorToggles", JArray.ObjectWithInts(HumanoidMalePredatorToggles)))
	HumanoidFemalePredatorToggles =	JArray.asIntArray(JMap.getObj(data, "HumanoidFemalePredatorToggles", JArray.ObjectWithInts(HumanoidFemalePredatorToggles)))
	PlayerAlias.DefaultLocus = JMap.getInt(data, "DefaultLocus", PlayerAlias.DefaultLocus)
	Menu.AltPerkMenus = 	JMap.getInt(data, "AltPerkMenus",			Menu.AltPerkMenus as int) as bool
	Menu.RecalculateLocusCumulative()
	
	SkullHandler.LoadSettings(data)
	Menu.Morphs.LoadSettings(data)

	return true
EndFunction


;=================================================
; Convenience function.


DevourmentManager Function instance() global
{ Returns the DevourmentManager instance, for situations in which a property isn't helpful (like global functions). }
	return Quest.GetQuest("DevourmentManager") as DevourmentManager
EndFunction
