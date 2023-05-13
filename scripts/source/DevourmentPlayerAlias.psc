ScriptName DevourmentPlayerAlias extends SKI_PlayerLoadGameAlias
{}
import Logging
import DevourmentUtil
import Devourment_JCDomain


DevourmentManager property Manager auto
DevourmentMCM property DevourMCM auto
DevourmentDialog property DialogQuest auto
Actor Property PlayerRef auto
Faction property Follower auto
Furniture property BedRoll auto
GlobalVariable property VoreDialog auto
GlobalVariable property PlayerIsDead auto
Message property Message_PlayerDigested auto
Message property Message_Puke auto
Message property Message_Excrete auto
Message property Message_Absorb auto
Message[] property Messages_BeingDigested auto
Perk property PlayerAbilities auto
ReferenceAlias property ApexRef auto
ReferenceAlias property PredRef auto
Spell property PlayerStruggleSpell auto
Spell property BeastformVoreSpell auto
Spell[] property SwallowSpells auto
Topic property DigestedDialog auto
int property DefaultLocus = 0 auto


float property INTERVAL = 3.0 autoreadonly
int SHOUT_KEY = 0
;int TOGGLE_POV = 0
int BLOCK_KEY = 0
int ATTACK_KEY = 0


String PREFIX = "DevourmentPlayerAlias"
bool DEBUGGING = false
Actor cameraTarget = none


Message StruggleNotification = none
Topic StruggleTopic = none
Quest CCSurvColdQuest = none


Actor puppet = none
int preyData = 0
bool blocking = false
ObjectReference bedrollRef = none


Event OnInit()
	Utility.wait(3.0)
	Manager.LoadGameChecks()
	RegisterForKey(SHOUT_KEY)
	self.LoadGameChecks()
EndEvent


Event OnControlDown(string sControl)
{ This will prevent the player from sleeping or waiting if they are taking damage -- either from being digested or from prey struggling. }
	Log1(PREFIX, "OnControlDown", sControl)

	If sControl == "Wait"
		if !Manager.relativelySafe(playerRef)
			Game.SetInCharGen(false, true, false)
			UI.InvokeString("Sleep/Wait Menu", "_global.SKSE.CloseMenu", "Sleep/Wait Menu")
		else
			Game.SetInCharGen(false, false, false)
		endIf
	elseif sControl == "Sleep"
		if !Manager.relativelySafe(playerRef)
			Game.SetInCharGen(false, true, false)
			UI.InvokeString("Sleep/Wait Menu", "_global.SKSE.CloseMenu", "Sleep/Wait Menu")
		else
			Game.SetInCharGen(false, false, false)
		endIf
	Endif
EndEvent


Event OnDying(Actor akKiller)
	Log1(PREFIX, "OnDying", Namer(akKiller))
	Manager.RegisterVomitAll(PlayerRef)
EndEvent


Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	Log2(PREFIX, "OnAnimationEvent", Namer(akSource), asEventName)

	if asEventName == "pa_2HWKillMoveA" || \
		asEventName == "pa_KillMove1HMDecap" || \
		asEventName == "pa_KillMove1HMDecapBleedOut" || \
		asEventName == "pa_KillMove1HMDecapKnife" || \
		asEventName == "pa_KillMove2HMDecap" || \
		asEventName == "pa_KillMove2HMDecapBleedOut" || \
		asEventName == "pa_KillMove2HWA" || \
		asEventName == "pa_KillMove2HWDecapBleedOut" || \
		asEventName == "pa_KillMoveDWDecap"

		Log3(PREFIX, "OnAnimationEvent", "Doing the overlay thing.", Namer(akSource), asEventName)

		ClearFaceOverlays(PlayerRef)
	endIf

EndEvent


Event OnPlayerLoadGame()
	Log0(PREFIX, "OnPlayerLoadGame")

	(DevourMCM as ski_questbase).OnGameReload()	;Required by MCM Helper. I did this here just to avoid attaching a load game alias.

	;/
	if DevourMCM.CurrentVersion < DevourMCM.GetVersion()
		Log3(PREFIX, "OnPlayerLoadGame", "UPGRADE REQUIRED", DevourMCM.CurrentVersion, DevourMCM.GetVersion())
		DevourMCM.Upgrade(DevourMCM.CurrentVersion, DevourMCM.GetVersion())
	endIf
	/;

	Manager.LoadGameChecks()
	self.LoadGameChecks()
	Utility.wait(1.0)
EndEvent


;=================================================
; Camera stuff

;Function RegisterForCameraState() native
;Function UnregisterForCameraState() native
; 
Event OnPlayerCameraState(int oldState, int newState)
	{NOT YET IN USE}
	if DEBUGGING
		Log2(PREFIX, "OnPlayerCameraState", "oldState=" + oldState, "newState=" + newState)
	endIf

	if JValue_isExists(preyData)
		if newState == 0
			setCameraTarget(PlayerRef)
		else
			setCameraTarget(ApexRef.GetReference() as Actor)
		endIf
	endIf
EndEvent


;=================================================
; Sleep stuff.

bool Function VoreSleep()
	return false
EndFunction


Event OnSleepStop(bool abInterrupted)
	if BedRollRef != none
		BedRollRef.Disable()
		BedRollRef.Delete()
		BedRollRef = none
	endIf
EndEvent


Function gotoDefault()
	if DEBUGGING
		Log0(PREFIX, "gotoDefault")
	endIf
	
	gotostate("DefaultState")
	PredRef.Clear()
	preyData = 0
