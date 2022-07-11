Scriptname DevourmentDisability extends ActiveMagicEffect
import Logging
import DevourmentUtil


DevourmentManager property Manager auto
Shout property DummyShout auto
Shout property VomitShout auto
Spell property DummySpell auto
WordOfPower property VomitWord auto
String PREFIX = "DevourmentDisability"


bool DEBUGGING = false
Actor prey
int preyData

Shout StoredShout
Spell StoredSpell

Event OnEffectStart(Actor akTarget, Actor akCaster)
{ Adds the vomit shout, the disabled shout, and the disabled spell. }
	if DEBUGGING
		Log2(PREFIX, "OnEffectStart", Namer(akTarget), Namer(akCaster))
	endIf

	prey = akTarget
	preyData = Manager.GetPreyData(prey)
	
	if !assertExists(PREFIX, "OnEffectStart", "preyData", preyData) \
	|| !assertNotNone(PREFIX, "OnEffectStart", "prey", prey)
		dispel()
		return
	endIf
	StoredShout = prey.GetEquippedShout()
	StoredSpell = prey.GetEquippedSpell(2)

	Game.unlockWord(VomitWord)
	prey.addShout(DummyShout)
	prey.equipShout(DummyShout)
	prey.addSpell(DummySpell, false)
	prey.equipSpell(DummySpell, 0)
	GotoState("Active")
EndEvent


Event onEffectFinish(Actor akTarget, Actor akCaster)
{ Remove the disabled shout and the disabled spell. }
	if DEBUGGING
		Log2(PREFIX, "onEffectFinish", Namer(akTarget), Namer(akCaster))
	endIf
	; Debug.Messagebox("Ended Disability")

	
	GotoState("Inactive")
	if prey && !prey.IsDead()
		prey.unequipSpell(DummySpell, 0)
		prey.unequipShout(DummyShout)
		prey.removeSpell(DummySpell)
		prey.removeShout(DummyShout)
	endIf
	Prey.EquipSpell(StoredSpell, 2)
	Prey.EquipShout(StoredShout)
 
EndEvent


; Event that is triggered when this actor finishes dying
Event OnDeath(Actor akKiller)
	Log2(PREFIX, "OnDeath", Namer(prey), "DIED!")
	if prey == Manager.playerRef
		;gotostate("Inactive")
	endIf
EndEvent


; Event that is triggered when this actor begins to die
Event OnDying(Actor akKiller)
	;Log2(PREFIX, "OnDying", Namer(prey), "DYING!")
	if prey == Manager.playerRef
		gotostate("Inactive")
	endIf
EndEvent


auto state Inactive
endState


state Active
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		if DEBUGGING
			Log2(PREFIX, "OnObjectEquipped", Namer(akBaseObject), Namer(akReference))
		endIf

		Form item
		if akReference
			item = akReference
		else
			item = akBaseObject
		endIf
		
		; Got this from Combat Gameplay Overhaul; it gives any Unequip events time to finish.
		Utility.waitmenumode(0.1)

		if akBaseObject == DummyShout || akBaseObject == DummySpell
			if DEBUGGING
				Log1(PREFIX, "OnObjectEquipped", "Dummy item -- ignoring.")
			endIf
		
		elseif akBaseObject as Spell || akBaseObject as Shout
			if DEBUGGING
				Log1(PREFIX, "OnObjectEquipped", "Spell/Shout -- equipping DummySpell and DummyShout.")
			endIf
			prey.equipSpell(DummySpell, 0)
			prey.equipShout(DummyShout)

		elseif !IsStrippable(item)
			if DEBUGGING
				Log1(PREFIX, "OnObjectEquipped", "!Strippable, ignoring.")
			endIf

		elseif item as Weapon
			if DEBUGGING
				Log1(PREFIX, "OnObjectEquipped", "Weapon -- equipping DummySpell and dropping weapon.")
			endIf
			prey.equipSpell(DummySpell, 0)
			CheckDrop(item)
		
		elseif item as Armor && (item as Armor).IsShield()
			if DEBUGGING
				Log1(PREFIX, "OnObjectEquipped", "Shield -- equipping DummySpell and dropping shield.")
			endIf
			prey.equipSpell(DummySpell, 0)
			CheckDrop(item)
		
		else
			if DEBUGGING
				Log1(PREFIX, "OnObjectEquipped", "Something -- dropping the something.")
			endIf
			CheckDrop(item)
		endIf
	endEvent


	Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
		{ If the dummyspell or dummyshout have been unequipped, reequip them. }
		if DEBUGGING
			Log2(PREFIX, "OnObjectUnEquipped", Namer(akBaseObject), Namer(akReference))
		endIf
		
		; Got this from Combat Gameplay Overhaul; it gives any Equip events time to finish.
		Utility.WaitMenuMode(0.1)

		if akBaseObject == DummySpell
			if prey.GetEquippedSpell(0) != DummySpell
				Log1(PREFIX, "OnObjectUnEquipped", "DummySpell -- re-equipping DummySpell.")
				prey.equipSpell(DummySpell, 0)
			endIf
		
		elseif akBaseObject == DummyShout
			if prey.GetEquippedShout() != DummyShout
				Log1(PREFIX, "OnObjectUnEquipped", "DummyShout -- re-equipping DummyShout.")
				prey.equipShout(DummyShout)
			endIf
		endIf
	endEvent
endState


bool Function CheckDrop(Form item)
	Actor pred = Manager.GetPred(preyData)
		
	if item as Weapon
		Log3(PREFIX, "CheckDrop", "Dropping", Namer(pred), Namer(item))
		prey.unequipItem(item, false, true)
		Debug.Notification("Oops! Dropped your weapon.")
		return Manager.DigestItem(pred, item, 1, prey)
		
	elseif item as Armor
		Log3(PREFIX, "CheckDrop", "Dropping", Namer(pred), Namer(item))
		
		Armor worn = item as Armor
		if worn.isHeavyArmor() || worn.isLightArmor()
			prey.unequipItem(item, false, true)
			Debug.Notification("Oops! Dropped your armor.")
			return Manager.DigestItem(pred, item, 1, prey)
		
		elseif worn.IsShield()
			prey.unequipItem(item, false, true)
			Debug.Notification("Oops! Dropped your shield.")
			return Manager.DigestItem(pred, item, 1, prey)
		
		elseif worn.isClothing()
			prey.unequipItem(item, false, true)
			Debug.Notification("Oops! Dropped your clothes.")
			return Manager.DigestItem(pred, item, 1, prey)
		endIf
	endIf

	return false
EndFunction


bool Function IsStrippable(Form item)
{ Checks if an item should be removed during digestion or not. }
	if item == None || !item.isPlayable() || item.HasKeywordString("SexlabNoStrip")
		return false
	elseif item as ObjectReference
		ObjectReference ref = item as ObjectReference
		return ref.GetBaseObject().GetName() == "" || PO3_SKSEFunctions.IsQuestItem(ref) || PO3_SKSEFunctions.IsVIP(ref)
	else
		return true
	endIf
endFunction