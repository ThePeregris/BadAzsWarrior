-- [[ [|cff355E3BB|r]adAzs |cff32CD32Warrior|r ]]
-- Author: ThePeregris
-- System: Battle Analysis Driven Assistant Zmart System
-- Version: 1.0 Gold (Turtle WoW)

local BadAzsVersion = "|cff355E3B[BadAzs v11.5]|r"
local _Cast = CastSpellByName
local SpellCache = {}

-- ============================================================
-- [ MOTORES UNIVERSAIS ]
-- ============================================================

-- Sensor de Swing (Janela de 1.0s para 2H)
local function BadAzs_GetSwingProgress()
    if SP_ST_Data and SP_ST_Data.main_start then 
        return GetTime() - SP_ST_Data.main_start
    end
    return nil 
end

-- Sensor de Especialização: Verifica o que o Warrior sabe fazer
local function BadAzs_MainStrike()
    if BadAzs_Ready("Bloodthirst") then _Cast("Bloodthirst") return true end
    if BadAzs_Ready("Mortal Strike") then _Cast("Mortal Strike") return true end
    return false
end

-- Rage Engine (Socorro de Raiva < 30)
local function BadAzs_RageEngine()
    local hp = (UnitHealth("player")/UnitHealthMax("player"))*100
    if UnitAffectingCombat("player") then
        if BadAzs_Ready("Bloodrage") and hp > 70 then _Cast("Bloodrage") end
        local _, _, active = GetShapeshiftFormInfo(3)
        if active and BadAzs_Ready("Berserker Rage") then _Cast("Berserker Rage") end
    end
end

-- ============================================================
-- [ PROTOCOLOS DE COMBATE ]
-- ============================================================

-- Protocolo SnD (Aproximação com Trava de Segurança CTRL)
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
        elseif inCombat then 
            if IsControlKeyDown() then
                if stance ~= 3 then _Cast("Berserker Stance") return true end
                if BadAzs_Ready("Intercept") then _Cast("Intercept") return true end
            end
            return true 
        end
        return true 
    end
    return false 
end

-- ============================================================
-- [ COMANDOS DE INTERFACE /B ]
-- ============================================================

function BadAzsArms()
    UIErrorsFrame:Clear()
    if UnitMana("player") < 30 then BadAzs_RageEngine() end
    if BadAzs_SnD(1) then return end 
    -- ... Lógica Universal de Dano 2H ...
end

function BadAzsFury()
    UIErrorsFrame:Clear()
    BadAzs_RageEngine()
    if BadAzs_SnD(3) then return end 
    -- ... Lógica Universal de Dano DW ...
end

function BadAzsTank()
    UIErrorsFrame:Clear()
    if BadAzs_SnD(2) then return end
    -- ... Lógica Universal de Proteção ...
end

-- Registro dos Comandos Oficiais BadAzs
SlashCmdList["BARMS"] = function() BadAzsArms() end
SLASH_BARMS1 = "/barms"

SlashCmdList["BFURY"] = function() BadAzsFury() end
SLASH_BFURY1 = "/bfury"

SlashCmdList["BTANK"] = function() BadAzsTank() end
SLASH_BTANK1 = "/btank"

-- Inicialização com Identidade BadAzs
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs]|r |cff32CD32Warrior Elite|r v11.5 por |cffDAA520ThePeregris|r")
    DEFAULT_CHAT_FRAME:AddMessage("Comandos: /barms, /bfury, /btank")
end)
