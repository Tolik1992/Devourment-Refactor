Scriptname DevourmentMCM extends SKI_ConfigBase conditional
{
Manages the mod configuration menu for Devourment.
It also stores all of the vore perks as properties, so it is very
useful for any other script that needs to access perks by name.
}
import DevourmentUtil
import Logging


Actor property PlayerRef auto
DevourmentPlayerAlias Property PlayerAlias Auto
DevourmentManager Property Manager Auto
DevourmentMorphs property Morphs auto
DevourmentSkullHandler property SkullHandler auto
DevourmentWeightManager property WeightManager auto
GlobalVariable property VoreDialog auto
bool property DisableDependencyChecks = false auto
bool property EnableHungryBones = true auto
bool property EnableCordyceps = true auto
bool property LooseItemVore = true auto
bool property AutoRebirth = true auto
bool property AltPerkMenus = false auto
bool property SLAccidents = false auto
bool property DontAddPowers = false auto conditional
bool property UnrestrictedItemVore = false auto
bool property GentleGas = false auto
bool property CounterVoreEnabled = true auto
bool property DigestToInventory = false auto
float[] property LocusChances auto
float[] property LocusCumulative auto
String[] property StatRaces auto

Perk[] Property DigestItems_arr Auto
Perk[] Property IronStomach_arr Auto
Perk[] Property Resilience_arr auto
Perk[] Property Slippery_arr auto
Perk[] Property StrongAcid_arr auto
Perk[] Property Struggle_arr auto
Perk[] Property Voracious_arr auto
Perk Property Comfy Auto
Perk Property ConstrictingGrip Auto
Perk Property ConsumeEssence Auto
Perk Property CounterVore auto
Perk Property Cordyceps Auto
Perk Property Delicious Auto
Perk Property DigestionDaedric Auto
Perk Property DigestionDwemer Auto
Perk Property DigestionUndead Auto
Perk Property NourishmentBody Auto
Perk Property NourishmentMana Auto
Perk Property PartingGift Auto
Perk Property Phylactery auto
Perk Property RaiseDead Auto
Perk Property SilentDefecate Auto
Perk Property SilentSwallow Auto
Perk Property SoulFood Auto
Perk Property StickTheLanding Auto
Perk Property StrongBack Auto
Perk Property VoreMagic1 auto
Perk Property VoreMagic2 auto

Spell Property QuickSettings auto
Spell Property Power_Regurgitate auto
Spell Property Power_Defecate auto
Spell Property Power_DigestItems auto


String property ExportFilename = "data\\skse\\plugins\\devourment\\db_export.json" autoreadonly
String property SettingsFileName = "data\\skse\\plugins\\devourment\\settings.json" autoreadonly
String property PredPerkFile = "data\\skse\\plugins\\devourment\\PredPerkData.json" autoreadonly
String property PreyPerkFile = "data\\skse\\plugins\\devourment\\PreyPerkData.json" autoreadonly


string[] scatListNPC
string[] scatListCreature
string[] scatListBolus
string[] BYKList
string[] disableList
string[] equipList
string[] struggleList
string[] nomsList
string[] multiPreyList
string[] difficultyList
string[] vomitStyles


int showPerks = 0
bool resetBellies = false
bool resetActorWeights = false
bool vomitActivated = false
bool flushActivated = false
bool adjustPreyData = false


int predSkillInfo
int preySkillInfo


String PREFIX = "DevourmentManager"
int preyID = 0
int difficulty = 2
int bellyPreset = 1


int optionsMap



int property VERSION = 117 auto
int function GetVersion()
	return 117
endFunction


event onConfigOpen()
	vomitActivated = false
	flushActivated = false
	resetBellies = false
	resetActorWeights = false
	adjustPreyData = false
	showPerks = 0
endEvent


event OnConfigClose()
	RecalculateLocusCumulative()

	if resetBellies
		resetBellies = false
		Manager.ResetBellies()
	endIf

	if resetActorWeights
		resetActorWeights = false
		WeightManager.ResetActorWeights()
	endIf

	if adjustPreyData
		adjustPreyData = false
		Manager.AdjustPreyData()
	endIf

	if showPerks
		if showPerks == 1
			if AltPerkMenus
				ShowPerkSubMenu(playerRef, true)
			else
				Manager.Devourment_ShowPredPerks.SetValue(1.0)
			endIf
		elseif showPerks == 2
			if AltPerkMenus
				ShowPerkSubMenu(playerRef, false)
			else
				Manager.Devourment_ShowPreyPerks.SetValue(1.0)
			endIf
		endIf
	endIf
	
	showPerks = 0
endEvent


string Function GetCustomControl(int keyCode)
	if keyCode == PlayerAlias.DIALOG_KEY
		return "Dialog"
	elseif keyCode == PlayerAlias.COMPEL_KEY
		return "Compel"
	elseif keyCode == PlayerAlias.QUICK_KEY
		return "Settings"
	elseif keyCode == PlayerAlias.VORE_KEY
		return "Vore"
	elseif keyCode == PlayerAlias.ENDO_KEY
		return "Endo"
	elseif keyCode == PlayerAlias.COMB_KEY
		return "Swallow"
	elseif keyCode == PlayerAlias.FORGET_KEY
		return "Forget"
	else
		return ""
	endIf
endFunction


event OnConfigInit()
	Pages = new string[8]
	Pages[0] = "$DVT_Stats"
	Pages[1] = "$DVT_Basic"
	Pages[2] = "$DVT_Toggles"
	Pages[3] = "$DVT_Stomach"
	Pages[4] = "$DVT_Perks"
	Pages[5] = "$DVT_MorphSettings"
	Pages[6] = "$DVT_Weight"
	Pages[7] = "$DVT_Debugging"

	vomitStyles = new String[3]
	vomitStyles[0] = "$DVT_VOMITSTYLE0"
	vomitStyles[1] = "$DVT_VOMITSTYLE1"
	vomitStyles[2] = "$DVT_VOMITSTYLE2"

	BYKList = new String[3]
	BYKList[0] = "$BYK0"
	BYKList[1] = "$BYK1"
	BYKList[2] = "$BYK2"

	scatListNPC = new String[4]
	scatListNPC[0] = "$DVT_SCAT_Absorb"
	scatListNPC[1] = "$DVT_SCAT_Feces"
	scatListNPC[2] = "$DVT_SCAT_Bones"
	scatListNPC[3] = "$DVT_SCAT_Vomit"

	scatListCreature = new String[3]
	scatListCreature[0] = "$DVT_SCAT_Absorb"
	scatListCreature[1] = "$DVT_SCAT_Feces"
	scatListCreature[2] = "$DVT_SCAT_Vomit"

	scatListBolus = new String[3]
	scatListBolus[0] = "$DVT_SCAT_Add"
	scatListBolus[1] = "$DVT_SCAT_Defecate"
	scatListBolus[2] = "$DVT_SCAT_Vomit"
	
	disableList = new string[3]
	disableList[0]="$DVT_DISABLE_DPC"
	disableList[1]="$DVT_DISABLE_Restrained"
	disableList[2]="$DVT_DISABLE_PlayerControls"

	equipList = new string[3]
	equipList[0] = "$DVT_EquipNone"
	equipList[1] = "$DVT_EquipMacross"
	equipList[2] = "$DVT_EquipSkeptic"

	struggleList = new String[3]
	struggleList[0] = "$DVT_STRUGGLE_Off"
	struggleList[1] = "$DVT_STRUGGLE_Player"
	struggleList[2] = "$DVT_STRUGGLE_Everyone"

	nomsList = new String[4]
	nomsList[0] = "$DVT_Noms0"
	nomsList[1] = "$DVT_Noms1"
	nomsList[2] = "$DVT_Noms2"
	nomsList[3] = "$DVT_Noms3"

	multiPreyList = new string[5]
	multiPreyList[0] = "$DVT_MULTI_Off"
	multiPreyList[1] = "$DVT_MULTI_Count"
	multiPreyList[2] = "$DVT_MULTI_Size1"
	multiPreyList[3] = "$DVT_MULTI_Size2"
	multiPreyList[4] = "$DVT_MULTI_Full"
	
	difficultyList = new string[7]
	difficultyList[0] = "$DVT_DIFFICULTY_0"
	difficultyList[1] = "$DVT_DIFFICULTY_1"
	difficultyList[2] = "$DVT_DIFFICULTY_2"
	difficultyList[3] = "$DVT_DIFFICULTY_3"
	difficultyList[4] = "$DVT_DIFFICULTY_4"
	difficultyList[5] = "$DVT_DIFFICULTY_5"
	difficultyList[6] = "$DVT_DIFFICULTY_6"
endEvent


Event OnVersionUpdate(int newVersion)
	Upgrade(CurrentVersion, newVersion)
EndEvent


Function Upgrade(int oldVersion, int newVersion)
{ Version 116 is a clean break, so upgrades all start from there. }
	if oldVersion < newVersion
		VERSION = newVersion
		PlayerAlias.Upgrade(oldVersion, newVersion)
		Manager.Upgrade(oldVersion, newVersion)
		DevourmentSkullHandler.instance().Upgrade(oldVersion, newVersion)
		DevourmentReformationQuest.instance().Upgrade(oldVersion, newVersion)
		DevourmentNewDova.instance().Upgrade(oldVersion, newVersion)
		RecalculateLocusCumulative()
	endif
endFunction


Function setDifficultyPreset(int preset)
	difficulty = preset
	
	if difficulty == 0
		Manager.acidDamageModifier = 0.1
		Manager.PredExperienceRate = 0.2
		Manager.PreyExperienceRate = 0.1
		Manager.struggleDamage = 0.1
		Manager.struggleDifficulty = 10.0
		Manager.NPCBonus = 0.1
		Manager.endoAnyone = true
		Manager.killPlayer = false
		Manager.noEscape = false
		Manager.swallowHeal = true
		Manager.whoStruggles = 0
		Manager.DigestionTime = 60.0
	elseif difficulty == 1
		Manager.acidDamageModifier = 0.5
		Manager.PredExperienceRate = 0.5
		Manager.PreyExperienceRate = 0.1
		Manager.struggleDamage = 0.5
		Manager.struggleDifficulty = 10.0
		Manager.NPCBonus = 0.5
		Manager.endoAnyone = true
		Manager.killPlayer = false
		Manager.noEscape = false
		Manager.swallowHeal = true
		Manager.whoStruggles = 1
		Manager.DigestionTime = 120.0
	elseif difficulty == 2
		Manager.acidDamageModifier = 1.0
		Manager.PredExperienceRate = 1.0
		Manager.PreyExperienceRate = 2.0
		Manager.struggleDamage = 1.0
		Manager.struggleDifficulty = 10.0
		Manager.NPCBonus = 1.0
		Manager.endoAnyone = false
		Manager.killPlayer = true
		Manager.noEscape = true
		Manager.swallowHeal = true
		Manager.whoStruggles = 2
		Manager.DigestionTime = 180.0
	elseif difficulty == 3
		Manager.acidDamageModifier = 2.0
		Manager.PredExperienceRate = 2.0
		Manager.PreyExperienceRate = 4.0
		Manager.struggleDamage = 2.0
		Manager.struggleDifficulty = 10.0
		Manager.NPCBonus = 2.0
		Manager.endoAnyone = false
		Manager.killPlayer = true
		Manager.noEscape = true
		Manager.swallowHeal = false
		Manager.whoStruggles = 2
		Manager.DigestionTime = 300.0
	elseif difficulty == 4
		Manager.acidDamageModifier = 5.0
		Manager.PredExperienceRate = 5.0
		Manager.PreyExperienceRate = 10.0
		Manager.struggleDamage = 5.0
		Manager.struggleDifficulty = 10.0
		Manager.NPCBonus = 5.0
		Manager.endoAnyone = false
		Manager.killPlayer = true
		Manager.noEscape = true
		Manager.swallowHeal = false
		Manager.whoStruggles = 2
		Manager.DigestionTime = 600.0
	elseif difficulty == 6
		Manager.acidDamageModifier = 20.0
		Manager.PredExperienceRate = 0.0
		Manager.PreyExperienceRate = 0.0
		Manager.struggleDamage = 2.0
		Manager.struggleDifficulty = 10.0
		Manager.NPCBonus = 5.0
		Manager.endoAnyone = false
		Manager.killPlayer = true
		Manager.killNPCs = true
		Manager.killEssential = true
		Manager.noEscape = true
		Manager.swallowHeal = true
		Manager.whoStruggles = 2
		Manager.endoAnyone = true
		Manager.multiPrey = Manager.MULTI_UNLIMITED
		Manager.DigestionTime = 10.0
	endIf
EndFunction


int function checkDifficultyPreset() 
	if Manager.acidDamageModifier == 0.1 \
		&& Manager.struggleDamage == 0.1 \
		&& Manager.struggleDifficulty == 10.0 \
		&& Manager.NPCBonus == 0.1 \
		&& Manager.endoAnyone == true \
		&& Manager.killPlayer == false \
		&& Manager.noEscape == false \
		&& Manager.swallowHeal == true \
		&& Manager.whoStruggles == 0
		return 0
	elseif Manager.acidDamageModifier == 0.5 \
		&& Manager.struggleDamage == 0.5 \
		&& Manager.struggleDifficulty == 10.0 \
		&& Manager.NPCBonus == 0.5 \
		&& Manager.endoAnyone == true \
		&& Manager.killPlayer == false \
		&& Manager.noEscape == false \
		&& Manager.swallowHeal == true \
		&& Manager.whoStruggles == 1
		return 1
	elseif Manager.acidDamageModifier == 1.0 \
		&& Manager.struggleDamage == 1.0 \
		&& Manager.struggleDifficulty == 10.0 \
		&& Manager.NPCBonus == 1.0 \
		&& Manager.endoAnyone == false \
		&& Manager.killPlayer == true \
		&& Manager.noEscape == true \
		&& Manager.swallowHeal == true \
		&& Manager.whoStruggles == 2
		return 2
	elseif Manager.acidDamageModifier == 2.0 \
		&& Manager.struggleDamage == 2.0 \
		&& Manager.struggleDifficulty == 10.0 \
		&& Manager.NPCBonus == 2.0 \
		&& Manager.endoAnyone == false \
		&& Manager.killPlayer == true \
		&& Manager.noEscape == true \
		&& Manager.swallowHeal == false \
		&& Manager.whoStruggles == 2
		return 3
	elseif Manager.acidDamageModifier == 5.0 \
		&& Manager.struggleDamage == 5.0 \
		&& Manager.struggleDifficulty == 10.0 \
		&& Manager.NPCBonus == 5.0 \
		&& Manager.endoAnyone == false \
		&& Manager.killPlayer == true \
		&& Manager.noEscape == true \
		&& Manager.swallowHeal == false \
		&& Manager.whoStruggles == 2
		return 4
	else
		return 5
	endIf
endFunction


