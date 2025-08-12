local _, ns = ...
local oUF = ns.oUF

local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
if not isRetail then return end

oUF.auras = {
    type = "retail",
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
    ["DEMONHUNTER"] = {
        [196718] = "raid", 	-- Darkness
        [196555] = "defensive", -- Netherwalk
        [198589] = "defensive", -- Blur
        -- [187827] = "defensive", -- Metamorphosis
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
        [586]    = "defensive", -- Fade
        [19236]  = "defensive", -- Desperate Prayer
        [47585]  = "defensive", -- Dispersion
        [193065] = "defensive", -- Protective Light
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
