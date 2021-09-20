ScriptName DevourmentWeightManager Extends ReferenceAlias
{
AUTHOR: Gaz
PURPOSE: WeightMorphs-esque Slider Manager for both Player and NPCs.
CREDIT: WeightMorphs and Ousnius, for providing the basis for this idea and implementation.
}
import Logging


;Plugin-set Properties.
Actor Property PlayerRef Auto
DevourmentManager property Manager auto
DevourmentSurvivalNeeds property Needs auto


;Settings Properties.
Bool Property PlayerEnabled = true Auto
Bool Property CompanionsEnabled = false Auto
Bool Property ActorsEnabled = false Auto
Float Property WeightLoss = 0.01 auto
Float Property WeightRate = 4.0 auto
Float Property MaximumWeight = 2.0 Auto
Float Property MinimumWeight = -1.0 Auto
Float Property VoreBaseGain = 0.05 Auto
Float Property IngredientBaseGain = 0.04 Auto
Float Property PotionBaseGain = 0.02 Auto
Float Property FoodBaseGain = 0.10 Auto
Float Property HighValueMultiplier = 2.0 Auto
Form[] Property HighValueFood Auto
Form[] Property NoValueFood Auto

String[] property MorphStrings auto
Float[] property MorphsHigh auto
Float[] property MorphsLow auto

String property rootNode = "NPC Root [Root]" autoReadOnly
float property RootLow = 0.0 auto
float property RootHigh = 0.0 auto


;Script-set Properties.
String PREFIX = "DevourmentWeightManager"
;String ConfigFile = "..\\devourment\\weightMorphing.json"


;Events
Event OnInit()
	SyncSettings()
EndEvent


Event OnPlayerLoadGame()
	SyncSettings()
EndEvent


Function SyncSettings(bool write = false)
	If PlayerEnabled || CompanionsEnabled || ActorsEnabled
        EventRegistration(True)
    EndIf
EndFunction


Function EventRegistration(Bool Register)
    If Register
		ConsoleUtil.PrintMessage("WeightManagement started.")
        RegisterForModEvent("Devourment_OnDeadDigestion", "DeadDigest")
        RegisterForModEvent("Devourment_onDeadReforming", "DeadReform")
        RegisterForModEvent("Devourment_onConsumeItem", "ItemConsume")

		if PlayerEnabled
			RegisterForSingleUpdateGameTime(WeightRate)
			RegisterForSleep()
			RegisterForModEvent("HookAnimationEnd", "SexlabAnimationEnd")
		endIf
    Else 
        UnRegisterForModEvent("Devourment_OnDeadDigestion")
        UnRegisterForModEvent("Devourment_onDeadReforming")
        UnRegisterForModEvent("Devourment_onConsumeItem")
		UnregisterForUpdate()
		UnregisterForUpdateGameTime()
		UnregisterForSleep()
    EndIf
EndFunction


Event OnUpdate()
	if PlayerEnabled
		ChangeActorWeight(PlayerRef, -WeightLoss)
	endIf

	if CompanionsEnabled && !ActorsEnabled
		Actor[] nearby = LibFire.FindNearbyFollowers(2048.0)
		int index = nearby.length
		while index
			index -= 1
			ChangeActorWeight(nearby[index], -WeightLoss)
		endWhile
	elseif ActorsEnabled
		Actor[] nearby = LibFire.FindNearbyActors(PlayerRef, 2048.0)
		int index = nearby.length
		while index
			index -= 1
			if nearby[index].HasKeywordString("ActorTypeNPC")
				ChangeActorWeight(nearby[index], -WeightLoss)
			endIf
		endWhile
	endIf

	If PlayerEnabled || CompanionsEnabled || ActorsEnabled
		RegisterForSingleUpdate(WeightRate * 3600.0)
	endIf
EndEvent 


