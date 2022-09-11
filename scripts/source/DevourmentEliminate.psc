ScriptName DevourmentEliminate extends ActiveMagicEffect
{
Causes the target to vomit or defecate all of their undigested prey and items.
}
import Logging
import Devourment_JCDomain


DevourmentManager property Manager auto
Actor property PlayerRef auto
Message property Message_Nothing auto
bool property Oral = true auto


String PREFIX = "DevourmentEliminate"


event OnEffectStart(Actor target, Actor caster)
	Eliminate(target)
endEvent


Function Eliminate(Actor pred)
	if !assertNotNone(PREFIX, "OnEffectStart", "pred", pred)
		return
	endif
	
	if pred == playerRef
		Form[] stomach = Manager.GetStomachArray(pred)
		if Manager.EmptyStomach(stomach)
			Manager.HelpAgnosticMessage(Message_Nothing, "DVT_ELIMINATEALL", 4.0, 0.0)
			Debug.SendAnimationEvent(pred, "IdleUncontrollableCough")
			return
		endIf
		
		Form[] excretable = Utility.CreateFormArray(stomach.length)
		UIListMenu eliminateList = UIExtensions.GetMenu("UIListMenu") as UIListMenu
		eliminateList.ResetMenu()
		
		int listIndex = 0
		int stomachIndex = stomach.length
		
		while stomachIndex
			stomachIndex -= 1
			ObjectReference content = stomach[stomachIndex] as ObjectReference

			if content
				if JLua_evalLuaInt("return dvt.isExcretable(args)", Manager.GetPreyData(content), 0, false)
					if Manager.IsDigested(Manager.GetPreyData(content))
						eliminateList.AddEntryItem(Namer(content, true) + " (digested)")
					else
						eliminateList.AddEntryItem(Namer(content, true))
					endIf
					excretable[listIndex] = content
					listIndex += 1
				endIf
			endIf
		endWhile
		
		eliminateList.AddEntryItem("Everything")
		
		if listIndex == 0
			Manager.HelpAgnosticMessage(Message_Nothing, "DVT_ELIMINATEALL", 4.0, 0.0)
			Debug.SendAnimationEvent(pred, "IdleUncontrollableCough")
			
		elseif listIndex == 1
			EliminateOne(excretable[0] as ObjectReference)

		else
			int resultIndex = 0
			if listIndex > 1
				eliminateList.OpenMenu()
				resultIndex = eliminateList.GetResultInt()
			endIf
			
			if resultIndex == listIndex
				EliminateAll(pred)
			
			elseif resultIndex >= 0
				EliminateOne(excretable[resultIndex] as ObjectReference)
			endIf
		endIf
		
	else
		EliminateAll(pred)
	endIf
EndFunction


Function EliminateOne(ObjectReference prey)
	if oral
		Manager.RegisterVomit(prey)
	else
		Manager.DefecateOne(prey)
	endIf
EndFunction


Function EliminateAll(Actor pred)
	if Manager.hasExcretable(pred)
		if oral
			Manager.vomit(pred)
		else
			Manager.poop(pred)
		endIf
	elseif pred == Manager.playerRef
		Manager.HelpAgnosticMessage(Message_Nothing, "DVT_ELIMINATEALL", 4.0, 0.0)
	endIf
EndFunction

