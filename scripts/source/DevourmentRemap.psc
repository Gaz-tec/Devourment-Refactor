Scriptname DevourmentRemap extends Quest
import Logging
import Devourment_JCDomain


FormList property RemapFrom auto
FormList property RemapTo auto
String property RaceRemaps = "..\\devourment\\raceRemaps.json" autoreadonly
String PREFIX = "DevourmentRemap"


;Gaz note. We used to only use RemapRaceName() but recently my Predator Toggles have encountered strange bugs I cannot resolve.
;I am switching to using Races for my lists and using only RemapRace(). 
;Other systems that use RemapRaceName() may have edge-case bugs like Glenmoril Witches showing as Hagravens. Monitor this.
Race Function RemapRace(Race from)
	int index = RemapFrom.Find(from)
	if index >= 0
		return RemapTo.GetAt(index) as Race
	else
		return from
	endIf
EndFunction


String Function RemapRaceName(Actor target)
	String raceName = RemapRace(target.GetLeveledActorBase().getRace()).getName()
	String remapName = JLua_evalLuaStr("return '...'..string.lower(args.name)", JLua_SetStr("name", raceName))
	String statName = JSonUtil.GetStringValue(RaceRemaps, remapName, raceName)
	Log4(PREFIX, "RemapRace", Namer(target), raceName, remapName, statName)
	return statName
EndFunction



