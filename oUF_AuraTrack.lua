--[[
	# Element: AuraTrack

	Handles creation and updating of aura buttons on raid frames.

	## Widgets

	AuraTrack	- A Frame to hold `Button`s representing buffs.

	## Options

	.num			- Number of auras to display. Defaults to 4 (number)
	.spacing		- Spacing between each button. Defaults to 6 (number)
	.spells			- Table of spells to track. the table key is a spellID and value is category.
	.display		- Setup how icons are displayed inside the unit frame. Options: "INLINE" or "CORNER". Default: "INLINE"
	.onlyShowPlayer - Shows only auras created by player/vehicle (boolean)

	### Spell Categories
	
	"heal"		-- display heals casted by the player only, like 'Renew', 'Regrowth', etc.
	"buff"		-- display auras casted by the player only, like 'Power Infustion'.
	"raid"		-- display auras casted by any unit which affects other units, like 'Power Word: Barrier', 'Pain Supression', 'Life Cocoon', etc.
	"defensive" -- display auras casted by a unit on itself, like 'Dispersion', 'Shield Wall', 'Dampen Harm', etc.

	## Example

		-- Position and size
		local AuraTrack = CreateFrame("Frame", nil, self)
		AuraTrack:SetAllPoints()
		AuraTrack.num = 4
		AuraTrack.spacing = 6
		AuraTrack.filter = "HELPFUL"
		AuraTrack.spells = {
			[17]    = "heal", -- Power Word: Shield ("heal" display only buffs casted by player)
			[10060] = "buff", -- Power Infusion
			[33206] = "raid", -- Pain Suppression
			[81782] = "raid", -- Power World: Barrier
			[47585] = "defensive", -- Dispersion
		}

		-- Register with oUF
		self.AuraTrack = AuraTrack
--]]

local _, ns = ...
local oUF = ns.oUF
assert(oUF, "oUF_AuraTrack as unable to locate oUF install.")

local _, class = UnitClass("player")

-- spell table
local spells = {}

