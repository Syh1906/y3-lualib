---@class Y3ReleaseInfo
---@field upstream Y3ReleaseUpstreamInfo
---@field local_branch Y3ReleaseLocalBranchInfo
---@field compatibility Y3ReleaseCompatibilityInfo
---@field full_name string

---@class Y3ReleaseUpstreamInfo
---@field code integer
---@field tag string
---@field commit string
---@field source string

---@class Y3ReleaseLocalBranchInfo
---@field code integer
---@field tag string
---@field name string

---@class Y3ReleaseCompatibilityInfo
---@field y3_editor string
---@field y3_helper string

---@type Y3ReleaseInfo
local release = {
    upstream = {
        code = 260616,
        tag = '未配置',
        commit = 'fee9872',
        source = 'origin/main',
    },
    local_branch = {
        code = 26070301,
        tag = 'moy-2026.07.03.1',
        name = 'Moy 本地迭代版',
    },
    compatibility = {
        y3_editor = '2.x',
        y3_helper = '待确认',
    },
    full_name = 'upstream 260616@fee9872 + moy-2026.07.03.1',
}

return release
