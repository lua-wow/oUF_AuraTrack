local _, ns = ...
local oUF = ns.oUF

local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
if not isClassic then return end

local _, class = UnitClass("player")

local auras = {
    type = "classic",
    ["DRUID"] = {
        [1126]	= "raid", -- Mark of the Wild (Rank 1)
        [5232]	= "raid", -- Mark of the Wild (Rank 2)
        [6756]	= "raid", -- Mark of the Wild (Rank 3)
        [5234]	= "raid", -- Mark of the Wild (Rank 4)
        [8907]	= "raid", -- Mark of the Wild (Rank 5)
        [9884]	= "raid", -- Mark of the Wild (Rank 6)
        [9885]	= "raid", -- Mark of the Wild (Rank 7)
        [26990]	= "raid", -- Mark of the Wild (Rank 8)
        
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

        [17]	= "raid", -- Power Word: Shield (Rank 1)
        [592]	= "raid", -- Power Word: Shield (Rank 2)
        [600]	= "raid", -- Power Word: Shield (Rank 3)
        [3747]	= "raid", -- Power Word: Shield (Rank 4)
        [6065]	= "raid", -- Power Word: Shield (Rank 5)
        [6066]	= "raid", -- Power Word: Shield (Rank 6)
        [10898]	= "raid", -- Power Word: Shield (Rank 7)
        [10899]	= "raid", -- Power Word: Shield (Rank 8)
        [10900]	= "raid", -- Power Word: Shield (Rank 9)
        [10901]	= "raid", -- Power Word: Shield (Rank 10)
        [25217]	= "raid", -- Power Word: Shield (Rank 11)
        [25218]	= "raid", -- Power Word: Shield (Rank 12)
        [48065]	= "raid", -- Power Word: Shield (Rank 13)
        [48066]	= "raid", -- Power Word: Shield (Rank 14)
        
        [139]	= "raid", -- Renew (Rank 1)
        [6074]	= "raid", -- Renew (Rank 2)
        [6075]	= "raid", -- Renew (Rank 3)
        [6076]	= "raid", -- Renew (Rank 4)
        [6077]	= "raid", -- Renew (Rank 5)
        [6078]	= "raid", -- Renew (Rank 6)
        [10927]	= "raid", -- Renew (Rank 7)
        [10928]	= "raid", -- Renew (Rank 8)
        [10929]	= "raid", -- Renew (Rank 9)
        [25315]	= "raid", -- Renew (Rank 10)
        [25221]	= "raid", -- Renew (Rank 11)
        [25222]	= "raid", -- Renew (Rank 12)
        [48067]	= "raid", -- Renew (Rank 13)
        [48068]	= "raid", -- Renew (Rank 14)
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
-- Season of Discovery (Phase 1 - Max Level 25)
--------------------------------------------------
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
    if not auras[class] then
        auras[class] = {}
    end

    for spellID, value in next, data do
        if not auras[class][spellID] then
            auras[class][spellID] = value
        end
    end
end

oUF.auras = auras
