-- [[ [|cff355E3BB|r]adAzs |cff32CD32Warrior|r ]]
-- Author:  ThePeregris
-- System:  Battle Analysis Driven Assistant Zmart System
-- Version: 11.5 Gold (BadAzsWarrior Edition)
-- ---------------------------------------------------------------------------

local BadAzsVersion = "|cff355E3B[BadAzsWarrior v11.5]|r"
local _Cast = CastSpellByName
local SpellCache = {}

-- ============================================================
-- [ MOTORES DE ANÁLISE ]
-- ============================================================

local function BadAzs_GetSwingProgress()
    if SP_ST_Data and SP_ST_Data.main_start then 
        return GetTime() - SP_ST_Data.main_start
    end
    return nil 
end

function BadAzs_Ready(spellName)
    if not SpellCache[spellName] then
        for i = 1, 200 do
            local n = GetSpellName(i, "spell")
            if not n then break end
            if n == spellName then SpellCache[spellName] = i break end
        end
    end
    local id = SpellCache[spellName]
    if not id then return false end
    local start, _ = GetSpellCooldown(id, "spell")
    return start == 0
end

-- ============================================================
-- [ PROTOCOLOS UNIVERSAIS ]
-- ============================================================

local function BadAzs_RageEngine()
    local hp = (UnitHealth("player")/UnitHealthMax("player"))*100
    if UnitAffectingCombat("player") then
        if BadAzs_Ready("Bloodrage") and hp > 70 then _Cast("Bloodrage") end
        local _, _, active = GetShapeshiftFormInfo(3)
        if active and BadAzs_Ready("Berserker Rage") then _Cast("Berserker Rage") end
    end
end

function BadAzs_SnD(prefStance)
    if not UnitExists("target") or UnitIsDead("target") then return true end
    local inCombat = UnitAffectingCombat("player")
    local distance = CheckInteractDistance("target", 3)
    local stance = 0
    for i=1, 3 do local _, _, active = GetShapeshiftFormInfo(i) if active then stance = i break end end

    if not distance then
        if not inCombat and prefStance == 1 then 
            if stance ~= 1 then _Cast("Battle Stance") return true end
            if BadAzs_Ready("Charge") then _Cast("Charge") return true end
        elseif inCombat and IsControlKeyDown() then 
            if stance ~= 3 then _Cast("Berserker Stance") return true end
            if BadAzs_Ready("Intercept") then _Cast("Intercept") return true end
        end
        return true 
    end
    return false 
end

-- ============================================================
-- [ ROTAÇÕES BadAzsWarrior ]
-- ============================================================

function BadAzsArms()
    UIErrorsFrame:Clear()
    if UnitMana("player") < 30 then BadAzs_RageEngine() end
    if BadAzs_SnD(1) then return end 
    
    local thp = (UnitHealth("target")/UnitHealthMax("target"))*100
    local rage = UnitMana("player")
    local swing = BadAzs_GetSwingProgress()

    if BadAzs_Ready("Victory Rush") then _Cast("Victory Rush") return end
    if thp <= 20 then _Cast("Execute") return end

    -- Detecção Agmóstica (MS ou BT)
    if BadAzs_Ready("Mortal Strike") then _Cast("Mortal Strike") return end
    if BadAzs_Ready("Bloodthirst") then _Cast("Bloodthirst") return end
    if BadAzs_Ready("Master Strike") then _Cast("Master Strike") return end

    _Cast("Overpower")

    -- Slam Weaving (1.0s Window)
    if swing and rage >= 15 and swing > 0 and swing < 1.0 then 
        _Cast("Slam") return 
    end

    if rage > 90 then _Cast("Heroic Strike") end
end

function BadAzsFury()
    UIErrorsFrame:Clear()
    BadAzs_RageEngine()
    if BadAzs_SnD(3) then return end 

    local thp = (UnitHealth("target")/UnitHealthMax("target"))*100
    local rage = UnitMana("player")

    if BadAzs_Ready("Victory Rush") then _Cast("Victory Rush") return end
    if thp <= 20 then _Cast("Execute") return end

    if BadAzs_Ready("Bloodthirst") then _Cast("Bloodthirst") return end
    if BadAzs_Ready("Whirlwind") and rage >= 25 then _Cast("Whirlwind") return end
    
    if rage > 90 then _Cast("Heroic Strike") end
end

function BadAzsTank()
    if BadAzs_SnD(2) then return end
    _Cast("Defensive Stance")
    _Cast("Shield Block")
    _Cast("Shield Slam")
    _Cast("Revenge")
    _Cast("Sunder Armor")
end

-- ============================================================
-- [ REGISTRO BadAzsWarrior ]
-- ============================================================

SlashCmdList["BARMS"] = function() BadAzsArms() end
SLASH_BARMS1 = "/barms"
SlashCmdList["BFURY"] = function() BadAzsFury() end
SLASH_BFURY1 = "/bfury"
SlashCmdList["BTANK"] = function() BadAzsTank() end
SLASH_BTANK1 = "/btank"

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzsWarrior]|r v11.5 por |cffDAA520ThePeregris|r")
end)
