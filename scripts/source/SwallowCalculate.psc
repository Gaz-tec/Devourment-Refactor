Scriptname SwallowCalculate extends DevourmentAnimatedSpell
{
This is the script that is called for all vore operations.
It calculates the odds of success, disables the player's controls
if they are the prey, applies the swallow sound and visual
effects, and adds the spell/items that prevent either of them from
being swallowed.
}
import DevourmentUtil
import Logging


;Actor property playerRef auto
;DevourmentManager Property Manager Auto
DevourmentPlayerAlias property playerAlias auto
EffectShader Property SwallowShader	 Auto
Keyword Property BeingSwallowed Auto
Keyword Property KeywordSurrender auto
Message Property Message_Capacity Auto
Message Property Message_SheathWeapon Auto
Message Property Message_Trust Auto
Perk property SilentSwallow auto
Sound[] Property SwallowSounds Auto
Spell Property SwallowPreventSpell Auto
;int property Locus = -1 auto
Bool Property Scripted = false Auto
Bool Property Reversed = false Auto
;bool Property Endo = false Auto
;String property animationFinisher = "" auto


String PREFIX = "SwallowCalculate"
float updateInterval = 0.10


bool DEBUGGING = false
;Actor prey
;Actor pred
bool weaponDrawn
bool deadPrey
int timer = 0


Event OnEffectStart(Actor akTarget, Actor akCaster)
	if !(akTarget && akCaster)
		assertNotNone(PREFIX, "OnEffectStart", "akTarget", akTarget)
		assertNotNone(PREFIX, "OnEffectStart", "akCaster", akCaster)
		return
	endif

	if Manager.paused
		Dispel()
		return
	endIf
	
	if !Reversed
		prey = akTarget
		pred = akCaster
	else
		pred = akTarget
		prey = akCaster
	endif

	if !Manager.validPredator(pred)
		Return
	EndIf

	if DEBUGGING
		Log5(PREFIX, "OnEffectStart", Namer(pred), Namer(prey), endo, Reversed, Scripted)
	endIf

	if locus < 0
		locus = DecideLocus()
	endIf
	
	deadPrey = prey.IsDead()
	weaponDrawn = pred.isWeaponDrawn()

	if pred != playerRef && Manager.IsFull(pred) && !Scripted
		if DEBUGGING
			Log1(PREFIX, "OnEffectStart", Namer(pred) + " is full.")
		endIf
		dispel()
		return

	elseif endo && weaponDrawn && pred == playerRef && !Scripted && !Manager.drawnAnimations
		Manager.HelpAgnosticMessage(Message_SheathWeapon, "DVT_SHEATHE", 3.0, 0.1)
		dispel()
		return

	elseif endo && !scripted && !DEBUGGING && !Manager.endoAnyone && !Manager.areFriends(pred, prey)
		if pred == playerRef
			Manager.HelpAgnosticMessage(Message_Trust, "DVT_TRUST", 3.0, 0.1)
		EndIf
		dispel()
		return
	endIf
		
	;Manager.CacheVoreWeight(pred)
	;Manager.CacheVoreWeight(prey)

	if pred == PlayerRef && !DEBUGGING && !Manager.HasRoomForPrey(pred, prey) && !Scripted
		Manager.HelpAgnosticMessage(Message_Capacity, "DVT_FULL", 3.0, 0.1)
		Manager.PlayerFullnessMeter.ForceMeterDisplay(true)
		dispel()

	elseif scripted || reversed
		DoSwallow()
		DevourmentManager.SendSwallowAttemptEvent(pred, prey, endo, false, true, locus)
	
	elseif endo
		float swallowDifficulty = 1.0 - Manager.getEndoSwallowChance(pred, prey)
		float d100Roll = Utility.randomFloat()
		
		if d100Roll < swallowDifficulty
			if pred == playerRef
				Manager.HelpAgnosticMessage(Message_Trust, "DVT_TRUST", 3.0, 0.1)
				if DEBUGGING
					Log4(PREFIX, "OnEffectStart", Namer(pred), Namer(prey), "FAILURE", d100Roll + " < " + swallowDifficulty)
				endIf
				if Manager.Notifications
					ConsoleUtil.PrintMessage("Endo failed: " + (d100Roll * 100.0) + " < " + (swallowDifficulty * 100.0) + "%")
				endIf
			EndIf

			DevourmentManager.SendSwallowAttemptEvent(pred, prey, endo, false, false, locus)
			dispel()
		else
			DoSwallow()
			DevourmentManager.SendSwallowAttemptEvent(pred, prey, endo, false, true, locus)
		endIf
	
	else
		bool stealth = pred.isSneaking() && !pred.isDetectedBy(prey)
		bool silent = stealth && pred.hasPerk(SilentSwallow)
		float swallowDifficulty = 1.0 - Manager.getVoreSwallowChance(pred, prey, stealth)

		if silent
			prey.stopcombat()
			prey.setalert(false)
		elseif deadPrey && pred == playerRef
			prey.SendStealAlarm(pred)
		endIf

		float d100Roll = Utility.randomFloat()
		if d100Roll >= swallowDifficulty
			DoSwallow()
			DevourmentManager.SendSwallowAttemptEvent(pred, prey, endo, stealth, true, locus)
			SwallowNotification(d100Roll, swallowDifficulty, success=true)

		else
			DevourmentManager.SendSwallowAttemptEvent(pred, prey, endo, stealth, false, locus)
			SwallowNotification(d100Roll, swallowDifficulty, success=false)

			if Manager.Menu.CounterVoreEnabled && prey.HasPerk(Manager.Menu.CounterVore)
				swallowDifficulty = 1.0 - Manager.getVoreSwallowChance(prey, pred, false)
				d100Roll = Utility.randomFloat()

				if d100Roll >= swallowDifficulty
					reversed = true
					pred = akTarget
					prey = akCaster
					DoSwallow()
					SwallowNotification(d100Roll, swallowDifficulty, success=true, counter=true)
					DevourmentManager.SendSwallowAttemptEvent(pred, prey, endo, stealth, true, locus)
				else
					SwallowNotification(d100Roll, swallowDifficulty, success=false, counter=true)
					dispel()
				endIf
			else
				dispel()
			endIf
		endif
	endif
