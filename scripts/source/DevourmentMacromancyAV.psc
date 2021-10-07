scriptName DevourmentMacromancyAV extends ActiveMagicEffect
{
This version of Macromancy uses an ActorValue to store the new size. Useful for size changes controlled by spells.
}
import Logging
import DevourmentUtil


DevourmentManager property Manager auto
Actor property PlayerRef auto
float property Speed = 0.08 auto
Keyword property DevourmentSize auto


String PREFIX = "DevourmentMacromancyAV"
bool DEBUGGING = false
String rootNode = "NPC Root [Root]"
ActorValueInfo AVProxy_Size
float Smoothness
float Unsmoothness
float currentScale
float MacromancyScaling
bool performanceMode
bool isFemale
Actor target


bool MacroMode = true
;string[] iniSettings
float cameraPos0
float cameraPos1
float cameraPos2
;float[] iniSettings_originalValues


event OnEffectStart(Actor akTarget, Actor akCaster)
{
Event received when this effect is first started (OnInit may not have been run yet!)
}
	if !akTarget
		assertNotNone(PREFIX, "OnEffectStart", "akTarget", akTarget)
		return
	endif

	AVProxy_Size = Manager.AVProxy_Size
	MacromancyScaling = Manager.MacromancyScaling
	Unsmoothness = Speed
	Smoothness = 1.0 - Unsmoothness
	performanceMode = Manager.PERFORMANCE
	target = akTarget

	if performanceMode
		currentScale = getTargetScale()
	else
		currentScale = 1.0
	endIf

	MacroMode = Manager.MacroMode && target == PlayerRef
	if target == PlayerRef
		cameraPos0 = Utility.GetINIFloat("fOverShoulderPosZ:Camera")
		cameraPos1 = Utility.GetINIFloat("fOverShoulderCombatPosZ:Camera")
		cameraPos2 = Utility.GetINIFloat("fVanityModeMinDist:Camera")
	endIf

	isFemale = Manager.IsFemale(target)
	Manager.UncacheVoreWeight(akTarget)
	NIOverride.AddNodeTransformScale(target, false, isFemale, rootNode, PREFIX, currentScale)
	NiOverride.UpdateNodeTransform(target, false, isFemale, rootNode)
	RegisterForSingleUpdate(0.0)
endEvent


Event OnUpdate()
	float targetScale = getTargetScale()
	
	if targetScale < 0.01
		targetScale = 0.01
	endIf

	float diff = targetScale - currentScale
	
	if diff < -0.01 || diff > 0.01
		if performanceMode
			currentScale = targetScale
		else
			currentScale = Smoothness * currentScale + Unsmoothness * targetScale
		endIf

		if MacroMode
			target.SetScale(currentScale)
		else
			NIOverride.AddNodeTransformScale(target, false, isFemale, rootNode, PREFIX, currentScale)
			NiOverride.UpdateNodeTransform(target, false, isFemale, rootNode)
		endIf

		if target == PlayerRef
			float d = 121.0*currentScale - 121.0
			Utility.SetINIFloat("fOverShoulderPosZ:Camera", ((cameraPos0 + 121.0) * currentScale) - 121.0)
			Utility.SetINIFloat("fOverShoulderCombatPosZ:Camera", ((cameraPos1 + 121.0) * currentScale) - 121.0)
			Utility.SetINIFloat("fVanityModeMinDist:Camera", ((cameraPos2 + 121.0) * currentScale) - 121.0)
			;Utility.SetINIFloat("fOverShoulderPosZ:Camera", cameraPos0 * currentScale + d)
			;Utility.SetINIFloat("fOverShoulderCombatPosZ:Camera", cameraPos1 * currentScale + d)
			;Utility.SetINIFloat("fVanityModeMinDist:Camera", cameraPos2 * currentScale + d)
			Game.UpdateThirdPerson()
		endIf

		RegisterForSingleUpdate(0.050)

	elseif !target.HasMagicEffectWithKeyword(DevourmentSize)
		Dispel()
	else
		RegisterForSingleUpdate(1.0)
	endIf
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
{
Event received when this effect is finished (effect may already be deleted, calling
functions on this effect will fail)
}
	if MacroMode
		target.SetScale(1.0)
	else
		NIOverride.RemoveNodeTransformScale(target, false, isFemale, rootNode, PREFIX)
		NiOverride.UpdateNodeTransform(target, false, isFemale, rootNode)
	endIf

	if target == PlayerRef
		Utility.SetINIFloat("fOverShoulderPosZ:Camera", cameraPos0)
		Utility.SetINIFloat("fOverShoulderCombatPosZ:Camera", cameraPos1)
		Utility.SetINIFloat("fVanityModeMinDist:Camera", cameraPos2)
		Game.UpdateThirdPerson()
	endIf
endEvent


float Function getTargetScale()
	float av = AVProxy_Size.GetCurrentValue(target) / 100.0
	if av < 1.0
		return av / MacromancyScaling
	else
		return av * MacromancyScaling
	endIf
endFunction
