local _, ns = ...

local feature = {
    key = "AuraSkins",
    page = "Unit Frames",
    searchTerms = {
        "aura skins", "buffs", "debuffs", "player auras", "buff frame",
        "debuff frame", "target auras", "target buffs", "target debuffs", "icon zoom", "aura border",
    },
}
ns:RegisterFeature(feature.key, feature)

local GetFFD = EllesmereUI and EllesmereUI._GetFFD
local ICON_ZOOM = 0.055
local BLIZZARD_AURA_ICON_SIZE = 30
local skinGen = 1
local lastCfg = {}
local durationFormat
local auraDirty = true
local refreshPending = false
local appliedBuffScale, appliedDebuffScale
local hooksInstalled = false
local eventFrame
local targetAuraKit
local targetBuffContainer
local targetDebuffContainer
local targetDefaultAuraContainer
local targetAuraKitBuilt = false
local TARGET_BUFF_STYLE = "faf:target:HELPFUL"
local TARGET_DEBUFF_STYLE = "faf:target:HARMFUL"

local function PromptReload()
    if EllesmereUI and EllesmereUI.ShowConfirmPopup then
        EllesmereUI:ShowConfirmPopup({
            title = "Reload Required",
            message = "Changing Aura Skins requires a UI reload to fully apply or restore Blizzard aura styling.",
            confirmText = "Reload Now",
            cancelText = "Later",
            onConfirm = function()
                ReloadUI()
            end,
        })
        return
    end

    StaticPopupDialogs["FAFNYIRTOOLS_AURASKINS_RELOAD"] = StaticPopupDialogs["FAFNYIRTOOLS_AURASKINS_RELOAD"] or {
        text = "Changing Aura Skins requires a UI reload to fully apply or restore Blizzard aura styling.",
        button1 = "Reload Now",
        button2 = "Later",
        OnAccept = function()
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("FAFNYIRTOOLS_AURASKINS_RELOAD")
end

local function DB()
    return ns:GetDatabase().auraSkins
end

local function UnitFramesLoaded()
    return C_AddOns and C_AddOns.IsAddOnLoaded
        and C_AddOns.IsAddOnLoaded("EllesmereUIUnitFrames")
end

-- Frame creation/suppression only changes on reload. Snapshot the effective
-- source at initialization, not Fafnyir's requested override (which may inherit
-- EUI's profile). Do not change ownership when a source popup is deferred.
local activeTargetSource

function feature:IsAvailable()
    if activeTargetSource == nil then
        if not UnitFramesLoaded() then
            activeTargetSource = "blizzard"
        else
            local euf = EllesmereUI and EllesmereUI._ModuleNS
                and EllesmereUI._ModuleNS["EllesmereUIUnitFrames"]
            if not euf or type(euf.GetUnitFrameSource) ~= "function" then
                return false -- Unknown ownership: leave frames alone; retry later.
            end
            local source = euf.GetUnitFrameSource("target")
            if source ~= "blizzard" and source ~= "eui" and source ~= "hidden" then
                return false
            end
            activeTargetSource = source
        end
    end
    return activeTargetSource == "blizzard"
end

local function NoteConfig(cfg)
    local font = (EllesmereUI.GetFontPath and EllesmereUI.GetFontPath("unitFrames")) or ""
    local outline = (EllesmereUI.GetFontOutlineFlag and EllesmereUI.GetFontOutlineFlag("unitFrames")) or ""
    if lastCfg.borderSize == cfg.borderSize
        and lastCfg.borderBehind == cfg.borderBehind
        and lastCfg.noBorderDebuffs == cfg.noBorderDebuffs
        and lastCfg.showText == cfg.showText
        and lastCfg.textSize == cfg.textSize
        and lastCfg.borderR == cfg.borderR
        and lastCfg.borderG == cfg.borderG
        and lastCfg.borderB == cfg.borderB
        and lastCfg.borderA == cfg.borderA
        and lastCfg.borderTexture == cfg.borderTexture
        and lastCfg.offX == cfg.borderTextureOffset
        and lastCfg.offY == cfg.borderTextureOffsetY
        and lastCfg.shiftX == cfg.borderTextureShiftX
        and lastCfg.shiftY == cfg.borderTextureShiftY
        and lastCfg.buffZoom == cfg.buffIconZoom
        and lastCfg.debuffZoom == cfg.debuffIconZoom
        and lastCfg.durFmt == cfg.durationFormat
        and lastCfg.font == font
        and lastCfg.outline == outline
        and lastCfg.targetAuras == cfg.targetAuras then
        return
    end

    lastCfg.borderSize = cfg.borderSize
    lastCfg.borderBehind = cfg.borderBehind
    lastCfg.noBorderDebuffs = cfg.noBorderDebuffs
    lastCfg.showText = cfg.showText
    lastCfg.textSize = cfg.textSize
    lastCfg.borderR, lastCfg.borderG = cfg.borderR, cfg.borderG
    lastCfg.borderB, lastCfg.borderA = cfg.borderB, cfg.borderA
    lastCfg.borderTexture = cfg.borderTexture
    lastCfg.offX, lastCfg.offY = cfg.borderTextureOffset, cfg.borderTextureOffsetY
    lastCfg.shiftX, lastCfg.shiftY = cfg.borderTextureShiftX, cfg.borderTextureShiftY
    lastCfg.buffZoom, lastCfg.debuffZoom = cfg.buffIconZoom, cfg.debuffIconZoom
    lastCfg.durFmt = cfg.durationFormat
    lastCfg.font, lastCfg.outline = font, outline
    lastCfg.targetAuras = cfg.targetAuras
    durationFormat = (cfg.durationFormat and cfg.durationFormat ~= "blizzard") and cfg.durationFormat or nil
    skinGen = skinGen + 1
end

local function FormatDuration(timeLeft, style)
    if timeLeft >= 86400 then
        return string.format("%dd", math.floor(timeLeft / 86400 + 0.5))
    end
    if style == "colon" then
        if timeLeft >= 3600 then
            return string.format("%d:%02d", math.floor(timeLeft / 3600), math.floor((timeLeft % 3600) / 60))
        elseif timeLeft >= 60 then
            return string.format("%d:%02d", math.floor(timeLeft / 60), math.floor(timeLeft % 60))
        end
        return string.format("%d", math.floor(timeLeft + 0.5))
    end
    if timeLeft >= 3600 then return string.format("%dh", math.floor(timeLeft / 3600 + 0.5)) end
    if style == "seconds" then return string.format("%d", math.floor(timeLeft + 0.5)) end
    if timeLeft >= 60 then return string.format("%dm", math.floor(timeLeft / 60 + 0.5)) end
    return string.format("%d", math.floor(timeLeft + 0.5))
end

local function SkinButton(btn, isDebuff, cfg, useButtonBounds)
    if not btn or btn.isAuraAnchor or not GetFFD then return end
    local ffd = GetFFD(btn)
    if not ffd then return end
    if ffd._fafAuraSkinned == skinGen and ffd._fafAuraDebuff == isDebuff then return end

    local iconFrame = btn.Icon
    local iconTex
    if iconFrame then
        iconTex = iconFrame.Texture or iconFrame.texture
        if not iconTex and iconFrame.GetRegions then
            for i = 1, iconFrame:GetNumRegions() do
                local r = select(i, iconFrame:GetRegions())
                if r and r.IsObjectType and r:IsObjectType("Texture") and r.SetTexCoord then
                    iconTex = r
                    break
                end
            end
        end
        if not iconTex and iconFrame.SetTexCoord then iconTex = iconFrame end
    end

    if iconTex and iconTex.SetTexCoord then
        local z = isDebuff and cfg.debuffIconZoom or cfg.buffIconZoom
        z = z or ICON_ZOOM
        iconTex:SetTexCoord(z, 1-z, z, 1-z)
    end

    if btn.DebuffBorder then
        btn.DebuffBorder:SetAlpha((isDebuff and cfg.noBorderDebuffs) and 1 or 0)
    end

    local durFS = btn.Duration
    if durFS and not durFS.SetFont and durFS.GetRegions then
        for i = 1, durFS:GetNumRegions() do
            local r = select(i, durFS:GetRegions())
            if r and r.SetFont then durFS = r; break end
        end
    end
    if durFS and durFS.SetFont and not ffd._fafAuraDurationHooked and durationFormat
        and type(btn.UpdateDuration) == "function" then
        ffd._fafAuraDurationHooked = true
        local fs = durFS
        hooksecurefunc(btn, "UpdateDuration", function(_, timeLeft)
            if not durationFormat or type(timeLeft) ~= "number" then return end
            if issecretvalue and issecretvalue(timeLeft) then return end
            if timeLeft > 0 then fs:SetText(FormatDuration(timeLeft, durationFormat)) end
        end)
    end

    if durFS and durFS.SetFont then
        if cfg.showText then
            local fontPath = EllesmereUI.GetFontPath and EllesmereUI.GetFontPath("unitFrames") or STANDARD_TEXT_FONT
            local outline = EllesmereUI.GetFontOutlineFlag and EllesmereUI.GetFontOutlineFlag("unitFrames") or "OUTLINE, SLUG"
            if EllesmereUI.PrimeFontShadow then EllesmereUI.PrimeFontShadow(durFS, outline == "") end
            durFS:SetFont(fontPath, cfg.textSize or 11, outline)
            durFS:SetTextColor(1,1,1,1)
        else
            durFS:SetTextColor(0,0,0,0)
        end
    end

    local countFS = btn.Count
    if countFS and not countFS.SetFont and countFS.GetRegions then
        for i = 1, countFS:GetNumRegions() do
            local r = select(i, countFS:GetRegions())
            if r and r.SetFont then countFS = r; break end
        end
    end
    if countFS and countFS.SetFont then
        local fontPath = EllesmereUI.GetFontPath and EllesmereUI.GetFontPath("unitFrames") or STANDARD_TEXT_FONT
        EllesmereUI.ApplyIconTextFont(countFS, fontPath, cfg.textSize or 11, "unitFrames")
    end

    local border = ffd._fafAuraBorder
    if not border then
        border = CreateFrame("Frame", nil, btn)
        border:EnableMouse(false)
        ffd._fafAuraBorder = border
    end
    border:SetFrameLevel(cfg.borderBehind and math.max(0, btn:GetFrameLevel()-1) or (btn:GetFrameLevel()+10))
    border:ClearAllPoints()
    if useButtonBounds then
        border:SetAllPoints(btn)
    else
        border:SetPoint("CENTER", iconFrame or btn, "CENTER", 0, 0)
        border:SetSize(BLIZZARD_AURA_ICON_SIZE, BLIZZARD_AURA_ICON_SIZE)
    end

    local bs = cfg.borderSize or 1
    local skipBorder = isDebuff and cfg.noBorderDebuffs
    if EllesmereUI.ApplySecretSafeBorderStyle then
        EllesmereUI.ApplySecretSafeBorderStyle(border, ffd,
            (bs > 0 and not skipBorder) and bs or 0,
            cfg.borderR or 0, cfg.borderG or 0, cfg.borderB or 0, cfg.borderA or 1,
            cfg.borderTexture or "solid",
            cfg.borderTextureOffset, cfg.borderTextureOffsetY,
            cfg.borderTextureShiftX, cfg.borderTextureShiftY,
            "unitframes", bs)
    elseif EllesmereUI.ApplyBorderStyle then
        EllesmereUI.ApplyBorderStyle(border,
            (bs > 0 and not skipBorder) and bs or 0,
            cfg.borderR or 0, cfg.borderG or 0, cfg.borderB or 0, cfg.borderA or 1,
            cfg.borderTexture or "solid",
            cfg.borderTextureOffset, cfg.borderTextureOffsetY,
            cfg.borderTextureShiftX, cfg.borderTextureShiftY,
            "unitframes", bs)
    end

    ffd._fafAuraSkinned = skinGen
    ffd._fafAuraDebuff = isDebuff
end

local function SkinAll(frame, isDebuff, cfg)
    if not frame or not frame.auraFrames then return end
    for _, btn in pairs(frame.auraFrames) do
        if btn and btn.Icon and not btn.isAuraAnchor then SkinButton(btn, isDebuff, cfg) end
    end
end

local function TargetAuraDefaultContainer()
    if not TargetFrame then return nil end
    if type(TargetFrame.GetAuraContainer) == "function" then
        local ok, c = pcall(TargetFrame.GetAuraContainer, TargetFrame)
        if ok and c then return c end
    end
    local content = TargetFrame.TargetFrameContent
    local contextual = content and content.TargetFrameContentContextual
    return contextual and contextual.Auras
end

local function ApplyTargetAuraText(_button, d, style)
    local fontPath = style.fontPath or STANDARD_TEXT_FONT
    if d.duration then
        if EllesmereUI and EllesmereUI.ApplyIconTextFont then
            EllesmereUI.ApplyIconTextFont(d.duration, fontPath, style.cdTextSize or 11, "unitFrames")
        else
            d.duration:SetFont(fontPath, style.cdTextSize or 11, "OUTLINE")
        end
        d.duration:SetTextColor(1, 1, 1, style.hideDurationText and 0 or 1)
    end
    if d.stack then
        if EllesmereUI and EllesmereUI.ApplyIconTextFont then
            EllesmereUI.ApplyIconTextFont(d.stack, fontPath, style.stackSize or 11, "unitFrames")
        else
            d.stack:SetFont(fontPath, style.stackSize or 11, "OUTLINE")
        end
        d.stack:SetTextColor(1, 1, 1, 1)
    end
end

local function BuildTargetAuraStyle(cfg, isDebuff)
    local size = cfg.targetIconSize or cfg.iconSize or 32
    local zoom = (isDebuff and cfg.debuffIconZoom or cfg.buffIconZoom) or ICON_ZOOM
    local borderSize = cfg.borderSize or 1
    if isDebuff and cfg.noBorderDebuffs then borderSize = 0 end

    local fontPath = (EllesmereUI and EllesmereUI.GetFontPath
        and EllesmereUI.GetFontPath("unitFrames")) or STANDARD_TEXT_FONT

    return {
        width = size, height = size,
        texCoord = { zoom, 1 - zoom, zoom, 1 - zoom },
        border = {
            cfg.borderR or 0, cfg.borderG or 0, cfg.borderB or 0, cfg.borderA or 1,
            size = borderSize,
            texture = cfg.borderTexture or "solid",
            offsetX = cfg.borderTextureOffset,
            offsetY = cfg.borderTextureOffsetY,
            shiftX = cfg.borderTextureShiftX,
            shiftY = cfg.borderTextureShiftY,
            behind = cfg.borderBehind,
            unitFrameLevel = TargetFrame and TargetFrame:GetFrameLevel() or 1,
        },
        cooldownReverse = true,
        cooldownDrawEdge = false,
        noDefaultFonts = true,
        hideDurationText = cfg.showText == false,
        cdTextSize = cfg.textSize or 11,
        stackSize = cfg.textSize or 11,
        fontPath = fontPath,
        applyExtra = ApplyTargetAuraText,
    }
end

local function HideBlizzardTargetAuras()
    targetDefaultAuraContainer = targetDefaultAuraContainer or TargetAuraDefaultContainer()
    local c = targetDefaultAuraContainer
    if c then pcall(c.SetAlpha, c, 0) end
end

local function ShowBlizzardTargetAuras()
    local c = targetDefaultAuraContainer or TargetAuraDefaultContainer()
    if c then pcall(c.SetAlpha, c, 1) end
end

local function AnchorTargetAuraContainers()
    if not (targetBuffContainer and targetDebuffContainer and TargetFrame) then return end
    local reference = targetDefaultAuraContainer or TargetAuraDefaultContainer()
    local size = DB().targetIconSize or DB().iconSize or 32
    -- Six icons plus five 1px gaps; retain AuraKit's rounding allowance.
    local rowWidth = 6 * size + 5 * 1 + 0.4

    targetBuffContainer:ClearAllPoints()
    if reference then
        targetBuffContainer:SetPoint("TOPLEFT", reference, "TOPLEFT", 0, 0)
    else
        targetBuffContainer:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", 5, -3)
    end

    targetDebuffContainer:ClearAllPoints()
    targetDebuffContainer:SetPoint("TOPLEFT", targetBuffContainer, "BOTTOMLEFT", 0, -1)

    if targetAuraKit.SetContainerAnchor then
        targetAuraKit.SetContainerAnchor(targetBuffContainer, "TOPLEFT")
        targetAuraKit.SetContainerAnchor(targetDebuffContainer, "TOPLEFT")
    end
    if targetAuraKit.SetContainerGrowth and AnchorUtil and AnchorUtil.FlowDirection then
        targetAuraKit.SetContainerGrowth(targetBuffContainer, AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Down)
        targetAuraKit.SetContainerGrowth(targetDebuffContainer, AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Down)
    end
    if targetAuraKit.SetContainerRowWidth then
        targetAuraKit.SetContainerRowWidth(targetBuffContainer, rowWidth)
        targetAuraKit.SetContainerRowWidth(targetDebuffContainer, rowWidth)
    end
end

local function ConfigureTargetAuraGroups(cfg)
    if not (targetBuffContainer and targetDebuffContainer) then return end
    local size = cfg.targetIconSize or cfg.iconSize or 32
    local layout = {
        elementWidth = size,
        elementHeight = size,
        elementSpacing = 1,
        lineSpacing = 1,
    }

    local bf = cfg.targetBuffFilter or "all"
    local buffKeys = { "all", "steal", "bigdef", "dispellable" }
    for i = 1, #buffKeys do
        local k = buffKeys[i]
        local on = (bf == "all" and k == "all")
            or (bf == "stealable" and k == "steal")
            or (bf == "bigdef" and k == "bigdef")
            or (bf == "dispellable" and k == "dispellable")
        targetBuffContainer:SetAuraGroupMaxFrameCount(k, on and 32 or 0)
        targetBuffContainer:SetAuraGroupLayout(k, layout)
    end

    local df = cfg.targetDebuffFilter or "all"
    local debuffKeys = { "all", "own", "priority", "prioritynp" }
    for i = 1, #debuffKeys do
        local k = debuffKeys[i]
        local on = (df == "all" and k == "all")
            or (df == "own" and k == "own")
            or (df == "important" and (k == "priority" or k == "prioritynp"))
        targetDebuffContainer:SetAuraGroupMaxFrameCount(k, on and 32 or 0)
        targetDebuffContainer:SetAuraGroupLayout(k, layout)
    end

    targetBuffContainer:SetShown(cfg.targetAuras ~= false)
    targetDebuffContainer:SetShown(cfg.targetAuras ~= false)
end

local function BuildTargetAuraKitContainers(cfg)
    if targetAuraKitBuilt then return true end
    if not TargetFrame then return false end

    targetAuraKit = EllesmereUI and EllesmereUI.AuraKit
    if not targetAuraKit
        or not targetAuraKit.CreateContainerShell
        or not targetAuraKit.AddGroupToContainer
        or not targetAuraKit.FinishContainer then
        return false
    end

    targetDefaultAuraContainer = TargetAuraDefaultContainer()
    targetAuraKit.styles[TARGET_BUFF_STYLE] = BuildTargetAuraStyle(cfg, false)
    targetAuraKit.styles[TARGET_DEBUFF_STYLE] = BuildTargetAuraStyle(cfg, true)

    targetBuffContainer = targetAuraKit.CreateContainerShell(TargetFrame, {
        point = { "TOPLEFT", TargetFrame, "BOTTOMLEFT", 5, -3 },
    })
    targetDebuffContainer = targetAuraKit.CreateContainerShell(TargetFrame, {
        point = { "TOPLEFT", TargetFrame, "BOTTOMLEFT", 5, -36 },
    })

    targetAuraKit.AddGroupToContainer(targetBuffContainer, {
        key = "all", filter = { "HELPFUL" }, maxFrameCount = 0, style = TARGET_BUFF_STYLE,
    })
    targetAuraKit.AddGroupToContainer(targetBuffContainer, {
        key = "steal", filter = { "HELPFUL" },
        candidateFilters = { isStealable = true },
        maxFrameCount = 0, style = TARGET_BUFF_STYLE,
    })
    targetAuraKit.AddGroupToContainer(targetBuffContainer, {
        key = "bigdef", filter = { "HELPFUL", "BIG_DEFENSIVE" },
        maxFrameCount = 0, style = TARGET_BUFF_STYLE,
    })
    targetAuraKit.AddGroupToContainer(targetBuffContainer, {
        key = "dispellable", filter = { "HELPFUL", "RAID_PLAYER_DISPELLABLE" },
        maxFrameCount = 0, style = TARGET_BUFF_STYLE,
    })

    targetAuraKit.AddGroupToContainer(targetDebuffContainer, {
        key = "all", filter = { "HARMFUL" }, maxFrameCount = 0, style = TARGET_DEBUFF_STYLE,
    })
    targetAuraKit.AddGroupToContainer(targetDebuffContainer, {
        key = "own", filter = { "HARMFUL", "PLAYER" },
        maxFrameCount = 0, style = TARGET_DEBUFF_STYLE,
    })
    targetAuraKit.AddGroupToContainer(targetDebuffContainer, {
        key = "priority", filter = { "HARMFUL" },
        candidateFilters = { isPriorityAura = true },
        maxFrameCount = 0, style = TARGET_DEBUFF_STYLE,
    })
    targetAuraKit.AddGroupToContainer(targetDebuffContainer, {
        key = "prioritynp", filter = { "HARMFUL" },
        candidateFilters = { nameplateShowPersonal = true, isPriorityAura = false },
        maxFrameCount = 0, style = TARGET_DEBUFF_STYLE,
    })

    targetAuraKit.FinishContainer(targetBuffContainer, "target")
    targetAuraKit.FinishContainer(targetDebuffContainer, "target")

    targetAuraKitBuilt = true
    HideBlizzardTargetAuras()
    AnchorTargetAuraContainers()
    ConfigureTargetAuraGroups(cfg)
    return true
end

local function SkinTargetFrameAuras(cfg)
    if cfg.targetAuras == false then
        if targetBuffContainer then targetBuffContainer:Hide() end
        if targetDebuffContainer then targetDebuffContainer:Hide() end
        ShowBlizzardTargetAuras()
        return
    end

    if not BuildTargetAuraKitContainers(cfg) then return end

    HideBlizzardTargetAuras()
    targetAuraKit.styles[TARGET_BUFF_STYLE] = BuildTargetAuraStyle(cfg, false)
    targetAuraKit.styles[TARGET_DEBUFF_STYLE] = BuildTargetAuraStyle(cfg, true)

    if targetAuraKit.RestyleSoon then
        targetAuraKit.RestyleSoon(TARGET_BUFF_STYLE)
        targetAuraKit.RestyleSoon(TARGET_DEBUFF_STYLE)
    end

    AnchorTargetAuraContainers()
    ConfigureTargetAuraGroups(cfg)

    if targetBuffContainer.UpdateAllAuras then targetBuffContainer:UpdateAllAuras() end
    if targetDebuffContainer.UpdateAllAuras then targetDebuffContainer:UpdateAllAuras() end
end

local function ApplyExpandButton()
    local cfg = DB()
    local button = BuffFrame and BuffFrame.CollapseAndExpandButton
    if not button then return end
    if cfg.showExpandButton == false then button:Hide() else button:Show() end
end

function feature:ApplyScale()
    if not self:IsAvailable() then return end
    local cfg = DB()
    if not cfg.enabled then return end
    local scale = (cfg.iconSize or 32) / 32
    if BuffFrame and BuffFrame.AuraContainer and appliedBuffScale ~= scale then
        BuffFrame.AuraContainer:SetScale(scale); appliedBuffScale = scale
    end
    if DebuffFrame and DebuffFrame.AuraContainer and appliedDebuffScale ~= scale then
        DebuffFrame.AuraContainer:SetScale(scale); appliedDebuffScale = scale
    end
    ApplyExpandButton()
end

function feature:Refresh()
    if not self:IsAvailable() then return end
    local cfg = DB()
    if not cfg.enabled then return end
    NoteConfig(cfg)
    auraDirty = false
    SkinAll(BuffFrame, false, cfg)
    SkinAll(DebuffFrame, true, cfg)
    SkinTargetFrameAuras(cfg)
    self:ApplyScale()
end

local function PendingRefresh()
    refreshPending = false
    if auraDirty then feature:Refresh() end
end

local function RequestRefresh()
    if refreshPending or not auraDirty then return end
    refreshPending = true
    C_Timer.After(0, PendingRefresh)
end

function feature:InstallHooks()
    if hooksInstalled or not self:IsAvailable() then return end
    hooksInstalled = true
    for _, frame in ipairs({BuffFrame, DebuffFrame}) do
        if frame and frame.AuraContainer and type(frame.AuraContainer.UpdateGridLayout) == "function" then
            hooksecurefunc(frame.AuraContainer, "UpdateGridLayout", RequestRefresh)
        end
    end
    local b = BuffFrame and BuffFrame.CollapseAndExpandButton
    if b and type(BuffFrame.RefreshConsolidationFrameVisibility) == "function" then
        hooksecurefunc(BuffFrame, "RefreshConsolidationFrameVisibility", ApplyExpandButton)
    end

    local function TargetAuraRefreshHook()
        if not feature:IsAvailable() or not DB().enabled or DB().targetAuras == false then return end

        C_Timer.After(0, function()
            if not feature:IsAvailable() or not DB().enabled or DB().targetAuras == false then return end
            if targetBuffContainer and targetBuffContainer.UpdateAllAuras then
                targetBuffContainer:UpdateAllAuras()
            end
            if targetDebuffContainer and targetDebuffContainer.UpdateAllAuras then
                targetDebuffContainer:UpdateAllAuras()
            end
        end)
    end

    if TargetFrame and TargetFrame.HookScript then
        TargetFrame:HookScript("OnShow", TargetAuraRefreshHook)
    end

end

function feature:Initialize()
    if not self:IsAvailable() then return end
    self:InstallHooks()
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:RegisterEvent("UNIT_AURA")
        eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        eventFrame:SetScript("OnEvent", function(_, event, unit)
            if not feature:IsAvailable() or not DB().enabled then return end
            if event == "UNIT_AURA" then
                if unit ~= "player" and unit ~= "target" then return end
                if unit == "target" then
                    if DB().targetAuras == false then return end
                    if targetBuffContainer and targetBuffContainer.UpdateAllAuras then
                targetBuffContainer:UpdateAllAuras()
            end
                    if targetDebuffContainer and targetDebuffContainer.UpdateAllAuras then
                        targetDebuffContainer:UpdateAllAuras()
                    end
                    return
                end
            elseif event == "PLAYER_TARGET_CHANGED" then
                if targetBuffContainer and targetBuffContainer.UpdateAllAuras then
                targetBuffContainer:UpdateAllAuras()
            end
                if targetDebuffContainer and targetDebuffContainer.UpdateAllAuras then
                    targetDebuffContainer:UpdateAllAuras()
                end
                return
            end

            auraDirty = true
            RequestRefresh()
        end)
    end
    auraDirty = true
    self:Refresh()
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD" and activeTargetSource == nil then
        self:Initialize()
    end
end

function feature:Reset()
    local d = DB()
    local defaults = ns.defaults.auraSkins
    for k,v in pairs(defaults) do d[k] = v end
    skinGen = skinGen + 1
    auraDirty = true
    self:Refresh()
end

local function Disabled()
    return not feature:IsAvailable()
end

local function PAOff()
    return Disabled() or not DB().enabled
end

local function SetValue(key, value)
    DB()[key] = value
    skinGen = skinGen + 1
    auraDirty = true
    feature:Refresh()
end


local function AttachColorSwatch(region)
    if not EllesmereUI.BuildColorSwatch then return end
    local swatch, refresh = EllesmereUI.BuildColorSwatch(
        region, region:GetFrameLevel()+5,
        function()
            local d=DB(); return d.borderR or 0,d.borderG or 0,d.borderB or 0,d.borderA or 1
        end,
        function(r,g,b,a)
            local d=DB(); d.borderR=r; d.borderG=g; d.borderB=b; d.borderA=a or 1
            skinGen=skinGen+1; auraDirty=true; feature:Refresh()
        end,
        true, 20)
    swatch:SetPoint("RIGHT", region._control or region, "LEFT", -8, 0)
    region._lastInline=swatch
    if EllesmereUI.RegisterWidgetRefresh then EllesmereUI.RegisterWidgetRefresh(refresh) end
end

function feature:BuildOptions(parent, yOffset)
    local W=EllesmereUI.Widgets
    local y=yOffset
    local h
    parent._showRowDivider=true

    _,h=W:SectionHeader(parent,"AURA SKINS",y); y=y-h

    if Disabled() then
        _,h=W:DualRow(parent,y,
            {type="label",text="Aura Skins requires a Blizzard Target frame; its active source is EUI, Hidden, or not yet available."},
            {type="label",text="Set Unit Frames > Target Frame to Blizzard Default, then reload. Other EUI frames can stay enabled."})
        y=y-h
        return math.abs(y)
    end

    _,h=W:DualRow(parent,y,
        {type="toggle",text="Enable Styled Buffs & Debuffs",
         getValue=function() return DB().enabled end,
         setValue=function(v)
            local old = DB().enabled
            SetValue("enabled",v)
            if old ~= v then PromptReload() end
         end},
        {type="slider",text="Icon Size",min=16,max=60,step=1,disabled=PAOff,
         getValue=function() return DB().iconSize or 32 end,
         setValue=function(v) SetValue("iconSize",v) end})
    y=y-h

    _,h=W:DualRow(parent,y,
        {type="slider",text="Buff Icon Zoom",min=0,max=0.20,step=0.01,disabled=PAOff,
         getValue=function() return DB().buffIconZoom or ICON_ZOOM end,
         setValue=function(v) SetValue("buffIconZoom",v) end},
        {type="slider",text="Debuff Icon Zoom",min=0,max=0.20,step=0.01,disabled=PAOff,
         getValue=function() return DB().debuffIconZoom or ICON_ZOOM end,
         setValue=function(v) SetValue("debuffIconZoom",v) end})
    y=y-h

    _,h=W:DualRow(parent,y,
        {type="toggle",text="Show Duration Text",disabled=PAOff,
         getValue=function() return DB().showText ~= false end,
         setValue=function(v) SetValue("showText",v) end},
        {type="slider",text="Text Size",min=6,max=24,step=1,disabled=PAOff,
         getValue=function() return DB().textSize or 11 end,
         setValue=function(v) SetValue("textSize",v) end})
    y=y-h

    _,h=W:DualRow(parent,y,
        {type="dropdown",text="Duration Format",disabled=PAOff,
         values={blizzard="Blizzard Default",compact="Standard",colon="Colon",seconds="Seconds"},
         order={"blizzard","compact","colon","seconds"},
         getValue=function() return DB().durationFormat or "blizzard" end,
         setValue=function(v) SetValue("durationFormat",v) end},
        {type="toggle",text="Show Expand Button",disabled=PAOff,
         getValue=function() return DB().showExpandButton ~= false end,
         setValue=function(v) SetValue("showExpandButton",v) end})
    y=y-h

    _,h=W:DualRow(parent,y,
        {type="toggle",text="Skin Target Frame Auras",disabled=PAOff,
         getValue=function() return DB().targetAuras ~= false end,
         setValue=function(v) SetValue("targetAuras",v) end},
        {type="slider",text="Target Aura Size",min=16,max=60,step=1,disabled=PAOff,
         getValue=function() return DB().targetIconSize or DB().iconSize or 32 end,
         setValue=function(v) SetValue("targetIconSize",v) end})
    y=y-h

    _,h=W:DualRow(parent,y,
        {type="dropdown",text="Target Buff Filter",disabled=PAOff,
         values={all="All Buffs",stealable="Stealable",bigdef="Big Defensive",dispellable="Dispellable"},
         order={"all","stealable","bigdef","dispellable"},
         getValue=function() return DB().targetBuffFilter or "all" end,
         setValue=function(v) SetValue("targetBuffFilter",v) end},
        {type="dropdown",text="Target Debuff Filter",disabled=PAOff,
         values={all="All Debuffs",own="Own Only",important="Important"},
         order={"all","own","important"},
         getValue=function() return DB().targetDebuffFilter or "all" end,
         setValue=function(v) SetValue("targetDebuffFilter",v) end})
    y=y-h

    local texValues,texOrder=EllesmereUI.GetBorderTextureDropdown()
    local borderRow
    borderRow,h=W:DualRow(parent,y,
        {type="dropdown",text="Border Style",disabled=PAOff,values=texValues,order=texOrder,
         getValue=function() return DB().borderTexture or "solid" end,
         setValue=function(v)
            local color,behind=EllesmereUI.GetBorderStyleSelectDefaults(v)
            local d=DB(); d.borderTexture=v; d.borderBehind=behind
            d.borderR=color.r; d.borderG=color.g; d.borderB=color.b; d.borderA=1
            d.borderTextureOffset=nil; d.borderTextureOffsetY=nil; d.borderTextureShiftX=nil; d.borderTextureShiftY=nil
            local sz=EllesmereUI.GetBorderDefaultSize("unitframes",v); if sz then d.borderSize=sz end
            skinGen=skinGen+1; auraDirty=true; feature:Refresh()
         end},
        {type="slider",text="Border Size",min=0,max=4,step=1,disabled=PAOff,
         getValue=function() return DB().borderSize or 1 end,
         setValue=function(v) SetValue("borderSize",v) end})
    y=y-h
    if borderRow and borderRow._rightRegion then AttachColorSwatch(borderRow._rightRegion) end

    _,h=W:DualRow(parent,y,
        {type="toggle",text="Use Blizzard Debuff Border",disabled=PAOff,
         getValue=function() return DB().noBorderDebuffs == true end,
         setValue=function(v) SetValue("noBorderDebuffs",v) end},
        {type="button",text="Reset Aura Skin Settings",buttonText="Reset",onClick=function()
            feature:Reset(); if EllesmereUI.RefreshPage then EllesmereUI:RefreshPage(true) end
         end})
    y=y-h

    return math.abs(y)
end
