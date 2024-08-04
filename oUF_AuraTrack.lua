--[[
	# Element: AuraTrack

	Handles creation and updating of aura buttons on raid frames.

	## Widgets

	AuraTrack	- A Frame to hold `Button`s representing buffs.

	## Options

	.num			- Number of auras to display. Defaults to 4 (number)
	.spacing		- Spacing between each button. Defaults to 6 (number)
	.spells			- Table of spells to track. the table key is a spellID and value is a RGB color.
	.icons			- Use icon own textures, else use the a color specified in the spell table.
	.display		- Setup how icons are displayed inside the unit frame. Options: "INLINE" or "CORNER". Default: "INLINE"
	.onlyShowPlayer - Shows only auras created by player/vehicle (boolean)

	## Example

		-- Position and size
		local AuraTrack = CreateFrame("Frame", nil, self)
		AuraTrack:SetAllPoints()
		AuraTrack.icons = true
		AuraTrack.num = 4
		AuraTrack.spacing = 6
		AuraTrack.filter = "HELPFUL"
		AuraTrack.spells = {
			[139] = oUF:CreateColor(0.40, 0.70, 0.20), -- Renew
		}

		-- Register with oUF
		self.AuraTrack = AuraTrack
--]]

local _, ns = ...
local oUF = ns.oUF
assert(oUF, "oUF_AuraTrack as unable to locate oUF install.")

local _, class = UnitClass("player")

-- colors
local red = oUF:CreateColor(0.89, 0.10, 0.10)
local orange = oUF:CreateColor(0.89, 0.45, 0.00)
local gray = oUF:CreateColor(0.49, 0.60, 0.55)
local gray_dark = oUF:CreateColor(0.33, 0.37, 0.47)
local white = oUF:CreateColor(1.00, 1.00, 1.00)
local yellow = oUF:CreateColor(1.00, 1.00, 0.07)
local yellow_light = oUF:CreateColor(1.00, 1.00, 0.66)
local green = oUF:CreateColor(0.20, 0.80, 0.20)
local green_yellow = oUF:CreateColor(0.83, 1.00, 0.25)
local green_spring = oUF:CreateColor(0.05, 1.00, 0.50)
local pink = oUF:CreateColor(0.80, 0.40, 0.80)
local violet = oUF:CreateColor(0.70, 0.30, 0.70)
local purple = oUF:CreateColor(0.40, 0.20, 0.80)
local purple_light = oUF:CreateColor(0.54, 0.21, 0.78)
local blue = oUF:CreateColor(0.12, 0.56, 1.00)
local blue_mana = oUF:CreateColor(0.31, 0.45, 0.63)
local turquoise = oUF:CreateColor(0.20, 0.80, 0.80)
local aquamarine = oUF:CreateColor(0.17, 1.00, 0.75)
local brown = oUF:CreateColor(0.78, 0.61, 0.43)

-- spell table
local spells = {}

if oUF.isRetail then
	spells = {
		["DEMONHUNTER"] = {
			[196718] = purple, 	-- Darkness
		},
		["DEATHKNIGHT"] = {
			[145629] = purple, -- Anti-Magic Zone
		},
		["EVOKER"] = {
			[357170] = yellow, -- Time Dilation
			[364343] = yellow_light, -- Echo
			[373862] = orange, -- Temporal Anomally
			[363502] = green, -- Dream Flight
			[366155] = green_yellow, -- Reversion
			[382614] = blue, -- Dream Breath
		},
		["DRUID"] = {
			[774]    = pink, -- Rejuvenation
			[155777] = pink, -- Rejuvenation (Germination)
			[8936]   = green, -- Regrowth
			[48438]  = green_yellow, -- Wild Growth
			[33763]  = gray_dark, -- Lifebloom (Normal version)
			[188550] = gray_dark, -- Lifebloom (Legendary version)
			[29166]  = gray, -- Inervate
			[102342] = orange, -- Ironbark
			[102351] = green_spring, -- Cenarion Ward (Initial Buff)
			[102352] = green_spring, -- Cenarion Ward (HoT)
			[157982] = white, -- Tranquility
			[200389] = yellow_light, -- Cultivation
			[207386] = blue, -- Spring Blossoms
		},
		["HUNTER"] = {
			[136] = green, -- Mend Pet
			[272790] = red, -- Frenzy
		},
		["MAGE"] = {
			[11426] = blue, -- Ice Barrier (Mass Barrier)
		},
		["MONK"] = {
			[119611] = green, -- Renewing Mist
			[116849] = green_yellow, -- Life Cocoon
			[124682] = yellow_light, -- Enveloping Mist
		},
		["PALADIN"] = {
			[53563]  = violet, -- Beacon of Light
			[156910] = violet, -- Beacon of Faith
			[200025] = violet, -- Beacon of Virtue
			[1022]   = aquamarine,-- Blessing of Protection
			[388011] = blue, -- Blessing of Winter
			[1044]   = orange, -- Blessing of Freedom
			[388010] = orange, -- Blessing of Autumn
			[6940]   = red, -- Blessing of Sacrifice
			[204018] = red, -- Blessing of Spellwarding
			[388007] = yellow, -- Blessing of Summer
			[388013] = green, -- Blessing of Spring
			[287280] = green, -- Glimmer of Light (Artifact HoT)
			[395180] = green, -- Barrier of Faith
			[200654] = yellow_light, -- Tyr's Deliverance
		},
		["PRIEST"] = {
			[194384] = yellow_light, -- Atonement
			[214206] = yellow_light, -- Atonement (PvP)
			[41635]  = violet, -- Prayer of Mending
			[139]    = green, -- Renew
			[17]     = red, -- Power Word: Shield
			[47788]  = white, -- Guardian Spirit
			[33206]  = white, -- Pain Suppression
			[81782]  = yellow, -- Power World: Barrier
			[193065] = purple, -- Protective Light
			[10060]  = blue, -- Power Infusion
		},
		["ROGUE"] = {
			[57934] = yellow_light, -- Tricks of the Trade
		},
		["SHAMAN"] = {
			[974]   = orange, -- Earth Shield
			[61295] = violet, -- Riptide
			[98008] = green_yellow, -- Spirit Link Totem
		},
		["WARLOCK"] = {
			[193396] = purple, -- Demonic Empowerment
		},
		["WARRIOR"] = {
			[3411]	 = yellow, -- Intervene
			[97462]	 = brown, -- Rallying Cry
			[114030] = red, -- Vigilance
		}
	}