Event OnUpdateGameTime()
	if PlayerEnabled
		ChangeActorWeight(PlayerRef, -WeightLoss)
	endIf

	if CompanionsEnabled || ActorsEnabled
		Actor[] nearby

		if CompanionsEnabled && !ActorsEnabled
			nearby = LibFire.FindNearbyFollowers(4096.0)
		else
			nearby = LibFire.FindNearbyActors(PlayerRef, 4096.0)
		endIf

		int index = nearby.length
		while index
			index -= 1
			Actor who = nearby[index]
			if !who.IsDead() && who.IsEnabled() && who.HasKeywordString("ActorTypeNPC")
				ChangeActorWeight(who, -WeightLoss)
			endIf
		endWhile
	endif

	If PlayerEnabled || CompanionsEnabled || ActorsEnabled
		RegisterForSingleUpdateGameTime(WeightRate)
	endIf
EndEvent 


Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
	ChangeActorWeight(PlayerRef, -afDesiredSleepEndTime / (WeightRate * 24.0))
EndEvent


Event SexlabAnimationEnd(int tid, bool HasPlayer)
	if HasPlayer
		ChangeActorWeight(PlayerRef, -WeightLoss)
	endIf
EndEvent


Event DeadDigest(Form f1, Form f2, float remaining)
	; This prevents gaining weight from prey that are reformed or fully digested.
	if remaining >= 100.0 || remaining <= 0.0
		return
	endIf

    Actor pred = f1 as Actor
    Actor prey = f2 as Actor
    
	If pred && prey && !isValidConsumer(pred)
        return
    endIf

    ;This will fire every tick of digestion so set it low and gradual.
    ;It would be much less computationally heavy to just wait until Digestion is over
    ;and *then* do this, but people want fidelity, to see the WG in action as they digest things.
	float currentWeight = ChangeActorWeight(pred, VoreBaseGain / Manager.DigestionTime)
EndEvent


Event DeadReform(Form f1, Form f2, float remaining)
	; This prevents gaining weight from prey that are reformed or fully digested.
	if remaining >= 100.0 || remaining <= 0.0
		return
	endIf

    Actor pred = f1 as Actor
    Actor prey = f2 as Actor
    
	If pred && prey && !isValidConsumer(pred)
        return
    endIf

	float currentWeight = ChangeActorWeight(pred, -VoreBaseGain / Manager.DigestionTime)
EndEvent


Event ItemConsume(Form consumer, Form itemBase, int count)
{ Event that fires when Devourment Actors consume something via Object Vore / Feeding. Also called for Player Equip events. }

    ; Putting this here is a bit ugly but might be worth it in the future.
    If NoValueFood.Find(itemBase) >= 0
		ConsoleUtil.PrintMessage(Namer(itemBase) + " has no food value.")
        Return
    endIf
    
    Actor pred = consumer as Actor
	If !isValidConsumer(pred)
		Log1(PREFIX, "ItemConsume", "INVALID CONSUMER")
        return
    endIf

	float baseWeight = itemBase.GetWeight()

    If FoodBaseGain > 0.0 && itemBase.HasKeywordString("VendorItemFood")
        If HighValueFood.Find(itemBase) >= 0
			ConsoleUtil.PrintMessage(Namer(itemBase) + ": high value food.")
            ChangeActorWeight(pred, FoodBaseGain * baseWeight * HighValueMultiplier)
        else
			ConsoleUtil.PrintMessage(Namer(itemBase) + ": regular food.")
            ChangeActorWeight(pred, FoodBaseGain * baseWeight)
        EndIf
		Manager.RegisterFakeDigestion(pred, baseWeight * count * 2.0)

    ElseIf PotionBaseGain > 0.0 && itemBase.HasKeywordString("VendorItemPotion")
        ChangeActorWeight(pred, PotionBaseGain)
		Manager.RegisterFakeDigestion(pred, baseWeight * count)
        
    ElseIf IngredientBaseGain > 0.0 && itemBase as Ingredient
        ChangeActorWeight(pred, IngredientBaseGain * baseWeight)
		Manager.RegisterFakeDigestion(pred, baseWeight * count)
    EndIf
EndEvent


Event OnObjectEquipped(Form type, ObjectReference ref)
	if PlayerEnabled
		if type as Potion || type as Ingredient
			ItemConsume(PlayerRef, type, 1)
		endIf
	endIf
