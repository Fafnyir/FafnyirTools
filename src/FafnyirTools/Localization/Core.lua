local ADDON_NAME, ns = ...

ns.Locale = ns.Locale or { english = {}, active = {} }

function ns:RegisterLocale(locale, strings)
    if type(strings) ~= "table" then return end

    if locale == "enUS" then
        for key, value in pairs(strings) do
            self.Locale.english[key] = value
        end
    end

    local activeLocale = GetLocale and GetLocale() or "enUS"
    if locale == activeLocale then
        for key, value in pairs(strings) do
            self.Locale.active[key] = value
        end
    end
end

function ns:Text(key, ...)
    local text = self.Locale.active[key] or self.Locale.english[key] or key
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, text, ...)
        if ok then return formatted end
    end
    return text
end
