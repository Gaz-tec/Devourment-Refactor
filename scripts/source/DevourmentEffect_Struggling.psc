ScriptName DevourmentEffect_Struggling extends ActiveMagicEffect
import Logging


DevourmentManager property Manager auto
DevourmentDialog property DialogQuest auto
Actor property PlayerRef auto
Message property StruggleTutorial auto
;TalkingActivator property Talker auto
;Topic property StrugglePrompt auto
;GlobalVariable property PlayerStruggleNext auto
Perk property ConstrictingGrip auto
CommonMeterInterfaceHandler property PlayerStruggleMeter auto


String PREFIX = "DevourmentEffect_Struggling"
bool DEBUGGING = true

Actor pred
;DevourmentTalker strugglePrompter
int preyData
bool constricted
;bool complexStruggles
float cameraShake
float struggleDifficulty 
float struggleDamage
String playerName 

float struggleScaling = 0.2
;int BLOCK_KEY = 0
;int ATTACK_KEY = 0
int[] STRUGGLE_KEYS
;int STRUGGLE_KEY2 = 0
bool StruggleLatch = false
float struggleProgress = 0.0
;int selectedStruggleKey = 0


Event OnEffectStart(Actor target, Actor caster)
	preyData = Manager.GetPreyData(PlayerRef)
	playerName = Namer(PlayerRef, true)

	pred = Manager.GetPred(preyData)
	;complexStruggles = Manager.ComplexStruggles
	
	constricted = pred.hasPerk(ConstrictingGrip)
	cameraShake = Manager.cameraShake
	struggleDifficulty = Manager.struggleDifficulty
	struggleDamage = Manager.GetStruggleDamage(pred, PlayerRef)

	;if complexStruggles
		struggleScaling = 0.5
		;strugglePrompter = PlayerRef.PlaceAtMe(Talker) as DevourmentTalker
		;strugglePrompter.PrepareForDialog(none)

		if Game.UsingGamepad()
			STRUGGLE_KEYS = new int[4]
			STRUGGLE_KEYS[0] = Input.GetMappedKey("Left Attack/Block", 2)
			STRUGGLE_KEYS[1] = Input.getMappedKey("Right Attack/Block", 2)
			STRUGGLE_KEYS[2] = Input.GetMappedKey("Activate", 2)
			STRUGGLE_KEYS[3] = Input.getMappedKey("Ready Weapon", 2)
		else
			STRUGGLE_KEYS = new int[4]
			STRUGGLE_KEYS[0] = Input.getMappedKey("Strafe Left")
			STRUGGLE_KEYS[1] = Input.getMappedKey("Strafe Right")
			STRUGGLE_KEYS[2] = Input.getMappedKey("Forward")
			STRUGGLE_KEYS[3] = Input.getMappedKey("Back")
		endIf
		;/
	else
		struggleScaling = 0.2

		if Game.UsingGamepad()
			STRUGGLE_KEYS = new int[2]
			STRUGGLE_KEYS[0] = Input.GetMappedKey("Left Attack/Block", 2)
			STRUGGLE_KEYS[1] = Input.getMappedKey("Right Attack/Block", 2)
		else
			STRUGGLE_KEYS = new int[2]
			STRUGGLE_KEYS[0] = Input.getMappedKey("Strafe Left")
			STRUGGLE_KEYS[1] = Input.getMappedKey("Strafe Right")
		endIf
	endIf
	/;
	;selectedStruggleKey = STRUGGLE_KEYS[0]
	StruggleLatch = true
	RegisterForKey(STRUGGLE_KEYS[0])
	RegisterForKey(STRUGGLE_KEYS[1])
	RegisterForKey(STRUGGLE_KEYS[2])
	RegisterForKey(STRUGGLE_KEYS[3])
	ResolvePlayerStruggle(0)

	If !Manager.StruggleTutorialShown
		Manager.StruggleTutorialShown = True
		StruggleTutorial.Show()
	EndIf

	if DEBUGGING
		!assertNotNone(PREFIX, "Struggle", "pred", pred)
		!assertExists(PREFIX, "Struggle", "preyData", preyData)
		Log3(PREFIX, "OnEffectStart", Namer(pred), constricted, struggleDamage)
	endIf
	
	;BLOCK_KEY = Input.GetMappedKey("Left Attack/Block")
	;ATTACK_KEY = Input.GetMappedKey("Right Attack/Block")

	;RegisterForKey(ATTACK_KEY)
	;RegisterForKey(BLOCK_KEY)
EndEvent


Event OnEffectFinish(Actor target, Actor caster)
	PlayerStruggleMeter.RemoveMeter()

	;if strugglePrompter
	;	strugglePrompter.Disable()
	;	strugglePrompter.Delete()
	;endIf
