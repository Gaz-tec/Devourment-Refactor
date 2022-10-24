scriptName DevourmentBellyScaling extends ActiveMagicEffect
{
}
import Logging
import DevourmentUtil
import Devourment_JCDomain


DevourmentManager property Manager auto
DevourmentMorphs property Morphs auto
Actor property PlayerRef auto
Armor[] property Fullnesses auto
FormList property FullnessTypes_All auto
Keyword property ActorTypeNPC auto


String PREFIX = "DevourmentBellyScaling"
bool DEBUGGING = false
bool isFemale
bool isNPC
Actor target

int DATA = 0
int OUTPUT_BODY = 0
int OUTPUT_BUMPS = 0
String PROTOTYPE = "{ \"currentScale\" : 0.0, \"targetScale\" : 0.0, \"currentScales\" : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0], \"targetScales\" : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0], \"oddity\" : 0.9, \"amplitude\" : 0.5, \"minDuration\" : 15.0, \"maxDuration\" : 30.0, \"bumps\" : [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}], \"output_scale\" : 0.0, \"output_body\" : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0], \"output_bumps\" : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] }"


;bool UseMorphVore = true
bool UseStruggleSliders = true
;bool UseLocationalMorphs = true
float UpdateTime = 0.05
float playerStruggle = 0.0
bool PlayerStruggleBumps

Float[] lastOutputBody
String[] Sliders
String[] StruggleSliders
bool[] isNode


event OnEffectStart(Actor akTarget, Actor akCaster)
	{ Event received when this effect is first started (OnInit may not have been run yet!) }
	if !akTarget
		assertNotNone(PREFIX, "OnEffectStart", "akTarget", akTarget)
		return
	endif

	target = akTarget
	isFemale = Manager.IsFemale(target)
	isNPC = target.HasKeyword(ActorTypeNPC)

	;UseMorphVore = Morphs.UseMorphVore
	PlayerStruggleBumps = Manager.whoStruggles > 0 && Manager.VisualStruggles
	UseStruggleSliders = Morphs.UseStruggleSliders && !Manager.PERFORMANCE
	;UseLocationalMorphs = Morphs.UseLocationalMorphs && IsNPC
	;Gaz assertion: Non-oral voretypes should not be restricted in this way. 
	;They should instead be restricted via entry points (i.e. spells)
	;This way if someone wants to add a cock to a wolf and be CV'd, the system does not fight this possibility, they need only add the spell.

	DATA = JValue_retain(JValue_objectFromPrototype(PROTOTYPE), PREFIX)
	OUTPUT_BODY = JMap_GetObj(DATA, "output_body")
	OUTPUT_BUMPS = JMap_GetObj(DATA, "output_bumps")
	JMap_SetForm(DATA, "target", target)

	if UseStruggleSliders
		JMap_setInt(DATA, "UseStruggleSliders", 1)
		JMap_setFlt(DATA, "StruggleAmplitude", Morphs.StruggleAmplitude)
	endIf

	;if UseLocationalMorphs
		;JMap_setInt(DATA, "UseLocationalMorphs", 1)
		if Morphs.UseEliminationLocus
			JMap_setInt(DATA, "UseEliminationLocus", 1)
		endIf
	;endIf

	if Manager.PERFORMANCE
		JMap_setFlt(DATA, "MorphSpeed", 1.0)
	else
		JMap_setFlt(DATA, "MorphSpeed", Morphs.MorphSpeed)
	endIf

	if !isNPC
		JMap_setFlt(DATA, "CreatureScaling", Morphs.CreatureScaling)
	endIf
	
	Manager.CommitMorphsToDB()

	Sliders = Morphs.Locus_Sliders
	lastOutputBody = Utility.CreateFloatArray(Sliders.Length)	;Create here, so Papyrus does not try to query elements that don't exist.
	StruggleSliders = Morphs.StruggleSliders
	IsNode = Utility.CreateBoolArray(Sliders.length)

	int sliderIndex = Sliders.length
	while sliderIndex
		sliderIndex -= 1
		String slider = Sliders[sliderIndex]
		IsNode[sliderIndex] = target.HasNode(slider) || StringUtil.find(slider, "NPC ") >= 0
	endWhile

	;/
	if target.HasKeyword(ActorTypeNPC)
		int EquippableBellyType = Morphs.EquippableBellyType
		if EquippableBellyType >= 0 && EquippableBellyType < Fullnesses.length
			Armor belly = Fullnesses[EquippableBellyType]
			target.equipItem(belly, false, true)
			if !belly.HasKeywordString("SexlabNoStrip")
				Keyword NoStrip = Keyword.GetKeyword("SexlabNoStrip")
				if NoStrip
					PO3_SKSEFunctions.AddKeywordToForm(belly, NoStrip)
				endIf
			endIf
			if EquippableBellyType > 0	
				Sliders[0] == "Equipable Vore prey belly"
				StruggleSliders[0] = "Equipable StruggleSlider1"
				StruggleSliders[1] = "Equipable StruggleSlider2"
				StruggleSliders[2] = "Equipable StruggleSlider3"
			EndIf
		else
			target.removeItem(FullnessTypes_All, 99, true)
		endIf
	endIf
	/;

	if Sliders.length < 1 || IsNode.length < 1 || !JValue_IsExists(DATA)
		AssertExists(PREFIX, "OnEffectStart", "DATA", DATA)
		AssertExists(PREFIX, "OnEffectStart", "OUTPUT_BODY", OUTPUT_BODY)
		AssertExists(PREFIX, "OnEffectStart", "OUTPUT_BUMPS", OUTPUT_BUMPS)
		return
	endIf

	if PlayerStruggleBumps
		RegisterForModEvent("Devourment_PlayerStruggle", "OnPlayerStruggle")
		RegisterForModEvent("Devourment_onLiveDigestion", "onLiveDigestion")
		RegisterForModEvent("Devourment_onPreyDeath", "onPreyDeath")
		RegisterForModEvent("Devourment_onEscape", "onEscape")
	else
		playerStruggle = -1.0
	endIf
	
	RegisterForSingleUpdate(0.0)