event OnPageReset(string page)
	optionsMap = JValue.ReleaseAndRetain(optionsMap, JIntMap.Object(), PREFIX)

	if difficulty < 5
		difficulty = checkDifficultyPreset()
	endIf
	
	int difficultyFlag = 0
	if difficulty < 5
		difficultyFlag = OPTION_FLAG_DISABLED
	endIf
	
	int targetFlags = 0
	Actor target = GetTarget()
	String targetName = Namer(target, true)
	Form resetPrey = Game.GetForm(preyID)

	if target == playerRef
		targetFlags = OPTION_FLAG_DISABLED
	endIf

	if Pages.find(page) < 0
		LoadCustomContent("Title.dds", 0, 126)
	else
		UnloadCustomContent()
	endIf

	if page == Pages[0]
		int perkPoints = Manager.GetPerkPoints(target)
		int predSkill = Manager.GetPredSkill(target) as int
		int preySkill = Manager.GetPreySkill(target) as int
		int numVictims = Manager.getNumVictims(target)
		int swallowSkill = Manager.getSwallowSkill(target) as int
		int acidDamage = Manager.getAcidDamage(target, Manager.fakePlayer) as int
		int MaxTime = Manager.getHoldingTime(target) as int
		int StruggleDamage = Manager.getStruggleDamage(target, Manager.fakePlayer) as int
		int acidresistance = (Manager.getAcidResistance(target) * 100) as int
		int swallowResistance = Manager.getSwallowResistance(target) as int
		int dtime = Manager.GetDigestionTime(target, none) as int
		int endoes = Manager.GetTimesSwallowed(target, true)
		int vores = Manager.GetTimesSwallowed(target, false)

		setCursorFillMode(TOP_TO_BOTTOM)
		addHeaderOption("Devourment v" + (Version / 100) + "." + (Version % 100))
		addTextOption("Viewing: ", targetName)
		predSkillInfo = addTextOption("Devourment pred skill: ", predSkill)
		preySkillInfo = addTextOption("Devourment prey skill: ", preySkill)
		addTextOption("Devourment level: ", Manager.GetVoreLevel(target))
		addTextOption("Devourment perk points: ", perkPoints)

		if Manager.MicroMode
			addTextOptionSt("CapacityInfoState",  "Devourment Capacity:   ", Manager.GetCapacity(target))
		endIf
		
		if WeightManager.PlayerEnabled
			addTextOption("Devourment Weight: ", WeightManager.GetWeightApprox(target))
		endIf

		addEmptyOption()
		addTextOption("Swallow skill: ", swallowSkill)
		addTextOption("Swallow resistance: ", swallowResistance)
		addTextOption("Acid damage: ", acidDamage + " hp/sec")
		addTextOption("Struggling damage: ", StruggleDamage + " hp")
		addTextOption("Maximum holding time: ", maxTime + " sec")
		addTextOption("Digestion duration: ", dtime + " sec")
		addTextOption("Acid resistance: ", acidresistance + "%")
		setCursorPosition(1)

		addHeaderOption("Total times swallowed: " + (endoes + vores))
		addTextOption("Endo", endoes)
		addTextOption("Vore", vores)
		
		addHeaderOption("Total victims digested: " + numVictims)
		addTextOption("Women", Manager.GetVictimType(target, "women"))
		addTextOption("Men", Manager.GetVictimType(target, "men"))
		addTextOption("Corpses", Manager.GetVictimType(target, "corpses"))

		DevourmentNewDova newDova = DevourmentNewDova.instance()
		if NewDova.prevDov > 0
			addTextOption("Previous Dovahkiins: ", NewDova.prevDov)
			addTextOption("Last Dovahkiin", NewDova.previousName)
		endif

		addEmptyOption()
		addTextOption("RACE ", " DIGESTED")
		
		int index = 0 
		while index < StatRaces.Length
			String raceName = StatRaces[index]
			addTextOption(raceName + " digested: ", Manager.GetVictimType(target, raceName))
			index += 1
		endWhile

		addTextOption("Others digested: ", Manager.GetVictimType(target, "other"))

	elseif page == Pages[1]
		setCursorFillMode(TOP_TO_BOTTOM)
		addHeaderOption("$DVT_Header_Difficulty")
		addMenuOptionSt("DifficultyMenuState", "$DVT_DifficultyPreset", difficultyList[difficulty])
		addMenuOptionSt("StruggleMenuState", "$DVT_Struggle", struggleList[Manager.whoStruggles], difficultyFlag)
		addMenuOptionSt("AutoNomsState", "$DVT_Autovore", nomsList[Manager.AutoNoms], difficultyFlag)
		addSliderOptionSt("StruggleDifficultyState", "$DVT_StruggleDifficulty", Manager.struggleDifficulty, "{1}x", difficultyFlag)
		addSliderOptionSt("StruggleDamageState", "$DVT_StruggleDamage", Manager.struggleDamage, "{1}x", difficultyFlag)
		addSliderOptionSt("DamageModState", "$DVT_AcidMult", Manager.AcidDamageModifier,"{1}x", difficultyFlag)
		addSliderOptionSt("PredExperienceRateState", "$DVT_PredExperienceRate", Manager.PredExperienceRate, "{1}x", difficultyFlag)
		addSliderOptionSt("PreyExperienceRateState", "$DVT_PreyExperienceRate", Manager.PreyExperienceRate, "{1}x", difficultyFlag)
		addSliderOptionSt("NPCBonusState", "$DVT_NPCChance", Manager.NPCBonus,"{1}x", difficultyFlag)
		addToggleOptionSt("SwallowHealState", "$DVT_SwallowHeal", Manager.SwallowHeal, difficultyFlag)
		addToggleOptionSt("endoAnyoneState", "$DVT_endoAnyone", Manager.endoAnyone, difficultyFlag)
		addToggleOptionSt("noEscapeState", "$DVT_NoEscape", Manager.NoEscape, difficultyFlag)
		addToggleOptionSt("microModeState", "$DVT_MicroMode", Manager.MicroMode)

		setCursorPosition(1)

		addHeaderOption("$DVT_Header_WhoGetsDigestested")
		addToggleOptionSt("DigestNPCState", "$DVT_DigestNonessentials", Manager.killNPCs)
		addToggleOptionSt("DigestEssentialState", "$DVT_DigestEssentials", Manager.killEssential)
		addToggleOptionSt("DigestPlayerState", "$DVT_DigestPlayer", Manager.killPlayer, difficultyFlag)

		addHeaderOption("$DVT_Header_WhoCanPred")

		if !Manager.VEGAN_MODE
			addToggleOptionSt("malePredToggleState", "$DVT_MalePred", Manager.malePreds)
			addToggleOptionSt("femalePredToggleState", "$DVT_FemPred", Manager.femalePreds)
		endIf

		addToggleOptionSt("creaturePredToggleState", "$DVT_creaturePred", Manager.creaturePreds)
		addToggleOptionSt("playerCentricState", "$DVT_PlayerCentric", Manager.PlayerCentric)
		addToggleOptionSt("playerAvoidantState", "$DVT_PlayerAvoidant", Manager.PlayerAvoidant)

		addHeaderOption("$DVT_Skulls")
		addToggleOptionSt("SkullsForDragonsState", "$DVT_SkullsDragons", SkullHandler.SkullsForDragons)
		addToggleOptionSt("SkullsForUniqueState", "$DVT_SkullsUnique", SkullHandler.SkullsForUnique || SkullHandler.SkullsForEveryone)
		addToggleOptionSt("SkullsForEssentialState", "$DVT_SkullsEssential", SkullHandler.SkullsForEssential || SkullHandler.SkullsForEveryone)
		addToggleOptionSt("SkullsForEveryoneState", "$DVT_SkullsEveryone", SkullHandler.SkullsForEveryone)
		addToggleOptionSt("SkullsSeparateState", "$DVT_SkullsSeparate", SkullHandler.SkullsSeparate)

	elseif page == Pages[2]
		setCursorFillMode(TOP_TO_BOTTOM)

		addHeaderOption("$DVT_Header_Visuals")
		addMenuOptionSt("ScatStateNPC", "$DVT_SCAT_TypeNPC", scatListNPC[Manager.scatTypeNPC])
		addMenuOptionSt("ScatStateCreature", "$DVT_SCAT_TypeCreature", scatListCreature[Manager.scatTypeCreature])
		addMenuOptionSt("ScatStateBolus", "$DVT_SCAT_TypeBolus", scatListBolus[Manager.scatTypeBolus])
		addMenuOptionSt("VomitStyleState", "$DVT_VomitStyle", vomitStyles[Manager.VomitStyle])
		addSliderOptionSt("cameraShakeState", "$DVT_cameraShake", Manager.cameraShake, "{2}")
		addSliderOptionSt("prefilledState", "$DVT_prefilled", Manager.PreFilledChance, "{2}")
		addToggleOptionSt("CombatAccelState", "$DVT_CombatAcceleration", Manager.CombatAcceleration)
		addToggleOptionSt("useHelpState", "$DVT_useHelpMessages", Manager.useHelpMessages)
		addToggleOptionSt("notificationsState", "$DVT_notifications", Manager.notifications)

		addHeaderOption("$DVT_Header_Sound")
		addToggleOptionSt("screamSoundsState", "$DVT_ScreamSounds", Manager.screamSounds)
		addSliderOptionSt("GurgleRateState", "$DVT_Gurgles", Manager.GurglesRate)
		addSliderOptionSt("BurpsRateState", "$DVT_Burps", Manager.BurpsRate)
		addSliderOptionSt("burpItemState", "$DVT_BurpItems", Manager.ItemBurping, "{2}")

		setCursorPosition(1)

		addHeaderOption("$DVT_Header_Other")
		addToggleOptionSt("voreDialogState", "$DVT_VoreDialog", VoreDialog.GetValue() != 0.0)
		addSliderOptionSt("LiveTimeState", "$DVT_LiveTime", Manager.liveMultiplier, "{2}x")
		addSliderOptionSt("DeadTimeState", "$DVT_DeadTime", Manager.DigestionTime, "{0} seconds")
		addSliderOptionSt("SwallowChanceState", "$DVT_MinSwallow", Manager.MinimumSwallowChance * 100.0, "{0}%")
		addSliderOptionSt("weightGainState", "$DVT_WeightGain", Manager.WeightGain, "{1}")
		addSliderOptionSt("NomsChanceState", "$DVT_NomsChance", Manager.NomsChance, "{3}")
		addMenuOptionSt("multiPreyState", "$DVT_MultiPrey", multiPreyList[Manager.multiprey])
		addMenuOptionSt("BYKState", "$DVT_PlayerDigested", BYKList[Manager.BYK])
		addToggleOptionSt("crouchScatState", "$DVT_crouchScat", Manager.crouchScat)
		addToggleOptionSt("shitItemsState", "$DVT_DefecateGear", Manager.ShitItems)
		addToggleOptionSt("stripItemsState", "$DVT_PreyStripping", Manager.stomachStrip)
		addToggleOptionSt("drawnAnimationState", "$DVT_DrawnAnimations", Manager.drawnAnimations)

	elseif page == Pages[3]
		setCursorFillMode(TOP_TO_BOTTOM)

		; Generate a list of prey.
		addHeaderOption("$DVT_PlayerStomachContents")
		
		if Manager.isPred(playerRef)
			Form[] stomach = Manager.getStomachArray(playerRef)
			if !Manager.EmptyStomach(stomach)
				int i = 0
				while i < stomach.length
					createDescriptor(stomach[i] as ObjectReference)
					i += 1
				endWhile
			endIf
		endIf

		setCursorPosition(1)
		
		; Display pred
		if Manager.IsPrey(playerRef)
			addHeaderOption("$DVT_PredStomachContents")
			Actor prey = playerRef
			while Manager.isPrey(prey)
				createDescriptor(prey)
				prey = Manager.getPred(Manager.getPreyData(prey))
			endWhile
		
		; Display target stomach contents.
		elseif target != none && target != playerRef
			addHeaderOption(targetName)
			Form[] stomach = Manager.getStomachArray(target)
			if !Manager.EmptyStomach(stomach)
				int i = 0
				while i < stomach.length
					createDescriptor(stomach[i] as ObjectReference)
					i += 1
				endWhile
			endIf
		endIf

	elseif page == Pages[4]
		setCursorFillMode(TOP_TO_BOTTOM)
		addHeaderOption("Perks")
		addTextOption("Devourment level: ", Manager.GetVoreLevel(playerRef))
		addTextOption("Devourment perk points: ", Manager.GetPerkPoints(playerRef))
		predSkillInfo = addTextOption("$DVT_PredSkillState", Manager.GetPredSkill(playerRef) as int)
		preySkillInfo = addTextOption("$DVT_PreySkillState", Manager.GetPreySkill(playerRef) as int)
		addEmptyOption()
		addToggleOptionSt("PredPerksState", "$DVT_ShowPredPerks", false)
		addToggleOptionSt("PreyPerksState", "$DVT_ShowPreyPerks", false)
		
	elseif page == Pages[5]
		setCursorFillMode(TOP_TO_BOTTOM)

		setCursorPosition(0)
		addMenuOptionSt("equipBellyState", "$DVT_EquipableBelly", equipList[Morphs.EquippableBellyType])
		addToggleOptionSt("UseLocusMorphsState", "$DVT_LocusMorphs", Morphs.UseLocationalMorphs)
		addSliderOptionSt("MorphSpeedState", "$DVT_MorphSpeed", Morphs.MorphSpeed, "{2}x")
		addToggleOptionSt("EliminationLocusState", "$DVT_UseEliminationLocus", Morphs.UseEliminationLocus)
		addToggleOptionSt("struggleSlidersState", "$DVT_StruggleSliders", Morphs.useStruggleSliders)

		if Morphs.UseStruggleSliders
			addSliderOptionSt("BumpAmplitudeState", "$DVT_BumpAmplitude", Morphs.struggleAmplitude, "{2}x")
		else
			addSliderOptionSt("BumpAmplitudeState", "$DVT_BumpAmplitude", Morphs.struggleAmplitude, "{2}x", OPTION_FLAG_DISABLED)
		endIf
		
		if !Morphs.UseLocationalMorphs
			setCursorPosition(1)
			addInputOptionSt("Slider_Locus0State", "$DVT_LocusSlider", Morphs.Locus_Sliders[0])
			addSliderOptionSt("Scaling_Locus0State", "$DVT_LocusScale", Morphs.Locus_Scales[0], "{2}")
			addEmptyOption()
			addSliderOptionSt("Scaling_Locus0_MaxState", "$DVT_LocusMaximum", Morphs.Locus_Maxes[0], "{2}")
	
		else
			AddHeaderOption("Locus 0 - Stomach")
			addInputOptionSt("Slider_Locus0State", "$DVT_LocusSlider", Morphs.Locus_Sliders[0])
			addSliderOptionSt("Scaling_Locus0State", "$DVT_LocusScale", Morphs.Locus_Scales[0], "{2}")
			addSliderOptionSt("Scaling_Locus0_MaxState", "$DVT_LocusMaximum", Morphs.Locus_Maxes[0], "{2}")
			addSliderOptionSt("Chance_Locus0", "$DVT_LocusChance", LocusChances[0], "{2}")

			AddHeaderOption("Locus 1 - Buttocks")
			addInputOptionSt("Slider_Locus1State", "$DVT_LocusSlider", Morphs.Locus_Sliders[1])
			addSliderOptionSt("Scaling_Locus1State", "$DVT_LocusScale", Morphs.Locus_Scales[1], "{2}")
			addSliderOptionSt("Scaling_Locus1_MaxState", "$DVT_LocusMaximum", Morphs.Locus_Maxes[1], "{2}")
			addSliderOptionSt("Chance_Locus1", "$DVT_LocusChance", LocusChances[1], "{2}")

			AddHeaderOption("Locus 2 - Uterus")
			addInputOptionSt("Slider_Locus2State", "$DVT_LocusSlider", Morphs.Locus_Sliders[2], OPTION_FLAG_DISABLED)
			addSliderOptionSt("Scaling_Locus2State", "$DVT_LocusScale", Morphs.Locus_Scales[2], "{2}", OPTION_FLAG_DISABLED)
			addSliderOptionSt("Scaling_Locus2_MaxState", "$DVT_LocusMaximum", Morphs.Locus_Maxes[2], "{2}", OPTION_FLAG_DISABLED)
			addSliderOptionSt("Chance_Locus2", "$DVT_LocusChance", LocusChances[2], "{2}")

			setCursorPosition(1)

			addToggleOptionSt("DualBreastModeState", "$DVT_UseDualBreastMode", Morphs.UseDualBreastMode)

			if Morphs.UseDualBreastMode
				AddHeaderOption("Locus 3 - Breasts (left)")
			else
				AddHeaderOption("Locus 3 - Breasts")
			endIf
			addInputOptionSt("Slider_Locus3State", "$DVT_LocusSlider", Morphs.Locus_Sliders[3])
			addSliderOptionSt("Scaling_Locus3State", "$DVT_LocusScale", Morphs.Locus_Scales[3], "{2}")
			addSliderOptionSt("Scaling_Locus3_MaxState", "$DVT_LocusMaximum", Morphs.Locus_Maxes[3], "{2}")
			addSliderOptionSt("Chance_Locus3", "$DVT_LocusChance", LocusChances[3], "{2}")

			if Morphs.UseDualBreastMode
				AddHeaderOption("Locus 4 - Breasts (right)")
				addInputOptionSt("Slider_Locus4State", "$DVT_LocusSlider", Morphs.Locus_Sliders[4])
				addSliderOptionSt("Scaling_Locus4State", "$DVT_LocusScale", Morphs.Locus_Scales[4], "{2}")
				addSliderOptionSt("Scaling_Locus4_MaxState", "$DVT_LocusMaximum", Morphs.Locus_Maxes[4], "{2}")
				addSliderOptionSt("Chance_Locus4", "$DVT_LocusChance", LocusChances[4], "{2}")
			endIf

			if !Manager.VEGAN_MODE
				AddHeaderOption("Locus 5 - Scrotum")
				addInputOptionSt("Slider_Locus5State", "$DVT_LocusSlider", Morphs.Locus_Sliders[5])
				addSliderOptionSt("Scaling_Locus5State", "$DVT_LocusScale", Morphs.Locus_Scales[5], "{2}")
				addSliderOptionSt("Scaling_Locus5_MaxState", "$DVT_LocusMaximum", Morphs.Locus_Maxes[5], "{2}")
				addSliderOptionSt("Chance_Locus5", "$DVT_LocusChance", LocusChances[5], "{2}")
			endIf
		endIf

	elseif page == Pages[6]
		setCursorFillMode(TOP_TO_BOTTOM)
		AddToggleOptionSt("WeightPlayerState", "Player Weight Morphs", WeightManager.PlayerEnabled)
		AddToggleOptionSt("WeightCompanionState", "Follower Weight Morphs", WeightManager.CompanionsEnabled)
		AddToggleOptionSt("WeightEveryoneState", "'Everyone Else' Morphs", WeightManager.ActorsEnabled)
		AddSliderOptionSt("WeightLossState", "Weight Loss", WeightManager.WeightLoss, "{2}")
		AddSliderOptionSt("WeightRateState", "Weight Rate", WeightManager.WeightRate, "{2}")
		AddSliderOptionSt("WeightMinState", "Minimum Weight", WeightManager.MinimumWeight, "{2}")
		AddSliderOptionSt("WeightMaxState", "Maximum Weight", WeightManager.MaximumWeight, "{2}")
		AddSliderOptionSt("WeightVoreBaseState", "Vore Base Gain", WeightManager.VoreBaseGain, "{3}")
		AddSliderOptionSt("WeightIngredientBaseState", "Ingredient Base Gain", WeightManager.IngredientBaseGain, "{3}")
		AddSliderOptionSt("WeightPotionBaseState", "Potion Base Gain", WeightManager.PotionBaseGain, "{3}")
		AddSliderOptionSt("WeightFoodBaseState", "Food Base Gain", WeightManager.FoodBaseGain, "{3}")
		AddSliderOptionSt("WeightHighValMultState", "High Value Multiplier", WeightManager.HighValueMultiplier, "{3}")

		AddSliderOptionSt("WeightPreviewState", "Weight Preview", 0.0, "{2}")
		AddToggleOptionSt("WeightLearnHighValueState", "Flag High Value", WeightManager.GetState() == "LearnHighValue")
		AddToggleOptionSt("WeightLearnNoValueState", "Flag No Value", WeightManager.GetState() == "LearnNoValue")

		AddHeaderOption("Morphs")
		addInputOptionSt("WeightAddMorphState", "Add Morph", "")

		String[] MorphStrings = WeightManager.MorphStrings
		float[] MultLow = WeightManager.MorphsLow
		float[] MultHigh = WeightManager.MorphsHigh

		int cutoff = MorphStrings.length / 2 - 2
		
		int index = 0
		while index < MorphStrings.length && MorphStrings[index] != ""
			if index == cutoff
				setCursorPosition(1)
				AddHeaderOption("Morphs")
			endIf

			int[] quad = new int[4]
			quad[0] = index
			quad[1] = AddInputOption("Morph", MorphStrings[index])
			quad[2] = AddInputOption("Low", MultLow[index])
			quad[3] = AddInputOption("High", MultHigh[index])
			AddEmptyOption()

			int oQuad = JArray.objectWithInts(quad)
			JIntMap.SetObj(optionsMap, quad[1], oQuad)
			JIntMap.SetObj(optionsMap, quad[2], oQuad)
			JIntMap.SetObj(optionsMap, quad[3], oQuad)

			index += 1
		endWhile

	elseif page == Pages[7]
		setCursorFillMode(TOP_TO_BOTTOM)

		if target
			addHeaderOption(Namer(target, true))
		else
			addHeaderOption("$DVT_NoTarget")
		endIf

		addToggleOptionSt("autoPredState", "$DVT_AutoPred", Manager.IsVorish(target), targetFlags)
		addTextOptionSt("forceVomitState", "$DVT_forceVomit", vomitActivated, targetFlags)

		addHeaderOption("$DVT_DebugSettings")
		addToggleOptionSt("saveSettingsState", "$DVT_SaveSettings", false, 0)
		addToggleOptionSt("loadSettingsState", "$DVT_LoadSettings", false, 0)

		addHeaderOption("$DVT_DebugFix")
		addToggleOptionSt("DebugDumpState", "$DVT_ExportDatabase", false)
		addToggleOptionSt("softDeathState", "$DVT_SoftDeath", Manager.SoftDeath)
		addToggleOptionSt("DontAddPowersState", "$DVT_DontAddPowers", DontAddPowers)
		addToggleOptionSt("AltPerkMenuState", "$DVT_AltPerkMenu", AltPerkMenus)
		addToggleOptionSt("PerformanceState", "$DVT_PerformanceMode", Manager.PERFORMANCE)
		addToggleOptionSt("DebugState", "$DVT_DebuggingMode", Manager.DEBUGGING)

		if Manager.DEBUGGING
			addHeaderOption("$DVT_DebugTools")
			addToggleOptionSt("UnrestrictedItemState", "$DVT_Unrestricted", false)
			addToggleOptionSt("maxSkillState", "$DVT_MaxSkill", false)
			addToggleOptionSt("maxPerksState", "$DVT_MaxPerks", false)
			addToggleOptionSt("FlushVomitQueue", "$DVT_FlushVomitQueue", flushActivated)
			addInputOptionSt("resetPreyState", "$DVT_resetPrey", Namer(resetPrey))
			addToggleOptionSt("ResetVisuals", "$DVT_ResetVisuals", false)
			addToggleOptionSt("ResetState", "$DVT_ResetDevourment", false)
		endif

		setCursorPosition(1)

		addHeaderOption("$DVT_Shortcuts")
		AddKeyMapOptionST("VoreKeyState", "$DVT_VoreKey", PlayerAlias.VORE_KEY)
		AddKeyMapOptionST("EndoKeyState", "$DVT_EndoKey", PlayerAlias.ENDO_KEY)
		AddKeyMapOptionST("CombKeyState", "$DVT_CombKey", PlayerAlias.COMB_KEY)
		AddKeyMapOptionST("DialogKeyState", "$DVT_dialogKey", PlayerAlias.DIALOG_KEY)
		AddKeyMapOptionST("QuickSettingsKeyState", "$DVT_DevourmentKey", PlayerAlias.QUICK_KEY)
		AddKeyMapOptionST("compelVoreKeyState", "$DVT_compelVoreKey", PlayerAlias.COMPEL_KEY)
		AddKeyMapOptionST("ForgetKeyState", "$DVT_ForgetKey", PlayerAlias.FORGET_KEY)

		addHeaderOption("")
		addToggleOptionSt("DisableDependencyState", "$DVT_DisableDependencyChecks", DisableDependencyChecks)

		if SKSE.GetVersion()
			addTextOption("SKSE", SKSE.GetVersion() + "." + SKSE.GetVersionMinor())
		else
			addTextOption("SKSE", "MISSING")
		endIf
		
		if MiscUtil.FileExists("Data/DLLPlugins/NetScriptFramework.Runtime.dll") && MiscUtil.FileExists("Data/NetScriptFramework/NetScriptFramework.log.txt")
			String NetscriptLog = MiscUtil.ReadFromFile("Data/NetScriptFramework/NetScriptFramework.log.txt")
			AddLogVersion("NetScriptFramework", NetscriptLog, " Initializing framework version %d+", "%d+")
			AddLogCheck("CustomSkillFramework", NetscriptLog, "CustomSkills.dll")
		else
			addTextOption("NetScriptFramework", "MISSING")
			addTextOption("CustomSkillFramework", "MISSING")
		endIf

		
		AddSKSEDetails("SSEEngineFixes", "EngineFixes plugin", "EngineFixes plugin")
		AddSKSEDetails("JContainers", "JContainers", "JContainers64", JContainers.FeatureVersion(), JContainers.APIVersion())
		AddSKSEDetails("PapyrusUtil", "papyrusutil plugin", "papyrusutil", PapyrusUtil.GetVersion(), PapyrusUtil.GetScriptVersion())
		AddSKSEDetails("ConsoleUtil", "console plugin", "ConsoleUtilSSE", ConsoleUtil.GetVersion())
		AddSKSEDetails("PO3 Papyrus Extender", "PapyrusExtender", "powerofthree's Papyrus Extender")
		AddSKSEDetails("NIOverride", "NIOverride", "skee", NIOverride.GetScriptVersion())
		AddQuestDetails("RaceMenu", "RaceMenu", RaceMenuBase.GetScriptVersionRelease())
		AddQuestDetails("XPMSE", "XPMSEMCM", XPMSELib.GetXPMSELibVersion() as String)

	endif
