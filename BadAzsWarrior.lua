-- [[ [|cff355E3BB|r]adAzs |cffC79C6EWarrior|r ]]
-- Author:  ThePeregris
-- Version: 18.2 (Self-Sufficient + Book Panel + Localizacao EN/PT)
-- Target:  Vanilla/Classic WoW (1.12 / LUA 5.0)
-- Requires: BadAzs Core (apenas utilitários universais: Vision/Focus/Racial)

local BadAzsVersion = "|cff355E3B[BadAzsWarrior v18.2]|r"
local LastSlamTime = 0

-- ==========================================================
-- LOCALIZACAO (EN padrao / PT alternativo)
-- ==========================================================
local BadAzsWar_L = {
    EN = {
        loaded        = "Loaded. Type /badazs warrior to configure.",
        title         = "BadAzs Warrior",
        profileArms    = "Arms (Battle Stance)",
        profileFury    = "Fury (Berserker Stance)",
        profileDefense = "Defense (Defensive Stance)",
        slamRage      = "Minimum Rage - Slam: ",
        hsRage        = "Minimum Rage - Heroic Strike: ",
        presetSlam    = "Preset Slam",
        presetHS      = "Preset Heroic Strike",
        itemrackLabel = "Enable ItemRack usage",
        itemrackSub   = "(automatic gear swap per build)",
        explainArms    = "Used whenever you run /baarms, regardless of what weapon is physically equipped. Slam fires on your swing timer; Heroic Strike dumps leftover rage. Both thresholds are yours to tune.",
        explainFury    = "Used whenever you run /bafury. No Slam here - Heroic Strike alone handles the rage dump between auto-attacks.",
        explainDefense = "Used whenever you run /batank. Controls how much rage you keep in reserve before topping off with Heroic Strike on top of your threat rotation.",
        explainRack   = "Requires the ItemRack addon with sets named exactly Arms, Fury and Defense. When enabled, gear swaps automatically to match the build you're running - not what's physically equipped.",
        cmdHeader     = "Macros",
        cmdList = {
            "/baarms - Arms rotation",
            "/bafury - Fury rotation",
            "/batank - Protection rotation",
            "Hold ALT - AoE rotation",
            "/badazs warrior - Open this panel"
        }
    },
    PT = {
        loaded        = "Carregado. Digite /badazs warrior para configurar.",
        title         = "BadAzs Warrior",
        profileArms    = "Arms (Battle Stance)",
        profileFury    = "Fury (Berserker Stance)",
        profileDefense = "Defense (Defensive Stance)",
        slamRage      = "Rage minima - Slam: ",
        hsRage        = "Rage minima - Heroic Strike: ",
        presetSlam    = "Preset Slam",
        presetHS      = "Preset Heroic Strike",
        itemrackLabel = "Ativar o uso do Item Rack",
        itemrackSub   = "(troca de equipamento automatica por build)",
        explainArms    = "Usado sempre que voce roda /baarms, independente da arma fisicamente equipada. Slam dispara no timer do swing; Heroic Strike gasta a rage sobrando. Os dois limiares sao ajustaveis.",
        explainFury    = "Usado sempre que voce roda /bafury. Sem Slam aqui - so Heroic Strike cuida do gasto de rage entre os golpes automaticos.",
        explainDefense = "Usado sempre que voce roda /batank. Controla quanta rage voce guarda de reserva antes de completar com Heroic Strike por cima da rotacao de ameaca.",
        explainRack   = "Exige o addon ItemRack com sets chamados exatamente Arms, Fury e Defense. Quando ativado, a troca de equipamento e automatica conforme a build que voce esta rodando - nao o que esta fisicamente equipado.",
        cmdHeader     = "Macros",
        cmdList = {
            "/baarms - Rotacao Arms",
            "/bafury - Rotacao Fury",
            "/batank - Rotacao Protection",
            "Segure ALT - Rotacao AoE",
            "/badazs warrior - Abre este painel"
        }
    }
}

-- ==========================================================
-- [0] MOTOR SITUACIONAL INTERNALIZADO (antes vinha do Core)
-- ==========================================================
CreateFrame("GameTooltip", "BadAzsWar_TooltipScanner", nil, "GameTooltipTemplate")
BadAzsWar_TooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE")

