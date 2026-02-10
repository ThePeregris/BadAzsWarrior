-- [[ [|cff355E3BB|r]adAzs |cff32CD32Warrior|r ]]
-- Author:  ThePeregris & Gemini
-- Version: 16.1 (Tooltip Fix)
-- Target:  Turtle WoW (1.12 / LUA 5.0)

local BadAzsVersion = "|cff355E3B[BadAzsWarrior v16.1]|r"
local LastSlamTime = 0 

-- ============================================================
-- [ CONFIGURAÇÃO ESTÁTICA ]
-- ============================================================
local BadAzsSets = { TwoHand = "TH", DualWield = "DW", Shield = "WS" }
local _Cast = CastSpellByName

local BadAzs_SlotCache = { ["Heroic Strike"] = nil, ["Cleave"] = nil }

CreateFrame("GameTooltip", "BadAzs_TooltipScanner", nil, "GameTooltipTemplate")
BadAzs_TooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE")

-- ============================================================
-- [1. INICIALIZAÇÃO E UTILITÁRIOS]
-- ============================================================
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loadFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
loadFrame:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        if not BadAzsDB then BadAzsDB = { UseItemRack = false, DumpMode = "SLAM" } end
        
        -- Filtro de Spam do Chat
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
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[Mode]|r: " .. (BadAzsDB.DumpMode or "SLAM") .. " Focus")
    end

    -- Atualiza Cache de Slots (Procura onde o jogador colocou HS e Cleave)
    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_SLOT_CHANGED" then
        BadAzs_SlotCache["Heroic Strike"] = nil
        BadAzs_SlotCache["Cleave"] = nil
        for i = 1, 120 do
            if HasAction(i) then
                local texture = GetActionTexture(i)
                if texture then
                    -- Icones Classicos 1.12
                    if string.find(texture, "Ability_Rogue_Ambush") or string.find(texture, "Ability_Warrior_Cleave") then 
                        -- Verifica Tooltip para ter certeza absoluta do nome
                        BadAzs_TooltipScanner:SetAction(i)
                        -- CORREÇÃO AQUI: O nome da variavel deve incluir "Scanner"
                        local name = BadAzs_TooltipScannerTextLeft1:GetText()
                        
                        if name == "Heroic Strike" then 
                            BadAzs_SlotCache["Heroic Strike"] = i 
                        elseif name == "Cleave" then
                            BadAzs_SlotCache["Cleave"] = i
                        end
                    end
                end
            end
        end
    end
end)

-- Verifica se uma magia "Next Melee" (HS/Cleave) já está ativa para não cancelar
function BadAzs_IsQueued(spellName)
    local slot = BadAzs_SlotCache[spellName]
    if slot and IsCurrentAction(slot) then
        return true
    end
    return false
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

function BadAzs_Cast(t) 
    if t == "Attack" then 
        if BadAzs_StartAttack then BadAzs_StartAttack() else AttackTarget() end
        return 
    end
    -- Proteção contra Toggle do HS/Cleave
    if (t == "Heroic Strike" or t == "Cleave") and BadAzs_IsQueued(t) then
        return -- Já está ativo, não casta de novo
    end
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

-- ============================================================
-- [2. MÓDULOS DE COMBATE]
-- ============================================================

-- [[ TANK ]]
function BadAzsTank()
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    
    if stance ~= 2 then BadAzs_Cast("Defensive Stance"); BadAzs_Equip("WS"); return end
    if BadAzsDB.UseItemRack and not BadAzs_HasShield() then BadAzs_Equip("WS") end
    
    if BadAzs_Ready("Victory Rush") then BadAzs_Cast("Victory Rush") end 
    BadAzs_Cast("Shield Block"); 
    
    if UnitExists("targettarget") and not UnitIsUnit("targettarget", "player") then 
        BadAzs_Cast("Taunt") 
    end

    if BadAzs_Ready("Shield Slam") then BadAzs_Cast("Shield Slam") end
    BadAzs_Cast("Revenge")
    BadAzs_Cast("Sunder Armor") 
    
    if rage > 50 then BadAzs_Cast("Heroic Strike") end