endEvent


Function AddLogVersion(String label, String log, String linePattern, String subPattern)
	int data = JLua.setStr("log", log, JLua.SetStr("p1", linePattern, JLua.SetStr("p2", subPattern)))
	String result = JLua.evalLuaStr("return args.log:match(args.p1):match(args.p2)", data)
	
	if result != "" 
		addTextOption(label, result)
	else
		addTextOption(label, "MISSING")
	endIf
EndFunction


Function AddLogCheck(String label, String log, String linePattern)
	int data = JLua.setStr("log", log, JLua.SetStr("p1", linePattern))
	String result = JLua.evalLuaStr("return args.log:match(args.p1)", data)
	
	if result != "" 
		addTextOption(label, "Found")
	else
		addTextOption(label, "MISSING")
	endIf
EndFunction


Function AddQuestDetails(String label, String name, String v1)
	if Quest.getQuest(name)
		addTextOption(label, v1)
	else
		addTextOption(label, "MISSING")
	endIf
EndFunction


Function AddSKSEDetails(String label, String pluginLE, String pluginSE, String v1 = "", String v2 = "")
	int skseVersion = 0
	
	if SKSE.GetPluginVersion(pluginSE) >= 0
		skseVersion = SKSE.GetPluginVersion(pluginSE)
	elseif SKSE.GetPluginVersion(pluginLE) >= 0
		skseVersion = SKSE.GetPluginVersion(pluginLE)
	else
		addTextOption(label, "MISSING")
		return
	endIf
	
	if v1 != "" && v2 != ""
		addTextOption(label, skseVersion + " (" + v1 + ", " + v2 + ")")
	elseif v1 != ""
		addTextOption(label, skseVersion + " (" + v1 + ")")
	else
		addTextOption(label, skseVersion)
	endIf
EndFunction


String Function createMorphText(int index, bool selected)
	float multLow = WeightManager.MorphsLow[index]
	float multHigh = WeightManager.MorphsHigh[index]

	if selected
		return "<font color='#EDDC7E'>" + "High = " + multHigh + ", Low = " + multLow
	else
		return "High = " + multHigh + ", Low = " + multLow
	endIf
EndFunction


String Function createHighlightText(ObjectReference target)
{ Creates a text description of a target for the prey list. }
	int preyData = Manager.getPreyData(target)
	int locus = Manager.GetLocus(preyData)
	Actor pred = Manager.getPred(preyData)
	Actor prey = target as Actor
	String[] lines = new String[4]
	
	if pred == playerRef && prey
		int predSkill = Manager.getPredSkill(prey) as int
		int preySkill = Manager.getPreySkill(prey) as int
		int size = Manager.GetVoreWeight(prey) as int
		int level = prey.getLevel()
		ArrayAddString(lines, Namer(target) + ": level " + level + ", pred skill " + predSkill + ", prey skill " + preySkill + ", size " + size)
		
	elseif target == playerRef
		int predSkill = Manager.getPredSkill(pred) as int
		int preySkill = Manager.getPreySkill(pred) as int
		int size = Manager.GetVoreWeight(pred) as int
		int level = pred.getLevel()
		ArrayAddString(lines, Namer(target) + ": level " + level + ", pred skill " + predSkill + ", prey skill " + preySkill + ", size " + size)
	endif

	if prey
		int timer = Manager.getTimer(preyData) as int
		
		if Manager.isDigesting(preyData)
			if Manager.isReforming(preyData)
				ArrayAddString(lines, "Reforming (" + Manager.GetDigestionPercent(preyData) as int + "% complete) (" + GetLocusName(locus) + ")")
			else
				ArrayAddString(lines, timer + " seconds until fully digested (" + Manager.getDigestionProgress(preyData) as int + "% complete) (" + GetLocusName(locus) + ")")
			endIf
		
		elseif Manager.IsVore(preyData)
			int dps = Manager.getDPS(preyData) as int
			int hp = (target as Actor).getActorValue("health") as int
			int hpMax = (target as Actor).getBaseActorValue("health") as int
			String health = hp + "/" + hpMax + " health"

			if Manager.isNoEscape(preyData) || Manager.noEscape
				ArrayAddString(lines, health + " health, " + dps + " acid damage/s, no escape (" + GetLocusName(locus) + ")")
			else
				ArrayAddString(lines, health + " health, " + dps + " acid damage/s, escape in " + timer + " seconds (" + GetLocusName(locus) + ")")
			endif
		endIf

	elseif target as DevourmentBolus
		DevourmentBolus bolus = target as DevourmentBolus
		ArrayAddString(lines, "Equipment weighing " + bolus.getWeight() as int + " units and worth " + bolus.getGoldValue() + " septims (" + GetLocusName(locus) + ")")

	else
		ArrayAddString(lines, "Item weighing " + target.getWeight() as int + " units (" + GetLocusName(locus) + ")")

	endIf

	if lines[0] == ""
		return ""
	endIf
	
	String highlight = lines[0]
	
	int i = 1
	while i < lines.length && lines[i] != ""
		highlight += "\n" + lines[i]
		i += 1
	endWhile
	
	return highlight
endFunction


String Function createDescriptorText(ObjectReference prey)
	int preyData = Manager.getPreyData(prey)
	int locus = Manager.GetLocus(preyData)
	String desc

	if Manager.isVomit(preyData)
		desc = "(vomiting)"
	elseif prey as Actor 
		if Manager.isReforming(preyData)
			desc = Manager.GetDigestionPercent(preyData) as int + "% reformed"
		elseif Manager.isDigesting(preyData)
			desc = Manager.getDigestionProgress(preyData) as int + "% digested"
		elseif Manager.isDigested(preyData)
			desc = "Fully digested"
		elseif Manager.isEndo(preyData)
			desc = "(nonlethal)"
		else
			int hp = (prey as Actor).getActorValue("health") as int
			int hpMax = (prey as Actor).getBaseActorValue("health") as int
			String health = hp + "/" + hpMax + " health"
			desc = health
		endIf
	else
		desc = "Bolus: " + Manager.GetDigestionProgress(preyData) as int + "% passed"
	endif
	
	return desc
EndFunction


Function createDescriptor(ObjectReference prey)
{ Creates a text description of a prey for the prey list. }
	int oid = addTextOption(createDescriptorText(prey), Namer(prey, true))
	JIntMap.SetForm(optionsMap, oid, prey)
endFunction


event OnOptionSelect(int oid)
	if !JIntMap.HasKey(optionsMap, oid)
		AssertTrue(PREFIX, "OnOptionSelect", "JIntMap.HasKey(optionsMap, oid)", JIntMap.HasKey(optionsMap, oid))
		return
	endIf

	int valueType = JIntMap.valueType(optionsMap, oid)

	if valueType == 4
		Form f = JIntMap.GetForm(optionsMap, oid)

		if f as ObjectReference
			int preyData = Manager.GetPreyData(f as ObjectReference)
			if JValue.isExists(preyData)
				ObjectReference content = Manager.GetContent(preyData)
				
				if Input.IsKeyPressed(56) ; ALT key
					ConsoleUtil.PrintMessage(LuaS("preyData", preyData))
					
				elseif content as ObjectReference
					ObjectReference bolus = content as ObjectReference
					Form[] bolusContents = bolus.GetContainerForms()
					
					if bolusContents == none
						ShowMessage("NONE")

					elseif bolusContents.length == 0
						ShowMessage("(EMPTY)")

					elseif bolusContents.length > 0
						String description

						int count = bolus.GetItemCount(bolusContents[0])
						description = NameWithCount(bolusContents[0], count)
					
						int bolusIndex = 1
						while bolusIndex < bolusContents.length
							count = bolus.GetItemCount(bolusContents[bolusIndex])
							description = description + "\n" + NameWithCount(bolusContents[bolusIndex], count)
							bolusIndex += 1
						endWhile
						
						ShowMessage(description)
					endIf
					
				endIf
			endIf
		endif
	endIf
endEvent


event OnOptionHighlight(int oid)
	{Used exclusively for dynamic lists.}

	if oid == predSkillInfo
		Actor target = GetTarget()
		int experience = Manager.GetPredXP(target) as int
		int skill = Manager.GetPredSkill(target) as int
		int needed = (skill*skill - experience) as int

		if needed > 0
			if target != playerRef
				String targetName = Namer(target, true)
				SetInfoText(needed + " more experience needed before " + targetName + "'s pred skill increases (" + experience + " / " + (skill*skill) + ")")
			else
				SetInfoText(needed + " more experience needed before your pred skill increases (" + experience + " / " + (skill*skill) + ")")
			endIf
		endIf

	elseif oid == preySkillInfo 
		Actor target = GetTarget()
		int experience = Manager.GetPreyXP(target) as int
		int skill = Manager.GetPreySkill(target) as int
		int needed = (skill*skill - experience) as int

		if needed > 0
			if target != playerRef
				String targetName = Namer(target, true)
				SetInfoText(needed + " more experience needed before " + targetName + "'s prey skill increases (" + experience + " / " + (skill*skill) + ")")
			else
				SetInfoText(needed + " more experience needed before your prey skill increases (" + experience + " / " + (skill*skill) + ")")
			endIf
		endIf
	
	elseif JIntMap.HasKey(optionsMap, oid)
		int valueType = JIntMap.valueType(optionsMap, oid)
		if valueType == 5
			SetInfoText("The morph's name, high weight value, and low weight value.\nDelete a morph's name to remove it.")

		elseif valueType == 4
			Form f = JIntMap.GetForm(optionsMap, oid)
			if f as ObjectReference
				SetInfoText(createHighlightText(f as ObjectReference))
			endIf
		endif
	endIf
endEvent


event OnOptionInputOpen(int oid)
	{Used exclusively for dynamic lists.}
	if !AssertTrue(PREFIX, "OnOptionInputOpen", "JIntMap.HasKey(optionsMap, oid)", JIntMap.HasKey(optionsMap, oid))
		return
	endIf

	String[] MorphStrings = WeightManager.MorphStrings
	float[] MultLow = WeightManager.MorphsLow
	float[] MultHigh = WeightManager.MorphsHigh

	; Get the quad.
	int oq = JIntMap.GetObj(optionsMap, oid)
	if !AssertExists(PREFIX, "OnOptionInputOpen", "oq", oq)
		return
	endIf

	int[] quad = JArray.asIntArray(oq)
	int index = quad[0]
	String morph = MorphStrings[index]

	if oid == quad[1]
		SetInputDialogStartText(MorphStrings[index])
	elseif oid == quad[2]
		SetInputDialogStartText(MultLow[index])
	elseif oid == quad[3]
		SetInputDialogStartText(MultHigh[index])
	endIf
endEvent


event OnOptionInputAccept(int oid, string a_input)
	if !AssertTrue(PREFIX, "OnOptionInputAccept", "JIntMap.hasKey(optionsMap, oid)", JIntMap.hasKey(optionsMap, oid))
		return
	endIf

	String[] MorphStrings = WeightManager.MorphStrings
	float[] MultLow = WeightManager.MorphsLow
	float[] MultHigh = WeightManager.MorphsHigh

	; Get the quad.
	int oq = JIntMap.GetObj(optionsMap, oid)
	if !AssertExists(PREFIX, "OnOptionInputAccept", "oq", oq)
		return
	endIf

	int[] quad = JArray.asIntArray(oq)
	int index = quad[0]
	String morph = MorphStrings[index]

	if oid == quad[1]
		if a_input == ""
			WeightManager.RemoveMorph(MorphStrings[index])
			ForcePageReset()
		else
			MorphStrings[index] = a_input
			SetInputOptionValue(oid, a_input)
		endIf

	elseif oid == quad[2]
		float val = a_input as float
		MultLow[index] = val
		SetInputOptionValue(oid, val)
	
	elseif oid == quad[3]
		float val = a_input as float
		MultHigh[index] = val
		SetInputOptionValue(oid, val)
	endIf
	WeightManager.SyncSettings(true)
	resetActorWeights = true
endEvent


state StruggleDifficultyState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.StruggleDifficulty)
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(1.0, 20.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.StruggleDifficulty = a_value
		SetSliderOptionValueST(a_value, "{1}x")
	endEvent

	event OnDefaultST()
		Manager.StruggleDifficulty = 10.0
		SetSliderOptionValueST(Manager.StruggleDifficulty, "{1}x")
	endEvent

	event OnHighlightST()
		SetInfoText("The difficulty of struggling free, for both the player and for NPCs and creatures. This is the percentage of the strugglebar that is filled each time the player or an NPC struggles successfully.")
	endEvent
endState


state StruggleDamageState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.StruggleDamage)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.StruggleDamage = a_value
		SetSliderOptionValueST(a_value, "{1}x")
		adjustPreyData = true
	endEvent

	event OnDefaultST()
		Manager.StruggleDamage = 1.0
		SetSliderOptionValueST(Manager.StruggleDamage, "{1}x")
		adjustPreyData = true
	endEvent

	event OnHighlightST()
		SetInfoText("Scales the damage dealt by prey struggling, for both the player and for NPCs and creatures.")
	endEvent
endState


state LiveTimeState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.liveMultiplier)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 10.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.liveMultiplier = a_value
		SetSliderOptionValueST(a_value, "{2}x")
		adjustPreyData = true
	endEvent

	event OnDefaultST()
		Manager.liveMultiplier = 1.0
		SetSliderOptionValueST(1.0, "{2}x")
		adjustPreyData = true
	endEvent

	event OnHighlightST()
		SetInfoText("Live digestion speed multiplier. Digestion damage will be adjusted inversely for balance reasons.")
	endEvent
endState


state DeadTimeState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.DigestionTime)
		SetSliderDialogDefaultValue(Manager.DigestionTime)
		SetSliderDialogRange(30.0, 86400.0)
		SetSliderDialogInterval(30.0)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.DigestionTime = a_value
		SetSliderOptionValueST(a_value, "{0} seconds")
		adjustPreyData = true
	endEvent

	event OnDefaultST()
		Manager.DigestionTime = 240.0
		SetSliderOptionValueST(Manager.DigestionTime, "{0} seconds")
		adjustPreyData = true
	endEvent

	event OnHighlightST()
		SetInfoText("Dead prey will take this long to digest.")
	endEvent
endState


state PredExperienceRateState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.PredExperienceRate)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 20.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.PredExperienceRate = a_value
		SetSliderOptionValueST(Manager.PredExperienceRate, "{1}x")
	endEvent

	event OnDefaultST()
		Manager.PredExperienceRate = 1.0
		SetSliderOptionValueST(Manager.PredExperienceRate, "{1}x")
	endEvent

	event OnHighlightST()
		SetInfoText("Adjusts how fast predators and prey gain vore perks and points in the vore skill.")
	endEvent
endState


state PreyExperienceRateState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.PreyExperienceRate)
		SetSliderDialogDefaultValue(2.0)
		SetSliderDialogRange(0.2, 40.0)
		SetSliderDialogInterval(0.2)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.PreyExperienceRate = a_value
		SetSliderOptionValueST(Manager.PreyExperienceRate, "{1}x")
	endEvent

	event OnDefaultST()
		Manager.PreyExperienceRate = 2.0
		SetSliderOptionValueST(Manager.PreyExperienceRate, "{1}x")
	endEvent

	event OnHighlightST()
		SetInfoText("Adjusts how fast predators and prey gain vore perks and points in the vore skill.")
	endEvent
endState


state SwallowChanceState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.MinimumSwallowChance * 100.0)
		SetSliderDialogDefaultValue(5.0)
		SetSliderDialogRange(1.0, 100.0)
		SetSliderDialogInterval(1.0)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.MinimumSwallowChance = a_value / 100.0
		SetSliderOptionValueST(a_value, "{0}%")
	endEvent

	event OnDefaultST()
		Manager.MinimumSwallowChance = 0.05
		SetSliderOptionValueST(5.0, "{0}%")
	endEvent

	event OnHighlightST()
		SetInfoText("All predators have at least this chance of swallowing anyone.")
	endEvent
endState