EndFunction


Function gotoEndo(int newPreyData)
	if !assertExists(PREFIX, "gotoEndo", "newPreyData", newPreyData)
		return
	endIf
	
	if DEBUGGING
		LogJ(PREFIX, "gotoEndo", newPreyData, Manager.getPred(newPreyData))
	endIf
	
	preyData = newPreyData
	ApexRef.ForceRefTo(Manager.FindApex(PlayerRef))
	PredRef.ForceRefTo(Manager.GetPred(preyData))
	gotostate("PlayerEndo")
EndFunction


Function gotoVore(int newPreyData)
	if !assertExists(PREFIX, "gotoVore", "newPreyData", newPreyData)
		return
	endIf
	
	if DEBUGGING
		LogJ(PREFIX, "gotoVore", newPreyData, Manager.getPred(newPreyData))
	endIf
	
	preyData = newPreyData
	ApexRef.ForceRefTo(Manager.FindApex(PlayerRef))
	PredRef.ForceRefTo(Manager.getPred(preyData))
	gotostate("PlayerVore")
EndFunction


Function CheckClearEliminate()
	if DEBUGGING
		Log0(PREFIX, "CheckClearEliminate")
	endIf
EndFunction


Function gotoEliminate()
	if DEBUGGING
		Log0(PREFIX, "gotoEliminate")
	endIf
	
	gotostate("PlayerEliminate")
EndFunction


Function gotoDead(int newPreyData)
	if !assertExists(PREFIX, "gotoDead", "newPreyData", newPreyData)
		return
	endIf
	
	if DEBUGGING
		LogJ(PREFIX, "gotoDead", newPreyData, Manager.getPred(newPreyData))
	endIf
	
	preyData = newPreyData
	ApexRef.ForceRefTo(Manager.FindApex(PlayerRef))
	PredRef.ForceRefTo(Manager.getPred(preyData))
	gotostate("PlayerIsDead")
EndFunction


Function gotoReforming(int newPreyData)
	if !assertExists(PREFIX, "gotoReforming", "newPreyData", newPreyData)
		return
	endIf
	
	if DEBUGGING
		LogJ(PREFIX, "gotoReforming", newPreyData, Manager.getPred(newPreyData))
	endIf
	
	preyData = newPreyData
	ApexRef.ForceRefTo(Manager.FindApex(PlayerRef))
	PredRef.ForceRefTo(Manager.getPred(preyData))
	gotostate("PlayerIsReforming")
EndFunction


Function StartPlayerStruggle()
	if !PlayerRef.HasSpell(PlayerStruggleSpell)
		PlayerRef.AddSpell(PlayerStruggleSpell, false)
	endIf
EndFunction


Function StopPlayerStruggle()
	if PlayerRef.HasSpell(PlayerStruggleSpell)
		PlayerRef.RemoveSpell(PlayerStruggleSpell)
	endIf
EndFunction

;/
Event OnKeyUp(int keyCode, float holdTime)
	if keyCode == TOGGLE_POV
		if jvalue_isExists(preyData)
			if Game.GetCameraState() != 0
				setCameraTarget(PlayerRef)
				Game.ForceFirstPerson()
				PlayerRef.SetAlpha(255.0)
			else
				setCameraTarget(ApexRef.GetReference() as Actor)
				Game.ForceThirdPerson()
				PlayerRef.SetAlpha(0.0)
			endIf
		endIf
	
	elseif blocking && puppet
		Debug.SendAnimationEvent(puppet, "BlockStop")
		blocking = false
	endIf
endEvent
/;

Function HotkeyDialogue()
	if DEBUGGING
		Log0(PREFIX, "HotkeyDialogue")
	endIf

	if VoreDialog.GetValue() != 0.0 && !DialogQuest.Activated && SafeProcess() && Manager.HasLivePrey(playerRef)
		Actor talker = Manager.FindATalker()
		if talker
			DialogQuest.DoDialog_PlayerAndPrey(talker, false)
		elseif DEBUGGING
			ConsoleUtil.PrintMessage("No live prey found.")
		endIf
	endIf
EndFunction

;/
Event OnKeyDown(int keyCode)
	if KeyCode == SHOUT_KEY
		HotkeyVore(SwallowSpells.find(playerRef.GetEquippedSpell(2)))
	endIf
EndEvent
/;

bool Function HotkeyVore(int i)
	;debug.MessageBox("hotkey")
	if i == 2
		SwallowSpells[2].cast(PlayerRef, PlayerRef)
		return true

	elseif i == 0 || i == 1
		Spell swallowSpell = SwallowSpells[i]
		;debug.MessageBox("try something")
		return TryGrabbedVore(swallowSpell) || TryCrosshairVore(swallowSpell)
	endIf

EndFunction


bool Function TryGrabbedVore(Spell swallowSpell)
	ObjectReference grabbed = Game.GetPlayerGrabbedRef()
	if grabbed == None
		return false
	elseif grabbed as actor
		swallowSpell.cast(PlayerRef, grabbed)
		return true
	else
		Manager.PlayVoreAnimation_Item(playerRef, grabbed, 0, true)
		Manager.DigestItem(playerRef, grabbed, 1, none, false, DefaultLocus)
		return true
	endIf
EndFunction


