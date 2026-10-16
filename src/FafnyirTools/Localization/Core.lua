local ADDON_NAME, ns = ...

ns.Locale = ns.Locale or { english = {}, active = {} }

local SUPPORTED_TEST_LOCALES = {
    zhcn = "zhCN",
    zhtw = "zhTW",
}

local function ActiveLocale()
    local override = FafnyirToolsLocaleOverride
    if override == "zhCN" or override == "zhTW" then
        return override
    end
    return GetLocale and GetLocale() or "enUS"
end

function ns:RegisterLocale(locale, strings)
    if type(strings) ~= "table" then return end

    if locale == "enUS" then
        for key, value in pairs(strings) do
            self.Locale.english[key] = value
        end
    end

    local activeLocale = ActiveLocale()
    if locale == activeLocale then
        for key, value in pairs(strings) do
            self.Locale.active[key] = value
        end
    end
end

SlashCmdList = SlashCmdList or {}
SLASH_FAFNYIRTOOLSLOCALE1 = "/faftoolslocale"
SlashCmdList["FAFNYIRTOOLSLOCALE"] = function(message)
    local value = string.lower((message or ""):match("^%s*(.-)%s*$"))

    if value == "reset" or value == "en" or value == "english" then
        FafnyirToolsLocaleOverride = nil
        ns:Print("Locale test override cleared. Type /reload to apply the client language.")
        return
    end

    local locale = SUPPORTED_TEST_LOCALES[value]
    if locale then
        FafnyirToolsLocaleOverride = locale
        ns:Print("Locale test override set to " .. locale .. ". Type /reload to apply it.")
        return
    end

    local current = FafnyirToolsLocaleOverride or "client default"
    ns:Print("Locale test override: " .. current .. ". Use /faftoolslocale zhCN, zhTW, or reset.")
end

function ns:Text(key, ...)
    local text = self.Locale.active[key] or self.Locale.english[key] or key
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, text, ...)
        if ok then return formatted end
    end
    return text
end