state weightGainState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.WeightGain)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(0.0, 20.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.WeightGain = a_value
		SetSliderOptionValueST(Manager.WeightGain, "{1}")
	endEvent

	event OnDefaultST()
		Manager.WeightGain = 0.0
		SetSliderOptionValueST(Manager.WeightGain, "{1}")
	endEvent

	event OnHighlightST()
		SetInfoText("Amount by which to adjust a predator's weight slider when they finish digesting live prey.")
	endEvent
endState


state NomsChanceState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.NomsChance)
		SetSliderDialogDefaultValue(0.03)
		SetSliderDialogRange(0.0, 1.0)
		SetSliderDialogInterval(0.005)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.NomsChance = a_value
		SetSliderOptionValueST(Manager.NomsChance, "{3}")
	endEvent

	event OnDefaultST()
		Manager.NomsChance = 0.03
		SetSliderOptionValueST(Manager.NomsChance, "{3}")
	endEvent

	event OnHighlightST()
		SetInfoText("The probability of random noms.")
	endEvent
endState


state NPCBonusState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.NPCBonus)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 10.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.NPCBonus = a_value
		SetSliderOptionValueST(a_value, "{1}x")
	endEvent

	event OnDefaultST()
		Manager.NPCBonus = 1.0
		SetSliderOptionValueST(1.0, "{1}x")
	endEvent

	event OnHighlightST()
		SetInfoText("Multiplier for NPCs' swallow chance. This applies to followers as well.")
	endEvent
endState


state GurgleRateState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.GurglesRate)
		SetSliderDialogDefaultValue(8.0)
		SetSliderDialogRange(0.0, 60.0)
		SetSliderDialogInterval(0.5)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.GurglesRate = a_value
		SetSliderOptionValueST(Manager.GurglesRate, "{1}")
	endEvent

	event OnDefaultST()
		Manager.GurglesRate = 8.0
		SetSliderOptionValueST(Manager.GurglesRate, "{1}")
	endEvent

	event OnHighlightST()
		SetInfoText("The average interval between stomach gurgles during digestion for one prey. More prey will result in more gurgling.")
	endEvent
endstate


state BurpsRateState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.BurpsRate)
		SetSliderDialogDefaultValue(16.0)
		SetSliderDialogRange(0.0, 60.0)
		SetSliderDialogInterval(0.5)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.BurpsRate = a_value
		SetSliderOptionValueST(Manager.BurpsRate, "{1}")
	endEvent

	event OnDefaultST()
		Manager.BurpsRate = 16.0
		SetSliderOptionValueST(Manager.BurpsRate, "{1}")
	endEvent

	event OnHighlightST()
		SetInfoText("The average interval between burps during digestion.")
	endEvent
endstate


state burpItemState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.ItemBurping)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(0.0, 1.0)
		SetSliderDialogInterval(0.05)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.ItemBurping = a_value
		SetSliderOptionValueST(Manager.ItemBurping, "{2}")
	endEvent

	event OnDefaultST()
		Manager.ItemBurping = 0.0
		SetSliderOptionValueST(Manager.ItemBurping, "{2}")
	endEvent

	event OnHighlightST()
		SetInfoText("The base probability of burping up a small item when you use the Burp power. The actual probability is affected by what's in your stomach.")
	endEvent
endstate


state prefilledState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.PreFilledChance)
		SetSliderDialogDefaultValue(0.05)
		SetSliderDialogRange(0.0, 1.0)
		SetSliderDialogInterval(0.01)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.PreFilledChance = a_value
		SetSliderOptionValueST(Manager.PreFilledChance, "{2}")
	endEvent

	event OnDefaultST()
		Manager.PreFilledChance = 0.05
		SetSliderOptionValueST(Manager.PreFilledChance, "{2}")
	endEvent

	event OnHighlightST()
		SetInfoText("Likelihood of a predatory NPC being initialized with prey already in their stomach. For performance reasons this is purely cosmetic.")
	endEvent
endstate


state cameraShakeState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.cameraShake)
		SetSliderDialogDefaultValue(0.1)
		SetSliderDialogRange(0.0, 1.0)
		SetSliderDialogInterval(0.02)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.cameraShake = a_value
		SetSliderOptionValueST(Manager.cameraShake, "{2}")
	endEvent

	event OnDefaultST()
		Manager.cameraShake = 0.1
		SetSliderOptionValueST(Manager.cameraShake, "{2}")
	endEvent

	event OnHighlightST()
		SetInfoText("Amount of camera shake (and controller vibration) during struggling when the player is the predator or the prey. At 0.0 it will be completely disabled.")
	endEvent
endstate


state DamageModState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Manager.AcidDamageModifier)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.0, 20.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		Manager.AcidDamageModifier = a_value
		SetSliderOptionValueST(a_value, "{1}x")
		adjustPreyData = true
	endEvent

	event OnDefaultST()
		Manager.AcidDamageModifier = 1.0
		SetSliderOptionValueST(1.0, "{1}x")
		adjustPreyData = true
	endEvent

	event OnHighlightST()
		SetInfoText("Digestion acid damage is multiplied by this value.")
	endEvent
endState


state StruggleMenuState
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Manager.whoStruggles)
		SetMenuDialogDefaultIndex(2)
		SetMenuDialogOptions(StruggleList)
	endEvent

	event OnMenuAcceptST(int index)
		Manager.whoStruggles = index
		SetMenuOptionValueST(StruggleList[index])
	endEvent

	event OnDefaultST()
		Manager.whoStruggles = 2
		SetMenuOptionValueST(StruggleList[2])
	endEvent

	event OnHighlightST()
		if Manager.whoStruggles == 0
			SetInfoText("Struggle system disabled.")
		elseif Manager.whoStruggles == 1
			SetInfoText("Struggle system enabled for the player.")
		elseif Manager.whoStruggles == 2
			SetInfoText("Struggle system enabled for everyone.")
		else
			SetInfoText("Control the struggle system.")
		endif
	endEvent
endstate


state AutoNomsState
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Manager.AutoNoms)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(NomsList)
	endEvent

	event OnMenuAcceptST(int index)
		Manager.AutoNoms = index
		SetMenuOptionValueST(NomsList[index])
	endEvent

	event OnDefaultST()
		Manager.AutoNoms = 0
		SetMenuOptionValueST(NomsList[0])
	endEvent

	event OnHighlightST()
		if Manager.AutoNoms == 0
			SetInfoText("The only random noms will be by followers who have been specifically requested to.")
		elseif Manager.AutoNoms == 1
			SetInfoText("Any predator can random nom the player and their followers.\nThis can cause a few problems.")
		elseif Manager.AutoNoms == 2
			SetInfoText("Any predator can random nom anyone except the player and their followers.\nThis can cause a LOT of problems. Not recommended, but still super fun.")
		else
			SetInfoText("Any predator can random nom anyone.\nThis can cause a LOT of problems. Not recommended, but still super fun.")
		endif
	endEvent
endstate



state PredPerksState
	event OnDefaultST()
		showPerks = 0
		setToggleOptionValueST(false)
		SetToggleOptionValueST(false, false, "PreyPerksState")
	endEvent

	event OnSelectST()
		if showPerks != 1
			showPerks = 1
			setToggleOptionValueST(true)
			SetToggleOptionValueST(false, false, "PreyPerksState")
		else
			showPerks = 0
			setToggleOptionValueST(false)
		endIf
	endEvent

	event OnHighlightST()
		SetInfoText("If selected, then the Predator perk tree will be displayed once the MCM is closed.")
	endEvent
endstate


state PreyPerksState
	event OnDefaultST()
		showPerks = 0
		setToggleOptionValueST(false)
		SetToggleOptionValueST(false, false, "PredPerksState")
	endEvent

	event OnSelectST()
		if showPerks != 2
			showPerks = 2
			setToggleOptionValueST(true)
			SetToggleOptionValueST(false, false, "PredPerksState")
		else
			showPerks = 0
			setToggleOptionValueST(false)
		endIf
	endEvent

	event OnHighlightST()
		SetInfoText("If selected, then the Prey perk tree will be displayed once the MCM is closed.")
	endEvent
endstate


state DigestNPCState
	event OnDefaultST()
		Manager.killNPCs = true
		setToggleOptionValueST(Manager.killNPCs)
	endEvent

	event OnSelectST()
		Manager.killNPCs = !Manager.killNPCs
		setToggleOptionValueST(Manager.killNPCs)
	endEvent

	event OnHighlightST()
		SetInfoText("Enables lethal digestion of non-essential NPCs. If this is enabled, NPCs can be digested to death. Disabling it does not guarantee that they will survive though, if they are taking damage from other sources. But remember, the player can always digest anyone.")
	endEvent
endstate


state DigestEssentialState
	event OnDefaultST()
		Manager.killEssential = false
		setToggleOptionValueST(Manager.killEssential)
	endEvent

	event OnSelectST()
		Manager.killEssential = !Manager.killEssential
		setToggleOptionValueST(Manager.killEssential)
	endEvent

	event OnHighlightST()
		SetInfoText("Enables lethal digestion of essential NPCs. If this is enabled, essential NPCs can be digested to death. This will break a lot of quests! Not recommended. Disabling it does not guarantee that they will survive, if they are taking damage from other sources. But remember, the player can always digest anyone.")
	endEvent
endstate


state malePredToggleState
	event OnDefaultST()
		Manager.malePreds = true
		setToggleOptionValueST(Manager.malePreds)
	endEvent

	event OnSelectST()
		Manager.malePreds = !Manager.malePreds
		setToggleOptionValueST(Manager.malePreds)
	endEvent

	event OnHighlightST()
		SetInfoText("Enables combat vore for male NPCs. They still need to be included in Devourment_DISTR.ini.")
	endEvent
endstate


state femalePredToggleState
	event OnDefaultST()
		Manager.femalePreds = true
		setToggleOptionValueST(Manager.femalePreds)
	endEvent

	event OnSelectST()
		Manager.femalePreds = !Manager.femalePreds
		setToggleOptionValueST(Manager.femalePreds)
	endEvent

	event OnHighlightST()
		SetInfoText("Enables combat vore for female NPCs. They still need to be included in Devourment_DISTR.ini.")
	endEvent
endstate


state creaturePredToggleState
	event OnDefaultST()
		Manager.creaturePreds = true
		setToggleOptionValueST(Manager.creaturePreds)
	endEvent

	event OnSelectST()
		Manager.creaturePreds = !Manager.creaturePreds
		setToggleOptionValueST(Manager.creaturePreds)
	endEvent

	event OnHighlightST()
		SetInfoText("Enables combat vore for animals, monsters, and other creatures. They still need to be included in Devourment_DISTR.ini.")
	endEvent
endstate


state playerCentricState
	event OnDefaultST()
		Manager.playerCentric = false
		setToggleOptionValueST(Manager.playerCentric)
		SetOptionFlagsST(OPTION_FLAG_NONE, false, "playerAvoidantState")
	endEvent

	event OnSelectST()
		Manager.playerCentric = !Manager.playerCentric
		setToggleOptionValueST(Manager.playerCentric)

		if Manager.playerCentric
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "playerAvoidantState")
		else
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "playerAvoidantState")
		endif
	endEvent

	event OnHighlightST()
		SetInfoText("The player will be the only valid target for combat vore and random noms by NPCs and creatures.")
	endEvent
endstate

state playerAvoidantState
	event OnDefaultST()
		Manager.PlayerAvoidant = false
		setToggleOptionValueST(Manager.PlayerAvoidant)
		SetOptionFlagsST(OPTION_FLAG_NONE, false, "playerCentricState")
	endEvent

	event OnSelectST()
		Manager.PlayerAvoidant = !Manager.PlayerAvoidant
		setToggleOptionValueST(Manager.PlayerAvoidant)

		if Manager.PlayerAvoidant
			SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "playerCentricState")
		else
			SetOptionFlagsST(OPTION_FLAG_NONE, false, "playerCentricState")
		endif
	endEvent

	event OnHighlightST()
		SetInfoText("The player will never be a target for combat vore.")
	endEvent
endstate


state DigestPlayerState
	event OnDefaultST()
		Manager.killPlayer = true
		setToggleOptionValueST(Manager.killPlayer)
	endEvent

	event OnSelectST()
		Manager.killPlayer = !Manager.killPlayer
		setToggleOptionValueST(Manager.killPlayer)
	endEvent

	event OnHighlightST()
		SetInfoText("Enables lethal digestion of the Dovakhiin. If this is enabled, the Dovahkiin can be digested to death. This will break a lot of quests! Totally recommended. Disabling it does not guarantee that you will survive, if you are taking damage from other sources.")
	endEvent
endstate


state ScatStateNPC
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Manager.scatTypeNPC)
		SetMenuDialogDefaultIndex(2)
		SetMenuDialogOptions(scatListNPC)
	endEvent

	event OnMenuAcceptST(int index)
		Manager.scatTypeNPC = index
		SetMenuOptionValueST(scatListNPC[Manager.scatTypeNPC])
	endEvent

	event OnDefaultST()
		Manager.scatTypeNPC = 2
		SetMenuOptionValueST(scatListNPC[Manager.scatTypeNPC])
	endEvent

	event OnHighlightST()
		if Manager.scatTypeNPC == 0
			SetInfoText("Defecation will be complete absorption (incompatible with Hungry Bones).")
		elseif Manager.scatTypeNPC == 1
			SetInfoText("Defecation will be a pile of feces (incompatible with Hungry Bones).")
		elseif Manager.scatTypeNPC == 2
			SetInfoText("Defecation will be a skeleton (required for the Hungry Bones perk and spell).")
		elseif Manager.scatTypeNPC == 3
			SetInfoText("Regurgitation will be used instead of defecation for NPC remains.")
		endIf
	endEvent
endstate


state ScatStateCreature
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Manager.scatTypeCreature)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(scatListCreature)
	endEvent

	event OnMenuAcceptST(int index)
		Manager.scatTypeCreature = index
		SetMenuOptionValueST(scatListCreature[Manager.scatTypeCreature])
	endEvent

	event OnDefaultST()
		Manager.scatTypeCreature = 1
		SetMenuOptionValueST(scatListCreature[Manager.scatTypeCreature])
	endEvent

	event OnHighlightST()
		if Manager.scatTypeCreature == 0
			SetInfoText("Defecation will be complete absorption.")
		elseif Manager.scatTypeCreature == 1
			SetInfoText("Defecation will be a pile of feces.")
		elseif Manager.scatTypeCreature == 2
			SetInfoText("Regurgitation will be used instead of defecation for creature remains.")
		endIf
	endEvent
endstate


state ScatStateBolus
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Manager.scatTypeBolus)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(scatListBolus)
	endEvent

	event OnMenuAcceptST(int index)
		Manager.scatTypeBolus = index
		SetMenuOptionValueST(scatListBolus[Manager.scatTypeBolus])
	endEvent

	event OnDefaultST()
		Manager.scatTypeBolus = 1
		SetMenuOptionValueST(scatListBolus[Manager.scatTypeBolus])
	endEvent

	event OnHighlightST()
		if Manager.scatTypeBolus == 0
			SetInfoText("Items will be added directly to the predator's inventory.")
		elseif Manager.scatTypeBolus == 1
			SetInfoText("Items will be defecated.")
		elseif Manager.scatTypeBolus == 2
			SetInfoText("Regurgitation will be used instead of defecation for items.")
		endIf
	endEvent
endstate


state DifficultyMenuState
	event OnMenuOpenST()
		SetMenuDialogStartIndex(difficulty)
		SetMenuDialogDefaultIndex(2)
		SetMenuDialogOptions(difficultyList)
	endEvent

	event OnMenuAcceptST(int index)
		SetDifficultyPreset(index)
		adjustPreyData = true
		SetMenuOptionValueST(difficultyList[difficulty])
		ForcePageReset()
	endEvent

	event OnDefaultST()
		SetDifficultyPreset(2)
		adjustPreyData = true
		SetMenuOptionValueST(difficultyList[difficulty])
		ForcePageReset()
	endEvent

	event OnHighlightST()
		if difficulty == 0
			SetInfoText("For you, the world is like a children's cartoon. Escaping from predators is easy, and advancement is faster than a training montage.")
		elseif difficulty == 1
			SetInfoText("For you, the world is like a peaceful meadow. You'll almost always survive and you'll have plenty to eat.")
		elseif difficulty == 2
			SetInfoText("For you, the world is a challenging place. It's eat or be eaten, and only the strong survive.")
		elseif difficulty == 3
			SetInfoText("For you, the world is a dark and terrifying place. It's eat or be eaten, and you're the tastiest meal in town.")
		elseif difficulty == 4
			SetInfoText("For you, life will be short and painful. But that's exactly how you like it.")
		elseif difficulty == 5
			SetInfoText("You drive to Walmart in a Honda Civic with a spoiler, racing tires, and winter chains all year. No preset can contain you.")
		elseif difficulty == 6
			SetInfoText("Debugging difficulty, for people who need to digest or be digested right fucking now.")
		endIf
	endEvent
endstate


state multiPreyState
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Manager.multiPrey)
		SetMenuDialogDefaultIndex(2)
		SetMenuDialogOptions(multiPreyList)
	endEvent

	event OnMenuAcceptST(int index)
		Manager.multiPrey = index
		SetMenuOptionValueST(multiPreyList[index])
	endEvent

	event OnDefaultST()
		Manager.multiPrey = 1
		SetMenuOptionValueST(multiPreyList[2])
	endEvent

	event OnHighlightST()
		if Manager.multiPrey == 0
			SetInfoText("Predators may only swallow a single prey at a time.")
		elseif Manager.multiPrey == 1
			SetInfoText("Predators may swallow one prey for every ten points of vore skill.")
		elseif Manager.multiPrey == 2
			SetInfoText("Predators may swallow one human-sized prey every twelve points of vore skill. Prey size will affect the limit -- predators can swallow a lot more chickens than giants.\nPredators will be blocked from swallowing more than they can hold.")
		elseif Manager.multiPrey == 3
			SetInfoText("Predators may swallow one human-sized prey every twelve points of vore skill. Prey size will affect the limit -- predators can swallow a lot more chickens than giants.\nPredators will vomit if they swallow too much.")
		elseif Manager.multiPrey == 4
			SetInfoText("There is no limit on the number of prey that a predator can swallow. Use with caution.")
		else
			SetInfoText("Control multiprey.")
		endif
	endEvent
endstate


state BYKState
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Manager.BYK)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(BYKList)
	endEvent

	event OnMenuAcceptST(int index)
		Manager.BYK = index
		SetMenuOptionValueST(BYKList[index])
	endEvent

	event OnDefaultST()
		Manager.BYK = 0
		SetMenuOptionValueST(BYKList[0])
	endEvent

	event OnHighlightST()
		if Manager.BYK == 0
			SetInfoText("Become Your Killer is never used.")
		elseif Manager.BYK == 1
			SetInfoText("Become Your Killer only applies to NPCs.")
		elseif Manager.BYK == 2
			SetInfoText("Become Your Killer applies to NPCs and creatures.")
		else
			SetInfoText("Control multiprey.")
		endif
	endEvent
endstate