elseif oUF.isCata then
	spells = {
		["DEATHKNIGHT"] = {
			[57330]	= gray, -- Horn of Winter
		},
		["DRUID"] = {
			[774]	 = pink, -- Rejuvenation
			[8936]	 = green, -- Regrowth
			[33763]  = gray_dark, -- Lifebloom
			[48438]  = green_yellow, -- Wild Growth
			[157982] = white, -- Tranquility
		},
		["HUNTER"] = {
			[24604]	= red, -- Furious Howl
			[34477]	= blue, -- Misdirection
		},
		["PALADIN"] = {
			[138]   = green_spring, -- Hand of Salvation
			[1022]  = aquamarine, -- Hand of Protection
			[1044]  = orange, -- Hand of Freedom
			[6940]  = red, -- Hand of Sacrifice
			[31821] = yellow, -- Aura Mastery
			[53563] = violet, -- Beacon of Light
			[70940] = purple, -- Divine Guardian
			[82327] = yellow_light, -- Holy Radiance
			[86273] = turquoise, -- Illuminated Healing
		},
		["PRIEST"] = {
			[17]	= red, -- Power Word Shield
			[139]	= green, -- Renew
			[6346]	= orange, -- Fear Ward
			[10060] = blue, -- Power Infusion
			[33076]	= violet, -- Prayer of Mending
			[33206] = white, -- Pain Suppression
			[47788]	= white, -- Guardian Spirit
			[62618] = yellow, -- Power World: Barrier
			[64844] = yellow_light, -- Divine Hymn
			[64904] = turquoise, -- Hymn of Hope
			[47930] = green_yellow, -- Grace (Rank 1)
			[77613] = green_yellow, -- Grace (Rank 2)
		},
		["ROGUE"] = {
			[57934] = yellow_light, -- Tricks of the Trade
		},
		["SHAMAN"] = {
			[974]	= orange, -- Earth Shield
			[61295] = violet, -- Riptide
			[98008]	= green_yellow,	-- Spirit Link Totem
		},
		["WARRIOR"] = {
			[469]  = purple,	-- Commanding Shout
			[6673] = gray,		-- Battle Shout
		}
	}
