-- [[ [|cff355E3BB|r]adAzs |cff32CD32Warrior|r ]]
-- Author:  ThePeregris & Gemini
-- Version: 17.5 (Core v2.3 Integrated)
-- Target:  Turtle WoW (1.12 / LUA 5.0)
-- Requires: BadAzs Core v2.3+

local BadAzsVersion = "|cff355E3B[BadAzsWarrior v17.5]|r"
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
    if not BadAzsDB then BadAzsDB = { UseItemRack = false, DumpMode = "SLAM" } end
    DEFAULT_CHAT_FRAME:AddMessage(BadAzsVersion .. " Loaded. Ready for Battle.")
end)

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

-- [[ TANK PRO (Target Lock & Charge) ]]
function BadAzsTank()
    UIErrorsFrame:Clear()
    if not UnitExists("target") then return end -- Trava de segurança
    
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    local lastDodge = getglobal("BadAzs_LastDodge") or 0
    local timeNow = GetTime()
    local inCombat = UnitAffectingCombat("player")

    -- [1] GAP CLOSER (Charge de Abertura)
    if not inCombat and not CheckInteractDistance("target", 3) then
        if BadAzs_Ready("Charge") then
            if stance ~= 1 then BadAzs_Cast("Battle Stance"); return 
            else BadAzs_Cast("Charge"); return end
        end
    end

    BadAzs_Cast("Attack")
    
    -- [2] STANCE DANCE: OVERPOWER (SAFE MODE)
    if (timeNow - lastDodge) < 4 and BadAzs_Ready("Overpower") and rage >= 5 and rage < 30 then
        if stance == 2 then BadAzs_Cast("Battle Stance"); return end 
        if stance == 1 then BadAzs_Cast("Overpower"); return end     
    end

    -- [3] SEGURANÇA E EQUIPAMENTO
    if stance ~= 2 then BadAzs_Cast("Defensive Stance"); BadAzs_Equip("WS"); return end
    if BadAzsDB.UseItemRack and not BadAzs_HasShield() then BadAzs_Equip("WS") end
    
    -- [4] GERAÇÃO DE RAIVA (BLOODRAGE)
    if inCombat and BadAzs_Ready("Bloodrage") then BadAzs_Cast("Bloodrage") end
    
    -- [5] ROTAÇÃO DE AMEAÇA
    if UnitExists("targettarget") and not UnitIsUnit("targettarget", "player") then 
        BadAzs_Cast("Taunt") 
    end

    if BadAzs_Ready("Shield Slam") then BadAzs_Cast("Shield Slam") end
    BadAzs_Cast("Revenge")
    if BadAzs_Ready("Victory Rush") then BadAzs_Cast("Victory Rush") end

    if not BadAzs_HasBuff("Ability_Defend") and rage >= 10 then BadAzs_Cast("Shield Block") end
    if not BadAzs_TargetHasDebuff("Ability_Warrior_WarCry") and rage >= 10 then BadAzs_Cast("Demoralizing Shout") end
    if not BadAzs_HasBuff("BattleShout") and rage >= 10 then BadAzs_Cast("Battle Shout") end
    
    if rage >= 15 then BadAzs_Cast("Sunder Armor") end
    if rage > 55 then BadAzs_Cast("Heroic Strike") end
end

-- [[ ARMS ]]
function BadAzsArms() 
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()
    
    local stance = BadAzs_GetStance()
    local thp = BadAzs_GetTargetHP()
    local rage = UnitMana("player")
    local inCombat = UnitAffectingCombat("player")

    if not inCombat and not CheckInteractDistance("target", 3) and BadAzs_Ready("Charge") then
        if stance ~= 1 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH"); return
        else BadAzs_Cast("Charge") end
    end

    if inCombat and IsControlKeyDown() and not CheckInteractDistance("target", 3) then
        if stance ~= 3 then BadAzs_Cast("Berserker Stance") else BadAzs_Cast("Intercept") end
        return
    end

    if thp > 0 and thp <= 20 then
        if stance == 2 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH") else BadAzs_Cast("Execute") end
        return 
    end

    if stance ~= 1 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH"); return end
    if rage < 30 and inCombat and BadAzs_Ready("Bloodrage") then BadAzs_Cast("Bloodrage") end
    if BadAzs_Ready("Victory Rush") then BadAzs_Cast("Victory Rush") end

    BadAzs_Cast("Overpower") 
    if BadAzs_Ready("Mortal Strike") then BadAzs_Cast("Mortal Strike") 
    elseif BadAzs_Ready("Bloodthirst") then BadAzs_Cast("Bloodthirst") end
    
    if not BadAzs_TargetHasDebuff("Ability_Gouge") and thp > 20 then BadAzs_Cast("Rend") end

    -- DUMP
    local slam_t = (BadAzsDB.DumpMode == "HS") and 50 or 15
    local hs_t = (BadAzsDB.DumpMode == "HS") and 35 or 60
    local timeNow = GetTime()
    if (timeNow - LastSlamTime) > 3.0 then
        if getglobal("SP_ST_Data") and SP_ST_Data.main_start then
            local swing = timeNow - SP_ST_Data.main_start
            if rage > slam_t and swing < 1.0 then BadAzs_Cast("Slam"); LastSlamTime = timeNow end
        elseif rage > (slam_t + 10) then BadAzs_Cast("Slam"); LastSlamTime = timeNow end
    end

    if rage > hs_t then BadAzs_Cast("Heroic Strike") end
    if not BadAzs_HasBuff("BattleShout") then BadAzs_Cast("Battle Shout") end