state VomitStyleState
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Manager.VomitStyle)
		SetMenuDialogDefaultIndex(2)
		SetMenuDialogOptions(vomitStyles)
	endEvent

	event OnMenuAcceptST(int index)
		Manager.VomitStyle = index
		SetMenuOptionValueST(vomitStyles[Manager.VomitStyle])
	endEvent

	event OnDefaultST()
		Manager.VomitStyle = 2
		SetMenuOptionValueST(vomitStyles[Manager.VomitStyle])
	endEvent

	event OnHighlightST()
		if Manager.VomitStyle == 0
			SetInfoText("The classic vomit pile. Derived from the ashpile effect. Quite nice looking, but it only comes in green.")
		elseif Manager.VomitStyle == 1
			SetInfoText("The Macross textured puddle. Simple but textured, so it can be colour matched to semen, vomit, milk, scat, etc.")
		elseif Manager.VomitStyle == 2
			SetInfoText("The Macross animated defilement. A Skeever corpse was sacrificed to produce this lovely morphing puddle. May behave strangely under some circumstances.")
		endif
	endEvent
endstate


state voreDialogState
	event OnSelectST()
		if VoreDialog.GetValue() != 0.0
			VoreDialog.SetValue(0.0)
		else 
			VoreDialog.SetValue(1.0)
		endIf
		setToggleOptionValueST(VoreDialog.GetValue() != 0.0)
	endEvent
	event OnDefaultST()
		VoreDialog.SetValue(1.0)
		setToggleOptionValueST(VoreDialog.GetValue() != 0.0)
	endEvent
	event OnHighlightST()
		SetInfoText("Controls whether Vore dialogue is available.")
	endEvent
endstate


state PerformanceState
	event OnSelectST()
		Manager.PERFORMANCE = !Manager.PERFORMANCE
		setToggleOptionValueST(Manager.PERFORMANCE)
		resetBellies = true
	endEvent
	event OnDefaultST()
		Manager.PERFORMANCE = false
		setToggleOptionValueST(false)
		resetBellies = true
	endEvent
	event OnHighlightST()
		SetInfoText("Enables performance mode, for das Kartoffeln.")
	endEvent
endState


state DebugState
	event OnSelectST()
		if !Manager.DEBUGGING
			bool confirm = ShowMessage("Are you sure you want to enable debugging mode?", false)
			if confirm
				Manager.DEBUGGING = true
				PlayerAlias.RegisterForKey(PlayerAlias.COMPEL_KEY)
				PlayerAlias.RegisterForKey(PlayerAlias.FORGET_KEY)
			endif
		else
			Manager.DEBUGGING = false
			PlayerAlias.UnregisterForKey(PlayerAlias.COMPEL_KEY)
			PlayerAlias.UnregisterForKey(PlayerAlias.FORGET_KEY)
		endif

		setToggleOptionValueST(Manager.DEBUGGING)
		ForcePageReset()
	endEvent
	event OnDefaultST()
		Manager.DEBUGGING = false
		setToggleOptionValueST(Manager.DEBUGGING)
		ForcePageReset()
	endEvent
	event OnHighlightST()
		SetInfoText("Enables debugging mode. This will make all player swallow attempts succeed, provide the player with all vore spells (if they are a predator), and enable some additional MCM options.")
	endEvent
endState


state FlushVomitQueue
	event OnSelectST()
		if !flushActivated
			flushActivated = true
			Manager.VOMIT_CLEAR()
			setToggleOptionValueST(true)
			ShowMessage("Devourment will attempt to flush the vomit queue as soon as you close the MCM.")
		endIf
	endEvent
	event OnDefaultST()
	endEvent
	event OnHighlightST()
		SetInfoText("Attempt to flush the vomit queue.")
	endEvent
endState


state DebugDumpState
	event OnSelectST()
		Manager.ExportDatabase(ExportFilename)
		ShowMessage("JContainers database exported to '" + ExportFilename + "'.", false)
	endEvent
	event OnDefaultST()
		SetTextOptionValueST(false)
	endEvent
	event OnHighlightST()
		SetInfoText("Export all of devourment's SKSE data to files.")
	endEvent
endState


state UnrestrictedItemState
	event OnSelectST()
		if !UnrestrictedItemVore
			bool confirm = ShowMessage("This will ruin everything. Are you sure?")
			if confirm
				UnrestrictedItemVore = true
			endIf
		else
			UnrestrictedItemVore = false
		endIf
		setToggleOptionValueST(UnrestrictedItemVore)
	endEvent
	event OnDefaultST()
		UnrestrictedItemVore = false
		setToggleOptionValueST(UnrestrictedItemVore)
	endEvent
	event OnHighlightST()
		SetInfoText("Enables swallowing a wider variety of inanimate objects. Don't ever use this. Not ever. Never, ever, ever.")
	endEvent
endState


state ResetVisuals
	event OnSelectST()
		Manager.UnassignAllPreyMeters()
		Manager.RestoreAllPreyMeters()
		resetBellies = true
		ShowMessage("Ran the reset procedure.", false)
		setToggleOptionValueST(true)
	endEvent
	event OnHighlightST()
		SetInfoText("Try to reset Devourment's visual. The includes the HUD meters and all belly scaling.")
	endEvent
endState


state ResetState
	event OnSelectST()
		bool confirm = ShowMessage("This might take a while, and it will erase your vore progress. Are you sure?")
		if confirm
			Manager.ResetDevourment()
			ShowMessage("Ran the reset procedure.", false)
			setToggleOptionValueST(true)
		endIf
	endEvent
	event OnHighlightST()
		SetInfoText("Try to reset devourment and all actors affected by it.")
	endEvent
endState


state maxSkillState
	event OnSelectST()
		bool confirm = ShowMessage("This will raise your vore skills by 100. Are you sure?")
		if confirm
			Manager.GivePredXP(playerRef, 10000.0)
			Manager.GivePreyXP(playerRef, 10000.0)
		endIf
		ForcePageReset()
	endEvent
	event OnDefaultST()
		SetTextOptionValueST(false)
	endEvent
	event OnHighlightST()
		SetInfoText("Set the player's vore skills to 100, for testing purposes.")
	endEvent
endState


state maxPerksState
	event OnSelectST()
		bool confirm = ShowMessage("This will give you 100 vore perk points. Are you sure?")
		if confirm
			Manager.IncreaseVoreLevel(playerRef, 100)
		endIf
		ForcePageReset()
	endEvent
	event OnDefaultST()
		SetTextOptionValueST(false)
	endEvent
	event OnHighlightST()
		SetInfoText("Give the player 100 vore perk points, for testing purposes.")
	endEvent
endState


state drawnAnimationState
	event OnDefaultST()
		Manager.drawnAnimations = false
		setToggleOptionValueST(Manager.drawnAnimations)
	endEvent
	event OnSelectST()
		Manager.drawnAnimations = !Manager.drawnAnimations
		setToggleOptionValueST(Manager.drawnAnimations)
	endEvent
	event OnHighlightST()
		SetInfoText("Play vore/scat/vomit animations even with weapons drawn. If this causes you to be unable to use your spells or weapons, just re-equip them and you should be okay. If you find it causes crashes or interferes with enemy AI, then you should definitely disable it.")
	endEvent
endstate


state screamSoundsState
	event OnDefaultST()
		Manager.screamSounds = false
		setToggleOptionValueST(Manager.screamSounds)
	endEvent
	event OnSelectST()
		Manager.screamSounds = !Manager.screamSounds
		setToggleOptionValueST(Manager.screamSounds)
	endEvent
	event OnHighlightST()
		SetInfoText("Play scream audio when Prey dies. It can be a little bit loud and off-putting.")
	endEvent
endstate


state SkullsForDragonsState
	event OnDefaultST()
		SkullHandler.SkullsForDragons = true
		setToggleOptionValueST(SkullHandler.SkullsForDragons)
	endEvent
	event OnSelectST()
		SkullHandler.SkullsForDragons = !SkullHandler.SkullsForDragons
		setToggleOptionValueST(SkullHandler.SkullsForDragons)
	endEvent
	event OnHighlightST()
		SetInfoText("Collect the skulls of dragons after digesting them. Careful, they're heavy.")
	endEvent
endstate


state SkullsForUniqueState
	event OnDefaultST()
		SkullHandler.SkullsForUnique = true
		setToggleOptionValueST(SkullHandler.SkullsForUnique)
	endEvent
	event OnSelectST()
		SkullHandler.SkullsForUnique = !SkullHandler.SkullsForUnique
		SkullHandler.SkullsForEveryone = SkullHandler.SkullsForEveryone && SkullHandler.SkullsForUnique
		setToggleOptionValueST(SkullHandler.SkullsForUnique)
		setToggleOptionValueST(SkullHandler.SkullsForEveryone, false, "SkullsForEveryoneState")
	endEvent
	event OnHighlightST()
		SetInfoText("Collect the skulls of unique NPCs after digesting them.\nUseful for resurrecting them if you need them for quest purposes.")
	endEvent
endstate


state SkullsForEssentialState
	event OnDefaultST()
		SkullHandler.SkullsForEssential = true
		setToggleOptionValueST(SkullHandler.SkullsForEssential)
	endEvent
	event OnSelectST()
		SkullHandler.SkullsForEssential = !SkullHandler.SkullsForEssential
		SkullHandler.SkullsForEveryone = SkullHandler.SkullsForEveryone && SkullHandler.SkullsForEssential
		setToggleOptionValueST(SkullHandler.SkullsForEssential)
		setToggleOptionValueST(SkullHandler.SkullsForEveryone, false, "SkullsForEveryoneState")
	endEvent
	event OnHighlightST()
		SetInfoText("Collect the skulls of essential, protected, and invulnerable NPCs after digesting them.\nUseful for resurrecting them if you need them for quest purposes.")
	endEvent
endstate


state SkullsForEveryoneState
	event OnDefaultST()
		SkullHandler.SkullsForEveryone = false
		setToggleOptionValueST(SkullHandler.SkullsForEveryone)
	endEvent
	event OnSelectST()
		SkullHandler.SkullsForEveryone = !SkullHandler.SkullsForEveryone
		SkullHandler.SkullsForUnique = SkullHandler.SkullsForUnique || SkullHandler.SkullsForEveryone
		SkullHandler.SkullsForEssential = SkullHandler.SkullsForEssential || SkullHandler.SkullsForEveryone
		setToggleOptionValueST(SkullHandler.SkullsForEveryone)
		setToggleOptionValueST(SkullHandler.SkullsForUnique, false, "SkullsForUniqueState")
		setToggleOptionValueST(SkullHandler.SkullsForEssential, false, "SkullsForEssentialState")
	endEvent
	event OnHighlightST()
		SetInfoText("Collect the skulls of ALL NPCs after digesting them.\nNot recommend. The skulls can accumulate extremely quickly.")
	endEvent
endstate


state SkullsSeparateState
	event OnDefaultST()
		SkullHandler.SkullsSeparate = false
		setToggleOptionValueST(SkullHandler.SkullsSeparate)
	endEvent
	event OnSelectST()
		SkullHandler.SkullsSeparate = !SkullHandler.SkullsSeparate
		setToggleOptionValueST(SkullHandler.SkullsSeparate)
	endEvent
	event OnHighlightST()
		SetInfoText("If enabled, skulls will be digested separately from the rest of the prey's body. This can cause problems if you find a way to re-swallow the skull before the rest of the body finishes digesting! It's fun though. Sooo fun.")
	endEvent
endstate


state softDeathState
	event OnDefaultST()
		Manager.SoftDeath = false
		setToggleOptionValueST(Manager.SoftDeath)
	endEvent
	event OnSelectST()
		Manager.SoftDeath = !Manager.SoftDeath
		setToggleOptionValueST(Manager.SoftDeath)
	endEvent
	event OnHighlightST()
		SetInfoText("If the player gets digested, player.kill() will be called instead of player.killEssential. This may improve compatibility with alternate death mods.")
	endEvent
endstate


state DontAddPowersState
	event OnDefaultST()
		DontAddPowers = false
		setToggleOptionValueST(DontAddPowers)
	endEvent
	event OnSelectST()
		DontAddPowers = !DontAddPowers
		setToggleOptionValueST(DontAddPowers)
	endEvent
	event OnHighlightST()
		SetInfoText("If this setting is enabled, the basic vore powers wont be (re)added to the player. Useful for those who play exclusively as prey, or who access the powers in others ways (such as Easy WheelMenu).")
	endEvent
endstate


state AltPerkMenuState
	event OnDefaultST()
		AltPerkMenus = false
		setToggleOptionValueST(AltPerkMenus)
	endEvent
	event OnSelectST()
		AltPerkMenus = !AltPerkMenus
		setToggleOptionValueST(AltPerkMenus)
	endEvent
	event OnHighlightST()
		SetInfoText("Use the alternate perk menus. They aren't as flashy as the ones from Custom Skill Framework, but at least they'll work without that mod installed.")
	endEvent
endstate


state SwallowHealState
	event OnDefaultST()
		Manager.SwallowHeal = false
		setToggleOptionValueST(Manager.SwallowHeal)
	endEvent
	event OnSelectST()
		Manager.SwallowHeal = !Manager.SwallowHeal
		setToggleOptionValueST(Manager.SwallowHeal)
	endEvent
	event OnHighlightST()
		SetInfoText("When prey are swallowed they are restored to full health so that they have a decent chance of struggling free.")
	endEvent
endstate


state endoAnyoneState
	event OnDefaultST()
		Manager.endoAnyone = false
		setToggleOptionValueST(Manager.endoAnyone)
	endEvent
	event OnSelectST()
		Manager.endoAnyone = !Manager.endoAnyone
		setToggleOptionValueST(Manager.endoAnyone)
	endEvent
	event OnHighlightST()
		SetInfoText("Endo can be used even when the predator and prey are not friends.")
	endEvent
endstate


state crouchScatState
	event OnDefaultST()
		Manager.crouchScat = true
		setToggleOptionValueST(Manager.crouchScat)
	endEvent
	event OnSelectST()
		Manager.crouchScat = !Manager.crouchScat
		setToggleOptionValueST(Manager.crouchScat)
	endEvent
	event OnHighlightST()
		SetInfoText("Defecate by crouching, when you are not in combat. This can interfere with sneaking.\nIf it's disabled, you can still use the Defecate power.")
	endEvent
endstate


state noEscapeState
	event OnDefaultST()
		Manager.noEscape = false
		setToggleOptionValueST(Manager.noEscape)
	endEvent
	event OnSelectST()
		Manager.noEscape = !Manager.noEscape
		setToggleOptionValueST(Manager.noEscape)
	endEvent
	event OnHighlightST()
		SetInfoText("Swallowed prey cannot escape their predators stomach unless the struggle mechanic is used")
	endEvent
endstate


state MicroModeState
	event OnDefaultST()
		Manager.MicroMode = false
		setToggleOptionValueST(Manager.MicroMode)
	endEvent
	event OnSelectST()
		Manager.MicroMode = !Manager.MicroMode
		setToggleOptionValueST(Manager.MicroMode)
		if Manager.MicroMode
			Manager.multiPrey = 3
			SetMenuOptionValueST(multiPreyList[3])
		endIf
	endEvent
	event OnHighlightST()
		SetInfoText("In Micro mode, prey can only be swallowed if they are smaller than the predator. This will not prevent vore from taking place through dialogue though.")
	endEvent
endstate


state CombatAccelState
	event OnDefaultST()
		Manager.CombatAcceleration = false
		setToggleOptionValueST(Manager.CombatAcceleration)
	endEvent
	event OnSelectST()
		Manager.CombatAcceleration = !Manager.CombatAcceleration
		setToggleOptionValueST(Manager.CombatAcceleration)
	endEvent
	event OnHighlightST()
		SetInfoText("Acceleration and digestion happen ten times faster in combat.")
	endEvent
endstate


state useHelpState
	event OnDefaultST()
		Manager.useHelpMessages = true
		setToggleOptionValueST(Manager.useHelpMessages)
	endEvent
	event OnSelectST()
		Manager.useHelpMessages = !Manager.useHelpMessages
		setToggleOptionValueST(Manager.useHelpMessages)
	endEvent
	event OnHighlightST()
		SetInfoText("Display messages using 'Help Messages' instead of top-left corner notifications. These messages sometimes get stuck in place until you quit and restart Skyrim. Sometimes they even get stuck permanently. But they look great!")
	endEvent
endstate



state UseLocusMorphsState
	event OnDefaultST()
		Morphs.UseLocationalMorphs = false
		resetBellies = true
		ForcePageReset()
	endEvent
	event OnSelectST()
		Morphs.UseLocationalMorphs = !Morphs.UseLocationalMorphs
		resetBellies = true
		ForcePageReset()
	endEvent
	event OnHighlightST()
		SetInfoText("Use locational morphs (breasts, stomach, etc). The results are heavily dependent on the body you use and can be unpredictable. ")
	endEvent
endstate


state EliminationLocusState
	event OnDefaultST()
		Morphs.UseEliminationLocus = true
		resetBellies = true
		setToggleOptionValueST(Morphs.UseEliminationLocus)
	endEvent
	event OnSelectST()
		Morphs.UseEliminationLocus = !Morphs.UseEliminationLocus
		resetBellies = true
		setToggleOptionValueST(Morphs.UseEliminationLocus)
	endEvent
	event OnHighlightST()
		SetInfoText("As digestion proceeds and the stomach shrinks, the butt will be inflated proportionally.")
	endEvent
endstate


state struggleSlidersState
	event OnDefaultST()
		Morphs.useStruggleSliders = false
		resetBellies = true
		ForcePageReset()
		setToggleOptionValueST(Morphs.useStruggleSliders)
	endEvent
	event OnSelectST()
		Morphs.useStruggleSliders = !Morphs.useStruggleSliders
		resetBellies = true
		ForcePageReset()
		setToggleOptionValueST(Morphs.useStruggleSliders)
	endEvent
	event OnHighlightST()
		SetInfoText("Use the struggle sliders built into some MorphVore bodies and some equippable bellies. More Script-intensive but better looking and probably more stable.\nThe Gat, Vegan, and KongPow bellies don't support this but they have built-in struggle animations. The SkepticMech and Gaz Bellies support them, as well as the Gaz MorphVore body.")
	endEvent
endstate


state equipBellyState
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Morphs.EquippableBellyType)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(EquipList)
	endEvent

	event OnMenuAcceptST(int index)
		Morphs.EquippableBellyType = index
		SetMenuOptionValueST(EquipList[index])
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.EquippableBellyType = 1
		SetMenuOptionValueST(EquipList[Morphs.EquippableBellyType])
		resetBellies = true
	endEvent

	event OnHighlightST()
		if Morphs.EquippableBellyType == 1
			SetInfoText("Equip the Macross morphvore belly with struggle sliders.\nCopies the body skin texture and generally looks excellent with any CBBE or 3BA body.")
		elseif Morphs.EquippableBellyType == 2
			SetInfoText("Equip the SkepticMech morphvore belly with struggle sliders.\nUses Xomod texturing and is relatively compatible with CBBE, 3BA, UNP, UUNP, and BHUNP.")
		else
			SetInfoText("Don't use any equipable belly.")
		endIf
	endEvent
endstate


state notificationsState
	event OnDefaultST()
		Manager.notifications = true
		setToggleOptionValueST(Manager.notifications)
	endEvent
	event OnSelectST()
		Manager.notifications = !Manager.notifications
		setToggleOptionValueST(Manager.notifications)
	endEvent
	event OnHighlightST()
		SetInfoText("Enables notification messages.")
	endEvent
endstate


