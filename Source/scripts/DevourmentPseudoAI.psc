Scriptname DevourmentPseudoAI extends ActiveMagicEffect
import Logging


Actor property PlayerRef auto
DevourmentManager property Manager auto
Faction property RandomNoms auto
Keyword property BeingSwallowed auto
MagicEffect property DontSwallowMe auto
Spell property VoreSpell auto
Spell property ScriptedEndoSpell auto
Spell property ScriptedVoreSpell auto
Spell property Diminution auto
Spell property BellyPort auto


float property SwallowRange = 225.0 autoReadOnly
float property CombatInterval = 5.0 autoReadOnly
float property NomsInterval = 10.0 autoReadOnly
float property PassiveInterval = 10.0 autoReadOnly


String PREFIX = "DevourmentPseudoAI"
String predName
bool DEBUGGING
bool bleedoutVore
bool companionVore
float reach


Event OnEffectStart(Actor akTarget, Actor akCaster)
{ Checks the combat state and which types of Noms are allowed. }

	DEBUGGING = Manager.DEBUGGING
	Actor pred = akTarget
	if pred
		predName = Namer(pred, true)
		reach = SwallowRange + pred.GetLength()
		bleedoutVore = !Game.IsPluginInstalled("SexLabDefeat.esp")
		companionVore = !Game.IsPluginInstalled("nwsFollowerFramework.esp")

		int aeCombatState = pred.GetCombatState()

		if combatCheck(pred, none, aeCombatState)
			gotostate("CombatState")
		elseif aeCombatState == 0 && RandomNomsAllowed(pred)
			PrefillCheck(pred)
			gotostate("NomsState")
		else
			PrefillCheck(pred)
			gotostate("PassiveState")
		endIf

	endIf
EndEvent


Event OnCombatStateChanged(Actor newTarget, int aeCombatState)
{ This is called in every state except CombatState. }

	if DEBUGGING
		Log3(PREFIX, "OnCombatStateChanged", predName, aeCombatState, Namer(newTarget))
	endIf

	Actor pred = self.GetTargetActor()
	if pred
		if combatCheck(pred, newTarget, aeCombatState)
			gotostate("CombatState")
		elseif aeCombatState == 0 && RandomNomsAllowed(pred)
			gotostate("NomsState")
		else
			gotostate("PassiveState")
		endIf
	endIf
EndEvent


Event onLoad()
{ When a pred is loaded, refresh their state. This also pulls the pred out of the Quiescent state. }

	Actor pred = self.GetTargetActor()
	if pred
		DEBUGGING = Manager.DEBUGGING
		if DEBUGGING
			Log1(PREFIX, "onLoad", predName)
		endIf
		
		int aeCombatState = pred.GetCombatState()

		if combatCheck(pred, none, aeCombatState)
			gotostate("CombatState")
		elseif aeCombatState == 0 && RandomNomsAllowed(pred)
			gotostate("NomsState")
		else
			gotostate("PassiveState")
		endIf
endIf
EndEvent


;/Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	Actor pred = akAggressor as Actor
	Actor prey = self.GetTargetActor()

	if !pred || !prey || projectile
		return

	elseif prey.getLevel() > pred.getLevel() && prey.getAVPercentage("Health") > 0.50
		if DEBUGGING
			Log1(PREFIX, "OnHit", "Too high level and not damaged enough")
		endIf

	elseif !bleedoutVore && prey.IsBleedingOut()
		if DEBUGGING
			Log1(PREFIX, "OnHit", "Bleeding out and BleedoutVore is disabled.")
		endIf

	elseif pred.getDistance(prey) > SwallowRange + pred.GetLength()
		if DEBUGGING
			Log1(PREFIX, "OnHit", "Too far")
		endIf

	elseif prey.hasMagicEffectWithKeyword(BeingSwallowed)
		if DEBUGGING
			Log1(PREFIX, "OnHit", "Already being swallowed")
		endIf

	elseif Manager.GetFullnessWith(pred, prey) > 1.5
		if DEBUGGING
			Log1(PREFIX, "OnHit", "Too full")
		endIf

	else	
		VoreSpell.cast(pred, prey)
		ConsoleUtil.PrintMessage(predName + " is trying to nom " + Namer(prey, true) + "!")
		if DEBUGGING
			Log3(PREFIX, "OnHit", predName, Namer(prey, true), "Nomming")
		endIf
	endIf	
EndEvent /;


Event onUnload()
	gotoState("Quiescent")
EndEvent


