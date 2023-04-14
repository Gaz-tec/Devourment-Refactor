ScriptName DevourmentSkullHandler extends Quest
import Logging
import Devourment_JCDomain


DevourmentManager property Manager auto
Actor property PlayerRef auto
Faction property PlayerFaction auto
Keyword property DevourmentSkull auto
Race[] property Races auto
Race property DragonRace auto
MiscObject[] property Skulls auto
SoulGem[] property Soulgems auto


bool property SkullsForDragons = true auto
bool property SkullsForEssential = true auto
bool property SkullsForUnique = true auto
bool property SkullsForUnleveled = false auto
bool property SkullsForEveryone = false auto
bool property SkullsSeparate = false auto
bool property NamedSouls = true auto
int property SoulsSeparate = 2 auto


String PREFIX = "DevourmentSkullHandler"


Function AddSoul(Actor pred, Actor prey)
	if !(pred && prey)
		return
	endIf

	; It's good to have the name on the skull. No anonymous skulls.
	String name = Namer(prey, true)
	if name == ""
		Log2(PREFIX, "AddSoul", "Couldn't find name for prey.", Namer(prey))
		return
	endIf
	
	int soulSize = PO3_SKSEFunctions.GetActorSoulSize(prey)
	Form soulForm = SoulGems[soulSize]
	ObjectReference soulRef = Pred.PlaceAtMe(soulForm, 1, true, true)

	; Set the name. This is actually really important, it's what prevents the skulls from stacking and keeps them distinct.
	if NamedSouls
		soulRef.SetDisplayName(name + "'s Soul", true)
	endIf

	if SoulsSeparate == 1
		; Digest it!
		Manager.DigestItem(pred, soulRef, 1, none)
		soulRef.enable()
	elseif SoulsSeparate == 2
		; Put it in the pred's inventory.
		soulRef.enable()
		prey.addItem(soulRef, 1, true)
	else
		; Put it in their inventory.
		soulRef.enable()
		prey.addItem(soulRef, 1, true)
	endIf
	
	Log3(PREFIX, "AddSoul", "Created soul", Namer(prey), Namer(soulRef))
EndFunction


Function AddSkull(Actor pred, Actor prey)
	if !(pred && prey)
		return
	endIf
	
	; This handles the complexity of mapping vampire races onto regular races, and stuff like that.
	DevourmentRemap remapper = (Manager as Quest) as DevourmentRemap
	Race remappedRace = remapper.RemapRace(prey.GetLeveledActorBase().GetRace())
	
	; We can't save every single skull, that would get ridiculous.
	; So as a first draft, how about essential and protected NPCs, as well as ALL dragons?
	; Throw in all unleveled NPCs.
	; Let's make this user-configurable somewhere down the line.
	
	ActorBase preyBase = prey.GetLeveledActorBase()
	ActorBase preyBaseUnlevel = prey.GetActorBase()
	
	if prey == playerRef
		Log2(PREFIX, "AddSkull", Namer(prey), "PlayerRef -- eligible for skull collection.")
	elseif SkullsForEveryone && (prey.HasKeyword(Manager.ActorTypeNPC) || remappedRace == DragonRace)
		Log2(PREFIX, "AddSkull", Namer(prey), "NPC -- eligible for skull collection.")
	elseif SkullsForEssential && (prey.IsEssential() || preyBase.IsProtected() || preyBase.IsInvulnerable())
		Log2(PREFIX, "AddSkull", Namer(prey), "Essential/protected -- eligible for skull collection.")
	elseif SkullsForUnique && preyBase.IsUnique() 
		Log3(PREFIX, "AddSkull", Namer(prey), "Unique NPC -- eligible for skull collection.", Namer(preyBase))
	elseif SkullsForUnleveled && (preyBase == preyBaseUnlevel && prey.HasKeyword(Manager.ActorTypeNPC))
		Log4(PREFIX, "AddSkull", Namer(prey), "Unleveled NPC -- eligible for skull collection.", Namer(preyBase), Namer(preyBaseUnlevel))
	elseif SkullsForDragons && remappedRace == DragonRace
		Log2(PREFIX, "AddSkull", Namer(prey), "Dragon -- eligible for skull collection.")
	else
		Log2(PREFIX, "AddSkull", "No criteria for skull collection was found.", Namer(prey))
		return
	endIf
	
	; It's good to have the name on the skull. No anonymous skulls.
	String name = Namer(prey, true)
	if name == ""
		Log2(PREFIX, "AddSkull", "Couldn't find name for prey.", Namer(prey))
		return
	endIf
	
	; Find the corresponding skull for the prey's race.
	int raceIndex = Races.find(remappedRace)
	if raceIndex < 0 || raceIndex >= Skulls.length
		if prey.HasKeyword(Manager.ActorTypeNPC)
			raceIndex = Races.find(Game.GetForm(0x13746) as Race)	;Nord Race. This failover was set up this way so as to not damage existing savegames in the event our array indexes are moved.
		else
			Log3(PREFIX, "AddSkull", "Couldn't find matching skull.", Namer(prey), Namer(remappedRace))
			return
		endIf
	endIf
	
	; Make the skull and name it appropriately.
	MiscObject skullForm = Skulls[raceIndex]
	DevourmentSkullObject skullRef = Pred.PlaceAtMe(skullForm, 1, true, false) as DevourmentSkullObject
	
	; Set the name. This is actually really important, it's what prevents the skulls from stacking and keeps them distinct.
	skullRef.InitializeFor(prey)	;Moved to deal with ItemDigest quirks!


	if SkullsSeparate
		; Digest it!
		;skullRef.InitializeFor(prey)
		Manager.DigestItem(pred, skullRef, 1, none)
		;((skullRef as Form) as ObjectReference).enable()	;This order looks funny, but DigestItem will start reformation if the skull is enabled first.
	else
		; Put it in their inventory.
		;skullRef.InitializeFor(prey)
		;((skullRef as Form) as ObjectReference).enable()
		prey.addItem(skullRef, 1, true)
	endIf

	
	Log3(PREFIX, "AddSkull", "Created skull", Namer(prey), Namer(skullRef))
