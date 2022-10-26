Scriptname DevourmentPseudoAI extends ActiveMagicEffect
import Logging


Actor property PlayerRef auto
DevourmentManager property Manager auto
Faction property CorpseVore auto
Keyword property BeingSwallowed auto
MagicEffect property DontSwallowMe auto
Spell property VoreSpell auto
Spell[] property CombatSpells auto
float property SwallowRange = 225.0 autoReadOnly

int combatSpellsCount = 0


String PREFIX = "DevourmentPseudoAI"
String predName
Actor Pred
bool DEBUGGING = false
bool doBleedoutVore
bool doCorpseVore
float reach
float cooldownTime = 5.0
bool coolingDown = false

Actor currentTarget = none
bool validTarget


Event OnEffectStart(Actor akTarget, Actor akCaster)
{ Checks the combat state and which types of Noms are allowed. }

	if !AssertNotNone(PREFIX, "OnEffectStart", "akTarget", akTarget)
		Dispel()
		return
	endIf

	pred = akTarget
	predName = Namer(pred, true)
	reach = SwallowRange + pred.GetLength()
	doBleedoutVore = !Game.IsPluginInstalled("SexLabDefeat.esp")
	doCorpseVore = pred.IsInFaction(CorpseVore)

	if pred.HasKeywordString("ActorTypeNPC")
		cooldownTime = Manager.Cooldown_NPC
	else
		cooldownTime = Manager.Cooldown_Creature
	endIf

	if Manager.validPredator(pred)
		currentTarget = pred.GetCombatTarget()
		validTarget = CombatCheck(currentTarget, pred.getCombatState())
	
		RegisterForSingleUpdate(cooldownTime)
		RegisterForAnimationEvent(pred, "HitFrame")
		RegisterForActorAction(0)


		int len = CombatSpells.length
		int index = 0
		int count = 0

		while index < len
			bool available = pred.HasSpell(CombatSpells[index])
			if !available 
				CombatSpells[index] = None
			elseif index != combatSpellsCount
				CombatSpells[combatSpellsCount] = CombatSpells[index]
				CombatSpells[index] = None
				combatSpellsCount += 1
			else
				combatSpellsCount += 1
			endIf
			index += 1
		endWhile

		if DEBUGGING
			Log2(PREFIX, "OnEffectStart", Namer(pred), SpellArrayToString(CombatSpells))
		endIf
	endIf
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
EndEvent 


Event OnCombatStateChanged(Actor newTarget, int aeCombatState)
	;Log0(PREFIX, "OnCombatStateChanged")

	if DEBUGGING
		Log5(PREFIX, "OnCombatStateChanged", predName, aeCombatState, "prev target = " + Namer(currentTarget), "new target = " + Namer(newTarget), CombatCheck(newTarget, aeCombatState))
	endIf

	currentTarget = newTarget
	validTarget = CombatCheck(currentTarget, aeCombatState)
	coolingDown = false
EndEvent


Event OnUpdate()
	if coolingDown
		currentTarget = pred.GetCombatTarget()
		validTarget = CombatCheck(currentTarget, pred.GetCombatState())
		coolingDown = false
		RegisterForSingleUpdate(Utility.RandomFloat(0.0, cooldownTime))

		if DEBUGGING
			Log2(PREFIX, "OnUpdate", predName, "WAIT A BIT")
		endIf
		
	elseif !validTarget
		coolingDown = false
		registerForSingleUpdate(cooldownTime)

		if DEBUGGING
			Log2(PREFIX, "OnUpdate", predName, "INVALID TARGET")
		endIf

	else 
		coolingDown = true
		registerForSingleUpdate(cooldownTime)

		if DEBUGGING
			Log2(PREFIX, "OnUpdate", predName, "NOM ATTEMPT")
		endIf
		bool madeAttempt = DoANom(currentTarget)
	endIf
EndEvent


Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	if validTarget && doCorpseVore && currentTarget.IsDead()
		if DEBUGGING
			Log6(PREFIX, "OnActorAction", predName, "EAT A CORPSE", actionType, Namer(akActor), Namer(source), slot)
		endIf
		bool madeAttempt = DoANom(currentTarget)
	elseif coolingDown
		if DEBUGGING
			Log6(PREFIX, "OnActorAction", predName, "COOLDOWN", actionType, Namer(akActor), Namer(source), slot)
		endIf
	elseif !validTarget
		if DEBUGGING
			Log6(PREFIX, "OnActorAction", predName, "INVALID TARGET", actionType, Namer(akActor), Namer(source), slot)
		endIf
	else
		coolingDown = true
		registerForSingleUpdate(cooldownTime) ; Reset the onUpdate timer.
		
		if DEBUGGING
			Log6(PREFIX, "OnActorAction", predName, "NOM ATTEMPT", actionType, Namer(akActor), Namer(source), slot)
		endIf
		bool madeAttempt = DoANom(currentTarget)
	endIf
