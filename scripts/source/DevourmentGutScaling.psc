scriptName DevourmentGutScaling extends ActiveMagicEffect
{
}
import Logging
import DevourmentUtil


DevourmentManager property Manager auto
DevourmentMorphs property Morphs auto
Actor property PlayerRef auto
String[] property StruggleSliders auto


String PREFIX = "DevourmentGutScaling"
bool DEBUGGING = false
bool isFemale

int DATA = 0
int OUTPUT_BUMPS = 0
String PROTOTYPE = "{ \"oddity\" : 0.9, \"amplitude\" : 0.5, \"minDuration\" : 15.0, \"maxDuration\" : 30.0, \"bumps\" : [{}, {}, {}], \"output_bumps\" : [0.0, 0.0, 0.0] }"


bool UseMorphVore = true
bool UseStruggleSliders = true
float UpdateTime = 0.05


event OnEffectStart(Actor akTarget, Actor akCaster)
	{ Event received when this effect is first started (OnInit may not have been run yet!) }
	if !akTarget
		assertNotNone(PREFIX, "OnEffectStart", "akTarget", akTarget)
		return
	endif

	isFemale = Manager.IsFemale(PlayerRef)
	UseStruggleSliders = Morphs.UseStruggleSliders

	DATA = JValue.retain(JValue.objectFromPrototype(PROTOTYPE), PREFIX)
	OUTPUT_BUMPS = JMap.GetObj(DATA, "output_bumps")

	AssertExists(PREFIX, "OnEffectStart", "DATA", DATA)
	RegisterForSingleUpdate(0.0)
endEvent


Event OnUpdate()
	JLua.evalLuaFlt("dvt.GutSliders(args)", DATA, 0, 0.0)
	float[] outputBumps = JArray.asFloatArray(OUTPUT_BUMPS)

	if DEBUGGING 
		Log1(PREFIX, "OnUpdate", LuaS("DATA", DATA))
	endIf
	
	bool updateWeights = false

	if UseStruggleSliders
		int sliderIndex = StruggleSliders.length
		while sliderIndex
			sliderIndex -= 1
			float scale = outputBumps[sliderIndex]
			if scale >= 0.0
				NIOverride.SetBodyMorph(PlayerRef, StruggleSliders[sliderIndex], PREFIX, scale)
				updateWeights = true
			endIf
		endWhile
	endIf
	
	if updateWeights
		NiOverride.UpdateModelWeight(PlayerRef)
		RegisterForSingleUpdate(UpdateTime)
	else
		RegisterForSingleUpdate(1.0)
	endIf
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
	DATA = JValue.release(DATA)
	NIOverride.ClearBodyMorphKeys(PlayerRef, PREFIX)
	NiOverride.UpdateModelWeight(PlayerRef)
endEvent
