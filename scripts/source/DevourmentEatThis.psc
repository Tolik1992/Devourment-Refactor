Scriptname DevourmentEatThis extends ActiveMagicEffect
import Logging


Actor property PlayerRef auto
DevourmentManager property Manager auto
Container property BolusContainer auto


String PREFIX = "DevourmentEatThis"
DevourmentBolus bolus = none
Actor receiverPred = none
Actor actualPred = none


Event OnEffectStart(Actor akTarget, Actor akCaster)
	if !assertNotNone(PREFIX, "OnEffectStart", "akTarget", akTarget)
		Dispel()
		return 
	endIf
	
	bolus = Manager.FakePlayer.placeAtMe(BolusContainer) as DevourmentBolus
	receiverPred = akTarget

	if akTarget == Manager.FakePlayer
		actualPred = PlayerRef
		bolus.eatConsumables = false
	else
		actualPred = akTarget
		bolus.eatConsumables = true
	endIf

	bolus.Initialize(Namer(PlayerRef, true) + "'s stash", PlayerRef, actualPred)
	RegisterForMenu("GiftMenu")
	receiverPred.ShowGiftMenu(true, none, true, false)
	;Log2(PREFIX, "OnEffectStart", Namer(actualPred), Namer(receiverPred))
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
EndEvent


Event OnMenuClose(string menuName)
	if bolus.GetNumItems() > 0
		Manager.RegisterDigestion(actualPred, bolus, false, 0)
		Manager.PlayVoreAnimation_Item(actualPred, bolus, 0, true)
	else
		bolus.delete()
	endIf

	if receiverPred == Manager.FakePlayer
		Manager.FakePlayer.MoveTo(Manager.HerStomach)
	endIf

	UnregisterForAllMenus()
	Dispel()
EndEvent


Function OnItemAdded(Form baseItem, int itemCount, ObjectReference itemReference, ObjectReference source)
	;Log6(PREFIX, "OnItemAdded", Namer(baseItem), itemCount, Namer(itemReference), Namer(source), Namer(actualPred), Namer(receiverPred))

	if source == PlayerRef
		if itemReference
			receiverPred.RemoveItem(itemReference, itemCount, false, bolus)
			Manager.PlayVoreAnimation_Item(actualPred, itemReference, 0, true)
		else
			receiverPred.RemoveItem(baseItem, itemCount, false, bolus)
		endIf
	endIf
EndFunction
