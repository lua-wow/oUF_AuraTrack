local _, ns = ...
local oUF = ns.oUF

local isMoP = (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC)
if not isMoP then return end

local _, class = UnitClass("player")

oUF.auras = {
    type = "mists",
    ["DEATHKNIGHT"] = {
        -- General
        [48707] = "defensive", -- Anti-Magic Shell
        [57330] = (class == "DEATHKNIGHT") and "raid" or nil, -- Horn of Winter

        -- Talent
        [51052] = "raid", -- Anti-Magic Zone

        -- Blood
        [48792] = "defensive", -- Icebound Fortitude
        [49028] = "defensive", -- Dancing Rune Weapon
        [49039] = "defensive", -- Lichborne
        [55233] = "defensive", -- Vampiric Blood

        -- Frost
        [108200] = "defensive", -- Remorseless Winter
    },
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
    ["MAGE"] = {},
    ["HUNTER"] = {},
    ["MONK"] = {
        -- Talent
        [122278] = "defensive", -- Dampen Harm
        [122783] = "defensive", -- Diffuse Magic

        -- Brewmaster
        [115176] = "defensive", -- Zen Meditation
        [115203] = "defensive", -- Fortifying Brew
        [115213] = "raid", -- Avert Harm
        [136070] = "heal", -- Guard (Black Ox Statue)

        -- Mistweaver
        [116849] = "raid", -- Life Cocoon
        [119611] = "heal", -- Renewing Mist
        [124682] = "heal", -- Enveloping Mist
        [124081] = "heal", -- Zen Sphere
    },
    ["PALADIN"] = {
        -- Holy
        [1038]  = "raid", -- Hand of Salvation
        [1022]  = "raid", -- Hand of Protection
        [1044]  = "raid", -- Hand of Freedom
        [6940]  = "raid", -- Hand of Sacrifice
        [31821] = "raid", -- Aura Mastery
        [53563] = "heal", -- Beacon of Light
        [70940] = "defensive", -- Divine Guardian
        [82327] = "heal", -- Holy Radiance
        [86273] = "heal", -- Illuminated Healing

        -- Protection
        [31850]  = "defensive", -- Ardent Defender
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
    ["WARLOCK"] = {},
    ["WARRIOR"] = {
        [469]  = "raid", -- Commanding Shout
        [6673] = (class == "WARRIOR") and "raid" or nil, -- Battle Shout
    }
}