local WarSwingData = { main_start = 0 }
local WarLastDodge = 0
local WarCombatFrame = CreateFrame("Frame")
WarCombatFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
WarCombatFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
WarCombatFrame:RegisterEvent("SPELLCAST_STOP")
WarCombatFrame:SetScript("OnEvent", function()
    if event == "CHAT_MSG_COMBAT_SELF_HITS" then
        WarSwingData.main_start = GetTime()
    elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then
        WarSwingData.main_start = GetTime()
        if arg1 and string.find(arg1, "dodges") then WarLastDodge = GetTime() end
    elseif event == "SPELLCAST_STOP" then
        if arg1 == "Slam" then WarSwingData.main_start = GetTime() end
    end
end)

local function BadAzsW_RawCast(spellName)
    if spellName == "Attack" then
        -- Toggle de auto-attack agora mora no Core (BadAzs_StartAttack) - e
        -- mecanica identica pra qualquer classe, unica fonte de verdade.
        if BadAzs_StartAttack then BadAzs_StartAttack() end
        return
    end
    CastSpellByName(spellName)
end

local function BadAzsW_FindSpellId(spellName)
    local i = 1
    while true do
        local name = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end
        if name == spellName then return i end
        i = i + 1
    end
    return nil
end

local function BadAzsW_Ready(spellName)
    local id = BadAzsW_FindSpellId(spellName)
    if not id then return false end
    local start = GetSpellCooldown(id, BOOKTYPE_SPELL)
    local isUsable, notEnoughMana = true, false
    if IsUsableSpell then isUsable, notEnoughMana = IsUsableSpell(id, BOOKTYPE_SPELL) end
    return isUsable and not notEnoughMana and start == 0
end

local function BadAzsW_HasBuff(buffName)
    local i = 1
    while UnitBuff("player", i) do
        local texture = UnitBuff("player", i)
        if string.find(texture, buffName) then return true end
        i = i + 1
    end
    return false
end

local function BadAzsW_TargetHasDebuff(textureName)
    local i = 1
    while UnitDebuff("target", i) do
        local texture = UnitDebuff("target", i)
        if string.find(texture, textureName) then return true end
        i = i + 1
    end
    return false
end

local function BadAzsW_GetTargetHP()
    if not UnitExists("target") then return 0 end
    local h, hmax = UnitHealth("target"), UnitHealthMax("target")
    if not hmax or hmax == 0 then return 0 end
    return (h / hmax) * 100
end

-- ==========================================================
-- [1] CACHE DE SLOT / EQUIPAMENTO / STANCE
-- ==========================================================
local WarriorSlotCache = { ["Heroic Strike"] = false, ["Cleave"] = false }

local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loadFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
loadFrame:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        if not BadAzsWarDB then BadAzsWarDB = {} end
        if BadAzsWarDB.UseItemRack == nil then BadAzsWarDB.UseItemRack = false end

        -- Migracao: perfis antigos por arma (TH/DW) viram perfis por build (arms/fury/defense)
        if not BadAzsWarDB.arms then
            BadAzsWarDB.arms = BadAzsWarDB.TH or { SlamThreshold = 15, HSThreshold = 60 }
        end
        if not BadAzsWarDB.fury then
            BadAzsWarDB.fury = BadAzsWarDB.DW or { HSThreshold = 50 }
        end
        if not BadAzsWarDB.defense then
            BadAzsWarDB.defense = { HSThreshold = 55 }
        end
        BadAzsWarDB.TH = nil
        BadAzsWarDB.DW = nil

        if not BadAzsWarDB.Locale then BadAzsWarDB.Locale = "EN" end

        DEFAULT_CHAT_FRAME:AddMessage(BadAzsVersion .. " " .. BadAzsWar_L[BadAzsWarDB.Locale].loaded)
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_SLOT_CHANGED" then
        for k in pairs(WarriorSlotCache) do WarriorSlotCache[k] = false end
        for i = 1, 120 do
            if HasAction(i) then
                local texture = GetActionTexture(i)
                if texture then
                    if string.find(texture, "Ability_Warrior_Cleave") or
                       string.find(texture, "Ability_Rogue_Ambush") or
                       string.find(texture, "Ability_MeleeDamage") then
                        BadAzsWar_TooltipScanner:SetAction(i)
                        local name = BadAzsWar_TooltipScannerTextLeft1:GetText()
                        if name and WarriorSlotCache[name] ~= nil then
                            WarriorSlotCache[name] = i
                        end
                    end
                end
            end
        end
    end
