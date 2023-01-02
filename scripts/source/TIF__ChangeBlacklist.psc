scriptName TIF__ChangeBlacklist extends TopicInfo hidden

DevourmentManager Property Manager Auto
bool property add auto

function Fragment_0(ObjectReference akSpeakerRef)
	if add
        Manager.PredatorBlacklist = PapyrusUtil.PushActor(Manager.PredatorBlacklist, akSpeakerRef as Actor)
		(akSpeakerRef as Actor).AddToFaction(Manager.PredatorBlacklistFaction)
	else
		Manager.PredatorBlacklist = PapyrusUtil.RemoveActor(Manager.PredatorBlacklist, akSpeakerRef as Actor)
		(akSpeakerRef as Actor).RemoveFromFaction(Manager.PredatorBlacklistFaction)
	endIf
endFunction
