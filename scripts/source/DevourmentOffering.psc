Scriptname DevourmentOffering extends ActiveMagicEffect
import DevourmentUtil
import Logging


DevourmentManager property Manager auto
Keyword property OfferingLink auto
Package property ApproachAndSwallow auto


String PREFIX = "DevourmentOffering"
Actor pred
Actor prey


Event OnEffectStart(Actor akTarget, Actor akCaster)
	if !assertNotNone(PREFIX, "onEffectStart", "akTarget", akTarget) \
	|| !assertNotNone(PREFIX, "onEffectStart", "akCaster", akCaster)
		return
	endIf

	pred = akTarget
	prey = akCaster
	pred.StopCombat()
	Manager.VoreConsent(prey)

	PO3_SKSEFunctions.SetLinkedRef(pred, prey, OfferingLink)
	ActorUtil.AddPackageOverride(pred, ApproachAndSwallow, 100, 0)
	pred.EvaluatePackage()

	prey.SheatheWeapon()
	;Debug.SendAnimationEvent(prey, "IdlePrayCrouchedEnter")
	
	RegisterForSingleUpdate(1.0)
EndEvent


Event OnUpdate()
	if pred.isHostileToActor(prey)
		Manager.forceSwallow(pred, prey, false)
	else
		Manager.forceSwallow(pred, prey, true)
	endIf
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
	PO3_SKSEFunctions.SetLinkedRef(pred, none, OfferingLink)
	ActorUtil.RemovePackageOverride(pred, ApproachAndSwallow)
	pred.EvaluatePackage()
EndEvent



Event OnPackageEnd(Package akOldPackage)
	PO3_SKSEFunctions.SetLinkedRef(pred, none, OfferingLink)
	ActorUtil.RemovePackageOverride(pred, ApproachAndSwallow)
	pred.EvaluatePackage()
EndEvent