state shitItemsState
	event OnDefaultST()
		Manager.shitItems = false
		setToggleOptionValueST(Manager.shitItems)
	endEvent
	event OnSelectST()
		Manager.shitItems = !Manager.shitItems
		setToggleOptionValueST(Manager.shitItems)
	endEvent
	event OnHighlightST()
		SetInfoText("Digested prey will have their equipment removed and excreted separately.")
	endEvent
endstate


state stripItemsState
	event OnDefaultST()
		Manager.stomachStrip = false
		setToggleOptionValueST(Manager.stomachStrip)
	endEvent
	event OnSelectST()
		Manager.stomachStrip = !Manager.stomachStrip
		setToggleOptionValueST(Manager.stomachStrip)
	endEvent
	event OnHighlightST()
		SetInfoText("Swallowed prey will have their equipment stripped off.")
	endEvent
endstate


state DisableDependencyState
	event OnDefaultST()
		DisableDependencyChecks = false
		setToggleOptionValueST(DisableDependencyChecks)
	endEvent
	event OnSelectST()
		DisableDependencyChecks = !DisableDependencyChecks
		setToggleOptionValueST(DisableDependencyChecks)
	endEvent
	event OnHighlightST()
		SetInfoText("Disable dependency checking when you load or start the game.")
	endEvent
endstate


state autoPredState
	event OnDefaultST()
	endEvent
	
	event OnSelectST()
		Actor target = GetTarget()
		if target != none && target != PlayerRef
			if Manager.IsVorish(target)
				Manager.ToggleVorish(target, false)
				SetToggleOptionValueST(false)
			else
				Manager.ToggleVorish(target, true)
				SetToggleOptionValueST(true)
			endIf
		else
			ShowMessage("No target selected!")
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("Add the Vorish keyword to the  NPC or creature. They will be eligible to use vore attacks during combat, regardless of their race or sex or other factions.")
	endEvent
endstate


state forceVomitState
	event OnSelectST()
		Actor target = GetTarget()
		if target != none && target != PlayerRef
			Manager.vomit(target)
			vomitActivated = true
			ForcePageReset()
		endIf
	endEvent
	event OnHighlightST()
		SetInfoText("Force the target to vomit out all of their undigested prey.")
	endEvent
endState


state BumpAmplitudeState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.struggleAmplitude)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.05, 5.0)
		SetSliderDialogInterval(0.05)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.struggleAmplitude = a_value
		SetSliderOptionValueST(Morphs.struggleAmplitude, "{2}x")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.struggleAmplitude = 1.0
		SetSliderOptionValueST(Morphs.struggleAmplitude, "{2}x")
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Scaling factor for the struggle bump sliders.")
	endEvent
endState


state MorphSpeedState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.MorphSpeed)
		SetSliderDialogDefaultValue(0.08)
		SetSliderDialogRange(0.01, 0.5)
		SetSliderDialogInterval(0.01)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.MorphSpeed = a_value
		resetBellies = true
		SetSliderOptionValueST(Morphs.MorphSpeed, "{2}x")
	endEvent

	event OnDefaultST()
		Morphs.MorphSpeed = 1.0
		resetBellies = true
		SetSliderOptionValueST(Morphs.MorphSpeed, "{2}x")
	endEvent

	event OnHighlightST()
		SetInfoText("Scaling rate for belly size and struggle bumps. Setting this too low will impact performance, but setting it too high will increase the choppiness of size changes.")
	endEvent
endState


state resetPreyState
	event OnInputOpenST()
		SetInputDialogStartText(PO3_SKSEFunctions.IntToString(preyID, true))
	endEvent

	event OnInputAcceptST(string a_input)
		int targetID = PO3_SKSEFunctions.StringToInt(a_input)
		ObjectReference target = Game.GetForm(targetID) as ObjectReference
		if target
			SetInputOptionValueST(Namer(target))
			Manager.resetPrey(target)
		endIf

	endEvent

	event OnHighlightST()
		SetInfoText("Reset a particular prey, reappearing them near their predator. Enter the refID of the prey at the prompt! NOT FULLY IMPLEMENTED YET.")
	endEvent
endState


state QuickSettingsKeyState
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if ConflictCheck("Settings", conflictControl, conflictName)
			PlayerAlias.UnRegisterForKey(PlayerAlias.QUICK_KEY)
			
			if newKeyCode > 1
				PlayerAlias.QUICK_KEY = newKeyCode
				SetKeyMapOptionValueST(PlayerAlias.QUICK_KEY)
				PlayerAlias.RegisterForKey(PlayerAlias.QUICK_KEY)
				playerRef.RemoveSpell(QuickSettings)
			else
				PlayerAlias.QUICK_KEY = 0
				SetKeyMapOptionValueST(PlayerAlias.QUICK_KEY)
				playerRef.AddSpell(QuickSettings)
			endIf
		endIf
	endEvent

	event OnDefaultST()
		PlayerAlias.UnRegisterForKey(PlayerAlias.QUICK_KEY)
		PlayerAlias.QUICK_KEY = 0
		SetKeyMapOptionValueST(0)
		playerRef.RemoveSpell(QuickSettings)
	endEvent

	event OnHighlightST()
		SetInfoText("Sets the quick-settings key.")
	endEvent
endState


state compelVoreKeyState
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if ConflictCheck("Compel", conflictControl, conflictName)
			PlayerAlias.UnRegisterForKey(PlayerAlias.COMPEL_KEY)
			PlayerAlias.COMPEL_KEY = newKeyCode
			SetKeyMapOptionValueST(PlayerAlias.COMPEL_KEY)

			if Manager.DEBUGGING && PlayerAlias.COMPEL_KEY > 1
				PlayerAlias.RegisterForKey(PlayerAlias.COMPEL_KEY)
			endIf
		endIf
	endEvent

	event OnDefaultST()
		PlayerAlias.UnRegisterForKey(PlayerAlias.COMPEL_KEY)
		PlayerAlias.COMPEL_KEY = 43
		SetKeyMapOptionValueST(PlayerAlias.COMPEL_KEY)
		
		if Manager.DEBUGGING
			PlayerAlias.RegisterForKey(PlayerAlias.COMPEL_KEY)
		endIf
	endEvent

	event OnHighlightST()
		SetInfoText("Sets the Compel Vore key. Forces actors to vore or endo each others. Only works in Debugging mode.")
	endEvent
endState


state ForgetKeyState
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if ConflictCheck("Forget", conflictControl, conflictName)
			PlayerAlias.UnRegisterForKey(PlayerAlias.FORGET_KEY)
			PlayerAlias.FORGET_KEY = newKeyCode
			SetKeyMapOptionValueST(PlayerAlias.FORGET_KEY)

			if Manager.DEBUGGING && PlayerAlias.FORGET_KEY > 1
				PlayerAlias.RegisterForKey(PlayerAlias.FORGET_KEY)
			endIf
		endIf
	endEvent

	event OnDefaultST()
		PlayerAlias.UnRegisterForKey(PlayerAlias.FORGET_KEY)
		PlayerAlias.FORGET_KEY = 0
		SetKeyMapOptionValueST(PlayerAlias.FORGET_KEY)
		
		if Manager.DEBUGGING
			PlayerAlias.RegisterForKey(PlayerAlias.FORGET_KEY)
		endIf
	endEvent

	event OnHighlightST()
		SetInfoText("Sets the Forget Spells key. The player will lose any spells or powers that are equipped. Only works in Debugging mode.")
	endEvent
endState


state VoreKeyState
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if ConflictCheck("Vore", conflictControl, conflictName)
			PlayerAlias.UnregisterForKey(PlayerAlias.VORE_KEY)
			
			if newKeyCode > 1
				PlayerAlias.VORE_KEY = newKeyCode
				SetKeyMapOptionValueST(PlayerAlias.VORE_KEY)
				PlayerAlias.RegisterForKey(PlayerAlias.VORE_KEY)
			else
				PlayerAlias.VORE_KEY = 0
				SetKeyMapOptionValueST(PlayerAlias.VORE_KEY)
			endIf
		endIf
	endEvent

	event OnDefaultST()
		PlayerAlias.UnregisterForKey(PlayerAlias.VORE_KEY)
		PlayerAlias.VORE_KEY = 0
		SetKeyMapOptionValueST(PlayerAlias.VORE_KEY)
	endEvent

	event OnHighlightST()
		SetInfoText("Sets the vore key.")
	endEvent
endState


state EndoKeyState
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if ConflictCheck("Endo", conflictControl, conflictName)
			PlayerAlias.UnregisterForKey(PlayerAlias.ENDO_KEY)
			
			if newKeyCode > 1
				PlayerAlias.ENDO_KEY = newKeyCode
				SetKeyMapOptionValueST(PlayerAlias.ENDO_KEY)
				PlayerAlias.RegisterForKey(PlayerAlias.ENDO_KEY)
			else
				PlayerAlias.ENDO_KEY = 0
				SetKeyMapOptionValueST(PlayerAlias.ENDO_KEY)
			endIf
		endIf
	endEvent

	event OnDefaultST()
		PlayerAlias.UnregisterForKey(PlayerAlias.ENDO_KEY)
		PlayerAlias.ENDO_KEY = 34
		SetKeyMapOptionValueST(PlayerAlias.ENDO_KEY)
	endEvent

	event OnHighlightST()
		SetInfoText("Sets the endo key.")
	endEvent
endState


state CombKeyState
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if ConflictCheck("Swallow", conflictControl, conflictName)
			PlayerAlias.UnregisterForKey(PlayerAlias.COMB_KEY)
			
			if newKeyCode > 1
				PlayerAlias.COMB_KEY = newKeyCode
				SetKeyMapOptionValueST(PlayerAlias.COMB_KEY)
				PlayerAlias.RegisterForKey(PlayerAlias.COMB_KEY)
			else
				PlayerAlias.COMB_KEY = 0
				SetKeyMapOptionValueST(PlayerAlias.COMB_KEY)
			endIf
		endIf
	endEvent

	event OnDefaultST()
		PlayerAlias.UnregisterForKey(PlayerAlias.COMB_KEY)
		PlayerAlias.COMB_KEY = 0
		SetKeyMapOptionValueST(PlayerAlias.COMB_KEY)
	endEvent

	event OnHighlightST()
		SetInfoText("Sets the contextual swallow key. Devourment will try to decide based on context whether to use vore or endo. This power usually doesn't work correctly on very large creatures because of range and targetting issues.")
	endEvent
endState


state dialogKeyState
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if ConflictCheck("Dialog", conflictControl, conflictName)
			PlayerAlias.UnregisterForKey(PlayerAlias.DIALOG_KEY)
			
			if newKeyCode > 1
				PlayerAlias.DIALOG_KEY = newKeyCode
				SetKeyMapOptionValueST(PlayerAlias.DIALOG_KEY)
				PlayerAlias.RegisterForKey(PlayerAlias.DIALOG_KEY)
			else
				PlayerAlias.DIALOG_KEY = 0
				SetKeyMapOptionValueST(PlayerAlias.DIALOG_KEY)
			endIf
		endIf
	endEvent

	event OnDefaultST()
		PlayerAlias.UnregisterForKey(PlayerAlias.DIALOG_KEY)
		PlayerAlias.DIALOG_KEY = 34
		SetKeyMapOptionValueST(PlayerAlias.DIALOG_KEY)
		PlayerAlias.RegisterForKey(PlayerAlias.DIALOG_KEY)
	endEvent

	event OnHighlightST()
		SetInfoText("Sets the vore dialog key.")
	endEvent
endState


state saveSettingsState
	event OnSelectST()
		if Manager.saveSettings(SettingsFileName)
			ShowMessage("Saved settings to '" + SettingsFileName + "'.", false)
		else
			ShowMessage("Couldn't write to '" + SettingsFileName + "'.", false)
		endIf
	endEvent
	event OnDefaultST()
		SetTextOptionValueST(false)
	endEvent
	event OnHighlightST()
		SetInfoText("Store settings to disk. If you start a new game, these settings will be loaded automatically.")
	endEvent
endState


state loadSettingsState
	event OnSelectST()
		if Manager.loadSettings(SettingsFileName)
			ShowMessage("Loaded settings from '" + SettingsFileName + "'.", false)
		else
			ShowMessage("Couldn't read from '" + SettingsFileName + "'.", false)
		endif
		ForcePageReset()
	endEvent
	event OnDefaultST()
		SetTextOptionValueST(false)
	endEvent
	event OnHighlightST()
		SetInfoText("Load settings from disk.")
	endEvent
endState


state Scaling_Locus0State
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.Locus_Scales[0])
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.05)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.Locus_Scales[0] = a_value
		SetSliderOptionValueST(a_value, "{2}")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Scales[0] = 1.0
		SetSliderOptionValueST(1.0, "{2}")
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Scaling size for Locus 0 (which is the stomach by default).")
	endEvent
endState


state Scaling_Locus1State
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.Locus_Scales[1])
		SetSliderDialogDefaultValue(5.0)
		SetSliderDialogRange(0.0, 20.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.Locus_Scales[1] = a_value
		SetSliderOptionValueST(a_value, "{2}")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Scales[1] = 5.0
		SetSliderOptionValueST(5.0, "{2}")
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Scaling size for Locus 1 (which is the buttocks by default).")
	endEvent
endState


state Scaling_Locus3State
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.Locus_Scales[3])
		SetSliderDialogDefaultValue(2.0)
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.05)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.Locus_Scales[3] = a_value
		SetSliderOptionValueST(a_value, "{2}")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Scales[3] = 2.0
		SetSliderOptionValueST(2.0, "{2}")
		resetBellies = true
	endEvent

	event OnHighlightST()
		if Morphs.UseDualBreastMode
			SetInfoText("Scaling size for Locus 3 (which is the left breast by default).")
		else
			SetInfoText("Scaling size for Locus 3 (which is the breasts by default).")
		endIf
	endEvent
endState


state Scaling_Locus4State
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.Locus_Scales[4])
		SetSliderDialogDefaultValue(2.0)
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.05)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.Locus_Scales[4] = a_value
		SetSliderOptionValueST(a_value, "{2}")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Scales[4] = 2.0
		SetSliderOptionValueST(2.0, "{2}")
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Scaling size for Locus 4 (which is the right breast by default).")
	endEvent
endState


state Scaling_Locus5State
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.Locus_Scales[5])
		SetSliderDialogDefaultValue(4.0)
		SetSliderDialogRange(0.0, 20.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.Locus_Scales[5] = a_value
		SetSliderOptionValueST(a_value, "{2}")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Scales[5] = 4.0
		SetSliderOptionValueST(4.0, "{2}")
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Scaling size for Locus 5 (which is the scrotum by default).")
	endEvent
endState


state Scaling_Locus0_MaxState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.Locus_Maxes[0])
		SetSliderDialogDefaultValue(5.0)
		SetSliderDialogRange(0.0, 50.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.Locus_Maxes[0] = a_value
		SetSliderOptionValueST(a_value, "{2}")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Maxes[0] = 5.0
		SetSliderOptionValueST(5.0, "{2}")
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Maximum scaling size for Locus 0 (which is the stomach by default).")
	endEvent
endState


state Scaling_Locus1_MaxState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.Locus_Maxes[1])
		SetSliderDialogDefaultValue(25.0)
		SetSliderDialogRange(0.0, 250.0)
		SetSliderDialogInterval(0.5)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.Locus_Maxes[1] = a_value
		SetSliderOptionValueST(a_value, "{2}")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Maxes[1] = 25.0
		SetSliderOptionValueST(25.0, "{2}")
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Maximum scaling size for Locus 1 (which is the buttocks by default).")
	endEvent
endState


state Scaling_Locus3_MaxState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.Locus_Maxes[3])
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.2)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.Locus_Maxes[3] = a_value
		SetSliderOptionValueST(a_value, "{2}")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Maxes[3] = 10.0
		SetSliderOptionValueST(10.0, "{2}")
		resetBellies = true
	endEvent

	event OnHighlightST()
		if Morphs.UseDualBreastMode
			SetInfoText("Maximum scaling size for Locus 3 (which is the left breast by default).")
		else
			SetInfoText("Maximum scaling size for Locus 3 (which is the breasts by default).")
		endIf
	endEvent
endState


state Scaling_Locus4_MaxState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.Locus_Maxes[4])
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.2)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.Locus_Maxes[4] = a_value
		SetSliderOptionValueST(a_value, "{2}")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Maxes[4] = 10.0
		SetSliderOptionValueST(10.0, "{2}")
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Maximum scaling size for Locus 4 (which is the right breast by default).")
	endEvent
endState


state Scaling_Locus5_MaxState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Morphs.Locus_Maxes[5])
		SetSliderDialogDefaultValue(20.0)
		SetSliderDialogRange(0.0, 250.0)
		SetSliderDialogInterval(0.5)
	endEvent

	event OnSliderAcceptST(float a_value)
		Morphs.Locus_Maxes[5] = a_value
		SetSliderOptionValueST(a_value, "{2}")
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Maxes[5] = 20.0
		SetSliderOptionValueST(20.0, "{2}")
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Maximum scaling size for Locus 5 (which is the scrotum by default).")
	endEvent
endState


state DualBreastModeState
	event OnSelectST()
		Morphs.UseDualBreastMode = !Morphs.UseDualBreastMode
		setToggleOptionValueST(Morphs.UseDualBreastMode)
		ForcePageReset()
		resetBellies = true
	endEvent
	event OnDefaultST()
		Morphs.UseDualBreastMode = true
		setToggleOptionValueST(Morphs.UseDualBreastMode)
		ForcePageReset()
		resetBellies = true
	endEvent
	event OnHighlightST()
		SetInfoText("In Dual-Breast mode, the breasts are treated as separate locuses.")
	endEvent
endstate


state Slider_Locus0State
	event OnInputOpenST()
		SetInputDialogStartText(Morphs.Locus_Sliders[0])
	endEvent

	event OnInputAcceptST(string a_input)
		Morphs.Locus_Sliders[0] = a_input
		SetInputOptionValueST(Morphs.Locus_Sliders[0])
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Sliders[0] = "Vore Prey Belly"
		SetInputOptionValueST(Morphs.Locus_Sliders[0])
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Slider/Node for Locus 0 (which is the belly by default). Recommendations:\n" + \
		"'Vore Prey Belly' is a slider present in the MorphVore bodies and the equippable bellies.\n" + \
		"'PregnancyBelly' is a slider in CBBE, 3BA, and BHUNP; it's supported by many armors and outfits.")
	endEvent
endState


state Slider_Locus1State
	event OnInputOpenST()
		SetInputDialogStartText(Morphs.Locus_Sliders[1])
	endEvent

	event OnInputAcceptST(string a_input)
		Morphs.Locus_Sliders[1] = a_input
		SetInputOptionValueST(Morphs.Locus_Sliders[1])
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Sliders[1] = "ChubbyButt"
		SetInputOptionValueST(Morphs.Locus_Sliders[1])
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Slider/Node for Locus 1 (which is the buttocks by default).\n" + \
		"Recommended: 'ChubbyButt' is a slider in CBBE, 3BA, and BHUNP; it's supported by many armors and outfits.")
	endEvent
endState


