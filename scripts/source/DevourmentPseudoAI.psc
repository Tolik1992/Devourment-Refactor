Scriptname DevourmentPseudoAI extends ActiveMagicEffect
import Logging


Actor property PlayerRef auto
DevourmentManager property Manager auto
Keyword property BeingSwallowed auto
MagicEffect property DontSwallowMe auto
Spell property VoreSpell auto
Spell property Diminution auto
Spell property BellyPortSpell auto


float property SwallowRange = 225.0 autoReadOnly
float property CombatInterval = 5.0 autoReadOnly


String PREFIX = "DevourmentPseudoAI"
String predName
Actor Pred
bool DEBUGGING = false
bool bleedoutVore
float reach


Actor currentTarget = none
bool validTarget


Event OnEffectStart(Actor akTarget, Actor akCaster)
{ Checks the combat state and which types of Noms are allowed. }

	if !AssertNotNone(PREFIX, "OnEffectStart", "akTarget", akTarget)
		Dispel()
		return
	endIf

	pred = akTarget
	predName = Namer(pred, true)
	reach = SwallowRange + pred.GetLength()
	bleedoutVore = !Game.IsPluginInstalled("SexLabDefeat.esp")

	if Manager.validPredator(pred)
		currentTarget = pred.GetCombatTarget()
		validTarget = CombatCheck(currentTarget, pred.getCombatState())
	
		RegisterForSingleUpdate(CombatInterval)
		RegisterForAnimationEvent(pred, "HitFrame")
		RegisterForActorAction(0)
	endIf
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
EndEvent 


Event OnCombatStateChanged(Actor newTarget, int aeCombatState)
	if DEBUGGING
		Log3(PREFIX, "OnCombatStateChanged", predName, aeCombatState, Namer(newTarget))
	endIf

	currentTarget = newTarget
	validTarget = CombatCheck(currentTarget, aeCombatState)
EndEvent


Event OnUpdate()
	if validTarget
		if DEBUGGING
			Log1(PREFIX, "OnUpdate", predName)
		endIf
		DoANom(currentTarget)
	endIf

	registerForSingleUpdate(CombatInterval)
EndEvent


Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	if validTarget
		registerForSingleUpdate(CombatInterval) ; Reset the onUpdate timer.

		if DEBUGGING
			Log1(PREFIX, "OnActorAction", predName)
		endIf
		DoANom(currentTarget)
	endIf
EndEvent


Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	if validTarget
		registerForSingleUpdate(CombatInterval) ; Reset the onUpdate timer.

		if DEBUGGING
			Log1(PREFIX, "OnAnimationEvent", predName)
		endIf
		DoANom(currentTarget)
	endIf
EndEvent


bool Function combatCheck(Actor newTarget, int combatState)
	return combatState > 0 && newTarget != none && pred != none && PlayerCheck(newTarget) && Manager.IsValidDigestion(pred, newTarget)
endFunction	


Function DoANom(Actor prey)
{ 
	Don't swallow anyone who is already being swallowed or too far away. If the prey is uninjured and higher level, don't swallow. 
	Print out appropriate debugging messages.
}

	if !prey 
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "No prey")
		endIf

	elseif prey.getLevel() > pred.getLevel() && prey.getAVPercentage("Health") > 0.50
		if DEBUGGING
			Log2(PREFIX, "DoANom_Combat", "Too high level and not damaged enough", Namer(prey))
		endIf

	elseif !bleedoutVore && prey.IsBleedingOut()
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "Bleeding out and BleedoutVore is disabled.")
		endIf

	elseif prey.hasMagicEffectWithKeyword(BeingSwallowed)
		if DEBUGGING
			Log2(PREFIX, "DoANom_Combat", "Already being swallowed", Namer(prey))
		endIf

	elseif Manager.GetFullnessWith(pred, prey) > 1.5
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "Too full")
		endIf

	elseif pred.getDistance(prey) > reach
		if DEBUGGING
			Log4(PREFIX, "DoANom_Combat", "Too far", Namer(prey), pred.getDistance(prey), reach)
		endIf

		if pred.GetActorValue("Conjuration") >= 35.0
			BellyPortSpell.Cast(pred, prey)
		elseif pred.GetActorValue("Alteration") >= 35.0
			Diminution.Cast(pred, prey)
		endIf

	else
		VoreSpell.cast(pred, prey)
		ConsoleUtil.PrintMessage(predName + " is trying to nom " + Namer(prey, true) + "!")
		if DEBUGGING
			Log3(PREFIX, "DoANom_Combat", predName, Namer(prey, true), "Nomming")
		endIf
	endIf
EndFunction


bool Function PlayerCheck(Actor target)
	if target == PlayerRef
		return Manager.playerPreference != 1
	else
		return Manager.playerPreference != 2
	endIf
EndFunction