Event OnCellDetach()
	GotoState("Quiescent")
EndEvent 


Event OnCellAttach()
EndEvent


state Quiescent
; The quiescent state does everything it can to ensure that the pred can be unloaded. It also tries to add a prefilled belly.

	Event OnBeginState()
		Dispel()
	EndEvent

	Event OnUpdate()
		Dispel()
	EndEvent

	Event OnCellAttach()
		GotoState("PassiveState")
		PrefillCheck(self.GetTargetActor())
	EndEvent
EndState


Auto State PassiveState

	Event OnBeginState()
		Actor pred = self.GetTargetActor()
		if pred
			DEBUGGING = Manager.DEBUGGING
			if DEBUGGING
				Log1(PREFIX, "PassiveState.OnBeginState", predName)
			endIf
			
			RegisterForSingleUpdate(PassiveInterval)
		endIf
	EndEvent

	Event OnUpdate()
		Actor pred = self.GetTargetActor()
		if pred
			if DEBUGGING
				Log1(PREFIX, "PassiveState.OnUpdate", predName)
			endIf
			
			int aeCombatState = pred.GetCombatState()

			if combatCheck(pred, none, aeCombatState)
				gotostate("CombatState")
			elseif aeCombatState == 0 && RandomNomsAllowed(pred)
				gotostate("NomsState")
			endIf

			RegisterForSingleUpdate(PassiveInterval)
		endIf
	EndEvent

EndState


State NomsState

	Event OnBeginState()
		Actor pred = self.GetTargetActor()
		if pred
			DEBUGGING = Manager.DEBUGGING
			if DEBUGGING
				Log1(PREFIX, "NomsState.OnBeginState", Namer(self.GetTargetActor()))
			endIf
			
			RegisterForSingleUpdate(nomsInterval)
		endIf
	EndEvent

	Event onEndState()
	EndEvent

	Event OnUpdate()
		Actor pred = self.GetTargetActor()
		if pred
			if DEBUGGING
				Log1(PREFIX, "NomsState.OnUpdate", predName)
				ConsoleUtil.PrintMessage(predName + " is looking for someone to nom.")
			endIf

			DoANom_Random(pred)
			registerForSingleUpdate(nomsInterval)
		endIf
	endEvent

EndState


State CombatState

	Event OnBeginState()
		Actor pred = self.GetTargetActor()
		if pred
			DEBUGGING = Manager.DEBUGGING
			if DEBUGGING
				Log1(PREFIX, "CombatState.OnBeginState", predName)
			endIf
			
			registerForSingleUpdate(CombatInterval)
			RegisterForAnimationEvent(GetTargetActor(), "HitFrame")
			RegisterForActorAction(0)
		endIf
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(GetTargetActor(), "HitFrame")
		UnregisterForActorAction(0)
	EndEvent

	Event OnCombatStateChanged(Actor newTarget, int aeCombatState)
		Actor pred = self.GetTargetActor()
		Actor prey = pred.GetCombatTarget()

		if pred
			if DEBUGGING
				Log3(PREFIX, "CombatState.OnCombatStateChanged", aeCombatState, predName, Namer(newTarget))
			endIf
			
			if combatCheck(pred, newTarget, aeCombatState)
				RegisterForAnimationEvent(GetTargetActor(), "HitFrame")
				RegisterForActorAction(0)
			else
				gotostate("passiveState")
			endIf
		endIf
	EndEvent


	Event OnUpdate()
		Actor pred = self.GetTargetActor()
		Actor prey = pred.GetCombatTarget()
	
		if pred && prey
			if DEBUGGING
				Log1(PREFIX, "CombatState.OnUpdate", predName)
			endIf

			DoANom_Combat(pred, prey)

			if LoadedCheck(pred)
				registerForSingleUpdate(CombatInterval)
			endIf
		endIf
	EndEvent

	
	Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
		Actor pred = self.GetTargetActor()
		Actor prey = pred.GetCombatTarget()

		if pred && prey
			if DEBUGGING
				Log1(PREFIX, "CombatState.OnActorAction", predName)
			endIf

			DoANom_Combat(pred, prey)

			if LoadedCheck(pred)
				registerForSingleUpdate(CombatInterval)
			endIf
		endIf
	EndEvent

	
	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
		Actor pred = self.GetTargetActor()
		Actor prey = pred.GetCombatTarget()

		if pred && prey
			if DEBUGGING
				Log1(PREFIX, "CombatState.OnAnimationEvent", predName)
			endIf

			DoANom_Combat(pred, prey)

			if LoadedCheck(pred)
				registerForSingleUpdate(CombatInterval)
			endIf
		endIf
	EndEvent

