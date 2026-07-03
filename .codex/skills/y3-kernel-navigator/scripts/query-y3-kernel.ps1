param(
    [Parameter(Mandatory = $true)]
    [string] $Query,

    [ValidateSet("all", "mount", "class", "function", "doc", "module", "object-layer", "converter", "extends", "ref-manager", "ui-layer")]
    [string] $Kind = "all",

    [int] $Limit = 20,

    [switch] $Exact,

    [switch] $Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Convert-ToSlashPath {
    param([string] $Path)
    return ($Path -replace "\\", "/")
}

function Find-Y3Root {
    param([string] $Start)

    $current = (Resolve-Path -LiteralPath $Start).Path
    while ($true) {
        $directInit = Join-Path $current "init.lua"
        $directGame = Join-Path $current "game"
        $directObject = Join-Path $current "object"
        if ((Test-Path -LiteralPath $directInit) -and (Test-Path -LiteralPath $directGame) -and (Test-Path -LiteralPath $directObject)) {
            return $current
        }

        $nested = Join-Path $current "y3"
        $nestedInit = Join-Path $nested "init.lua"
        $nestedGame = Join-Path $nested "game"
        $nestedObject = Join-Path $nested "object"
        if ((Test-Path -LiteralPath $nestedInit) -and (Test-Path -LiteralPath $nestedGame) -and (Test-Path -LiteralPath $nestedObject)) {
            return $nested
        }

        $parent = Split-Path -Parent $current
        if ($parent -eq $current -or [string]::IsNullOrWhiteSpace($parent)) {
            return $null
        }
        $current = $parent
    }
}

function New-Result {
    param(
        [string] $Status,
        [array] $Matches,
        [array] $Errors
    )

    return [ordered]@{
        schemaVersion = 1
        status = $Status
        query = [ordered]@{
            text = $Query
            kind = $Kind
            exact = [bool] $Exact
            limit = $Limit
        }
        matches = @($Matches | Select-Object -First $Limit)
        errors = @($Errors)
    }
}

function Test-Match {
    param([string] $Text)
    if ($null -eq $Text) {
        return $false
    }
    $queries = @($Query)
    if ($Query.Contains(".")) {
        $queries += ($Query.Split(".")[-1])
    }
    if ($Exact) {
        foreach ($item in $queries) {
            if ($Text -eq $item) {
                return $true
            }
        }
        return $false
    }
    foreach ($item in $queries) {
        if ($Text.IndexOf($item, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            return $true
        }
    }
    return $false
}

function Get-MatchRank {
    param([object] $Item)

    $names = @()
    if ($Item.Contains("name")) {
        $names += [string] $Item.name
    }
    if ($Item.Contains("module")) {
        $names += [string] $Item.module
    }
    if ($Item.Contains("source") -and $Item.source.Contains("path")) {
        $names += [string] $Item.source.path
    }

    $queryText = $Query
    $queryTail = $queryText
    if ($queryText.Contains(".")) {
        $queryTail = $queryText.Split(".")[-1]
    }

    foreach ($name in $names) {
        if ($name.Equals($queryText, [System.StringComparison]::OrdinalIgnoreCase) -or
            $name.Equals($queryTail, [System.StringComparison]::OrdinalIgnoreCase)) {
            return 0
        }
    }
    foreach ($name in $names) {
        $leaf = [System.IO.Path]::GetFileNameWithoutExtension($name)
        if ($leaf.Equals($queryText, [System.StringComparison]::OrdinalIgnoreCase) -or
            $leaf.Equals($queryTail, [System.StringComparison]::OrdinalIgnoreCase)) {
            return 1
        }
    }
    foreach ($name in $names) {
        if ($name.IndexOf($queryText, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            return 2
        }
    }
    return 3
}

function Test-ConverterRecordMatch {
    param(
        [object] $Record,
        [hashtable] $TypeAliasMap
    )

    if ((Test-Match $Record.method) -or
        (Test-Match $Record.name) -or
        (Test-Match $Record.target) -or
        (Test-Match $Record.text)) {
        return $true
    }

    $queries = @($Query)
    if ($Query.Contains(".")) {
        $queries += ($Query.Split(".")[-1])
    }
    foreach ($item in $queries) {
        if ($TypeAliasMap.ContainsKey($item)) {
            $pyType = $TypeAliasMap[$item]
            if ($Record.name -eq $pyType -or $Record.target -eq $pyType) {
                return $true
            }
        }
    }
    return $false
}

try {
    $root = Find-Y3Root -Start (Get-Location).Path
    if (-not $root) {
        $result = New-Result -Status "error" -Matches @() -Errors @([ordered]@{
            errorCode = "SOURCE_NOT_FOUND"
            message = "Y3 root was not found from the current directory or parents."
        })
    }
    else {
        $matches = [System.Collections.Generic.List[object]]::new()
        $sourceGlobs = @("init.lua", "game", "util", "tools", "object", "ui_framework", "meta")

        if ($Kind -eq "all" -or $Kind -eq "mount") {
            $mountFiles = @(
                (Join-Path $root "init.lua"),
                (Join-Path $root "ui_framework/init.lua")
            )
            foreach ($mountFile in $mountFiles) {
                if (-not (Test-Path -LiteralPath $mountFile)) {
                    continue
                }
                $relMount = Convert-ToSlashPath ([System.IO.Path]::GetRelativePath($root, $mountFile))
                $lines = Get-Content -LiteralPath $mountFile
                for ($i = 0; $i -lt $lines.Count; $i++) {
                    $line = $lines[$i]
                    $match = [regex]::Match($line, "^\s*(y3(?:\.[A-Za-z0-9_]+)+)\s*=\s*(?:require|include)\s*['""]([^'""]+)['""]")
                    if ($match.Success) {
                        $name = $match.Groups[1].Value
                        $module = $match.Groups[2].Value
                        if ((Test-Match $name) -or (Test-Match $module)) {
                            $matches.Add([ordered]@{
                                kind = "mount"
                                name = $name
                                module = $module
                                source = [ordered]@{
                                    path = $relMount
                                    line = $i + 1
                                }
                                text = $line.Trim()
                            })
                        }
                    }
                }
            }
        }

        $luaFiles = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
        foreach ($entry in $sourceGlobs) {
            $path = Join-Path $root $entry
            if (Test-Path -LiteralPath $path -PathType Leaf) {
                $luaFiles.Add((Get-Item -LiteralPath $path))
            }
            elseif (Test-Path -LiteralPath $path -PathType Container) {
                Get-ChildItem -LiteralPath $path -Recurse -File -Filter "*.lua" | ForEach-Object { $luaFiles.Add($_) }
            }
        }

        $converterRecords = [System.Collections.Generic.List[object]]::new()
        $typeAliasMap = @{}
        foreach ($file in $luaFiles) {
            $rel = Convert-ToSlashPath ([System.IO.Path]::GetRelativePath($root, $file.FullName))
            $lines = Get-Content -LiteralPath $file.FullName
            for ($i = 0; $i -lt $lines.Count; $i++) {
                $line = $lines[$i]
                $converterMatch = [regex]::Match($line, "(?:y3\.py_converter|M)\.(register_py_to_lua|register_lua_to_py|register_type_alias)\s*\(\s*['""]([^'""]+)['""](?:\s*,\s*['""]([^'""]+)['""])?")
                if ($converterMatch.Success) {
                    $method = $converterMatch.Groups[1].Value.Trim()
                    $fromType = $converterMatch.Groups[2].Value.Trim()
                    $toType = $converterMatch.Groups[3].Value.Trim()
                    if ($method -eq "register_type_alias" -and -not [string]::IsNullOrWhiteSpace($toType)) {
                        $typeAliasMap[$toType] = $fromType
                    }
                    $converterRecords.Add([ordered]@{
                        kind = "converter"
                        name = $fromType
                        method = $method
                        target = $toType
                        source = [ordered]@{ path = $rel; line = $i + 1 }
                        text = $line.Trim()
                    })
                }
            }
        }

        $extendsMatchIndex = @{}
        foreach ($file in $luaFiles) {
            $rel = Convert-ToSlashPath ([System.IO.Path]::GetRelativePath($root, $file.FullName))
            $lines = Get-Content -LiteralPath $file.FullName

            $objectLayerMatch = [regex]::Match($rel, "^object/(editable_object|runtime_object|scene_object)/([^/]+)\.lua$")
            if ($objectLayerMatch.Success -and ($Kind -eq "all" -or $Kind -eq "object-layer")) {
                $layer = $objectLayerMatch.Groups[1].Value
                $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                if ((Test-Match $name) -or (Test-Match $layer) -or (Test-Match $rel)) {
                    $matches.Add([ordered]@{
                        kind = "object-layer"
                        name = $name
                        layer = $layer
                        source = [ordered]@{ path = $rel; line = 1 }
                        text = $rel
                    })
                }
            }

            $isUiLayerFile = $false
            if ($rel -eq "object/scene_object/ui.lua" -or
                $rel -eq "object/scene_object/ui_prefab.lua" -or
                $rel -eq "object/scene_object/scene_ui.lua" -or
                $rel -eq "util/local_ui.lua" -or
                $rel.StartsWith("ui_framework/")) {
                $isUiLayerFile = $true
            }
            if ($isUiLayerFile -and ($Kind -eq "all" -or $Kind -eq "ui-layer")) {
                $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                if ((Test-Match $name) -or (Test-Match $rel)) {
                    $matches.Add([ordered]@{
                        kind = "ui-layer"
                        name = $name
                        source = [ordered]@{ path = $rel; line = 1 }
                        text = $rel
                    })
                }
            }

            for ($i = 0; $i -lt $lines.Count; $i++) {
                $line = $lines[$i]
                if ($Kind -eq "all" -or $Kind -eq "class") {
                    $classMatch = [regex]::Match($line, "^---@class\s+([^\s:]+(?:\s*:\s*[^\r\n]+)?)")
                    if ($classMatch.Success) {
                        $name = $classMatch.Groups[1].Value.Trim()
                        if (Test-Match $name) {
                            $matches.Add([ordered]@{
                                kind = "class"
                                name = $name
                                source = [ordered]@{ path = $rel; line = $i + 1 }
                                text = $line.Trim()
                            })
                        }
                    }
                }
                if ($Kind -eq "all" -or $Kind -eq "function") {
                    $funcMatch = [regex]::Match($line, "^function\s+([A-Za-z0-9_\.:-]+)\s*\(")
                    if ($funcMatch.Success) {
                        $name = $funcMatch.Groups[1].Value.Trim()
                        if (Test-Match $name) {
                            $matches.Add([ordered]@{
                                kind = "function"
                                name = $name
                                source = [ordered]@{ path = $rel; line = $i + 1 }
                                text = $line.Trim()
                            })
                        }
                    }
                }
                if ($Kind -eq "all" -or $Kind -eq "module") {
                    $requireMatch = [regex]::Match($line, "require\s*['""]([^'""]+)['""]")
                    if ($requireMatch.Success) {
                        $name = $requireMatch.Groups[1].Value.Trim()
                        if (Test-Match $name) {
                            $matches.Add([ordered]@{
                                kind = "module"
                                name = $name
                                source = [ordered]@{ path = $rel; line = $i + 1 }
                                text = $line.Trim()
                            })
                        }
                    }
                }
                if ($Kind -eq "all" -or $Kind -eq "extends") {
                    $classExtendsMatch = [regex]::Match($line, "^---@class\s+([^\s:]+)\s*:\s*([^\r\n]+)")
                    if ($classExtendsMatch.Success) {
                        $name = $classExtendsMatch.Groups[1].Value.Trim()
                        $extends = $classExtendsMatch.Groups[2].Value.Trim()
                        if ((Test-Match $name) -or (Test-Match $extends) -or (Test-Match $line)) {
                            $item = [ordered]@{
                                kind = "extends"
                                name = $name
                                extends = $extends
                                sourceKind = "annotation"
                                source = [ordered]@{ path = $rel; line = $i + 1 }
                                text = $line.Trim()
                            }
                            $key = $name + "`0" + $extends
                            if (-not $extendsMatchIndex.ContainsKey($key)) {
                                $extendsMatchIndex[$key] = $matches.Count
                                $matches.Add($item)
                            }
                        }
                    }
                    $extendsCallMatch = [regex]::Match($line, "Extends\s*\(\s*['""]([^'""]+)['""]\s*,\s*['""]([^'""]+)['""]")
                    if ($extendsCallMatch.Success) {
                        $name = $extendsCallMatch.Groups[1].Value.Trim()
                        $extends = $extendsCallMatch.Groups[2].Value.Trim()
                        if ((Test-Match $name) -or (Test-Match $extends) -or (Test-Match $line)) {
                            $item = [ordered]@{
                                kind = "extends"
                                name = $name
                                extends = $extends
                                sourceKind = "runtime"
                                source = [ordered]@{ path = $rel; line = $i + 1 }
                                text = $line.Trim()
                            }
                            $key = $name + "`0" + $extends
                            if ($extendsMatchIndex.ContainsKey($key)) {
                                $idx = $extendsMatchIndex[$key]
                                $matches[$idx] = $item
                            }
                            else {
                                $extendsMatchIndex[$key] = $matches.Count
                                $matches.Add($item)
                            }
                        }
                    }
                }
                if ($Kind -eq "all" -or $Kind -eq "ref-manager") {
                    $refMatch = [regex]::Match($line, "ref_manager\s*=\s*New\s*['""]Ref['""]\s*\(\s*['""]([^'""]+)['""]")
                    if ($refMatch.Success) {
                        $name = $refMatch.Groups[1].Value.Trim()
                        if ((Test-Match $name) -or (Test-Match $line)) {
                            $matches.Add([ordered]@{
                                kind = "ref-manager"
                                name = $name
                                source = [ordered]@{ path = $rel; line = $i + 1 }
                                text = $line.Trim()
                            })
                        }
                    }
                }
                if (($Kind -eq "all" -or $Kind -eq "ui-layer") -and $isUiLayerFile) {
                    $uiClassMatch = [regex]::Match($line, "^---@class\s+([^\s:]+)")
                    $uiFunctionMatch = [regex]::Match($line, "^function\s+([A-Za-z0-9_\.:-]+)\s*\(")
                    if ($uiClassMatch.Success) {
                        $name = $uiClassMatch.Groups[1].Value.Trim()
                        if (Test-Match $name) {
                            $matches.Add([ordered]@{
                                kind = "ui-layer"
                                name = $name
                                source = [ordered]@{ path = $rel; line = $i + 1 }
                                text = $line.Trim()
                            })
                        }
                    }
                    if ($uiFunctionMatch.Success) {
                        $name = $uiFunctionMatch.Groups[1].Value.Trim()
                        if (Test-Match $name) {
                            $matches.Add([ordered]@{
                                kind = "ui-layer"
                                name = $name
                                source = [ordered]@{ path = $rel; line = $i + 1 }
                                text = $line.Trim()
                            })
                        }
                    }
                }
            }
        }
        if ($Kind -eq "all" -or $Kind -eq "converter") {
            foreach ($record in $converterRecords) {
                if (Test-ConverterRecordMatch -Record $record -TypeAliasMap $typeAliasMap) {
                    $matches.Add($record)
                }
            }
        }
        if ($Kind -eq "all" -or $Kind -eq "doc") {
            $apiRoot = Join-Path $root "doc/API"
            if (Test-Path -LiteralPath $apiRoot) {
                Get-ChildItem -LiteralPath $apiRoot -File -Filter "*.md" | ForEach-Object {
                    $base = $_.BaseName
                    if (Test-Match $base) {
                        $matches.Add([ordered]@{
                            kind = "doc"
                            name = $base
                            source = [ordered]@{
                                path = Convert-ToSlashPath ([System.IO.Path]::GetRelativePath($root, $_.FullName))
                                line = 1
                            }
                            text = $_.Name
                        })
                    }
                    else {
                        $docLines = Get-Content -LiteralPath $_.FullName
                        for ($i = 0; $i -lt $docLines.Count; $i++) {
                            $line = $docLines[$i]
                            if ($line.StartsWith("## ") -and (Test-Match $line)) {
                                $matches.Add([ordered]@{
                                    kind = "doc"
                                    name = $line.Substring(3).Trim()
                                    source = [ordered]@{
                                        path = Convert-ToSlashPath ([System.IO.Path]::GetRelativePath($root, $_.FullName))
                                        line = $i + 1
                                    }
                                    text = $line.Trim()
                                })
                            }
                        }
                    }
                }
            }
        }

        $status = "ok"
        $errors = @()
        $matches = @($matches | Sort-Object @{ Expression = { Get-MatchRank $_ } }, @{ Expression = { $_.kind } }, @{ Expression = { $_.source.path } }, @{ Expression = { $_.source.line } })
        $result = New-Result -Status $status -Matches $matches -Errors $errors
    }
}
catch {
    $result = New-Result -Status "error" -Matches @() -Errors @([ordered]@{
        errorCode = "QUERY_FAILED"
        message = $_.Exception.Message
    })
}

if ($Json) {
    $result | ConvertTo-Json -Depth 20
}
else {
    if ($result.status -eq "ok") {
        Write-Output "[OK] matches: $($result.matches.Count)"
        foreach ($item in $result.matches) {
            $path = $item.source.path
            $line = $item.source.line
            Write-Output "$($item.kind) $($item.name) ${path}:$line"
        }
    }
    else {
        Write-Output "[ERROR] $($result.errors[0].errorCode): $($result.errors[0].message)"
        exit 1
    }
}
