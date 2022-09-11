Scriptname DevourmentBurp extends ActiveMagicEffect 


DevourmentManager Property Manager auto
Perk Property EpicGas auto
Explosion property BurpExplosion auto
Explosion property FartExplosion auto
Spell property GiantStomp auto
ImpactDataSet property FXDragonLandingImpactSet auto


bool property Oral auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	if DevourmentMCM.Instance().GentleGas
		;
	elseif akCaster.hasPerk(EpicGas)
		if oral
			;akCaster.PlayImpactEffect(FXDragonLandingImpactSet, "NPC Head [Head]", 0, 0, -1, 512)
			;akCaster.KnockAreaEffect(10.0, 256.0)
			GiantStomp.Cast(akTarget, akCaster)
		else
			akCaster.PlayImpactEffect(FXDragonLandingImpactSet, "Butt", 0, 0, -1, 512)
			akCaster.KnockAreaEffect(1.0, 256.0)
		endIf
	else
		if oral
			akCaster.PlaceAtMe(BurpExplosion)
		else
			akCaster.PlaceAtMe(FartExplosion)
		endIf
	endIf
	
	Manager.playBurp(akCaster, Oral)
EndEvent
