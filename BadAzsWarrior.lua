-- [[ [|cff355E3BB|r]adAzs |cff32CD32Warrior|r ]]
-- Author:  ThePeregris
-- Version: 12.3 (Charge Logic Fix)
-- Target:  Turtle WoW (1.12.1)

local BadAzsVersion = "|cff355E3B[BadAzsWarrior v12.3 - Charge Fix]|r"
local LastSlamTime = 0 

-- ============================================================
-- [ CONFIGURAÇÃO ESTÁTICA ]
-- ============================================================
local BadAzsSets = { TwoHand = "TH", DualWield = "DW", Shield = "WS" }

-- ============================================================
-- [1. INICIALIZAÇÃO ]
-- ============================================================
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loadFrame:SetScript("OnEvent", function()
    if not BadAzsDB then BadAzsDB = { UseItemRack = false } end
    local block = {
        "fail", "not ready", "enough rage", "Another action", "range", 
        "No target", "recovered", "Ability", "Must be in", "nothing to attack", 
        "facing", "Unknown unit", "Inventory is full", "Cannot equip", 
        "Item is not ready", "Target needs to be", "You are dead", "spell is not learned"
    }
    for i = 1, 7 do
        local frame = _G["ChatFrame"..i]
        if frame and not frame.BHooked then
            local original = frame.AddMessage
            frame.AddMessage = function(self, msg, r, g, b, id)
                if msg and type(msg) == "string" then
                    for _, p in pairs(block) do if string.find(msg, p) then return end end
                end
                original(self, msg, r, g, b, id)
            end
            frame.BHooked = true
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage(BadAzsVersion)
end)

local SpellCache = {}
local _Cast = CastSpellByName

local function GetSpellID(spellName)
    if SpellCache[spellName] then return SpellCache[spellName] end
    for i = 1, 200 do
        local n = GetSpellName(i, "spell")
        if not n then break end
        if n == spellName then SpellCache[spellName] = i return i end
    end
    return nil
end

function BadAzs_Ready(spellName)
    if UnitXP_SP3_Addon and UnitXP_SP3_Addon.SpellReady then
        return UnitXP_SP3_Addon.SpellReady(spellName)
    end
    local id = GetSpellID(spellName)
    if not id then return false end
    local start, duration = GetSpellCooldown(id, "spell")
    return start == 0
end

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

local attacking = false
local f = CreateFrame'Frame'
f:RegisterEvent'PLAYER_ENTER_COMBAT'; f:RegisterEvent'PLAYER_LEAVE_COMBAT'
f:SetScript('OnEvent', function() attacking = (event == 'PLAYER_ENTER_COMBAT') end)

function BadAzs_Cast(t) 
    if t == "Attack" and attacking then return end 
    _Cast(t) 
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

function BadAzs_HasBuff(texturePartialName)
    for i=0, 31 do
        local texture = GetPlayerBuffTexture(i)
        if texture and string.find(texture, texturePartialName) then return true end
    end
    return false
end

-- ============================================================
-- [2. MÓDULOS DE COMBATE]
-- ============================================================

-- [[ TANK ]]
function BadAzsTank()
    if not attacking then AttackTarget() end 
    UIErrorsFrame:Clear()
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    
    if stance ~= 2 then BadAzs_Cast("Defensive Stance"); BadAzs_Equip("WS"); return end
    if BadAzsDB.UseItemRack and not BadAzs_HasShield() then BadAzs_Equip("WS") end
    
    BadAzs_Cast("Shield Block"); BadAzs_Cast("Thunder Clap")
    
    if UnitExists("targettarget") and not UnitIsUnit("targettarget", "player") then 
        BadAzs_Cast("Taunt") 
    end
    if BadAzs_Ready("Shield Slam") then BadAzs_Cast("Shield Slam") end
    BadAzs_Cast("Revenge"); BadAzs_Cast("Sunder Armor") 
    if rage > 50 then BadAzs_Cast("Heroic Strike") end
end

