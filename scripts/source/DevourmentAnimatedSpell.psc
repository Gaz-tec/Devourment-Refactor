Scriptname DevourmentAnimatedSpell extends ActiveMagicEffect
{
AUTHOR: Gaz
PURPOSE: Provides functions for deciding and executing vore animations.
Intended to be extended by spells where needed. Does not handle FX beyond animation.
TODO: Node Scaling systems.
}

DevourmentManager Property Manager Auto
Actor Property PlayerRef Auto
Int property Locus = -1 Auto
Bool Property Endo = false Auto
Bool Property PreferLongAnimation = False Auto
Bool Property ProtectActors = True Auto
Actor Property Prey Auto
Actor Property Pred Auto 

Bool PredWasEssential = False
Bool PreyWasEssential = False
Bool PredWasProtected = False
Bool PreyWasProtected = False
Bool ReversedAngle = False
String PreyAnim = ""
String PredAnim = ""
String AnimationFinisher = ""
Float AnimationFinisherDelay = 0.0
Float PreyOffset = 1.0
Float AnimLength = 0.0
Float MouthOpenStart = 0.0
Float MouthOpenTimer = 0.0

Bool Function DoAnimatedVore()
{ Intended to be a latent function, only returning after the animation has fully run. 
 Prey, Pred, Consent, Locus & Endo must be set before calling. 
 Setting Short/Long animation preference is optional. }

    If DecideAnim() && Pred.Is3DLoaded()

			ActorBase PredActorBase
			ActorBase PreyActorBase
			If ProtectActors
				PredWasEssential = Pred.IsEssential()
				PreyWasEssential = Prey.IsEssential()
				PredActorBase = Pred.GetActorBase()
				PreyActorBase = Prey.GetActorBase()
				PredWasProtected = PredActorBase.IsProtected()
				PreyWasProtected = PreyActorBase.IsProtected()
				PredActorBase.SetEssential(True)
				PreyActorBase.SetEssential(True)
			EndIf

			If Pred != PlayerRef
				Debug.SendAnimationEvent(Pred, "Reset")
				Pred.SetDontMove(true)
				Pred.StopCombat()
				Pred.StopTranslation()
				Pred.EnableAI(false)
				Pred.SetRestrained()
			EndIf

			float angleX = Pred.GetAngleX()
			float angleY = Pred.GetAngleY()
			float angleZ = Pred.GetAngleZ()
			float posX = Pred.GetPositionX()
			float posY = Pred.GetPositionY()
			float posZ = Pred.GetPositionZ()

			ObjectReference PredMarker = Pred.PlaceAtMe(Manager.AnimationMarker, 1, false, false)
			PredMarker.SetPosition(posX, posY, posZ)
			PredMarker.SetAngle(angleX, angleY, angleZ)

			ObjectReference PreyMarker = Pred.PlaceAtMe(Manager.AnimationMarker, 1, false, false)
			PreyMarker.SetPosition(posX + preyOffset*Math.Sin(angleZ), posY + preyOffset*Math.Cos(angleZ), posZ)
			If !ReversedAngle
				PreyMarker.SetAngle(angleX+180.0, angleY+180.0, angleZ+180.0)
			Else
				PreyMarker.SetAngle(angleX, angleY, angleZ)
			EndIf
			
			If Prey != PlayerRef
				Prey.SetDontMove(true)
				Prey.StopCombat()
				Prey.StopTranslation()
				Prey.EnableAI(false)
				Prey.SetRestrained()
			Else
				Game.ForceThirdPerson()
			EndIf

			Pred.MoveTo(PredMarker)
			Pred.SetVehicle(PredMarker)

			Prey.MoveTo(PreyMarker)
			Prey.SetVehicle(PreyMarker)

			Pred.EnableAI(true)
			Prey.EnableAI(true)
			Utility.Wait(0.7)
			Debug.SendAnimationEvent(Prey, PreyAnim)
			Debug.SendAnimationEvent(Pred, PredAnim)

			If AnimationFinisherDelay != 0.0
				RegisterForSingleUpdate(AnimationFinisherDelay)
			EndIf
			If MouthOpenStart != 0.0
				Utility.Wait(MouthOpenStart)
				OpenMouth()
				Utility.Wait(MouthOpenTimer)
				CloseMouth()
				Utility.Wait(AnimLength - (MouthOpenStart + MouthOpenTimer))
			Else
				Utility.Wait(AnimLength)
			EndIf
			
			If ProtectActors
				If !PredWasEssential && !PredWasProtected
					PredActorBase.SetEssential(False)
				ElseIf !PredWasEssential && PredWasProtected
					PredActorBase.SetEssential(False)
					PredActorBase.SetProtected(True)
				EndIf

				If !PreyWasEssential && !PreyWasProtected
					PreyActorBase.SetEssential(False)
				ElseIf !PreyWasEssential && PreyWasProtected
					PreyActorBase.SetEssential(False)
					PreyActorBase.SetProtected(True)
				EndIf
			EndIf

			Pred.SetVehicle(None)
			Prey.SetVehicle(None)
			Return True
	
	Else
		Return False
    EndIf
