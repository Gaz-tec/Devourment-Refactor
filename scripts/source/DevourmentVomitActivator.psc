scriptName DevourmentVomitActivator extends ObjectReference
import DevourmentUtil
import Logging


Actor property playerRef auto
ActorBase[] property PuddleSkeevers auto
Container property Pile_Vomit_Classic auto
Container property PuddleActivator auto
Container[] property Piles auto
DevourmentManager property Manager auto
EffectShader property slimeEffect auto
EffectShader property bloodEffect1 auto
EffectShader property bloodEffect2 auto
Explosion property vomitExplosion_Knockdown auto
Idle property ResetIdle auto
Form property SkeeverBone auto
Perk property StickTheLanding auto
Perk property HungryBones auto
Spell property DontSwallowMe auto
Spell property NotThere auto
float property slimeDuration auto
int property slot auto


String PREFIX = "DevourmentVomitActivator"
;DevourmentPuddle puddleRef
String puddleMorph
float puddleProgress
float puddleIncrement
float puddleInterval


function OnInit()
	Manager.getNextVomit(self)
	RegisterForSingleUpdate(1.0)
endFunction


Function vomitLive(Actor pred, Actor prey, bool endo, int locus)
	if pred == playerRef || prey == playerRef || pred.isNearPlayer()
		if prey.hasPerk(StickTheLanding) || pred.isDead()
			if locus != 2
				self.placeAtMe(vomitExplosion_Knockdown)
			endIf
			
			Manager.reappearPreyAt(prey, self)
			if DevourmentManager.WaitUntilPresent(prey, self)
				slimeEffect.play(prey, slimeDuration)
				DontSwallowMe.Cast(prey, prey)
			endIf
			
		else
			Manager.reappearPreyAt(prey, self)
			if DevourmentManager.WaitUntilPresent(prey, self)
				pred.pushActorAway(prey, 5.0)
				
				if locus != 2
					Utility.wait(0.05)
					prey.placeAtMe(vomitExplosion_Knockdown)
				endIf
				
				slimeEffect.play(prey, slimeDuration)
				DontSwallowMe.Cast(prey, prey)
			endIf
		endIf
		
		if Manager.GivePartingGift(prey)
			pred.DamageActorValue("Health", 200.0)
			bloodEffect1.play(pred, 10.0)
			bloodEffect2.play(pred, 10.0)
		endIf

	else
		Manager.reappearPreyAt(prey, self, vertical=42.0)
	endif
EndFunction


Function vomitDead(Actor pred, Actor prey, int locus)
	if locus != 2 && (pred == playerRef || pred.isNearPlayer())
		self.SetAngle(0.0, 0.0, pred.GetAngleZ())
		self.placeAtMe(vomitExplosion_Knockdown)
	endIf
	
	ObjectReference pile
	
	if pred.HasPerk(HungryBones) && prey.HasKeywordString("ActorTypeNPC")
		pile = VomitSkeleton(pred, prey, locus)
		ConsoleUtil.SetSelectedReference(prey)
		ConsoleUtil.ExecuteCommand("unequipall")
	elseif Manager.VomitStyle == 1
		pile = SpawnPuddle1(locus)
	elseif Manager.VomitStyle == 2
		pile = SpawnSkeeverpuddle2(locus)
	else
		pile = self.placeAtMe(Pile_Vomit_Classic)
		pile.setAngle(0.0, 0.0, 0.0)
	endIf
	
	prey.removeAllItems(pile, false, true)
EndFunction


Function vomitBolus(Actor pred, DevourmentBolus bolus)
	self.SetAngle(0.0, 0.0, pred.GetAngleZ())
	Manager.reappearBolusAt(bolus, self, front = true, vertical=72.0)
	self.placeAtMe(vomitExplosion_Knockdown)
EndFunction


Function vomitItem(Actor pred, ObjectReference item)
	self.SetAngle(0.0, 0.0, pred.GetAngleZ())
	Manager.reappearItemAt(item, self, front = true)
	self.placeAtMe(vomitExplosion_Knockdown)
EndFunction


ObjectReference Function VomitSkeleton(Actor pred, Actor prey, int locus)
	Actor pile = self.placeAtMe(Manager.GetBonesType(prey), 1, true, true) as Actor

	float angleZ = pred.GetAngleZ()
	pred.PushActorAway(pile, 5.0)
	pile.kill()
	pile.Enable()
	pile.setAlpha(0.0)
	pile.setScale(prey.GetScale())
	pile.SetDisplayName("Bones (" + Namer(prey, true) + ")")
	pile.setAlpha(1.0, true)
		
	if locus != 2
		Utility.wait(0.05)
		pile.placeAtMe(vomitExplosion_Knockdown)
	endIf
	
	slimeEffect.play(prey, slimeDuration)
	Manager.RaiseDead_async(pred, pile)
	return pile
EndFunction


ObjectReference Function SpawnPuddle1(int locus)
	ObjectReference puddleRef

	if locus >= 0 && locus < Piles.length
		puddleRef = self.placeAtMe(Piles[locus])
	else
		puddleRef = self.placeAtMe(Piles[0])
	endIf
	puddleRef.setAngle(0.0, 0.0, 0.0)

	ObjectReference pile = self.placeAtMe(PuddleActivator, 1, false, true)
	pile.setAngle(0.0, 0.0, 1.0)
	pile.setScale(1.0)	;TODO: adjust based on specific pile. Some piles should scale volumetrically, others should not as they include static assets like dragon bones.

	pile.SetActorOwner(None)
	pile.SetFactionOwner(None)

	pile.EnableNoWait(true)
	return pile
EndFunction


ObjectReference Function SpawnSkeeverpuddle2(int locus)
	DevourmentPuddle puddleRef
	
	if locus >= 0 && locus < PuddleSkeevers.length
		puddleRef = self.PlaceAtMe(PuddleSkeevers[locus], 1, false, true) as DevourmentPuddle
	else
		puddleRef = self.PlaceAtMe(PuddleSkeevers[0], 1, false, true) as DevourmentPuddle
	endIf

	puddleRef.Initialize(self)

	ObjectReference pile = self.placeAtMe(PuddleActivator, 1, false, true)
	pile.setAngle(0.0, 0.0, 1.0)
	pile.setScale(1.0)	;TODO: adjust based on specific pile. Some piles should scale volumetrically, others should not as they include static assets like dragon bones.

	pile.SetActorOwner(None)
	pile.SetFactionOwner(None)

	pile.EnableNoWait(true)

	return pile
EndFunction


Event OnUpdate()
	disable(true)
	delete()
EndEvent