EndState


bool Function LoadedCheck(Actor pred)
	if !pred.Is3DLoaded()
		Log1(PREFIX, "LoadedCheck", "Dispelling")
		UnregisterForUpdate()
		pred = none
		return false
	else
		if DEBUGGING
			Log1(PREFIX, "LoadedCheck", "Passed")
		endIf
		return true
	endIf
EndFunction


bool Function RandomNomsAllowed(Actor pred)
	if DEBUGGING
		Log4(PREFIX, "RandomNomsAllowed", predName, pred.IsInFaction(RandomNoms), Manager.AutoNoms, Manager.validPredator(pred))
	endIf

	if pred.IsInFaction(RandomNoms) || Manager.AutoNoms > 0
		return Manager.validPredator(pred)
	else
		return false
	endIf
EndFunction


bool Function combatCheck(Actor pred, Actor newTarget, int combatState)
	if combatState == 0 || newTarget == none
		return false

	elseif combatState > 0 && newTarget && Manager.validPredator(pred) && Manager.IsValidDigestion(pred, newTarget) && PlayerCheck(newTarget)

		if DEBUGGING
			Log4(PREFIX, "combatCheck", "PASSED", predName, combatState, Namer(newTarget))
		endIf
		return true
	else 
		if DEBUGGING
			Log4(PREFIX, "combatCheck", "FAILED", predName, combatState, Namer(newTarget))
		endIf
		return false
	endIf
endFunction	


Actor Function GetNomsTarget(Actor pred)
	bool playerAvailable = !Manager.PlayerAvoidant && !Manager.IsPrey(PlayerRef) && (Manager.AutoNoms == 1 || Manager.AutoNoms == 3)

	if DEBUGGING
		Log3(PREFIX, "GetNomsTarget", predName, "playerAvailable="+playerAvailable, "autoNoms="+Manager.AutoNoms)
	endIf

	if Manager.PlayerCentric || Manager.AutoNoms == 0
		return playerRef
	endIf

	Actor[] NPCs = LibFire.FindNearbyActors(pred, reach * 2.0)
	Actor[] filtered

	if Manager.AutoNoms == 1
		filtered = Filter1(NPCs, pred, playerRef)
	elseif Manager.AutoNoms == 2
		filtered = Filter2(NPCs, pred, playerRef)
	else
		filtered = Filter3(NPCs, pred)
	endIf

	int firstNone = filtered.find(none)
	int index = utility.randomInt(0, firstNone - 1)

	if DEBUGGING
		Log4(PREFIX, "GetNomsTarget", predName, firstNone, index, ActorArrayToString(filtered))
	endIf

	if index >= 0
		return filtered[index] as Actor
	elseif playerAvailable && pred.GetDistance(playerRef) < reach * 2.0
		return playerRef
	else
		return none
	endIf
EndFunction


Function DoANom_Random(Actor pred)
{ 
	Don't swallow anyone who is already being swallowed or too far away or will make the pred too full.
	Print out appropriate debugging messages.
}
	float roll = utility.randomFloat()

	if roll > Manager.NomsChance
		if DEBUGGING
			Log1(PREFIX, "DoANom_Random", "Failed roll " + roll + " vs " + Manager.NomsChance)
		endIf

	elseif Manager.isFull(pred) 
		if DEBUGGING
			Log1(PREFIX, "DoANom_Random", "Full")
		endIf

	elseif Game.GetDialogueTarget() != none
		if DEBUGGING
			Log1(PREFIX, "DoANom_Random", "Player in dialogue")
		endIf

	else
		Actor nomsTarget = GetNomsTarget(self.GetTargetActor())
		if DEBUGGING
			Log1(PREFIX, "DoANom_Random", predName + " chose " + Namer(nomsTarget) + " for Nomming.")
		endIf
		
		if nomsTarget && PlayerCheck(nomsTarget)
			ConsoleUtil.PrintMessage(predName + " is trying to nom " + Namer(nomsTarget, true) + "!")
			ScriptedEndoSpell.Cast(pred, nomsTarget)
		endIf
	endIf
EndFunction