endEvent


Function DoSwallow()
	if Reversed
		If pred == PlayerRef
			Manager.HelpAgnosticMessage(Manager.Messages_Retrovore[locus], "DVT_RETROVORE", 10.0, 0.1)
		ElseIf prey == PlayerRef
			Manager.notify(pred.GetDisplayName() + " is trying to force their way into your body!")
		EndIf
	endIf

	pred.addSpell(SwallowPreventSpell, false)
	prey.addSpell(SwallowPreventSpell, false)
	;Utility.SetIniFloat("fActorFadeOutLimit:Camera", 0.0)

	; If the player is being swallowed, stop the pred from attacking and disable the player.
	if prey == playerRef
		pred.stopCombat()
		Utility.wait(0.01)
		Manager.deactivatePrey(prey)

	; If the player is endoing, stop the prey from attacking and switch the camera to them. Didn't I disable this?
	elseif pred == playerRef && endo
		prey.stopCombat()
		PlayerAlias.setCameraTarget(prey)

	; If the swallowing doesn't involve the player, do a camera check. If the prey is the player's predator, this will switch the camera.
	else
		PlayerAlias.CameraAndControlCheck(pred, prey, endo)
	endif

	; Disable the prey's ability to move and attack and whatnot.
	; Calling SetRestrained on a dead NPC will resurrect them!
	;
	if prey != playerRef && !deadPrey
		prey.setRestrained(true)
	endIf

	; This is where we do animation stuff.
	if pred.is3DLoaded()
		if Reversed
			prey.SplineTranslateTo(pred.GetPositionX(), pred.GetPositionY(), pred.GetPositionZ(), 0.0, 0.0, prey.GetAngleZ(), 1.0, 500.0)
			prey.pushActorAway(pred, 0.3)
		elseif weaponDrawn 
			if Manager.drawnAnimations
				pred.sheatheWeapon()
				Utility.wait(0.3)
				DoAnimatedVore()
			endIf
		else
			DoAnimatedVore()
		endif
	endIf
	
	if !endo && !deadPrey && pred == playerRef && !StorageUtil.HasIntValue(prey, "voreConsent") && !prey.HasKeyword(KeywordSurrender)
		prey.SendAssaultAlarm()
	endIf

	if endo
		SwallowShader.play(prey, 0.1)
		Utility.Wait(1.0)
		SwallowSounds[locus].play(pred)
		Utility.Wait(0.5)
	else
		SwallowShader.play(prey, 0.1)
		SwallowSounds[locus].play(pred)
	endIf

	; A lot of vore is done in combat so the pred may have died since the effect started.
	; If that is the case, this effect has to cleanup after itself nicely.
	if pred.isDead()
		Log3(PREFIX, "FinishSwallow", Namer(pred), Namer(prey), "Dead pred!")
		Manager.reactivatePrey(prey)
		SwallowShader.stop(prey)

		; If the camera got switched to the player's pred (and they're dead now), switch it back to the player.
		if prey == playerRef && playerAlias.isCameraTarget(pred)
			playerAlias.setCameraTarget(playerRef)
		endIf

	else
		; If the camera got switched to the player's prey, switch it back to the player.
		if pred == playerRef && playerAlias.isCameraTarget(prey)
			playerAlias.setCameraTarget(playerRef)
		endif

		SwallowShader.stop(prey)
		Manager.RegisterDigestion(pred, prey, endo, locus)
		
		if weaponDrawn && !endo && pred == playerRef && !pred.hasKeyword(BeingSwallowed)
			pred.drawWeapon()
		endif
	endif

	pred.removeSpell(SwallowPreventSpell)
	prey.removeSpell(SwallowPreventSpell)
	;Dispel()
