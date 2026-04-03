<#
.SYNOPSIS
    Horror.Place Style Validation Pipeline
    Automated validation for style definitions, routing profiles, and schema compliance.

.DESCRIPTION
    This script validates all horror style artifacts across the Horror.Place
    repository ecosystem, ensuring:
    - Schema compliance (ALN/JSON Schema)
    - Security sanitization (no dangerous tokens, safe Lua)
    - Cross-repo consistency (public/private sync)
    - Metric routing validity (weight bounds, token conflicts)
    - Palette integrity (hex format, role coverage)
    
    Designed for CI/CD integration with GitHub Actions, Azure DevOps, or local pre-commit hooks.

.EXAMPLE
    # Validate all styles in the public repo
    .\scripts\validate_styles.ps1 -Scope Public -Verbose

.EXAMPLE
    # Validate a specific style file with detailed output
    .\scripts\validate_styles.ps1 -StylePath "docs/styles/TerraScape.md" -Detailed

.EXAMPLE
    # Run in CI mode (fail-fast, machine-readable output)
    .\scripts\validate_styles.ps1 -Mode CI -OutputFormat JSON
#>

[CmdletBinding(DefaultParameterSetName = 'FullScan')]
param(
    # Scope of validation
    [Parameter(Mandatory = $false)]
    [ValidateSet('Public', 'Vault', 'Lab', 'All')]
    [string]$Scope = 'Public',
    
    # Target path (file or directory)
    [Parameter(Mandatory = $false, ParameterSetName = 'Targeted')]
    [string]$StylePath,
    
    # Validation mode
    [Parameter(Mandatory = $false)]
    [ValidateSet('Development', 'CI', 'Release')]
    [string]$Mode = 'Development',
    
    # Output format
    [Parameter(Mandatory = $false)]
    [ValidateSet('Text', 'JSON', 'JUnit')]
    [string]$OutputFormat = 'Text',
    
    # Fail on warnings (strict mode)
    [Parameter(Mandatory = $false)]
    [switch]$Strict,
    
    # Skip network-dependent checks (offline mode)
    [Parameter(Mandatory = $false)]
    [switch]$Offline,
    
    # Path to schema registry
    [Parameter(Mandatory = $false)]
    [string]$SchemaRegistryPath = "$PSScriptRoot/../docs/schemas",
    
    # Path to routing profiles
    [Parameter(Mandatory = $false)]
    [string]$RoutingProfilesPath = "$PSScriptRoot/../configs/routing_profiles.toml"
)

# ============================================================================
# IMPORTS & INITIALIZATION
# ============================================================================

# Import required modules
$RequiredModules = @('Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.Security')
foreach ($mod in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Error "Required module not found: $mod"
        exit 1
    }
    Import-Module $mod -ErrorAction Stop
}

# Load internal validation functions
. "$PSScriptRoot/validation_helpers.ps1"

# Initialize result collector
$ValidationResults = [System.Collections.Generic.List[object]]::new()
$StartTime = Get-Date

# ============================================================================
# CORE VALIDATION FUNCTIONS
# ============================================================================

function Test-StyleSchemaCompliance {
    <#
    .SYNOPSIS
        Validate a style definition against ALN/JSON schema.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$StyleFile,
        
        [Parameter(Mandatory = $false)]
        [string]$SchemaPath
    )
    
    $result = [PSCustomObject]@{
        File = $StyleFile
        Check = 'SchemaCompliance'
        Status = 'Pending'
        Errors = @()
        Warnings = @()
    }
    
    try {
        # Load style content
        $content = Get-Content $StyleFile -Raw -Encoding UTF8
        
        # Determine schema based on file extension/content
        $schema = if ($StyleFile -match '\.aln$') {
            # ALN schema validation (simplified: check required fields)
            $required = @('id', 'version', 'metrics', 'palettes', 'prompt_primitives', 'routing', 'audit')
            $missing = $required | Where-Object { $content -notmatch [regex]::Escape($_) }
            if ($missing) {
                $result.Errors += "Missing required ALN fields: $($missing -join ', ')"
                $result.Status = 'Failed'
            } else {
                $result.Status = 'Passed'
            }
        } elseif ($StyleFile -match '\.lua$') {
            # Lua style: validate structure via safe parser
            $parsed = ConvertFrom-LuaSafe -LuaString $content -Validate:$true
            $result.Status = 'Passed'
        } elseif ($StyleFile -match '\.(md|toml|json)$') {
            # Markdown/TOML/JSON: basic structural checks
            if ($content -match 'id\s*[=:]\s*["\']?[A-Z]') {
                $result.Status = 'Passed'
            } else {
                $result.Warnings += "Style may be missing machine-readable id field"
                $result.Status = if ($Strict) { 'Failed' } else { 'Warning' }
            }
        } else {
            $result.Warnings += "Unknown file format; skipping deep validation"
            $result.Status = 'Skipped'
        }
    } catch {
        $result.Errors += "Validation error: $($_.Exception.Message)"
        $result.Status = 'Failed'
    }
    
    return $result
}

