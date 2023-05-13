ScriptName DevourmentBellyport extends ActiveMagicEffect
import Logging


Actor property PlayerRef auto
DevourmentManager property Manager auto
Explosion property Graphics auto
Message property Message_Full auto
Bool property Endo = False auto

String PREFIX = "Devourment_Bellyport"

Event OnEffectStart(Actor prey, Actor pred)
	;Log3(PREFIX, "OnEffectStart", prey.GetLevel(), aggression, magnitude)
	
	if !(pred && prey)
		assertNotNone(PREFIX, "OnEffectStart", "pred", pred)
		assertNotNone(PREFIX, "OnEffectStart", "prey", prey)
		return
	endif

	if !Manager.HasRoomForPrey(pred, prey)
		If pred == PlayerRef
			Manager.HelpAgnosticMessage(Message_Full, "DVT_FULL", 3.0, 0.1)
			Manager.PlayerFullnessMeter.ForceMeterDisplay(true)
		EndIf
		return
	endIf

	bool stealth = pred.isSneaking() && !pred.isDetectedBy(prey)
	float fMagickaCost = Manager.GetStaminaSwallowCost(pred, prey, stealth, True)
	if pred.GetActorValue("Magicka") >= fMagickaCost
		pred.DamageActorValue("Magicka", fMagickaCost)
		If pred == PlayerRef
			PlayerRef.RampRumble(0.4, 0.5, 1600)
		endIf
	else
		UI.invoke("HUD Menu", "_root.HUDMovieBaseInstance.StartMagickaBlinking")
		Return
	endIf

	int locus = 0
	if pred == PlayerRef
		locus = (Manager.GetAliasById(0) as DevourmentPlayerAlias).DefaultLocus
	endIf
	
	Manager.RegisterDigestion(pred, prey, endo, locus)
	prey.placeatme(Graphics, 1, false, false)
EndEvent