EndEvent


auto state DefaultState
endState


state LearnNoValue
	Event OnObjectEquipped(Form type, ObjectReference ref)
		if type as Potion || type as Ingredient
			addNoValueFood(type)
		endIf
	EndEvent
endState


state LearnHighValue
	Event OnObjectEquipped(Form type, ObjectReference ref)
		if type as Potion || type as Ingredient
			addHighValueFood(type)
		endIf
	EndEvent
endState


Function ResetActorWeight(Actor target)
	Log1(PREFIX, "ResetActorWeight", Namer(target))
	if target
		bool isFemale = Manager.IsFemale(target)
		NIOverride.RemoveNodeTransformScale(target, false, isFemale, rootNode, PREFIX)
		NIOverride.UpdateNodeTransform(target, false, isFemale, rootNode)

		if NiOverride.HasBodyMorphKey(target, PREFIX)
			StorageUtil.UnSetFloatValue(target, "DevourmentActorWeight")
			NiOverride.ClearBodyMorphKeys(target, PREFIX)
			NiOverride.ClearBodyMorphKeys(target, PREFIX)
		endIf
	endIf
EndFunction


Function ResetActorWeights()
	NiOverride.ForEachMorphedReference("ResetActorWeight", Manager)
EndFunction


float Function GetCurrentActorWeight(Actor target)
	return StorageUtil.GetFloatValue(target, "DevourmentActorWeight", 0.0)
EndFunction


float Function ChangeActorWeight(Actor target, float afChange, float afPreview = 0.0)
	{ All-purpose function for losing and gaining Weight. }

	float CurrentWeight = StorageUtil.GetFloatValue(target, "DevourmentActorWeight", 0.0)
	;Log3(PREFIX, "ChangeActorWeight", Namer(target), CurrentWeight, afChange)

	if afChange != 0.0
		CurrentWeight += afChange
		if CurrentWeight < MinimumWeight
			CurrentWeight = MinimumWeight
		elseif CurrentWeight > MaximumWeight
			CurrentWeight = MaximumWeight
		endIf

		;Save our Weight on the actor.
		StorageUtil.SetFloatValue(target, "DevourmentActorWeight", CurrentWeight)
	endIf

	if afPreview == 0.0
		ConsoleUtil.PrintMessage(Namer(target, true) + "'s weight to changed by " + afChange + " to " + CurrentWeight + ".")
	else
		ConsoleUtil.PrintMessage("Previewing " + Namer(target, true) + " at weight " + afPreview)
	endIf

	int numMorphs = MorphStrings.Length
	int iSlider = 0

	; Apply the preview weight, if one was specified.
	if afPreview != 0.0
		CurrentWeight = afPreview
	endIf

	if RootLow != 0.0 && RootHigh != 0.0
		bool isFemale = Manager.IsFemale(target)
		if CurrentWeight < 0.0 && RootLow != 0.0
			NIOverride.AddNodeTransformScale(target, false, isFemale, rootNode, PREFIX, 1.0 - CurrentWeight * RootLow)
			NIOverride.UpdateNodeTransform(target, false, isFemale, rootNode)
		else
			NIOverride.AddNodeTransformScale(target, false, isFemale, rootNode, PREFIX, 1.0 + CurrentWeight * RootHigh)
			NIOverride.UpdateNodeTransform(target, false, isFemale, rootNode)
		endIf
	endIf

	if CurrentWeight < 0.0
		While iSlider < numMorphs && MorphStrings[iSlider] != ""
			NiOverride.SetBodyMorph(target, MorphStrings[iSlider], PREFIX, -CurrentWeight * MorphsLow[iSlider])
			iSlider += 1
		EndWhile
	else
		While iSlider < numMorphs && MorphStrings[iSlider] != ""
			NiOverride.SetBodyMorph(target, MorphStrings[iSlider], PREFIX, CurrentWeight * MorphsHigh[iSlider])
			iSlider += 1
		EndWhile
	endIf

    ;Update the model.
    NiOverride.UpdateModelWeight(target)

	return CurrentWeight
