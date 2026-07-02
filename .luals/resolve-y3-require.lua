local source = debug.getinfo(1, 'S').source
local plugin_path = source:sub(1, 1) == '@' and source:sub(2) or source
plugin_path = plugin_path:gsub('\\', '/')

local package_root = plugin_path:match('^(.*)/%.luals/[^/]+$')
    or plugin_path:match('^(.*)/[^/]+$')

local function file_exists(path)
    local file = io.open(path, 'rb')
    if not file then
        return false
    end
    file:close()
    return true
end

local function path_to_uri(path)
    path = path:gsub('\\', '/')
    path = path:gsub('^([A-Z]):', function (drive)
        return drive:lower() .. ':'
    end)
    local encoded = path:gsub('([^A-Za-z0-9%-%._~/])', function(char)
        return string.format('%%%02X', char:byte())
    end)
    return 'file:///' .. encoded
end

local function module_to_relative_path(name)
    if name == 'y3' then
        return 'init'
    end
    local rest = name:match('^y3%.(.+)$')
    if not rest then
        return nil
    end
    return (rest:gsub('%.', '/'))
end

---@param uri string
---@param name string
---@return string[]?
function ResolveRequire(uri, name)
    if not package_root then
        return nil
    end

    local relative_path = module_to_relative_path(name)
    if not relative_path then
        return nil
    end

    local candidates = {
        package_root .. '/' .. relative_path .. '.lua',
        package_root .. '/' .. relative_path .. '/init.lua',
    }
    for _, candidate in ipairs(candidates) do
        if file_exists(candidate) then
            return { path_to_uri(candidate) }
        end
    end
    return nil
end