else
	spells = {
		["DEATHKNIGHT"] = {
			[57330] = oUF.isWrath and gray or nil, -- Horn of Winter
		},
		["DRUID"] = {
			[1126]	= turquoise, -- Mark of the Wild (Rank 1)
			[5232]	= turquoise, -- Mark of the Wild (Rank 2)
			[6756]	= turquoise, -- Mark of the Wild (Rank 3)
			[5234]	= turquoise, -- Mark of the Wild (Rank 4)
			[8907]	= turquoise, -- Mark of the Wild (Rank 5)
			[9884]	= turquoise, -- Mark of the Wild (Rank 6)
			[9885]	= turquoise, -- Mark of the Wild (Rank 7)
			[26990]	= turquoise, -- Mark of the Wild (Rank 8)
			[48469]	= turquoise, -- Mark of the Wild (Rank 9)
			[21849]	= turquoise, -- Gift of the Wild (Rank 1)
			[21850]	= turquoise, -- Gift of the Wild (Rank 2)
			[26991]	= turquoise, -- Gift of the Wild (Rank 3)
			[48470]	= turquoise, -- Gift of the Wild (Rank 4)

			[467]	= brown, -- Thorns (Rank 1)
			[782]	= brown, -- Thorns (Rank 2)
			[1075]	= brown, -- Thorns (Rank 3)
			[8914]	= brown, -- Thorns (Rank 4)
			[9756]	= brown, -- Thorns (Rank 5)
			[9910]	= brown, -- Thorns (Rank 6)
			[26992]	= brown, -- Thorns (Rank 7)
			[53307]	= brown, -- Thorns (Rank 8)

			[774]	= pink, -- Rejuvenation (Rank 1)
			[1058]	= pink, -- Rejuvenation (Rank 2)
			[1430]	= pink, -- Rejuvenation (Rank 3)
			[2090]	= pink, -- Rejuvenation (Rank 4)
			[2091]	= pink, -- Rejuvenation (Rank 5)
			[3627]	= pink, -- Rejuvenation (Rank 6)
			[8910]	= pink, -- Rejuvenation (Rank 7)
			[9839]	= pink, -- Rejuvenation (Rank 8)
			[9840]	= pink, -- Rejuvenation (Rank 9)
			[9841]	= pink, -- Rejuvenation (Rank 10)
			[25299]	= pink, -- Rejuvenation (Rank 11)
			[26981]	= pink, -- Rejuvenation (Rank 12)
			[26982]	= pink, -- Rejuvenation (Rank 13)
			[48440]	= pink, -- Rejuvenation (Rank 14)
			[48441]	= pink, -- Rejuvenation (Rank 15)

			[8936]	= green, -- Regrowth (Rank 1)
			[8938]	= green, -- Regrowth (Rank 2)
			[8939]	= green, -- Regrowth (Rank 3)
			[8940]	= green, -- Regrowth (Rank 4)
			[8941]	= green, -- Regrowth (Rank 5)
			[9750]	= green, -- Regrowth (Rank 6)
			[9856]	= green, -- Regrowth (Rank 7)
			[9857]	= green, -- Regrowth (Rank 8)
			[9858]	= green, -- Regrowth (Rank 9)
			[26980]	= green, -- Regrowth (Rank 10)
			[48442]	= green, -- Regrowth (Rank 11)
			[48443]	= green, -- Regrowth (Rank 12)

			[29166]	= gray, -- Innervate
			
			[33763]	= gray_dark, -- Lifebloom (Rank 1)
			[48450]	= gray_dark, -- Lifebloom (Rank 2)
			[48451]	= gray_dark, -- Lifebloom (Rank 3)
		},
		["HUNTER"] = {
			[19506]	= orange, -- Trueshot Aura (Rank 1)
			[20905]	= orange, -- Trueshot Aura (Rank 2)
			[20906]	= orange, -- Trueshot Aura (Rank 3)
			[27066]	= orange, -- Trueshot Aura (Rank 4)

			[13159]	= blue, -- Aspect of the Pack

			[20043]	= aquamarine, -- Aspect of the Wild (Rank 1)
			[20190]	= aquamarine, -- Aspect of the Wild (Rank 2)
			[27045]	= aquamarine, -- Aspect of the Wild (Rank 3)

			[24604]	= red, -- Furious Howl (Rank 1)
			[24605]	= red, -- Furious Howl (Rank 2)
			[24603]	= red, -- Furious Howl (Rank 3)
			[24597]	= red, -- Furious Howl (Rank 4)
			[64494]	= red, -- Furious Howl (Rank 5)
			[64495]	= red, -- Furious Howl (Rank 6)
		},
		["MAGE"] = {
			[1459]	= blue_mana, -- Arcane Intellect (Rank 1)
			[1460]	= blue_mana, -- Arcane Intellect (Rank 2)
			[1461]	= blue_mana, -- Arcane Intellect (Rank 3)
			[10156] = blue_mana, -- Arcane Intellect (Rank 4)
			[10157] = blue_mana, -- Arcane Intellect (Rank 5)
			[27126] = blue_mana, -- Arcane Intellect (Rank 6)
			[23028] = blue_mana, -- Arcane Brilliance (Rank 1)
			[27127] = blue_mana, -- Arcane Brilliance (Rank 2)

			[604]	= green_spring, -- Dampen Magic (Rank 1)
			[8450]	= green_spring, -- Dampen Magic (Rank 2)
			[8451]	= green_spring, -- Dampen Magic (Rank 3)
			[10173] = green_spring, -- Dampen Magic (Rank 4)
			[10174] = green_spring, -- Dampen Magic (Rank 5)
			[33944] = green_spring, -- Dampen Magic (Rank 6)

			[1008]	= aquamarine, -- Amplify Magic (Rank 1)
			[8455]	= aquamarine, -- Amplify Magic (Rank 2)
			[10169] = aquamarine, -- Amplify Magic (Rank 3)
			[10170] = aquamarine, -- Amplify Magic (Rank 4)
			[27130] = aquamarine, -- Amplify Magic (Rank 5)
			[33946] = aquamarine, -- Amplify Magic (Rank 6)

			[130]	= white, -- Slow Fall
		},
		["PALADIN"] = {
			[1044]	= orange, -- Blessing of Freedom

			[6940]	= red, -- Blessing Sacrifice (Rank 1)
			[20729]	= red, -- Blessing Sacrifice (Rank 2)
			[27147]	= red, -- Blessing Sacrifice (Rank 3)
			[27148]	= red, -- Blessing Sacrifice (Rank 4)

			[19740]	= violet, -- Blessing of Might (Rank 1)
			[19834]	= violet, -- Blessing of Might (Rank 2)
			[19835]	= violet, -- Blessing of Might (Rank 3)
			[19836]	= violet, -- Blessing of Might (Rank 4)
			[19837]	= violet, -- Blessing of Might (Rank 5)
			[19838]	= violet, -- Blessing of Might (Rank 6)
			[25291]	= violet, -- Blessing of Might (Rank 7)
			[27140]	= violet, -- Blessing of Might (Rank 8)
			[25782]	= violet, -- Greater Blessing of Might (Rank 1)
			[25916]	= violet, -- Greater Blessing of Might (Rank 2)
			[27141]	= violet, -- Greater Blessing of Might (Rank 3)

			[19742]	= blue, -- Blessing of Wisdom (Rank 1)
			[19850]	= blue, -- Blessing of Wisdom (Rank 2)
			[19852]	= blue, -- Blessing of Wisdom (Rank 3)
			[19853]	= blue, -- Blessing of Wisdom (Rank 4)
			[19854]	= blue, -- Blessing of Wisdom (Rank 5)
			[25290]	= blue, -- Blessing of Wisdom (Rank 6)
			[27142]	= blue, -- Blessing of Wisdom (Rank 7)
			[25894]	= blue, -- Greater Blessing of Wisdom (Rank 1)
			[25918]	= blue, -- Greater Blessing of Wisdom (Rank 2)
			[27143]	= blue, -- Greater Blessing of Wisdom (Rank 3)

			[465]	= purple, -- Devotion Aura (Rank 1)
			[10290]	= purple, -- Devotion Aura (Rank 2)
			[643]	= purple, -- Devotion Aura (Rank 3)
			[10291]	= purple, -- Devotion Aura (Rank 4)
			[1032]	= purple, -- Devotion Aura (Rank 5)
			[10292]	= purple, -- Devotion Aura (Rank 6)
			[10293]	= purple, -- Devotion Aura (Rank 7)
			[27149]	= purple, -- Devotion Aura (Rank 8)

			[19977]	= yellow_light, -- Blessing of Light (Rank 1)
			[19978]	= yellow_light, -- Blessing of Light (Rank 2)
			[19979]	= yellow_light, -- Blessing of Light (Rank 3)
			[27144]	= yellow_light, -- Blessing of Light (Rank 4)

			[1022] 	= aquamarine, -- Blessing of Protection (Rank 1)
			[5599] 	= aquamarine, -- Blessing of Protection (Rank 2)
			[10278]	= aquamarine, -- Blessing of Protection (Rank 3)

			-- [19746]	= concentration_aura, -- Concentration Aura
			-- [32223]	= crusader_aura, -- Crusader Aura

			[28790]	= yellow, -- Holy Power (armor)
			[28791]	= yellow, -- Holy Power (attack power)
			[28793]	= yellow, -- Holy Power (spell damage)
			[28795]	= yellow, -- Holy Power (mana regeneration)
		},
		["PRIEST"] = {
			[1243]	= white, -- Power Word: Fortitude (Rank 1)
			[1244] 	= white, -- Power Word: Fortitude (Rank 2)
			[1245] 	= white, -- Power Word: Fortitude (Rank 3)
			[2791] 	= white, -- Power Word: Fortitude (Rank 4)
			[10937]	= white, -- Power Word: Fortitude (Rank 5)
			[10938]	= white, -- Power Word: Fortitude (Rank 6)
			[25389]	= white, -- Power Word: Fortitude (Rank 7)
			[48161]	= white,	-- Power Word: Fortitude (Rank 8)
			[21562]	= white, -- Prayer of Fortitude (Rank 1)
			[21564]	= white, -- Prayer of Fortitude (Rank 2)
			[25392]	= white, -- Prayer of Fortitude (Rank 3)
			[48162]	= white, -- Prayer of Fortitude (Rank 4)

			[14752]	= yellow_light, -- Divine Spirit (Rank 1)
			[14818]	= yellow_light, -- Divine Spirit (Rank 2)
			[14819]	= yellow_light, -- Divine Spirit (Rank 3)
			[27841]	= yellow_light, -- Divine Spirit (Rank 4)
			[25312]	= yellow_light, -- Divine Spirit (Rank 5)
			[48073]	= yellow_light, -- Divine Spirit (Rank 6)
			[27681]	= yellow_light, -- Prayer of Spirit (Rank 1)
			[32999]	= yellow_light, -- Prayer of Spirit (Rank 2)
			[48074]	= yellow_light, -- Prayer of Spirit (Rank 3)

			[976]	= purple, -- Shadow Protection (Rank 1)
			[10957]	= purple, -- Shadow Protection (Rank 2)
			[10958]	= purple, -- Shadow Protection (Rank 3)
			[25433]	= purple, -- Shadow Protection (Rank 4)
			[48169]	= purple, -- Shadow Protection (Rank 5)
			[27683]	= purple, -- Prayer of Shadow Protection (Rank 1)
			[39374]	= purple, -- Prayer of Shadow Protection (Rank 2)
			[48170]	= purple, -- Prayer of Shadow Protection (Rank 3)

			[17]	= red, -- Power Word: Shield (Rank 1)
			[592]	= red, -- Power Word: Shield (Rank 2)
			[600]	= red, -- Power Word: Shield (Rank 3)
			[3747]	= red, -- Power Word: Shield (Rank 4)
			[6065]	= red, -- Power Word: Shield (Rank 5)
			[6066]	= red, -- Power Word: Shield (Rank 6)
			[10898]	= red, -- Power Word: Shield (Rank 7)
			[10899]	= red, -- Power Word: Shield (Rank 8)
			[10900]	= red, -- Power Word: Shield (Rank 9)
			[10901]	= red, -- Power Word: Shield (Rank 10)
			[25217]	= red, -- Power Word: Shield (Rank 11)
			[25218]	= red, -- Power Word: Shield (Rank 12)
			[48065]	= red, -- Power Word: Shield (Rank 13)
			[48066]	= red, -- Power Word: Shield (Rank 14)
			
			[139]	= green, -- Renew (Rank 1)
			[6074]	= green, -- Renew (Rank 2)
			[6075]	= green, -- Renew (Rank 3)
			[6076]	= green, -- Renew (Rank 4)
			[6077]	= green, -- Renew (Rank 5)
			[6078]	= green, -- Renew (Rank 6)
			[10927]	= green, -- Renew (Rank 7)
			[10928]	= green, -- Renew (Rank 8)
			[10929]	= green, -- Renew (Rank 9)
			[25315]	= green, -- Renew (Rank 10)
			[25221]	= green, -- Renew (Rank 11)
			[25222]	= green, -- Renew (Rank 12)
			[48067]	= green, -- Renew (Rank 13)
			[48068]	= green, -- Renew (Rank 14)
		},
		["SHAMAN"] = {
			[974]  	= orange, 		-- Earth Shield (Rank 1)
			[32593]	= orange, 		-- Earth Shield (Rank 2)
			[32594]	= orange, 		-- Earth Shield (Rank 3)

			[30708]	= red,			-- Totem of Wrath (Rank 1)
			
			[29203]	= blue_mana,	-- Healing Way

			[16237]	= blue,			-- Ancestral Fortitude

			[25909]	= tranquil_air, -- Tranquil Air

			[8185] 	= red,	-- Fire Resistance Totem (Rank 1)
			[10534]	= red,	-- Fire Resistance Totem (Rank 2)
			[10535]	= red,	-- Fire Resistance Totem (Rank 3)
			[25562]	= red,	-- Fire Resistance Totem (Rank 4)

			[8182] 	= blue_mana,	-- Frost Resistance Totem (Rank 1)
			[10476]	= blue_mana,	-- Frost Resistance Totem (Rank 2)
			[10477]	= blue_mana,	-- Frost Resistance Totem (Rank 3)
			[25559]	= blue_mana,	-- Frost Resistance Totem (Rank 4)

			[10596]	= nature_totem, -- Nature Resistance Totem (Rank 1)
			[10598]	= nature_totem, -- Nature Resistance Totem (Rank 2)
			[10599]	= nature_totem, -- Nature Resistance Totem (Rank 3)
			[25573]	= nature_totem, -- Nature Resistance Totem (Rank 4)

			[5672] 	= turquoise, -- Healing Stream Totem (Rank 1)
			[6371] 	= turquoise, -- Healing Stream Totem (Rank 2)
			[6372] 	= turquoise, -- Healing Stream Totem (Rank 3)
			[10460]	= turquoise, -- Healing Stream Totem (Rank 4)
			[10461]	= turquoise, -- Healing Stream Totem (Rank 5)
			[25566]	= turquoise, -- Healing Stream Totem (Rank 6)

			[5677] 	= aquamarine, -- Mana Spring Totem (Rank 1)
			[10491]	= aquamarine, -- Mana Spring Totem (Rank 2)
			[10493]	= aquamarine, -- Mana Spring Totem (Rank 3)
			[10494]	= aquamarine, -- Mana Spring Totem (Rank 4)
			[25569]	= aquamarine, -- Mana Spring Totem (Rank 5)

			[8072] 	= green_yellow, -- Stoneskin Totem (Rank 1)
			[8156] 	= green_yellow, -- Stoneskin Totem (Rank 2)
			[8157] 	= green_yellow, -- Stoneskin Totem (Rank 3)
			[10403]	= green_yellow, -- Stoneskin Totem (Rank 4)
			[10404]	= green_yellow, -- Stoneskin Totem (Rank 5)
			[10405]	= green_yellow, -- Stoneskin Totem (Rank 6)
			[25506]	= green_yellow, -- Stoneskin Totem (Rank 7)
			[25507]	= green_yellow, -- Stoneskin Totem (Rank 8)

			[8076] 	= brown, -- Strength of Earth Totem (Rank 1)
			[8162] 	= brown, -- Strength of Earth Totem (Rank 2)
			[8163] 	= brown, -- Strength of Earth Totem (Rank 3)
			[10441]	= brown, -- Strength of Earth Totem (Rank 4)
			[25362]	= brown, -- Strength of Earth Totem (Rank 5)
			[25527]	= brown, -- Strength of Earth Totem (Rank 6)

			[8836] 	= green_spring, -- Grace of Air Totem (Rank 1)
			[10626]	= green_spring, -- Grace of Air Totem (Rank 2)
			[25360]	= green_spring, -- Grace of Air Totem (Rank 3)
			[2895] 	= green_spring, -- Wrath of Air Totem (Rank 1)
		},
		["WARLOCK"] = {
			[5597] 	= green_spring, -- Unending Breath

			[6307] 	= red, -- Blood Pact (Rank 1)
			[7804] 	= red, -- Blood Pact (Rank 2)
			[7805] 	= red, -- Blood Pact (Rank 3)
			[11766]	= red, -- Blood Pact (Rank 4)
			[11767]	= red, -- Blood Pact (Rank 5)

			[132] 	= aquamarine, -- Detect Lesser Invisibility (Classic) / Detect Invisibility
			[2970] 	= aquamarine, -- Detect Invisibility
			[11743]	= aquamarine, -- Detect Greater Invisibility
			[19480]	= aquamarine, -- Paranoia
		},
		["WARRIOR"] = {
			[469]  	= purple, -- Commanding Shout

			[6673] 	= gray, -- Battle Shout (Rank 1)
			[5242] 	= gray, -- Battle Shout (Rank 2)
			[6192] 	= gray, -- Battle Shout (Rank 3)
			[11549]	= gray, -- Battle Shout (Rank 4)
			[11550]	= gray, -- Battle Shout (Rank 5)
			[11551]	= gray, -- Battle Shout (Rank 6)
			[25289]	= gray, -- Battle Shout (Rank 7)
			[2048] 	= gray, -- Battle Shout (Rank 8)
		}
	}

	--------------------------------------------------
	-- Season of Discovery (Phase 1 - Max Level 25)
	--------------------------------------------------
	if oUF.isClassic then
		-- DRUID
		spells["DRUID"][408120] = wild_growth -- Wild Growth
		spells["DRUID"][408124] = gray_dark -- Lifebloom
		spells["DRUID"][414680] = purple -- Living Seed

		-- MAGE
		spells["MAGE"][400735] = violet -- Temporal Beacon
		spells["MAGE"][401417] = green -- Regeneration
		spells["MAGE"][412510] = green_yellow -- Mass Regeneration
		
		-- PALADIN
		spells["PALADIN"][407613] = violet -- Beacon of Light

		-- PRIEST
		spells["PRIEST"][401877] = violet -- Prayer of Mending
		
		-- SHAMAN
		spells["SHAMAN"][408514] = orange -- Earth Shield
		spells["SHAMAN"][415236] = aquamarine -- Healing Rain
	end