EndFunction


bool Function isValidConsumer(Actor consumer)
	if consumer == PlayerRef
		return PlayerEnabled
	elseif LibFire.ActorIsFollower(consumer)
		return CompanionsEnabled 
	elseif consumer.GetActorBase().IsUnique()
		return ActorsEnabled
	endIf
EndFunction


bool Function addHighValueFood(Form food)
	Log1(PREFIX, "addHighValueFood", Namer(food))
	DevourmentUtil.ArrayAddFormEx(HighValueFood, food)
	SyncSettings(true)
	ConsoleUtil.PrintMessage("Added High-Value food: " + Namer(food))
	LogForms(PREFIX, "addHighValueFood", "HighValueFood", HighValueFood)
	return true
endFunction


bool Function addNoValueFood(Form food)
	Log1(PREFIX, "addNoValueFood", Namer(food))
	DevourmentUtil.ArrayAddFormEx(NoValueFood, food)
	SyncSettings(true)
	ConsoleUtil.PrintMessage("Added No-Value food: " + Namer(food))
	LogForms(PREFIX, "addNoValueFood", "NoValueFood", HighValueFood)
	return true
endFunction


bool Function addMorph(String name, float multHigh, float multLow)
	if MorphStrings.find(name) >= 0
        return false
    endIf

    int index = MorphStrings.find("")
    if index < 0 
		int newSize = 1 + MorphStrings.length * 2
        MorphStrings = Utility.ResizeStringArray(MorphStrings, newSize, "")
        MorphsHigh = Utility.ResizeFloatArray(MorphsHigh, newSize, 0.0)
        MorphsLow = Utility.ResizeFloatArray(MorphsLow, newSize, 0.0)

		index = MorphStrings.find("")
		if index < 0 
			return false
		endIf
    endIf

    MorphStrings[index] = name
    MorphsHigh[index] = multHigh
    MorphsLow[index] = multLow

	SyncSettings(true)
	return true
EndFunction


bool Function removeMorph(String name)
    int index = MorphStrings.find(name)
    if index < 0 
        return false
    endIf

    MorphStrings[index] = ""

    int checkIndex = index + 1
    
    while checkIndex < MorphStrings.length
        if MorphStrings[checkIndex] != ""
            MorphStrings[index] = MorphStrings[checkIndex]
            MorphsHigh[index] = MorphsHigh[checkIndex]
            MorphsLow[index] = MorphsLow[checkIndex]
            MorphStrings[checkIndex] = ""
            index = MorphStrings.find("")
            checkIndex = index + 1
        else
            checkIndex += 1
        endIf
    endWhile

	SyncSettings(true)
    return true
EndFunction


int Function GetWeightApprox(Actor target)
	float diff = MaximumWeight - MinimumWeight
	float baseWeight = StorageUtil.GetFloatValue(target, "DevourmentActorWeight", 0.0)
	float weight = 100.0 + (baseWeight - MinimumWeight) * 150.0 / diff
	return weight as int
EndFunction


float Function GetLossPerDay()
	return 24.0 * WeightLoss / WeightRate
EndFunction


float Function GetGainPerHumanoid()
	return 2.0 * VoreBaseGain
EndFunction


float Function GetGainPer100Food()
	return 100.0 * FoodBaseGain
EndFunction