EndFunction

Bool Function DecideAnim()
{ Populates this scripts' variables and decides on a suitable animation, if any. }

    ;Note, because of the nature of this function, it will need adjustment anytime animations are sufficiently changed.
    Bool FNISDetected = Manager.FNISDetected
    DevourmentRemap Remapper = (Manager as Quest) as DevourmentRemap
    bool isConsented = StorageUtil.HasIntValue(prey, "voreConsent")
	Bool isPreyNPC = Prey.HasKeywordString("ActorTypeNPC")

	If Pred.hasKeywordString("ActorTypeDragon")
		If Pred.GetAnimationVariableInt("DevourmentDragonAnimationVersion") > 0 && Manager.DragonVoreAnimation && isPreyNPC
			If !Prey.IsDead()
				ReversedAngle = True
				PreyOffset = 20.0
				If isConsented
					If PreferLongAnimation
						PredAnim = "DevourmentDragon_FeetFirstLong_DragonPredator"
						PreyAnim = "DevourmentDragon_FeetFirstLong_HumanPrey"
						AnimLength = 21.5	;Anim is 645 frames long.
					Else
						PredAnim = "DevourmentDragon_FeetFirstShort_DragonPredator"
						PreyAnim = "DevourmentDragon_FeetFirstShort_HumanPrey"
						AnimLength = 9.0	;Anim is 270 frames long.
					EndIf
				Else
					If PreferLongAnimation
						PredAnim = "DevourmentDragon_HeadFirstLong_DragonPredator"
						PreyAnim = "DevourmentDragon_HeadFirstLong_HumanPrey"
						AnimLength = 19.3	;Anim is 580 frames long.
					Else
						PredAnim = "DevourmentDragon_HeadFirstShort_DragonPredator"
						PreyAnim = "DevourmentDragon_HeadFirstShort_HumanPrey"
						AnimLength = 9.7	;Anim is 290 frames long.
					EndIf
				EndIf
				Return True
			EndIF
		EndIf
	ElseIf Game.GetForm(0x000131EE) == remapper.RemapRace(pred.GetLeveledActorBase().GetRace()) || \
		Game.GetForm(0x0001320A) == remapper.RemapRace(pred.GetLeveledActorBase().GetRace())	;Dog + Wolf
    	If Pred.GetAnimationVariableInt("DevourmentCanineAnimationVersion") > 0 && isPreyNPC
			If !Prey.IsDead()
				If isConsented
					PreyOffset = 160.17
					PredAnim = "DevourmentCanine_CaninePredator"
					PreyAnim = "DevourmentCanine_HumanPrey"
					AnimLength = 26.0
				EndIf
				Return True
			EndIf
		EndIf
    ElseIf Pred.HasKeywordString("ActorTypeNPC")
        if !FNISDetected
			PredAnim = "IdleHug"
			PreyAnim = "IdleCowerEnter"
			AnimLength = 0.5
		else
			if prey.isDead() ; Corpse Vore
				PredAnim = "IdleCannibalFeedCrouching"
				AnimLength = 0.45
			elseif prey.GetSleepState() > 2 ; Sleeping Vore
				PredAnim = "IdleCannibalFeedStanding"
				AnimLength = 0.45
			elseif Manager.GetVoreWeightRatio(pred, prey) > 0.125 && isPreyNPC ; Giant Vore
				;Beast races have different mouth alignments and tails, so must be different.
				Bool IsPredBeastRace = pred.hasKeywordString("IsBeastRace")
				ReversedAngle = True
				PreyOffset = 25.0
				If IsPredBeastRace
					If PreferLongAnimation
						PredAnim = "DevourmentMacroBeast_Long_BeastPredator"
						PreyAnim = "DevourmentMacroBeast_Long_HumanPrey"
						AnimLength = 12.0	;Anim is 360 frames long.
						MouthOpenStart = 2.7 	;Prey near mouth at frame 80.
						MouthOpenTimer = 7.3	;Prey at base of neck at frame 300.
					Else
						PredAnim = "DevourmentMacroBeast_Short_BeastPredator"
						PreyAnim = "DevourmentMacroBeast_Short_HumanPrey"
						AnimLength = 5.0	;Anim is 180 frames long. Reduced timer for brevity.
						MouthOpenStart = 1.3 	;Prey near mouth at frame 40.
						MouthOpenTimer = 3.7	;Prey at base of neck at frame 150.
					EndIf
				Else
					If PreferLongAnimation
						PredAnim = "DevourmentMacroHuman_Long_HumanPredator"
						PreyAnim = "DevourmentMacroHuman_Long_HumanPrey"
						AnimLength = 12.0	;Anim is 360 frames long.
						MouthOpenStart = 2.7 	;Prey near mouth at frame 80.
						MouthOpenTimer = 7.3	;Prey at base of neck at frame 300.
					Else
						PredAnim = "DevourmentMacroHuman_Short_HumanPredator"
						PreyAnim = "DevourmentMacroHuman_Short_HumanPrey"
						AnimLength = 5.0	;Anim is 180 frames long. Reduced timer for brevity.
						MouthOpenStart = 1.3 	;Prey near mouth at frame 40.
						MouthOpenTimer = 3.7	;Prey at base of neck at frame 150.
					EndIf
				EndIf
				Return True

			elseif endo
				if locus == 1 ; AnalVore (endo)
					PredAnim = "IdleChairFrontEnter"
					PreyAnim = "IdleCowerEnter"
					AnimLength = 1.2
					AnimationFinisher = "IdleChairFrontQuickExit"
					AnimationFinisherDelay = 1.0
				elseif locus == 5 ; CockVore (endo)
					PredAnim = "AP_IdleStand_A2_S3"
					PreyAnim = "AP_KneelBlowjob_A1_S1"
					AnimLength = 1.2
				else
					Return False
					pred.PlayIdleWithTarget(Manager.IdleVore, prey)
				endIf
				Return True
			else
				if locus == 0 ; OralVore
					PreyOffset = 30.0
					PredAnim = "DevourmentSameSize_HumanPredator"
					;Debug.SendAnimationEvent(prey, "DevourA02")
					PreyAnim = "IdleCowerEnter"
					AnimLength = 4.3
				elseif locus == 1 ; AnalVore
					PredAnim = "IdleChairFrontEnter"
					PreyAnim = "IdleCowerEnter"
					AnimLength = 1.65
					AnimationFinisher = "IdleChairFrontQuickExit"
					AnimationFinisherDelay = 1.5
				else
					PredAnim = "IdleHug"
					PreyAnim = "IdleCowerEnter"
				endIf
				Return True
			endIf
		endif

	ElseIf Game.GetForm(0x000131FF) == remapper.RemapRace(pred.GetLeveledActorBase().GetRace())	;Mammoth
   		If Manager.MammothVoreAnimation && isPreyNPC && \
			pred.GetAnimationVariableInt("DevourmentMammothAnimationVersion") > 0
			If !Prey.IsDead()
				ReversedAngle = True
				PreyOffset = 39.0
				If PreferLongAnimation
					PredAnim = "DevourmentMammoth_Long_MammothPredator"
					PreyAnim = "DevourmentMammoth_Long_HumanPrey"
					AnimLength = 10.15	;Anim is 335 frames long. Shortened timer.
				Else
					PredAnim = "DevourmentMammoth_Short_MammothPredator"
					PreyAnim = "DevourmentMammoth_Short_HumanPrey"
					AnimLength = 5.3	;Anim is 190 frames long. Shortened timer.
				EndIf
				Return True
			EndIf
		EndIf

	ElseIf Game.GetForm(0x000CDD84) == remapper.RemapRace(pred.GetLeveledActorBase().GetRace())	;Werewolf
		If pred.GetAnimationVariableInt("DevourmentWerewolfAnimationVersion") > 0
			If prey.GetAnimationVariableInt("DevourmentBunnyAnimationVersion") > 0
				If !Prey.IsDead()
					If PreferLongAnimation
						PredAnim = "DevourmentWerewolf_Long_WerewolfPredator"
						PreyAnim = "DevourmentWerewolf_Long_BunnyPrey"
						AnimLength = 11.00	;Anim is 330 frames long.
					Else
						PredAnim = "DevourmentWerewolf_Short_WerewolfPredator"
						PreyAnim = "DevourmentWerewolf_Short_BunnyPrey"
						AnimLength = 6.7	;Anim is 200 frames long.
					EndIf
					Return True
				EndIF
			EndIf
		EndIf
	Else
		Return False
    EndIf
EndFunction

Event OnUpdate()
	if AnimationFinisher != ""
		Debug.SendAnimationEvent(pred, AnimationFinisher)
	endIf
EndEvent

Function OpenMouth() ;Mouth functions taken from Vicyntae's SCV mod.
	ClearPhoneme()
	Pred.SetExpressionOverride(16, 80)
	MfgConsoleFunc.SetPhonemeModifier(Pred, 0, 1, 60)
endFunction

function CloseMouth()
	Pred.SetExpressionOverride(7, 50)
	MfgConsoleFunc.SetPhonemeModifier(Pred, 0, 1, 0)
endFunction

function ClearPhoneme()
	int i
	while i <= 15
		MfgConsoleFunc.SetPhonemeModifier(Pred, 0, i, 0)
		i += 1
	endWhile
endFunction

;/
			if IsPlayer && Config.AutoTFC
				MiscUtil.SetFreeCameraState(true)
				MiscUtil.SetFreeCameraSpeed(Config.AutoSUCSM)
			endIf
			/;