end)

local function BadAzsW_Cast(spellName)
    local slot = WarriorSlotCache[spellName]
    if slot and IsCurrentAction(slot) then return end
    BadAzsW_RawCast(spellName)
end

-- mode = "Arms" | "Fury" | "Defense" - precisa bater com o nome exato do set no ItemRack
local function BadAzs_Equip(mode)
    if not BadAzsWarDB.UseItemRack then return end
    local EquipFunc = nil
    if ItemRack and type(ItemRack.EquipSet) == "function" then EquipFunc = ItemRack.EquipSet
    elseif type(ItemRack_EquipSet) == "function" then EquipFunc = ItemRack_EquipSet end
    if not EquipFunc then return end
    EquipFunc(mode)
end

function BadAzs_GetStance()
    for i = 1, 3 do local _, _, a = GetShapeshiftFormInfo(i) if a then return i end end
    return 1
end

function BadAzs_HasOffHand() return GetInventoryItemLink("player", 17) ~= nil end
function BadAzs_HasShield()
    local link = GetInventoryItemLink("player", 17)
    if link and string.find(link, "Shield") then return true end
    return false
end

-- ==========================================================
-- [2] TANK
-- ==========================================================
function BadAzsTank()
    if BadAzs_Sustain then BadAzs_Sustain() end
    BadAzsW_Cast("Attack")
    UIErrorsFrame:Clear()

    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    local timeNow = GetTime()
    local inCombat = UnitAffectingCombat("player")

    if not inCombat and not CheckInteractDistance("target", 3) and BadAzsW_Ready("Charge") then
        if stance ~= 1 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("Defense"); return
        else BadAzsW_Cast("Charge") end
    end

    if (timeNow - WarLastDodge) < 4 and BadAzsW_Ready("Overpower") and rage >= 5 and rage < 30 then
        if stance == 2 then BadAzsW_Cast("Battle Stance"); return end
        if stance == 1 then BadAzsW_Cast("Overpower"); return end
    end

    if stance ~= 2 then BadAzsW_Cast("Defensive Stance"); BadAzs_Equip("Defense"); return end
    if BadAzsWarDB.UseItemRack and not BadAzs_HasShield() then BadAzs_Equip("Defense") end

    if inCombat and BadAzsW_Ready("Bloodrage") then BadAzsW_Cast("Bloodrage") end
    if rage > (BadAzsWarDB.defense.HSThreshold or 55) then BadAzsW_Cast("Heroic Strike") end

    if UnitExists("targettarget") and not UnitIsUnit("targettarget", "player") then
        BadAzsW_Cast("Taunt")
    end

    if BadAzsW_Ready("Shield Slam") then BadAzsW_Cast("Shield Slam") end
    BadAzsW_Cast("Revenge")

    if BadAzsW_Ready("Concussion Blow") then BadAzsW_Cast("Concussion Blow") end
    if BadAzsW_Ready("Victory Rush") then BadAzsW_Cast("Victory Rush") end

    if not BadAzsW_HasBuff("Ability_Defend") and rage >= 10 then BadAzsW_Cast("Shield Block") end
    if not BadAzsW_TargetHasDebuff("Ability_Warrior_WarCry") and rage >= 10 then BadAzsW_Cast("Demoralizing Shout") end
    if not BadAzsW_HasBuff("BattleShout") and rage >= 10 then BadAzsW_Cast("Battle Shout") end
    if rage >= 15 then BadAzsW_Cast("Sunder Armor") end
end

