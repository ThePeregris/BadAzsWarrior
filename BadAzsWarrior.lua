-- [[ [|cff355E3BB|r]adAzs |cff32CD32Warrior|r ]]
-- Author:  ThePeregris & Gemini
-- Version: 17.0 (Lite Module)
-- Target:  Turtle WoW (1.12 / LUA 5.0)
-- Requires: BadAzs Core v2.0+

local BadAzsVersion = "|cff355E3B[BadAzsWarrior v17.0]|r"
local LastSlamTime = 0 

-- ============================================================
-- [ CONFIGURAÇÃO LOCAL ]
-- ============================================================
local BadAzsSets = { TwoHand = "TH", DualWield = "DW", Shield = "WS" }

-- ============================================================
-- [1. INICIALIZAÇÃO ]
-- ============================================================
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loadFrame:SetScript("OnEvent", function()
    -- Inicializa variáveis salvas se não existirem
    if not BadAzsDB then BadAzsDB = { UseItemRack = false, DumpMode = "SLAM" } end
    
    DEFAULT_CHAT_FRAME:AddMessage(BadAzsVersion .. " Loaded.")
    DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[Mode]|r: " .. (BadAzsDB.DumpMode or "SLAM") .. " Focus")
end)

-- Helper Local: Troca de Equipamento
local function BadAzs_Equip(mode)
    if not BadAzsDB.UseItemRack then return end
    local EquipFunc = nil
    if ItemRack and type(ItemRack.EquipSet) == "function" then EquipFunc = ItemRack.EquipSet
    elseif type(ItemRack_EquipSet) == "function" then EquipFunc = ItemRack_EquipSet end
    if not EquipFunc then return end 
    if mode == "TH" then EquipFunc(BadAzsSets.TwoHand)
    elseif mode == "DW" then EquipFunc(BadAzsSets.DualWield)
    elseif mode == "WS" then EquipFunc(BadAzsSets.Shield)
    end
end

-- Helper Local: Detecção de Stance
function BadAzs_GetStance() 
    for i=1, 3 do local _, _, a = GetShapeshiftFormInfo(i) if a then return i end end
    return 1 
end

function BadAzs_HasOffHand() return GetInventoryItemLink("player", 17) ~= nil end
function BadAzs_HasShield()
    local link = GetInventoryItemLink("player", 17)
    if link and string.find(link, "Shield") then return true end
    return false
end

-- ============================================================
-- [2. MÓDULOS DE COMBATE ]
-- ============================================================

-- [[ TANK ]]
function BadAzsTank()
    -- Core lida com Auto Attack
    BadAzs_Cast("Attack") 
    UIErrorsFrame:Clear()
    
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    
    -- Stance & Equip Check
    if stance ~= 2 then BadAzs_Cast("Defensive Stance"); BadAzs_Equip("WS"); return end
    if BadAzsDB.UseItemRack and not BadAzs_HasShield() then BadAzs_Equip("WS") end
    
    -- Rotation
    if BadAzs_Ready("Victory Rush") then BadAzs_Cast("Victory Rush") end 
    BadAzs_Cast("Shield Block")
    
    if UnitExists("targettarget") and not UnitIsUnit("targettarget", "player") then 
        BadAzs_Cast("Taunt") 
    end

    if BadAzs_Ready("Shield Slam") then BadAzs_Cast("Shield Slam") end
    BadAzs_Cast("Revenge")
    BadAzs_Cast("Sunder Armor") 
    
    -- Core impede cancelamento se HS já estiver ativo
    if rage > 50 then BadAzs_Cast("Heroic Strike") end
end

-- [[ ARMS (DUAL MODE) ]]
function BadAzsArms() 
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()
    
    local stance = BadAzs_GetStance()
    local thp = BadAzs_GetTargetHP() -- Função Global do Core
    local rage = UnitMana("player")
    local inCombat = UnitAffectingCombat("player")

    -- Gap Closer (Charge)
    if not inCombat and not CheckInteractDistance("target", 3) and BadAzs_Ready("Charge") then
        if stance ~= 1 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH"); return
        else BadAzs_Cast("Charge") end
    end

    -- Gap Closer (Intercept)
    if inCombat and IsControlKeyDown() and not CheckInteractDistance("target", 3) then
        if stance ~= 3 then BadAzs_Cast("Berserker Stance") else BadAzs_Cast("Intercept") end
        return
    end

    -- EXECUTE PHASE
    if thp > 0 and thp <= 20 then
        if stance == 2 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH") else BadAzs_Cast("Execute") end
        return 
    end

    -- Stance Check
    if stance ~= 1 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH"); return end
    if BadAzsDB.UseItemRack and BadAzs_HasOffHand() then BadAzs_Equip("TH") end

    -- Buffs
    if rage < 30 and inCombat and BadAzs_Ready("Bloodrage") then BadAzs_Cast("Bloodrage") end
    if BadAzs_Ready("Victory Rush") then BadAzs_Cast("Victory Rush") end

    -- Main Rotation
    BadAzs_Cast("Overpower") 
    
    if BadAzs_Ready("Mortal Strike") then BadAzs_Cast("Mortal Strike") 
    elseif BadAzs_Ready("Bloodthirst") then BadAzs_Cast("Bloodthirst") end
    
    local hasRend = BadAzs_TargetHasDebuff("Ability_Gouge")
    if not hasRend and thp > 20 then BadAzs_Cast("Rend") end

    -- [[ DUMP: SLAM vs HS ]]
    local slam_thresh = 15 
    local hs_thresh = 60    
    
    if BadAzsDB.DumpMode == "HS" then
        slam_thresh = 50 
        hs_thresh = 35   
    end

    -- Lógica de Slam Sincronizado (Usa dados globais do Core)
    local timeNow = GetTime()
    if (timeNow - LastSlamTime) > 3.0 then
        -- SP_ST_Data é global no Core
        if getglobal("SP_ST_Data") and SP_ST_Data.main_start then
            local swing = timeNow - SP_ST_Data.main_start
            if rage > slam_thresh and swing < 1.0 then 
                BadAzs_Cast("Slam"); LastSlamTime = timeNow 
            end
        elseif rage > (slam_thresh + 10) then 
            BadAzs_Cast("Slam"); LastSlamTime = timeNow 
        end
    end

    if rage > hs_thresh then BadAzs_Cast("Heroic Strike") end
    
    if not BadAzs_HasBuff("BattleShout") then BadAzs_Cast("Battle Shout") end
