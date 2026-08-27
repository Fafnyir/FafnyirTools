local ADDON_NAME, ns = ...

local sidebar = {}
ns.Sidebar = sidebar

function sidebar:Install()
    if not EllesmereUI
        or type(EllesmereUI.ADDON_GROUPS) ~= "table"
        or type(EllesmereUI._addonInfoByFolder) ~= "table"
    then
        return false
    end

    EllesmereUI._addonInfoByFolder[ns.MODULE_KEY] = {
        folder = ns.MODULE_KEY,
        display = "Fafnyir Tools",
        search_name = "Fafnyir Tools for EllesmereUI",
        alwaysLoaded = true,
    }

    local targetGroup

    for _, group in ipairs(EllesmereUI.ADDON_GROUPS) do
        if group.key == "fafnyirtools" then
            targetGroup = group
            break
        end
    end

    if not targetGroup then
        targetGroup = {
            key = "fafnyirtools",
            label = "Fafnyir Tools",
            members = {},
        }

        table.insert(EllesmereUI.ADDON_GROUPS, targetGroup)
    end

    targetGroup.label = "Fafnyir Tools"
    targetGroup.members = targetGroup.members or {}

    for _, folder in ipairs(targetGroup.members) do
        if folder == ns.MODULE_KEY then
            return true
        end
    end

    table.insert(targetGroup.members, ns.MODULE_KEY)
    return true
end

sidebar:Install()
