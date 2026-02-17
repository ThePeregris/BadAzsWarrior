-- [[ [|cff355E3BB|r]adAzs |cff32CD32Warrior|r ]]
-- Author:  ThePeregris & Gemini
-- Version: 17.4 (Self-Sufficient Cache)
-- Target:  Turtle WoW (1.12 / LUA 5.0)
-- Requires: BadAzs Core v2.3+

local BadAzsVersion = "|cff355E3B[BadAzsWarrior v17.4]|r"
local LastSlamTime = 0 

-- Cache Local Exclusivo do Guerreiro
local WarriorSlotCache = { 
    ["Heroic Strike"] = nil, 
    ["Cleave"] = nil 
}

local BadAzsSets = { TwoHand = "TH", DualWield = "DW", Shield = "WS" }

local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loadFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED") -- Agora o Warrior monitora suas barras
loadFrame:SetScript("OnEvent", function()
    
    if event == "PLAYER_ENTERING_WORLD" then
        if not BadAzsDB then BadAzsDB = { UseItemRack = false, DumpMode = "SLAM" } end
        DEFAULT_CHAT_FRAME:AddMessage(BadAzsVersion .. " Loaded.")
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[Mode]|r: " .. (BadAzsDB.DumpMode or "SLAM") .. " Focus")
    end

    -- Scanner de Barras (Trazido do Core para cá)
    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_SLOT_CHANGED" then
        for k in pairs(WarriorSlotCache) do WarriorSlotCache[k] = nil end
        
        for i = 1, 120 do
            if HasAction(i) then
                local texture = GetActionTexture(i)
                if texture then
                    -- Procura apenas magias de Warrior que precisam de "Next Melee" check
                    -- Texture de Cleave e Heroic Strike (dependendo do client, HS pode ter texture de Ambush ou Attack)
                    if string.find(texture, "Ability_Warrior_Cleave") or 
                       string.find(texture, "Ability_Rogue_Ambush") or 
                       string.find(texture, "Ability_MeleeDamage") then
                        
                        -- Usa o scanner global do Core (que é apenas uma ferramenta)
                        BadAzs_TooltipScanner:SetAction(i)
                        local name = BadAzs_TooltipScannerTextLeft1:GetText()
                        
                        if name and WarriorSlotCache[name] ~= nil then 
                            WarriorSlotCache[name] = i
                        end
                    end
                end
            end
        end
    end
end)

-- Função Local de Cast Seguro para Warrior
local function BadAzsW_Cast(spellName)
    -- Verifica cache local para evitar toggle off
    local slot = WarriorSlotCache[spellName]
    if slot and IsCurrentAction(slot) then return end
    
    -- Chama o Core para executar o ataque no target
    BadAzs_Cast(spellName)
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

-- [[ TANK PRO ]]
function BadAzsTank()
    BadAzsW_Cast("Attack")
    UIErrorsFrame:Clear()
    
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    local lastDodge = getglobal("BadAzs_LastDodge") or 0
    local timeNow = GetTime()

    -- [PRIORIDADE ZERO] HEROIC STRIKE (Rage Dump)
    if rage > 60 then BadAzsW_Cast("Heroic Strike") end

    -- [1] STANCE DANCE: OVERPOWER
    if (timeNow - lastDodge) < 4 and BadAzs_Ready("Overpower") and rage >= 5 and rage < 30 then
        if stance == 2 then BadAzsW_Cast("Battle Stance"); return end 
        if stance == 1 then BadAzsW_Cast("Overpower"); return end      
    end

    -- [2] SEGURANÇA E EQUIPAMENTO
    if stance ~= 2 then BadAzsW_Cast("Defensive Stance"); BadAzs_Equip("WS"); return end
    if BadAzsDB.UseItemRack and not BadAzs_HasShield() then BadAzs_Equip("WS") end
    
    -- [3] ROTAÇÃO DE AMEAÇA
    if UnitExists("targettarget") and not UnitIsUnit("targettarget", "player") then 
        BadAzsW_Cast("Taunt") 
    end

    if BadAzs_Ready("Shield Slam") then BadAzsW_Cast("Shield Slam") end
    BadAzsW_Cast("Revenge")

    if BadAzs_Ready("Victory Rush") then BadAzsW_Cast("Victory Rush") end

    if not BadAzs_HasBuff("Ability_Defend") and rage >= 10 then 
        BadAzsW_Cast("Shield Block") 
    end

    if not BadAzs_TargetHasDebuff("Ability_Warrior_WarCry") and rage >= 10 then
        BadAzsW_Cast("Demoralizing Shout")
    end

    if rage >= 15 then BadAzsW_Cast("Sunder Armor") end
end