state Slider_Locus3State
	event OnInputOpenST()
		SetInputDialogStartText(Morphs.Locus_Sliders[3])
	endEvent

	event OnInputAcceptST(string a_input)
		Morphs.Locus_Sliders[3] = a_input
		SetInputOptionValueST(Morphs.Locus_Sliders[3])
		resetBellies = true
	endEvent

	event OnDefaultST()
		if Morphs.UseDualBreastMode
			Morphs.Locus_Sliders[3] = "BVoreL"
		else
			Morphs.Locus_Sliders[3] = "BreastsNewSH"
		endIf
		SetInputOptionValueST(Morphs.Locus_Sliders[3])
		resetBellies = true
	endEvent

	event OnHighlightST()
		if Morphs.UseDualBreastMode
			SetInfoText(\
			"Slider/Node for Locus 3 (which is the left breast by default). Recommendations:\n" + \
			"'BVoreL' is the left breast vore slider from the MorphVore 3BAv2 body.\n" + \
			"'NPC L Breast' is the left breast node from the XPMSE skeleton. It works with almost everything.")
		else
			SetInfoText("Slider/Node for Locus 3 (which is the breasts by default).\n" + \
			"Recommended: 'BreastsNewSH' is a slider in CBBE, 3BA, and BHUNP; it's supported by many armors and outfits.")
		endIf
	endEvent
endState


state Slider_Locus4State
	event OnInputOpenST()
		SetInputDialogStartText(Morphs.Locus_Sliders[4])
	endEvent

	event OnInputAcceptST(string a_input)
		Morphs.Locus_Sliders[4] = a_input
		SetInputOptionValueST(Morphs.Locus_Sliders[4])
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Sliders[4] = "BVoreR"
		SetInputOptionValueST(Morphs.Locus_Sliders[4])
		resetBellies = true
	endEvent

	event OnHighlightST()
		if Morphs.UseDualBreastMode
			SetInfoText(\
			"Slider/Node for Locus 4 (which is the right breast by default). Recommendations:\n" + \
			"'BVoreR' is the right breast vore slider from the MorphVore 3BAv2 body.\n" + \
			"'NPC R Breast' is the right breast node from the XPMSE skeleton. It works with almost everything.")
		else
		endIf
	endEvent
endState


state Slider_Locus5State
	event OnInputOpenST()
		SetInputDialogStartText(Morphs.Locus_Sliders[5])
	endEvent

	event OnInputAcceptST(string a_input)
		Morphs.Locus_Sliders[5] = a_input
		SetInputOptionValueST(Morphs.Locus_Sliders[5])
		resetBellies = true
	endEvent

	event OnDefaultST()
		Morphs.Locus_Sliders[5] = "CVore"
		SetInputOptionValueST(Morphs.Locus_Sliders[5])
		resetBellies = true
	endEvent

	event OnHighlightST()
		SetInfoText("Slider/Node for Locus 5 (which is the scrotum by default). Recommendations:\n" + \
		"'CVore' is the cockvore slider from the MorphVore male bodies.\n" + \
		"'NPC GenitalsScrotum [GenScrot]' is the scrotum node from the XPMSE skeleton. It works with almost everything.")
	endEvent
endState


state Chance_Locus0
	Event OnSliderOpenST()
		SetSliderDialogStartValue(LocusChances[0])
		SetSliderDialogDefaultValue(0.5)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.02)
	endEvent

	event OnSliderAcceptST(float a_value)
		LocusChances[0] = a_value
		SetSliderOptionValueST(a_value, "{2}")
	endEvent

	event OnDefaultST()
		LocusChances[0] = 0.5
		SetSliderOptionValueST(0.5, "{2}")
	endEvent

	event OnHighlightST()
		SetInfoText("Probability that NPCs will ingest to locus 0 (oral-vore by default)")
	endEvent
endState


state Chance_Locus1
	Event OnSliderOpenST()
		SetSliderDialogStartValue(LocusChances[1])
		SetSliderDialogDefaultValue(0.1)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.02)
	endEvent

	event OnSliderAcceptST(float a_value)
		LocusChances[1] = a_value
		SetSliderOptionValueST(a_value, "{2}")
	endEvent

	event OnDefaultST()
		LocusChances[1] = 0.1
		SetSliderOptionValueST(0.1, "{2}")
	endEvent

	event OnHighlightST()
		SetInfoText("Probability that NPCs will ingest to locus 1 (anal-vore by default)")
	endEvent
endState


state Chance_Locus2
	Event OnSliderOpenST()
		SetSliderDialogStartValue(LocusChances[2])
		SetSliderDialogDefaultValue(0.1)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.02)
	endEvent

	event OnSliderAcceptST(float a_value)
		LocusChances[2] = a_value
		SetSliderOptionValueST(a_value, "{2}")
	endEvent

	event OnDefaultST()
		LocusChances[2] = 0.1
		SetSliderOptionValueST(0.1, "{2}")
	endEvent

	event OnHighlightST()
		SetInfoText("Probability that NPCs will ingest to locus 2 (unbirth by default)")
	endEvent
endState


state Chance_Locus3
	Event OnSliderOpenST()
		SetSliderDialogStartValue(LocusChances[3])
		SetSliderDialogDefaultValue(0.1)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.02)
	endEvent

	event OnSliderAcceptST(float a_value)
		LocusChances[3] = a_value
		SetSliderOptionValueST(a_value, "{2}")
	endEvent

	event OnDefaultST()
		LocusChances[3] = 0.1
		SetSliderOptionValueST(0.1, "{2}")
	endEvent

	event OnHighlightST()
		if Morphs.UseDualBreastMode
			SetInfoText("Probability that NPCs will ingest to locus 3 (left breast-vore by default)")
		else
			SetInfoText("Probability that NPCs will ingest to locus 3 (breast-vore by default)")
		endIf
	endEvent
endState


state Chance_Locus4
	Event OnSliderOpenST()
		SetSliderDialogStartValue(LocusChances[4])
		SetSliderDialogDefaultValue(0.1)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.02)
	endEvent

	event OnSliderAcceptST(float a_value)
		LocusChances[4] = a_value
		SetSliderOptionValueST(a_value, "{2}")
	endEvent

	event OnDefaultST()
		LocusChances[4] = 0.1
		SetSliderOptionValueST(0.1, "{2}")
	endEvent

	event OnHighlightST()
		SetInfoText("Probability that NPCs will ingest to locus 4 (right breast-vore by default)")
	endEvent
endState


state Chance_Locus5
	Event OnSliderOpenST()
		SetSliderDialogStartValue(LocusChances[5])
		SetSliderDialogDefaultValue(0.1)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.02)
	endEvent

	event OnSliderAcceptST(float a_value)
		LocusChances[5] = a_value
		SetSliderOptionValueST(a_value, "{2}")
	endEvent

	event OnDefaultST()
		LocusChances[5] = 0.1
		SetSliderOptionValueST(0.1, "{2}")
	endEvent

	event OnHighlightST()
		SetInfoText("Probability that NPCs will ingest to locus 5 (cock-vore by default)")
	endEvent
endState