if oUF.isRetail then
	spells = {
		["DEMONHUNTER"] = {
			[196718] = "raid", 	-- Darkness
			[196555] = "defensive", -- Netherwalk
        	[198589] = "defensive", -- Blur
        	-- [187827] = "defensive", -- Metamorphosis
		},
		["DEATHKNIGHT"] = {
			[145629] = "raid", -- Anti-Magic Zone
			-- Blood
			[48707]  = "defensive", -- Anti-Magic Shell
			[48792]  = "defensive", -- Icebound Fortitude
			[49028]  = "defensive", -- Dancing Rune Weapon
			[49039]  = "defensive", -- Lichborne
			[55233]  = "defensive", -- Vampiric Blood
			[194679] = "defensive", -- Rune Tap
		},
		["EVOKER"] = {
			-- Preservation
			[357170] = "raid", -- Time Dilation
			[374227] = "raid", -- Zephyr
			[374348] = "raid", -- Renewing Blaze
			[378441] = "raid", -- Time Stop (PvP)
			[364343] = "heal", -- Echo
			[373862] = "heal", -- Temporal Anomally
			[363502] = "heal", -- Dream Flight
			[366155] = "heal", -- Reversion
			[382614] = "heal", -- Dream Breath

			[363916] = "defensive", -- Obsidian Scales
			-- [374348] = "defensive", -- Renewing Blaze
			[370960] = "defensive", -- Emerald Communion
			[431872] = "defensive", -- Temporality (Chronowarden Hero Talent)
			[377088] = "defensive", -- Rush of Vitality
		},
		["DRUID"] = {
			[22812]  = "defensive", -- Barkskin

			-- Balance
			[29166]  = "raid", -- Inervate

			-- Guardian
			[22842]  = "defensive", -- Frenzied Regeneration
			[61336]  = "defensive", -- Survival Instincts
			[102558] = "defensive", -- Incarnation: Guardian of Ursoc
			[200851] = "defensive", -- Rage of the Sleeper

			-- Feral

			-- Restoration
			[102342] = "raid", -- Ironbark
			[157982] = "raid", -- Tranquility
			[774]    = "heal", -- Rejuvenation
			[8936]   = "heal", -- Regrowth
			[33763]  = "heal", -- Lifebloom (Normal version)
			[48438]  = "heal", -- Wild Growth
			[102351] = "heal", -- Cenarion Ward (Initial Buff)
			[102352] = "heal", -- Cenarion Ward (HoT)
			[155777] = "heal", -- Rejuvenation (Germination)
			[188550] = "heal", -- Lifebloom (Legendary version)
			[200389] = "heal", -- Cultivation
			[207386] = "heal", -- Spring Blossoms

			-- (Crenna Earth-Daughter - Follower Dungeon)
			[419204] = "heal", -- Rejuvenation
			[419287] = "heal", -- Regrowth
			[419207] = "raid", -- Lifebloom
			[419344] = "raid", -- wild-growth
		},
		["HUNTER"] = {
			[136] 	 = "heal", -- Mend Pet
			[272790] = "buff", -- Frenzy
			[186265] = "defensive", -- Aspect of the Turtle
        	[264735] = "defensive", -- Survival of the Fittest
		},
		["MAGE"] = {
			[414664] = "raid", -- Mass Invisibility
            [414661] = "raid", -- Ice Barrier (Mass Barrier)
            [414662] = "raid", -- Blazing Barrier (Mass Barrier)
            [414663] = "raid", -- Prismatic Barrier (Mass Barrier)

			[80353]  = "buff", -- Time Warp
			[11426]  = "defensive", -- Ice Barrier
			[45438]  = "defensive", -- Ice Block
			-- [55342]  = "defensive", -- Mirror Image
			-- [113862] = "defensive", -- Greater Invisibility
            [235313] = "defensive", -- Blazing Barrier
            [235450] = "defensive", -- Prismatic Barrier
			[342246] = "defensive", -- Alter Time
			[414658] = "defensive", -- Ice Cold
		},
		["MONK"] = {
			[115203] = "defensive", -- Fortifying Brew
			[122278] = "defensive", -- Dampen Harm
			[122783] = "defensive", -- Diffuse Magic
			-- Brewmaster
			[115176] = "defensive", -- Zen Meditation
			-- Windwalker
			[125174] = "defensive", -- Touch of Karma
			-- Mistweaver
			[116849] = "raid", -- Life Cocoon
			[119611] = "heal", -- Renewing Mist
			[124682] = "heal", -- Enveloping Mist
			[443113] = "heal", -- Strenght of the Black Ox

		},
		["PALADIN"] = {
			[498]	 = "defensive", -- Divine Protection
			[642]	 = "defensive", -- Divine Shield
			[1022]   = "raid", -- Blessing of Protection
			[1044]   = "raid", -- Blessing of Freedom
			[6940]   = "raid", -- Blessing of Sacrifice
			[204018] = "raid", -- Blessing of Spellwarding
			[210256] = "raid", -- Blessing of Sanctuary (PvP)

			-- Holy
			[53563]  = "heal", -- Beacon of Light
			[156910] = "heal", -- Beacon of Faith
			[200025] = "heal", -- Beacon of Virtue
			[200654] = "heal", -- Tyr's Deliverance
			[287280] = "heal", -- Glimmer of Light (Artifact HoT)
			[395180] = "heal", -- Barrier of Faith
			[31821]  = "raid", -- Aura Mastery
			[388007] = "buff", -- Blessing of Summer
			[388010] = "buff", -- Blessing of Autumn
			[388011] = "buff", -- Blessing of Winter
			[388013] = "buff", -- Blessing of Spring

			-- Protection
			[432496] = "buff", -- Holy Bulwark
			[432502] = "buff", -- Sacred Weapon
			[31850]  = "defensive", -- Ardent Defender
			[212641] = "defensive", -- Guardian of Ancient Kings
			[205191] = "defensive", -- Eye for an Eye
			[389539] = "defensive", -- Sentinel
			[184662] = "defensive", -- Shield of Vengeance

			-- Retribution

			-- [1022] = true, -- 保护祝福 - Blessing of Protection
			-- [6940] = true, -- 牺牲祝福 - Blessing of Sacrifice
			-- [204018] = true, -- 破咒祝福 - Blessing of Spellwarding
			-- [210256] = true, -- 庇护祝福 - Blessing of Sanctuary
			[228050] = "unknown", -- Divine Shield
		},
		["PRIEST"] = {
			[17]     = "heal", -- Power Word: Shield
			[139]    = "heal", -- Renew
			[10060]  = "buff", -- Power Infusion

			-- Discipline
			[33206]  = "raid", -- Pain Suppression
			[81782]  = "raid", -- Power World: Barrier
			[194384] = "heal", -- Atonement
			[214206] = "heal", -- Atonement (PvP)

			-- Holy
			[47788]  = "raid", -- Guardian Spirit
			[197268] = "raid", -- Ray of Hope (PvP)
			[213610] = "raid", -- Holy Ward (PvP)
			[41635]  = "heal", -- Prayer of Mending
			[193065] = "heal", -- Protective Light

			-- Shadow
			[47585] = "defensive", -- Dispersion
			-- Vampiric Embrace
			-- [19236] = true, -- 绝望祷言 - Desperate Prayer
			-- [586] = true, -- 渐隐术 -- TODO: 373446 通透影像 - Fade
			-- [193065] = true, -- 防护圣光 - Protective Light
			-- [27827] = true, -- 救赎之魂 - Spirit of Redemption
		},
		["ROGUE"] = {
			[1966]   = "defensive", -- Feint
			[5277]   = "defensive", -- Evasion
			[31224]  = "defensive", -- Cloak of Shadows
			[57934]  = "buff", -- Tricks of the Trade
			[114018] = "raid", -- Shroud of Concealment (player)
			[115834] = "raid", -- Shroud of Concealment (group)
		},
		["SHAMAN"] = {
			[108271] = "defensive", -- Astral Shift
			-- Elemental
			-- Enhancement
			-- Restoration
			[974]    = "heal", -- Earth Shield
			[61295]  = "heal", -- Riptide
			[8178]   = "raid", -- Grounding Totem
			[98008]	 = "raid", -- Spirit Link Totem
			[201633] = "raid", -- Earthen Wall
			[201657] = "raid", -- Earthen Wall
			[383018] = "raid", -- Stoneskin

			[409293] = "defensive", -- Burrow (PvP)
			[114893] = "defensive", -- Stone Bulwark
		},
		["WARLOCK"] = {
			[193396] = "buff", -- Demonic Empowerment
			[104773] = "defensive", -- Unending Resolve
			[212295] = "defensive", -- Nether Ward (PvP)
			[108416] = "defensive", -- Dark Pact
		},
		["WARRIOR"] = {
			[3411]	 = "raid", -- Intervene
			[97462]	 = "raid", -- Rallying Cry
			[114030] = "raid", -- Vigilance
			[213871] = "raid", -- Bodyguard (PvP)
			[871]	 = "defensive", -- Shield Wall
			[12975]  = "defensive", -- Last Stand
			[23920]  = "defensive", -- Spell Reflection
			[118038] = "defensive", -- Die by the Sword
			[184364] = "defensive", -- Enraged Regeneration
		}
	}
