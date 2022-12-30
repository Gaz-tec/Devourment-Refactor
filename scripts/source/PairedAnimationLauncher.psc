Scriptname PairedAnimationLauncher extends ActiveMagicEffect
{
Script to call and test animations
}

Idle Property PairedAnimation Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

		akTarget.StopCombat()
		akCaster.StopCombat()
		Debug.SendAnimationEvent(akTarget,"returnToDefault")
		Debug.SendAnimationEvent(akCaster,"returnToDefault")
		if akCaster.PlayIdleWithTarget(PairedAnimation, akTarget)
			ConsoleUtil.PrintMessage("Worked")
		else
			ConsoleUtil.PrintMessage("Failed")
		endIf
		Utility.wait(10.0)
		Dispel()

EndEvent