bool Function TryCrosshairVore(Spell swallowSpell)
	ObjectReference targeted = Game.GetCurrentCrossHairRef()
	if targeted == None 
		if PlayerRef.GetRace() == Manager.WerewolfBeastRace || PlayerRef.GetRace() == Manager.DLC2WerebearBeastRace
			BeastformVoreSpell.Cast(PlayerRef, None)
			;ObjectReference marker = PlayerRef.PlaceAtMe(Manager.AnimationMarker, 1, false, true)
			;marker.MoveTo()
	;	debug.MessageBox("nothing targeted")
		endif
		return false
	elseif targeted as Actor
		swallowSpell.cast(PlayerRef, targeted)
		return true
	elseif !playerRef.IsInCombat() && !playerRef.IsRunning()
		Manager.LooseItemVore(PlayerRef, targeted)
		return true
	else 
		return false
	endIf
EndFunction


Event DA_EndBlackout(string eventName, string strArg, float numArg, Form sender)
EndEvent


;=================================================
; State system for the player.


auto State DefaultState
;/
This state means that the player is free (not prey).
* It initiates dialogue if it's called via the Dialogue Key.
* It transfers the camera to the player.
/;


	Event OnBeginState()
		if DEBUGGING
			Log0(PREFIX, "DefaultState.OnBeginState")
		endIf
		;RegisterForKey(SHOUT_KEY)
		SetCameraTarget(PlayerRef)
		DialogQuest.setStage(0)
	EndEvent

	Event OnEndState()
		UnregisterForKey(SHOUT_KEY)
	EndEvent
	
EndState


State PlayerEliminate
;/
This state means that the player is free (not prey) and has fully digested prey that they need to eliminate.
* It shows a message every few seconds reminding the player of that fact.
/;


	Event onBeginState()
		if DEBUGGING
			Log0(PREFIX, "PlayerEliminate.onBeginState")
		endIf
		RegisterForKey(SHOUT_KEY)
		RegisterForSingleUpdate(0.0)
	EndEvent

	Event onUpdate()
		Manager.HelpAgnosticMessage(Message_Excrete, "DVT_POOP", 1.0, 0.1)
		RegisterForSingleUpdate(20.0)
	EndEvent

	Event onEndState()
		if DEBUGGING
			Log0(PREFIX, "PlayerDefecate.onEndState")
		endIf
		UnRegisterForKey(SHOUT_KEY)
		Message.resetHelpMessage("DVT_POOP")
	EndEvent

	Function gotoEliminate()
		if DEBUGGING
			Log1(PREFIX, "gotoEliminate", "DevourmentPlayerAlias is already in PlayerEliminate state.")
		endIf
	EndFunction

	Function CheckClearEliminate()
		if DEBUGGING
			Log0(PREFIX, "PlayerEliminate.CheckClearEliminate")
		endIf
		
		if !Manager.HasDigested(playerRef)
			gotostate("DefaultState")
		endIf
	EndFunction

EndState


State PlayerVore
;/
This state means that the player is inside a hostile predator.
* It initiates dialogue if it's called via Dialogue Key.
* It transfers the camera to the predator.
/;

	Event onBeginState()
		if DEBUGGING
			Log2(PREFIX, "PlayerVore.onBeginState", AliasNamer(PredRef), AliasNamer(ApexRef))
		endIf
		
		int locus = Manager.GetLocus(preyData)
		if locus >= 0 && locus < Messages_BeingDigested.length
			Manager.HelpAgnosticMessage(Messages_BeingDigested[locus], "DVT_BEINGDIGESTED", 4.0, 0.1)
		else
			Manager.HelpAgnosticMessage(Messages_BeingDigested[0], "DVT_BEINGDIGESTED", 4.0, 0.1)
		endif

		Actor apex = ApexRef.GetReference() as Actor
		SetCameraTarget(Apex)

		if IsControllable(apex, endo = false)
			TakeControlOf(apex)
		endIf

		if Manager.canStruggle(playerRef, preyData)
			StartPlayerStruggle()
		endIf
		
		Game.SetInCharGen(false, true, false)
		
		If CCSurvColdQuest
			(CCSurvColdQuest as Survival_NeedCold).DecreaseCold(600.0, (CCSurvColdQuest as Survival_NeedCold).needStage1Value, false) ;Remove significant Coldness from the player.
		EndIf
	EndEvent


	Function HotkeyDialogue()
		if DEBUGGING
			Log1(PREFIX, "PlayerVore.HotkeyDialogue", "Puppet=" + Namer(Puppet))
		endIf
	
		if Puppet && Puppet.GetPlayerControls()
			ReleaseControlOf(Puppet)			
		elseif VoreDialog.GetValue() != 0.0 && !DialogQuest.Activated && SafeProcess()
			DialogQuest.DoDialog_PlayerAndApex()
		endIf
	EndFunction
	
	
	bool Function HotkeyVore(int i)
		if DEBUGGING
			Log0(PREFIX, "PlayerVore.HotkeyVore")
		endIf
	EndFunction


	Event OnKeyDown(int keyCode)
		if DEBUGGING
			Log1(PREFIX, "PlayerVore.onKeyDown", keyCode)
		endIf
		if CheckAttack(KeyCode)
			;
		endIf
	EndEvent


	Event onEndState()
		if DEBUGGING
			Log2(PREFIX, "PlayerVore.onEndState", AliasNamer(PredRef), AliasNamer(ApexRef))
		endIf
		
		Actor apex = Manager.FindApex(playerRef)
		if apex 
			ReleaseControlOf(apex)
		endIf

		Actor pred = PredRef.GetReference() as Actor
		if pred && pred != apex
			ReleaseControlOf(pred)
		endIf

		StopPlayerStruggle()
		Game.SetInCharGen(false, false, false)
		PO3_SKSEFunctions.ResetActorDetection(playerRef)
	EndEvent


	Function gotoEliminate()
		if DEBUGGING
			Log1(PREFIX, "PlayerVore.gotoEliminate", "Cannot enter PlayerEliminate state when the player is prey.")
		endIf
	EndFunction
	