EndFunction


ObjectReference Function CloneSkullToWorld(DevourmentSkullObject akSkull, Actor akPrey)
{Function to clone a Skull relatively exactly. Used when we need a Skull that was previously in a container to suddenly be in a worldspace as .Drop functions break their Prey Var.}

	Form skullBaseForm = akSkull.GetBaseObject()
	MiscObject skullForm = skullBaseForm as MiscObject
	DevourmentSkullObject skullRef = (PlayerRef.PlaceAtMe(skullForm, 1, true, true) as Form) as DevourmentSkullObject
	skullRef.InitializeFor(akPrey)
	Return skullRef
	
EndFunction


bool Function SwallowSkull(Actor pred, ObjectReference skullRef, int locus = -1)
	if skullRef == none || skullRef.IsDisabled()
		assertFail(PREFIX, "SwallowSkull", "Invalid skull.")
		return false
	endIf
	
	Actor revivee = (skullRef as DevourmentSkullObject).GetRevivee()
	if revivee == none
		assertFail(PREFIX, "SwallowSkull", "Revivee couldn't be found.")
		return false
	endIf
	
	; For the player, get a suitable proxy.
	if revivee == PlayerRef
		Actor deadDovaRef = DevourmentNewDova.instance().deadDovaRef
		if deadDovaRef
			revivee = deadDovaRef
		else
			return false
		endIf
	endIf

	Log0(PREFIX, "SwallowSkull")
	
	if locus >= 0
		Manager.RegisterReformation(pred, revivee, locus)
	elseif Manager.IsFemale(pred)
		Manager.RegisterReformation(pred, revivee, 2)
	else
		Manager.RegisterReformation(pred, revivee, 0)
	endIf
	
	pred.removeItem(skullRef, 1, true)
	skullRef.Disable(true)
	skullRef.Delete()
	
	return true
EndFunction


bool Function ReviveSkullToWorld(Actor pred, DevourmentSkullObject skullRef)
	Actor revivee = skullRef.GetRevivee()
	if revivee == none
		assertFail(PREFIX, "ReviveSkullToWorld", "Revivee couldn't be found.")
		return false
	endIf
	
	revivee.Enable(false)
	revivee.Reset(none)
	revivee.SetOutfit(Manager.DigestionOutfit)
	revivee.RemoveAllItems()
	revivee.IgnoreFriendlyHits(true)
	revivee.SetGhost(false)
	
	; Make the revivee friendly towards the pred.
	revivee.SetRelationshipRank(Pred, revivee.GetRelationshipRank(Pred) + 2)
	if pred == PlayerRef
		revivee.MakePlayerFriend()
	;	revivee.AddToFaction(PlayerFaction)
	;	revivee.RemoveFromFaction(revivee.GetCrimeFaction())
	endIf
	
	revivee.Moveto(Pred, 0.0, 0.0, 0.0, true)
	revivee.StopCombatAlarm()
	
	Log3(PREFIX, "ReviveSkullToWorld", "Finished revival process.", Namer(skullRef), Namer(revivee))
	skullRef.Disable(true)
	skullRef.Delete()

	return true
EndFunction


Function LoadSettings(int data)
	SkullsForDragons = 		JMap_getInt(data, "SkullsForDragons", 	SkullsForDragons as int) as bool
	SkullsForUnique = 		JMap_getInt(data, "SkullsForUnique", 	SkullsForUnique as int) as bool
	SkullsForEssential =	JMap_getInt(data, "SkullsForEssential",	SkullsForEssential as int) as bool
	SkullsForEveryone = 	JMap_getInt(data, "SkullsForEveryone",	SkullsForEveryone as int) as bool
	SkullsSeparate = 		JMap_getInt(data, "SkullsSeparate",		SkullsSeparate as int) as bool
	SoulsSeparate = 		JMap_getInt(data, "SoulsSeparate",		SoulsSeparate)
	NamedSouls = 			JMap_getInt(data, "NamedSouls",			NamedSouls as int) as bool
EndFunction


Function SaveSettings(int data)
	JMap_setInt(data, "SkullsForDragons", 	SkullsForDragons as int)
	JMap_setInt(data, "SkullsForUnique",	SkullsForUnique as int)
	JMap_setInt(data, "SkullsForEssential",	SkullsForEssential as int)
	JMap_setInt(data, "SkullsForEveryone",	SkullsForEveryone as int)
	JMap_setInt(data, "SkullsSeparate",		SkullsSeparate as int)
	JMap_setInt(data, "SoulsSeparate",		SoulsSeparate)
	JMap_setInt(data, "NamedSouls",			NamedSouls as int)
EndFunction


Function Upgrade(int oldVersion, int newVersion)
	Log2(PREFIX, "Upgrade", oldVersion, newVersion)
EndFunction
	
	
DevourmentSkullHandler Function instance() global
{ Returns the DevourmentSkullHandler instance, for situations in which a property isn't helpful (like global functions). }
	return Quest.GetQuest("DevourmentSkullHandler") as DevourmentSkullHandler
EndFunction