EndFunction


int Function DecideLocus()
	if pred == playerRef || (prey == playerRef && reversed)
		int deflocus = PlayerAlias.DefaultLocus
		if deflocus < 0
			return RandomLocus()
		else
			return deflocus
		endIf
	elseif !pred.HasKeyword(Manager.ActorTypeNPC)
		return 0
	else
		return RandomLocus()
	endIf
endFunction


int Function RandomLocus()
	bool isFemale = Manager.IsFemale(pred) 
	bool DualBreastMode = Manager.Menu.Morphs.UseDualBreastMode	;WTF...
	Form SoSAPI = Quest.GetQuest("SOS_Misc") 
	bool hasCock = false
	If SoSAPI
		hasCock = ((SoSAPI as Form) as SOS_API).IsSchlonged(pred)
	EndIf
	float[] cumulative = Manager.Menu.LocusCumulative
	float chance = Utility.RandomFloat(0.0, cumulative[0])
	int loc = cumulative.length

	while loc
		loc -= 1
		if chance < cumulative[loc]
			if (hasCock && loc == 5) || (!isFemale && loc != 2 && loc != 3)
				if loc == 3 && DualBreastMode	;Alternate the breasts..
					if StorageUtil.PluckIntValue(pred, "DevourmentBreastVoreL", missing = 0)
						loc = 4
					Else
						StorageUtil.SetIntValue(pred, "DevourmentBreastVoreL", 1)
					endif
				endIf
				return loc
			else
				return 0
			endIf
		endIf
	endWhile

	return 0
EndFunction


Function SwallowNotification(float d100Roll, float swallowDifficulty, bool success, bool counter = false)
	if DEBUGGING
		if counter
			Log3(PREFIX, "SwallowNotification", Namer(pred), Namer(prey), "COUNTERVORE")
		endIf

		if success
			Log4(PREFIX, "SwallowNotification", Namer(pred), Namer(prey), "SUCCESS", d100Roll + " < " + swallowDifficulty)
		else
			Log4(PREFIX, "SwallowNotification", Namer(pred), Namer(prey), "FAILURE", d100Roll + " < " + swallowDifficulty)
		endIf
	endIf

	if Manager.Notifications
		if counter
			if success
				ConsoleUtil.PrintMessage("Countervore attack by " + Namer(pred, true) + " succeeded against " + Namer(prey, true) + ": " + (d100Roll * 100.0) + " > " + (swallowDifficulty * 100.0) + "%")
			else
				ConsoleUtil.PrintMessage("Countervore attack by " + Namer(pred, true) + " failed against " + Namer(prey, true) + ": " + (d100Roll * 100.0) + " > " + (swallowDifficulty * 100.0) + "%")
			endIf
		else
			if success
				ConsoleUtil.PrintMessage("Vore attack by " + Namer(pred, true) + " succeeded against " + Namer(prey, true) + ": " + (d100Roll * 100.0) + " > " + (swallowDifficulty * 100.0) + "%")
			else
				ConsoleUtil.PrintMessage("Vore attack by " + Namer(pred, true) + " failed against " + Namer(prey, true) + ": " + (d100Roll * 100.0) + " > " + (swallowDifficulty * 100.0) + "%")
			endIf
		endIf
	endIf
EndFunction