Function DoANom_Combat(Actor pred, Actor prey)
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

	elseif pred.getDistance(prey) > reach
		if DEBUGGING
			Log4(PREFIX, "DoANom_Combat", "Too far", Namer(prey), pred.getDistance(prey), reach)
		endIf

		if pred.GetActorValue("Conjuration") > 50.0
			BellyPort.Cast(pred, prey)
		elseif pred.GetActorValue("Alteration") > 50.0
			Diminution.Cast(pred, prey)
		endIf

	elseif prey.hasMagicEffectWithKeyword(BeingSwallowed)
		if DEBUGGING
			Log2(PREFIX, "DoANom_Combat", "Already being swallowed", Namer(prey))
		endIf

	elseif Manager.GetFullnessWith(pred, prey) > 1.5
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "Too full")
		endIf

	elseif !PlayerCheck(prey)
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "Failed PlayerCheck")
		endIf

	elseif !companionVore && LibFire.ActorIsFollower(prey)
		if DEBUGGING
			Log1(PREFIX, "DoANom_Combat", "No followers -- compatibility mode for NFF.")
		endIf

	else
		VoreSpell.cast(pred, prey)
		ConsoleUtil.PrintMessage(predName + " is trying to nom " + Namer(prey, true) + "!")
		if DEBUGGING
			Log3(PREFIX, "DoANom_Combat", predName, Namer(prey, true), "Nomming")
		endIf
	endIf
EndFunction


Function PrefillCheck(Actor pred)
	if DEBUGGING
		Log1(PREFIX, "PrefillCheck", predName)
	endIF

	if Manager.validPredator(pred) && pred.HasKeywordString("ActorTypeNPC") && pred.Is3DLoaded()

		float prefilledChance = Manager.PreFilledChance
		if pred.HasKeyword(Manager.DevourmentSuperPred)
			preFilledChance *= 3.0
		endIf

		if Utility.RandomFloat() < preFilledChance && !PlayerRef.HasLOS(pred)
			Manager.RegisterFakeDigestion(pred, -1.0)
			if DEBUGGING
				Log2(PREFIX, "PrefillCheck", predName, "Prefilling to 1.0.")
			endIF
		endIf
	endIf
EndFunction


Actor[] Function Filter1(Actor[] NPCs, Actor excluded, Actor included)
	{ Filters a list of NPCs with one excluded Refs and a choice of one required ref and one required faction. }

	Actor[] filtered = new Actor[20]
	int addIndex = 0
	int checkIndex = NPCs.length
	if checkIndex > filtered.length
		checkIndex = filtered.length
	endIf

	while checkIndex
		checkIndex -= 1
		Actor NPC = NPCs[checkIndex] as Actor

		if NPC && NPC != excluded && !NPC.isDead() && (NPC == included || LibFire.ActorIsFollower(NPC)) && !NPC.isDead() && !NPC.isDisabled() && !NPC.isChild()
			filtered[addIndex] = NPC
			addIndex += 1
		endIf
	endWhile

	return filtered
endFunction


Actor[] Function Filter2(Actor[] NPCs, Actor excluded1, Actor excluded2)
	{ Filters a list of NPCs with two excluded Refs and one excluded faction. }

	Actor[] filtered = new Actor[20]
	int addIndex = 0
	int checkIndex = NPCs.length
	if checkIndex > filtered.length
		checkIndex = filtered.length
	endIf

	while checkIndex
		checkIndex -= 1
		Actor NPC = NPCs[checkIndex] as Actor

		if NPC && NPC != excluded1 && NPC != excluded2 && !NPC.isDead() && !LibFire.ActorIsFollower(NPC) && !NPC.isDead() && !NPC.isDisabled() && !NPC.isChild()
			filtered[addIndex] = NPC
			addIndex += 1
		endIf
	endWhile

	return filtered
endFunction


Actor[] Function Filter3(Actor[] NPCs, Actor excluded)
	{ Filters a list of NPCs with one excluded Ref. }

	Actor[] filtered = new Actor[20]
	int addIndex = 0
	int checkIndex = NPCs.length
	if checkIndex > filtered.length
		checkIndex = filtered.length
	endIf

	while checkIndex
		checkIndex -= 1
		Actor NPC = NPCs[checkIndex] as Actor

		if NPC && NPC != excluded && !NPC.isDead() && !NPC.isDisabled() && !NPC.isChild()
			filtered[addIndex] = NPC
			addIndex += 1
		endIf
	endWhile

	return filtered
endFunction


bool Function PlayerCheck(Actor target)
	if target == PlayerRef
		return !Manager.PlayerAvoidant
	else
		return !Manager.PlayerCentric
	endIf
EndFunction
