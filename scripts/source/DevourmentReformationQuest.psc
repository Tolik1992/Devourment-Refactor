ScriptName DevourmentReformationQuest extends Quest
{ 
To add a reformation host (for the default scenario) use this code:
DevourmentReformationQuest.instance().AddReformationHost(host)

To start reforming the player inside of Pred, call
DevourmentManager.RegisterReformation(pred, playerRef, locus)

}
import Logging


DevourmentManager property Manager auto
Actor property PlayerRef auto
FormList property PhylacteryList auto


String PREFIX = "DevourmentReformationQuest"


Event onInit()
	RegisterForAnimationEvent(PlayerRef, "SoundPlay.NPCHorseDismount")
EndEvent


Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	If akSource == PlayerRef
		If asEventName == "SoundPlay.NPCHorseDismount"
			Actor horse = Game.GetPlayersLastRiddenHorse()
			if horse
				AddReformationHost(horse)
			endIf		
		endIf
	endIf
EndEvent


Function Upgrade(int oldVersion, int newVersion)
{ Version 105 is a clean break, so upgrades all start from there. }
	Log2(PREFIX, "Upgrade", oldVersion, newVersion)
EndFunction
	
	
bool Function StartReformation()
{ Precondition: the player has been digested and defecated. }
	Log0(PREFIX, "StartReformation")
	RegisterForSingleUpdate(0.5)
	return true
EndFunction


Event OnUpdate()
	Log0(PREFIX, "OnUpdate")
	DefaultReformation()
EndEvent


Function DefaultReformation()
	Log0(PREFIX, "DefaultReformation")
	
	Actor reviver = GetReformationHost()
	Log2(PREFIX, "DefaultReformation", "Reviver selection:", Namer(reviver))

	if reviver == none || reviver.IsDead() || reviver.IsDisabled()
		Log1(PREFIX, "DefaultReformation", "Invalid reviver, killing player.")
		Manager.KillPlayer_ForReal()
		return
	endIf
	
	if Manager.IsPrey(reviver)
		Log1(PREFIX, "DefaultReformation", "Reviver is prey, forcing escape.")
		Manager.ForceEscape(reviver)
	endIf

	Log1(PREFIX, "DefaultReformation", "Prepared: calling RegisterReformation now!")
	Manager.RegisterReformation(reviver, PlayerRef, 0)
EndFunction


Actor Function GetReformationHost()
	Form[] ReformationHosts = PhylacteryList.ToArray()
	int hostIndex = ReformationHosts.length

	while hostIndex
		hostIndex -= 1
		Actor host = ReformationHosts[hostIndex] as Actor

		; Clear any hosts that are dead, disabled, or unfriendly.
		if host
			if host.IsDead() || host.IsDisabled() || !Manager.AreFriends(PlayerRef, host)
				Log2(PREFIX, "GetReformationHost", "Purging dead/disabled/hostile host.", Namer(host))
				PhylacteryList.RemoveAddedForm(host)
			endIf
		endIf
	endWhile

	if PhylacteryList.GetSize() == 0
		return none
	endIf

	Debug.MessageBox("Who does your soul reach out to?")

	UIListMenu hostList = UIExtensions.GetMenu("UIListMenu") as UIListMenu
	hostList.ResetMenu()

	ReformationHosts = PhylacteryList.ToArray()
	int index = 0
	while index < ReformationHosts.length
		Actor phylactery = ReformationHosts[index] as Actor
		hostList.AddEntryItem(Namer(phylactery))
		index += 1
	endWhile

	hostList.OpenMenu()
	hostIndex = hostList.GetResultInt()
	if hostIndex < 0
		return None
	endIf

	Actor host = ReformationHosts[hostIndex] as Actor

	assertNotNone(PREFIX, "GetReformationHost", "host", host)
	assertFalse(PREFIX, "GetReformationHost", "host.IsDead()", host.IsDead())
	assertFalse(PREFIX, "GetReformationHost", "host.IsDisabled()", host.IsDisabled())
	assertTrue(PREFIX, "GetReformationHost", "Manager.AreFriends(PlayerRef, host)", Manager.AreFriends(PlayerRef, host))

	return host
EndFunction


bool Function AddReformationHost(Actor host)
	if !host
		AssertNotNone(PREFIX, "AddReformationHost", "host", host)
		return false
	endIf

	Log1(PREFIX, "AddReformationHost", Namer(host))
	PhylacteryList.AddForm(host)
	return true
endFunction


DevourmentReformationQuest Function instance() global
	{ Returns the DevourmentReformationQuest instance, for situations in which a property isn't helpful (like global functions). }
	return Quest.GetQuest("DevourmentReformationQuest") as DevourmentReformationQuest
EndFunction
