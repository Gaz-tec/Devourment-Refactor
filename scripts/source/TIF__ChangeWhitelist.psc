scriptName TIF__ChangeWhitelist extends TopicInfo hidden

DevourmentManager Property Manager Auto
bool property add auto

function Fragment_0(ObjectReference akSpeakerRef)
	if add
        Manager.PredatorWhitelist = PapyrusUtil.PushActor(Manager.PredatorWhitelist, akSpeakerRef as Actor)
		(akSpeakerRef as Actor).AddToFaction(Manager.PredatorWhitelistFaction)
	else
		Manager.PredatorWhitelist = PapyrusUtil.RemoveActor(Manager.PredatorWhitelist, akSpeakerRef as Actor)
		(akSpeakerRef as Actor).RemoveFromFaction(Manager.PredatorWhitelistFaction)
	endIf
endFunction