EndState


State PlayerEndo
;/
This state means that the player is inside a friendly predator.
* It shows a message every few seconds reminding the player that they can shout to escape.
* It initiates dialogue if it's called via Dialogue Key.
* On starting, it assigns player controls to the predator if they are a follower/horse, and removes them on ending.
* It transfers the camera to the predator.
/;


	Event onBeginState()
		if DEBUGGING
			Log2(PREFIX, "PlayerEndo.onBeginState", AliasNamer(PredRef), AliasNamer(ApexRef))
		endIf

		; If the predator is a horse or a follower, this *should* let the player control them.
		Actor apex = ApexRef.GetReference() as Actor
		if IsControllable(apex, endo = true)
			TakeControlOf(apex)
		endIf

		SetCameraTarget(apex)
		RegisterForKey(SHOUT_KEY)
		
		If CCSurvColdQuest
			(CCSurvColdQuest as Survival_NeedCold).DecreaseCold(600.0, (CCSurvColdQuest as Survival_NeedCold).needStage1Value, false) ;Remove significant Coldness from the player.
		EndIf
		
		RegisterForSingleUpdate(0.0)
	EndEvent


	Function onUpdate()
		if Manager.CanEscapeEndo(preyData)
			Manager.HelpAgnosticMessage(Message_Puke, "DVT_VOMIT", 1.0, 0.1)
		endIf

		RegisterForSingleUpdate(10.0)
	EndFunction


	Event OnCombatStateChanged(Actor newTarget, int aeCombatState)
		if aeCombatState > 1 && puppet && puppet.GetPlayerControls()
			ReleaseControlOf(puppet)
		elseif aeCombatState <= 1
			Actor apex = Manager.FindApex(PlayerRef)
			if IsControllable(apex, endo = true)
				TakeControlOf(apex)
			endIf
		endIf
	EndEvent
	
	
	Function HotkeyDialogue()
		if DEBUGGING
			Log1(PREFIX, "PlayerEndo.HotkeyDialogue", "Puppet=" + Namer(Puppet))
		endIf
	
		if Puppet && Puppet.GetPlayerControls()
			ReleaseControlOf(Puppet)			
		elseif VoreDialog.GetValue() != 0.0 && !DialogQuest.Activated && SafeProcess()
			DialogQuest.DoDialog_PlayerAndApex()
		endIf
	EndFunction
	
	
	bool Function HotkeyVore(int i)
		if DEBUGGING
			Log0(PREFIX, "PlayerEndo.HotkeyVore")
		endIf
	EndFunction

	
	Event OnKeyDown(int keyCode)
		if DEBUGGING
			Log1(PREFIX, "PlayerEndo.onKeyDown", keyCode)
		endif
		
		if KeyCode == SHOUT_KEY
			UnRegisterForKey(SHOUT_KEY)
			Manager.RegisterVomit(playerRef)
		elseif CheckAttack(KeyCode)
			;
		endIf
	EndEvent

	
	Event onEndState()
		if DEBUGGING
			Log2(PREFIX, "PlayerEndo.onEndState", AliasNamer(PredRef), AliasNamer(ApexRef))
		endIf
		Message.resetHelpMessage("DVT_VOMIT")
		UnRegisterForKey(SHOUT_KEY)
		
		UnRegisterForKey(Input.getMappedKey("Left Attack/Block", 0))
		UnRegisterForKey(Input.getMappedKey("Right Attack/Block", 0))
		UnRegisterForKey(Input.getMappedKey("Activate", 0))
		
		Actor apex = Manager.FindApex(playerRef)
		if apex
			ReleaseControlOf(apex)
		endIf

		Actor pred = PredRef.GetReference() as Actor
		if pred
			ReleaseControlOf(pred)
		endIf
	EndEvent


	Function gotoEliminate()
		Log1(PREFIX, "PlayerEndo.gotoEliminate", "Cannot enter PlayerEliminate state when the player is prey.")
	EndFunction


	bool Function VoreSleep()
		if BedRollRef != none
			Log1(PREFIX, "PlayerEndo:VoreSleep", "Found old bedroll; deleting.")
			BedRollRef.Disable()
			BedRollRef.Delete()
			BedRollRef = none
		endIf

		Actor apex = Manager.FindApex(playerRef)
		Actor pred = PredRef.GetReference() as Actor

		if apex.IsInCombat() || pred.IsInCombat() || playerRef.IsInCombat()
			ConsoleUtil.PrintMessage("No sleeping in combat!")
			return false
		elseif !SafeProcess()
			ConsoleUtil.PrintMessage("Unsafe process!")
			return false
		elseif !playerRef.HasPerk(DevourMCM.Comfy)
			ConsoleUtil.PrintMessage("Need the Comfy perk!")
			return false
		elseif !Manager.IsPrey(playerRef)
			ConsoleUtil.PrintMessage("Not even inside a stomach. Come on, dude.")
			return false
		elseif !Manager.RelativelySafe(playerRef)
			ConsoleUtil.PrintMessage("Not RelativelySafe!")
			return false
		else
			RegisterForSleep()
			BedRollRef = PlayerRef.placeAtMe(BedRoll)

			; Hand off the activation to DevourmentLocationTracker, because it needs to move the player to the bedroll.
			int handle = ModEvent.Create("DevourmentVoreSleep")
			ModEvent.pushForm(handle, BedRollRef)
			ModEvent.Send(handle)
			return true
		endIf
	EndFunction
	
