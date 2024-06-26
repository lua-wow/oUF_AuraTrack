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

local Spells = {}
if (oUF.isRetail) then
	Spells = {
		-- PRIEST
		[194384]  = oUF:CreateColor(1.00, 1.00, 0.66), -- Atonement
		[214206]  = oUF:CreateColor(1.00, 1.00, 0.66), -- Atonement (PvP)
		[193065]  = oUF:CreateColor(0.54, 0.21, 0.78), -- Protective Light
		[41635]   = oUF:CreateColor(0.20, 0.70, 0.20), -- Prayer of Mending
		[139]     = oUF:CreateColor(0.40, 0.70, 0.20), -- Renew
		[17]      = oUF:CreateColor(0.89, 0.10, 0.10), -- Power Word: Shield
		[47788]   = oUF:CreateColor(0.86, 0.45, 0.00), -- Guardian Spirit
		[33206]   = oUF:CreateColor(0.00, 0.00, 0.74), -- Pain Suppression
		[10060]   = oUF:CreateColor(0.00, 0.00, 0.74), -- Power Infusion
		[81782]   = oUF:CreateColor(0.00, 0.00, 0.74), -- Power World: Barrier

		-- DRUID
		[774]     = oUF:CreateColor(0.80, 0.40, 0.80), -- Rejuvenation
		[155777]  = oUF:CreateColor(0.80, 0.40, 0.80), -- Rejuvenation (Germination)
		[8936]    = oUF:CreateColor(1.00, 1.00, 0.00), -- Regrowth
		[33763]   = oUF:CreateColor(0.40, 0.80, 0.20), -- Lifebloom (Normal version)
		[188550]  = oUF:CreateColor(0.40, 0.80, 0.20), -- Lifebloom (Legendary version)
		[48438]   = oUF:CreateColor(0.80, 0.40, 0.00), -- Wild Growth
		[207386]  = oUF:CreateColor(0.40, 0.20, 0.80), -- Spring Blossoms
		[102351]  = oUF:CreateColor(0.20, 0.80, 0.80), -- Cenarion Ward (Initial Buff)
		[102352]  = oUF:CreateColor(0.20, 0.80, 0.80), -- Cenarion Ward (HoT)
		[102342]  = oUF:CreateColor(0.20, 0.80, 0.80), -- Ironbark
		[200389]  = oUF:CreateColor(1.00, 1.00, 0.40), -- Cultivation
		[391891]  = oUF:CreateColor(1.00, 1.00, 0.40), -- Adaptive Swarm
		[157982]  = oUF:CreateColor(1.00, 1.00, 1.00), -- Tranquility

		-- PALADIN
		[53563]   = oUF:CreateColor(0.70, 0.30, 0.70), -- Beacon of Light
		[156910]  = oUF:CreateColor(0.70, 0.30, 0.70), -- Beacon of Faith
		[200025]  = oUF:CreateColor(0.70, 0.30, 0.70), -- Beacon of Virtue
		[1022]    = oUF:CreateColor(0.20, 0.20, 1.00), -- Blessing of Protection
		[1044]    = oUF:CreateColor(0.89, 0.45, 0.00), -- Blessing of Freedom
		[6940]    = oUF:CreateColor(0.89, 0.10, 0.10), -- Blessing of Sacrifice
		[204018]  = oUF:CreateColor(0.70, 0.70, 0.30), -- Blessing of Spellwarding
		[223306]  = oUF:CreateColor(0.70, 0.70, 0.30), -- Bestow Faith
		[287280]  = oUF:CreateColor(0.20, 0.80, 0.20), -- Glimmer of Light (Artifact HoT)

		-- SHAMAN
		[61295]   = oUF:CreateColor(0.70, 0.30, 0.70), -- Riptide
		[974]     = oUF:CreateColor(0.20, 0.20, 1.00), -- Earth Shield

		-- MONK
		[119611]  = oUF:CreateColor(0.30, 0.80, 0.60), -- Renewing Mist
		[116849]  = oUF:CreateColor(0.20, 0.80, 0.20), -- Life Cocoon
		[124682]  = oUF:CreateColor(0.80, 0.80, 0.25), -- Enveloping Mist
		[191840]  = oUF:CreateColor(0.27, 0.62, 0.70), -- Essence Font

		-- ROGUE
		[57934]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Tricks of the Trade

		-- WARRIOR
		[114030]  = oUF:CreateColor(0.20, 0.20, 1.00), -- Vigilance
		[3411]    = oUF:CreateColor(0.89, 0.09, 0.05), -- Intervene

		-- WARLOCK
		[193396]  = oUF:CreateColor(0.60, 0.20, 0.80), -- Demonic Empowerment

		-- HUNTER
		[272790]  = oUF:CreateColor(0.89, 0.09, 0.05), -- Frenzy
		[136]     = oUF:CreateColor(0.20, 0.80, 0.20), -- Mend Pet
	}