elseif oUF.isMoP then
	spells = {
		["DRUID"] = {
			[22812]  = "defensive", -- Barkskin

			-- Balance
			[29166]  = "raid", -- Inervate

			-- Guardian
			[22842]  = "defensive", -- Frenzied Regeneration
			[61336]  = "defensive", -- Survival Instincts

			-- Restoration
			[740]    = "raid", -- Tranquility
			[102342] = "raid", -- Ironbark
			[774]    = "heal", -- Rejuvenation
			[8936]   = "heal", -- Regrowth
			[33763]  = "heal", -- Lifebloom
			[48438]  = "heal", -- Wild Growth
			[102351] = "heal", -- Cenarion Ward (Initial Buff)
			[102352] = "heal", -- Cenarion Ward (HoT)
		},
		["DEATHKNIGHT"] = {
			[57330] = "raid", -- Horn of Winter
			[48792] = "defensive", -- Icebound Fortitude
			[48707] = "defensive", -- Anti-Magic Shell
			[49028] = "defensive", -- Dancing Rune Weapon
			[49039] = "defensive", -- Lichborne
			[55233] = "defensive", -- Vampiric Blood
			[108200] = "defensive", -- Remorseless Winter
		},
		["MONK"] = {
			-- Mistweaver
			[116849] = "raid", -- Life Cocoon
			[119611] = "heal", -- Renewing Mist
			[124682] = "heal", -- Enveloping Mist
			[124081] = "heal", -- Zen Sphere
		},
		["PALADIN"] = {
			-- Holy
			[1038]   = "raid", -- Hand of Salvation
			[1022]  = "raid", -- Hand of Protection
			[1044]  = "raid", -- Hand of Freedom
			[6940]  = "raid", -- Hand of Sacrifice
			[31821] = "raid", -- Aura Mastery
			[53563] = "heal", -- Beacon of Light
			[70940] = "defensive", -- Divine Guardian
			[82327] = "heal", -- Holy Radiance
			[86273] = "heal", -- Illuminated Healing

			-- Protection
			[31850] = "defensive", -- Ardent Defender
			[204018] = "raid", -- Blessing of Spellwarding
			[184662] = "defensive", -- Shield of Vengeance
		},
		["PRIEST"] = {
			[17]    = "heal", -- Power Word: Shield
			[139]   = "heal", -- Renew
			[6346]  = "buff", -- Fear Ward
			[10060] = "buff", -- Power Infusion

			-- Discipline
			[33206] = "raid", -- Pain Suppression
			[81782] = "raid", -- Power World: Barrier
			[109964] = "heal", -- Spirit Shell

			-- Holy
			[47788] = "raid", -- Guardian Spirit
			[41635] = "heal", -- Prayer of Mending
			[62618] = "raid", -- Power World: Barrier
			[64844] = "raid", -- Divine Hymn
		},
		["ROGUE"] = {
			[57934] = "raid", -- Tricks of the Trade
		},
		["SHAMAN"] = {
			-- All
			[108271] = "defensive", -- Astral Shift
			-- Restoration
			[974]	 = "heal", -- Earth Shield
			[61295]  = "heal", -- Riptide
			[98008]	 = "raid", -- Spirit Link Totem
			[120668] = "raid", -- Stormlash Totem
		},
		["WARRIOR"] = {
			[469]  = "raid", -- Commanding Shout
			[6673] = "raid", -- Battle Shout
		}
	}
