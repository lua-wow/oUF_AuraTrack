local _, ns = ...
local oUF = ns.oUF

local isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)
if not isCata then return end

oUF.auras = {
    type = "cata",
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
