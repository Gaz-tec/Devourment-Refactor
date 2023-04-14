ScriptName TIF__PrevDovaBounty extends TopicInfo hidden

GlobalVariable Property BountyGlobal Auto

Function Fragment_0(ObjectReference akSpeakerRef)
	Game.GetPlayer().AddItem(Game.GetForm(0xF), BountyGlobal.GetValue() as Int)
	BountyGlobal.SetValue(0.0)
endFunction
