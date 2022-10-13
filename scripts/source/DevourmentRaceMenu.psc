Scriptname DevourmentRaceMenu extends RaceMenuBase

;Ranges
float Property SCALE_MIN = 0.01 AutoReadOnly ; Set this to the min value for a scale slider, cannot be negative nor zero, do no make it smaller than 0.01, if you want smaller than that, you can use the hidden slider.
float Property SCALE_MAX = 8.00 AutoReadOnly ; Set this to the max value for a scale slider
float Property POSITION_RANGE = 10.00 AutoReadOnly ; Set this to the negative min and positive max value for a position slider
float Property ROTATION_RANGE = 180.00 AutoReadOnly ; Set this to the negative min and positive max value for a rotation slider, 180.00 = 360 degree, 120 = 240 degree range
float Property SCALE_STEPPING = 0.01 AutoReadOnly ; Set this to the value a scale slider steps to
float Property POSITION_STEPPING = 0.10 AutoReadOnly ; Set this to the value a position slider steps to
float Property ROTATION_STEPPING = 0.10 AutoReadOnly ; Set this to the value a rotation slider steps to

; Devourment BodyMorph sliders.
string Property SLIDER_VOREPREYBELLY = "Vore Prey Belly" AutoReadOnly
string Property SLIDER_CVORE = "CVore" AutoReadOnly
string Property SLIDER_BVOREL = "BVoreL" AutoReadOnly
string Property SLIDER_BVORER = "BVoreR" AutoReadOnly
string Property SLIDER_STRUGGLE_BELLY1 = "StruggleSlider1" AutoReadOnly
string Property SLIDER_STRUGGLE_BELLY2 = "StruggleSlider2" AutoReadOnly
string Property SLIDER_STRUGGLE_BELLY3 = "StruggleSlider3" AutoReadOnly
string Property SLIDER_STRUGGLE_BREASTL1 = "BVoreStruggleL1" AutoReadOnly
string Property SLIDER_STRUGGLE_BREASTL2 = "BVoreStruggleL2" AutoReadOnly
string Property SLIDER_STRUGGLE_BREASTL3 = "BVoreStruggleL3" AutoReadOnly
string Property SLIDER_STRUGGLE_BREASTR1 = "BVoreStruggleR1" AutoReadOnly
string Property SLIDER_STRUGGLE_BREASTR2 = "BVoreStruggleR2" AutoReadOnly
string Property SLIDER_STRUGGLE_BREASTR3 = "BVoreStruggleR3" AutoReadOnly

string Property SLIDER_EXTRA_A = "Giant belly (coldsteelj)" AutoReadOnly
string Property SLIDER_EXTRA_B = "SSBBW2 body" AutoReadOnly
string Property SLIDER_EXTRA_C = "SSBBW3 body" AutoReadOnly
string Property SLIDER_EXTRA_D = "SSBBW_Muscled" AutoReadOnly
string Property SLIDER_EXTRA_E = "SSBBW WGBelly" AutoReadOnly
string Property SLIDER_EXTRA_F = "SSBBW Ultkir body" AutoReadOnly
string Property SLIDER_EXTRA_G = "SSBBW Butt growth" AutoReadOnly
string Property SLIDER_EXTRA_H = "SSBBW2 Boobs Growth" AutoReadOnly
string Property SLIDER_EXTRA_I = "Giant belly up" AutoReadOnly
string Property SLIDER_EXTRA_J = "SSBBW WGBelly" AutoReadOnly
string Property SLIDER_EXTRA_K = "FatBelly" AutoReadOnly


;Callbacks Table
string Property CALLBACK_VOREPREYBELLY = "CALLBACK_VOREPREYBELLY" AutoReadOnly
string Property CALLBACK_CVORE = "CALLBACK_CVORE" AutoReadOnly
string Property CALLBACK_BVOREL = "CALLBACK_BVOREL" AutoReadOnly
string Property CALLBACK_BVORER = "CALLBACK_BVORER" AutoReadOnly
string Property CALLBACK_STRUGGLE_BELLY1 = "CALLBACK_STRUGGLE_BELLY1" AutoReadOnly
string Property CALLBACK_STRUGGLE_BELLY2 = "CALLBACK_STRUGGLE_BELLY2" AutoReadOnly
string Property CALLBACK_STRUGGLE_BELLY3 = "CALLBACK_STRUGGLE_BELLY3" AutoReadOnly
string Property CALLBACK_STRUGGLE_BREASTL1 = "CALLBACK_STRUGGLE_BREASTL1" AutoReadOnly
string Property CALLBACK_STRUGGLE_BREASTL2 = "CALLBACK_STRUGGLE_BREASTL2" AutoReadOnly
string Property CALLBACK_STRUGGLE_BREASTL3 = "CALLBACK_STRUGGLE_BREASTL3" AutoReadOnly
string Property CALLBACK_STRUGGLE_BREASTR1 = "CALLBACK_STRUGGLE_BREASTR1" AutoReadOnly
string Property CALLBACK_STRUGGLE_BREASTR2 = "CALLBACK_STRUGGLE_BREASTR2" AutoReadOnly
string Property CALLBACK_STRUGGLE_BREASTR3 = "CALLBACK_STRUGGLE_BREASTR3" AutoReadOnly