-- ==========================================================
-- [3] ARMS (2H)
-- ==========================================================
function BadAzsArms()
    if BadAzs_Sustain then BadAzs_Sustain() end
    BadAzsW_Cast("Attack")
    UIErrorsFrame:Clear()

    local stance = BadAzs_GetStance()
    local thp = BadAzsW_GetTargetHP()
    local rage = UnitMana("player")
    local inCombat = UnitAffectingCombat("player")

    if not inCombat and not CheckInteractDistance("target", 3) and BadAzsW_Ready("Charge") then
        if stance ~= 1 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("Arms"); return
        else BadAzsW_Cast("Charge") end
    end

    if inCombat and IsControlKeyDown() and not CheckInteractDistance("target", 3) then
        if stance ~= 3 then BadAzsW_Cast("Berserker Stance") else BadAzsW_Cast("Intercept") end
        return
    end

    if thp > 0 and thp <= 20 then
        if stance == 2 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("Arms") else BadAzsW_Cast("Execute") end
        return
    end

    if stance ~= 1 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("Arms"); return end
    if BadAzsWarDB.UseItemRack and BadAzs_HasOffHand() then BadAzs_Equip("Arms") end

    if rage < 30 and inCombat and BadAzsW_Ready("Bloodrage") then BadAzsW_Cast("Bloodrage") end
    if BadAzsW_Ready("Victory Rush") then BadAzsW_Cast("Victory Rush") end

    BadAzsW_Cast("Overpower")

    if BadAzsW_Ready("Mortal Strike") then BadAzsW_Cast("Mortal Strike")
    elseif BadAzsW_Ready("Bloodthirst") then BadAzsW_Cast("Bloodthirst") end

    local hasRend = BadAzsW_TargetHasDebuff("Ability_Gouge")
    if not hasRend and thp > 20 then BadAzsW_Cast("Rend") end

    if BadAzsW_Ready("Master Strike") then BadAzsW_Cast("Master Strike") end

    -- [[ DUMP: limites vem do perfil da build Arms (configuravel no painel) ]]
    local profile = BadAzsWarDB.arms
    local slam_thresh = profile.SlamThreshold or 15
    local hs_thresh = profile.HSThreshold or 60

    local timeNow = GetTime()
    if (timeNow - LastSlamTime) > 3.0 then
        if WarSwingData.main_start and WarSwingData.main_start > 0 then
            local swing = timeNow - WarSwingData.main_start
            if rage > slam_thresh and swing < 1.0 then
                BadAzsW_Cast("Slam"); LastSlamTime = timeNow
            end
        elseif rage > (slam_thresh + 10) then
            BadAzsW_Cast("Slam"); LastSlamTime = timeNow
        end
    end

    if rage > hs_thresh then BadAzsW_Cast("Heroic Strike") end
    if not BadAzsW_HasBuff("BattleShout") then BadAzsW_Cast("Battle Shout") end
end

-- ==========================================================
-- [4] FURY (DW)
-- ==========================================================
function BadAzsFury()
    if BadAzs_Sustain then BadAzs_Sustain() end
    BadAzsW_Cast("Attack")
    UIErrorsFrame:Clear()

    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    local inCombat = UnitAffectingCombat("player")

    if not inCombat and not CheckInteractDistance("target", 3) and BadAzsW_Ready("Charge") then
        if stance ~= 1 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("Arms"); return
        else BadAzsW_Cast("Charge") end
    end

    if inCombat and IsControlKeyDown() and not CheckInteractDistance("target", 3) then
        if stance ~= 3 then BadAzsW_Cast("Berserker Stance") else BadAzsW_Cast("Intercept") end
        return
    end

    if stance ~= 3 then BadAzsW_Cast("Berserker Stance"); BadAzs_Equip("Fury"); return end
    if BadAzsWarDB.UseItemRack and (BadAzs_HasShield() or not BadAzs_HasOffHand()) then BadAzs_Equip("Fury") end

    if inCombat and BadAzsW_Ready("Bloodrage") then BadAzsW_Cast("Bloodrage") end
    if inCombat and BadAzsW_Ready("Berserker Rage") then BadAzsW_Cast("Berserker Rage") end
    if BadAzsW_Ready("Victory Rush") then BadAzsW_Cast("Victory Rush") end

    BadAzsW_Cast("Blood Fury"); BadAzsW_Cast("Berserking")

    local thp = BadAzsW_GetTargetHP()
    if thp > 0 and thp <= 20 then BadAzsW_Cast("Execute"); return end

    if BadAzsW_Ready("Bloodthirst") then BadAzsW_Cast("Bloodthirst")
    elseif BadAzsW_Ready("Mortal Strike") then BadAzsW_Cast("Mortal Strike") end

    if BadAzsW_Ready("Master Strike") then BadAzsW_Cast("Master Strike") end
    if BadAzsW_Ready("Whirlwind") then BadAzsW_Cast("Whirlwind") end

    local hs_thresh = BadAzsWarDB.fury.HSThreshold or 50
    if rage > hs_thresh then BadAzsW_Cast("Heroic Strike") end
    if not BadAzsW_HasBuff("BattleShout") then BadAzsW_Cast("Battle Shout") end
end