bool function ArrayAddString(String[] asArray, String asValue) global
{ Taken from Chesko's CommonArrayHelper.psc. }
	int i = 0
	while i < asArray.Length
		if asArray[i] == ""
			asArray[i] = asValue
			return true
		else
			i += 1
		endif
	endWhile
	return false
endFunction


bool function ArrayAddInt(int[] aiArray, int aiValue, int aiInsertAtValue = 0) global
{ Taken from Chesko's CommonArrayHelper.psc. }
	int i = 0
	while i < aiArray.Length
		if aiArray[i] == aiInsertAtValue
			aiArray[i] = aiValue
			return true
		else
			i += 1
		endif
	endWhile
	return false
endFunction


bool function ArrayAddForm(Form[] akArray, Form akValue) global
{ Taken from Chesko's CommonArrayHelper.psc. }
	int i = 0
	while i < akArray.Length
		if akArray[i] == none
			akArray[i] = akValue
			return true
		else
			i += 1
		endif
	endWhile
	return false
endFunction


String Function ToggleString(String name, bool toggle)
	if toggle
		return name + ": [X]"
	else
		return name + ": [ ]"
	endIf
EndFunction


Function DisplayQuickSettings()
	UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
	Actor subject = PlayerRef
	Actor target2 = Game.GetCurrentConsoleRef() as Actor
	Actor target3 = Game.GetCurrentCrosshairRef() as Actor

	String playerName = Namer(playerRef, true)
	String target2Name = Namer(target2, true)
	String target3Name = Namer(target3, true)
	
	menu.ResetMenu()

	int ENTRY_SUBJECT
	int ENTRY_T1 = -1
	int ENTRY_T2 = -1
	int ENTRY_T3 = -1

	if (target2 && target2 != playerRef) || (target3 && target3 != playerRef)
		ENTRY_SUBJECT = menu.AddEntryItem("Subject: " + playerName, entryHasChildren = true)
		ENTRY_T1 = menu.AddEntryItem(playerName, ENTRY_SUBJECT)
		
		if target2 && target2 != playerRef
			ENTRY_T2 = menu.AddEntryItem(target2Name, ENTRY_SUBJECT)
		endIf

		if target3 && target3 != playerRef && target3 != target2
			ENTRY_T3 = menu.AddEntryItem(target3Name, ENTRY_SUBJECT)
		endIf
	else
		ENTRY_SUBJECT = menu.AddEntryItem("Subject: " + playerName)
	endIf

	int ENTRY_BELLY1 = menu.AddEntryItem("View " + playerName + "'s' contents", entryHasChildren = true)
	AddPredContents(menu, ENTRY_BELLY1, playerRef)

	if target2 != PlayerRef
		int ENTRY_BELLY2 = menu.AddEntryItem("View " + target2Name + "'s' contents", entryHasChildren = true)
		AddPredContents(menu, ENTRY_BELLY2, target2)
	endIf

	if target3 != PlayerRef && target3 != target2
		int ENTRY_BELLY3 = menu.AddEntryItem("View " + target3Name + "'s' contents", entryHasChildren = true)
		AddPredContents(menu, ENTRY_BELLY3, target3)
	endIf

	int ENTRY_LOCUS = menu.AddEntryItem("Default Locus: " + GetLocusName(PlayerAlias.DefaultLocus), entryHasChildren = true)
	int[] ENTRY_LOCI = Utility.CreateIntArray(6)
	int locusIndex = 0
	while locusIndex < ENTRY_LOCI.length
		ENTRY_LOCI[locusIndex] = menu.AddEntryItem(GetLocusName(locusIndex), ENTRY_LOCUS)
		locusIndex += 1
	endWhile

	int ENTRY_PERKS = menu.AddEntryItem("Perks (" + Manager.GetPerkPoints(subject) + " perk points)", entryHasChildren = true)
	int ENTRY_PERK_PRED = menu.AddEntryItem("Pred Perks", ENTRY_PERKS)
	int ENTRY_PERK_PREY = menu.AddEntryItem("Prey Perks", ENTRY_PERKS)

	int ENTRY_TOGGLES = menu.AddEntryItem("Toggles")
	int ENTRY_LOOSE = menu.AddEntryItem(ToggleString("Loose item vore", LooseItemVore), ENTRY_TOGGLES)
	int ENTRY_REBIRTH = menu.AddEntryItem(ToggleString("Automatic rebirth", AutoRebirth), ENTRY_TOGGLES)
	int ENTRY_CROUCH = menu.AddEntryItem(ToggleString("Crouch Scat", Manager.CrouchScat), ENTRY_TOGGLES)
	int ENTRY_ESCAPE = menu.AddEntryItem(ToggleString("Anal Escape", Manager.AnalEscape), ENTRY_TOGGLES)
	int ENTRY_GENTLE = menu.AddEntryItem(ToggleString("Gentle Gas", GentleGas), ENTRY_TOGGLES)
	
	int ENTRY_TOINV = -100
	if PlayerRef.HasPerk(DigestItems_arr[2])
		ENTRY_TOINV = menu.AddEntryItem(ToggleString("Digest to Inventory", DigestToInventory), ENTRY_TOGGLES)
	endIf

	int ENTRY_HUNGRYBONES = -100
	if PlayerRef.HasPerk(RaiseDead)
		ENTRY_HUNGRYBONES = menu.AddEntryItem(ToggleString("Hungry Bones", EnableHungryBones), ENTRY_TOGGLES)
	endIf
	
	int ENTRY_CORDYCEPS = -100
	if PlayerRef.HasPerk(Cordyceps)
		ENTRY_CORDYCEPS = menu.AddEntryItem(ToggleString("Cordyceps", EnableCordyceps), ENTRY_TOGGLES)
	endIf
	
	int ENTRY_SLACCIDENTS = -100
	if DevourmentSexlab.instance().SLA != none
		ENTRY_SLACCIDENTS = menu.AddEntryItem(ToggleString("SLAccidents", SLAccidents), ENTRY_TOGGLES)
	endIf

	int ENTRY_COUNTER = -100
	if PlayerRef.HasPerk(CounterVore)
		ENTRY_COUNTER = menu.AddEntryItem(ToggleString("Counter-Vore", CounterVoreEnabled), ENTRY_TOGGLES)
	endIf

	int ENTRY_TEST1 = -100
	int ENTRY_TEST2 = -100
	if Manager.DEBUGGING
		ENTRY_TEST1 = menu.AddEntryItem("Overlay Test")
		ENTRY_TEST2 = menu.AddEntryItem("Name Test")
	endIf

	int ENTRY_FORTIS = -100
	if subject.HasPerk(DigestItems_arr[2])
		ENTRY_FORTIS = menu.AddEntryItem("Digest Items")
	endIf

	int ENTRY_VOMIT = menu.AddEntryItem("Regurgitate")
	int ENTRY_POOP = menu.AddEntryItem("Defecate")
	

	int ENTRY_SLEEP = -100
	if Manager.IsPrey(playerRef) && playerRef.HasPerk(Comfy) && Manager.RelativelySafe(playerRef)
		ENTRY_SLEEP = menu.AddEntryItem("Vore Sleep")
	endIf
	
	int ENTRY_EXIT = menu.AddEntryItem("Exit")
	
	bool exit = false
	while !exit
		menu.OpenMenu()
		int result = menu.GetResultInt()
		
		if result == ENTRY_EXIT || result < 0
			exit = true
	
		elseif result == ENTRY_T1
			subject = PlayerRef
			menu.SetPropertyIndexString("entryName", ENTRY_SUBJECT, "Subject: " + playerName)

		elseif result == ENTRY_T2
			subject = target2
			menu.SetPropertyIndexString("entryName", ENTRY_SUBJECT, "Subject: " + target2Name)

		elseif result == ENTRY_T3
			subject = target3
			menu.SetPropertyIndexString("entryName", ENTRY_SUBJECT, "Subject: " + target3Name)
		
		elseif ENTRY_LOCI.find(result) >= 0
			PlayerAlias.DefaultLocus = ENTRY_LOCI.find(result)
			menu.SetPropertyIndexString("entryName", ENTRY_LOCUS, "Default Locus: " + GetLocusName(PlayerAlias.DefaultLocus))

		elseif result == ENTRY_LOOSE
			LooseItemVore = !LooseItemVore
			menu.SetPropertyIndexString("entryName", ENTRY_LOOSE, ToggleString("Loose item vore", LooseItemVore))
	
		elseif result == ENTRY_REBIRTH
			AutoRebirth = !AutoRebirth
			menu.SetPropertyIndexString("entryName", ENTRY_REBIRTH, ToggleString("Automatic rebirth", AutoRebirth))

		elseif result == ENTRY_CROUCH
			Manager.CrouchScat = !Manager.CrouchScat
			menu.SetPropertyIndexString("entryName", ENTRY_CROUCH, ToggleString("Crouch Scat", Manager.CrouchScat))

		elseif result == ENTRY_ESCAPE
			Manager.AnalEscape = !Manager.AnalEscape
			menu.SetPropertyIndexString("entryName", ENTRY_ESCAPE, ToggleString("Anal Escape", Manager.AnalEscape))

		elseif result == ENTRY_GENTLE
			GentleGas = !GentleGas
			menu.SetPropertyIndexString("entryName", ENTRY_GENTLE, ToggleString("Gentle Gas", GentleGas))

		elseif result == ENTRY_TOINV
			DigestToInventory = !DigestToInventory
			menu.SetPropertyIndexString("entryName", ENTRY_TOINV, ToggleString("Digest To Inventory", DigestToInventory))

		elseif result == ENTRY_HUNGRYBONES
			EnableHungryBones = !EnableHungryBones
			menu.SetPropertyIndexString("entryName", ENTRY_HUNGRYBONES, ToggleString("Hungry Bones", EnableHungryBones))

		elseif result == ENTRY_SLACCIDENTS
			SLAccidents = !SLAccidents
			menu.SetPropertyIndexString("entryName", ENTRY_SLACCIDENTS, ToggleString("SLAccidents", SLAccidents))

		elseif result == ENTRY_COUNTER
			CounterVoreEnabled = !CounterVoreEnabled
			menu.SetPropertyIndexString("entryName", ENTRY_COUNTER, ToggleString("Counter-Vore", CounterVoreEnabled))

		elseif result == ENTRY_CORDYCEPS
			EnableCordyceps = !EnableCordyceps
			menu.SetPropertyIndexString("entryName", ENTRY_CORDYCEPS, ToggleString("Cordyceps", EnableCordyceps))

		elseif result == ENTRY_PERK_PRED
			if AltPerkMenus || subject != playerRef
				ShowPerkSubMenu(subject, true)
			else
				Manager.Devourment_ShowPredPerks.SetValue(1.0)
			endIf
			exit = true

		elseif result == ENTRY_PERK_PREY
			if AltPerkMenus || subject != playerRef
				ShowPerkSubMenu(subject, false)
			else
				Manager.Devourment_ShowPreyPerks.SetValue(1.0)
			endIf
			exit = true

		elseif result == ENTRY_VOMIT
			if LibFire.ActorIsFollower(subject)
				Power_Regurgitate.cast(subject, subject)
			else
				Power_Regurgitate.cast(PlayerRef, PlayerRef)
			endIf
			exit = true

		elseif result == ENTRY_FORTIS
			if LibFire.ActorIsFollower(subject)
				Power_DigestItems.cast(subject, subject)
			else
				Power_DigestItems.cast(PlayerRef, PlayerRef)
			endIf
			exit = true

		elseif result == ENTRY_POOP
			if LibFire.ActorIsFollower(subject)
				Power_Defecate.cast(subject, subject)
			else
				Power_Defecate.cast(PlayerRef, PlayerRef)
			endIf
			exit = true

		elseif result == ENTRY_SLEEP
			PlayerAlias.VoreSleep()
			exit = true

		elseif result == ENTRY_TEST1 
			PlayerAlias.ClearFaceOverlays(PlayerRef)
			exit = true

		elseif result == ENTRY_TEST2
			String name1 = subject.GetLeveledActorBase().GetName()
			String name2 = subject.GetActorBase().GetName()
			String name3 = subject.GetDisplayName()
			Debug.MessageBox("Levelled = '" + name1 + "', unlevelled = '" + name2 + "', display = '" + name3 + "'")
			exit = true

		endIf
	endWhile
EndFunction


Function AddPredContents(UIListMenu menu, int parentEntry, Actor pred)
	Form[] stomach = Manager.getStomachArray(pred) as Form[]
	if Manager.EmptyStomach(stomach)
		menu.AddEntryItem("(Nothing)", parentEntry)
	else
		int stomachIndex = 0
		while stomachIndex < stomach.length
			ObjectReference stomachItem = stomach[stomachIndex] as ObjectReference
			stomachIndex += 1

			int ENTRY_CONTENTS = menu.AddEntryItem(Namer(stomachItem, true), parentEntry, entryHasChildren = true)

			if stomachItem as Actor
				AddPreyDetails(menu, ENTRY_CONTENTS, stomachItem as Actor)
			else
				AddBolusContents(menu, ENTRY_CONTENTS, stomachItem)
			endIf
		endWhile
	endIf
EndFunction


Function AddBolusContents(UIListMenu menu, int parentEntry, ObjectReference bolus)
	Form[] bolusContents = bolus.GetContainerForms()
	if bolusContents.length > 0
		String description = Namer(bolusContents[0], !Manager.DEBUGGING)
	
		int bolusIndex = 0
		while bolusIndex < bolusContents.length
			Form item = bolusContents[bolusIndex]
			int count = bolus.GetItemCount(item)
			menu.AddEntryItem(NameWithCount(bolusContents[bolusIndex], count), parentEntry)
			bolusIndex += 1
		endWhile
	else
		menu.AddEntryItem("(EMPTY)", parentEntry)
	endIf
EndFunction


Function AddPreyDetails(UIListMenu menu, int parentEntry, Actor prey)
	menu.AddEntryItem("Name: " + Namer(prey, !Manager.DEBUGGING), parentEntry)
	menu.AddEntryItem("Level: " + prey.GetLevel(), parentEntry)
	menu.AddEntryItem("Pred skill: " + Manager.GetPredSkill(prey) as int, parentEntry)
	menu.AddEntryItem("Prey skill: " + Manager.GetPreySkill(prey) as int, parentEntry)
	
	int preyData = Manager.GetPreyData(prey)
	menu.AddEntryItem("Locus: " + GetLocusName(Manager.GetLocus(preyData)), parentEntry)

	if Manager.IsReforming(preyData)
		menu.AddEntryItem("Reforming: " + Manager.GetDigestionPercent(preyData) as int + "%", parentEntry)
	elseif Manager.IsDigesting(preyData)
		menu.AddEntryItem("Digesting: " + Manager.GetDigestionProgress(preyData) as int + "%", parentEntry)
	elseif Manager.IsDigested(preyData)
		menu.AddEntryItem("DIGESTED", parentEntry)
	elseif Manager.IsEndo(preyData)
		menu.AddEntryItem("Health: " + prey.GetActorValue("Health") as int + " / " + prey.GetBaseActorValue("Health") as int + " (" + prey.GetActorValuePercentage("Health") + "%)", parentEntry)
		menu.AddEntryItem("Non-lethal", parentEntry)
	elseif Manager.IsVore(preyData)
		menu.AddEntryItem("Health: " + prey.GetActorValue("Health") as int + " / " + prey.GetBaseActorValue("Health") as int + " (" + prey.GetActorValuePercentage("Health") + "%)", parentEntry)
		menu.AddEntryItem("Acid DPS: " + Manager.GetDPS(preyData) , parentEntry)
	endIf
EndFunction


bool Function ConflictCheck(String reference, String conflictControl, String conflictName)
{Taken from Nether's Follower Framework. }
	if !conflictControl || reference == conflictName
		return true
	endIf

	string myMsg

	if conflictName
		myMsg = "This key is already mapped to \"" + conflictControl + "\" (" + conflictName + ")\n\nContinue?"
	else
		myMsg = "This key is already mapped to \"" + conflictControl + "\"\n\nContinue?"
	endif

	return ShowMessage(myMsg, true)
endFunction


String Function NameWithCount(Form item, int count)
	if count == 1
		return Namer(item, !Manager.DEBUGGING)
	else
		return Namer(item, !Manager.DEBUGGING) + " (" + count + ")"
	endIf
endFunction


String Function GetLocusName(int locus)
	if locus == 0
		return "Swallow"
	elseif locus == 1
		return "Anal"
	elseif locus == 2
		return "Unbirth"
	elseif locus == 3
		return "Breast (left)"
	elseif locus == 4
		return "Breast (right)"
	elseif locus == 5
		if Manager.VEGAN_MODE
			return "DISABLED"
		else
			return "Cock"
		endIf
	else
		return "Unknown " + locus
	endIf
EndFunction


bool Function ShowPerkSubMenu(Actor subject, bool pred)
	if !subject
		return false
	elseif !subject.GetActorBase().IsUnique() 
		Debug.MessageBox(Namer(subject, true) + " is not a unique actor and cannot gain perks.")
		return false
	endIf

	int perkMap
	float skill
	
	if pred
		perkMap = JValue.readFromFile(PredPerkFile)
		skill = Manager.GetPredSkill(subject)
	else
		perkMap = JValue.readFromFile(PreyPerkFile)
		skill = Manager.GetPreySkill(subject)
	endIf
	
	if !AssertExists(PREFIX, "ShowPerkSubMenu", "perkMap", perkMap)
		return false
	endIf
	
	JValue.retain(perkMap, PREFIX)
	UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu

	bool exit = false
	while !exit
		int perkPoints = Manager.GetPerkPoints(subject)
		Perk[] perkList = new Perk[50]
		int perkIndex = 0

		menu.ResetMenu()
		String[] names = JArray.asStringArray(JArray.Sort(JMap.allKeys(perkMap)))
		int[] entries = Utility.createIntArray(names.length)

		int index = 0
		
		while index < names.length
			String name = names[index]
			int perkEntry = JMap.GetObj(perkMap, name)
			if AssertExists(PREFIX, "ShowPerkSubMenu", name, perkEntry)
				
				float requiredSkill = JMap.GetFlt(perkEntry, "Skill")
				Perk requiredPerk = JMap.GetForm(perkEntry, "Req") as Perk
				Perk thePerk = JMap.GetForm(perkEntry, "Perk") as Perk
				String description = JMap.GetStr(perkEntry, "Description")
				
				if skill >= requiredSkill && thePerk != none && !subject.HasPerk(thePerk) && (requiredPerk == none || subject.HasPerk(requiredPerk))
					perkList[perkIndex] = thePerk
					int ENTRY_PERK = menu.AddEntryItem(name, entryHasChildren = true)
					if description != ""
						menu.AddEntryItem(description, ENTRY_PERK)
					endIf
					if requiredSkill > 0.0
						menu.AddEntryItem("Require Skill: " + requiredSkill, ENTRY_PERK)
					endIf
					if perkPoints > 0
						entries[perkIndex] = menu.AddEntryItem("Add Perk", ENTRY_PERK)
					elseif Manager.DEBUGGING
						entries[perkIndex] = menu.AddEntryItem("Add Perk (DEBUGGING)", ENTRY_PERK)
					endIf
					perkIndex += 1
				endIf
			endIf
			
			index += 1
		endWhile
		
		int ENTRY_EXIT = menu.AddEntryItem("Exit")
		menu.OpenMenu()
		int result = menu.GetResultInt()
		int entryIndex = entries.find(result)

		if result < 0 || result == ENTRY_EXIT 
			exit = true
		elseif entryIndex >= 0 && perkList[entryIndex]
			if subject == PlayerRef
				subject.addPerk(perkList[entryIndex])
			else
				PO3_SKSEFunctions.AddBasePerk(subject, perkList[entryIndex])
			endIf

			if perkPoints > 0
				perkPoints = Manager.DecrementPerkPoints(subject)
			endIf

			if perkPoints <= 0 && !Manager.DEBUGGING
				exit = true
			endIf
		endIf
	endWhile
	
	JValue.release(perkMap)
	return true
EndFunction


Actor Function GetTarget()
	Actor target

	;target = Game.GetCurrentConsoleRef() as Actor
	;if target
	;	return target
	;endIf
	
	target = Game.GetCurrentCrosshairRef() as Actor
	if target
		return target
	endIf

	return PlayerRef
EndFunction


Function RecalculateLocusCumulative()
	LocusCumulative = Utility.CreateFloatArray(LocusChances.length)
	
	if Manager.VEGAN_MODE
		LocusChances[5] = 0.0
	endIf

	float sum = 0
	int locus = LocusChances.length

	while locus
		locus -= 1
		sum += LocusChances[locus]
		LocusCumulative[locus] = sum
	endWhile
EndFunction


state WeightPlayerState
	event OnSelectST()
		WeightManager.PlayerEnabled = !WeightManager.PlayerEnabled
		setToggleOptionValueST(WeightManager.PlayerEnabled)
		WeightManager.SyncSettings(true)
		resetActorWeights = true
	endEvent
	event OnDefaultST()
		WeightManager.PlayerEnabled = true
		setToggleOptionValueST(WeightManager.PlayerEnabled)
		WeightManager.SyncSettings(true)
		resetActorWeights = true
	endEvent
	event OnHighlightST()
		"Enables weight gain for the player."
	endEvent
endstate


state WeightCompanionState
	event OnSelectST()
		WeightManager.CompanionsEnabled = !WeightManager.CompanionsEnabled
		setToggleOptionValueST(WeightManager.CompanionsEnabled)
		WeightManager.SyncSettings(true)
		resetActorWeights = true
	endEvent
	event OnDefaultST()
		WeightManager.CompanionsEnabled = false
		setToggleOptionValueST(WeightManager.CompanionsEnabled)
		WeightManager.SyncSettings(true)
		resetActorWeights = true
	endEvent
	event OnHighlightST()
		"Enables weight gain for followers."
	endEvent
endstate


state WeightEveryoneState
	event OnSelectST()
		WeightManager.ActorsEnabled = !WeightManager.ActorsEnabled
		setToggleOptionValueST(WeightManager.ActorsEnabled)
		WeightManager.SyncSettings(true)
		resetActorWeights = true
	endEvent
	event OnDefaultST()
		WeightManager.ActorsEnabled = false
		setToggleOptionValueST(WeightManager.ActorsEnabled)
		WeightManager.SyncSettings(true)
		resetActorWeights = true
	endEvent
	event OnHighlightST()
		"Enables weight gain for unique NPCs that are not the player or a follower."
	endEvent
endstate


state WeightLossState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WeightManager.WeightLoss)
		SetSliderDialogDefaultValue(0.05)
		SetSliderDialogRange(0.0, 1.0)
		SetSliderDialogInterval(0.01)
	endEvent

	event OnSliderAcceptST(float a_value)
		WeightManager.WeightLoss = a_value
		SetSliderOptionValueST(a_value, "{2}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnDefaultST()
		WeightManager.WeightLoss = 0.05
		SetSliderOptionValueST(0.05, "{2}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnHighlightST()
		SetInfoText("How much weight loss occurs for each time interval while awake.\nCurrent settings will result in a weight loss of approximately " + WeightManager.GetLossPerDay() + " per day.")
	endEvent
endState


state WeightRateState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WeightManager.WeightRate)
		SetSliderDialogDefaultValue(4.0)
		SetSliderDialogRange(0.01, 24.0)
		SetSliderDialogInterval(0.01)
	endEvent

	event OnSliderAcceptST(float a_value)
		WeightManager.WeightRate = a_value
		SetSliderOptionValueST(a_value, "{2}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnDefaultST()
		WeightManager.WeightRate = 4.0
		SetSliderOptionValueST(4.0, "{2}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnHighlightST()
		SetInfoText("How often weight loss occurs (in hours).\nCurrent settings will result in a weight loss of approximately " + WeightManager.GetLossPerDay() + " per day.")
	endEvent
endState


state WeightMinState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WeightManager.MinimumWeight)
		SetSliderDialogDefaultValue(-1.0)
		SetSliderDialogRange(-10.0, WeightManager.MaximumWeight)
		SetSliderDialogInterval(0.05)
	endEvent

	event OnSliderAcceptST(float a_value)
		WeightManager.MinimumWeight = a_value
		SetSliderOptionValueST(a_value, "{2}")
		WeightManager.SyncSettings(true)
		resetActorWeights = true
	endEvent

	event OnDefaultST()
		WeightManager.MinimumWeight = -1.0
		SetSliderOptionValueST(-1.0, "{2}")
		WeightManager.SyncSettings(true)
		resetActorWeights = true
	endEvent

	event OnHighlightST()
		SetInfoText("Minimum value for weight.")
	endEvent
endState


state WeightMaxState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WeightManager.MaximumWeight)
		SetSliderDialogDefaultValue(2.0)
		SetSliderDialogRange(WeightManager.MinimumWeight, 10.0)
		SetSliderDialogInterval(0.05)
	endEvent

	event OnSliderAcceptST(float a_value)
		WeightManager.MaximumWeight = a_value
		SetSliderOptionValueST(a_value, "{2}")
		WeightManager.SyncSettings(true)
		resetActorWeights = true
	endEvent

	event OnDefaultST()
		WeightManager.MaximumWeight = 2.0
		SetSliderOptionValueST(2.0, "{2}")
		WeightManager.SyncSettings(true)
		resetActorWeights = true
	endEvent

	event OnHighlightST()
		SetInfoText("Maximum value for weight.")
	endEvent
endState


state WeightVoreBaseState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WeightManager.VoreBaseGain)
		SetSliderDialogDefaultValue(0.05)
		SetSliderDialogRange(0.0, 1.0)
		SetSliderDialogInterval(0.001)
	endEvent

	event OnSliderAcceptST(float a_value)
		WeightManager.VoreBaseGain = a_value
		SetSliderOptionValueST(a_value, "{3}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnDefaultST()
		WeightManager.VoreBaseGain = 0.05
		SetSliderOptionValueST(0.05, "{4}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnHighlightST()
		SetInfoText("Weight gain multiplier for vore digestion. This can be applied hundreds of times during a digestion, so keep the value low.\nCurrent settings will result in a weight gain of approximately " + WeightManager.GetGainPerHumanoid() + " per humanoid sized prey.")
	endEvent
endState


state WeightIngredientBaseState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WeightManager.IngredientBaseGain)
		SetSliderDialogDefaultValue(0.04)
		SetSliderDialogRange(0.0, 1.0)
		SetSliderDialogInterval(0.005)
	endEvent

	event OnSliderAcceptST(float a_value)
		WeightManager.IngredientBaseGain = a_value
		SetSliderOptionValueST(a_value, "{3}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnDefaultST()
		WeightManager.IngredientBaseGain = 0.04
		SetSliderOptionValueST(0.04, "{3}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnHighlightST()
		SetInfoText("Weight gain multiplier for ingredients.")
	endEvent
endState


state WeightPotionBaseState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WeightManager.PotionBaseGain)
		SetSliderDialogDefaultValue(0.02)
		SetSliderDialogRange(0.0, 1.0)
		SetSliderDialogInterval(0.005)
	endEvent

	event OnSliderAcceptST(float a_value)
		WeightManager.PotionBaseGain = a_value
		SetSliderOptionValueST(a_value, "{3}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnDefaultST()
		WeightManager.PotionBaseGain = 0.02
		SetSliderOptionValueST(0.02, "{3}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnHighlightST()
		SetInfoText("Weight gain multiplier for potions.")
	endEvent
endState


state WeightFoodBaseState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WeightManager.FoodBaseGain)
		SetSliderDialogDefaultValue(0.10)
		SetSliderDialogRange(0.0, 1.0)
		SetSliderDialogInterval(0.005)
	endEvent

	event OnSliderAcceptST(float a_value)
		WeightManager.FoodBaseGain = a_value
		SetSliderOptionValueST(a_value, "{3}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnDefaultST()
		WeightManager.FoodBaseGain = 0.10
		SetSliderOptionValueST(0.10, "{3}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnHighlightST()
		SetInfoText("Weight gain multiplier for food.")
	endEvent
endState


state WeightHighValMultState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WeightManager.HighValueMultiplier)
		SetSliderDialogDefaultValue(2.0)
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.05)
	endEvent

	event OnSliderAcceptST(float a_value)
		WeightManager.HighValueMultiplier = a_value
		SetSliderOptionValueST(a_value, "{2}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnDefaultST()
		WeightManager.HighValueMultiplier = 2.0
		SetSliderOptionValueST(2.0, "{2}")
		WeightManager.SyncSettings(true)
	endEvent

	event OnHighlightST()
		SetInfoText("Weight gain multiplier for high-value food.")
	endEvent
endState


state WeightPreviewState
	Event OnSliderOpenST()
		SetSliderDialogStartValue(0.0)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(WeightManager.MinimumWeight * 2.0, WeightManager.MaximumWeight * 2.0)
		SetSliderDialogInterval((WeightManager.MaximumWeight - WeightManager.MinimumWeight) / 100.0)
	endEvent

	event OnSliderAcceptST(float a_value)
		WeightManager.ChangeActorWeight(PlayerRef, 0.0, a_value)
		SetSliderOptionValueST(a_value, "{2}")
	endEvent

	event OnDefaultST()
		WeightManager.ChangeActorWeight(PlayerRef, 0.0, 0.0)
		SetSliderOptionValueST(0.0, "{2}")
	endEvent

	event OnHighlightST()
		SetInfoText("Preview a weight on the player. It will be reset the next time your weight updates, or if you set the preview back to the default value of 0.")
	endEvent
endState


state WeightLearnHighValueState
	event OnSelectST()
		if WeightManager.GetState() == "LearnHighValue"
			WeightManager.GotoState("DefaultState")
			setToggleOptionValueST(false)
			setToggleOptionValueST(false, false, "WeightLearnNoValueState")
		else
			WeightManager.GotoState("LearnHighValue")
			setToggleOptionValueST(true)
			setToggleOptionValueST(false, false, "WeightLearnNoValueState")
		endIf
	endEvent
	event OnDefaultST()
		WeightManager.GotoState("DefaultState")
		setToggleOptionValueST(false)
		setToggleOptionValueST(false, false, "WeightLearnNoValueState")
	endEvent
	event OnHighlightST()
		SetInfoText("The next thing that the player eats or drinks will be flagged as a 'High Value' food.")
	endEvent
endState


state WeightLearnNoValueState
	event OnSelectST()
		if WeightManager.GetState() == "LearnNoValue"
			WeightManager.GotoState("DefaultState")
			setToggleOptionValueST(false)
			setToggleOptionValueST(false, false, "WeightLearnHighValueState")
		else
			WeightManager.GotoState("LearnNoValue")
			setToggleOptionValueST(true)
			setToggleOptionValueST(false, false, "WeightLearnHighValueState")
		endIf
	endEvent
	event OnDefaultST()
		WeightManager.GotoState("DefaultState")
		setToggleOptionValueST(false)
		setToggleOptionValueST(false, false, "WeightLearnHighValueState")
	endEvent
	event OnHighlightST()
		SetInfoText("The next thing that the player eats or drinks will be flagged as a 'No Value' food.")
	endEvent
endState


state WeightAddMorphState
	event OnInputOpenST()
		SetInputDialogStartText("")
	endEvent

	event OnInputAcceptST(string a_input)
		WeightManager.AddMorph(a_input, 0.0, 0.0)
		ForcePageReset()
		resetActorWeights = true
	endEvent

	event OnHighlightST()
		SetInfoText("Add a weight morph.")
	endEvent
endState


