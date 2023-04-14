ScriptName DevourmentBolus extends ObjectReference
import Logging


DevourmentManager property Manager auto
Container property DropperContainer auto
MiscObject property Gold auto


String PREFIX = "DevourmentBolus"
Actor property intialPred auto
Actor property owner auto
String property name auto
Faction property PlayerFaction auto
bool property eatConsumables = true auto

ObjectReference Property SkullSwapNew Auto
{Intended to be left un-filled. Is used as temporary storage for Cloned Skulls.}

bool DEBUGGING = false
float angleZ = 0.0
float force = 10.0
int value = 0
int totalCount = 0
ObjectReference dropper = none


Event OnInit()
EndEvent


Function Initialize(String newName, Actor newOwner, Actor newPred, bool consume = true)
	SetName(newName)
	owner = newOwner
	intialPred = newPred
	eatConsumables = consume

	SetActorOwner(owner.GetLeveledActorBase())
	SetFactionOwner(None)
EndFunction


bool Function IsEmpty()
	return totalCount <= 0 && GetNumItems() <= 0 && GetWeight() <= 0.0
EndFunction


Function setName(String newName)
	name = newName
	parent.SetName(newName)
	SetDisplayName(newName)
EndFunction


String Function getName()
	return name
EndFunction


float Function getWeight()
	;Log4(PREFIX, "getWeight", weight, baseWeight, armorWeight, itemWeight)
	return GetTotalItemWeight()
EndFunction


int Function GetGoldValue()
	return value
EndFunction


ObjectReference Function enableDropping(ObjectReference loc, float newAngleZ, float newForce)
	if DEBUGGING
		Log3(PREFIX, "enableDropping", Namer(loc), newAngleZ, newForce)	
	endIf
	
	if !dropper
		dropper = loc.placeAtMe(DropperContainer)
	else
		dropper.moveTo(loc)
	endIf
	
	angleZ = newAngleZ
	force = newForce
	
	gotostate("DropState")
	return dropper
EndFunction


Function disableDropping()
	gotostate("DefaultState")
EndFunction


Function OnItemAdded(Form baseItem, int itemCount, ObjectReference itemReference, ObjectReference source)
	if DEBUGGING
		Log7(PREFIX, "OnItemAdded", Namer(baseItem), itemCount, Namer(itemReference), Namer(source), totalCount, self.GetGoldValue(), self.GetWeight())
	endIf
	
	totalCount += itemCount

	; For edible forms (potions and ingredients), feed them to the owner.
	if eatConsumables && (baseItem as Potion || baseItem as Ingredient)
		if DEBUGGING 
			Log4(PREFIX, "OnItemAdded", "CONSUMING", Namer(baseItem), Namer(itemReference), itemCount)
		endIf
		
		if Manager.ConsumeItem(intialPred, baseItem, itemReference, itemCount)
			if itemReference
				RemoveItem(itemReference, itemCount, true, intialPred)
			else
				RemoveItem(baseItem, itemCount, true, intialPred)
			endIf
		endIf

	elseif itemReference
		value += itemReference.getGoldValue() * itemCount
	else
		value += baseItem.getGoldValue() * itemCount
	endIf

	if DEBUGGING
		Log3(PREFIX, "OnItemAdded", totalCount, self.GetGoldValue(), self.GetWeight())
	endIf
EndFunction


state DropState
	Function OnItemRemoved(Form baseItem, int itemCount, ObjectReference itemReference, ObjectReference destination)
		if DEBUGGING
			Log4(PREFIX, "DropState.OnItemRemove", Namer(baseItem), itemCount, Namer(itemReference), Namer(destination))
		endIf

		bool havok = force > 0.0 && baseItem.GetWeight() >= 1.0

		; Singular item, so we probably got an ItemReference handle too.
		; Drop it, disown it, and apply a havok impulse.
		if itemCount == 1
			;Actor rev = (baseItem as DevourmentSkullObject).GetRevivee()
			;Debug.MessageBox("1 Revivee: " + rev)

			ObjectReference ref = destination.DropObject(baseItem, 1)

			;When we Drop skulls, the SkullObject script is reinstantiated, clearing the Prey Variable.
			;To preserve the Prey Variable, we make a new skull via OnContainerChange Event, then swap the "real" dropped skull with the new clone skull here.
			If ref as DevourmentSkullObject
				While SkullSwapNew == None
					Utility.Wait(0.01)
				EndWhile
				ref.Disable()
				SkullSwapNew.MoveTo(Ref)
				ref.Delete()
				itemReference = SkullSwapNew
				itemReference.Enable()
			Endif

			if itemReference && havok
				int count = 0
				while !itemReference.is3DLoaded() && count < 10
					Utility.Wait(0.01)
					count += 1
				endWhile
				if count < 10
					itemReference.ApplyHavokImpulse(Math.sin(angleZ), Math.cos(angleZ), 1.0, force)
				endIf
			endIf

		; Infinitely stackable item. Drop it as one stack.
		elseif baseItem as Ammo || baseItem as Ingredient
			ObjectReference ref = destination.DropObject(baseItem, itemCount)
			if ref && havok
				ref.ApplyHavokImpulse(Math.sin(angleZ), Math.cos(angleZ), 1.0, force)
			endIf

		; Big stack. Separate it into ten smaller stacks.
		; Don't apply a havok imulse, it causes terrifying problems.
		elseif itemCount > 10
			int bunchSize = itemCount / 10
			int i = itemCount
			while i > bunchSize
				ObjectReference ref = destination.DropObject(baseItem, bunchSize)
				i -= bunchSize
			endWhile
			ObjectReference ref = destination.DropObject(baseItem, i)
		
		; Small stack. 
		else
			int i = itemCount
			while i
				ObjectReference ref = destination.DropObject(baseItem, 1)
				if ref && havok
					ref.ApplyHavokImpulse(Math.sin(angleZ), Math.cos(angleZ), 1.0, force)
				endIf
				i -= 1
			endWhile
		endIf
	
		totalCount -= itemCount
		if totalCount <= 0
			gotostate("DeleteState")
		endIf
	endFunction
endState


auto state DefaultState
	Function OnItemRemoved(Form baseItem, int itemCount, ObjectReference itemReference, ObjectReference destination)
		if DEBUGGING
			Log4(PREFIX, "DefaultState.OnItemRemove", Namer(baseItem), itemCount, Namer(itemReference), Namer(destination))
		endIf

		totalCount -= itemCount
	endFunction
endState


state DeleteState
	event onBeginState()
		;Log0(PREFIX, "DeleteState.onBeginState")
		registerForSingleUpdate(2.0)
	endEvent
	event OnUpdate()
		;Log0(PREFIX, "DeleteState.OnUpdate")
		if dropper != none
			dropper.disableNoWait()
			dropper.delete()
		endIf
		
		disableNoWait()
		delete()
	endEvent
endState