-- ==========================================================
-- [5] UTILIDADE / AOE
-- ==========================================================
function BadAzs_ShieldInterrupt()
    local offhand = GetInventoryItemLink("player", 17)
    if not offhand then CastSpellByName("Pummel"); return end
    local _, _, _, _, _, itemType, itemSubType, _, equipLoc = GetItemInfo(offhand)
    if itemSubType == "Shields" or equipLoc == "INVTYPE_SHIELD" then
        CastSpellByName("Shield Bash")
    else
        CastSpellByName("Pummel")
    end
end

function BadAzsCrowd()
    BadAzsW_Cast("Attack")
    local stance = BadAzs_GetStance()
    local rage = UnitMana("player")
    if stance == 1 then
        BadAzsW_Cast("Sweeping Strikes"); BadAzsW_Cast("Thunder Clap")
        BadAzsW_Cast("Berserker Stance"); BadAzs_Equip("Arms")
        return
    end
    if stance == 3 then
        BadAzsW_Cast("Whirlwind"); if rage >= 20 then BadAzsW_Cast("Cleave") end
        return
    end
    if stance == 2 then BadAzsW_Cast("Battle Stance"); BadAzs_Equip("Arms") end
end

function BadAzs_ArmsWrapper() if IsAltKeyDown() then BadAzsCrowd() else BadAzsArms() end end
function BadAzs_FuryWrapper() if IsAltKeyDown() then BadAzsCrowd() else BadAzsFury() end end

-- ==========================================================
-- [6] PAINEL GRÁFICO DE CONFIGURAÇÃO  (/badazs warrior)
-- Formato de livro: pagina esquerda = controles, pagina direita = explicacoes
-- Perfis organizados por BUILD (Arms/Fury/Defense), nao por arma equipada.
-- ==========================================================
local Panel = CreateFrame("Frame", "BadAzsWarriorPanel", UIParent)
Panel:SetWidth(620)
Panel:SetHeight(620)
Panel:SetPoint("CENTER", 0, 0)
Panel:SetMovable(true)
Panel:EnableMouse(true)
Panel:RegisterForDrag("LeftButton")
Panel:SetScript("OnDragStart", function() this:StartMoving() end)
Panel:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
Panel:SetFrameStrata("DIALOG")
Panel:Hide()

local LeftPage = CreateFrame("Frame", nil, Panel)
LeftPage:SetWidth(300)
LeftPage:SetHeight(400)
LeftPage:SetPoint("TOPLEFT", Panel, "TOPLEFT", 0, -60)
LeftPage:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

local RightPage = CreateFrame("Frame", nil, Panel)
RightPage:SetWidth(300)
RightPage:SetHeight(400)
RightPage:SetPoint("TOPLEFT", Panel, "TOPLEFT", 320, -60)
RightPage:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

local title = Panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("|cffC79C6EBadAzs Warrior|r")

local closeBtn = CreateFrame("Button", "BadAzsWarriorPanelClose", Panel, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -4, -4)

-- Botao de idioma (EN/PT)
local langBtn = CreateFrame("Button", "BadAzsWar_LangBtn", Panel, "UIPanelButtonTemplate")
langBtn:SetPoint("TOPLEFT", 8, -10)
langBtn:SetWidth(44); langBtn:SetHeight(20)

-- ==================== PAGINA ESQUERDA: CONTROLES ====================
local armsHeader = LeftPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
armsHeader:SetPoint("TOP", 0, -14)

local slamSlider = CreateFrame("Slider", "BadAzsWar_SlamSlider", LeftPage, "OptionsSliderTemplate")
slamSlider:SetPoint("TOP", 0, -38)
slamSlider:SetWidth(240)
slamSlider:SetMinMaxValues(0, 100)
slamSlider:SetValueStep(5)
getglobal(slamSlider:GetName().."Low"):SetText("0")
getglobal(slamSlider:GetName().."High"):SetText("100")
slamSlider:SetScript("OnValueChanged", function()
    BadAzsWarDB.arms.SlamThreshold = this:GetValue()
    getglobal(this:GetName().."Text"):SetText(BadAzsWar_L[BadAzsWarDB.Locale].slamRage .. this:GetValue())
end)