EndState


State PlayerIsDead
;/
This state means that the player is dead, and has not yet pressed the shout key to finish being digested.
It shows a message every few seconds reminding the player of that fact.
When the shout key is pressed, it will call Manager.KillPlayer() to finish up.
/;

	Event onBeginState()
		if DEBUGGING
			Log2(PREFIX, "PlayerIsDead.onBeginState", AliasNamer(PredRef), AliasNamer(ApexRef))
		endIf
		
		RegisterForKey(SHOUT_KEY)
		PlayerIsDead.SetValue(1.0)

		Actor apex = ApexRef.GetReference() as Actor

		if VoreDialog.GetValue() != 0.0
			Log1(PREFIX, "PlayerIsDead.onBeginState", "Trying to get apex to say digestion dialog")

			if apex && apex.hasKeyword(Manager.ActorTypeNPC) && apex.GetCombatState() == 0
				Log1(PREFIX, "PlayerIsDead.onBeginState", "Do the saying of it")
				apex.say(DigestedDialog, none, true)
			endIf
		EndIf

		if apex && IsControllable(apex, endo = true)
			TakeControlOf(apex)
		endIf

		Game.SetInCharGen(false, true, false)
		RegisterForSingleUpdate(5.0)
	EndEvent


	Event onUpdate()
		Manager.HelpAgnosticMessage(Message_PlayerDigested, "DVT_DEAD", 2.0, 10.0)
		RegisterForSingleUpdate(8.0)
	EndEvent


	Event OnKeyDown(int keyCode)
		if DEBUGGING
			Log1(PREFIX, "PlayerIsDead.onKeyDown", keyCode)
		endIf
		
		if KeyCode == SHOUT_KEY
			if DialogQuest.Activated 
				Log1(PREFIX, "PlayerIsDead.OnKeyDown", "Wait for dialogue to stop.")
			elseif !SafeProcess()
				Log1(PREFIX, "PlayerIsDead.OnKeyDown", "Wait for SafeProcess().")
			else
				UnRegisterForUpdate()
				UnRegisterForKey(SHOUT_KEY)
				Manager.KillPlayer(PredRef.GetReference() as Actor)
			endIf
		endIf
	EndEvent


	Event onEndState()
		if DEBUGGING
			Log0(PREFIX, "PlayerIsDead.onEndState")
		endIf
		
		Message.resetHelpMessage("DVT_DEAD")
		UnRegisterForKey(SHOUT_KEY)
		PlayerIsDead.SetValue(0.0)
		Game.SetInCharGen(false, false, false)

		Actor apex = Manager.FindApex(PlayerRef)
		Actor pred = PredRef.GetReference() as Actor

		if apex 
			ReleaseControlOf(apex)
		endIf
		if pred
			ReleaseControlOf(pred)
		endIf
	EndEvent


	Function HotkeyDialogue()
		if DEBUGGING
			Log0(PREFIX, "PlayerIsDead.HotkeyDialogue")
		endIf
	endFunction


	bool Function HotkeyVore(int i)
		if DEBUGGING
			Log0(PREFIX, "PlayerIsDead.HotkeyVore")
		endIf
	EndFunction

	
	Function gotoEliminate()
		if DEBUGGING
			Log1(PREFIX, "PlayerIsDead.gotoEliminate", "Cannot enter PlayerEliminate state when the player is dead.")
		endIf
	EndFunction


	Event DA_EndBlackout(string eventName, string strArg, float numArg, Form sender)
		gotoDefault()
	EndEvent
	
	
EndState


State PlayerIsReforming
	;/
	This state means that the player is dead but reforming.
	/;
	
	Event onBeginState()
		if DEBUGGING
			Log2(PREFIX, "PlayerIsReforming.onBeginState", AliasNamer(PredRef), AliasNamer(ApexRef))
		endIf
		
		PlayerIsDead.SetValue(1.0)
		Actor apex = ApexRef.GetReference() as Actor

		if apex && IsControllable(apex, endo = true)
			TakeControlOf(apex)
		endIf

		Game.SetInCharGen(false, true, false)
		RegisterForSingleUpdate(5.0)
	EndEvent


	Event onUpdate()
		float percent = Manager.GetDigestionPercent(preyData)
		Debug.Notification(percent + "% reformed")
		RegisterForSingleUpdate(8.0)
	EndEvent


	Function HotkeyDialogue()
		if DEBUGGING
			Log0(PREFIX, "PlayerIsReforming.HotkeyDialogue")
		endIf
	endFunction


	bool Function HotkeyVore(int i)
		if DEBUGGING
			Log0(PREFIX, "PlayerIsReforming.HotkeyVore")
		endIf
	EndFunction

	
	Event onEndState()
		if DEBUGGING
			Log0(PREFIX, "PlayerIsReforming.onEndState")
		endIf
		
		Message.resetHelpMessage("DVT_DEAD")
		PlayerIsDead.SetValue(0.0)
		Game.SetInCharGen(false, false, false)

		Actor apex = Manager.FindApex(PlayerRef)
		Actor pred = PredRef.GetReference() as Actor

		if apex 
			ReleaseControlOf(apex)
		endIf
		if pred && pred != apex
			ReleaseControlOf(pred)
		endIf
	EndEvent


	Function gotoEliminate()
		if DEBUGGING
			Log1(PREFIX, "PlayerIsReforming.gotoEliminate", "Cannot enter PlayerEliminate state when the player is reforming.")
		endIf
	EndFunction


	Event DA_EndBlackout(string eventName, string strArg, float numArg, Form sender)
		gotoDefault()
	EndEvent
	
	
