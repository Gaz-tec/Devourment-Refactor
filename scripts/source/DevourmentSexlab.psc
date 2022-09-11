ScriptName DevourmentSexlab extends ReferenceAlias
{
Handles sexlab-related features of Devourment.
This creates a layer of separation, in case Sexlab isn't present.
}
import Logging
import DevourmentUtil


DevourmentManager property Manager auto hidden
Quest property Sexlab auto hidden
Quest property SLA auto hidden

bool DEBUGGING = false
String PREFIX = "DevourmentSexlab"


Event OnInit()
	Utility.wait(2.0)
	OnPlayerLoadGame()
EndEvent


Event OnPlayerLoadGame()
	if !Sexlab && Quest.GetQuest("SexLabQuestFramework")
		Sexlab = SexlabUtil.GetAPI()
	endIf
	if !SLA && Quest.GetQuest("sla_Framework")
		SLA = Quest.GetQuest("sla_Framework")
	endIf

	if Sexlab
		RegisterForModEvent("HookAnimationStart", "SexlabAnimationStart")
		RegisterForModEvent("HookAnimationEnd", "SexlabAnimationEnd")
		RegisterForModEvent("HookAnimationEnding", "SexlabAnimationEnding")
		RegisterForModEvent("HookAnimationEnd_Vore", "SexlabAnimationEnd_Vore")
		RegisterForModEvent("HookAnimationEnd_Endo", "SexlabAnimationEnd_Endo")
	endIf

	if SLA
		RegisterForModEvent("Devourment_onSwallow", "onSwallow")
	endIf
EndEvent


Event onSwallow(Form f1, Form f2, bool endo, int locus)
	Actor pred = f1 as Actor
	Actor prey = f2 as Actor

	if pred && prey
		SwallowArousal(pred, prey, endo)
	endIf
EndEvent


Event SexlabAnimationStart(int tid, bool HasPlayer)
	sslThreadController thread = (Sexlab as SexLabFramework).GetController(tid)

	if thread 
		int i = thread.positions.length
		while i
			i -= 1
			Actor pos = thread.positions[i]
			if pos
				Manager.RegisterBlock(PREFIX, pos)
			endIf
		endWhile
	endIf
EndEvent


Event SexlabAnimationEnd(int tid, bool HasPlayer)
	sslThreadController thread = (Sexlab as SexLabFramework).GetController(tid)

	if thread 
		int i = thread.positions.length
		while i
			i -= 1
			Actor pos = thread.positions[i]
			if pos
				Manager.UnregisterBlock(PREFIX, pos)
			endIf
		endWhile
	endIf
EndEvent


Event SexlabAnimationEnding(int tid, bool HasPlayer)
	sslThreadController thread = (Sexlab as SexLabFramework).GetController(tid)

	if thread && thread.positions.length >= 2
		String[] tags = thread.Animation.GetTags()
		Actor pred = thread.positions[1]
		Actor prey = thread.positions[0]
		
		Log1(PREFIX, "SexlabAnimationEnding", "Checking tags")
		
		if tags.find("OralVore") >= 0
			Log1(PREFIX, "SexlabAnimationEnding", "OralVore found.")
			Manager.RegisterDigestion(pred, prey, true, 0)
		elseif tags.find("AnalVore") >= 0
			Log1(PREFIX, "SexlabAnimationEnding", "AnalVore found.")
			Manager.RegisterDigestion(pred, prey, true, 1)
		elseif tags.find("UnBirth") >= 0
			Log1(PREFIX, "SexlabAnimationEnding", "Unbirth found.")
			Manager.RegisterDigestion(pred, prey, true, 2)
		elseif tags.find("CockVore") >= 0
			Log1(PREFIX, "SexlabAnimationEnding", "CockVore found.")
			Manager.RegisterDigestion(pred, prey, true, 4)
		elseif tags.find("Vore") >= 0
			Log1(PREFIX, "SexlabAnimationEnding", "Vore found.")
			Manager.RegisterDigestion(pred, prey, true, 0)
		;elseif thread.positions.find(Manager.PlayerRef) >= 0 && Utility.RandomInt(100) < 10
		;	Log1(PREFIX, "SexlabAnimationEnding", "Accidental Digestion")
		;	Manager.SwitchLethalAll(Manager.PlayerRef, true)
		endIf
	endIf
EndEvent


Event SexlabAnimationEnd_Vore(int tid, bool HasPlayer)
	Log2(PREFIX, "SexlabAnimationEnd_Vore", tid, hasPlayer)
	sslThreadController thread = (Sexlab as SexLabFramework).GetController(tid)
	if thread && thread.positions.length >= 2
		Manager.ForceSwallow(thread.positions[0], thread.positions[1], false)
	endIf
EndEvent


Event SexlabAnimationEnd_Endo(int tid, bool HasPlayer)
	Log2(PREFIX, "SexlabAnimationEnd_Endo", tid, hasPlayer)
	sslThreadController thread = (Sexlab as SexLabFramework).GetController(tid)
	if thread && thread.positions.length >= 2
		Manager.ForceSwallow(thread.positions[0], thread.positions[1], true)
	endIf
EndEvent


bool Function Masturbate(Actor subject)
{ Tells an actor to play a masturbation animation. }
	if !(subject && Sexlab)
		if DEBUGGING
			assertNotNone(PREFIX, "Masturbate", "subject", subject)
			assertNotNone(PREFIX, "Masturbate", "Sexlab", Sexlab)
		endIf
		return false
	endIf
	
	Log1(PREFIX, "Masturbate", Namer(subject))
	
	Actor[] actors = new Actor[1]
	actors[0] = subject
	sslBaseAnimation[] anims = (Sexlab as SexLabFramework).PickAnimationsByActors(actors)
	
	if DEBUGGING
		LogStrings(PREFIX, "Masturbate", "anims", makeNameArray(anims))
	endIf

	sslThreadModel Thread = (Sexlab as SexLabFramework).NewThread()
	Thread.AddActor(subject)
	Thread.SetAnimations(anims)
	Thread.StartThread()
	return true
