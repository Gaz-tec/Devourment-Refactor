scriptName HelperSpellEffect extends ActiveMagicEffect


Spell property SpellToCast = none auto
Spell property CasterSpellToAdd = none auto
Spell property TargetSpellToAdd = none auto
bool property DispelMe = true auto
float property Delay = 0.0 auto

Actor target
Actor caster


function OnEffectStart(Actor akTarget, Actor akCaster)
	target = akTarget
	caster = akCaster

	if Delay > 0.0
		RegisterForSingleUpdate(Delay)
	else
		castNow()
	endIf
endFunction


Event OnUpdate()
	castNow()
EndEvent


Function castNow()
	if SpellToCast != none
		SpellToCast.Cast(target, caster)
	endIf
	
	if TargetSpellToAdd != none
		target.addSpell(TargetSpellToAdd, false)
	endif
	
	if CasterSpellToAdd != none
		caster.addSpell(CasterSpellToAdd, false)
	endif
	
	if DispelMe
		self.Dispel()
	endIf
EndFunction