EndState

	
	;=================================================
; Utility functions.


Function CameraAndControlCheck(Actor apex, Actor prey, bool endo)
	{ For an arbitrary apex and prey, make sure that if the player is involved, ApexRef, the camera, and the player controls all get updated. }
	if DEBUGGING
		Log6(PREFIX, "CameraAndControlCheck", "apex=" + Namer(apex), "prey=" + Namer(prey), endo, "PlayerApex=" + Namer(Manager.FindApex(playerRef)), AliasNamer(PredRef), AliasNamer(ApexRef))
	endIf


	if prey != playerRef && prey == Manager.FindApex(playerRef)
		if puppet == prey
			if IsControllable(apex, endo)
				TakeControlOf(apex)
			else
				ReleaseControlOf(prey)
			endIf
		endIf

		ApexRef.ForceRefTo(apex)
		self.SetCameraTarget(apex)
	endIf
EndFunction


Function setCameraTarget(Actor newTarget)
	if newTarget == None
		newTarget = PlayerRef
	endIf

	if newTarget != cameraTarget
		ConsoleUtil.PrintMessage("Switching camera to " + Namer(newTarget))
	endIf

	cameraTarget = newTarget
	Game.setCameraTarget(cameraTarget)
	
	if cameraTarget != playerRef
		Game.ForceFirstPerson()
		Game.ForceThirdPerson()
	endIf

	if DEBUGGING
		Debug.TraceStack("DevourmentPlayerAlias.SetCameraTarget(" + Namer(newTarget) + ")")
	endIf
EndFunction


bool Function isCameraTarget(Actor target)
	return target == cameraTarget
EndFunction


bool function ClearFaceOverlays(Actor target)
	bool isFemale = (target.GetLeveledActorBase().GetSex() != 0)
	String area = "Face"

	int slot = NiOverride.GetNumFaceOverlays()
	while slot
		slot -= 1
		clear_overlay(target, IsFemale, area, slot)
	endWhile
endFunction


Function clear_overlay(Actor target, bool isFemale, string area, int slot) global
	{ Taken entirely from SlaveTats. }
    string nodeName = area + " [ovl" + slot + "]"

	if 1==1
		string overlay_path = NiOverride.GetNodeOverrideString(target, isFemale, nodeName, 9, 0)
		ConsoleUtil.PrintMessage("Removing overlay '" + nodeName + "'' = " + overlay_path)
		if NiOverride.HasNodeOverride(target, isFemale, nodeName, 9, 1)
			ConsoleUtil.PrintMessage(NIOverride.GetNodeOverrideString(target, isFemale, nodeName, 9, 0))
			ConsoleUtil.PrintMessage(NIOverride.GetNodeOverrideString(target, isFemale, nodeName, 9, 1))
			ConsoleUtil.PrintMessage(NIOverride.GetNodeOverrideString(target, isFemale, nodeName, 7, -1))
			ConsoleUtil.PrintMessage(NIOverride.GetNodeOverrideString(target, isFemale, nodeName, 0, -1))
			ConsoleUtil.PrintMessage(NIOverride.GetNodeOverrideString(target, isFemale, nodeName, 8, -1))
		endIf
	endIf

	NiOverride.AddNodeOverrideString(target, isFemale, nodeName, 9, 0, SLAVETATPREFIX() + "blank.dds", true)
    Utility.Wait(0.01)
    if NiOverride.HasNodeOverride(target, isFemale, nodeName, 9, 1)
        NiOverride.AddNodeOverrideString(target, isFemale, nodeName, 9, 1, SLAVETATPREFIX() + "blank.dds", true)
        Utility.Wait(0.01)
        NiOverride.RemoveNodeOverride(target, isFemale, nodeName, 9, 1)
        Utility.Wait(0.01)
    endif
    NiOverride.RemoveNodeOverride(target, isFemale, nodeName, 9, 0)
    Utility.Wait(0.01)
    NiOverride.RemoveNodeOverride(target, isFemale, nodeName, 7, -1)
    Utility.Wait(0.01)
    NiOverride.RemoveNodeOverride(target, isFemale, nodeName, 0, -1)
    Utility.Wait(0.01)
    NiOverride.RemoveNodeOverride(target, isFemale, nodeName, 8, -1)
    Utility.Wait(0.01)
Endfunction


string function SLAVETATPREFIX() global
    return "Actors\\Character\\slavetats\\"
endfunction


;=================================================
; Maintenance functions.