endEvent


Event onPreyDeath(Form pred, Form prey)
{ Checks if the principal struggler has died. If so, the principal struggler field is cleared. }
	if pred == target && prey == playerRef
		playerStruggle = 0.0
	endIf
EndEvent


Event onEscape(Form pred, Form prey, bool oral)
{ Checks if the principal struggler has escaped. If so, the principal struggler field is cleared. }
	if pred == target && prey == playerRef
		playerStruggle = 0.0
	endIf
EndEvent


Event OnCombatStateChanged(Actor newTarget, int aeCombatState)
	if aeCombatState > 1
		JMap_SetInt(DATA, "squench", 1)
	else
		JMap_removeKey(DATA, "squench")
	endIf
EndEvent


Event onLiveDigestion(Form pred, Form prey, float damage, float percent)
{ Updates the bumpAmplitude field for the principal struggler. }
	if pred == target && prey == playerRef
		playerStruggle *= 0.5
	endIf
EndEvent


Event OnPlayerStruggle()
	if Manager.GetPredFor(PlayerRef) == target
		playerStruggle = 1.0
	endIf
EndEvent


Event OnUpdate()
	float totalScale = JLua_evalLuaFlt("return dvt.BumpSliders(args, " + playerStruggle + ")", DATA, 0, 0.0)
	float[] outputBody = JArray_asFloatArray(OUTPUT_BODY)
	float[] outputBumps = JArray_asFloatArray(OUTPUT_BUMPS)

	if DEBUGGING 
		Log2(PREFIX, "OnUpdate", totalScale, LuaS("DATA", DATA))
		LogFloats(PREFIX, "OnUpdate", "outputBody", outputBody)
		LogFloats(PREFIX, "OnUpdate", "outputBumps", outputBumps)
	endIf
	
	bool updateWeights = false

	;if UseMorphVore
		;/
		if !UseLocationalMorphs
			if totalScale >= 0.0
				if IsNode[0]
					NIOverride.AddNodeTransformScale(target, false, isFemale, Sliders[0], PREFIX, 1.0 + totalScale)
					NIOverride.UpdateNodeTransform(target, false, isFemale, Sliders[0])
				else
					NIOverride.SetBodyMorph(target, Sliders[0], PREFIX, totalScale)
					updateWeights = true
				endIf
			endIf
		else
		/;
			int sliderIndex = Sliders.length
			while sliderIndex
				sliderIndex -= 1
				float scale = outputBody[sliderIndex]
				if scale >= 0.0 && lastOutputBody[sliderIndex] != scale
					if IsNode[sliderIndex]
						NIOverride.AddNodeTransformScale(target, false, isFemale, Sliders[sliderIndex], PREFIX, 1.0 + scale)
						NIOverride.UpdateNodeTransform(target, false, isFemale, Sliders[sliderIndex])
						lastOutputBody = outputBody
					else
						NIOverride.SetBodyMorph(target, Sliders[sliderIndex], PREFIX, scale)
						updateWeights = true
					endIf
				endIf
			endWhile
		;endIf
	;endIf
	
	if UseStruggleSliders
		sliderIndex = StruggleSliders.length
		while sliderIndex
			sliderIndex -= 1
			float scale = outputBumps[sliderIndex]
			if scale >= 0.0
				NIOverride.SetBodyMorph(target, StruggleSliders[sliderIndex], PREFIX, scale)
				updateWeights = true
			endIf
		endWhile
	endIf
	
	if updateWeights
		NiOverride.UpdateModelWeight(target)
		RegisterForSingleUpdate(UpdateTime)
		lastOutputBody = outputBody
	else
		RegisterForSingleUpdate(1.0)
	endIf
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
	DATA = JValue_release(DATA)
	NIOverride.ClearBodyMorphKeys(target, PREFIX)

	;if UseMorphVore
		int sliderIndex = Sliders.length
		while sliderIndex
			sliderIndex -= 1
			if IsNode[sliderIndex]
				NIOverride.RemoveNodeTransformScale(target, false, isFemale, Sliders[sliderIndex], PREFIX)
				NIOverride.UpdateNodeTransform(target, false, isFemale, Sliders[sliderIndex])
			endIf
		endWhile
	;endIf
	
	NiOverride.UpdateModelWeight(target)
	target.RemoveItem(FullnessTypes_All, 99, true)
endEvent