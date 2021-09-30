ScriptName DevourmentEffect_Struggling extends ActiveMagicEffect
import Logging


DevourmentManager property Manager auto
DevourmentDialog property DialogQuest auto
Actor property PlayerRef auto
Perk property ConstrictingGrip auto
CommonMeterInterfaceHandler property PlayerStruggleMeter auto


String PREFIX = "DevourmentEffect_Struggling"
bool DEBUGGING = true

Actor pred
int preyData
bool constricted
float cameraShake
float struggleDifficulty 
float struggleDamage
String playerName 

float struggleScaling = 0.2
int BLOCK_KEY = 0
int ATTACK_KEY = 0
int STRUGGLE_KEY1 = 0
int STRUGGLE_KEY2 = 0
bool StruggleLatch = false
float struggleProgress = 0.0
int selectedStruggleKey = 0


Event OnEffectStart(Actor target, Actor caster)
	preyData = Manager.GetPreyData(PlayerRef)
	playerName = Namer(PlayerRef, true)

	pred = Manager.GetPred(preyData)
	constricted = pred.hasPerk(ConstrictingGrip)
	cameraShake = Manager.cameraShake
	struggleDifficulty = Manager.struggleDifficulty
	struggleDamage = Manager.GetStruggleDamage(pred, PlayerRef)

	if Game.UsingGamepad()
		STRUGGLE_KEY1 = Input.GetMappedKey("Left Attack/Block")
		STRUGGLE_KEY2 = Input.getMappedKey("Right Attack/Block")
	else
		STRUGGLE_KEY1 = Input.getMappedKey("Strafe Left")
		STRUGGLE_KEY2 = Input.getMappedKey("Strafe Right")
	endIf

	selectedStruggleKey = STRUGGLE_KEY1
	StruggleLatch = true
	RegisterForKey(selectedStruggleKey)
	ResolvePlayerStruggle(0)
	
	if DEBUGGING
		!assertNotNone(PREFIX, "Struggle", "pred", pred)
		!assertExists(PREFIX, "Struggle", "preyData", preyData)
		Log3(PREFIX, "OnEffectStart", Namer(pred), constricted, struggleDamage)
	endIf
	
	BLOCK_KEY = Input.GetMappedKey("Left Attack/Block")
	ATTACK_KEY = Input.GetMappedKey("Right Attack/Block")

	RegisterForKey(ATTACK_KEY)
	RegisterForKey(BLOCK_KEY)
EndEvent


Event OnEffectFinish(Actor target, Actor caster)
	PlayerStruggleMeter.RemoveMeter()
EndEvent


Event OnPlayerLoadGame()
	RegisterForModEvent("Devourment_PlayerStruggle", "OnPlayerStruggle")
EndEvent


Function updateStruggleMeter(float struggle)
	PlayerStruggleMeter.AttributeValue.setValue(struggle)
	PlayerStruggleMeter.UpdateMeter(true)
endFunction	


Event OnKeyUp(int keyCode, float holdTime)
	if keyCode == ATTACK_KEY
		if Game.GetCameraState() == 0
			Debug.SendAnimationEvent(PlayerRef, "AttackStartH2HRight")
		endIf
	elseif keyCode == BLOCK_KEY
		if Game.GetCameraState() == 0
			Debug.SendAnimationEvent(PlayerRef, "AttackStartH2HLeft")
		endIf
	elseif StruggleLatch && (keyCode == STRUGGLE_KEY1 || keyCode == STRUGGLE_KEY2)
		StruggleLatch = false
		if !DialogQuest.Activated && DevourmentUtil.SafeProcess() && Manager.canStruggle(playerRef, preyData)
			ResolvePlayerStruggle(keyCode)
		endIf
	endIf
EndEvent


Function ResolvePlayerStruggle(int keyCode)
	bool successful = keyCode == selectedStruggleKey && keyCode != 0

	if successful
		if selectedStruggleKey == STRUGGLE_KEY1
			selectedStruggleKey = STRUGGLE_KEY2
		else
			selectedStruggleKey = STRUGGLE_KEY1
		endIf

		RegisterForKey(selectedStruggleKey)
	endIf

	; Chance in the struggle bar.
	float increment = struggleDifficulty * struggleScaling
	float damage = struggleDamage * struggleScaling

	if DEBUGGING
		Log5(PREFIX, "ResolvePlayerStruggle", keyCode, successful, increment, damage, struggleProgress)
	endIf

	if constricted
		increment *= 0.2
	endIf
	
	if successful
		struggleProgress += increment
		if struggleProgress > 100.0
			struggleProgress = 100.0
		endIf
	else
		struggleProgress -= increment
		if struggleProgress < 0.0
			struggleProgress = 0.0
		endIf
	endIf

	UpdateStruggleMeter(struggleProgress)
	StruggleLatch = true

	; Struggle damage dealt to pred.
	Manager.playGurgle(pred, 10.0 * struggleScaling)

	if cameraShake > 0.0 && Utility.RandomFloat() < struggleScaling
		Game.ShakeCamera(pred, cameraShake)
	endIf

	; Vomit the prey if they've filled the strugglebar.
	if struggleProgress >= 100.0
		Manager.CheckAndSetPartingGift(pred, PlayerRef)
		Manager.ForceEscape(PlayerRef)
	endIf

	if !successful
		return
	endIf

	; Apply damage and show notifications.
	if constricted
		if DEBUGGING
			ConsoleUtil.PrintMessage(PlayerName + " struggled " + struggleProgress as int + " percent free.")
		endIf
	else
		pred.DamageActorValue("Health", damage)
		if DEBUGGING
			ConsoleUtil.PrintMessage(PlayerName + " struggled " + struggleProgress as int + " percent free, causing " + damage + " damage.")
		endIf
	endIf

	int handle = ModEvent.Create("Devourment_PlayerStruggle")
	ModEvent.Send(handle)

	Manager.GivePreyXP_async(PlayerRef, damage / 5.0)
	if !constricted
		Manager.GivePredXP_async(pred, damage / 5.0)
	endIf	
EndFunction