end

-- [[ ARMS (DUAL MODE) ]]
function BadAzsArms() 
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()
    
    local stance = BadAzs_GetStance()
    local thp = (BadAzs_GetTargetHP and BadAzs_GetTargetHP()) or 100
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

    -- EXECUTE PHASE
    if thp > 0 and thp <= 20 then
        if stance == 2 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH") else BadAzs_Cast("Execute") end
        return 
    end

    if stance ~= 1 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH"); return end
    if BadAzsDB.UseItemRack and BadAzs_HasOffHand() then BadAzs_Equip("TH") end

    if rage < 30 and inCombat and BadAzs_Ready("Bloodrage") then BadAzs_Cast("Bloodrage") end
    
    if BadAzs_Ready("Victory Rush") then BadAzs_Cast("Victory Rush") end

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

    local timeNow = GetTime()
    if (timeNow - LastSlamTime) > 3.0 then
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
    
    if not inCombat and not CheckInteractDistance("target", 3) and BadAzs_Ready("Charge") then
        if stance ~= 1 then BadAzs_Cast("Battle Stance"); BadAzs_Equip("TH"); return
        else BadAzs_Cast("Charge") end
    end

    if inCombat and IsControlKeyDown() and not CheckInteractDistance("target", 3) then
        if stance ~= 3 then BadAzs_Cast("Berserker Stance") else BadAzs_Cast("Intercept") end
        return
    end

    if stance ~= 3 then BadAzs_Cast("Berserker Stance"); BadAzs_Equip("DW"); return end
    
    if BadAzsDB.UseItemRack and (BadAzs_HasShield() or not BadAzs_HasOffHand()) then
        BadAzs_Equip("DW")
    end
    
    if inCombat and BadAzs_Ready("Bloodrage") then BadAzs_Cast("Bloodrage") end
    if inCombat and BadAzs_Ready("Berserker Rage") then BadAzs_Cast("Berserker Rage") end
    
    if BadAzs_Ready("Victory Rush") then BadAzs_Cast("Victory Rush") end
    BadAzs_Cast("Blood Fury"); BadAzs_Cast("Berserking")

    local thp = (BadAzs_GetTargetHP and BadAzs_GetTargetHP()) or 100
    if thp > 0 and thp <= 20 then BadAzs_Cast("Execute"); return end 
    
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
-- [3. SLASH COMMANDS E CONTROLES]
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
    elseif string.find(msg, "mode slam") then
        BadAzsDB.DumpMode = "SLAM"
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs]|r Prioridade: |cff00ccffSLAM FOCUS|r")
    elseif string.find(msg, "mode hs") then
        BadAzsDB.DumpMode = "HS"
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs]|r Prioridade: |cffffaa00HS FOCUS|r")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff355E3B[BadAzs Config]|r")
        local rackStatus = BadAzsDB.UseItemRack and "|cff00ff00ON|r" or "|cffff0000OFF|r"
        local modeStatus = (BadAzsDB.DumpMode == "SLAM") and "|cff00ccffSLAM|r" or "|cffffaa00HS|r"
        DEFAULT_CHAT_FRAME:AddMessage("ItemRack: " .. rackStatus)
        DEFAULT_CHAT_FRAME:AddMessage("Dump Mode: " .. modeStatus)
        DEFAULT_CHAT_FRAME:AddMessage("Comandos: /badazs mode [slam | hs]")
    end
end

SLASH_BFURY1 = "/bfury"; SlashCmdList["BFURY"] = BadAzs_FuryWrapper
SLASH_BARMS1 = "/barms"; SlashCmdList["BARMS"] = BadAzs_ArmsWrapper
SLASH_BTANK1 = "/btank"; SlashCmdList["BTANK"] = BadAzsTank