EndEvent


Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	if validTarget && doCorpseVore && currentTarget.IsDead()
		if DEBUGGING
			Log4(PREFIX, "OnAnimationEvent", predName, "EAT A CORPSE", Namer(akSource), asEventName)
		endIf
		bool madeAttempt = DoANom(currentTarget)
	elseif coolingDown
		if DEBUGGING
			Log4(PREFIX, "OnAnimationEvent", predName, "COOLDOWN", Namer(akSource), asEventName)
		endIf
	elseif !validTarget
		if DEBUGGING
			Log4(PREFIX, "OnAnimationEvent", predName, "INVALID TARGET", Namer(akSource), asEventName)
		endIf
	else
		coolingDown = true
		registerForSingleUpdate(cooldownTime) ; Reset the onUpdate timer.

		if DEBUGGING
			Log4(PREFIX, "OnAnimationEvent", predName, "NOM ATTEMPT", Namer(akSource), asEventName)
		endIf
		bool madeAttempt = DoANom(currentTarget)
	endIf
EndEvent


bool Function combatCheck(Actor newTarget, int combatState)
	return combatState ==  1 && newTarget != none && pred != none && !newTarget.isChild() \
	&& (doCorpseVore || !newTarget.isDead()) && PlayerCheck(newTarget) \
	&& Manager.IsValidDigestion(pred, newTarget)
endFunction	


bool Function DoANom(Actor prey)
{ 
	Don't swallow anyone who is already being swallowed or too far away. If the prey is uninjured and higher level, don't swallow. 
	Print out appropriate debugging messages.
}
	if !AssertNotNone(PREFIX, "DoANom", "prey", prey)
		return false

	elseif !Manager.validPredator(pred)
		return false

		;/
	elseif !isWeakened(prey)
		if DEBUGGING
			Log2(PREFIX, "DoANom", "Prey not weakened.", Namer(prey))
		endIf
		return false
		/;
	elseif !doBleedoutVore && prey.IsBleedingOut()
		if DEBUGGING
			Log1(PREFIX, "DoANom", "Bleeding out and BleedoutVore is disabled.")
		endIf
		return false

	elseif prey.hasMagicEffectWithKeyword(BeingSwallowed)
		if DEBUGGING
			Log2(PREFIX, "DoANom", "Already being swallowed", Namer(prey))
		endIf
		return false

	elseif pred.getDistance(prey) > reach
		if DEBUGGING
			Log4(PREFIX, "DoANom", "Too far", Namer(prey), pred.getDistance(prey), reach)
		endIf

		if combatSpellsCount > 0
			int selection = Utility.RandomInt(0, combatSpellsCount - 1)
			CombatSpells[selection].Cast(pred, prey)
		endIf
		return false

	elseif Manager.GetFullnessWith(pred, prey) > 1.5
		if DEBUGGING
			Log1(PREFIX, "DoANom", "Too full")
		endIf
		return false

	elseif !doCorpseVore && prey.IsDead()
		if DEBUGGING
			Log1(PREFIX, "DoANom", "Already dead")
		endIf
		return false

	else
		if DEBUGGING
			Log3(PREFIX, "DoANom", predName, Namer(prey, true), "Nomming")
		endIf
		VoreSpell.cast(pred, prey)
		return true
	endIf
EndFunction

;/
Ordinarily, NPCs are only allowed to make Swallow rolls against targets that are below 50% hp, or targets they are higher level than. 
I understand why this was written this way, but it causes a lot of uncertainty with users and would be better as roll-bias the user can set in MCM explicitly.

bool Function isWeakened(Actor prey)
	if prey.GetActorValuePercentage("Health") <= 0.50 
		if DEBUGGING
			Log2(PREFIX, "isWeakened", Namer(prey), "Health is below 50%")
		endIf
		return true
	elseif prey.getLevel() < pred.getLevel()
		if DEBUGGING
			Log2(PREFIX, "isWeakened", Namer(prey), "Lower level than predator")
		endIf
		return true
	else
		return false
	endIf
EndFunction
/;


bool Function PlayerCheck(Actor target)
	if target == PlayerRef
		return Manager.playerPreference != 1
	else
		return Manager.playerPreference != 2
	endIf
EndFunction
