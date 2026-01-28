-- [[ [|cff355E3BB|r]adAzs |cff32CD32Warrior|r ]]
-- Author:  ThePeregris
-- Version: 11.5 Gold

local BadAzsVersion = "|cff355E3B[BadAzsWarrior v11.5]|r"
local _Cast = CastSpellByName
local SpellCache = {}

-- ============================================================
-- [ MOTORES DE ANÁLISE ]
-- ============================================================

local function BadAzs_Ready(spellName)
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

local function BadAzs_GetSwingProgress()
    if SP_ST_Data and SP_ST_Data.main_start then 
        return GetTime() - SP_ST_Data.main_start
    end
    return nil 
end

-- ============================================================
-- [ ROTAÇÕES PRINCIPAIS ]
-- ============================================================

-- Rotação ARMS (2H)
function BadAzs_ArmsRotation()
    UIErrorsFrame:Clear()
    -- Exemplo simplificado para teste:
    if BadAzs_Ready("Victory Rush") then _Cast("Victory Rush") return end
    if BadAzs_Ready("Mortal Strike") then _Cast("Mortal Strike") return end
    if BadAzs_Ready("Bloodthirst") then _Cast("Bloodthirst") return end
    _Cast("Attack")
end

-- Rotação FURY (DW)
function BadAzs_FuryRotation()
    UIErrorsFrame:Clear()
    if BadAzs_Ready("Bloodthirst") then _Cast("Bloodthirst") return end
    if BadAzs_Ready("Whirlwind") then _Cast("Whirlwind") return end
    _Cast("Attack")
end

-- Rotação TANK (Shield)
function BadAzs_TankRotation()
    UIErrorsFrame:Clear()
    _Cast("Shield Block")
    _Cast("Sunder Armor")
    _Cast("Attack")
end

-- ============================================================
-- [ REGISTRO DE COMANDOS SLASH ]
-- ============================================================

-- O segredo está aqui: SlashCmdList["NOME"] = Função
SlashCmdList["BADAZSARMS"] = function() BadAzs_ArmsRotation() end
SLASH_BADAZSARMS1 = "/barms"

SlashCmdList["BADAZSFURY"] = function() BadAzs_FuryRotation() end
SLASH_BADAZSFURY1 = "/bfury"

SlashCmdList["BADAZSTANK"] = function() BadAzs_TankRotation() end
SLASH_BADAZSTANK1 = "/btank"

-- ============================================================
-- [ INICIALIZAÇÃO ]
-- ============================================================
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzsWarrior]|r v11.5 por |cffDAA520ThePeregris|r")
    DEFAULT_CHAT_FRAME:AddMessage("Comandos ativos: /barms, /bfury, /btank")
end)
