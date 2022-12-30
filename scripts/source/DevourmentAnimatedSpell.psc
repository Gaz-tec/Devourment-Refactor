Scriptname DevourmentAnimatedSpell extends ActiveMagicEffect
{
AUTHOR: Gaz
PURPOSE: Provides functions for deciding and executing vore animations.
Intended to be extended by spells where needed. Does not handle FX beyond animation.
TODO: Node Scaling systems.
}

import Devourment_JCDomain

DevourmentManager Property Manager Auto
Actor Property PlayerRef Auto
Int property Locus = -1 Auto
Bool Property Endo = false Auto
Bool Property PreferlongAnimation = False Auto
Bool Property ProtectActors = True Auto
Actor Property Prey Auto
Actor Property Pred Auto
FormList Property DevourmentPairedIdles Auto

Idle PairedAnimation
Bool PredWasEssential = False
Bool PreyWasEssential = False
Bool PredWasProtected = False
Bool PreyWasProtected = False
Bool ReversedAngle = False
Int AnimIndex = 0
String AnimationFinisher = ""
Float AnimationFinisherDelay = 0.0
Float PreyOffset = 1.0
Float AnimLength = 0.0
Float MouthOpenStart = 0.0
Float MouthOpenTimer = 0.0

Bool doScaling = False
Bool isFemale
Int scaleInterps ; TODO - make this an MCM configurable?
Int animationScales ; JArray holds all scaling events
Int numScales ; Total number of scaling events
Int scaleFrame = 0; Scaling iterator
Float lagFactor ; From profiling, the lag appears to be approximately 10% of the time submitted.

Int Function DoAnimatedVore()
{ Intended to be a latent function, only returning after the animation has fully run. 
  Prey, Pred, Consent, Locus & Endo must be set before calling. 
  Setting Short/long animation preference is optional. 
  47 - Modified to return an int code:
  0 for no animation found, 1 for animation executed successfully,
  2 for animation failed to execute.
  Note: Animations can "succeed", yet fail to play. Need to nail this down.}

    If DecideAnim() && Pred.Is3DLoaded()

		If doScaling
			numScales = JArray_Count(animationScales)
			isFemale = prey.GetActorBase().GetSex()==1
		EndIf

		; What are these for..... Commenting for now as they add significant delay.
		;ActorBase PredActorBase
		;ActorBase PreyActorBase
		;If ProtectActors
		;	PredWasEssential = Pred.IsEssential()
		;	PreyWasEssential = Prey.IsEssential()
		;	PredActorBase = Pred.GetActorBase()
		;	PreyActorBase = Prey.GetActorBase()
		;	PredWasProtected = PredActorBase.IsProtected()
		;	PreyWasProtected = PreyActorBase.IsProtected()
		;	PredActorBase.SetEssential(True)
		;	PreyActorBase.SetEssential(True)
		;EndIf

		if Pred.IsFlying()  ; Flying animations bad - specifically for dragons
			;ConsoleUtil.PrintMessage("Pred is Flying")
			return 2
		endIf

		; We could use a JContainers Formarray for this, but for now a hardcoded FormList will do.
		PairedAnimation = DevourmentPairedIdles.GetAt(AnimIndex) as Idle

		; Unfortunately, this does not catch all the errors.
		; I still get the occasional animation that 'succeeds' but doesn't actually play.
		; However, this should just play out as normal even if this happens.
		if !Pred.PlayIdleWithTarget(PairedAnimation, Prey)  
			;ConsoleUtil.PrintMessage("Animation Failed")
			return 2
		endIf

		If doScaling ; For now, these are incompatible
			RegisterForSingleUpdate(JArray_getFlt(JArray_getObj(animationScales,scaleFrame),1)*lagFactor)
		ElseIf AnimationFinisherDelay != 0.0
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
		
		;If ProtectActors
		;	If !PredWasEssential && !PredWasProtected
		;		PredActorBase.SetEssential(False)
		;	ElseIf !PredWasEssential && PredWasProtected
		;		PredActorBase.SetEssential(False)
		;		PredActorBase.SetProtected(True)
		;	EndIf

		;	If !PreyWasEssential && !PreyWasProtected
		;		PreyActorBase.SetEssential(False)
		;	ElseIf !PreyWasEssential && PreyWasProtected
		;		PreyActorBase.SetEssential(False)
		;		PreyActorBase.SetProtected(True)
		;	EndIf
		;EndIf

		Return 1
	
	Else
		Return 0
    EndIf
EndFunction

Int Function GetAnimationData()
{ Retrieves the animation info database, and If not cached, caches it. }
	int info = jdb_solveObj(".dvtPairedAnimData")
	If !info
		info = jvalue_readFromFile("Data/dvtPairedAnimData.json")
		jdb_setObj("dvtPairedAnimData", info)
	EndIf
	return info