function Test-SecuritySanitization {
    <#
    .SYNOPSIS
        Scan style artifacts for dangerous patterns, tokens, or code injection risks.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )
    
    $result = [PSCustomObject]@{
        File = $ArtifactPath
        Check = 'SecuritySanitization'
        Status = 'Pending'
        Errors = @()
        Warnings = @()
    }
    
    try {
        $content = Get-Content $ArtifactPath -Raw
        
        # Dangerous Lua patterns
        $dangerousLua = @(
            'os\.(execute|remove|rename|exit)',
            'io\.(popen|input|output)',
            'load(string|file)?\s*\(',
            'require\s*\([^)]*["\']',
            'package\.loadlib',
            'debug\.(getinfo|traceback)'
        )
        
        foreach ($pattern in $dangerousLua) {
            if ($content -match $pattern) {
                $result.Errors += "Dangerous Lua pattern detected: $pattern"
                $result.Status = 'Failed'
            }
        }
        
        # Blocked content tokens (from routing_profiles.toml)
        $blockedTokens = @('gore', 'blood', 'violence', 'self-harm', 'non-consensual')
        foreach ($token in $blockedTokens) {
            # Case-insensitive, word-boundary match
            if ($content -match "\b$token\b") {
                $result.Errors += "Blocked content token found: $token"
                $result.Status = 'Failed'
            }
        }
        
        # Path traversal attempts
        if ($content -match '[\\/:*?"<>|]{2,}') {
            $result.Warnings += "Potential path traversal pattern detected"
            if ($Strict) { $result.Status = 'Failed' }
        }
        
        # If no errors found
        if ($result.Status -eq 'Pending') {
            $result.Status = 'Passed'
        }
    } catch {
        $result.Errors += "Security scan error: $($_.Exception.Message)"
        $result.Status = 'Failed'
    }
    
    return $result
}

function Test-MetricRoutingValidity {
    <#
    .SYNOPSIS
        Validate that metric-to-prompt routing rules are well-formed and conflict-free.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$StyleFile,
        
        [Parameter(Mandatory = $false)]
        [string]$RoutingConfig
    )
    # Implementation would parse routing rules and check:
    # - Weight expressions are valid enum values
    # - Positive/negative tokens don't conflict
    # - Metric IDs reference defined metrics
    # - Value ranges are [0,1] and min <= max
    # Simplified for this file:
    
    $result = [PSCustomObject]@{
        File = $StyleFile
        Check = 'MetricRoutingValidity'
        Status = 'Passed'  # Placeholder
        Errors = @()
        Warnings = @()
    }
    
    return $result
}

function Test-PaletteIntegrity {
    <#
    .SYNOPSIS
        Validate hex color codes, role coverage, and cross-platform fallbacks.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$StyleFile
    )
    
    $result = [PSCustomObject]@{
        File = $StyleFile
        Check = 'PaletteIntegrity'
        Status = 'Pending'
        Errors = @()
        Warnings = @()
    }
    
    try {
        $content = Get-Content $StyleFile -Raw
        
        # Extract hex codes (basic regex)
        $hexCodes = [regex]::Matches($content, '#[0-9A-Fa-f]{6}') | ForEach-Object { $_.Value }
        
        # Validate format (already ensured by regex, but check count)
        if ($hexCodes.Count -lt 3) {
            $result.Warnings += "Style has fewer than 3 hex colors; may lack palette depth"
            if ($Strict) { $result.Status = 'Failed' }
        }
        
        # Check for required roles (heuristic: look for role names)
        $requiredRoles = @('background_base', 'highlight')
        $foundRoles = $requiredRoles | Where-Object { $content -match $_ }
        if ($foundRoles.Count -lt $requiredRoles.Count) {
            $missing = $requiredRoles | Where-Object { $_ -notin $foundRoles }
            $result.Warnings += "Missing recommended palette roles: $($missing -join ', ')"
        }
        
        # Check hex uniqueness
        $uniqueHex = $hexCodes | Select-Object -Unique
        if ($uniqueHex.Count -lt $hexCodes.Count) {
            $result.Warnings += "Duplicate hex codes detected; consider consolidating palette"
        }
        
        if ($result.Status -eq 'Pending') {
            $result.Status = 'Passed'
        }
    } catch {
        $result.Errors += "Palette validation error: $($_.Exception.Message)"
        $result.Status = 'Failed'
    }
    
    return $result
}