Function LoadGameChecks()
{
This does most of the work of doing all the things that need to happen when the game is loaded.
* It checks if all hard and soft dependencies are present.
* It calls corresponding function in DevourmentManager.
* It check the EasyWheelManager plugin in a way that wont cause a million papyrus log error messages.
* It makes sure that it is registered for events of interest like sleep and wait.
* It makes sure that the player has devourment abilities if they should.
}
	if Manager.IsPrey(playerRef)
		Manager.deactivatePrey(playerRef)

		Actor apex = Manager.findApex(playerRef)
		self.SetCameraTarget(apex)
		Manager.ResetBelly(apex)

		if Manager.IsEndo(preyData)
			PO3_Events_Alias.RegisterForShoutAttack(self)
		endIf
	else
		self.SetCameraTarget(playerRef)
	endIf
	
	Quest EWMDVT = Quest.getQuest("EWM_DVT")
	if Quest.getQuest("_WheelMenuQuest")
		EWMDVT.start()
		EWMDVT.registerForModEvent("Devourment_CheckSpells", "checkPowers")
	else
		EWMDVT.stop()
	endIf

	CCSurvColdQuest = Quest.GetQuest("Survival_NeedColdQuest")
	If CCSurvColdQuest
		Manager.CCSurvivalInstalled = true
	endIf

	if !playerRef.HasPerk(PlayerAbilities)
		playerRef.AddPerk(PlayerAbilities)
	endIf
	
	RegisterForAnimationEvent(PlayerRef, "pa_2HWKillMoveA")
	RegisterForAnimationEvent(PlayerRef, "pa_KillMove1HMDecap")
	RegisterForAnimationEvent(PlayerRef, "pa_KillMove1HMDecapBleedOut")
	RegisterForAnimationEvent(PlayerRef, "pa_KillMove1HMDecapKnife")
	RegisterForAnimationEvent(PlayerRef, "pa_KillMove2HMDecap")
	RegisterForAnimationEvent(PlayerRef, "pa_KillMove2HMDecapBleedOut")
	RegisterForAnimationEvent(PlayerRef, "pa_KillMove2HWA")
	RegisterForAnimationEvent(PlayerRef, "pa_KillMove2HWDecapBleedOut")
	RegisterForAnimationEvent(PlayerRef, "pa_KillMoveDWDecap")
	
	RegisterForTrackedStatsEvent()
	RegisterForSleep()
	RegisterForControl("Wait")
	RegisterForAnimationEvent(PlayerRef, "SetRace")

	RegisterForKeys()
	
	Message.resetHelpMessage("DVT_DEAD")
	Message.resetHelpMessage("DVT_POOP")
	Message.resetHelpMessage("DVT_VOMIT")
	Message.resetHelpMessage("DVT_PERKGAIN")
	Message.resetHelpMessage("DVT_SKILLGAIN")
	
	RegisterForModEvent("da_BeginBleedout", "DA_BeginBleedout")
	RegisterForModEvent("da_EndBlackout", "DA_EndBlackout")

	CheckDependencies()
endFunction


int Function ChooseDefaultLocus()
	UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
	menu.ResetMenu()
	menu.AddEntryItem("Stomach")
	menu.AddEntryItem("Anal Vore")
	menu.AddEntryItem("Unbirth")
	menu.AddEntryItem("Breast Vore")
	menu.AddEntryItem("Cock Vore")
	
	menu.OpenMenu()
	int result = menu.GetResultInt()
	if result >= 0
		DefaultLocus = result
	else
		DefaultLocus = 0
	endIf
	
	return DefaultLocus
EndFunction


bool Function CheckAttack(int KeyCode)
	if KeyCode == BLOCK_KEY
		if puppet && DevourmentUtil.SafeProcess()
			if !puppet.isWeaponDrawn()
				ConsoleUtil.PrintMessage("DRAWING WEAPON")
				puppet.DrawWeapon()
			elseif !blocking
				ConsoleUtil.PrintMessage("PLAYING BLOCK")
				Debug.SendAnimationEvent(puppet, "BlockStart")
				blocking = true
			endIf
		endIf
		return true

	elseif KeyCode == ATTACK_KEY
		if puppet && DevourmentUtil.SafeProcess()
			if !puppet.isWeaponDrawn()
				ConsoleUtil.PrintMessage("DRAWING WEAPON")
				puppet.DrawWeapon()
			else
				ConsoleUtil.PrintMessage("PLAYING ATTACK")
				Debug.SendAnimationEvent(puppet, "AttackStart")
			endIf
		endIf
		return true
		
	else
		return false
	endIf
EndFunction


bool Function IsControllable(Actor target, bool endo)
	if DEBUGGING
		Log6(PREFIX, "IsControllable", Namer(target), endo, target.isInFaction(Follower), target.IsPlayerTeammate(), target.IsPlayersLastRiddenHorse(), target.HasKeyword(Manager.ActorTypeNPC))
	endIf

	if !target
		return false
	elseif endo && (target.isInFaction(Follower) || target.IsPlayerTeammate() || target.IsPlayersLastRiddenHorse())
		return true
	elseif !endo
		return DevourMCM.EnableCordyceps && playerRef.HasPerk(DevourMCM.Cordyceps) && target.HasKeyword(Manager.ActorTypeNPC)
	else
		return false
	endIf
EndFunction


bool Function TakeControlOf(Actor target)
	if DEBUGGING
		Log1(PREFIX, "ReleaseControlOf", Namer(target))
	endIf

	if puppet && puppet != target
		ReleaseControlOf(puppet)
	endIf

	if !target.GetPlayerControls()
		ConsoleUtil.PrintMessage("Taking player control of " + Namer(target, !DEBUGGING))
		target.SetPlayerControls(true)
		target.enableAI(true)
		puppet = target
	endIf

	BLOCK_KEY = Input.GetMappedKey("Left Attack/Block")
	ATTACK_KEY = Input.GetMappedKey("Right Attack/Block")
	RegisterForKey(BLOCK_KEY)
	RegisterForKey(ATTACK_KEY)

	return true