end

local function CreateButton(element, index)
	local button = CreateFrame("Button", element:GetDebugName() .. "Button" .. index, element)

	local backdrop = button:CreateTexture(nil, "BACKGROUND")
	backdrop:SetPoint("TOPLEFT", button, -1, 1)
	backdrop:SetPoint("BOTTOMRIGHT", button, 1, -1)
	
	local cd = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
	cd:SetAllPoints()
	cd:SetReverse(true)
	cd:SetHideCountdownNumbers(true)
	
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	local countFrame = CreateFrame("Frame", nil, button)
	countFrame:SetAllPoints(button)
	countFrame:SetFrameLevel(cd:GetFrameLevel() + 1)
	
	local count = countFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	count:SetPoint("BOTTOMRIGHT", countFrame, "BOTTOMRIGHT", -1, 0)
	
	button.Backdrop = backdrop
	button.Cooldown = cd
	button.Icon = icon
	button.Count = count

	--[[ Callback: AuraTrack:PostCreateButton(button)
	Called after a new aura button has been created.

	* self   - the widget holding the aura buttons
	* button - the newly created aura button (Button)
	--]]
	if (element.PostCreateButton) then
		element:PostCreateButton(button)
	end

	return button
end

local function SetPosition(element, from, to)
	local display = element.display or "INLINE"
	local size = element.size or 16
	local spacing = element.spacing or 6

	local positions = {
		[1] = "TOPLEFT",
		[2] = "TOPRIGHT",
		[3] = "BOTTOMLEFT",
		[4] = "BOTTOMRIGHT"
	}

	for i = from, to do
		local button = element[i]
		if (not button) then break end

		if (display == "CORNER") then
			local j = ((i - 1) % 4) + 1
			local pos = positions[j]
			local x = pos:match("LEFT") and 3 or -3
			local y = pos:match("TOP") and -3 or 3

			button:ClearAllPoints()
			button:SetPoint(pos, x, y)
		else
			local x = (i * size) - (size) + (i * spacing)
			local y = (size / 3)

			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", x, y)
		end
	end
