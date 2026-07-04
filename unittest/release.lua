local release = require 'y3.release'

assert(release.upstream.code == 260616)
assert(release.upstream.tag == '未配置')
assert(release.upstream.commit == 'fee9872')
assert(release.local_branch.code == 26070301)
assert(release.local_branch.tag == 'moy-2026.07.03.1')
assert(release.full_name == 'upstream 260616@fee9872 + moy-2026.07.03.1')
assert(release.compatibility.y3_editor == '2.x')
assert(release.compatibility.y3_helper == '待确认')
local y3_release_view = {
    release = release,
    version = release.upstream.code,
    upstream_version = release.upstream.code,
    local_version = release.local_branch.code,
    full_version = release.full_name,
}

assert(y3_release_view.version == y3_release_view.release.upstream.code)
assert(y3_release_view.upstream_version == y3_release_view.release.upstream.code)
assert(y3_release_view.local_version == y3_release_view.release.local_branch.code)
assert(y3_release_view.full_version == y3_release_view.release.full_name)