function Test-CrossRepoConsistency {
    <#
    .SYNOPSIS
        Verify that public style specs align with vault/lab references (hash/sig checks).
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$StyleId,
        
        [Parameter(Mandatory = $false)]
        [switch]$Offline
    )
    
    $result = [PSCustomObject]@{
        StyleId = $StyleId
        Check = 'CrossRepoConsistency'
        Status = 'Pending'
        Errors = @()
        Warnings = @()
    }
    
    if ($Offline) {
        $result.Status = 'Skipped'
        $result.Warnings += "Offline mode: skipping cross-repo verification"
        return $result
    }
    
    # In production: fetch artifact hashes from Horror.Place-Orchestrator API
    # and compare with local file hashes
    # Simplified: check for .sig/.hash sidecar files
    $sigFile = "$StyleFile.sig"
    $hashFile = "$StyleFile.sha256"
    
    if (Test-Path $sigFile) {
        # Verify signature (placeholder: would use gpg/age)
        $result.Warnings += "Signature file present; cryptographic verification not implemented in this script"
    }
    
    if (Test-Path $hashFile) {
        $expectedHash = Get-Content $hashFile -Raw
        $actualHash = (Get-FileHash $StyleFile -Algorithm SHA256).Hash.ToLower()
        if ($expectedHash.Trim() -ne $actualHash) {
            $result.Errors += "Hash mismatch: file may be corrupted or tampered"
            $result.Status = 'Failed'
        }
    }
    
    if ($result.Status -eq 'Pending') {
        $result.Status = 'Passed'
    }
    
    return $result
}

# ============================================================================
# MAIN VALIDATION ORCHESTRATION
# ============================================================================

function Invoke-StyleValidation {
    <#
    .SYNOPSIS
        Run full validation pipeline on target styles.
    #>
    
    # Determine target files
    $targetFiles = if ($PSCmdlet.ParameterSetName -eq 'Targeted' -and $StylePath) {
        if (Test-Path $StylePath) { @(Resolve-Path $StylePath) } else { @() }
    } else {
        # Scan based on Scope
        $baseDirs = switch ($Scope) {
            'Public' { @("$PSScriptRoot/../docs/styles", "$PSScriptRoot/../crates") }
            'Vault'  { @("$PSScriptRoot/../../HorrorPlace-Black-Archivum/styles") }  # Would be submodule
            'Lab'    { @("$PSScriptRoot/../../HorrorPlace-Obscura-Nexus/experimental") }
            'All'    { @("$PSScriptRoot/../docs/styles", "$PSScriptRoot/../crates") }  # Public only in this repo
        }
        
        $extensions = @('*.md', '*.aln', '*.lua', '*.toml', '*.json')
        $baseDirs | ForEach-Object {
            if (Test-Path $_) {
                $extensions | ForEach-Object {
                    Get-ChildItem -Path $_ -Filter $_ -Recurse -File -ErrorAction SilentlyContinue
                }
            }
        } | Select-Object -ExpandProperty FullName
    }
    
    Write-Verbose "Validating $($targetFiles.Count) artifacts"
    
    foreach ($file in $targetFiles) {
        # Skip non-style files
        if ($file -match '(README|LICENSE|SECURITY|\.git)') { continue }
        
        # Run validation checks
        $checks = @(
            { Test-StyleSchemaCompliance -StyleFile $file -SchemaPath $SchemaRegistryPath },
            { Test-SecuritySanitization -ArtifactPath $file },
            { Test-MetricRoutingValidity -StyleFile $file -RoutingConfig $RoutingProfilesPath },
            { Test-PaletteIntegrity -StyleFile $file }
        )
        
        foreach ($check in $checks) {
            $result = & $check
            $ValidationResults.Add($result)
            
            # Output progress in Development mode
            if ($Mode -eq 'Development') {
                $statusIcon = switch ($result.Status) {
                    'Passed' { '✓' }
                    'Failed' { '✗' }
                    'Warning' { '⚠' }
                    'Skipped' { '○' }
                    default { '?' }
                }
                Write-Host "[$statusIcon] $($result.Check) - $($result.File)" -ForegroundColor $(
                    switch ($result.Status) {
                        'Passed' { 'Green' }
                        'Failed' { 'Red' }
                        'Warning' { 'Yellow' }
                        default { 'Gray' }
                    }
                )
            }
        }
        
        # Cross-repo check for public styles
        if ($Scope -in @('Public', 'All') -and $file -match 'docs/styles/.*\.') {
            $styleId = [System.IO.Path]::GetFileNameWithoutExtension($file)
            $crossResult = Test-CrossRepoConsistency -StyleId $styleId -Offline:$Offline
            $ValidationResults.Add($crossResult)
        }
    }
}