Function LoadSettingsFrom(int data)
	PlayerEnabled =			JMap.GetInt(data, "PlayerEnabled", PlayerEnabled as int) as bool
	CompanionsEnabled =		JMap.GetInt(data, "CompanionsEnabled", CompanionsEnabled as int) as bool
	ActorsEnabled =			JMap.GetInt(data, "ActorsEnabled", ActorsEnabled as int) as bool
	WeightLoss =			JMap.GetFlt(data, "WeightLoss", WeightLoss)
	WeightRate =			JMap.GetFlt(data, "WeightRate", WeightRate)
	MaximumWeight =			JMap.GetFlt(data, "MaximumWeight", MaximumWeight)
	MinimumWeight =			JMap.GetFlt(data, "MinimumWeight", MinimumWeight)
	VoreBaseGain =			JMap.GetFlt(data, "VoreBaseGain", VoreBaseGain)
	IngredientBaseGain =	JMap.GetFlt(data, "IngredientBaseGain", IngredientBaseGain)
	PotionBaseGain =		JMap.GetFlt(data, "PotionBaseGain", PotionBaseGain)
	FoodBaseGain =			JMap.GetFlt(data, "FoodBaseGain", FoodBaseGain)
	HighValueMultiplier = 	JMap.GetFlt(data, "HighValueMultiplier", HighValueMultiplier)
	RootLow = 				JMap.GetFlt(data, "RootLow", 0.0)
	RootHigh = 				JMap.GetFlt(data, "RootHigh", 0.0)

	MorphStrings = 			JArray.asStringArray(JMap.getObj(data, "MorphStrings", JArray.ObjectWithStrings(MorphStrings)))
	MorphsHigh = 			JArray.asFloatArray(JMap.getObj(data, "MorphsHigh", JArray.ObjectWithFloats(MorphsHigh)))
	MorphsLow = 			JArray.asFloatArray(JMap.getObj(data, "MorphsLow", JArray.ObjectWithFloats(MorphsLow)))
	HighValueFood = 		JArray.asFormArray(JMap.getObj(data, "HighValueFood", JArray.ObjectWithForms(HighValueFood)))
	NoValueFood = 			JArray.asFormArray(JMap.getObj(data, "NoValueFood", JArray.ObjectWithForms(NoValueFood)))

	if MorphStrings == none 
		MorphStrings = new String[20]
		MorphsHigh = new float[20]
		MorphsLow = new float[20]

    elseif MorphStrings.length < 20
        Utility.ResizeStringArray(MorphStrings, 20)
        Utility.ResizeFloatArray(MorphsHigh, 20)
        Utility.ResizeFloatArray(MorphsLow, 20)
    endIf
EndFunction


Function SaveSettingsTo(int data)
	JMap.SetInt(data, "PlayerEnabled", 			PlayerEnabled as int) as bool
	JMap.SetInt(data, "CompanionsEnabled", 		CompanionsEnabled as int) as bool
	JMap.SetInt(data, "ActorsEnabled", 			ActorsEnabled as int) as bool
	JMap.SetFlt(data, "WeightLoss", 			WeightLoss)
	JMap.SetFlt(data, "WeightRate", 			WeightRate)
	JMap.SetFlt(data, "MaximumWeight", 			MaximumWeight)
	JMap.SetFlt(data, "MinimumWeight", 			MinimumWeight)
	JMap.SetFlt(data, "VoreBaseGain", 			VoreBaseGain)
	JMap.SetFlt(data, "IngredientBaseGain", 	IngredientBaseGain)
	JMap.SetFlt(data, "PotionBaseGain", 		PotionBaseGain)
	JMap.SetFlt(data, "FoodBaseGain", 			FoodBaseGain)
	JMap.SetFlt(data, "HighValueMultiplier", 	HighValueMultiplier)
	JMap.SetFlt(data, "RootLow", 				RootLow)
	JMap.SetFlt(data, "RootHigh", 				RootHigh)
	JMap.SetObj(data, "MorphStrings", 			JArray.objectWithStrings(MorphStrings))
	JMap.SetObj(data, "MorphsHigh", 			JArray.objectWithFloats(MorphsHigh))
	JMap.SetObj(data, "MorphsLow", 				JArray.objectWithFloats(MorphsLow))
	JMap.SetObj(data, "HighValueFood", 			JArray.objectWithForms(HighValueFood))
	JMap.SetObj(data, "NoValueFood", 			JArray.objectWithForms(NoValueFood))
EndFunction


Function Upgrade(int oldVersion, int newVersion)
	Log2(PREFIX, "Upgrade", oldVersion, newVersion)
	
	if oldVersion > 0 && oldVersion != newVersion
		ResetActorWeights()
	endIf
EndFunction
	
	
DevourmentWeightManager Function instance() global
	Quest.GetQuest("DevourmentWeightManager").GetAliasById(0)
EndFunction
