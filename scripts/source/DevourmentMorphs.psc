ScriptName DevourmentMorphs extends ReferenceAlias


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
	;UseMorphVore = 		JMap.getInt(data, "UseMorphVore", 			UseMorphVore as int) as bool
	;UseLocationalMorphs = 	JMap.getInt(data, "UseLocationalMorphs", 	UseLocationalMorphs as int) as bool
	useStruggleSliders = 	JMap.getInt(data, "UseStruggleSliders", 	UseStruggleSliders as int) as bool
	UseEliminationLocus = 	JMap.getInt(data, "UseEliminationLocus", 	UseEliminationLocus as int) as bool
	UseDualBreastMode = 	JMap.getInt(data, "UseDualBreastMode", 		UseDualBreastMode as int) as bool
	;EquippableBellyType = 	JMap.getInt(data, "EquippableBellyType", 	EquippableBellyType)
	MorphSpeed = 			JMap.getFlt(data, "MorphSpeed", 			MorphSpeed)
	StruggleAmplitude = 	JMap.getFlt(data, "StruggleAmplitude", 		StruggleAmplitude)
	CreatureScaling = 		JMap.getFlt(data, "CreatureScaling", 		CreatureScaling)
	Locus_Scales = 			JArray.asFloatArray(JMap.getObj(data, "Locus_Scales"))
	Locus_Maxes = 			JArray.asFloatArray(JMap.getObj(data, "Locus_Maxes"))
	Locus_Sliders = 		JArray.asStringArray(JMap.getObj(data, "Locus_Sliders"))
EndFunction


Function SaveSettings(int data)
	;JMap.setInt(data, "UseMorphVore", 			UseMorphVore as int)
	;JMap.setInt(data, "UseLocationalMorphs", 	UseLocationalMorphs as int)
	JMap.setInt(data, "UseStruggleSliders", 	UseStruggleSliders as int)
	JMap.setInt(data, "UseEliminationLocus", 	UseEliminationLocus as int)
	JMap.setInt(data, "UseDualBreastMode", 		UseDualBreastMode as int)
	;JMap.setInt(data, "EquippableBellyType", 	EquippableBellyType)
	JMap.setFlt(data, "MorphSpeed", 			MorphSpeed)
	JMap.setFlt(data, "StruggleAmplitude", 		StruggleAmplitude)
	JMap.setFlt(data, "CreatureScaling", 		CreatureScaling)
	JMap.setObj(data, "Locus_Scales", 			JArray.ObjectWithFloats(Locus_Scales))
	JMap.setObj(data, "Locus_Maxes", 			JArray.ObjectWithFloats(Locus_Maxes))
	JMap.setObj(data, "Locus_Sliders", 			JArray.ObjectWithStrings(Locus_Sliders))
EndFunction