string Property CALLBACK_EXTRA_A = "CALLBACK_EXTRA_A" AutoReadOnly
string Property CALLBACK_EXTRA_B = "CALLBACK_EXTRA_B" AutoReadOnly
string Property CALLBACK_EXTRA_C = "CALLBACK_EXTRA_C" AutoReadOnly
string Property CALLBACK_EXTRA_D = "CALLBACK_EXTRA_D" AutoReadOnly
string Property CALLBACK_EXTRA_E = "CALLBACK_EXTRA_E" AutoReadOnly
string Property CALLBACK_EXTRA_F = "CALLBACK_EXTRA_F" AutoReadOnly
string Property CALLBACK_EXTRA_G = "CALLBACK_EXTRA_G" AutoReadOnly
string Property CALLBACK_EXTRA_H = "CALLBACK_EXTRA_H" AutoReadOnly
string Property CALLBACK_EXTRA_I = "CALLBACK_EXTRA_I" AutoReadOnly
string Property CALLBACK_EXTRA_J = "CALLBACK_EXTRA_J" AutoReadOnly
string Property CALLBACK_EXTRA_K = "CALLBACK_EXTRA_K" AutoReadOnly

string Property CATEGORY_VORE = "DevourmentVoreCategory" AutoReadOnly




Event OnCategoryRequest()
	AddCategory(CATEGORY_VORE, "VORE")
EndEvent


Event OnStartup()
	parent.OnStartup()
EndEvent


; Add Custom sliders here
Event OnSliderRequest(Actor target, ActorBase targetBase, Race actorRace, bool isFemale)
	AddSliderEx("Vore Prey Belly", CATEGORY_VORE, CALLBACK_VOREPREYBELLY, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_VOREPREYBELLY, "Devourment.esp"))
	AddSliderEx("CVore", CATEGORY_VORE, CALLBACK_CVORE, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_CVORE, "Devourment.esp"))
	AddSliderEx("BVoreL", CATEGORY_VORE, CALLBACK_BVOREL, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_BVOREL, "Devourment.esp"))
	AddSliderEx("BVoreR", CATEGORY_VORE, CALLBACK_BVORER, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_BVORER, "Devourment.esp"))

	AddSliderEx("StruggleSliderBelly1", CATEGORY_VORE, CALLBACK_STRUGGLE_BELLY1, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_STRUGGLE_BELLY1, "Devourment.esp"))
	AddSliderEx("StruggleSliderBelly2", CATEGORY_VORE, CALLBACK_STRUGGLE_BELLY2, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_STRUGGLE_BELLY2, "Devourment.esp"))
	AddSliderEx("StruggleSliderBelly3", CATEGORY_VORE, CALLBACK_STRUGGLE_BELLY3, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_STRUGGLE_BELLY3, "Devourment.esp"))

	AddSliderEx("StruggleSliderBreastLeft1", CATEGORY_VORE, CALLBACK_STRUGGLE_BREASTL1, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_STRUGGLE_BREASTL1, "Devourment.esp"))
	AddSliderEx("StruggleSliderBreastLeft2", CATEGORY_VORE, CALLBACK_STRUGGLE_BREASTL2, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_STRUGGLE_BREASTL2, "Devourment.esp"))
	AddSliderEx("StruggleSliderBreastLeft3", CATEGORY_VORE, CALLBACK_STRUGGLE_BREASTL3, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_STRUGGLE_BREASTL3, "Devourment.esp"))

	AddSliderEx("StruggleSliderBreastRight1", CATEGORY_VORE, CALLBACK_STRUGGLE_BREASTR1, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_STRUGGLE_BREASTR1, "Devourment.esp"))
	AddSliderEx("StruggleSliderBreastRight2", CATEGORY_VORE, CALLBACK_STRUGGLE_BREASTR2, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_STRUGGLE_BREASTR2, "Devourment.esp"))
	AddSliderEx("StruggleSliderBreastRight3", CATEGORY_VORE, CALLBACK_STRUGGLE_BREASTR3, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_STRUGGLE_BREASTR3, "Devourment.esp"))

	AddSliderEx(SLIDER_EXTRA_A, CATEGORY_VORE, CALLBACK_EXTRA_A, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_A, "Devourment.esp"))
	AddSliderEx(SLIDER_EXTRA_B, CATEGORY_VORE, CALLBACK_EXTRA_B, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_B, "Devourment.esp"))
	AddSliderEx(SLIDER_EXTRA_C, CATEGORY_VORE, CALLBACK_EXTRA_C, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_C, "Devourment.esp"))
	AddSliderEx(SLIDER_EXTRA_D, CATEGORY_VORE, CALLBACK_EXTRA_D, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_D, "Devourment.esp"))
	AddSliderEx(SLIDER_EXTRA_E, CATEGORY_VORE, CALLBACK_EXTRA_E, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_E, "Devourment.esp"))
	AddSliderEx(SLIDER_EXTRA_F, CATEGORY_VORE, CALLBACK_EXTRA_F, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_F, "Devourment.esp"))
	AddSliderEx(SLIDER_EXTRA_G, CATEGORY_VORE, CALLBACK_EXTRA_G, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_G, "Devourment.esp"))
	AddSliderEx(SLIDER_EXTRA_H, CATEGORY_VORE, CALLBACK_EXTRA_H, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_H, "Devourment.esp"))
	AddSliderEx(SLIDER_EXTRA_I, CATEGORY_VORE, CALLBACK_EXTRA_I, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_I, "Devourment.esp"))
	AddSliderEx(SLIDER_EXTRA_J, CATEGORY_VORE, CALLBACK_EXTRA_J, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_J, "Devourment.esp"))
	AddSliderEx(SLIDER_EXTRA_K, CATEGORY_VORE, CALLBACK_EXTRA_K, SCALE_MIN, SCALE_MAX, SCALE_STEPPING, NiOverride.GetBodyMorph(target, SLIDER_EXTRA_K, "Devourment.esp"))
