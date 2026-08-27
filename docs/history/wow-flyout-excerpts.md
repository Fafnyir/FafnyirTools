# WoW — flyout excerpts

Task ID: `6a864a08-77ec-83ea-a188-bbc45b367a50`. Historical diagnostic guesses only; later successful flyout work supersedes these attempts. Only relevant retrieved turns are included; unrelated gearing discussion is excluded.

## Turn ab5e74cd-f662-4113-87f8-65b964b76728 — userMessage

How do you edit these flyout bars in Ellesmere?

[User attached 1 image; image contents were not included]

## Turn ab5e74cd-f662-4113-87f8-65b964b76728 — agentMessage

Ah — those aren't actually an EllesmereUI-created bar. **That's Blizzard's native spell flyout**, with EllesmereUI applying its action-button skin to it. In your screenshot it looks like the Mage **Teleport/Portal flyout**.

Ellesmere's current code explicitly uses Blizzard's `SpellFlyout`; it skins the buttons to match the parent action bar but leaves Blizzard in control of the flyout contents. citeturn0search0

So there are two separate things you might mean by "edit":

**If you mean appearance/direction:** EllesmereUI controls that through the **Action Bar containing the flyout button**. The flyout inherits things like button shape, icon zoom, border size/color, etc. from that parent bar. citeturn0search0 Ellesmere also specifically added logic so flyouts choose a sensible direction based on where the action bar is positioned—for example, a vertical bar on the right opens left. citeturn0search5

**If you mean the actual icons inside it:** that's Blizzard's spell flyout, so 

[Excerpt truncated by retrieval; revisit original task for full text.]

## Turn 575d70e0-49b7-43de-8b9d-e31c730af2e0 — userMessage

The annoying white border. Seems like a bug.

## Turn 575d70e0-49b7-43de-8b9d-e31c730af2e0 — agentMessage

Yeah — that **white border looks like a skinning bug**, not intended styling.

What’s probably happening is EllesmereUI is skinning the flyout button itself, but Blizzard’s native flyout button texture/border is still being shown underneath or on top of it. That would explain why the flyout icons have the Ellesmere-style shape but still carry that bright square outline.

Given the screenshot, I’d suspect one of these two things:

- Ellesmere is not hiding the flyout button’s default `NormalTexture`/border region.
- Blizzard changed the flyout button template in the current patch and Ellesmere’s flyout skin code isn’t clearing the new texture layer.

Since we already have **Fafnyir Tools for EllesmereUI**, this is a perfect little addon fix: hook `SpellFlyout`, iterate its visible buttons when the flyout opens, and hide/alpha out the offending default border texture while leaving Ellesmere’s own skin intact.

If you want, I can patch **Fafnyir Tools** specifically for that white flyout 

[Excerpt truncated by retrieval; revisit original task for full text.]

## Turn 1fb1fc76-154f-484f-b3eb-cc605187f6db — userMessage

Lets try

## Turn 1fb1fc76-154f-484f-b3eb-cc605187f6db — agentMessage

Absolutely. Since the build handoff was declined, I can still give you a **small manual patch** to test without touching the rest of Fafnyir Tools.

The likely culprit is Blizzard’s native `SpellFlyout` button artwork surviving underneath Ellesmere’s skin. Add this as a small module, for example `FlyoutFix.lua`:

```lua
local function CleanFlyoutButton(button)
    if not button then return end

    -- Blizzard's native button texture can show as a bright white square
    local normal = button:GetNormalTexture()
    if normal then
        normal:SetAlpha(0)
    end

    -- Hide obvious Blizzard border/background regions without
    -- touching EllesmereUI's separately-created skin elements.
    for _, region in ipairs({ button:GetRegions() }) do
        if region:IsObjectType("Texture") then
            local texture = region:GetTexture()

            if texture then
                local name = region:GetDebugName() or ""

                if name:find("Border")
                    or n

[Excerpt truncated by retrieval; revisit original task for full text.]

## Turn 6df7a56d-54eb-4a66-a3b6-2a54999b2a90 — userMessage

Border is still there

## Turn 6df7a56d-54eb-4a66-a3b6-2a54999b2a90 — agentMessage

That tells us the white outline is **not Blizzard’s default `NormalTexture`**. I checked EllesmereUI’s current flyout code, and it is already explicitly hiding Blizzard’s normal texture; then Ellesmere creates its **own border** for each flyout button using `PP.CreateBorder` / `PP.UpdateBorder`. citeturn837779search0

So the screenshot is much more likely showing **EllesmereUI’s flyout border being rendered white**, probably because the flyout is inheriting the wrong border color from its parent bar after the current patch. citeturn837779search0

That means our first patch was attacking the wrong layer.

Try replacing the previous `FlyoutFix.lua` with this much narrower test:

```lua
local function FixFlyoutBorders()
    local flyout = _G.SpellFlyout
    if not flyout or not EllesmereUI or not EllesmereUI.PP then
        return
    end

    local PP = EllesmereUI.PP

    for i = 1, flyout:GetNumChildren() do
        local btn = select(i, flyout:GetChildren())

        if btn and 