local hsSliderArms = CreateFrame("Slider", "BadAzsWar_HSSliderArms", LeftPage, "OptionsSliderTemplate")
hsSliderArms:SetPoint("TOP", 0, -86)
hsSliderArms:SetWidth(240)
hsSliderArms:SetMinMaxValues(0, 100)
hsSliderArms:SetValueStep(5)
getglobal(hsSliderArms:GetName().."Low"):SetText("0")
getglobal(hsSliderArms:GetName().."High"):SetText("100")
hsSliderArms:SetScript("OnValueChanged", function()
    BadAzsWarDB.arms.HSThreshold = this:GetValue()
    getglobal(this:GetName().."Text"):SetText(BadAzsWar_L[BadAzsWarDB.Locale].hsRage .. this:GetValue())
end)

local slamBtn = CreateFrame("Button", nil, LeftPage, "UIPanelButtonTemplate")
slamBtn:SetPoint("TOP", -62, -114)
slamBtn:SetWidth(110); slamBtn:SetHeight(20)

local hsBtn = CreateFrame("Button", nil, LeftPage, "UIPanelButtonTemplate")
hsBtn:SetPoint("TOP", 68, -114)
hsBtn:SetWidth(130); hsBtn:SetHeight(20)

local furyHeader = LeftPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
furyHeader:SetPoint("TOP", 0, -150)

local hsSliderFury = CreateFrame("Slider", "BadAzsWar_HSSliderFury", LeftPage, "OptionsSliderTemplate")
hsSliderFury:SetPoint("TOP", 0, -174)
hsSliderFury:SetWidth(240)
hsSliderFury:SetMinMaxValues(0, 100)
hsSliderFury:SetValueStep(5)
getglobal(hsSliderFury:GetName().."Low"):SetText("0")
getglobal(hsSliderFury:GetName().."High"):SetText("100")
hsSliderFury:SetScript("OnValueChanged", function()
    BadAzsWarDB.fury.HSThreshold = this:GetValue()
    getglobal(this:GetName().."Text"):SetText(BadAzsWar_L[BadAzsWarDB.Locale].hsRage .. this:GetValue())
end)

local defenseHeader = LeftPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
defenseHeader:SetPoint("TOP", 0, -210)

local hsSliderDefense = CreateFrame("Slider", "BadAzsWar_HSSliderDefense", LeftPage, "OptionsSliderTemplate")
hsSliderDefense:SetPoint("TOP", 0, -234)
hsSliderDefense:SetWidth(240)
hsSliderDefense:SetMinMaxValues(0, 100)
hsSliderDefense:SetValueStep(5)
getglobal(hsSliderDefense:GetName().."Low"):SetText("0")
getglobal(hsSliderDefense:GetName().."High"):SetText("100")
hsSliderDefense:SetScript("OnValueChanged", function()
    BadAzsWarDB.defense.HSThreshold = this:GetValue()
    getglobal(this:GetName().."Text"):SetText(BadAzsWar_L[BadAzsWarDB.Locale].hsRage .. this:GetValue())
end)

-- Checkbox: ItemRack (alinhado a esquerda, label em 2 linhas)
local rackCheck = CreateFrame("CheckButton", "BadAzsWar_RackCheck", LeftPage, "UICheckButtonTemplate")
rackCheck:SetPoint("TOPLEFT", 26, -274)
getglobal(rackCheck:GetName().."Text"):SetText("")

local rackLabel = LeftPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
rackLabel:SetPoint("LEFT", rackCheck, "RIGHT", 4, 0)
rackLabel:SetJustifyH("LEFT")

rackCheck:SetScript("OnClick", function()
    BadAzsWarDB.UseItemRack = (this:GetChecked() == 1)
end)

-- ==================== PAGINA DIREITA: EXPLICACOES ====================
local explainArms = RightPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
explainArms:SetPoint("TOP", 0, -14)
explainArms:SetWidth(260)
explainArms:SetJustifyH("LEFT")
explainArms:SetSpacing(2)

local explainFury = RightPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
explainFury:SetPoint("TOP", 0, -150)
explainFury:SetWidth(260)
explainFury:SetJustifyH("LEFT")
explainFury:SetSpacing(2)

local explainDefense = RightPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
explainDefense:SetPoint("TOP", 0, -210)
explainDefense:SetWidth(260)
explainDefense:SetJustifyH("LEFT")
explainDefense:SetSpacing(2)

local explainRack = RightPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
explainRack:SetPoint("TOP", 0, -274)
explainRack:SetWidth(260)
explainRack:SetJustifyH("LEFT")
explainRack:SetSpacing(2)