EndEvent


Event OnSliderChanged(string callback, float value)
	If callback == CALLBACK_VOREPREYBELLY
		NiOverride.SetBodyMorph(_targetActor, SLIDER_VOREPREYBELLY, "Devourment.esp", value)
	ElseIf callback == CALLBACK_CVORE
		NiOverride.SetBodyMorph(_targetActor, SLIDER_CVORE, "Devourment.esp", value)
	ElseIf callback == CALLBACK_BVOREL
		NiOverride.SetBodyMorph(_targetActor, SLIDER_BVOREL, "Devourment.esp", value)
	ElseIf callback == CALLBACK_BVORER
		NiOverride.SetBodyMorph(_targetActor, SLIDER_BVORER, "Devourment.esp", value)
	ElseIf callback == CALLBACK_STRUGGLE_BELLY1
		NiOverride.SetBodyMorph(_targetActor, SLIDER_STRUGGLE_BELLY1, "Devourment.esp", value)
	ElseIf callback == CALLBACK_STRUGGLE_BELLY2
		NiOverride.SetBodyMorph(_targetActor, SLIDER_STRUGGLE_BELLY2, "Devourment.esp", value)
	ElseIf callback == CALLBACK_STRUGGLE_BELLY3
		NiOverride.SetBodyMorph(_targetActor, SLIDER_STRUGGLE_BELLY3, "Devourment.esp", value)
	ElseIf callback == CALLBACK_STRUGGLE_BREASTL1
		NiOverride.SetBodyMorph(_targetActor, SLIDER_STRUGGLE_BREASTL1, "Devourment.esp", value)
	ElseIf callback == CALLBACK_STRUGGLE_BREASTL2
		NiOverride.SetBodyMorph(_targetActor, SLIDER_STRUGGLE_BREASTL2, "Devourment.esp", value)
	ElseIf callback == CALLBACK_STRUGGLE_BREASTL3
		NiOverride.SetBodyMorph(_targetActor, SLIDER_STRUGGLE_BREASTL3, "Devourment.esp", value)
	ElseIf callback == CALLBACK_STRUGGLE_BREASTR1
		NiOverride.SetBodyMorph(_targetActor, SLIDER_STRUGGLE_BREASTR1, "Devourment.esp", value)
	ElseIf callback == CALLBACK_STRUGGLE_BREASTR2
		NiOverride.SetBodyMorph(_targetActor, SLIDER_STRUGGLE_BREASTR2, "Devourment.esp", value)
	ElseIf callback == CALLBACK_STRUGGLE_BREASTR3
		NiOverride.SetBodyMorph(_targetActor, SLIDER_STRUGGLE_BREASTR3, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_A
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_A, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_B
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_B, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_C
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_C, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_D
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_D, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_E
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_E, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_F
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_F, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_G
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_G, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_H
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_H, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_I
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_I, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_J
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_J, "Devourment.esp", value)
	ElseIf callback == CALLBACK_EXTRA_K
		NiOverride.SetBodyMorph(_targetActor, SLIDER_EXTRA_K, "Devourment.esp", value)
	Endif
	NiOverride.UpdateModelWeight(_targetActor)
EndEvent
