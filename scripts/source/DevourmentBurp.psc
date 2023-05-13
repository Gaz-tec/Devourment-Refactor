Scriptname DevourmentBurp extends ActiveMagicEffect 


DevourmentManager Property Manager auto
Perk Property EpicGas auto
Explosion property BurpExplosionLarge auto
Explosion property FartExplosionLarge auto
Explosion property BurpExplosionSmall auto
Explosion property FartExplosionSmall auto
;Spell property GiantStomp auto
;ImpactDataSet property FXDragonLandingImpactSet auto

bool property SendModEvent = true auto
bool property Oral auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
	Manager.PlayBurp_async(akCaster, oral, SendModEvent)
	if DevourmentMCM.Instance().GentleGas
		;
	elseif akCaster.hasPerk(EpicGas)
		if oral
			;akCaster.PlayImpactEffect(FXDragonLandingImpactSet, "NPC Head [Head]", 0, 0, -1, 512)
			;akCaster.KnockAreaEffect(10.0, 256.0)
			;GiantStomp.Cast(akTarget, akCaster)
			akCaster.PlaceAtMe(BurpExplosionLarge)
		else
			;akCaster.PlayImpactEffect(FXDragonLandingImpactSet, "Butt", 0, 0, -1, 512)
			;akCaster.KnockAreaEffect(1.0, 256.0)
			akCaster.PlaceAtMe(FartExplosionLarge)
		endIf
	else
		if oral
			akCaster.PlaceAtMe(BurpExplosionSmall)
		else
			akCaster.PlaceAtMe(FartExplosionSmall)
		endIf
	endIf
EndEvent
