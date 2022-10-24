scriptName DialogueVore extends TopicInfo hidden


bool property NoEscape = false auto
{ If set to true, the prey will not be able to struggle or escape. }

bool property Consented = false auto
{ If set to true, the prey will not be able to struggle or escape; and non-consensual dialogue will be blocked. }

bool property strip = false auto
{ Strip the clothing/armor of the prey before swallowing. }

bool property kissoff = false auto
{ The pred and prey will share a kiss before swallowing (requires Sexlab). }

float property damage = 0.0 auto
{ The prey will take sufficient damage to reduce their health to this amount. }

bool property applyToPred = false auto
{ Indicates that diplomacy and influence options apply to the pred instead of the prey. }

bool property intimidate = false auto
{ Indicates that the prey (or the pred if ApplyToPred is set) had to pass an Intimidate check. }

bool property persuade = false auto
{ Indicates that the prey (or the pred if ApplyToPred is set) had to pass a Persuade check. }

bool property bribe = false auto
{ Indicates that the prey (or the pred if ApplyToPred is set) had to pass a Bribe check. }


int property override = -1 auto


Function Process(Actor pred, Actor prey, bool endo)
	if Override >= 0
		Faction StrangerFaction = Game.GetFormFromFile(0xD00, "Devourment.esp") as Faction
		pred.SetFactionRank(StrangerFaction, Override)
	endIf

	if strip
		DevourmentSexlab.instance().Strip(prey)
	endIf
	
	if kissOff && SexlabUtil.SexLabIsReady()
		bool result = DevourmentSexlab.instance().Kisses(pred, prey, true, endo)
		if !result
			Swallow(pred, prey, endo)
		endIf
	else
		Swallow(pred, prey, endo)
	endIf
endFunction


Function Swallow(Actor pred, Actor prey, bool endo)
	if applyToPred
		if intimidate
			Intimidate(pred)
		elseif persuade
			Persuade(pred)
		elseif bribe
			Bribe(pred)
		endIf
	else
		if intimidate
			Intimidate(prey)
		elseif persuade
			Persuade(prey)
		elseif bribe
			Bribe(prey)
		endIf
	endIf
	
	DevourmentManager manager = DevourmentManager.instance()
	manager.ForceSwallow(pred, prey, endo)
	
	if damage > 0.0
		float health = prey.getActorValue("health")
		if damage < health
			prey.damageActorValue("health", health - damage)
		elseif health > 11.0
			prey.damageActorValue("health", health - 10.0)
		endIf
	endIf

	if NoEscape
		manager.DisableEscape(prey)
	endIf
	
	if consented
		manager.VoreConsent(prey)
	endIf
EndFunction 


Function Escape(Actor pred, Actor prey, bool oralEscape)
	DevourmentManager manager = DevourmentManager.instance()

	manager.forceEscape(prey)

	if applyToPred
		if intimidate
			Intimidate(pred)
		elseif persuade
			Persuade(pred)
		elseif bribe
			Bribe(pred)
		endIf
	else
		if intimidate
			Intimidate(prey)
		elseif persuade
			Persuade(prey)
		elseif bribe
			Bribe(prey)
		endIf
	endIf
EndFunction


Function DisableEscape(Actor prey)
	DevourmentManager manager = DevourmentManager.instance()

	manager.disableEscape(prey)

	if consented
		manager.VoreConsent(prey)
	endIf
EndFunction


Function SwitchToEndo(Actor prey)
	if !(Prey.IsDead())
	DevourmentManager manager = DevourmentManager.instance()

	if consented
		manager.VoreConsent(prey)
	endIf

	if NoEscape
		manager.DisableEscape(prey)
	endIf

	manager.switchLethal(prey, false)
	endIf
EndFunction


Function SwitchToVore(ObjectReference prey)

	DevourmentManager manager = DevourmentManager.instance()
	if !((Prey as Actor).IsDead())
	if consented
		manager.VoreConsent(prey)
	endIf

	if NoEscape
		manager.DisableEscape(prey)
	endIf

	manager.switchLethal(prey, true)
	endIf
EndFunction


Function LethalDisable(Actor pred, Actor prey)
	DevourmentManager manager = DevourmentManager.instance()
	if !(Prey.IsDead())
	if applyToPred
		if intimidate
			Intimidate(pred)
		elseif persuade
			Persuade(pred)
		elseif bribe
			Bribe(pred)
		endIf
	elseif prey
		if intimidate
			Intimidate(prey)
		elseif persuade
			Persuade(prey)
		elseif bribe
			Bribe(prey)
		endIf
	endIf

	if prey && !(prey.isDead())
		manager.disableEscape(prey)

		if consented
			manager.VoreConsent(prey)
		endIf

		manager.SwitchLethal(prey, true)
		
	else
		Form[] stomach = Manager.GetStomachArray(pred)
		
		if !stomach || stomach.length == 0 || !stomach[0]
			return
		endIf
		
		int preyIndex = stomach.length
		while preyIndex
			preyIndex -= 1
			if stomach[preyIndex] as Actor && !((stomach[preyIndex] as Actor).IsDead())
				manager.DisableEscape(stomach[preyIndex] as Actor)
				manager.SwitchLethal(stomach[preyIndex] as Actor, true)
			endIf
		endWhile
	endIf
	endIf
EndFunction


Function Bribe(Actor pTarget)
{ We need a custom version of Bribe, because the default bribe amount is WAY too low. }
	Actor playerRef = Game.GetPlayer()
	FavorDialogueScript generic = Quest.GetQuest("DialogueFavorGeneric") as FavorDialogueScript

	Generic.SkillUseMultiplier = Generic.SpeechSkillMult.value
	Generic.SkillUseBribe = Generic.SkillUseMultiplier * playerRef.GetActorValue("Speechcraft")
	Debug.trace(self + "Current Skill uses given: " + Generic.SkillUseBribe + " times the Skill Use Multiplier")
	
	int bribeAmount = pTarget.GetBribeAmount() * 50
	
	if bribeAmount <= playerRef.GetGoldAmount()
		; remove gold, put gold in target, and set bribed state.
		playerRef.RemoveItem(Generic.Gold, bribeAmount)
		pTarget.AddItem(Generic.Gold, bribeAmount)
		pTarget.SetBribed()

		; give player skill uses
		Game.AdvanceSkill("Speechcraft", Generic.SkillUseBribe)

		; increment game stats
		Game.IncrementStat("Bribes")
		if Game.QueryStat("Persuasions") && Game.QueryStat("Intimidations")
			Game.AddAchievement(28)
		endif
	endif
endFunction


Function Persuade(Actor pTarget)
	(Quest.GetQuest("DialogueFavorGeneric") as FavorDialogueScript).Persuade(pTarget)
endFunction


Function Intimidate(Actor pTarget)
	(Quest.GetQuest("DialogueFavorGeneric") as FavorDialogueScript).Intimidate(pTarget)
endFunction


Actor Function Resolve(ObjectReference target)
	if target as DevourmentTalker
		return (target as DevourmentTalker).Target
	elseif target as Actor
		return target as Actor
	else
		return none
	endIf
EndFunction