EndFunction


bool Function ReleaseControlOf(Actor target)
	if DEBUGGING
		Log1(PREFIX, "ReleaseControlOf", Namer(target))
	endIf

	if target.GetPlayerControls()
		ConsoleUtil.PrintMessage("Releasing player control of " + Namer(target, !DEBUGGING))
		target.SetPlayerControls(false)
		target.enableAI(true)
	endIf

	if puppet == target
		puppet = none
	endIf

	if BLOCK_KEY > 1
		UnregisterForKey(BLOCK_KEY)
	endIf
	if ATTACK_KEY > 1
		UnregisterForKey(ATTACK_KEY)
	endIf
	
	return true
EndFunction


Function UnregisterForKeys()
	if SHOUT_KEY > 1
		UnregisterForKey(SHOUT_KEY)
	endIf
	if BLOCK_KEY > 1
		UnregisterForKey(BLOCK_KEY)
	endIf
	if ATTACK_KEY > 1
		UnregisterForKey(ATTACK_KEY)
	endIf
EndFunction


Function RegisterForKeys()
	if Input.getMappedKey("Shout") != SHOUT_KEY
		if SHOUT_KEY > 1
			UnregisterForKey(SHOUT_KEY)
		endIf
		SHOUT_KEY = Input.getMappedKey("Shout")
	endIf
	
	;if Input.getMappedKey("Toggle POV") != TOGGLE_POV
	;	if TOGGLE_POV > 0
	;		UnregisterForKey(TOGGLE_POV)
	;	endIf
	;	TOGGLE_POV = Input.getMappedKey("Toggle POV")
	;endIf

	RegisterForKey(SHOUT_KEY)
	;RegisterForKey(TOGGLE_POV)
	
	if BLOCK_KEY > 1
		RegisterForKey(BLOCK_KEY)
	endIf
	if ATTACK_KEY > 1
		RegisterForKey(ATTACK_KEY)
	endIf
EndFunction


Function CheckDependencies()

	String ErrorReport = "You are missing the following dependencies: "
	Bool Display = False
	;/ 	MUST FIX!
	if !CheckSKSE("6.0.2")
		ErrorReport  = ErrorReport + " EngineFixes"
		Display = True
	endIf
	/;
	if JContainers.FeatureVersion() < 1 || JContainers.APIVersion() < 4 ;|| !CheckSKSE("JContainers64", 4)
		ErrorReport  = ErrorReport + " JContainers"
		Display = True
	endIf
	if PapyrusUtil.GetVersion() < 39 || PapyrusUtil.GetScriptVersion() < 39 ;|| !CheckSKSE("papyrusutil", 2)
		ErrorReport  = ErrorReport + " PapyrusUtil"
		Display = True
	endIf
	if ConsoleUtil.GetVersion() < 4 ;|| !CheckSKSE("ConsoleUtilSSE", 1)
		ErrorReport  = ErrorReport + " ConsoleUtil"
		Display = True
	endIf
	if NIOverride.GetScriptVersion() < 7 ;|| !CheckSKSE("skee", 1)
		ErrorReport  = ErrorReport + " NIOverride"
		Display = True
	endIf
	if RaceMenuBase.GetScriptVersionRelease() < 7
		ErrorReport = ErrorReport + " RaceMenu"
		Display = True
	endIf
	if !CheckSKSE("powerofthree's Papyrus Extender")
		ErrorReport  = ErrorReport + " po3 Papyrus Extender"
		Display = True
	endIf
	if XPMSELib.GetXPMSELibVersion() < 4.2
		ErrorReport  = ErrorReport + " XPMSE"
		Display = True
	endIf
	;/ MUST FIX!
	if !CheckSKSE("powerofthree's Spell Perk Item Distributor")
		ErrorReport  = ErrorReport + " SpellPerkItemDistributor" 
		Display = True
	endIf
	/;
	If Display
		LogAndBox(PREFIX, "CheckDependencies", ErrorReport, 2)
	EndIf
EndFunction


bool Function CheckSKSE(String pluginSE)
	int skseVersion = 0
	If SKSE.GetPluginVersion(pluginSE) >=0
		skseVersion = SKSE.GetPluginVersion(pluginSE)
	EndIf
	return skseVersion
endFunction


Function Upgrade(int oldVersion, int newVersion)
	Log2(PREFIX, "Upgrade", oldVersion, newVersion)
EndFunction


;==========================================================================================
;
;==========================================================================================


Event OnCellLoad()
	Utility.Wait(0.1)
	Manager.PrefillCheck()
EndEvent


Function PrefillCheck(Actor pred) 
	if DEBUGGING
		Log1(PREFIX, "PrefillCheck", Namer(pred))
	endIF

	if Manager.validPredator(pred) && pred.HasKeywordString("ActorTypeNPC") && pred.Is3DLoaded()

		float prefilledChance = Manager.PreFilledChance
		if pred.HasKeyword(Manager.DevourmentSuperPred)
			preFilledChance *= 3.0
		endIf

		if Utility.RandomFloat() < preFilledChance && !PlayerRef.HasLOS(pred)
			Manager.RegisterFakeDigestion(pred, -1.0)
			if DEBUGGING
				Log2(PREFIX, "PrefillCheck", Namer(pred), "Prefilling to 1.0.")
			endIF
		endIf
	endIf
EndFunction