EndFunction


bool Function Kisses(Actor kissyFace1, Actor kissyFace2, bool swallowAfter, bool endo)
{ Tells a pair of actors to play a kissing animation. }
	if !(kissyFace1 && kissyFace2 && Sexlab)
		if DEBUGGING
			assertNotNone(PREFIX, "onKisses", "kissyFace1", kissyFace1)
			assertNotNone(PREFIX, "onKisses", "kissyFace2", kissyFace2)
			assertNotNone(PREFIX, "Masturbate", "Sexlab", Sexlab)
		endIf
		return false
	endIf

	Log2(PREFIX, "Kisses", Namer(kissyFace1), Namer(kissyFace2))
	sslBaseAnimation[] anims = (Sexlab as SexLabFramework).GetAnimationsByTags(2, "kiss,kissing", "forced,aggressive,rape,M", false)

	if DEBUGGING
		LogStrings(PREFIX, "Kisses", "anims", makeNameArray(anims))
	endIf

	sslThreadModel Thread = (Sexlab as SexLabFramework).NewThread()
	Thread.AddActor(kissyFace1)
	Thread.AddActor(kissyFace2)
	Thread.SetNoStripping(kissyFace1)
	Thread.SetNoStripping(kissyFace2)
	Thread.SetAnimations(anims)
	
	if swallowAfter
		if endo
			Thread.SetHook("Endo")
		else
			Thread.SetHook("Vore")
		endIf
	endIf
	
	return Thread.StartThread() != none
EndFunction


Function Strip(Actor ActorRef)
{Adapted from sslActorAlias.psc in Sexlab 1.63beta8 by Ashal.}
	if !assertNotNone(PREFIX, "Strip", "ActorRef", ActorRef) \
	|| !assertTrue(PREFIX, "Strip", "ActorRef.hasKeyword(Manager.KeywordNPC)", ActorRef.hasKeyword(Manager.ActorTypeNPC))
		return
	endIf
	
	;Log1(PREFIX, "Strip", Namer(ActorRef))
	
	int baseSex = ActorRef.getLeveledActorBase().getSex()
	bool isFemale = baseSex != 0
	Debug.SendAnimationEvent(ActorRef, "Arrok_Undress_G"+BaseSex)

	Form ItemRef
	
	; Right hand
	ItemRef = ActorRef.GetEquippedObject(1)
	if Manager.IsStrippable(ItemRef)
		ActorRef.UnequipItemEX(ItemRef, 1, false)
	endIf
	
	; Left hand
	ItemRef = ActorRef.GetEquippedObject(0)
	if Manager.IsStrippable(ItemRef)
		ActorRef.UnequipItemEX(ItemRef, 2, false)
	endIf
	
	; Strip armor slots
	int i = 31
	while i >= 0
		; Grab item in slot
		ItemRef = ActorRef.GetWornForm(Armor.GetMaskForSlot(i + 30))
		if Manager.IsStrippable(ItemRef)
			ActorRef.UnequipItemEX(ItemRef, 0, false)
		endIf
		; Move to next slot
		i -= 1
	endWhile
endFunction


int Function SwallowArousal(Actor pred, Actor prey, bool endo)
	if !(SLA && Sexlab && pred && prey)
		return 0
	endIf

	slaFrameworkScr SLAF = SLA as slaFrameworkScr
	
	int gender = (Sexlab as SexlabFramework).GetGender(prey)
	int pref = SLAF.GetGenderPreference(pred)

	bool genderMatch = pref == 2 || (pref == 0 && gender == 0) || (pref == 1 && gender == 1)
	bool isLewd = (Sexlab as SexlabFramework).Stats.IsLewd(pred)
	bool lewdnessMatch = (isLewd && !endo) || (!isLewd && endo)

	if DEBUGGING
		Log7(PREFIX, "SwallowArousal", Namer(pred), Namer(prey), gender, pref, isLewd, genderMatch, lewdnessMatch)
	endIf

	if genderMatch && lewdnessMatch
		SLAF.UpdateActorExposure(pred, 10, "Vore sweet spot: 10 points of exposure.")
		return 10
	elseif genderMatch
		SLAF.UpdateActorExposure(pred, 4, "Gender match: 4 points of exposure.")
		return 4
	elseif lewdnessMatch
		SLAF.UpdateActorExposure(pred, 4, "Lewdness match: 4 points of exposure.")
		return 4
	else
		SLAF.UpdateActorExposure(pred, 1, "Double mismatch: 1 point of exposure.")
		return 1
	endIf
EndFunction


bool Function AccidentCheck(Actor pred)
	if !(SLA && pred)
		return false
	endIf

	int arousal = (SLA as slaFrameworkScr).GetActorArousal(pred)
	if Utility.RandomInt(0, 1000) < arousal
		Manager.SwitchLethalAll(pred, true)
		return true
	else
		return false
	endIf
EndFunction


;=================================================
; Convenience function.


DevourmentSexlab Function instance() global
{
Returns the DevourmentSexlab instance, for situations in which
a property isn't helpful (like global functions).
}
	return Quest.GetQuest("DevourmentManager").getAlias(0) as DevourmentSexlab
EndFunction


String[] Function makeNameArray(sslBaseAnimation[] anims)
{ Convert an animation array to form array. }
	String[] arr = Utility.createStringArray(anims.length)
	int i = anims.length
	while i
		i -= 1
		arr[i] = anims[i].getName()
	endWhile
	return arr
EndFunction