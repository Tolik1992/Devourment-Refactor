Scriptname DevourmentPseudoAI extends ActiveMagicEffect
import Logging


Actor property PlayerRef auto
DevourmentManager property Manager auto
Keyword property BeingSwallowed auto
MagicEffect property DontSwallowMe auto
Spell property VoreSpell auto
Spell[] property CombatSpells auto
float property SwallowRange = 225.0 autoReadOnly

int combatSpellsCount = 0


String PREFIX = "DevourmentPseudoAI"
String predName
Actor Pred
bool DEBUGGING = false
bool bleedoutVore
float reach
float cooldownTime = 5.0
bool coolingDown = false

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

	if LibFire.ActorIsFollower(pred)
		cooldownTime = Manager.Cooldown_Follower
	elseif pred.HasKeywordString("ActorTypeNPC")
		cooldownTime = Manager.Cooldown_NPC
	else
		cooldownTime = Manager.Cooldown_Creature
	endIf

	if Manager.validPredator(pred)
		currentTarget = pred.GetCombatTarget()
		validTarget = CombatCheck(currentTarget, pred.getCombatState())
	
		RegisterForSingleUpdate(cooldownTime)
		RegisterForAnimationEvent(pred, "HitFrame")
		RegisterForActorAction(0)


		int len = CombatSpells.length
		int index = 0
		int count = 0

		while index < len
			bool available = pred.HasSpell(CombatSpells[index])
			if !available 
				CombatSpells[index] = None
			elseif index != combatSpellsCount
				CombatSpells[combatSpellsCount] = CombatSpells[index]
				CombatSpells[index] = None
				combatSpellsCount += 1
			else
				combatSpellsCount += 1
			endIf
			index += 1
		endWhile

		if DEBUGGING
			Log2(PREFIX, "OnEffectStart", Namer(pred), SpellArrayToString(CombatSpells))
		endIf
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
	coolingDown = false
EndEvent


Event OnUpdate()
	if coolingDown
		if DEBUGGING
			Log2(PREFIX, "OnUpdate", predName, "WAIT A BIT")
		endIf
		coolingDown = false
		RegisterForSingleUpdate(Utility.RandomFloat(0.0, cooldownTime))

	elseif validTarget
		if DEBUGGING
			Log1(PREFIX, "OnUpdate", predName)
		endIf
		coolingDown = true
		registerForSingleUpdate(cooldownTime)
		DoANom(currentTarget)

	else
		if DEBUGGING
			Log2(PREFIX, "OnUpdate", predName, "COOLDOWN")
		endIf
		coolingDown = false
		registerForSingleUpdate(cooldownTime)
	endIf
EndEvent


Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	if validTarget && !coolingDown
		coolingDown = true
		registerForSingleUpdate(cooldownTime) ; Reset the onUpdate timer.
		
		if DEBUGGING
			Log1(PREFIX, "OnActorAction", predName)
		endIf
		DoANom(currentTarget)
	else
		if DEBUGGING
			Log6(PREFIX, "OnActorAction", predName, "COOLDOWN", actionType, Namer(akActor), Namer(source), slot)
		endIf
	endIf
EndEvent


Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	if validTarget && !coolingDown
		coolingDown = true
		registerForSingleUpdate(cooldownTime) ; Reset the onUpdate timer.

		if DEBUGGING
			Log1(PREFIX, "OnAnimationEvent", predName)
		endIf
		DoANom(currentTarget)
	else
		if DEBUGGING
			Log2(PREFIX, "OnAnimationEvent", predName, "COOLDOWN")
		endIf
	endIf
EndEvent


bool Function combatCheck(Actor newTarget, int combatState)
	return combatState ==  1 && newTarget != none && pred != none && !newTarget.isChild() && !newTarget.isDead() \
	&& PlayerCheck(newTarget) && Manager.IsValidDigestion(pred, newTarget)
endFunction	


bool Function DoANom(Actor prey)
{ 
	Don't swallow anyone who is already being swallowed or too far away. If the prey is uninjured and higher level, don't swallow. 
	Print out appropriate debugging messages.
}
	if AssertNotNone(PREFIX, "DoANom", "prey", prey)
		return false

	elseif !isWeakened(prey)
		if DEBUGGING
			Log2(PREFIX, "DoANom_Combat", "Prey not weakened.", Namer(prey))
		endIf
		return false

	elseif !bleedoutVore && prey.IsBleedingOut()
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "Bleeding out and BleedoutVore is disabled.")
		endIf
		return false

	elseif prey.hasMagicEffectWithKeyword(BeingSwallowed)
		if DEBUGGING
			Log2(PREFIX, "DoANom_Combat", "Already being swallowed", Namer(prey))
		endIf

	elseif pred.getDistance(prey) > reach
		if DEBUGGING
			Log4(PREFIX, "DoANom_Combat", "Too far", Namer(prey), pred.getDistance(prey), reach)
		endIf

		if combatSpellsCount > 0
			int selection = Utility.RandomInt(0, combatSpellsCount - 1)
			CombatSpells[selection].Cast(pred, prey)
		endIf
		return false

	elseif Manager.GetFullnessWith(pred, prey) > 1.5
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "Too full")
		endIf
		return false

	elseif prey.IsDead()
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "Already dead")
		endIf
		return false

	else
		VoreSpell.cast(pred, prey)
		if DEBUGGING
			Log3(PREFIX, "DoANom_Combat", predName, Namer(prey, true), "Nomming")
		endIf
		return true
	endIf
EndFunction


bool Function isWeakened(Actor prey)
	if prey.getAVPercentage("Health") <= 0.50 
		if DEBUGGING
			Log2(PREFIX, "isWeakened", Namer(prey), "Health is below 50%")
		endIf
		return true
	elseif prey.GetAnimationVariableBool("IsStaggering")
		if DEBUGGING
			Log2(PREFIX, "isWeakened", Namer(prey), "Staggered")
		endIf
		return true
	elseif prey.getLevel() < pred.getLevel()
		if DEBUGGING
			Log2(PREFIX, "isWeakened", Namer(prey), "Lower level than predator")
		endIf
		return true
	else
		return false
	endIf
EndFunction


bool Function PlayerCheck(Actor target)
	if target == PlayerRef
		return Manager.playerPreference != 1
	else
		return Manager.playerPreference != 2
	endIf
EndFunction