-- ==================== RODAPE: LEMBRETE DE COMANDOS ====================
local divider = Panel:CreateTexture(nil, "ARTWORK")
divider:SetPoint("TOP", 0, -468)
divider:SetWidth(590); divider:SetHeight(1)
divider:SetTexture(0.5, 0.5, 0.5, 0.5)

local cmdHeader = Panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
cmdHeader:SetPoint("TOP", 0, -480)

local cmdText = Panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
cmdText:SetPoint("TOP", 0, -500)
cmdText:SetWidth(560)
cmdText:SetJustifyH("LEFT")
cmdText:SetSpacing(3)

function BadAzsWar_RefreshPanel()
    local L = BadAzsWar_L[BadAzsWarDB.Locale]

    title:SetText("|cffC79C6E" .. L.title .. "|r")
    langBtn:SetText(BadAzsWarDB.Locale)

    armsHeader:SetText("|cffffd200" .. L.profileArms .. "|r")
    furyHeader:SetText("|cffffd200" .. L.profileFury .. "|r")
    defenseHeader:SetText("|cffffd200" .. L.profileDefense .. "|r")

    slamBtn:SetText(L.presetSlam)
    hsBtn:SetText(L.presetHS)

    slamSlider:SetValue(BadAzsWarDB.arms.SlamThreshold or 15)
    hsSliderArms:SetValue(BadAzsWarDB.arms.HSThreshold or 60)
    hsSliderFury:SetValue(BadAzsWarDB.fury.HSThreshold or 50)
    hsSliderDefense:SetValue(BadAzsWarDB.defense.HSThreshold or 55)

    getglobal(slamSlider:GetName().."Text"):SetText(L.slamRage .. (BadAzsWarDB.arms.SlamThreshold or 15))
    getglobal(hsSliderArms:GetName().."Text"):SetText(L.hsRage .. (BadAzsWarDB.arms.HSThreshold or 60))
    getglobal(hsSliderFury:GetName().."Text"):SetText(L.hsRage .. (BadAzsWarDB.fury.HSThreshold or 50))
    getglobal(hsSliderDefense:GetName().."Text"):SetText(L.hsRage .. (BadAzsWarDB.defense.HSThreshold or 55))

    if BadAzsWarDB.UseItemRack then rackCheck:SetChecked(1) else rackCheck:SetChecked(nil) end
    rackLabel:SetText(L.itemrackLabel .. "\n|cff888888" .. L.itemrackSub .. "|r")

    explainArms:SetText(L.explainArms)
    explainFury:SetText(L.explainFury)
    explainDefense:SetText(L.explainDefense)
    explainRack:SetText(L.explainRack)

    cmdHeader:SetText("|cffffd200" .. L.cmdHeader .. "|r")
    local lines = ""
    local i
    for i = 1, table.getn(L.cmdList) do
        if i > 1 then lines = lines .. "\n" end
        lines = lines .. L.cmdList[i]
    end
    cmdText:SetText(lines)
end

langBtn:SetScript("OnClick", function()
    if BadAzsWarDB.Locale == "EN" then BadAzsWarDB.Locale = "PT" else BadAzsWarDB.Locale = "EN" end
    BadAzsWar_RefreshPanel()
end)

slamBtn:SetScript("OnClick", function()
    BadAzsWarDB.arms.SlamThreshold = 15
    BadAzsWarDB.arms.HSThreshold = 60
    BadAzsWar_RefreshPanel()
end)

hsBtn:SetScript("OnClick", function()
    BadAzsWarDB.arms.SlamThreshold = 50
    BadAzsWarDB.arms.HSThreshold = 35
    BadAzsWar_RefreshPanel()
end)

Panel:SetScript("OnShow", function() BadAzsWar_RefreshPanel() end)

-- ==========================================================
-- [7] SLASH COMMANDS
-- ==========================================================
BadAzs_PanelRegistry = BadAzs_PanelRegistry or {}
BadAzs_PanelRegistry["warrior"] = function()
    if Panel:IsShown() then Panel:Hide() else Panel:Show() end
end

SLASH_BAFURY1 = "/bafury"; SlashCmdList["BAFURY"] = BadAzs_FuryWrapper
SLASH_BAARMS1 = "/baarms"; SlashCmdList["BAARMS"] = BadAzs_ArmsWrapper
SLASH_BATANK1 = "/batank"; SlashCmdList["BATANK"] = BadAzsTank
