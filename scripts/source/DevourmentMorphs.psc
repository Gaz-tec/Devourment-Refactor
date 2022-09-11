ScriptName DevourmentMorphs extends ReferenceAlias

import Devourment_JCDomain

DevourmentManager property Manager auto
Actor property PlayerRef auto
bool property UseDualBreastMode = true auto
;bool property UseMorphVore = true auto
bool property UseStruggleSliders = true auto
;bool property UseLocationalMorphs = true auto
bool property UseEliminationLocus = false auto
;int property EquippableBellyType = 1 auto
float property StruggleAmplitude = 1.0 auto
float property MorphSpeed = 0.07 auto
float property CreatureScaling = 2.0 auto
float[] property Locus_Scales auto
float[] property Locus_Maxes auto
String[] property Locus_Sliders auto
String[] property StruggleSliders auto


Event OnInit()
EndEvent


Function LoadSettings(int data)
	;UseMorphVore = 		JMap_getInt(data, "UseMorphVore", 			UseMorphVore as int) as bool
	;UseLocationalMorphs = 	JMap_getInt(data, "UseLocationalMorphs", 	UseLocationalMorphs as int) as bool
	useStruggleSliders = 	JMap_getInt(data, "UseStruggleSliders", 	UseStruggleSliders as int) as bool
	UseEliminationLocus = 	JMap_getInt(data, "UseEliminationLocus", 	UseEliminationLocus as int) as bool
	UseDualBreastMode = 	JMap_getInt(data, "UseDualBreastMode", 		UseDualBreastMode as int) as bool
	;EquippableBellyType = 	JMap_getInt(data, "EquippableBellyType", 	EquippableBellyType)
	MorphSpeed = 			JMap_getFlt(data, "MorphSpeed", 			MorphSpeed)
	StruggleAmplitude = 	JMap_getFlt(data, "StruggleAmplitude", 		StruggleAmplitude)
	CreatureScaling = 		JMap_getFlt(data, "CreatureScaling", 		CreatureScaling)
	Locus_Scales = 			JArray_asFloatArray(JMap_getObj(data, "Locus_Scales"))
	Locus_Maxes = 			JArray_asFloatArray(JMap_getObj(data, "Locus_Maxes"))
	Locus_Sliders = 		JArray_asStringArray(JMap_getObj(data, "Locus_Sliders"))
EndFunction


Function SaveSettings(int data)
	;JMap_setInt(data, "UseMorphVore", 			UseMorphVore as int)
	;JMap_setInt(data, "UseLocationalMorphs", 	UseLocationalMorphs as int)
	JMap_setInt(data, "UseStruggleSliders", 	UseStruggleSliders as int)
	JMap_setInt(data, "UseEliminationLocus", 	UseEliminationLocus as int)
	JMap_setInt(data, "UseDualBreastMode", 		UseDualBreastMode as int)
	;JMap_setInt(data, "EquippableBellyType", 	EquippableBellyType)
	JMap_setFlt(data, "MorphSpeed", 			MorphSpeed)
	JMap_setFlt(data, "StruggleAmplitude", 		StruggleAmplitude)
	JMap_setFlt(data, "CreatureScaling", 		CreatureScaling)
	JMap_setObj(data, "Locus_Scales", 			JArray_ObjectWithFloats(Locus_Scales))
	JMap_setObj(data, "Locus_Maxes", 			JArray_ObjectWithFloats(Locus_Maxes))
	JMap_setObj(data, "Locus_Sliders", 			JArray_ObjectWithStrings(Locus_Sliders))
EndFunction