else
	Spells = {
		-- PRIEST
		[1243]    = oUF:CreateColor(1.00, 1.00, 0.66), -- Power Word: Fortitude (Rank 1)
		[1244]    = oUF:CreateColor(1.00, 1.00, 0.66), -- Power Word: Fortitude (Rank 2)
		[1245]    = oUF:CreateColor(1.00, 1.00, 0.66), -- Power Word: Fortitude (Rank 3)
		[2791]    = oUF:CreateColor(1.00, 1.00, 0.66), -- Power Word: Fortitude (Rank 4)
		[10937]   = oUF:CreateColor(1.00, 1.00, 0.66), -- Power Word: Fortitude (Rank 5)
		[10938]   = oUF:CreateColor(1.00, 1.00, 0.66), -- Power Word: Fortitude (Rank 6)
		[25389]   = oUF:CreateColor(1.00, 1.00, 0.66), -- Power Word: Fortitude (Rank 7)
		[48161]   = oUF:CreateColor(1.00, 1.00, 0.66), -- Power Word: Fortitude (Rank 8)
		[21562]   = oUF:CreateColor(1.00, 1.00, 0.66), -- Prayer of Fortitude (Rank 1)
		[21564]   = oUF:CreateColor(1.00, 1.00, 0.66), -- Prayer of Fortitude (Rank 2)
		[25392]   = oUF:CreateColor(1.00, 1.00, 0.66), -- Prayer of Fortitude (Rank 3)
		[48162]   = oUF:CreateColor(1.00, 1.00, 0.66), -- Prayer of Fortitude (Rank 4)
		[14752]   = oUF:CreateColor(0.20, 0.70, 0.20), -- Divine Spirit (Rank 1)
		[14818]   = oUF:CreateColor(0.20, 0.70, 0.20), -- Divine Spirit (Rank 2)
		[14819]   = oUF:CreateColor(0.20, 0.70, 0.20), -- Divine Spirit (Rank 3)
		[27841]   = oUF:CreateColor(0.20, 0.70, 0.20), -- Divine Spirit (Rank 4)
		[25312]   = oUF:CreateColor(0.20, 0.70, 0.20), -- Divine Spirit (Rank 5)
		[48073]	  = oUF:CreateColor(0.20, 0.70, 0.20), -- Divine Spirit (Rank 6)
		[27681]   = oUF:CreateColor(0.20, 0.70, 0.20), -- Prayer of Spirit (Rank 1)
		[32999]   = oUF:CreateColor(0.20, 0.70, 0.20), -- Prayer of Spirit (Rank 2)
		[48074]   = oUF:CreateColor(0.20, 0.70, 0.20), -- Prayer of Spirit (Rank 3)
		[976]     = oUF:CreateColor(0.70, 0.70, 0.70), -- Shadow Protection (Rank 1)
		[10957]   = oUF:CreateColor(0.70, 0.70, 0.70), -- Shadow Protection (Rank 2)
		[10958]   = oUF:CreateColor(0.70, 0.70, 0.70), -- Shadow Protection (Rank 3)
		[25433]   = oUF:CreateColor(0.70, 0.70, 0.70), -- Shadow Protection (Rank 4)
		[48169]   = oUF:CreateColor(0.70, 0.70, 0.70), -- Shadow Protection (Rank 5)
		[27683]   = oUF:CreateColor(0.70, 0.70, 0.70), -- Prayer of Shadow Protection (Rank 1)
		[39374]   = oUF:CreateColor(0.70, 0.70, 0.70), -- Prayer of Shadow Protection (Rank 2)
		[48170]   = oUF:CreateColor(0.70, 0.70, 0.70), -- Prayer of Shadow Protection (Rank 3)
		[17]      = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 1)
		[592]     = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 2)
		[600]     = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 3)
		[3747]    = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 4)
		[6065]    = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 5)
		[6066]    = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 6)
		[10898]   = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 7)
		[10899]   = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 8)
		[10900]   = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 9)
		[10901]   = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 10)
		[25217]   = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 11)
		[25218]   = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 12)
		[48065]   = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 13)
		[48066]   = oUF:CreateColor(0.00, 0.00, 1.00), -- Power Word: Shield (Rank 14)
		[139]     = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 1)
		[6074]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 2)
		[6075]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 3)
		[6076]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 4)
		[6077]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 5)
		[6078]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 6)
		[10927]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 7)
		[10928]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 8)
		[10929]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 9)
		[25315]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 10)
		[25221]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 11)
		[25222]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 12)
		[48067]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 13)
		[48068]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Renew (Rank 14)
		
		-- HUNTER
		[19506]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Trueshot Aura (Rank 1)
		[20905]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Trueshot Aura (Rank 2)
		[20906]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Trueshot Aura (Rank 3)
		[27066]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Trueshot Aura (Rank 4)
		[13159]   = oUF:CreateColor(0.00, 0.00, 0.85), -- Aspect of the Pack
		[20043]   = oUF:CreateColor(0.33, 0.93, 0.79), -- Aspect of the Wild (Rank 1)
		[20190]   = oUF:CreateColor(0.33, 0.93, 0.79), -- Aspect of the Wild (Rank 2)
		[27045]   = oUF:CreateColor(0.33, 0.93, 0.79), -- Aspect of the Wild (Rank 3)
		
		-- MAGE
		[1459]    = oUF:CreateColor(0.89, 0.09, 0.05), -- Arcane Intellect (Rank 1)
		[1460]    = oUF:CreateColor(0.89, 0.09, 0.05), -- Arcane Intellect (Rank 2)
		[1461]    = oUF:CreateColor(0.89, 0.09, 0.05), -- Arcane Intellect (Rank 3)
		[10156]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Arcane Intellect (Rank 4)
		[10157]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Arcane Intellect (Rank 5)
		[27126]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Arcane Intellect (Rank 6)
		[23028]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Arcane Brilliance (Rank 1)
		[27127]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Arcane Brilliance (Rank 2)
		[604]     = oUF:CreateColor(0.20, 0.80, 0.20), -- Dampen Magic (Rank 1)
		[8450]    = oUF:CreateColor(0.20, 0.80, 0.20), -- Dampen Magic (Rank 2)
		[8451]    = oUF:CreateColor(0.20, 0.80, 0.20), -- Dampen Magic (Rank 3)
		[10173]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Dampen Magic (Rank 4)
		[10174]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Dampen Magic (Rank 5)
		[33944]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Dampen Magic (Rank 6)
		[1008]    = oUF:CreateColor(0.20, 0.80, 0.20), -- Amplify Magic (Rank 1)
		[8455]    = oUF:CreateColor(0.20, 0.80, 0.20), -- Amplify Magic (Rank 2)
		[10169]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Amplify Magic (Rank 3)
		[10170]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Amplify Magic (Rank 4)
		[27130]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Amplify Magic (Rank 5)
		[33946]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Amplify Magic (Rank 6)
		[130]     = oUF:CreateColor(0.00, 0.00, 0.50), -- Slow Fall
		
		-- PALADIN
		[1044]    = oUF:CreateColor(0.89, 0.45, 0.00), -- Blessing of Freedom
		[6940]    = oUF:CreateColor(0.89, 0.10, 0.10), -- Blessing Sacrifice (Rank 1)
		[20729]   = oUF:CreateColor(0.89, 0.10, 0.10), -- Blessing Sacrifice (Rank 2)
		[27147]   = oUF:CreateColor(0.89, 0.10, 0.10), -- Blessing Sacrifice (Rank 3)
		[27148]   = oUF:CreateColor(0.89, 0.10, 0.10), -- Blessing Sacrifice (Rank 4)
		[19740]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Might (Rank 1)
		[19834]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Might (Rank 2)
		[19835]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Might (Rank 3)
		[19836]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Might (Rank 4)
		[19837]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Might (Rank 5)
		[19838]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Might (Rank 6)
		[25291]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Might (Rank 7)
		[27140]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Might (Rank 8)
		[19742]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Wisdom (Rank 1)
		[19850]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Wisdom (Rank 2)
		[19852]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Wisdom (Rank 3)
		[19853]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Wisdom (Rank 4)
		[19854]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Wisdom (Rank 5)
		[25290]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Wisdom (Rank 6)
		[27142]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Blessing of Wisdom (Rank 7)
		[25782]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Greater Blessing of Might (Rank 1)
		[25916]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Greater Blessing of Might (Rank 2)
		[27141]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Greater Blessing of Might (Rank 3)
		[25894]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Greater Blessing of Wisdom (Rank 1)
		[25918]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Greater Blessing of Wisdom (Rank 2)
		[27143]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Greater Blessing of Wisdom (Rank 3)
		[465]     = oUF:CreateColor(0.58, 1.00, 0.50), -- Devotion Aura (Rank 1)
		[10290]   = oUF:CreateColor(0.58, 1.00, 0.50), -- Devotion Aura (Rank 2)
		[643]     = oUF:CreateColor(0.58, 1.00, 0.50), -- Devotion Aura (Rank 3)
		[10291]   = oUF:CreateColor(0.58, 1.00, 0.50), -- Devotion Aura (Rank 4)
		[1032]    = oUF:CreateColor(0.58, 1.00, 0.50), -- Devotion Aura (Rank 5)
		[10292]   = oUF:CreateColor(0.58, 1.00, 0.50), -- Devotion Aura (Rank 6)
		[10293]   = oUF:CreateColor(0.58, 1.00, 0.50), -- Devotion Aura (Rank 7)
		[27149]   = oUF:CreateColor(0.58, 1.00, 0.50), -- Devotion Aura (Rank 8)
		[19977]   = oUF:CreateColor(0.17, 1.00, 0.75), -- Blessing of Light (Rank 1)
		[19978]   = oUF:CreateColor(0.17, 1.00, 0.75), -- Blessing of Light (Rank 2)
		[19979]   = oUF:CreateColor(0.17, 1.00, 0.75), -- Blessing of Light (Rank 3)
		[27144]   = oUF:CreateColor(0.17, 1.00, 0.75), -- Blessing of Light (Rank 4)
		[1022]    = oUF:CreateColor(0.17, 1.00, 0.75), -- Blessing of Protection (Rank 1)
		[5599]    = oUF:CreateColor(0.17, 1.00, 0.75), -- Blessing of Protection (Rank 2)
		[10278]   = oUF:CreateColor(0.17, 1.00, 0.75), -- Blessing of Protection (Rank 3)
		[19746]   = oUF:CreateColor(0.83, 1.00, 0.07), -- Concentration Aura
		[32223]   = oUF:CreateColor(0.83, 1.00, 0.07), -- Crusader Aura
		[28790]   = oUF:CreateColor(1.00, 1.00, 0.07), -- Holy Power (armor)
		[28791]   = oUF:CreateColor(1.00, 1.00, 0.07), -- Holy Power (attack power)
		[28793]   = oUF:CreateColor(1.00, 1.00, 0.07), -- Holy Power (spell damage)
		[28795]   = oUF:CreateColor(1.00, 1.00, 0.07), -- Holy Power (mana regeneration)
		
		-- DRUID
		[1126]    = oUF:CreateColor(0.20, 0.80, 0.80), -- Mark of the Wild (Rank 1)
		[5232]    = oUF:CreateColor(0.20, 0.80, 0.80), -- Mark of the Wild (Rank 2)
		[6756]    = oUF:CreateColor(0.20, 0.80, 0.80), -- Mark of the Wild (Rank 3)
		[5234]    = oUF:CreateColor(0.20, 0.80, 0.80), -- Mark of the Wild (Rank 4)
		[8907]    = oUF:CreateColor(0.20, 0.80, 0.80), -- Mark of the Wild (Rank 5)
		[9884]    = oUF:CreateColor(0.20, 0.80, 0.80), -- Mark of the Wild (Rank 6)
		[9885]    = oUF:CreateColor(0.20, 0.80, 0.80), -- Mark of the Wild (Rank 7)
		[26990]   = oUF:CreateColor(0.20, 0.80, 0.80), -- Mark of the Wild (Rank 8)
		[48469]   = oUF:CreateColor(0.20, 0.80, 0.80), -- Mark of the Wild (Rank 9)
		[21849]   = oUF:CreateColor(0.20, 0.80, 0.80), -- Gift of the Wild (Rank 1)
		[21850]   = oUF:CreateColor(0.20, 0.80, 0.80), -- Gift of the Wild (Rank 2)
		[26991]   = oUF:CreateColor(0.20, 0.80, 0.80), -- Gift of the Wild (Rank 3)
		[48470]   = oUF:CreateColor(0.20, 0.80, 0.80), -- Gift of the Wild (Rank 4)
		[467]     = oUF:CreateColor(0.40, 0.20, 0.80), -- Thorns (Rank 1)
		[782]     = oUF:CreateColor(0.40, 0.20, 0.80), -- Thorns (Rank 2)
		[1075]    = oUF:CreateColor(0.40, 0.20, 0.80), -- Thorns (Rank 3)
		[8914]    = oUF:CreateColor(0.40, 0.20, 0.80), -- Thorns (Rank 4)
		[9756]    = oUF:CreateColor(0.40, 0.20, 0.80), -- Thorns (Rank 5)
		[9910]    = oUF:CreateColor(0.40, 0.20, 0.80), -- Thorns (Rank 6)
		[26992]   = oUF:CreateColor(0.40, 0.20, 0.80), -- Thorns (Rank 7)
		[53307]   = oUF:CreateColor(0.40, 0.20, 0.80), -- Thorns (Rank 8)
		[774]     = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 1)
		[1058]    = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 2)
		[1430]    = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 3)
		[2090]    = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 4)
		[2091]    = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 5)
		[3627]    = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 6)
		[8910]    = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 7)
		[9839]    = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 8)
		[9840]    = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 9)
		[9841]    = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 10)
		[25299]   = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 11)
		[26981]   = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 12)
		[26982]   = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 13)
		[48440]   = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 14)
		[48441]   = oUF:CreateColor(0.83, 1.00, 0.25), -- Rejuvenation (Rank 15)
		[8936]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 1)
		[8938]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 2)
		[8939]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 3)
		[8940]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 4)
		[8941]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 5)
		[9750]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 6)
		[9856]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 7)
		[9857]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 8)
		[9858]    = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 9)
		[26980]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 10)
		[48442]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 11)
		[48443]   = oUF:CreateColor(0.33, 0.73, 0.75), -- Regrowth (Rank 12)
		[29166]   = oUF:CreateColor(0.49, 0.60, 0.55), -- Innervate
		[33763]   = oUF:CreateColor(0.33, 0.37, 0.47), -- Lifebloom (Rank 1)
		[48450]   = oUF:CreateColor(0.33, 0.37, 0.47), -- Lifebloom (Rank 2)
		[48451]   = oUF:CreateColor(0.33, 0.37, 0.47), -- Lifebloom (Rank 3)
		
		-- SHAMAN
		[974]     = oUF:CreateColor(0.20, 0.20, 1.00), -- Earth Shield (Rank 1)
		[32593]   = oUF:CreateColor(0.20, 0.20, 1.00), -- Earth Shield (Rank 2)
		[32594]   = oUF:CreateColor(0.20, 0.20, 1.00), -- Earth Shield (Rank 3)
		[30708]   = oUF:CreateColor(1.00, 0.00, 0.00), -- Totem of Wrath (Rank 1)
		[29203]   = oUF:CreateColor(0.70, 0.30, 0.70), -- Healing Way
		[16237]   = oUF:CreateColor(0.20, 0.20, 1.00), -- Ancestral Fortitude
		[25909]   = oUF:CreateColor(0.00, 0.00, 0.50), -- Tranquil Air
		[8185]    = oUF:CreateColor(0.05, 1.00, 0.50), -- Fire Resistance Totem (Rank 1)
		[10534]   = oUF:CreateColor(0.05, 1.00, 0.50), -- Fire Resistance Totem (Rank 2)
		[10535]   = oUF:CreateColor(0.05, 1.00, 0.50), -- Fire Resistance Totem (Rank 3)
		[25562]   = oUF:CreateColor(0.05, 1.00, 0.50), -- Fire Resistance Totem (Rank 4)
		[8182]    = oUF:CreateColor(0.54, 0.53, 0.79), -- Frost Resistance Totem (Rank 1)
		[10476]   = oUF:CreateColor(0.54, 0.53, 0.79), -- Frost Resistance Totem (Rank 2)
		[10477]   = oUF:CreateColor(0.54, 0.53, 0.79), -- Frost Resistance Totem (Rank 3)
		[25559]   = oUF:CreateColor(0.54, 0.53, 0.79), -- Frost Resistance Totem (Rank 4)
		[10596]   = oUF:CreateColor(0.33, 1.00, 0.20), -- Nature Resistance Totem (Rank 1)
		[10598]   = oUF:CreateColor(0.33, 1.00, 0.20), -- Nature Resistance Totem (Rank 2)
		[10599]   = oUF:CreateColor(0.33, 1.00, 0.20), -- Nature Resistance Totem (Rank 3)
		[25573]   = oUF:CreateColor(0.33, 1.00, 0.20), -- Nature Resistance Totem (Rank 4)
		[5672]    = oUF:CreateColor(0.67, 1.00, 0.50), -- Healing Stream Totem (Rank 1)
		[6371]    = oUF:CreateColor(0.67, 1.00, 0.50), -- Healing Stream Totem (Rank 2)
		[6372]    = oUF:CreateColor(0.67, 1.00, 0.50), -- Healing Stream Totem (Rank 3)
		[10460]   = oUF:CreateColor(0.67, 1.00, 0.50), -- Healing Stream Totem (Rank 4)
		[10461]   = oUF:CreateColor(0.67, 1.00, 0.50), -- Healing Stream Totem (Rank 5)
		[25566]   = oUF:CreateColor(0.67, 1.00, 0.50), -- Healing Stream Totem (Rank 6)
		[5677]    = oUF:CreateColor(0.67, 1.00, 0.80), -- Mana Spring Totem (Rank 1)
		[10491]   = oUF:CreateColor(0.67, 1.00, 0.80), -- Mana Spring Totem (Rank 2)
		[10493]   = oUF:CreateColor(0.67, 1.00, 0.80), -- Mana Spring Totem (Rank 3)
		[10494]   = oUF:CreateColor(0.67, 1.00, 0.80), -- Mana Spring Totem (Rank 4)
		[25569]   = oUF:CreateColor(0.67, 1.00, 0.80), -- Mana Spring Totem (Rank 5)
		[8072]    = oUF:CreateColor(0.00, 0.00, 0.26), -- Stoneskin Totem (Rank 1)
		[8156]    = oUF:CreateColor(0.00, 0.00, 0.26), -- Stoneskin Totem (Rank 2)
		[8157]    = oUF:CreateColor(0.00, 0.00, 0.26), -- Stoneskin Totem (Rank 3)
		[10403]   = oUF:CreateColor(0.00, 0.00, 0.26), -- Stoneskin Totem (Rank 4)
		[10404]   = oUF:CreateColor(0.00, 0.00, 0.26), -- Stoneskin Totem (Rank 5)
		[10405]   = oUF:CreateColor(0.00, 0.00, 0.26), -- Stoneskin Totem (Rank 6)
		[25506]   = oUF:CreateColor(0.00, 0.00, 0.26), -- Stoneskin Totem (Rank 7)
		[25507]   = oUF:CreateColor(0.00, 0.00, 0.26), -- Stoneskin Totem (Rank 8)
		[8076]    = oUF:CreateColor(0.78, 0.61, 0.43), -- Strength of Earth Totem (Rank 1)
		[8162]    = oUF:CreateColor(0.78, 0.61, 0.43), -- Strength of Earth Totem (Rank 2)
		[8163]    = oUF:CreateColor(0.78, 0.61, 0.43), -- Strength of Earth Totem (Rank 3)
		[10441]   = oUF:CreateColor(0.78, 0.61, 0.43), -- Strength of Earth Totem (Rank 4)
		[25362]   = oUF:CreateColor(0.78, 0.61, 0.43), -- Strength of Earth Totem (Rank 5)
		[25527]   = oUF:CreateColor(0.78, 0.61, 0.43), -- Strength of Earth Totem (Rank 6)
		[8836]    = oUF:CreateColor(1.00, 1.00, 1.00), -- Grace of Air Totem (Rank 1)
		[10626]   = oUF:CreateColor(1.00, 1.00, 1.00), -- Grace of Air Totem (Rank 2)
		[25360]   = oUF:CreateColor(1.00, 1.00, 1.00), -- Grace of Air Totem (Rank 3)
		[2895]    = oUF:CreateColor(1.00, 1.00, 1.00), -- Wrath of Air Totem (Rank 1)
		
		-- WARLOCK
		[5597]    = oUF:CreateColor(0.89, 0.09, 0.05), -- Unending Breath
		[6512]    = oUF:CreateColor(0.20, 0.80, 0.20), -- Detect Lesser Invisibility
		[2970]    = oUF:CreateColor(0.20, 0.80, 0.20), -- Detect Invisibility
		[11743]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Detect Greater Invisibility
		[6307]    = oUF:CreateColor(0.89, 0.09, 0.05), -- Blood Pact (Rank 1)
		[7804]    = oUF:CreateColor(0.89, 0.09, 0.05), -- Blood Pact (Rank 2)
		[7805]    = oUF:CreateColor(0.89, 0.09, 0.05), -- Blood Pact (Rank 3)
		[11766]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Blood Pact (Rank 4)
		[11767]   = oUF:CreateColor(0.89, 0.09, 0.05), -- Blood Pact (Rank 5)
		[19480]   = oUF:CreateColor(0.20, 0.80, 0.20), -- Paranoia
		[24604]   = oUF:CreateColor(0.08, 0.59, 0.41), -- Furious Howl (Rank 1)
		[24605]   = oUF:CreateColor(0.08, 0.59, 0.41), -- Furious Howl (Rank 2)
		[24603]   = oUF:CreateColor(0.08, 0.59, 0.41), -- Furious Howl (Rank 3)
		[24597]   = oUF:CreateColor(0.08, 0.59, 0.41), -- Furious Howl (Rank 4)
		
		-- WARRIOR
		[6673]    = oUF:CreateColor(0.20, 0.20, 1.00), -- Battle Shout (Rank 1)
		[5242]    = oUF:CreateColor(0.20, 0.20, 1.00), -- Battle Shout (Rank 2)
		[6192]    = oUF:CreateColor(0.20, 0.20, 1.00), -- Battle Shout (Rank 3)
		[11549]   = oUF:CreateColor(0.20, 0.20, 1.00), -- Battle Shout (Rank 4)
		[11550]   = oUF:CreateColor(0.20, 0.20, 1.00), -- Battle Shout (Rank 5)
		[11551]   = oUF:CreateColor(0.20, 0.20, 1.00), -- Battle Shout (Rank 6)
		[25289]   = oUF:CreateColor(0.20, 0.20, 1.00), -- Battle Shout (Rank 7)
		[2048]    = oUF:CreateColor(0.20, 0.20, 1.00), -- Battle Shout (Rank 8)
		[469]     = oUF:CreateColor(0.40, 0.20, 0.80), -- Commanding Shout
	}

	--------------------------------------------------
	-- Season of Discovery (Phase 1 - Max Level 25)
	--------------------------------------------------
	if (oUF.isClassic) then
		-- DRUID
		Spells[408124] = oUF:CreateColor(0.40, 0.80, 0.2) -- Lifebloom
		Spells[414680] = oUF:CreateColor(0.20, 0.80, 0.8) -- Living Seed
		Spells[408120] = oUF:CreateColor(0.80, 0.40, 0) -- Wild Growth

		-- MAGE
		Spells[400735] = oUF:CreateColor(0.20, 0.70, 0.2) -- Temporal Beacon
		Spells[401417] = oUF:CreateColor(0.20, 0.70, 0.2) -- Regeneration
		Spells[412510] = oUF:CreateColor(0.20, 0.70, 0.2) -- Mass Regeneration
		
		-- PALADIN
		Spells[407613] = oUF:CreateColor(0.70, 0.30, 0.7) -- Beacon of Light

		-- PRIEST
		Spells[401877] = oUF:CreateColor(0.20, 0.70, 0.2) -- Prayer of Mending
		
		-- SHAMAN
		Spells[408514] = oUF:CreateColor(0.20, 0.20, 1) -- Earth Shield
		Spells[415236] = oUF:CreateColor(0.70, 0.30, 0.7) -- Healing Rain
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

local function updateAura(element, unit, data, position)
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
	return data.isFromPlayerOrPlayerPet and (element.spells[data.spellId] ~= nil)
end

local function SortAuras(a, b)
	if(a.isPlayerAura ~= b.isPlayerAura) then
		return a.isPlayerAura
	end

	if(a.canApplyAura ~= b.canApplyAura) then
		return a.canApplyAura
	end

	return a.auraInstanceID < b.auraInstanceID
end

local function processData(element, unit, data)
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

local function Update(self, event, unit, info)
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
			local data = processData(element, unit, C_UnitAuras.GetAuraDataBySlot(unit, slots[i]))
			element.all[data.auraInstanceID] = data

			if ((element.FilterAura or FilterAura)(element, unit, data)) then
				element.active[data.auraInstanceID] = true
			end
		end
	else
		if (info.addedAuras) then
			for _, data in next, info.addedAuras do
				if(data.isHelpful and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, element.filter)) then
					element.all[data.auraInstanceID] = processData(element, unit, data)

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
					element.all[auraInstanceID] = processData(element, unit, C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID))

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
			updateAura(element, unit, element.sorted[i], i)
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
	return (self.AuraTrack.Override or Update)(self, ...)
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
		element.spells = element.spells or Spells
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