EndFunction

Bool Function DecideAnim()
{ Populates this scripts' variables and decides on a suitable animation, if any. }
	; 27/11/22 Reworked to support paired anims.
	Int dvtAnimDB = GetAnimationData()
	String query = AnimQueryBuilder()

	; Edge Cases
	If query=="human.endo"
		pred.PlayIdleWithTarget(Manager.IdleVore, prey)
		return False
	EndIf

	Int animData = jmap_GetObj(dvtAnimDB, query)
	If animData == 0
		return False
	EndIf
	
	AnimIndex = jmap_getInt(animData, "animindex")
	AnimLength = jmap_getFlt(animData, "animlength")
	PreyOffset = jmap_getFlt(animData, "preyoffset")
	ReversedAngle = jmap_getInt(animData, "reversedangle") == 1
	MouthOpenStart = jmap_getFlt(animData, "mouthopenstart")
	MouthOpenTimer = jmap_getFlt(animData, "mouthopentimer")
	AnimationFinisher = jmap_getStr(animData, "animationfinisher")
	AnimationFinisherDelay = jmap_getFlt(animData, "animationfinisherdelay")
	animationScales = jmap_getObj(animData, "scales")

	ConsoleUtil.PrintMessage("dvtAnimData: "+dvtAnimDB+", AnimIndex: "+AnimIndex)

	; We need to do this in order to change the OnUpdate function from "AnimationFinisher" to "Scaling"
	If animationScales != 0
		If AnimationFinisher == ""
			ConsoleUtil.PrintMessage("We are doing Scaling")
			doScaling = True
			scaleInterps = jmap_getInt(dvtAnimDB, "scaleinterps")
			lagFactor = jmap_getFlt(dvtAnimDB, "lagfactor")
			ConsoleUtil.PrintMessage(lagFactor)
			jvalue_retain(animationScales, "dvtAnimScales")
			GoToState("Scaling")
		Else
			ConsoleUtil.PrintMessage("Scaling and AnimationFinisher not compatible!")
		EndIf
	EndIf

	return True
EndFunction

String Function AnimQueryBuilder()
{ Builds a query string to retrieve data from JSON dvtAnimationData }
	Bool FNISDetected = Manager.FNISDetected
	DevourmentRemap Remapper = (Manager as Quest) as DevourmentRemap
	bool isConsented = StorageUtil.HasIntValue(prey, "voreConsent")
	Bool isPreyNPC = Prey.HasKeywordString("ActorTypeNPC")
	Int predRace = remapper.RemapRace(pred.GetLeveledActorBase().GetRace()).GetFormID() ; Only run this once and use decimal races
	Int preyRace = remapper.RemapRace(prey.GetLeveledActorBase().GetRace()).GetFormID() ; Only run this once and use decimal races

	String query = ""

	If Pred.hasKeywordString("ActorTypeDragon")
		If Pred.GetAnimationVariableInt("DevourmentDragonAnimationVersion") > 0 && Manager.DragonVoreAnimation && isPreyNPC
			If !Prey.IsDead()
				query += "dragon.human"
				If isConsented
					query += ".con"
				ElseIf locus==1
					query += ".anal"
				ElseIf locus==2
					query += ".unbirth"
				EndIf
				If Utility.RandomFloat() > 0.75 ;PreferlongAnimation && 
					query += ".long"
				EndIf
				Return query
			EndIF
		EndIf
	ElseIf predRace == 78318 ;Dog
   	 	If Pred.GetAnimationVariableInt("DevourmentCanineAnimationVersion") > 0
			query += "dog"
			If isPreyNPC
				If !Prey.IsDead()
					If isConsented
						query += ".human"
					EndIf
				EndIf
			ElseIf preyRace == 78318
				If !Prey.IsDead()
					query += ".dog"
				EndIf
			EndIf
			Return query
		EndIf
	ElseIf predRace == 78346 ;Wolf
    		If Pred.GetAnimationVariableInt("DevourmentCanineAnimationVersion") > 0
			query += "wolf"
			If isPreyNPC
				If !Prey.IsDead()
					;If isConsented
						query += ".human"
					;EndIf
				EndIf
			ElseIf preyRace == 78346
				If !Prey.IsDead()
					query += ".wolf"
				EndIf
			EndIf
			Return query
		EndIf
	ElseIf Pred.HasKeywordString("ActorTypeNPC")
		If !FNISDetected
			query += "human.nofnis"
			Return query
		Else
			If prey.isDead() ; Corpse Vore
				query += "human.corpse"
				Return query
			ElseIf prey.GetSleepState() > 2 ; Sleeping Vore
				query += "human.sleep"
				Return query
			ElseIf Manager.GetVoreWeightRatio(pred, prey) > 0.125 && isPreyNPC ; giant Vore
				;beast races have different mouth alignments and tails, so must be different.
				query += "giant.human"
				If pred.hasKeywordString("IsBeastRace")
					query += ".beast"
				EndIf
				If Utility.RandomFloat() > 0.75 ;PreferlongAnimation && 
					query += ".long" ;Prey near mouth at frame 80. Prey at base of neck at frame 300.
					;SHORT - Prey near mouth at frame 40. Prey at base of neck at frame 150.
				EndIf
				Return query
			EndIf
			query += "human" ; Must be a vanilla human anim
			If endo ; Add Endo check
				query += ".endo"
			EndIf
			If locus == 0 ; OralVore
				query += ".oral"
			ElseIf locus == 1 ; AnalVore
				query += ".anal"
			ElseIf locus == 5 ; CockVore
				query += ".cock"
			EndIf
			Return query
		EndIf
	ElseIf predRace == 78335 ;Mammoth
   		If Manager.MammothVoreAnimation && isPreyNPC && \
			pred.GetAnimationVariableInt("DevourmentMammothAnimationVersion") > 0
			If !Prey.IsDead()
				query += "mammoth.human"
				If Utility.RandomFloat() > 0.75 ;PreferlongAnimation && 
					query += ".long"
				EndIf
				Return query
			EndIf
		EndIf
	ElseIf predRace == 843140 ;Werewolf
		If pred.GetAnimationVariableInt("DevourmentWerewolfAnimationVersion") > 0
			If prey.GetAnimationVariableInt("DevourmentBunnyAnimationVersion") > 0
				If !Prey.IsDead()
					query += "werewolf.bunny"
					If Utility.RandomFloat() > 0.75 ;PreferlongAnimation &&
						query += ".long"
					EndIf
					Return query
				EndIF
			EndIf
		EndIf
	Else
		Return query
    EndIf
EndFunction

Event OnUpdate()
	If AnimationFinisher != ""
		Debug.SendAnimationEvent(pred, AnimationFinisher)
	EndIf
EndEvent

Function OpenMouth() ;Mouth functions taken from Vicyntae's SCV mod.
	ClearPhoneme()
	Pred.SetExpressionOverride(16, 80)
	MfgConsoleFunc.SetPhonemeModifier(Pred, 0, 1, 60)
EndFunction

function CloseMouth()
	Pred.SetExpressionOverride(7, 50)
	MfgConsoleFunc.SetPhonemeModifier(Pred, 0, 1, 0)
EndFunction

function ClearPhoneme()
	int i
	while i <= 15
		MfgConsoleFunc.SetPhonemeModifier(Pred, 0, i, 0)
		i += 1
	EndWhile
EndFunction

;/
			If IsPlayer && Config.AutoTFC
				MiscUtil.SetFreeCameraState(true)
				MiscUtil.SetFreeCameraSpeed(Config.AutoSUCSM)
			EndIf
			/;

State Scaling
	; The active scaling event. Incompatible with AnimationFinisher!
	Event OnUpdate()
		;Debug.StartStackProfiling()
		
		Int localScaleFrame = scaleFrame
		scaleFrame += 1
		If scaleFrame < numScales
			; Time for next Frame
			RegisterForSingleUpdate(jarray_getFlt(jarray_getObj(animationScales,localScaleFrame + 1),1)*lagFactor)
		Else
			; Begin ending sequence
			GoToState("EndScaling")
			RegisterForSingleUpdate(1.0) ; Temporary Measure - eventually I'll add a JSON entry for this, but this will do.
		EndIf
		; 47 Notes - This is Incredibly Cumbersome (tm). I don't think it's slow - JContainers is v. fast
		; but it doesn't stop this code from being ugly and difficult to read. There must be a better way to do this.
		Int boneData = jarray_getObj(animationScales,localScaleFrame)
		Bool counter = jarray_getStr(boneData, 0) == "Counter"
		If !counter ; Regular Scaling - Simply loop through bones and scale linearly
			Int bones = jarray_getObj(boneData,2)
			Int numBones = jarray_Count(bones)
			Int startScales = jarray_getObj(boneData,3)
			Int deltaScales = jarray_getObj(boneData,5)
			Int subFrameIterator = 0
			Int boneIterator = 0
			While (subFrameIterator < scaleInterps)
				boneIterator = numBones
				While (boneIterator > 0)
					boneIterator -= 1
					String currentBone = jarray_getStr(bones,boneIterator)
					Float currentScale = jarray_getFlt(startScales,boneIterator) + subFrameIterator*jarray_getFlt(deltaScales,boneIterator)/scaleInterps
					NiOverride.AddNodeTransformScale(prey, False, isFemale, currentBone, "DevourmentAnimScale", currentScale)
					NiOverride.UpdateNodeTransform(prey, False, isFemale, currentBone)
				EndWhile
				subFrameIterator += 1
			EndWhile
		Else ; CounterScaling - Loop through parents and scale linearly, then loop through children and scale inversely
			Int parentBones = jarray_getObj(boneData,2)
			Int childBones = jarray_getObj(boneData,3)
			Int parentScales = jarray_getObj(boneData,4)
			Int parentDeltas = jarray_getObj(boneData,6)
			Int childScales = jarray_getObj(boneData,7)
			Int childFinalScales = jarray_getObj(boneData, 8)
			Int subFrameIterator = 0
			Int parentBoneIterator
			Int childBoneIterator
			Float parentProduct
			While (subFrameIterator < scaleInterps)
				parentProduct = 1.0 ; Product of parent scalings
				parentBoneIterator = jarray_count(parentBones)
				childBoneIterator = jarray_count(childBones)
				While (parentBoneIterator > 0) ; Perform parent scaling
					parentBoneIterator -= 1
					String currentBone = jarray_getStr(parentBones,parentBoneIterator)
					Float currentScale = jarray_getFlt(parentScales,parentBoneIterator) + subFrameIterator*jarray_getFlt(parentDeltas,parentBoneIterator)/scaleInterps
					parentProduct *= currentScale
					NiOverride.AddNodeTransformScale(prey, False, isFemale, currentBone, "DevourmentAnimScale", currentScale)
					NiOverride.UpdateNodeTransform(prey, False, isFemale, currentBone)
				EndWhile
				While (childBoneIterator > 0) ; Perform child scaling
					childBoneIterator -= 1
					If (subFrameIterator == (scaleInterps - 1)) ; If it's the last frame, use JSON values - prevents accumulating error.
						String currentBone = jarray_getStr(childBones,childBoneIterator)
						NiOverride.AddNodeTransformScale(prey, False, isFemale, currentBone, "DevourmentAnimScale", jarray_getFlt(childFinalScales,childBoneIterator))
						NiOverride.UpdateNodeTransform(prey, False, isFemale, currentBone)
					Else
						String currentBone = jarray_getStr(childBones,childBoneIterator)
						Float currentScale = 1 / parentProduct ;jarray_getFlt(childScales,childBoneIterator) / parentProduct	
						NiOverride.AddNodeTransformScale(prey, False, isFemale, currentBone, "DevourmentAnimScale", currentScale)
						NiOverride.UpdateNodeTransform(prey, False, isFemale, currentBone)
					EndIf
				EndWhile
				subFrameIterator += 1
			EndWhile
		EndIf
	EndEvent
EndState

State EndScaling
	; Resets all prey bones to normal scale
	Event OnUpdate()
		GoToState(None)
		Utility.wait(10.0) ; Again, this is a temporary measure. Eventually I will have a JSON entry for this/
		Int frame = 0
		While (frame < numScales)
			Int boneData = jarray_getObj(animationScales,frame)
			Bool counter = jarray_getStr(boneData, 0) == "Counter"
			If !counter ; Regular Scaling - Simply loop through bones and scale linearly
				Int bones = jarray_getObj(boneData,2)
				Int numBones = jarray_Count(bones)
				Int boneIterator = numBones
				While (boneIterator > 0)
					boneIterator -= 1
					String currentBone = jarray_getStr(bones,boneIterator)
					NiOverride.RemoveNodeTransformScale(prey, False, isFemale, currentBone, "DevourmentAnimScale")
					NiOverride.UpdateNodeTransform(prey, False, isFemale, currentBone)
				EndWhile
			Else ; CounterScaling - Loop through parents and scale linearly, then loop through children and scale inversely
				Int parentBones = jarray_getObj(boneData,2)
				Int childBones = jarray_getObj(boneData,3)
				Int parentBoneIterator = jarray_count(parentBones)
				Int childBoneIterator = jarray_count(childBones)
				parentBoneIterator = jarray_count(parentBones)
				While (parentBoneIterator > 0) ; Perform parent scaling
					parentBoneIterator -= 1
					String currentBone = jarray_getStr(parentBones,parentBoneIterator)
					NiOverride.RemoveNodeTransformScale(prey, False, isFemale, currentBone, "DevourmentAnimScale")
					NiOverride.UpdateNodeTransform(prey, False, isFemale, currentBone)
				EndWhile
				childBoneIterator = jarray_count(childBones)
				While (childBoneIterator > 0) ; Perform child scaling
					childBoneIterator -= 1
					String currentBone = jarray_getStr(childBones,childBoneIterator)
					NiOverride.RemoveNodeTransformScale(prey, False, isFemale, currentBone, "DevourmentAnimScale")
					NiOverride.UpdateNodeTransform(prey, False, isFemale, currentBone)
				EndWhile
			EndIf
			frame += 1
		EndWhile
		jvalue_release(animationScales)
		ConsoleUtil.PrintMessage("Finished Scaling")
	EndEvent
EndState