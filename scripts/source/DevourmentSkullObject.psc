ScriptName DevourmentSkullObject extends ObjectReference
import Logging

Actor Prey
; PERSISTENCE NOTES: "When any variable in a currently loaded script points at a reference, that reference is temporarily persistent. 
; It will stay persistent until no variables are pointing at it any more, at which point it will unload. (This assumes no other game system is keeping the object alive) 
; This means that you should try not to have variables holding on to objects any longer then you need them. You can clear variables by assigning "None" to them." 
; https://www.creationkit.com/index.php?title=Persistence_(Papyrus)#Variables
;
; We used to use LinkedRef and StorageUtil as solutions for keeping Prey persistent and stored in Skull objects. We did this because this would
; allow us to keep Actors persistent without increasing save script data / papyrus heap size, instead offloading to the SKSE co-save. Unfortunately both these methods were not always reliable.
; So for now, we're just going to use a known safe method, an Actor Var, even though it adds a bit of weight to the save.

;String PREFIX = "DevourmentSkullObject"

bool Function IsInitialized()
	return Prey != None
EndFunction

Actor Function GetRevivee()
	return Prey
EndFunction

Function InitializeFor(Actor akPrey)
	Self.SetDisplayName(Namer(akPrey, true) + "'s Skull")
	Prey = akPrey
EndFunction

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
	If akOldContainer as DevourmentBolus && !akNewContainer as DevourmentBolus
		;It is important that the result of this call be very deliberate in timing when the thread yields.
		;Yielding at the wrong time causes ref shuffling and the ref to this skull can be lost before the Bolus can swap it.
		(akOldContainer as DevourmentBolus).SkullSwapNew = DevourmentSkullHandler.Instance().CloneSkullToWorld(Self, Prey)
		RegisterForSingleUpdate(6.0)
	EndIf
endEvent

Event OnUpdate()
	Self.Disable()
	Self.Delete()
EndEvent