end

local function Update(element, unit, data, position)
	if (not data.name) then return end

	local button = element[position]
	if (not button) then
		--[[ Override: Auras:CreateButton(position)
		Used to create an aura button at a given position.

		* self     - the widget holding the aura buttons
		* position - the position at which the aura button is to be created (number)

		## Returns

		* button - the button used to represent the aura (Button)
		--]]
		button = (element.CreateButton or CreateButton)(element, position)

		table.insert(element, button)
		element.createdButtons = element.createdButtons + 1
	end

	local color = element.spells[data.spellId] or oUF:CreateColor(1, 1, 1)

	-- for tooltips
	button.auraInstanceID = data.auraInstanceID
	button.isHarmful = data.isHarmful

	if (button.Backdrop) then
		local mu = 0.15
		button.Backdrop:SetColorTexture(color.r * mu, color.g * mu, color.b * mu)
	end

	if (button.Cooldown and not element.disableCooldown) then
		if (data.duration > 0) then
			button.Cooldown:SetCooldown(data.expirationTime - data.duration, data.duration, data.timeMod)
			button.Cooldown:Show()
		else
			button.Cooldown:Hide()
		end
	end

	if (button.Icon) then
		if (element.icons) then
			button.Icon:SetTexture(data.icon)
		else
			button.Icon:SetColorTexture(color.r, color.g, color.b)
		end
	end

	if (button.Count) then
		button.Count:SetText(data.applications > 1 and data.applications or '')
	end

	local size = element.size or 16
	button:SetSize(size, size)
	button:EnableMouse(false)
	button:Show()

	--[[ Callback: AuraTrack:PostUpdateButton(unit, button, data, position)
	Called after the aura button has been updated.

	* self     - the widget holding the aura buttons
	* button   - the updated aura button (Button)
	* unit     - the unit for which the update has been triggered (string)
	* data     - the [UnitAuraInfo](https://wowpedia.fandom.com/wiki/Struct_UnitAuraInfo) object (table)
	* position - the actual position of the aura button (number)
	--]]
	if (element.PostUpdateButton) then
		element:PostUpdateButton(button, unit, data, position)
	end
end

local function FilterAura(element, unit, data)
	return data.isPlayerAura and (element.spells[data.spellId] ~= nil)
end

local function SortAuras(a, b)
	if (a.isPlayerAura ~= b.isPlayerAura) then
		return a.isPlayerAura
	end

	if (a.canApplyAura ~= b.canApplyAura) then
		return a.canApplyAura
	end

	return a.auraInstanceID < b.auraInstanceID
end

local function ProcessData(element, unit, data)
	if (not data) then return end

	data.isPlayerAura = data.sourceUnit and (UnitIsUnit("player", data.sourceUnit) or UnitIsOwnerOrControllerOfUnit("player", data.sourceUnit))

	--[[ Callback: AuraTrack:PostProcessAuraData(unit, data)
	Called after the aura data has been processed.

	* self - the widget holding the aura buttons
	* unit - the unit for which the update has been triggered (string)
	* data - [UnitAuraInfo](https://wowpedia.fandom.com/wiki/Struct_UnitAuraInfo) object (table)

	## Returns

	* data - the processed aura data (table)
	--]]
	if (element.PostProcessAuraData) then
		data = element:PostProcessAuraData(unit, data)
	end

	return data
end

local function UpdateAuras(self, event, unit, info)
	if (self.unit ~= unit) then return end

	local isFullUpdate = (not info) or info.isFullUpdate

	local element = self.AuraTrack
	if (not element) then return end

	element.num = element.num or 4
	element.spacing = element.spacing or 6
	element.size = (element:GetWidth() / element.num) - (element.spacing) - (element.spacing / (element.num))
	element.filter = "HELPFUL"
	if (element.onlyShowPlayer) then
		element.filter = element.filter .. "|PLAYER"
	end

	if (element.PreUpdate) then
		element:PreUpdate(unit, isFullUpdate)
	end

	local changed = false

	if (isFullUpdate) then
		element.all = table.wipe(element.all or {})
		element.active = table.wipe(element.active or {})
		changed = true

		local slots = { C_UnitAuras.GetAuraSlots(unit, element.filter) }
		for i = 2, #slots do
			local data = ProcessData(element, unit, C_UnitAuras.GetAuraDataBySlot(unit, slots[i]))
			element.all[data.auraInstanceID] = data

			if ((element.FilterAura or FilterAura)(element, unit, data)) then
				element.active[data.auraInstanceID] = true
			end
		end
	else
		if (info.addedAuras) then
			for _, data in next, info.addedAuras do
				if(data.isHelpful and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, element.filter)) then
					element.all[data.auraInstanceID] = ProcessData(element, unit, data)

					if ((element.FilterAura or FilterAura)(element, unit, data)) then
						element.active[data.auraInstanceID] = true
						changed = true
					end
				end
			end
		end

		if (info.updatedAuraInstanceIDs) then
			for _, auraInstanceID in next, info.updatedAuraInstanceIDs do
				if(element.all[auraInstanceID]) then
					element.all[auraInstanceID] = ProcessData(element, unit, C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID))

					if (element.active[auraInstanceID]) then
						element.active[auraInstanceID] = true
						changed = true
					end
				end
			end
		end

		if (info.removedAuraInstanceIDs) then
			for _, auraInstanceID in next, info.removedAuraInstanceIDs do
				if(element.all[auraInstanceID]) then
					element.all[auraInstanceID] = nil

					if(element.active[auraInstanceID]) then
						element.active[auraInstanceID] = nil
						changed = true
					end
				end
			end
		end
	end

	if (element.PostUpdateInfo) then
		element:PostUpdateInfo(unit, changed)
	end

	if (changed) then
		element.sorted = table.wipe(element.sorted or {})

		for auraInstanceID in next, element.active do
			table.insert(element.sorted, element.all[auraInstanceID])
		end

		table.sort(element.sorted, element.SortBuffs or element.SortAuras or SortAuras)

		local numVisible = math.min(element.num, #element.sorted)

		for i = 1, numVisible do
			Update(element, unit, element.sorted[i], i)
		end

		local visibleChanged = false

		if (numVisible ~= element.visibleButtons) then
			element.visibleButtons = numVisible
			visibleChanged = element.reanchorIfVisibleChanged
		end

		for i = numVisible + 1, #element do
			element[i]:Hide()
		end

		if (visibleChanged or element.createdButtons > element.anchoredButtons) then
			if (visibleChanged) then
				(element.SetPosition or SetPosition) (element, 1, numVisible)
			else
				(element.SetPosition or SetPosition) (element, element.anchoredButtons + 1, element.createdButtons)
				element.anchoredButtons = element.createdButtons
			end
		end

		if (element.PostUpdate) then
			element:PostUpdate(unit)
		end
	end
end

local function Path(self, ...)
	return (self.AuraTrack.Override or UpdateAuras)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.AuraTrack
	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		element.createdButtons = element.createdButtons or 0
		element.anchoredButtons = 0
		element.visibleButtons = 0
		element.onlyShowPlayer = (type(element.onlyShowPlayer) == "boolean" and element.onlyShowPlayer) or (type(element.onlyShowPlayer) ~= "boolean" and true)
		element.spells = element.spells or spells[class] or {}
		element.icons = element.icons or false

		self:RegisterEvent("UNIT_AURA", Path)

		return true
	end
end

local function Disable(self)
	if (self.AuraTrack) then
		self:UnregisterEvent("UNIT_AURA", Path)
	end
end

oUF:AddElement("AuraTrack", Path, Enable, Disable)
