param(
    [switch] $Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Convert-ToSlashPath {
    param([string] $Path)
    return ($Path -replace "\\", "/")
}

function New-Check {
    param(
        [string] $Id,
        [ValidateSet("ok", "warning", "error")]
        [string] $Status,
        [string] $Message,
        [array] $Items = @()
    )
    return [ordered]@{
        id = $Id
        status = $Status
        message = $Message
        items = @($Items)
    }
}

function Test-PathSet {
    param(
        [string[]] $Paths,
        [string] $CheckId
    )
    $missing = @()
    foreach ($path in $Paths) {
        if (-not (Test-Path -LiteralPath $path)) {
            $missing += Convert-ToSlashPath $path
        }
    }
    if ($missing.Count -gt 0) {
        return New-Check -Id $CheckId -Status "error" -Message "Required paths are missing." -Items $missing
    }
    return New-Check -Id $CheckId -Status "ok" -Message "Required paths exist."
}

try {
    $root = (Resolve-Path -LiteralPath ".").Path
    $checks = [System.Collections.Generic.List[object]]::new()

    $requiredRoot = @(
        (Join-Path $root "init.lua"),
        (Join-Path $root "README.md"),
        (Join-Path $root ".luarc.json"),
        (Join-Path $root "game"),
        (Join-Path $root "util"),
        (Join-Path $root "object"),
        (Join-Path $root "tools"),
        (Join-Path $root "doc/API.md")
    )
    $checks.Add((Test-PathSet -Paths $requiredRoot -CheckId "development_repo_gate"))

    $navigatorRoot = Join-Path $root ".codex/skills/y3-kernel-navigator"
    $maintainerRoot = Join-Path $root ".codex/skills/y3-kernel-skill-maintainer"
    $requiredSkills = @(
        (Join-Path $navigatorRoot "SKILL.md"),
        (Join-Path $maintainerRoot "SKILL.md"),
        (Join-Path $navigatorRoot "agents/openai.yaml"),
        (Join-Path $maintainerRoot "agents/openai.yaml"),
        (Join-Path $navigatorRoot "references/tools-kernel.md")
    )
    $checks.Add((Test-PathSet -Paths $requiredSkills -CheckId "skill_files"))

    if (Test-Path -LiteralPath $navigatorRoot) {
        $navTextParts = [System.Collections.Generic.List[string]]::new()
        Get-ChildItem -LiteralPath $navigatorRoot -Recurse -File -Include "*.md", "*.ps1", "*.yaml" | ForEach-Object {
            $navTextParts.Add((Get-Content -LiteralPath $_.FullName -Raw))
        }
        $navText = $navTextParts -join "`n"
        $forbidden = @(
            "y3-kernel-skill-maintainer",
            "开发仓同步门",
            "同步门",
            "发布前验证",
            "发布前",
            "发布流程",
            "维护索引",
            "索引重建要求",
            "重建索引",
            "source manifest",
            "coverage diff"
        )
        $hits = @()
        foreach ($word in $forbidden) {
            if ($navText.Contains($word)) {
                $hits += $word
            }
        }
        if ($hits.Count -gt 0) {
            $checks.Add((New-Check -Id "navigator_isolation" -Status "error" -Message "Navigator contains maintainer-only terms." -Items $hits))
        }
        else {
            $checks.Add((New-Check -Id "navigator_isolation" -Status "ok" -Message "Navigator does not reference maintainer-only terms."))
        }
    }

    $navReferences = Join-Path $navigatorRoot "references"
    if (Test-Path -LiteralPath $navReferences) {
        $refFiles = @(Get-ChildItem -LiteralPath $navReferences -File -Filter "*.md")
        if ($refFiles.Count -lt 5) {
            $checks.Add((New-Check -Id "navigator_reference_count" -Status "warning" -Message "Navigator has fewer reference files than expected." -Items @($refFiles.Count)))
        }
        else {
            $checks.Add((New-Check -Id "navigator_reference_count" -Status "ok" -Message "Navigator references exist." -Items @($refFiles.Count)))
        }
    }
    else {
        $checks.Add((New-Check -Id "navigator_reference_count" -Status "error" -Message "Navigator references directory is missing."))
    }

    $publicDocMapPath = Join-Path $navigatorRoot "references/kernel-public-doc-map.md"
    if (Test-Path -LiteralPath $publicDocMapPath) {
        $docMapText = Get-Content -LiteralPath $publicDocMapPath -Raw
        $requiredDocKeywords = @(
            "LocalUILogic",
            "SceneUI",
            "SaveData",
            "Network",
            "ECAFunction",
            "ECAHelper",
            "Pool",
            "Reload"
        )
        $missingDocKeywords = @()
        foreach ($keyword in $requiredDocKeywords) {
            if (-not $docMapText.Contains($keyword)) {
                $missingDocKeywords += $keyword
            }
        }
        if ($missingDocKeywords.Count -gt 0) {
            $checks.Add((New-Check -Id "public_doc_map_coverage" -Status "error" -Message "Required API map keywords are missing." -Items $missingDocKeywords))
        }
        else {
            $checks.Add((New-Check -Id "public_doc_map_coverage" -Status "ok" -Message "Required API map keywords exist."))
        }
    }
    else {
        $checks.Add((New-Check -Id "public_doc_map_coverage" -Status "error" -Message "kernel-public-doc-map.md is missing."))
    }

    $initPath = Join-Path $root "init.lua"
    if (Test-Path -LiteralPath $initPath) {
        $mountCount = @(Select-String -LiteralPath $initPath -Pattern "^\s*y3\.[A-Za-z0-9_]+\s*=" | ForEach-Object { $_ }).Count
        if ($mountCount -gt 0) {
            $checks.Add((New-Check -Id "init_mounts_detected" -Status "ok" -Message "init.lua y3 mounts detected." -Items @($mountCount)))
        }
        else {
            $checks.Add((New-Check -Id "init_mounts_detected" -Status "warning" -Message "No y3 mounts were detected in init.lua."))
        }
    }

    $errorCount = @($checks | Where-Object { $_.status -eq "error" }).Count
    $warningCount = @($checks | Where-Object { $_.status -eq "warning" }).Count
    $status = "ok"
    if ($errorCount -gt 0) {
        $status = "error"
    }
    elseif ($warningCount -gt 0) {
        $status = "warning"
    }

    $result = [ordered]@{
        schemaVersion = 1
        status = $status
        checkedAt = (Get-Date).ToString("o")
        summary = [ordered]@{
            errors = $errorCount
            warnings = $warningCount
            checks = $checks.Count
        }
        checks = @($checks)
        errors = @($checks | Where-Object { $_.status -eq "error" })
    }
}
catch {
    $result = [ordered]@{
        schemaVersion = 1
        status = "error"
        checkedAt = (Get-Date).ToString("o")
        summary = [ordered]@{ errors = 1; warnings = 0; checks = 0 }
        checks = @()
        errors = @([ordered]@{
            id = "CHECK_FAILED"
            status = "error"
            message = $_.Exception.Message
            items = @()
        })
    }
}

if ($Json) {
    $result | ConvertTo-Json -Depth 20
}
else {
    Write-Output "[INFO] status: $($result.status)"
    foreach ($check in $result.checks) {
        $label = "[OK]"
        if ($check.status -eq "warning") {
            $label = "[WARN]"
        }
        elseif ($check.status -eq "error") {
            $label = "[ERROR]"
        }
        Write-Output "$label $($check.id): $($check.message)"
    }
    if ($result.status -eq "error") {
        exit 1
    }
}
