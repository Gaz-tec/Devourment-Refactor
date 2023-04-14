scriptName TIF__ToggleFaction extends TopicInfo hidden

Faction property fac auto
bool property enable auto

function Fragment_0(ObjectReference akSpeakerRef)
	if enable
		(akSpeakerRef as Actor).AddToFaction(fac)
	else
		(akSpeakerRef as Actor).RemoveFromFaction(fac)
	endIf
endFunction
