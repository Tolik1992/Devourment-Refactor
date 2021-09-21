ScriptName DevourmentQuickSettings extends ActiveMagicEffect


Event OnEffectStart(Actor akTarget, Actor akCaster)
	DevourmentMCM.instance().DisplayQuickSettings()
EndEvent