-- [[ ARMS (FIXED CHARGE) ]]
function BadAzsArms() 
    if not attacking then AttackTarget() end 
    UIErrorsFrame:Clear()
    
    local stance = BadAzs_GetStance()
    local thp = UnitHealth("target")/UnitHealthMax("target")*100
    local rage = UnitMana("player")
    local inCombat = UnitAffectingCombat("player")

    -- [[ GAP CLOSER (CHARGE) FIX ]]
    -- Só tenta se: Fora de Combate + Longe + Charge Pronto
    if not inCombat and not CheckInteractDistance("target", 3) and BadAzs_Ready("Charge") then
        if stance ~= 1 then 
            BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH")
            return -- Return necessário para troca de postura
        else 
            BadAzs_Cast("Charge") 
            -- SEM RETURN AQUI: Se falhar (distância), continua o script.
        end
    end

    -- Intercept (Safety CTRL)
    if inCombat and IsControlKeyDown() and not CheckInteractDistance("target", 3) then
        if stance ~= 3 then BadAzs_Cast("Berserker Stance") else BadAzs_Cast("Intercept") end
        return
    end

    -- Fase Execute
    if thp <= 20 then
        if stance == 2 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH") else BadAzs_Cast("Execute") end
        return
    end

    if stance ~= 1 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH"); return end
    if BadAzsDB.UseItemRack and BadAzs_HasOffHand() then BadAzs_Equip("TH") end

    if rage < 30 and inCombat then BadAzs_Cast("Bloodrage") end

    BadAzs_Cast("Overpower") 
    
    if BadAzs_Ready("Mortal Strike") then BadAzs_Cast("Mortal Strike") 
    elseif BadAzs_Ready("Bloodthirst") then BadAzs_Cast("Bloodthirst") end
    
    if BadAzs_Ready("Master Strike") then BadAzs_Cast("Master Strike") end

    local hasRend = false
    for i=1,16 do local t = UnitDebuff("target", i); if t and string.find(t, "Ability_Gouge") then hasRend=true break end end
    if not hasRend and thp > 20 then BadAzs_Cast("Rend") end

    -- Slam Anti-Clip (3.0s)
    local timeNow = GetTime()
    if (timeNow - LastSlamTime) > 3.0 then
        if SP_ST_Data and SP_ST_Data.main_start then
            local swing = timeNow - SP_ST_Data.main_start
            if rage > 15 and swing < 1.0 then 
                BadAzs_Cast("Slam"); LastSlamTime = timeNow 
            end
        elseif rage > 25 then 
            BadAzs_Cast("Slam"); LastSlamTime = timeNow 
        end
    end

    if rage > 60 then BadAzs_Cast("Heroic Strike") end
    if not BadAzs_HasBuff("BattleShout") then BadAzs_Cast("Battle Shout") end
end

-- [[ FURY (FIXED CHARGE) ]]
function BadAzsFury() 
    if not attacking then AttackTarget() end 
    UIErrorsFrame:Clear() 
    
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    local inCombat = UnitAffectingCombat("player")
    
    -- Gap Closer Fix
    if not inCombat and not CheckInteractDistance("target", 3) and BadAzs_Ready("Charge") then
        if stance ~= 1 then 
            BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH")
            return
        else 
            BadAzs_Cast("Charge") 
        end
    end

    if inCombat and IsControlKeyDown() and not CheckInteractDistance("target", 3) then
        if stance ~= 3 then BadAzs_Cast("Berserker Stance") else BadAzs_Cast("Intercept") end
        return
    end

    if stance ~= 3 then BadAzs_Cast("Berserker Stance"); BadAzs_Equip("DW"); return end
    
    if BadAzsDB.UseItemRack and (BadAzs_HasShield() or not BadAzs_HasOffHand()) then
        BadAzs_Equip("DW")
    end
    
    if inCombat then BadAzs_Cast("Bloodrage"); BadAzs_Cast("Berserker Rage") end
    BadAzs_Cast("Victory Rush"); BadAzs_Cast("Blood Fury"); BadAzs_Cast("Berserking")

    local thp = UnitHealth("target")/UnitHealthMax("target")*100
    if thp <= 20 then BadAzs_Cast("Execute"); return end
    
    if BadAzs_Ready("Bloodthirst") then BadAzs_Cast("Bloodthirst") 
    elseif BadAzs_Ready("Mortal Strike") then BadAzs_Cast("Mortal Strike") end
    
    if BadAzs_Ready("Whirlwind") then BadAzs_Cast("Whirlwind") end
    if BadAzs_Ready("Master Strike") then BadAzs_Cast("Master Strike") end
    
    if rage > 60 then BadAzs_Cast("Heroic Strike") end
    if not BadAzs_HasBuff("BattleShout") then BadAzs_Cast("Battle Shout") end
end

-- [[ UTILIDADE ]]
function BadAzsCrowd()
    if not attacking then AttackTarget() end 
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
-- [3. SLASH COMMANDS]
-- ============================================================
function BadAzs_ArmsWrapper() if IsAltKeyDown() then BadAzsCrowd() else BadAzsArms() end end
function BadAzs_FuryWrapper() if IsAltKeyDown() then BadAzsCrowd() else BadAzsFury() end end

SLASH_BADAZSCMD1 = "/badazs"
SlashCmdList["BADAZSCMD"] = function(msg)
    msg = string.lower(msg)
    if string.find(msg, "itemrack on") then
        BadAzsDB.UseItemRack = true
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs]|r ItemRack: |cff00ff00LIGADO|r")
    elseif string.find(msg, "itemrack off") then
        BadAzsDB.UseItemRack = false
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs]|r ItemRack: |cffff0000DESLIGADO|r")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs Config]|r")
        local status = BadAzsDB.UseItemRack and "|cff00ff00LIGADO|r" or "|cffff0000DESLIGADO|r"
        DEFAULT_CHAT_FRAME:AddMessage("ItemRack Swap: " .. status)
        DEFAULT_CHAT_FRAME:AddMessage("Use: /badazs itemrack on | off")
    end
end

SLASH_BFURY1 = "/bfury"; SlashCmdList["BFURY"] = BadAzs_FuryWrapper
SLASH_BARMS1 = "/barms"; SlashCmdList["BARMS"] = BadAzs_ArmsWrapper
SLASH_BTANK1 = "/btank"; SlashCmdList["BTANK"] = BadAzsTank