elseif oUF.isCata then
	spells = {
		["DEATHKNIGHT"] = {
			[57330]	= "raid", -- Horn of Winter
		},
		["DRUID"] = {
			[774]	 = "heal", -- Rejuvenation
			[8936]	 = "heal", -- Regrowth
			[33763]  = "heal", -- Lifebloom
			[48438]  = "heal", -- Wild Growth
			[157982] = "raid", -- Tranquility
		},
		["HUNTER"] = {
			[24604]	= "buff", -- Furious Howl
			[34477]	= "raid", -- Misdirection
		},
		["PALADIN"] = {
			[138]   = "raid", -- Hand of Salvation
			[1022]  = "raid", -- Hand of Protection
			[1044]  = "raid", -- Hand of Freedom
			[6940]  = "raid", -- Hand of Sacrifice
			[31821] = "raid", -- Aura Mastery
			[53563] = "heal", -- Beacon of Light
			[70940] = "defensive", -- Divine Guardian
			[82327] = "heal", -- Holy Radiance
			[86273] = "heal", -- Illuminated Healing
		},
		["PRIEST"] = {
			[17]	= "heal", -- Power Word Shield
			[139]	= "heal", -- Renew
			[6346]	= "buff", -- Fear Ward
			[10060] = "buff", -- Power Infusion
			[33076]	= "heal", -- Prayer of Mending
			[33206] = "raid", -- Pain Suppression
			[47788]	= "raid", -- Guardian Spirit
			[62618] = "raid", -- Power World: Barrier
			[64844] = "raid", -- Divine Hymn
			[64904] = "raid", -- Hymn of Hope
			[47930] = "heal", -- Grace (Rank 1)
			[77613] = "heal", -- Grace (Rank 2)
		},
		["ROGUE"] = {
			[57934] = "raid", -- Tricks of the Trade
		},
		["SHAMAN"] = {
			[974]	= "heal", -- Earth Shield
			[61295] = "heal", -- Riptide
			[98008]	= "raid", -- Spirit Link Totem
		},
		["WARRIOR"] = {
			[469]  = "raid", -- Commanding Shout
			[6673] = "raid", -- Battle Shout
		}
	}