[Excerpt truncated by retrieval; revisit original task for full text.]

## Turn d944bc77-d3da-4ed3-bfcb-b1560e61529b — userMessage

Still white

## Turn d944bc77-d3da-4ed3-bfcb-b1560e61529b — agentMessage

Good — that rules out both Blizzard’s normal texture **and** Ellesmere’s ordinary pixel border.

I checked EllesmereUI’s current flyout code, and there’s another layer: for shaped buttons it creates a dedicated `shapeBorder` texture on the flyout button and renders it at overlay level 6. That texture is separate from the normal PP border we just tried to recolor. citeturn240884search0turn240884search3

So this is the next thing I’d target. Replace the current test file with:

```lua
local function FixFlyoutShapeBorders()
    local flyout = _G.SpellFlyout
    if not flyout then return end

    for _, btn in ipairs({ flyout:GetChildren() }) do
        if btn and btn:IsObjectType("Button") then
            -- Ellesmere stores per-frame data internally; scan textures
            -- and suppress the overlay border texture it creates.
            for _, region in ipairs({ btn:GetRegions() }) do
                if region:IsObjectType("Texture") then
                    local layer, subLev

[Excerpt truncated by retrieval; revisit original task for full text.]

## Turn 235b21ce-cbf4-4dcc-be45-bacc7b8bfcf2 — userMessage

Still white

## Turn 235b21ce-cbf4-4dcc-be45-bacc7b8bfcf2 — agentMessage

Good — then I don’t want to guess at a third layer.

I checked EllesmereUI’s current flyout code. It already hides Blizzard’s normal flyout art, then creates its own `shapeBorder` or PP border depending on button shape. Since both of our attempted overrides left the white outline untouched, the fastest path now is to **inspect the actual regions on one visible flyout button in-game** and identify exactly which texture is white. citeturn632619search0turn632619search2

Replace `FlyoutFix.lua` with this diagnostic:

```lua
local function DumpFlyoutButton()
    local flyout = _G.SpellFlyout
    if not flyout or not flyout:IsShown() then
        print("|cffff6600Fafnyir Tools:|r Open a spell flyout first.")
        return
    end

    local button

    for _, child in ipairs({ flyout:GetChildren() }) do
        if child:IsObjectType("Button") and child:IsShown() then
            button = child
            break
        end
    end

    if not button then
        print("|cffff6600Fafnyir

[Excerpt truncated by retrieval; revisit original task for full text.]

## Turn a5bcefa2-052b-4e56-ad2c-be8d2fa35233 — userMessage

\--- Flyout Button Debug ---
Button: SpellFlyoutPopupButton1
1 Texture SpellFlyoutPopupButton1.BorderShadow tex=4615764 layer=ARTWORK sub=1 RGBA=1.00 1.00 1.00 1.00 alpha=1 shown=false
2 Texture SpellFlyoutPopupButton1.Arrow tex=4615764 layer=OVERLAY sub=2 RGBA=1.00 1.00 1.00 1.00 alpha=1 shown=false
3 Texture SpellFlyoutPopupButton1Icon tex=135744 layer=BACKGROUND sub=0 RGBA=1.00 1.00 1.00 1.00 alpha=1 shown=true
4 MaskTexture SpellFlyoutPopupButton1.IconMask tex=4626072 layer=BACKGROUND sub=0 RGBA=1.00 1.00 1.00 1.00 alpha=1 shown=true
5 Texture SpellFlyoutPopupButton1.SlotBackground tex=4613342 layer=BACKGROUND sub=0 RGBA=1.00 1.00 1.00 1.00 alpha=1 shown=true
6 Texture SpellFlyoutPopupButton1.SlotArt tex=4615764 layer=BACKGROUND sub=0 RGBA=1.00 1.00 1.00 1.00 alpha=1 shown=false
7 Texture SpellFlyoutPopupButton1Flash tex=4615764 layer=ARTWORK sub=1 RGBA=1.00 1.00 1.00 1.00 alpha=1 shown=false
8 FontString SpellFlyoutPopupButton1Name
9 Texture SpellFlyoutPopupButton1Border tex=46157

## Turn a5bcefa2-052b-4e56-ad2c-be8d2fa35233 — agentMessage

Perfect — **we found it.**

The culprit is almost certainly this region:

`SpellFlyoutPopupButton1.SlotBackground`

It is the only always-visible background artwork besides the icon/mask:

- `SlotBackground` → **shown=true**
- texture `4613342`
- layer `BACKGROUND`
- full white RGBA

Everything we previously targeted — `Border`, `NormalTexture`, `shapeBorder` — is either hidden or alpha 0 in your dump. So this is why none of those fixes touched the white outline.

Replace `FlyoutFix.lua` with this very targeted version:

```lua
local function FixFlyoutButton(button)
    if not button then return end

    -- Blizzard's SlotBackground is the visible white square
    if button.SlotBackground then
        button.SlotBackground:SetAlpha(0)
        button.SlotBackground:Hide()
    end
end

local function FixSpellFlyout()
    local flyout = _G.SpellFlyout
    if not flyout then return end

    for _, child in ipairs({ flyout:GetChildren() }) do
        if child:IsObjectType("Button") then
   

[Excerpt truncated by retrieval; revisit original task for full text.]

## Turn 59b8a159-d485-4298-9c9e-c5dac4a40903 — userMessage

still white

## Turn 59b8a159-d485-4298-9c9e-c5dac4a40903 — agentMessage

Okay — then we’ve proven the white border is **not one of the button’s direct texture regions**. The next likely culprit is a **child Frame created by EllesmereUI**, which our `/fafflyoutdebug` dump never inspected.

That explains why hiding `NormalTexture`, `SlotBackground`, and the other direct textures did nothing.

Let’s inspect the actual frame tree instead of guessing again. Replace the diagnostic with this:

```lua
local function DumpFrame(frame, depth)
    if not frame or depth > 4 then return end

    local indent = string.rep("  ", depth)
    local name = frame.GetDebugName and frame:GetDebugName() or tostring(frame)

    print(indent .. "|cffff9900FRAME:|r " .. tostring(name)
        .. " level=" .. tostring(frame.GetFrameLevel and frame:GetFrameLevel() or "?")
        .. " strata=" .. tostring(frame.GetFrameStrata and frame:GetFrameStrata() or "?")
        .. " shown=" .. tostring(frame:IsShown()))

    if frame.GetRegions then
        for i, region in ipairs({ frame:GetReg

[Excerpt truncated by retrieval; revisit original task for full text.]

## Turn e399f53f-6986-4a52-a7a5-38897a41df0d — userMessage

Seems to be an Ellesmere issue. If I change this option to none. The white border goes away.

[User attached 1 image; image contents were not included]

## Turn e399f53f-6986-4a52-a7a5-38897a41df0d — agentMessage

Yes — **that pretty much confirms it’s an EllesmereUI flyout-border bug**, not Blizzard’s native flyout artwork.

The fact that setting **Border Size → None** makes the white outline disappear means the offending element is tied directly to EllesmereUI’s border-generation path for flyout buttons. Our earlier texture tests missed it because the visible border is likely being created by Ellesmere’s own border helper/backdrop logic rather than one of the obvious `SpellFlyoutPopupButton` textures.

So I would **stop patching Fafnyir Tools for this**. The cleaner answer is either to leave that specific border option on **None** for the action bar that owns the Mage flyout, or report it upstream to Ellesmere as a reproducible bug:

> Spell flyout buttons render a white border when Action Bar Border Size is enabled; setting Border Size to None removes it.

That’s a very solid repro case.

If you want, I can also help you write a concise bug report for Ellesmere with the exact steps and the de

[Excerpt truncated by retrieval; revisit original task for full text.]