end

-- [[ FURY ]]
function BadAzsFury() 
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear() 
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    local inCombat = UnitAffectingCombat("player")
    
    if stance ~= 3 then BadAzs_Cast("Berserker Stance"); BadAzs_Equip("DW"); return end
    if inCombat and BadAzs_Ready("Bloodrage") then BadAzs_Cast("Bloodrage") end
    if inCombat and BadAzs_Ready("Berserker Rage") then BadAzs_Cast("Berserker Rage") end
    BadAzs_Cast("Blood Fury"); BadAzs_Cast("Berserking")

    local thp = BadAzs_GetTargetHP()
    if thp > 0 and thp <= 20 then BadAzs_Cast("Execute"); return end 
    
    if BadAzs_Ready("Bloodthirst") then BadAzs_Cast("Bloodthirst") 
    elseif BadAzs_Ready("Mortal Strike") then BadAzs_Cast("Mortal Strike") end
    if BadAzs_Ready("Whirlwind") then BadAzs_Cast("Whirlwind") end
    
    local hs_t = (BadAzsDB.DumpMode == "HS") and 35 or 50
    if rage > hs_t then BadAzs_Cast("Heroic Strike") end
    if not BadAzs_HasBuff("BattleShout") then BadAzs_Cast("Battle Shout") end
end

-- [[ UTILIDADE ]]
function BadAzsCrowd()
    BadAzs_Cast("Attack")
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    if stance == 1 then 
        BadAzs_Cast("Sweeping Strikes"); BadAzs_Cast("Thunder Clap")
        BadAzs_Cast("Berserker Stance"); BadAzs_Equip("TH"); return 
    end
    if stance == 3 then 
        BadAzs_Cast("Whirlwind"); if rage >= 20 then BadAzs_Cast("Cleave") end; return
    end
    if stance == 2 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH") end
end

-- [[ UTILITY: Intervene (Usa a Via Rápida do Core) ]]
function BadAzsIntervene()
    local stance = BadAzs_GetStance()    
    if stance ~= 2 then BadAzs_Cast("Defensive Stance"); return end
    BadAzs_Util("Intervene")
end

-- ============================================================
-- [3. SLASH COMMANDS ]
-- ============================================================
function BadAzs_ArmsWrapper() if IsAltKeyDown() then BadAzsCrowd() else BadAzsArms() end end
function BadAzs_FuryWrapper() if IsAltKeyDown() then BadAzsCrowd() else BadAzsFury() end end

SLASH_BACONFIG1 = "/baconfig"
SlashCmdList["BACONFIG"] = function(msg)
    msg = string.lower(msg)
    if string.find(msg, "itemrack on") then BadAzsDB.UseItemRack = true; DEFAULT_CHAT_FRAME:AddMessage("ItemRack: ON")
    elseif string.find(msg, "itemrack off") then BadAzsDB.UseItemRack = false; DEFAULT_CHAT_FRAME:AddMessage("ItemRack: OFF")
    elseif string.find(msg, "mode slam") then BadAzsDB.DumpMode = "SLAM"; DEFAULT_CHAT_FRAME:AddMessage("Mode: SLAM")
    elseif string.find(msg, "mode hs") then BadAzsDB.DumpMode = "HS"; DEFAULT_CHAT_FRAME:AddMessage("Mode: HS")
    else DEFAULT_CHAT_FRAME:AddMessage("/baconfig mode slam/hs | itemrack on/off") end
end

SLASH_BAFURY1 = "/bafury"; SlashCmdList["BAFURY"] = BadAzs_FuryWrapper
SLASH_BAARMS1 = "/baarms"; SlashCmdList["BAARMS"] = BadAzs_ArmsWrapper
SLASH_BATANK1 = "/batank"; SlashCmdList["BATANK"] = BadAzsTank
