local function HideStatusTextures(frame)
    if not frame then return end
    local content = frame.TargetFrameContent
    if not content then return end
    local main = content.TargetFrameContentMain
    if not main then return end

    for _, region in ipairs({ main:GetRegions() }) do
        if region:GetObjectType() == "Texture" then
            local h = region:GetHeight() or 0
            local w = region:GetWidth() or 0
            if h > 5 and h < 25 and w > 50 then
                region:SetAlpha(0)
                region:Hide()
                hooksecurefunc(region, "Show", function(self)
                    self:SetAlpha(0)
                    self:Hide()
                end)
            end
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("PLAYER_FOCUS_CHANGED")

f:SetScript("OnEvent", function()
    HideStatusTextures(TargetFrame)
    HideStatusTextures(FocusFrame)
end)
