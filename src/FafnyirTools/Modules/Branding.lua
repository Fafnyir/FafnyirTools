local ADDON_NAME, ns = ...

local feature = {
    key = "Branding",
    page = "About",
    searchTerms = { "logo", "branding", "header" },
}

ns:RegisterFeature(feature.key, feature)

local HEADER_TEXTURE = "Interface\\AddOns\\FafnyirTools\\Media\\Header"
local HEADER_WIDTH = 512
local HEADER_HEIGHT = 128
local BOTTOM_SPACING = 12

function feature:BuildOptions(parent, yOffset)
    local header = parent:CreateTexture(nil, "ARTWORK")
    header:SetTexture(HEADER_TEXTURE)
    header:SetSize(HEADER_WIDTH, HEADER_HEIGHT)
    header:SetPoint("TOP", parent, "TOP", 0, yOffset)

    return math.abs(yOffset - HEADER_HEIGHT - BOTTOM_SPACING)
end