end

-- [[ FURY ]]
function BadAzsFury() 
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear() 
    
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    local inCombat = UnitAffectingCombat("player")
    
    -- Gap Closer
    if not inCombat and not CheckInteractDistance("target", 3) and BadAzs_Ready("Charge") then
        if stance ~= 1 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH"); return
        else BadAzs_Cast("Charge") end
    end

    if inCombat and IsControlKeyDown() and not CheckInteractDistance("target", 3) then
        if stance ~= 3 then BadAzs_Cast("Berserker Stance") else BadAzs_Cast("Intercept") end
        return
    end

    -- Stance Check
    if stance ~= 3 then BadAzs_Cast("Berserker Stance"); BadAzs_Equip("DW"); return end
    
    if BadAzsDB.UseItemRack and (BadAzs_HasShield() or not BadAzs_HasOffHand()) then
        BadAzs_Equip("DW")
    end
    
    -- Buffs
    if inCombat and BadAzs_Ready("Bloodrage") then BadAzs_Cast("Bloodrage") end
    if inCombat and BadAzs_Ready("Berserker Rage") then BadAzs_Cast("Berserker Rage") end
    if BadAzs_Ready("Victory Rush") then BadAzs_Cast("Victory Rush") end
    BadAzs_Cast("Blood Fury"); BadAzs_Cast("Berserking")

    -- Execute
    local thp = BadAzs_GetTargetHP()
    if thp > 0 and thp <= 20 then BadAzs_Cast("Execute"); return end 
    
    -- Rotation
    if BadAzs_Ready("Bloodthirst") then BadAzs_Cast("Bloodthirst") 
    elseif BadAzs_Ready("Mortal Strike") then BadAzs_Cast("Mortal Strike") end
    
    if BadAzs_Ready("Whirlwind") then BadAzs_Cast("Whirlwind") end
    
    local hs_thresh = 50
    if BadAzsDB.DumpMode == "HS" then hs_thresh = 35 end

    if rage > hs_thresh then BadAzs_Cast("Heroic Strike") end
    
    if not BadAzs_HasBuff("BattleShout") then BadAzs_Cast("Battle Shout") end
end

-- [[ UTILIDADE ]]
function BadAzsCrowd()
    BadAzs_Cast("Attack")
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    if stance == 1 then 
        BadAzs_Cast("Sweeping Strikes"); BadAzs_Cast("Thunder Clap")
        BadAzs_Cast("Berserker Stance"); BadAzs_Equip("TH") 
        return 
    end
    if stance == 3 then 
        BadAzs_Cast("Whirlwind"); if rage >= 20 then BadAzs_Cast("Cleave") end
        return
    end
    if stance == 2 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH") end
end

-- ============================================================
-- [3. SLASH COMMANDS ]
-- ============================================================
function BadAzs_ArmsWrapper() if IsAltKeyDown() then BadAzsCrowd() else BadAzsArms() end end
function BadAzs_FuryWrapper() if IsAltKeyDown() then BadAzsCrowd() else BadAzsFury() end end

SLASH_BACONFIG1 = "/baconfig"
SlashCmdList["BACONFIG"] = function(msg)
    msg = string.lower(msg)
    
    if string.find(msg, "itemrack on") then
        BadAzsDB.UseItemRack = true
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs]|r ItemRack: |cff00ff00LIGADO|r")
    elseif string.find(msg, "itemrack off") then
        BadAzsDB.UseItemRack = false
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs]|r ItemRack: |cffff0000DESLIGADO|r")
    elseif string.find(msg, "mode slam") then
        BadAzsDB.DumpMode = "SLAM"
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs]|r Prioridade: |cff00ccffSLAM FOCUS|r")
    elseif string.find(msg, "mode hs") then
        BadAzsDB.DumpMode = "HS"
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs]|r Prioridade: |cffffaa00HS FOCUS|r")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs Warrior Config]|r")
        local rackStatus = BadAzsDB.UseItemRack and "|cff00ff00ON|r" or "|cffff0000OFF|r"
        local modeStatus = (BadAzsDB.DumpMode == "SLAM") and "|cff00ccffSLAM|r" or "|cffffaa00HS|r"
        DEFAULT_CHAT_FRAME:AddMessage("ItemRack: " .. rackStatus)
        DEFAULT_CHAT_FRAME:AddMessage("Dump Mode: " .. modeStatus)
        DEFAULT_CHAT_FRAME:AddMessage("Comandos: /baconfig mode [slam | hs]")
    end
end

SLASH_BAFURY1 = "/bafury"; SlashCmdList["BAFURY"] = BadAzs_FuryWrapper
SLASH_BAARMS1 = "/baarms"; SlashCmdList["BAARMS"] = BadAzs_ArmsWrapper
SLASH_BATANK1 = "/batank"; SlashCmdList["BATANK"] = BadAzsTank