else
	spells = {
		["DEATHKNIGHT"] = {
			[57330] = oUF.isWrath and "buff" or nil, -- Horn of Winter
		},
		["DRUID"] = {
			[1126]	= "raid", -- Mark of the Wild (Rank 1)
			[5232]	= "raid", -- Mark of the Wild (Rank 2)
			[6756]	= "raid", -- Mark of the Wild (Rank 3)
			[5234]	= "raid", -- Mark of the Wild (Rank 4)
			[8907]	= "raid", -- Mark of the Wild (Rank 5)
			[9884]	= "raid", -- Mark of the Wild (Rank 6)
			[9885]	= "raid", -- Mark of the Wild (Rank 7)
			[26990]	= "raid", -- Mark of the Wild (Rank 8)
			[48469]	= "raid", -- Mark of the Wild (Rank 9)
			[21849]	= "raid", -- Gift of the Wild (Rank 1)
			[21850]	= "raid", -- Gift of the Wild (Rank 2)
			[26991]	= "raid", -- Gift of the Wild (Rank 3)
			[48470]	= "raid", -- Gift of the Wild (Rank 4)

			[467]	= "raid", -- Thorns (Rank 1)
			[782]	= "raid", -- Thorns (Rank 2)
			[1075]	= "raid", -- Thorns (Rank 3)
			[8914]	= "raid", -- Thorns (Rank 4)
			[9756]	= "raid", -- Thorns (Rank 5)
			[9910]	= "raid", -- Thorns (Rank 6)
			[26992]	= "raid", -- Thorns (Rank 7)
			[53307]	= "raid", -- Thorns (Rank 8)

			[774]	= "heal", -- Rejuvenation (Rank 1)
			[1058]	= "heal", -- Rejuvenation (Rank 2)
			[1430]	= "heal", -- Rejuvenation (Rank 3)
			[2090]	= "heal", -- Rejuvenation (Rank 4)
			[2091]	= "heal", -- Rejuvenation (Rank 5)
			[3627]	= "heal", -- Rejuvenation (Rank 6)
			[8910]	= "heal", -- Rejuvenation (Rank 7)
			[9839]	= "heal", -- Rejuvenation (Rank 8)
			[9840]	= "heal", -- Rejuvenation (Rank 9)
			[9841]	= "heal", -- Rejuvenation (Rank 10)
			[25299]	= "heal", -- Rejuvenation (Rank 11)
			[26981]	= "heal", -- Rejuvenation (Rank 12)
			[26982]	= "heal", -- Rejuvenation (Rank 13)
			[48440]	= "heal", -- Rejuvenation (Rank 14)
			[48441]	= "heal", -- Rejuvenation (Rank 15)

			[8936]	= "heal", -- Regrowth (Rank 1)
			[8938]	= "heal", -- Regrowth (Rank 2)
			[8939]	= "heal", -- Regrowth (Rank 3)
			[8940]	= "heal", -- Regrowth (Rank 4)
			[8941]	= "heal", -- Regrowth (Rank 5)
			[9750]	= "heal", -- Regrowth (Rank 6)
			[9856]	= "heal", -- Regrowth (Rank 7)
			[9857]	= "heal", -- Regrowth (Rank 8)
			[9858]	= "heal", -- Regrowth (Rank 9)
			[26980]	= "heal", -- Regrowth (Rank 10)
			[48442]	= "heal", -- Regrowth (Rank 11)
			[48443]	= "heal", -- Regrowth (Rank 12)

			[29166]	= "buff", -- Innervate
			
			[33763]	= "heal", -- Lifebloom (Rank 1)
			[48450]	= "heal", -- Lifebloom (Rank 2)
			[48451]	= "heal", -- Lifebloom (Rank 3)
		},
		["HUNTER"] = {
			[19506]	= "buff", -- Trueshot Aura (Rank 1)
			[20905]	= "buff", -- Trueshot Aura (Rank 2)
			[20906]	= "buff", -- Trueshot Aura (Rank 3)
			[27066]	= "buff", -- Trueshot Aura (Rank 4)

			[13159]	= "raid", -- Aspect of the Pack

			[20043]	= "raid", -- Aspect of the Wild (Rank 1)
			[20190]	= "raid", -- Aspect of the Wild (Rank 2)
			[27045]	= "raid", -- Aspect of the Wild (Rank 3)

			[24604]	= "buff", -- Furious Howl (Rank 1)
			[24605]	= "buff", -- Furious Howl (Rank 2)
			[24603]	= "buff", -- Furious Howl (Rank 3)
			[24597]	= "buff", -- Furious Howl (Rank 4)
			[64494]	= "buff", -- Furious Howl (Rank 5)
			[64495]	= "buff", -- Furious Howl (Rank 6)
		},
		["MAGE"] = {
			[1459]	= (class == "MAGE") and "raid" or nil, -- Arcane Intellect (Rank 1)
			[1460]	= (class == "MAGE") and "raid" or nil, -- Arcane Intellect (Rank 2)
			[1461]	= (class == "MAGE") and "raid" or nil, -- Arcane Intellect (Rank 3)
			[10156] = (class == "MAGE") and "raid" or nil, -- Arcane Intellect (Rank 4)
			[10157] = (class == "MAGE") and "raid" or nil, -- Arcane Intellect (Rank 5)
			[27126] = (class == "MAGE") and "raid" or nil, -- Arcane Intellect (Rank 6)
			[23028] = (class == "MAGE") and "raid" or nil, -- Arcane Brilliance (Rank 1)
			[27127] = (class == "MAGE") and "raid" or nil, -- Arcane Brilliance (Rank 2)

			[604]	= "buff", -- Dampen Magic (Rank 1)
			[8450]	= "buff", -- Dampen Magic (Rank 2)
			[8451]	= "buff", -- Dampen Magic (Rank 3)
			[10173] = "buff", -- Dampen Magic (Rank 4)
			[10174] = "buff", -- Dampen Magic (Rank 5)
			[33944] = "buff", -- Dampen Magic (Rank 6)

			[1008]	= "buff", -- Amplify Magic (Rank 1)
			[8455]	= "buff", -- Amplify Magic (Rank 2)
			[10169] = "buff", -- Amplify Magic (Rank 3)
			[10170] = "buff", -- Amplify Magic (Rank 4)
			[27130] = "buff", -- Amplify Magic (Rank 5)
			[33946] = "buff", -- Amplify Magic (Rank 6)

			[130]	= "buff", -- Slow Fall
		},
		["PALADIN"] = {
			[1044]	= "raid", -- Blessing of Freedom

			[6940]	= "raid", -- Blessing Sacrifice (Rank 1)
			[20729]	= "raid", -- Blessing Sacrifice (Rank 2)
			[27147]	= "raid", -- Blessing Sacrifice (Rank 3)
			[27148]	= "raid", -- Blessing Sacrifice (Rank 4)

			[19740]	= "raid", -- Blessing of Might (Rank 1)
			[19834]	= "raid", -- Blessing of Might (Rank 2)
			[19835]	= "raid", -- Blessing of Might (Rank 3)
			[19836]	= "raid", -- Blessing of Might (Rank 4)
			[19837]	= "raid", -- Blessing of Might (Rank 5)
			[19838]	= "raid", -- Blessing of Might (Rank 6)
			[25291]	= "raid", -- Blessing of Might (Rank 7)
			[27140]	= "raid", -- Blessing of Might (Rank 8)
			[25782]	= "raid", -- Greater Blessing of Might (Rank 1)
			[25916]	= "raid", -- Greater Blessing of Might (Rank 2)
			[27141]	= "raid", -- Greater Blessing of Might (Rank 3)

			[19742]	= "raid", -- Blessing of Wisdom (Rank 1)
			[19850]	= "raid", -- Blessing of Wisdom (Rank 2)
			[19852]	= "raid", -- Blessing of Wisdom (Rank 3)
			[19853]	= "raid", -- Blessing of Wisdom (Rank 4)
			[19854]	= "raid", -- Blessing of Wisdom (Rank 5)
			[25290]	= "raid", -- Blessing of Wisdom (Rank 6)
			[27142]	= "raid", -- Blessing of Wisdom (Rank 7)
			[25894]	= "raid", -- Greater Blessing of Wisdom (Rank 1)
			[25918]	= "raid", -- Greater Blessing of Wisdom (Rank 2)
			[27143]	= "raid", -- Greater Blessing of Wisdom (Rank 3)

			[465]	= "buff", -- Devotion Aura (Rank 1)
			[10290]	= "buff", -- Devotion Aura (Rank 2)
			[643]	= "buff", -- Devotion Aura (Rank 3)
			[10291]	= "buff", -- Devotion Aura (Rank 4)
			[1032]	= "buff", -- Devotion Aura (Rank 5)
			[10292]	= "buff", -- Devotion Aura (Rank 6)
			[10293]	= "buff", -- Devotion Aura (Rank 7)
			[27149]	= "buff", -- Devotion Aura (Rank 8)

			[19977]	= "raid", -- Blessing of Light (Rank 1)
			[19978]	= "raid", -- Blessing of Light (Rank 2)
			[19979]	= "raid", -- Blessing of Light (Rank 3)
			[27144]	= "raid", -- Blessing of Light (Rank 4)

			[1022] 	= "raid", -- Blessing of Protection (Rank 1)
			[5599] 	= "raid", -- Blessing of Protection (Rank 2)
			[10278]	= "raid", -- Blessing of Protection (Rank 3)

			-- [19746]	= concentration_aura, -- Concentration Aura
			-- [32223]	= crusader_aura, -- Crusader Aura

			[28790]	= "buff", -- Holy Power (armor)
			[28791]	= "buff", -- Holy Power (attack power)
			[28793]	= "buff", -- Holy Power (spell damage)
			[28795]	= "buff", -- Holy Power (mana regeneration)
		},
		["PRIEST"] = {
			[1243]	= (class == "PRIEST") and "raid" or nil, -- Power Word: Fortitude (Rank 1)
			[1244] 	= (class == "PRIEST") and "raid" or nil, -- Power Word: Fortitude (Rank 2)
			[1245] 	= (class == "PRIEST") and "raid" or nil, -- Power Word: Fortitude (Rank 3)
			[2791] 	= (class == "PRIEST") and "raid" or nil, -- Power Word: Fortitude (Rank 4)
			[10937]	= (class == "PRIEST") and "raid" or nil, -- Power Word: Fortitude (Rank 5)
			[10938]	= (class == "PRIEST") and "raid" or nil, -- Power Word: Fortitude (Rank 6)
			[25389]	= (class == "PRIEST") and "raid" or nil, -- Power Word: Fortitude (Rank 7)
			[48161]	= (class == "PRIEST") and "raid" or nil, -- Power Word: Fortitude (Rank 8)
			[21562]	= (class == "PRIEST") and "raid" or nil, -- Prayer of Fortitude (Rank 1)
			[21564]	= (class == "PRIEST") and "raid" or nil, -- Prayer of Fortitude (Rank 2)
			[25392]	= (class == "PRIEST") and "raid" or nil, -- Prayer of Fortitude (Rank 3)
			[48162]	= (class == "PRIEST") and "raid" or nil, -- Prayer of Fortitude (Rank 4)

			[14752]	= (class == "PRIEST") and "raid" or nil, -- Divine Spirit (Rank 1)
			[14818]	= (class == "PRIEST") and "raid" or nil, -- Divine Spirit (Rank 2)
			[14819]	= (class == "PRIEST") and "raid" or nil, -- Divine Spirit (Rank 3)
			[27841]	= (class == "PRIEST") and "raid" or nil, -- Divine Spirit (Rank 4)
			[25312]	= (class == "PRIEST") and "raid" or nil, -- Divine Spirit (Rank 5)
			[48073]	= (class == "PRIEST") and "raid" or nil, -- Divine Spirit (Rank 6)
			[27681]	= (class == "PRIEST") and "raid" or nil, -- Prayer of Spirit (Rank 1)
			[32999]	= (class == "PRIEST") and "raid" or nil, -- Prayer of Spirit (Rank 2)
			[48074]	= (class == "PRIEST") and "raid" or nil, -- Prayer of Spirit (Rank 3)

			[976]	= (class == "PRIEST") and "raid" or nil, -- Shadow Protection (Rank 1)
			[10957]	= (class == "PRIEST") and "raid" or nil, -- Shadow Protection (Rank 2)
			[10958]	= (class == "PRIEST") and "raid" or nil, -- Shadow Protection (Rank 3)
			[25433]	= (class == "PRIEST") and "raid" or nil, -- Shadow Protection (Rank 4)
			[48169]	= (class == "PRIEST") and "raid" or nil, -- Shadow Protection (Rank 5)
			[27683]	= (class == "PRIEST") and "raid" or nil, -- Prayer of Shadow Protection (Rank 1)
			[39374]	= (class == "PRIEST") and "raid" or nil, -- Prayer of Shadow Protection (Rank 2)
			[48170]	= (class == "PRIEST") and "raid" or nil, -- Prayer of Shadow Protection (Rank 3)

			[17]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 1)
			[592]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 2)
			[600]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 3)
			[3747]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 4)
			[6065]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 5)
			[6066]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 6)
			[10898]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 7)
			[10899]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 8)
			[10900]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 9)
			[10901]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 10)
			[25217]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 11)
			[25218]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 12)
			[48065]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 13)
			[48066]	= oUF.isClassic and "raid" or "heal", -- Power Word: Shield (Rank 14)
			
			[139]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 1)
			[6074]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 2)
			[6075]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 3)
			[6076]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 4)
			[6077]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 5)
			[6078]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 6)
			[10927]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 7)
			[10928]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 8)
			[10929]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 9)
			[25315]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 10)
			[25221]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 11)
			[25222]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 12)
			[48067]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 13)
			[48068]	= oUF.isClassic and "raid" or "heal", -- Renew (Rank 14)
		},
		["SHAMAN"] = {
			[974]  	= "heal", -- Earth Shield (Rank 1)
			[32593]	= "heal", -- Earth Shield (Rank 2)
			[32594]	= "heal", -- Earth Shield (Rank 3)

			[30708]	= "raid", -- Totem of Wrath (Rank 1)
			
			[29203]	= "heal", -- Healing Way

			[16237]	= "buff", -- Ancestral Fortitude

			[25909]	= "raid", -- Tranquil Air

			[8185] 	= "raid", -- Fire Resistance Totem (Rank 1)
			[10534]	= "raid", -- Fire Resistance Totem (Rank 2)
			[10535]	= "raid", -- Fire Resistance Totem (Rank 3)
			[25562]	= "raid", -- Fire Resistance Totem (Rank 4)

			[8182] 	= "raid", -- Frost Resistance Totem (Rank 1)
			[10476]	= "raid", -- Frost Resistance Totem (Rank 2)
			[10477]	= "raid", -- Frost Resistance Totem (Rank 3)
			[25559]	= "raid", -- Frost Resistance Totem (Rank 4)

			[10596]	= "raid", -- Nature Resistance Totem (Rank 1)
			[10598]	= "raid", -- Nature Resistance Totem (Rank 2)
			[10599]	= "raid", -- Nature Resistance Totem (Rank 3)
			[25573]	= "raid", -- Nature Resistance Totem (Rank 4)

			[5672] 	= "heal", -- Healing Stream Totem (Rank 1)
			[6371] 	= "heal", -- Healing Stream Totem (Rank 2)
			[6372] 	= "heal", -- Healing Stream Totem (Rank 3)
			[10460]	= "heal", -- Healing Stream Totem (Rank 4)
			[10461]	= "heal", -- Healing Stream Totem (Rank 5)
			[25566]	= "heal", -- Healing Stream Totem (Rank 6)

			[5677] 	= "buff", -- Mana Spring Totem (Rank 1)
			[10491]	= "buff", -- Mana Spring Totem (Rank 2)
			[10493]	= "buff", -- Mana Spring Totem (Rank 3)
			[10494]	= "buff", -- Mana Spring Totem (Rank 4)
			[25569]	= "buff", -- Mana Spring Totem (Rank 5)

			[8072] 	= "raid", -- Stoneskin Totem (Rank 1)
			[8156] 	= "raid", -- Stoneskin Totem (Rank 2)
			[8157] 	= "raid", -- Stoneskin Totem (Rank 3)
			[10403]	= "raid", -- Stoneskin Totem (Rank 4)
			[10404]	= "raid", -- Stoneskin Totem (Rank 5)
			[10405]	= "raid", -- Stoneskin Totem (Rank 6)
			[25506]	= "raid", -- Stoneskin Totem (Rank 7)
			[25507]	= "raid", -- Stoneskin Totem (Rank 8)

			[8076] 	= "raid", -- Strength of Earth Totem (Rank 1)
			[8162] 	= "raid", -- Strength of Earth Totem (Rank 2)
			[8163] 	= "raid", -- Strength of Earth Totem (Rank 3)
			[10441]	= "raid", -- Strength of Earth Totem (Rank 4)
			[25362]	= "raid", -- Strength of Earth Totem (Rank 5)
			[25527]	= "raid", -- Strength of Earth Totem (Rank 6)

			[8836] 	= "raid", -- Grace of Air Totem (Rank 1)
			[10626]	= "raid", -- Grace of Air Totem (Rank 2)
			[25360]	= "raid", -- Grace of Air Totem (Rank 3)
			[2895] 	= "raid", -- Wrath of Air Totem (Rank 1)
		},
		["WARLOCK"] = {
			[5597] 	= "raid", -- Unending Breath

			[6307] 	= "raid", -- Blood Pact (Rank 1)
			[7804] 	= "raid", -- Blood Pact (Rank 2)
			[7805] 	= "raid", -- Blood Pact (Rank 3)
			[11766]	= "raid", -- Blood Pact (Rank 4)
			[11767]	= "raid", -- Blood Pact (Rank 5)

			[132] 	= "raid", -- Detect Lesser Invisibility (Classic) / Detect Invisibility
			[2970] 	= "raid", -- Detect Invisibility
			[11743]	= "raid", -- Detect Greater Invisibility
			[19480]	= "raid", -- Paranoia
		},
		["WARRIOR"] = {
			[469]  	= "raid", -- Commanding Shout

			[6673] 	= (class == "WARRIOR") and "raid" or nil, -- Battle Shout (Rank 1)
			[5242] 	= (class == "WARRIOR") and "raid" or nil, -- Battle Shout (Rank 2)
			[6192] 	= (class == "WARRIOR") and "raid" or nil, -- Battle Shout (Rank 3)
			[11549]	= (class == "WARRIOR") and "raid" or nil, -- Battle Shout (Rank 4)
			[11550]	= (class == "WARRIOR") and "raid" or nil, -- Battle Shout (Rank 5)
			[11551]	= (class == "WARRIOR") and "raid" or nil, -- Battle Shout (Rank 6)
			[25289]	= (class == "WARRIOR") and "raid" or nil, -- Battle Shout (Rank 7)
			[2048] 	= (class == "WARRIOR") and "raid" or nil, -- Battle Shout (Rank 8)
		}
	}

	--------------------------------------------------
	-- Season of Dippscovery (Phase 1 - Max Level 25)
	--------------------------------------------------
	if oUF.isClassic then
		local sod = {
			["DRUID"] = {
				[408120] = "heal", -- Wild Growth
				[408124] = "heal", -- Lifebloom
				[414680] = "heal", -- Living Seed
			},
			["MAGE"] = {
				[400735] = "heal", -- Temporal Beacon
				[401417] = "heal", -- Regeneration
				[412510] = "heal" -- Mass Regeneration
			},
			["PALADIN"] = {
				[407613] = "heal" -- Beacon of Light
			},
			["PRIEST"] = {
				[401877] = "heal" -- Prayer of Mending
			},
			["SHAMAN"] = {
				[408514] = "heal", -- Earth Shield
				[415236] = "heal" -- Healing Rain
			}
		}

		for class, data in next, sod do
			if not spells[class] then
				spells[class] = {}
			end

			for spellID, value in next, data do
				if not spells[class][spellID] then
					spells[class][spellID] = value
				end
			end
		end
	end