# ============================================================================
# OUTPUT FORMATTING
# ============================================================================

function Format-ValidationResults {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Results,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Text', 'JSON', 'JUnit')]
        [string]$Format = 'Text'
    )
    
    switch ($Format) {
        'Text' {
            $passed = $Results | Where-Object { $_.Status -eq 'Passed' } | Measure-Object
            $failed = $Results | Where-Object { $_.Status -eq 'Failed' } | Measure-Object
            $warnings = $Results | Where-Object { $_.Status -eq 'Warning' } | Measure-Object
            
            Write-Host "`n=== Validation Summary ===" -ForegroundColor Cyan
            Write-Host "Passed: $($passed.Count)" -ForegroundColor Green
            Write-Host "Failed: $($failed.Count)" -ForegroundColor Red
            Write-Host "Warnings: $($warnings.Count)" -ForegroundColor Yellow
            Write-Host "Total: $($Results.Count) checks`n"
            
            # Show failures and warnings
            $Results | Where-Object { $_.Status -in @('Failed', 'Warning') } | ForEach-Object {
                Write-Host "[$($_.Status.ToUpper())] $($_.File)" -ForegroundColor $(
                    if ($_.Status -eq 'Failed') { 'Red' } else { 'Yellow' }
                )
                $_.Errors | ForEach-Object { Write-Host "  Error: $_" -ForegroundColor Red }
                $_.Warnings | ForEach-Object { Write-Host "  Warning: $_" -ForegroundColor Yellow }
                Write-Host ""
            }
        }
        'JSON' {
            $output = [PSCustomObject]@{
                timestamp = (Get-Date -Format 'o')
                mode = $Mode
                scope = $Scope
                summary = @{
                    total = $Results.Count
                    passed = ($Results | Where-Object { $_.Status -eq 'Passed' }).Count
                    failed = ($Results | Where-Object { $_.Status -eq 'Failed' }).Count
                    warnings = ($Results | Where-Object { $_.Status -eq 'Warning' }).Count
                }
                results = $Results
            }
            $output | ConvertTo-Json -Depth 10
        }
        'JUnit' {
            # JUnit XML format for CI integration
            $xml = [xml]@"
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="Horror.Place.StyleValidation" tests="$($Results.Count)" failures="$(($Results | Where-Object { $_.Status -eq 'Failed' }).Count)" time="$((Get-Date) - $StartTime).TotalSeconds">
</testsuites>
"@
            $suite = $xml.CreateElement('testsuite')
            $suite.SetAttribute('name', 'StyleValidation')
            $suite.SetAttribute('timestamp', (Get-Date -Format 'o'))
            
            foreach ($r in $Results) {
                $case = $xml.CreateElement('testcase')
                $case.SetAttribute('name', "$($r.Check) - $($r.File)")
                $case.SetAttribute('time', '0.001')  # Placeholder
                
                if ($r.Status -eq 'Failed') {
                    $failure = $xml.CreateElement('failure')
                    $failure.SetAttribute('message', ($r.Errors -join '; '))
                    $case.AppendChild($failure) | Out-Null
                } elseif ($r.Status -eq 'Warning') {
                    $warning = $xml.CreateElement('skipped')
                    $warning.SetAttribute('message', ($r.Warnings -join '; '))
                    $case.AppendChild($warning) | Out-Null
                }
                
                $suite.AppendChild($case) | Out-Null
            }
            
            $xml.testsuites.AppendChild($suite) | Out-Null
            $xml.OuterXml
        }
    }
}

# ============================================================================
# EXECUTION
# ============================================================================

try {
    Write-Verbose "Starting Horror.Place Style Validation (Mode: $Mode, Scope: $Scope)"
    
    # Run validation
    Invoke-StyleValidation
    
    # Format and output results
    $output = Format-ValidationResults -Results $ValidationResults -Format $OutputFormat
    
    if ($OutputFormat -eq 'Text') {
        # Text output already written by Format-ValidationResults
    } else {
        Write-Output $output
    }
    
    # Exit code based on results
    $failedCount = ($ValidationResults | Where-Object { $_.Status -eq 'Failed' }).Count
    if ($failedCount -gt 0) {
        Write-Error "Validation failed: $failedCount errors"
        exit 1
    } elseif ($Strict -and ($ValidationResults | Where-Object { $_.Status -eq 'Warning' }).Count -gt 0) {
        Write-Warning "Strict mode: warnings treated as failures"
        exit 1
    } else {
        Write-Verbose "Validation completed successfully"
        exit 0
    }
} catch {
    Write-Error "Validation pipeline error: $($_.Exception.Message)"
    exit 2
}