-- [[ ARMS (DUAL MODE) ]]
function BadAzsArms() 
    BadAzsW_Cast("Attack")
    UIErrorsFrame:Clear()
    
    local stance = BadAzs_GetStance()
    local thp = BadAzs_GetTargetHP()
    local rage = UnitMana("player")
    local inCombat = UnitAffectingCombat("player")

    if not inCombat and not CheckInteractDistance("target", 3) and BadAzs_Ready("Charge") then
        if stance ~= 1 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("TH"); return
        else BadAzsW_Cast("Charge") end
    end

    if inCombat and IsControlKeyDown() and not CheckInteractDistance("target", 3) then
        if stance ~= 3 then BadAzsW_Cast("Berserker Stance") else BadAzsW_Cast("Intercept") end
        return
    end

    if thp > 0 and thp <= 20 then
        if stance == 2 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("TH") else BadAzsW_Cast("Execute") end
        return 
    end

    if stance ~= 1 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("TH"); return end
    if BadAzsDB.UseItemRack and BadAzs_HasOffHand() then BadAzs_Equip("TH") end

    if rage < 30 and inCombat and BadAzs_Ready("Bloodrage") then BadAzsW_Cast("Bloodrage") end
    if BadAzs_Ready("Victory Rush") then BadAzsW_Cast("Victory Rush") end

    BadAzsW_Cast("Overpower") 
    
    if BadAzs_Ready("Mortal Strike") then BadAzsW_Cast("Mortal Strike") 
    elseif BadAzs_Ready("Bloodthirst") then BadAzsW_Cast("Bloodthirst") end
    
    local hasRend = BadAzs_TargetHasDebuff("Ability_Gouge")
    if not hasRend and thp > 20 then BadAzsW_Cast("Rend") end

    -- [[ DUMP: SLAM vs HS ]]
    local slam_thresh = 15 
    local hs_thresh = 60    
    if BadAzsDB.DumpMode == "HS" then
        slam_thresh = 50; hs_thresh = 35    
    end

    local timeNow = GetTime()
    if (timeNow - LastSlamTime) > 3.0 then
        if getglobal("SP_ST_Data") and SP_ST_Data.main_start then
            local swing = timeNow - SP_ST_Data.main_start
            if rage > slam_thresh and swing < 1.0 then 
                BadAzsW_Cast("Slam"); LastSlamTime = timeNow 
            end
        elseif rage > (slam_thresh + 10) then 
            BadAzsW_Cast("Slam"); LastSlamTime = timeNow 
        end
    end

    if rage > hs_thresh then BadAzsW_Cast("Heroic Strike") end
    if not BadAzs_HasBuff("BattleShout") then BadAzsW_Cast("Battle Shout") end
end

-- [[ FURY ]]
function BadAzsFury() 
    BadAzsW_Cast("Attack")
    UIErrorsFrame:Clear() 
    
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    local inCombat = UnitAffectingCombat("player")
    
    if not inCombat and not CheckInteractDistance("target", 3) and BadAzs_Ready("Charge") then
        if stance ~= 1 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("TH"); return
        else BadAzsW_Cast("Charge") end
    end

    if inCombat and IsControlKeyDown() and not CheckInteractDistance("target", 3) then
        if stance ~= 3 then BadAzsW_Cast("Berserker Stance") else BadAzsW_Cast("Intercept") end
        return
    end

    if stance ~= 3 then BadAzsW_Cast("Berserker Stance"); BadAzs_Equip("DW"); return end
    
    if BadAzsDB.UseItemRack and (BadAzs_HasShield() or not BadAzs_HasOffHand()) then
        BadAzs_Equip("DW")
    end
    
    if inCombat and BadAzs_Ready("Bloodrage") then BadAzsW_Cast("Bloodrage") end
    if inCombat and BadAzs_Ready("Berserker Rage") then BadAzsW_Cast("Berserker Rage") end
    if BadAzs_Ready("Victory Rush") then BadAzsW_Cast("Victory Rush") end
    BadAzsW_Cast("Blood Fury"); BadAzsW_Cast("Berserking")

    local thp = BadAzs_GetTargetHP()
    if thp > 0 and thp <= 20 then BadAzsW_Cast("Execute"); return end 
    
    if BadAzs_Ready("Bloodthirst") then BadAzsW_Cast("Bloodthirst") 
    elseif BadAzs_Ready("Mortal Strike") then BadAzsW_Cast("Mortal Strike") end
    
    if BadAzs_Ready("Whirlwind") then BadAzsW_Cast("Whirlwind") end
    
    local hs_thresh = 50
    if BadAzsDB.DumpMode == "HS" then hs_thresh = 35 end

    if rage > hs_thresh then BadAzsW_Cast("Heroic Strike") end
    
    if not BadAzs_HasBuff("BattleShout") then BadAzsW_Cast("Battle Shout") end
end

-- [[ UTILIDADE ]]
function BadAzsCrowd()
    BadAzsW_Cast("Attack")
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    if stance == 1 then 
        BadAzsW_Cast("Sweeping Strikes"); BadAzsW_Cast("Thunder Clap")
        BadAzsW_Cast("Berserker Stance"); BadAzs_Equip("TH") 
        return 
    end
    if stance == 3 then 
        BadAzsW_Cast("Whirlwind"); if rage >= 20 then BadAzsW_Cast("Cleave") end
        return
    end
    if stance == 2 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("TH") end
end

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
