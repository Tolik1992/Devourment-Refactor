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
;Quest property CCQ auto


String PREFIX = "DevourmentMacromancyAV"
String rootNode = "NPC Root [Root]"
ActorValueInfo AVProxy_Size
float Smoothness
float Unsmoothness
float currentScale
float MacromancyScaling
bool performanceMode
bool isFemale
Actor target


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
		currentScale = MacromancyScaling * AVProxy_Size.GetCurrentValue(target) / 100.0
	else
		currentScale = 1.0
	endIf

	isFemale = Manager.IsFemale(target)

	Manager.UncacheVoreWeight(akTarget)
	NIOverride.AddNodeTransformScale(target, false, isFemale, rootNode, PREFIX, currentScale)
	NiOverride.UpdateNodeTransform(target, false, isFemale, rootNode)
	RegisterForSingleUpdate(0.0)
	;Log2(PREFIX, "OnEffectStart", Namer(target), AVProxy_Size.GetCurrentValue(target) / 100.0)
endEvent


Event OnUpdate()
	float targetScale = MacromancyScaling * AVProxy_Size.GetCurrentValue(target) / 100.0
	
	if targetScale < 0.01
		targetScale = 0.01
	endIf

	float diff = targetScale - currentScale
	
	if diff < -0.01 || diff > 0.01
		if performanceMode
			currentScale = targetScale
		elseif diff < -0.2
			currentScale -= 0.2
		elseif diff > 0.2
			currentScale += 0.2
		else
			currentScale = Smoothness * currentScale + Unsmoothness * targetScale
		endIf

		NIOverride.AddNodeTransformScale(target, false, isFemale, rootNode, PREFIX, currentScale)
		NiOverride.UpdateNodeTransform(target, false, isFemale, rootNode)
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
	NIOverride.RemoveNodeTransformScale(target, false, isFemale, rootNode, PREFIX)
	NiOverride.UpdateNodeTransform(target, false, isFemale, rootNode)
	;Log1(PREFIX, "OnEffectFinish", Namer(target))
endEvent