end

local function CreateButton(element, index)
	local button = CreateFrame("Button", element:GetDebugName() .. "Button" .. index, element)

	if button.CreateBackdrop then
		button:CreateBackdrop()
	end
	
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

	-- for tooltips
	button.auraInstanceID = data.auraInstanceID
	button.isHarmful = data.isHarmful

	if (button.Cooldown and not element.disableCooldown) then
		if (data.duration > 0) then
			button.Cooldown:SetCooldown(data.expirationTime - data.duration, data.duration, data.timeMod)
			button.Cooldown:Show()
		else
			button.Cooldown:Hide()
		end
	end

	if (button.Icon) then
		button.Icon:SetTexture(data.icon)
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
	if element.onlyShowPlayer then
		return data.isPlayerAura and (element.type ~= nil)
	end
	
	if data.type == "heal" or data.type == "buff" or data.type == true then
		return data.isPlayerAura
	end
	return data.type ~= nil
end

local function SortAuras(a, b)
	if (a.isPlayerAura ~= b.isPlayerAura) then
		return a.isPlayerAura
	end

	if (a.canApplyAura ~= b.canApplyAura) then
		return a.canApplyAura
	end

	-- if aura 'duration' is 'nil' or '0', it do not expires
	local aExpires = a.duration and a.duration > 0
	local bExpires = b.duration and b.duration > 0
	if (aExpires ~= bExpires) then
		return aExpires
	end

	if (aExpires and bExpires and a.duration ~= b.duration) then
		return a.duration < b.duration
	end

	return a.auraInstanceID < b.auraInstanceID
end

local function ProcessData(element, unit, data)
	if (not data) then return end

	data.isPlayerAura = data.sourceUnit and (UnitIsUnit("player", data.sourceUnit) or UnitIsOwnerOrControllerOfUnit("player", data.sourceUnit))
	
	if data.sourceUnit == "player" then
		data.sourceClass = class
		data.type = element.spells[data.spellId]
	elseif data.sourceUnit then
		data.sourceClass = select(2, UnitClass(data.sourceUnit))
		data.type = (spells[data.sourceClass] or {})[data.spellId]
	end

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
		element.onlyShowPlayer = ((type(element.onlyShowPlayer) == "boolean") and element.onlyShowPlayer) or false
		element.spells = Mixin(spells[class] or {}, element.spells or {})

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