EndEvent

;/
Event OnPlayerLoadGame()
	if strugglePrompter
		strugglePrompter.ShowPrompt(StrugglePrompt)
	endIf
EndEvent
/;

Function updateStruggleMeter(float struggle)
	PlayerStruggleMeter.AttributeValue.setValue(struggle)
	PlayerStruggleMeter.UpdateMeter(true)
endFunction	


Event OnKeyUp(int keyCode, float holdTime)
	;/if keyCode == ATTACK_KEY
		if Game.GetCameraState() == 0
			Debug.SendAnimationEvent(PlayerRef, "AttackStartH2HRight")
		endIf
	elseif keyCode == BLOCK_KEY
		if Game.GetCameraState() == 0
			Debug.SendAnimationEvent(PlayerRef, "AttackStartH2HLeft")
		endIf
	endIf/;
	
	if StruggleLatch && (STRUGGLE_KEYS.find(keyCode) >= 0)
		StruggleLatch = false
		if !DialogQuest.Activated && DevourmentUtil.SafeProcess() && Manager.canStruggle(playerRef, preyData)
			ResolvePlayerStruggle(keyCode)
		else
			StruggleLatch = true
		endIf
	endIf
EndEvent


Function ResolvePlayerStruggle(int keyCode)
	bool successful = (keyCode == STRUGGLE_KEYS[0] || keyCode == STRUGGLE_KEYS[1] || keyCode == STRUGGLE_KEYS[2] || keyCode == STRUGGLE_KEYS[3]) && (keyCode != 0)

	;if successful
		;selectedStruggleKey = GetNextStruggleKey()
		;RegisterForKey(selectedStruggleKey)
	;endIf

	; Chance in the struggle bar.
	float increment = struggleDifficulty * struggleScaling
	float damage = struggleDamage * struggleScaling

	if DEBUGGING
		Log5(PREFIX, "ResolvePlayerStruggle", keyCode, successful, increment, damage, struggleProgress)
	endIf

	if constricted
		increment *= 0.2
	endIf
	
	if successful
		struggleProgress += increment
		if struggleProgress > 100.0
			struggleProgress = 100.0
		endIf
	else
		struggleProgress -= increment
		if struggleProgress < 0.0
			struggleProgress = 0.0
		endIf
	endIf

	UpdateStruggleMeter(struggleProgress)
	StruggleLatch = true

	; Struggle damage dealt to pred.
	Manager.playGurgle(pred, 10.0 * struggleScaling)

	if cameraShake > 0.0 && Utility.RandomFloat() < struggleScaling
		Game.ShakeCamera(pred, cameraShake)
	endIf

	; Vomit the prey if they've filled the strugglebar.
	if struggleProgress >= 100.0
		Manager.CheckAndSetPartingGift(pred, PlayerRef)
		Manager.ForceEscape(PlayerRef)
	; Otherwise display the struggle prompt.
	;elseif strugglePrompter
	;	strugglePrompter.ShowPrompt(StrugglePrompt)
	endIf

	if !successful
		return
	endIf

	; Apply damage and show notifications.
	if constricted
		if DEBUGGING
			ConsoleUtil.PrintMessage(PlayerName + " struggled " + struggleProgress as int + " percent free.")
		endIf
	else
		pred.DamageActorValue("Health", damage)
		if DEBUGGING
			ConsoleUtil.PrintMessage(PlayerName + " struggled " + struggleProgress as int + " percent free, causing " + damage + " damage.")
		endIf
	endIf

	int handle = ModEvent.Create("Devourment_PlayerStruggle")
	ModEvent.Send(handle)

	;Manager.GivePreyXP_async(PlayerRef, damage / 5.0)
	Manager.GivePredXP_async(PlayerRef, damage / 5.0)
	if !constricted
		Manager.GivePredXP_async(pred, damage / 5.0)
	endIf	
EndFunction

;/
int Function GetNextStruggleKey()
	if complexStruggles
		int prev = STRUGGLE_KEYS.find(selectedStruggleKey)
		int next = Utility.RandomInt(0, 2)
		if next >= prev
			next += 1
		endIf

		if Game.UsingGamepad()
			PlayerStruggleNext.SetValue(next as float + 4.0)
		else
			PlayerStruggleNext.SetValue(next as float)
		endIf

		return STRUGGLE_KEYS[next]
	else
		if selectedStruggleKey == STRUGGLE_KEYS[0]
			return STRUGGLE_KEYS[1]
		else
			return STRUGGLE_KEYS[0]
		endIf
	endIf
EndFunction
/;
